# 08 — Docker: Containers for Development, Shipping, and Safe Agent Autonomy
> 🇰🇷 도커 3용도 완전 가이드: ① 에이전트를 안전하게 풀어놓는 개발 컨테이너 ② 스택별 프로덕션 이미지 ③ 개발용 compose. 복사해 쓰는 템플릿은 `templates/docker/`에 있다.

Quick conventions load automatically from `.claude/rules/docker.md` when you touch Docker files. This guide is the full treatment.

## 1. Containers as the safety boundary for agent autonomy

Approving every tool call kills flow; skipping approvals on your host machine is reckless. The resolution is environmental, not behavioral: **run Claude Code inside a container that has your repo, no production credentials, and a limited blast radius — then autonomy is safe because the walls are.** Inside such a sandbox, permissive modes (`--dangerously-skip-permissions`) become an acceptable trade; on a host with your SSH keys and cloud creds, they never are.

A minimal devcontainer (see `templates/docker/devcontainer.json`):

```jsonc
{
  "name": "project-dev",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu-24.04",
  "features": { "ghcr.io/devcontainers/features/node:1": { "version": "22" } },
  "postCreateCommand": "npm install -g @anthropic-ai/claude-code",
  "remoteUser": "vscode"
}
```

Rules of the sandbox: mount only the project (not `$HOME`); inject nothing beyond the API key it needs; prefer network restriction (Anthropic's reference devcontainer ships a firewall script allowlisting only necessary domains); treat the container as disposable — `git push` is what leaves, nothing else matters.
> 🇰🇷 요지: 에이전트를 조심시키는 게 아니라, 사고가 나도 무해한 방을 만들어 준다. 자율성은 벽이 만든다.

## 2. Production images — the six laws

1. **Multi-stage always**: heavy build stage → minimal runtime stage. Compilers, dev deps, and source never ship.
2. **Pin bases** (`node:22-slim`, `python:3.12-slim`, digest-pin for maximum rigor). `latest` is a time bomb with a random timer.
3. **Layer order = cache order**: manifests + dependency install *before* `COPY . .` — otherwise every source edit re-downloads the world. Add `--mount=type=cache` for package-manager stores.
4. **Non-root runtime** (`USER node` / a created `app` user). 
5. **`.dockerignore` is load-bearing**: `.git`, `node_modules`, `target`, `dist`, `.env*`, `docs`, `.claude` — without it, builds are slow AND secrets can leak into layers.
6. **HEALTHCHECK** every long-running service — it's what makes `depends_on: condition: service_healthy` and orchestrator restarts meaningful.

## 3. Per-stack annotated Dockerfiles (copies in `templates/docker/`)

### Node / pnpm

```dockerfile
# syntax=docker/dockerfile:1
FROM node:22-slim AS base
ENV PNPM_HOME=/pnpm PATH=$PNPM_HOME:$PATH
RUN corepack enable                                  # pnpm without a global install
WORKDIR /app

FROM base AS deps
COPY package.json pnpm-lock.yaml ./
RUN --mount=type=cache,target=/pnpm/store pnpm install --frozen-lockfile

FROM deps AS build
COPY . .
RUN pnpm build

FROM base AS runtime                                  # fresh slim stage: no dev deps, no source
ENV NODE_ENV=production
COPY package.json pnpm-lock.yaml ./
RUN --mount=type=cache,target=/pnpm/store pnpm install --prod --frozen-lockfile
COPY --from=build /app/dist ./dist
USER node
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:3000/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"
CMD ["node", "dist/index.js"]
```
Why it's shaped this way: lockfile-only layer caches dependency installs across source edits; the runtime stage reinstalls *prod-only* deps so devDependencies physically cannot ship; `corepack` keeps the pnpm version pinned by `package.json`'s `packageManager` field.

### Python / uv

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.12-slim AS base
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv   # uv without pip bootstrap
WORKDIR /app

FROM base AS deps
COPY pyproject.toml uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv uv sync --frozen --no-dev

FROM base AS runtime
COPY --from=deps /app/.venv /app/.venv
ENV PATH="/app/.venv/bin:$PATH"
COPY . .
RUN useradd -m app && chown -R app:app /app
USER app
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8000/health').status==200 else 1)"
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Rust (services & CI) — cargo-chef for sane caching

```dockerfile
# syntax=docker/dockerfile:1
FROM rust:1.79-slim AS chef
RUN cargo install cargo-chef
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json      # dependency "recipe" only

FROM chef AS builder
COPY --from=planner /app/recipe.json .
RUN cargo chef cook --release --recipe-path recipe.json   # deps compile: cached until Cargo.toml changes
COPY . .
RUN cargo build --release

FROM debian:bookworm-slim AS runtime
RUN useradd -m app
COPY --from=builder /app/target/release/mybin /usr/local/bin/mybin
USER app
CMD ["mybin"]
```
Without cargo-chef, every source edit recompiles all dependencies (minutes); with it, dependency layers cache until manifests change.

**Tauri note**: the desktop app itself is *not distributed* via Docker — users install native bundles. Docker's role in a Tauri project is (a) CI build containers with the Linux GUI deps (`libwebkit2gtk-4.1-dev`, `libgtk-3-dev`, `libayatana-appindicator3-dev`, etc.) for reproducible `tauri build`, and (b) containerizing any *backend services* the app talks to, per the patterns above.

## 4. Development compose (copy: `templates/docker/docker-compose.dev.yml`)

```yaml
services:
  app:
    build: { context: ., target: deps }     # stop at deps stage; run dev server on top
    command: pnpm dev
    volumes:
      - .:/app                              # hot reload: source mounted
      - /app/node_modules                   # …but container's node_modules masked from host
    env_file: .env                          # gitignored; never baked into images
    ports: ["3000:3000"]
    depends_on:
      db: { condition: service_healthy }    # start AFTER the db actually answers
  db:
    image: postgres:16-alpine
    environment: { POSTGRES_PASSWORD: dev }
    ports: ["5432:5432"]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 3s
      retries: 10
    volumes: [ dbdata:/var/lib/postgresql/data ]
volumes:
  dbdata:
```
The two patterns worth internalizing: the **anonymous-volume mask** (`/app/node_modules`) that keeps Linux-built binaries from colliding with host installs, and **healthcheck-gated startup** (`service_healthy`) that replaces "sleep 5 and pray".

## 5. Secrets — the three commandments

1. **Never `COPY` a `.env`** or secret file into an image (the `.dockerignore` line is your seatbelt; the COMPASS guard-secrets hook is another).
2. **Never pass secrets via `ARG`/`ENV` at build time** — both persist inspectably in image history. Build-time need → BuildKit: `RUN --mount=type=secret,id=npm_token pnpm install` with `docker build --secret id=npm_token,src=...`.
3. **Runtime secrets arrive from outside**: env injection from the platform, compose `env_file` (gitignored), or a secret manager. The image itself stays secret-free and therefore shareable.

## 6. Operational hygiene

- **Scan** (`docker scout cves` / `trivy image`) in CI; rebuild when base images patch.
- **12-factor runtime**: config via env; logs to stdout/stderr only; handle SIGTERM and exit within the grace period (`CMD` in exec-JSON form so signals actually reach your process — shell form swallows them).
- **Slim vs alpine vs distroless**: default `-slim` (glibc, fewest surprises); alpine when size rules and musl quirks are understood; distroless for maximum-hardening final stages once debugging needs are settled.
- Tag images with the git sha (`app:a1b2c3d`) — "what exactly is running?" should never be a mystery.
> 🇰🇷 요약: 스캔은 CI에서, 로그는 stdout으로, 설정은 env로, 시그널은 exec 형식 CMD로, 태그는 커밋 해시로.
