---
paths:
  - "**/Dockerfile*"
  - "**/docker-compose*.y*ml"
  - "**/compose*.y*ml"
  - ".devcontainer/**"
  - "**/.dockerignore"
---

# Docker Rules
> 🇰🇷 Dockerfile/compose 작업 시 자동 적용. 심화 내용은 guides/08-docker.md.

- **Multi-stage always**: build stage → slim runtime stage. Dev tools, compilers, and source never ship in the final image.
- **Pin base images** to at least minor version (`node:22-slim`, `python:3.12-slim`), never bare `latest`.
- **Layer order = cache order**: copy manifests (`package.json`+lockfile / `Cargo.toml` / `pyproject.toml`+lock) and install deps BEFORE copying source. Use `--mount=type=cache` for package-manager caches.
- **Non-root runtime**: `USER node` / created `app` user in the final stage. Root containers are a finding, not a default.
- **.dockerignore is mandatory** and includes at minimum: `.git`, `node_modules`, `target`, `dist`, `.env*`, `docs`, `.claude`.
- **Secrets never enter images**: no `COPY .env`, no secrets in `ARG`/`ENV` (they persist in layers). Build-time → BuildKit `--mount=type=secret`; runtime → environment/secret manager.
- **HEALTHCHECK** on every long-running service; compose `depends_on` uses `condition: service_healthy`, not prayer.
- 12-factor runtime: config via env, logs to stdout/stderr (no log files in containers), handle SIGTERM for graceful shutdown.
- Dev vs prod: compose file + volumes for hot-reload in dev; the production image never mounts source.
- Scan before ship (`docker scout` / `trivy`); rebuild on base-image CVEs.
