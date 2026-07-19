# COMPASS

> **🇰🇷 처음이신가요? → [`START_HERE.md`](START_HERE.md)** — 30분 온보딩: 정직한 장단점, 설치 함정 2개, 연습 미션, 문제해결. 이 README는 전체 참조 문서이고, 한 장짜리 전체 사용법은 [`COMPASS-USAGE-GUIDE.md`](COMPASS-USAGE-GUIDE.md)입니다.

**An agentic engineering operating system for Claude Code** — clarify-first interviews, trade-off-driven decisions, bloat-proof modules, an always-current codebase index, living checklists, and a durable-state architecture that survives 1M+ token, multi-week projects.

> 🇰🇷 COMPASS는 클로드 코드용 '에이전트 엔지니어링 운영체계'입니다. 요구를 90% 이상 이해하기 전엔 코드를 쓰지 않고, 중요한 결정마다 효율형/효과형 선택지를 견주고, 파일 비대화를 훅으로 감시하고, 코드베이스 색인을 항상 최신으로 유지하며, 컨텍스트 창을 아득히 넘는 장기 프로젝트에서도 "디스크가 진실"이라는 원칙으로 무너지지 않게 설계되었습니다.

**Tagline:** *Disk is truth, context is cache.*
**C**larify · **O**ptions · **M**ap · **P**lan · **A**ct · **S**crutinize · **S**ustain

---

## Install (2 minutes)

### Mode A — per project (recommended)
Copy the contents of this folder into your project root, merging with what's there:

```bash
# from inside the unzipped COMPASS folder:
cp -r CLAUDE.md .claude docs guides templates /path/to/your-project/
cd /path/to/your-project && git add -A && git commit -m "chore: install COMPASS"
```

Start `claude` in the project. Done — the SessionStart hook will greet you with your project state.

> 🇰🇷 방법 A: 이 폴더 내용물을 프로젝트 루트에 복사. 그게 전부입니다.

### Mode B — pieces globally
`CLAUDE.md`(내용을 `~/.claude/CLAUDE.md`에 병합), `.claude/agents/`, `.claude/commands/`, `.claude/skills/`는 `~/.claude/` 아래에 두면 모든 프로젝트에 적용됩니다. 단, hooks/settings와 `docs/` 상태 파일은 프로젝트별 설치를 권장합니다 (경로 스코프 rules는 사용자 레벨에서 동작이 불안정한 버전이 있음 — 아래 Compatibility 참조).

### Mode C — as a plugin
For many repos, package as a Claude Code plugin — recipe in `guides/10-extensibility.md`.

### Add to your project's `.gitignore`
```
.claude/settings.local.json
.claude/secrets.unlock
.env*
!.env.example
```

---

## Quickstart — the golden path

```
/setup                                     ← once per project: profile it into docs/PROJECT.md
/spec 문서 검색 SaaS를 만들고 싶어요        ← interview until ≥90% confidence → docs/SPEC.md
/blueprint                                      ← options (A효율/B효과/C균형) → PLAN + TODO
/next                                      ← one task: build → verify → state updated  (repeat)
/inspect                                    ← independent reviewer must PASS
/checkpoint                                ← save-game: docs honest + git commit
```

**New to driving this? `guides/14-daily-playbook.md`** has two fully annotated real sessions (22 prompts) showing exactly what to type when; **`guides/15-scenarios.md`** shows the same system across three scales — a weekend Firebase prototype, a paid MVP, and a months-long 1M+-token product. Next session: just open `claude` — your state auto-loads. `/restore` for the deep restore. When lost, `CLAUDE.md`'s routing table tells you which command fits.

> 🇰🇷 /setup 1회 + 다섯 커맨드 루프가 황금 경로입니다. 새 세션에서는 그냥 시작하세요 — 훅이 진행상황을 자동 주입합니다.

---


## Good first prompts — 좋은 첫 지시의 형태

The interview does the heavy lifting, so your first message doesn't need to be perfect — it needs to carry **goal + context + constraints + honest unknowns**. Describe the problem and situation; let `/spec` extract the rest. Two copy-paste shapes:

**New product (신규):**
```
/spec 팀 없이 혼자 운영할 문서 검색 SaaS를 만들고 싶어요.
목표: 사내 문서가 흩어져 못 찾는 문제 해결, 월 구독으로 수익화.
상황: 고객은 10~50인 한국 기업, 온프레미스 판매 가능성도 있음.
제약: Supabase+TypeScript 선호, 3개월 안에 첫 유료 고객.
잘 모르겠는 것: 검색 품질을 어느 수준까지 맞춰야 팔리는지, 가격.
```

