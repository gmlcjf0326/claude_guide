---
description: Save-game protocol — make the project fully resumable from disk, then commit
---

Execute the checkpoint sequence from the `long-horizon` skill:
> 🇰🇷 세이브 포인트. 이거 없이 세션을 끝내거나 /clear·/compact 하지 않는다.

1. `docs/TODO.md` — every status honest: nothing left `[~]` unless you are mid-task on purpose; blocked items marked `[!]` with a one-line reason.
2. `docs/PROGRESS.md` — refresh the snapshot (date, phase, last done, in flight, next, blockers). Keep it ≤ 60 lines by pruning older detail into `docs/SESSION_LOG.md`.
3. `docs/SESSION_LOG.md` — append one entry: did / decided / learned / next / one improvement observed (feeds `/improve`).
3b. `docs/DECISIONS.md` — record any decision made this session (ADR-lite, per the template).
4. `docs/CODEBASE_MAP.md` — update if any structure changed this session (Rule 6).
5. **Sweep the stage for secrets first**: `git status --porcelain | grep -Ei '(^|[ /])\.env($|\.)|\.(pem|key|p12|pfx)( |$)' | grep -vE '\.env\.(example|sample|template)'` — any hit: stop, fix `.gitignore`, unstage it. Only then `git add -A && git commit` with a conventional message, then **`git push` if a remote is configured** — a checkpoint that exists on one disk is a wish, not a save. (The guard hook watches file edits, not git — the stage is YOUR responsibility.)
6. Print the resume line: "Next session: run /restore, then start with <task>."
