---
name: definition-of-done
description: The verification gate that decides whether work may be called complete. Use before marking any TODO item [x], before saying "done", "finished", "implemented", or "fixed", during /inspect and /checkpoint, and whenever tempted to skip tests because a change "is small". Defines the DoD checklist and the proof-of-work reporting format.
---

# Definition of Done

"It should work" is a hypothesis. "Here is the passing output" is done. Nothing is complete until it survives this checklist.
> 🇰🇷 "될 겁니다"는 가설이고, "통과 로그 여기 있습니다"가 완료다.

## The Checklist

A task is DONE only when ALL of these hold (or a listed exception is declared out loud):

1. **Builds clean** — compile/build succeeds from a clean state.
2. **Gates green** — lint: 0 errors · typecheck: 0 errors · tests: all pass, including NEW tests for NEW behavior. A feature without a test is not done; it is undocumented risk.
3. **Bloat budget respected** — no file pushed past 300/500, no function past 50, or the split was done (skill: bloat-guard).
4. **Diff reviewed against plan** — read your own diff as a hostile reviewer: does it do what `docs/PLAN.md` said, nothing more, nothing less? Unplanned extras → remove or get approval.
5. **No debris** — no leftover debug prints, commented-out corpses, TODO-with-no-ticket, unused imports.
6. **Security pass** — inputs validated at boundaries; no secrets in code or logs; no injection vectors introduced.
7. **State updated** — TODO status honest, PROGRESS appended, MAP updated if structure changed (Rules 4 & 6).

## Proof of Work

When reporting completion, paste the *actual* gate output (final lines are enough):

```
$ pnpm test
Test Files  14 passed (14) · Tests  87 passed (87)
```

Never summarize a gate you did not run. "Tests should pass" is a red flag phrase — run them.

## The Verification Pyramid (where to spend effort)

1. **Types & lint** — cheapest, catch the dumbest 30% instantly. Always on (hook-assisted).
2. **Unit tests** — the workhorse: every new behavior, every fixed bug (regression test first, then fix).
3. **Integration tests** — where the money is lost: API + DB, IPC boundary (Tauri), auth flows, RLS policies.
4. **Manual/E2E smoke** — expensive; reserve for the critical path before a release.

When a bug is found: write the failing test FIRST, watch it fail, then fix, then watch it pass. The failing test is the only proof you understood the bug.

## Honest Exceptions

Some tasks legitimately can't meet every line (e.g., no test runner exists yet in a greenfield repo). The rule is not "always perfect" — it is **never silent**: state which line is skipped, why, and add the debt to `docs/BACKLOG.md` with a revisit note.