**Existing codebase (기존 코드베이스에 도입):**
```
/map           ← 먼저 색인을 만들어 현재 구조를 파악하게 한 뒤
/spec 이 프로젝트에 결제(구독) 기능을 추가하고 싶어요. 현재 auth는
Supabase를 쓰고 있고, Stripe를 고려 중이지만 확신은 없습니다.
```

**Permanent directives (영구 지침)**: anything that must survive every compaction and session — language policy, forbidden dependencies, security invariants — goes in during `/setup`, or any time later with one stroke: `/remember 모든 사용자 노출 문구는 한/영 병기`. It lands in `.claude/rules/project-directives.md`, which loads in every session, forever.

Anti-patterns: prescribing the solution in message one ("Redis 붙여줘" — say the problem instead, the tradeoff analysis will earn the solution), and dumping a 3-page spec you wrote alone (paste it, but *as interview input*: `/spec 아래 초안을 검토하고 빈틈을 질문해줘: ...`).
> 🇰🇷 요령: 완벽한 지시문을 쓰려 하지 말 것. 목표·상황·제약·모르는 것 네 가지만 담으면 인터뷰가 나머지를 끌어낸다.


## Migrating from a manual workflow — 수동 운용에서 갈아타기

Already running "Opus advisor + Sonnet worker, max effort, plan mode, bypass permissions, save-then-compact near the limit"? COMPASS is that workflow, automated and made durable:

| Your manual habit | COMPASS equivalent | What changes |
|---|---|---|
| Set Opus advisor + Sonnet worker by hand | `/setup` asks once (step 3c) and enables `opusplan` in `.claude/settings.local.json` + `model: opus` pins on `architect` / `/setup` `/spec` `/blueprint` | One interview answer — no hand-editing |
| `/effort max` | Keep it; `ultrathink` is additionally baked into `/setup` `/spec` `/blueprint` `/improve` | Unchanged |
| Declare the goal in plan mode | `/setup` (once per project) → `/spec` (per feature) → `/blueprint` | The plan lands on **disk** (PLAN.md/TODO.md), not in volatile context |
| `--dangerously-skip-permissions` on the host | Same flag, **inside the devcontainer** (`templates/docker/devcontainer.json`); `acceptEdits` on the host | Hooks (secrets-block, bloat, stop-gate) still run even in bypass mode — but the container wall is the real safety |
| Near the window limit: "save to memory" → `/compact` | At **~60%**: `/checkpoint` → `/compact` (focused); at a phase boundary: `/checkpoint` → `/clear` | Ad-hoc saving becomes a protocol; state auto-reinjects via the SessionStart hook. Directives go to `/remember`, state goes to `/checkpoint` — two tools, not one vague ask |

> 🇰🇷 요약: 습관은 그대로, 위치와 타이밍만 바뀐다 — 계획은 디스크로, bypass는 컨테이너로, 저장은 60%에서 프로토콜로.

## What's inside

| Path | What it is |
|---|---|
| `CLAUDE.md` | The constitution (~95 lines): state machine, 12 rules, routing table |
| `.claude/settings.json` | Secrets deny-list, hook wiring, statusline |
| `.claude/hooks/` | **The law + the co-pilot**: guard-secrets · post-edit (auto-format + bloat budget + checkpoint counter) · session-resume (state injection + situation-aware suggestions) · stop-gate · statusline |
| `.claude/agents/` | `architect` (Opus advisor, read-only) · `code-reviewer` (Sonnet) · `explorer` (Haiku scout) |
| `.claude/commands/` | `/setup` `/spec` `/blueprint` `/next` `/inspect` `/checkpoint` `/restore` `/map` `/improve` `/advise` `/healthcheck` `/remember` `/research` `/secrets` |
| `.claude/skills/` | requirement-interview · tradeoff-analysis · codebase-map · bloat-guard · long-horizon · definition-of-done · **research** |
| `.claude/rules/` | **project-directives (always-on 영구 지침)** + path-scoped stack conventions: TypeScript · Rust/Tauri · Python · Java · Supabase/Firebase · PostgreSQL · AI/LLM · Docker · UI/Design |
| `docs/` | **Durable state** (pre-seeded): **PROJECT (charter)** · SPEC · PLAN · TODO · PROGRESS · CODEBASE_MAP · DECISIONS · SESSION_LOG · BACKLOG · **inputs/ (참고 자료 투입구)** · **research/ (조사 보관소)** |
| `guides/00–16` | Deep rationale, read on demand — incl. **07 Long-Horizon (1M+ tokens)**, **08 Docker**, **12 Design Systems (Astryx)**, **13 Mobile Apps & Monetization**, **14 Daily Playbook (실전 운전법)**, **15 Scenarios by Scale (규모별 3막 시나리오)**, **16 Public-Sector Design (KRDS)** |
| `templates/` | Pristine copies of every docs file + Docker templates + **CI workflow** + **design/ (KRDS 토큰·컴포넌트·데모)** + `.mcp.json.example` |

