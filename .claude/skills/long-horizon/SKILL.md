---
name: long-horizon
description: Operational playbook for long-horizon work — projects whose total output far exceeds one context window (100K to 1M+ tokens of code across many sessions and days). Use when running /checkpoint or /restore, before any /compact or /clear, when context usage approaches ~60%, when starting a new phase, when returning to a project after time away, or whenever there is a risk of losing state. Implements the "disk is truth, context is cache" doctrine.
---

# Long Horizon

The context window holds roughly one afternoon of work. A real product is months. The gap is not survivable by memory — only by *state that lives on disk*. Everything here serves one test:

**The Resume Test — a brand-new session, given only the files in `docs/`, reaches the correct next action within 2 minutes.**
> 🇰🇷 컨텍스트 창은 반나절 분량, 실제 제품은 수개월 분량. 그 간극은 기억이 아니라 '디스크 위의 상태'로만 건널 수 있다. 기준은 단 하나: 새 세션이 docs/만 읽고 2분 안에 올바른 다음 행동에 도달하는가.

## The Doctrine

1. **Disk is truth; context is cache.** Anything only in context is already lost — you just don't know it yet.
2. **Write state as you go, not at the end.** A crash at minute 55 must cost 5 minutes, not 55.
3. **When memory and disk disagree, disk wins.** Your recollection may be from before a compaction.
4. **Tests are long-term memory of intent.** A rule enforced by a test survives every context wipe; a rule remembered in context survives none.
5. **Retrieval over recall.** Don't hold the codebase in your head — hold the map, and look things up (via the `explorer` subagent) when needed.

## Checkpoint Sequence (run via /checkpoint; also before ANY /compact or /clear)

1. `docs/TODO.md` — statuses made honest: `[x]` only if verified; stuck items → `[!]` + one-line reason; not-really-started → back to `[ ]`.
2. `docs/PROGRESS.md` — rewrite the snapshot: date · phase · last done · in flight · next 1–3 actions · blockers. **Keep ≤ 60 lines**: prune older narrative into `docs/SESSION_LOG.md`. PROGRESS is a dashboard, not a diary.
3. `docs/SESSION_LOG.md` — append one entry (template format): Did / Decided / Learned / Next / Improve.
4. `docs/CODEBASE_MAP.md` — update if structure changed (Rule 6). `docs/DECISIONS.md` — any decision made this session recorded.
5. `git add -A && git commit -m "<type>: <summary>"` — the commit *is* the checkpoint; uncommitted work is unprotected work.
6. Say the resume line out loud: "Next session: /restore, then <specific task>."

## Resume Sequence (run via /restore; light version auto-injects via SessionStart hook)

1. Read `docs/PROGRESS.md`, open items in `docs/TODO.md`, last 2 entries of `docs/SESSION_LOG.md`.
2. Cross-check reality: `git log --oneline -5`, `git status`. Disk state ≠ git state → investigate before anything else.
3. Skim `docs/SPEC.md` and `docs/PLAN.md` headings — re-anchor to the goal, not just the task.
4. State in ≤ 8 lines: where we are, what's in flight, what's next. Get a nod, then work.

## Compaction Playbook

- Compact **at ~60% context usage** — by 80% (auto-compact territory) the summary quality is already degraded.
- **Checkpoint first, always.** Compaction is lossy; the checkpoint is the lossless backup.
- Use a focused prompt: `/compact Focus on: the current task and its acceptance criteria, decisions made this session, files touched and why, and immediate next steps. Discard: file contents already committed, exploration dead-ends, resolved errors.`
- After compaction, the SessionStart hook re-injects PROGRESS/TODO — trust those over the compacted summary if they conflict.

## Phase Discipline (multi-day / multi-week projects)

- **One phase per session** beats marathon sessions: end each phase with /checkpoint, then `/clear` and start the next phase fresh. Fresh context + good docs outperforms a long, polluted context.
- **Drift ritual at every phase boundary**: re-read `docs/SPEC.md` top to bottom. Three outcomes: code matches spec (continue) · spec is outdated (update spec + note in DECISIONS) · code drifted (stop, add a reconciliation task to TODO before new work).
- Offload wide reading to the `explorer` subagent; feed yourself distilled summaries only. Reference file paths in notes instead of pasting contents.

## Failure Modes → Fixes

| Symptom | Cause | Fix |
|---|---|---|
| "Compaction amnesia" — forgets mid-task decisions | compact without checkpoint | Checkpoint-before-compact; decisions in DECISIONS.md |
| Zombie `[~]` tasks nobody is doing | statuses updated "later" | stop-gate hook blocks it; make statuses honest now |
| Map says X, code says Y | structure changed without map update | Rule 6 same-commit contract; /map freshness check |
| Rebuilding something that exists | didn't consult the map | Map's "Where to add X" table; explorer-first search |
| Plan and code quietly diverge | phases without the drift ritual | SPEC re-read at every phase boundary |
| PROGRESS.md is a 300-line diary | no pruning | ≤ 60 lines; prune into SESSION_LOG at checkpoint |

## Scaling Guide

| Project size | What actually changes |
|---|---|
| ~10K tokens (script, small fix) | States 4–6 only; docs/ optional |
| ~100K (a real feature) | Full state machine; SPEC/PLAN/TODO live; map begins |
| ~1M+ (a product) | Everything above **plus**: phase-per-session, drift ritual every boundary, /improve every milestone, map audits, DECISIONS discipline, and the test suite treated as the project's memory |
