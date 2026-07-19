# 03 — Planning & Living Checklists
> 🇰🇷 계획(PLAN)과 살아있는 체크리스트(TODO/PROGRESS)의 해부학 — "항시 업데이트"가 규율이 되는 법.

## PLAN.md anatomy

A plan is phases, and a phase is a promise: *at the end of this phase, something verifiable is true.*

- **Phases are vertical slices** — each ends in something runnable/demoable (walking skeleton first: one thin end-to-end path through UI → API → DB before any feature gets deep). Never phase by layer ("Phase 1: all models, Phase 2: all APIs") — layer phases verify nothing until the very end.
- Each phase carries: goal (one sentence) · acceptance criteria (testable) · risks (what could invalidate it).
- The plan references the DECISIONS entries it depends on, so when a decision is revisited, the affected phases are findable.

## Task granularity — the half-day rule

Every `docs/TODO.md` item is ≤ half a day of work with a verifiable end state. "Implement billing" is a phase masquerading as a task; "Stripe webhook endpoint verifies signature + stores event (test incl.)" is a task. Oversized tasks are where honesty dies — they sit `[~]` for days and nobody knows what's actually done inside them.
> 🇰🇷 반나절 넘는 작업은 쪼갠다. 큰 작업 하나가 [~] 상태로 며칠 방치되는 순간 체크리스트는 죽는다.

## The checklist grammar

```
- [ ] not started        - [~] in progress (mark BEFORE starting work)
- [x] done & verified    - [!] blocked — one-line reason required
```

Three enforcement points keep it *living* rather than decorative:
1. `/next` marks `[~]` **before** implementing and `[x]` only after gates pass.
2. The **stop-gate hook** refuses to end a session while `[~]` items dangle — statuses must be made honest first.
3. `/checkpoint` audits every status against reality.

## PROGRESS.md — dashboard, not diary

PROGRESS answers one question for a cold-started session: *where are we and what's next?* Keep it ≤ 60 lines: snapshot header (date/phase/status line), last done, in flight, next 1–3 actions, blockers. Anything older gets pruned into `SESSION_LOG.md` at checkpoint time. A 300-line PROGRESS is a diary wearing a dashboard's badge — and the auto-resume hook injects its tail, so bloat there directly pollutes every session start.

## Relationship to Claude Code's built-in task list

Claude Code's native task tools are excellent *within-session* working memory — keep using them for step tracking. But `docs/TODO.md` is the cross-session, git-versioned source of truth that survives crashes, machine switches, and tool changes. When they disagree, TODO.md wins (disk is truth). The simple discipline: native tasks for the current sitting, TODO.md updated at every task completion and checkpoint.