## What loads when (context economics)

| Layer | Loads | Idle cost |
|---|---|---|
| CLAUDE.md | every session | always (kept lean on purpose) |
| rules/*.md | when a matching file is touched | ~0 |
| skills | when the task matches the description | ~60 tokens each |
| subagents / guides / templates | on invocation / on demand | 0 |

---





## Bringing your own research — docs/inputs/

Already did deep research, wrote a PRD, or have requirement notes? Drop those `.md` files into **`docs/inputs/`** before running `/setup`. It reads them first, distills the key facts into `docs/PROJECT.md`, drafts a `docs/SPEC.md` from your requirements, files reusable findings into `docs/research/`, and then interviews you only about what your documents *didn't* already answer — surfacing any conflicts instead of silently resolving them. The originals stay as source-of-truth but never load every session (zero idle token cost). Messy input is fine; state your goal and hard constraints explicitly and `/setup` extracts the rest.

> 🇰🇷 미리 연구한 문서를 `docs/inputs/`에 넣고 `/setup`을 실행하면, 그 내용을 먼저 분석해 PROJECT·SPEC 초안·research로 증류하고, 문서가 답하지 않은 것만 인터뷰합니다. 원본은 항상 로드되지 않아 토큰 낭비가 없습니다.



## Public-sector design layer — 공공기관 디자인 (KRDS)

For Korean government/public-institution work, `templates/design/` ships a **measured, not asserted** design layer: KRDS-anchored token file (every text/background pair computed against WCAG — 16/16 PASS, e.g. body 16.18:1, buttons 4.55:1), base stylesheet encoding Korean typography law (Pretendard GOV 17px · 150% · letter-spacing 0 · `word-break: keep-all`), reference components (buttons/forms/cards/badges/alerts — borders not shadows, one primary per screen), a Tailwind v4 `@theme` bridge, and a zero-inline-style demo page. The **magic-number rule** (token grade diff ≥50 ⇒ 4.5:1) lets you pick compliant pairs by arithmetic. Per-client playbook (표준형/확장형/GOV.UK풍/대시보드): `guides/16-public-sector-design.md`. Inline `style=` on tags is now review-blocking everywhere (three honest exceptions documented).

> 🇰🇷 공공 작업의 접근성은 주장이 아니라 실측이다 — 토큰 파일의 모든 조합이 계산으로 검증되어 있고, 리뷰어가 인라인 스타일과 4.5:1 미달을 차단한다.

## Real assets & Korean responses — 에셋과 한국어 잠금

**밋밋한 결과물 방지**: the design rule now *requires* real assets on user-facing work — icon library installed (lucide-react default), a chosen webfont loaded (Pretendard Variable for Korean products), real or placeholder images with a `CREDITS.md` ledger. Emoji-as-icon or default system font on branded UI is a review-blocking violation. Copy-paste recipes (Pretendard CDN link, lucide setup, image sourcing rules): `guides/12-design-system.md §7`.

**한국어 응답 잠금** (3중): Rule 12 now covers *all* output including follow-up questions and status reports · the session hook re-injects the language reminder every session · and `/setup` proactively offers the permanent directive `모든 대화·질문·보고는 한국어로`. For ALL projects at once, add one line to `~/.claude/CLAUDE.md`: `Always respond in Korean (한국어) — questions, summaries, and reports included. Code and identifiers stay in English.`

**CI**: copy `templates/ci/github-actions-node.yml` → `.github/workflows/ci.yml` to enforce the same gates on every push (Rust/Python variants noted inside).

## When knowledge runs out — 웹 검색과 리서치

Claude's training has a cutoff, and beta libraries (Astryx is v0.x) move weekly. COMPASS handles the gap with a three-tier protocol (skill: `research`):

| Tier | For | How |
|---|---|---|
| Training knowledge | stable ground (Postgres, React fundamentals) | used directly |
| **Live verification** | beta/v0.x deps, exact APIs, version-specific behavior, post-cutoff facts | installed `node_modules` types (ground truth for your lockfile) → package CLIs (Astryx: `npm run astryx -- component <Name>`) → Context7 MCP → official docs via built-in WebSearch/WebFetch |
| **Deep research** (`/research <topic>`) | evidence-needing decisions | structured findings persisted to `docs/research/` — searched once, reusable forever |

Safety net: hallucinated APIs collide with installed types at the typecheck gate. Activate the MCP servers (Context7 docs, Playwright for visual verification) with `cp templates/.mcp.json.example .mcp.json`.

> 🇰🇷 원칙: 베타 라이브러리는 절대 기억으로 코딩하지 않는다 — 설치된 패키지가 곧 1차 문서다. 조사 결과는 디스크에 영구 저장되어 두 번 검색하지 않는다.

## The proactive co-pilot — 상황 인지 자동 제안

COMPASS doesn't just wait for commands — three deterministic channels watch the situation and suggest the next move:

| Channel | When | What you see |
|---|---|---|
| **Session briefing** | every session start (incl. after `/clear` and `/compact`) | One prioritized suggestion, relayed in Claude's first reply: unprofiled → `/setup` · `[~]` dangling → continue it · uncommitted changes → `/checkpoint` · no SPEC → `/spec` · open tasks → `/next` + the task name · stale map → `/map` note |
| **Unprotected-work counter** | 25 / 50 / 75 edits since the last PROGRESS update | Mid-work nudge: "checkpoint now" — a healthy `/next` cycle refreshes PROGRESS every task, so crossing 25 *is* the warning signal |
| **Statusline** | always, in the terminal footer | `🧭 COMPASS · Opus · phase:2 — billing · 2open/1wip · 12 edits since ckpt` |

Noise design: the briefing emits **exactly one** suggestion (first match in priority order); the counter fires only at thresholds. Semantic suggestions ("this sounds big — run /spec") remain Claude's job via the CLAUDE.md routing table — hooks handle only what can be detected deterministically. Honest note: hooks can't see context-window %, so the counter measures the thing that actually matters — how much work sits unprotected since the last save — and complements Claude Code's own auto-compact.

> 🇰🇷 세 채널 모두 결정론적 신호만 사용하고, 제안은 항상 최대 1개 — 잔소리가 아니라 브리핑이 되도록 설계했다.

## Universal inventory, per-project activation — 범용인데 낭비가 없는 이유

COMPASS ships everything, but a given project *activates* only its slice — and `docs/PROJECT.md` (written once by `/setup`, injected every session) aims the whole system at YOUR product, stage, and quality bias. Example — a TypeScript + Supabase SaaS:

| Layer | What actually loads |
|---|---|
| Always | CLAUDE.md (~95 lines) + PROJECT identity + PROGRESS/TODO tails (hook) |
| On touching `*.ts` / `supabase/` / `*.sql` / `*.tsx` | typescript · serverless · postgres · design rules |
| Never (this project) | java.md, python.md … (~0 tokens idle — path-scoped) |
| On demand | skills when the task matches; guides only when read |

> 🇰🇷 요약: 인벤토리는 범용, 활성화는 프로젝트별. 그리고 /setup의 프로젝트 헌장이 "이 프로젝트 전용" 조준을 더한다.



## Test-mode secrets — `/secrets on|off` (보안해제 모드)

By default Claude cannot touch `.env` (hook-blocked). But a key the **user pastes into chat is already exposed** — blocking its application is friction, not security. So: `/secrets on` flips an explicit, visible test mode — Claude may then write your pasted keys into `.env` and read it back. Rails that never relax: `.gitignore` is verified/patched before unlocking · secret **values are never echoed** back (key names only) · env files are never committed · `.pem`/`.key`/certificates stay permanently locked · the unlock shows in every session briefing and the statusline until you run `/secrets off`. `/healthcheck` flags unlocks older than a week.

> 🇰🇷 채팅으로 준 키는 이미 노출된 값 — 테스트면 .env 적용을 막을 이유가 없다. 대신 '켜져 있음'이 항상 보이는 명시 모드로: 켜기 한 줄, 끄기 한 줄, 값 에코는 어떤 모드에서도 금지.

## Command naming — 내장 명령어 충돌 회피

COMPASS names deliberately dodge Claude Code built-ins. Verified collisions we renamed around: built-in `/plan` (plan-mode toggle), `/review` (PR review), `/resume` (session picker), `/doctor` and its new alias `/checkup` (setup diagnostics). Hence:

| 옛 습관이 부르는 이름 | COMPASS 명령 |
|---|---|
| plan | **/blueprint** — 옵션 비교 → 계획+TODO |
| review | **/inspect** — 독립 리뷰어 PASS/FAIL |
| resume | **/restore** — 디스크에서 심층 복원 |
| doctor | **/healthcheck** — 설치 자가진단 (섀도 감지 포함) |

