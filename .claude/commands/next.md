---
description: Execute the next open task from docs/TODO.md with the full BUILD → VERIFY loop
argument-hint: [optional: specific task to pick instead of the topmost]
---

Run one full task cycle. One task only — never batch.
> 🇰🇷 한 번에 한 작업. 완료 기준 불명확하면 코드 전에 질문.

1. Pick the topmost `[ ]` task in `docs/TODO.md` (or the one named: $ARGUMENTS). Mark it `[~]` immediately — the stop-gate hook holds you accountable for it.
2. Restate the task's acceptance criteria in one or two lines. If they are unclear, ask before writing any code.
3. Implement smallest-change-first, tests alongside code. Respect the bloat budget (Rule 5) and whatever `.claude/rules/*.md` loaded for these file types. Use the `explorer` subagent for any wide code search.
4. Run the relevant gates (lint / typecheck / tests) yourself.
5. Update state: mark the task `[x]` (or `[!]` + one-line reason), append 2–3 lines to `docs/PROGRESS.md`, and update `docs/CODEBASE_MAP.md` if structure changed (Rule 6).
6. Report: what changed · proof it works (paste actual test/lint output) · the next suggested task.
