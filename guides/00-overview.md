# 00 — COMPASS Overview: Philosophy & Architecture
> 🇰🇷 시스템 전체 철학과 구조. 처음 설치 후 이 문서 하나만 읽어도 전체가 보이도록 설계했다.

## What COMPASS is

COMPASS is an operating system for agentic coding: a small set of always-loaded rules, deterministic hooks, on-demand skills, model-routed subagents, and durable state files that together make Claude Code (1) understand before building, (2) compare before deciding, (3) verify before claiming done, and (4) survive projects far larger than any context window.

**C**larify · **O**ptions · **M**ap · **P**lan · **A**ct · **S**crutinize · **S**ustain

## The four design principles

### 1. Instructions are advisory; hooks are law
Official guidance is explicit: memory files are "context, not enforced configuration" — to block an action regardless of what the model decides, you need a PreToolUse hook. So COMPASS splits every rule by nature:
- **Judgment rules** (how to design, when to ask) → CLAUDE.md, skills, guides.
- **Must-always-happen rules** (never touch secrets, always format, never abandon `[~]` tasks) → hooks in `.claude/hooks/`, which run deterministically every time.
> 🇰🇷 판단이 필요한 규칙은 문서로, 무조건 지켜야 하는 규칙은 훅으로. 프롬프트는 요청이고 훅은 법이다.

### 2. The instruction budget is real
Frontier models follow roughly 150–200 instructions consistently, and the harness spends dozens of those already. So the root CLAUDE.md stays lean (~100 lines) and everything else loads *only when relevant*:

| Layer | Loads when | Cost when idle |
|---|---|---|
| `CLAUDE.md` | every session | always paid — keep lean |
| `.claude/rules/*.md` | a matching file is touched (`paths:` frontmatter) | ~0 |
| Skills (`SKILL.md`) | task matches its description | ~60 tokens (name+description) |
| Subagents | explicitly or auto-delegated | 0 (separate context) |
| `guides/*.md` | Claude reads them on demand | 0 |

### 3. Disk is truth; context is cache
All durable state lives in `docs/*.md`. The context window is treated as volatile memory that can vanish (crash, `/clear`, compaction) at any moment. This single principle is what makes 1M+ token projects workable — see `guides/07-long-horizon.md`.

### 4. The map is curated, never generated
Research on repository context files found LLM-generated structural overviews *reduced* agent success in most settings while raising cost. COMPASS's `CODEBASE_MAP.md` is therefore decision-level and hand-curated (with agent help), never an auto-dumped file tree. See `guides/05-codebase-index.md`.

## Component map

```
CLAUDE.md                 ← constitution: state machine + 12 rules + routing
.claude/
  settings.json           ← permissions deny-list, hook wiring, statusline
  hooks/                  ← LAW+CO-PILOT: guard-secrets · post-edit(format+bloat+ckpt counter) · session-resume(state+suggestions) · stop-gate · statusline
  rules/                  ← stack conventions, path-scoped (TS, Rust/Tauri, Python, Java, serverless, Postgres, AI, Docker, Design) + project-directives (always-on)
  agents/                 ← architect(advisor) · code-reviewer(Sonnet) · explorer(Haiku)
  commands/               ← 14: /setup /spec /blueprint /next /inspect /checkpoint + /restore /map /advise /remember /improve /research /secrets /healthcheck
  skills/                 ← requirement-interview · tradeoff-analysis · codebase-map · bloat-guard · long-horizon · definition-of-done · research
docs/                     ← DURABLE STATE: PROJECT SPEC PLAN TODO PROGRESS CODEBASE_MAP DECISIONS SESSION_LOG BACKLOG + inputs/ + research/
guides/                   ← this folder (00–16): deep rationale, read on demand
templates/                ← pristine copies of every docs/ file + Docker + CI + design(KRDS) + .mcp.json.example
```

## The golden path

```
/spec "what you want"   → interview until ≥90% confidence → docs/SPEC.md
/blueprint                   → options with trade-offs → docs/PLAN.md + docs/TODO.md
/next  (repeat)         → one task: build → verify → update state
/inspect                 → independent reviewer PASS required
/checkpoint             → save-game: docs updated + commit
```
First session in a project: run `/setup` once before this loop — it profiles the project into `docs/PROJECT.md`. Next session: just start — the SessionStart hook auto-injects your state; `/restore` for the deep version.
> 🇰🇷 /setup 1회 + 이 다섯 커맨드 루프가 황금 경로다. 나머지(/restore /map /advise /remember /improve /research /secrets /healthcheck)는 필요할 때 꺼내 쓰는 전문 도구.

## Requirement → mechanism map (why each piece exists)

| Need | Mechanism |
|---|---|
| Understand perfectly before working | `/spec` + requirement-interview skill + confidence gate (Rule 1) |
| Propose better directions | Better-direction protocol (Rule 2, in the interview skill) |
| Efficiency-vs-impact options | `/blueprint` + tradeoff-analysis skill (Rule 3) |
| Prevent code bloat | Rule 5 budgets + post-edit hook + bloat-guard skill |
| Find anything as files multiply | CODEBASE_MAP + Rule 6 same-commit contract + /map |
| Living checklists, always updated | TODO/PROGRESS discipline (Rule 4) + stop-gate hook |
| Survive 1M+ tokens | long-horizon skill + /checkpoint + /restore + SessionStart hook |
| Opus advisor / Sonnet worker | opusplan model + architect subagent + /advise |
| Continuous improvement | /improve + SESSION_LOG "Improve" lines + promotion ladder (guide 11) |
| Extensibility | guide 10: add skills/commands/hooks/MCP/plugins |