Rule when adding your own commands: type `/` first and check the live list — built-ins win ambiguity, and the list grows monthly. `/healthcheck` step 0 re-verifies all 14 names every time you run it. Note: Anthropic has unified custom commands into skills; `.claude/commands/` remains fully supported, and any COMPASS command can be migrated to `.claude/skills/<name>/SKILL.md` unchanged if you prefer that format later.

> 🇰🇷 요약: 내장과 겹치던 4개를 개명했고, /healthcheck가 앞으로 생길 충돌까지 자동 감지한다.


## Upgrading safely — 업그레이드 시 데이터 보존

Never overwrite a project wholesale with a newer COMPASS zip. **Yours (never overwrite):** `docs/` and `.claude/rules/project-directives.md`. **Replaceable:** `CLAUDE.md`, `guides/`, `templates/`, and the rest of `.claude/`. Exact commands in `START_HERE.md §10`. Removal: delete `CLAUDE.md`, `.claude/`, `guides/`, `templates/` — keep `docs/` (it's your project's record).

## Requirements & compatibility

- **Claude Code v2.x+** (uses hooks, skills, `.claude/rules` with `paths:` frontmatter, subagent `model:` routing).
- **bash** for hooks (macOS/Linux native; **Windows → WSL or Git Bash**). `jq` recommended but optional — every hook has a grep fallback and degrades gracefully.
- **Opus access is optional and opt-in.** The package ships model-neutral (no `model` pins), so it runs unmodified on any plan. `/setup` step 3c asks once; answering YES enables `opusplan` via `.claude/settings.local.json` and pins `model: opus` in `agents/architect.md` and the `setup`/`spec`/`blueprint` command frontmatter. To enable or disable by hand, those are the complete locations — verify with `grep -rn "model" .claude/`.
- Claude Code evolves weekly. If something seems ignored:
  - `/hooks` — verify the four hook events registered (the statusline is wired separately via `statusLine` and won't appear there)
  - `/memory` — verify CLAUDE.md and rules loaded; **if a path-scoped rule never loads on your version, remove its `paths:` block** (it will then load unconditionally — acceptable, files are lean) — some versions had scoping quirks, especially for user-level rules
  - `claude --version` and the official docs are the final authority

> 🇰🇷 훅은 bash 기반입니다(Windows는 WSL/Git Bash). jq 없어도 동작합니다. Opus는 선택 사항입니다 — 기본 배포는 모델 미지정이라 어떤 플랜에서도 그대로 동작하고, Opus가 있으면 `/setup`이 한 번 물어보고 켜 줍니다.

## Design honesty — read once

1. **Prompts are advisory; hooks are law.** CLAUDE.md rules raise the *probability* of good behavior; only the four hooks *guarantee* theirs (secrets, formatting, bloat warnings, honest task states). That's why both layers exist.
2. **No system makes 1M-token autonomy flawless.** COMPASS's promise is *recoverability*: any crash, compaction, or `/clear` costs at most the work since the last checkpoint, and any fresh session passes the 2-minute Resume Test. That property, maintained, is what lets projects run for months.
3. **The map is curated, not generated** — research shows auto-generated repo context files hurt agent performance. Rule 6's same-commit contract is what keeps curation cheap.

## FAQ

**Q. 꼭 /spec부터 해야 하나요?** 사소한 수정(한 줄 수정, 오타)은 아닙니다 — 상태 머신의 4→5→6만 탑니다. 그 외는 /spec이 결국 더 빠릅니다: 잘못 만든 것을 다시 만드는 비용이 인터뷰 비용보다 항상 큽니다.

**Q. 훅이 너무 엄격하면?** `.claude/settings.json`에서 개별 훅 블록을 제거하면 해당 강제만 꺼집니다(문서 규칙은 유지됨). 비대화 임계값은 `post-edit.sh`의 300/500 숫자를 수정하세요.

**Q. 토큰 비용은?** 상시 로드는 CLAUDE.md ~95줄 + 영구지침 + 세션 훅이 주입하는 상태 요약이 전부입니다. rules는 해당 파일을 만질 때만, skills는 발동 시에만 로드됩니다. 서브에이전트는 별도 컨텍스트라 본대를 오염시키지 않습니다.

**Q. 커스터마이즈해도 되나요?** 그러라고 만든 시스템입니다 — `guides/11-continuous-improvement.md`의 승격 사다리를 따라 여러분의 실수 패턴을 규칙과 훅으로 승격시키세요. 지켜야 할 불변식은 넷뿐: lean CLAUDE.md · disk-is-truth · hooks-for-must-haves · curated map.

---

MIT License · COMPASS v1.14.1 · Built for solo developers running Sonnet-as-builder + Opus-as-advisor.
