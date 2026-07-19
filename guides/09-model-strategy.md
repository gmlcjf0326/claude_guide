# 09 — Model Strategy: Opus Advises, Sonnet Builds, Haiku Scouts
> 🇰🇷 모델 좌석 배치 — 가장 비싼 추론을 가장 비싼 결정에만 쓰는 법.

## The seating chart

| Seat | Model | Where it's wired | Used for |
|---|---|---|---|
| Planner/Advisor | **Opus** (opt-in) | `/setup` step 3c enables it: `opusplan` in `.claude/settings.local.json` · `model: opus` frontmatter on `/setup` `/spec` `/blueprint` · `architect` subagent | requirement interviews, plans, trade-off adjudication, irreversible decisions, milestone health checks |
| Builder | **Sonnet** | opusplan's execution half · `code-reviewer` subagent | implementation, tests, refactors, reviews |
| Scout | **Haiku** | `explorer` subagent | wide cheap read-only search & summarization |

`opusplan` gives the split automatically: Opus reasons while in plan mode, Sonnet takes over for execution. Pinning `model: opus` on `/setup`, `/spec`, and `/blueprint` additionally guarantees the highest-leverage thinking moments get the strongest reasoning even outside plan mode. **The package ships model-neutral** — no plan is required, and everything works on your plan's default model. `/setup` step 3c asks once and, on a YES, turns the Opus seats on; the complete pin locations are `.claude/settings.local.json` (`opusplan`), `agents/architect.md`, and the `setup`/`spec`/`blueprint` command frontmatter (`grep -rn "model" .claude/` to audit).

## Reasoning depth — the other dial

Before adding agents or switching models, turn up *thinking*:
- `ultrathink` in a prompt requests maximum reasoning for that turn — COMPASS bakes it into `/setup`, `/spec`, `/blueprint`, and `/improve`, the four moments where deep reasoning changes outcomes.
- Session-wide effort (`/effort` where available) is worth raising for architecture days and lowering for mechanical chores.
- Plan mode (read-only explore → written plan → approve) is the cheap insurance for any multi-file change: if you could describe the diff in one sentence, skip it; otherwise use it.

## Why COMPASS caps at three subagents

Published multi-agent results are seductive (a lead-plus-workers research system beating single-agent by ~90%) but come with two caveats that decide the matter for coding: multi-agent systems burn ~15× the tokens of a chat, and **coding tasks rarely parallelize well** — agents coordinating live edits step on each other. So the design rule: **escalate reasoning depth, not agent count.** Subagents here exist for *context isolation* (explorer keeps your window clean; reviewer gets unbiased fresh eyes; architect gets an independent judgment seat), never for parallel construction.
> 🇰🇷 에이전트를 늘리지 말고 사고 깊이를 올려라. 서브에이전트 셋의 존재 이유는 병렬 작업이 아니라 '컨텍스트 격리'다.

## Cost intuition

Opus per-token cost is meaningfully higher than Sonnet's (≈1.7× as of 2026 — check current pricing) — but tokens are not the unit that matters; *rework* is. One Opus-grade decision that prevents a schema migration pays for a month of `/advise` calls. Conversely, Opus writing boilerplate CRUD is pure waste. The seating chart above is the cost model: expensive reasoning at irreversible moments, cheap reasoning everywhere else.
