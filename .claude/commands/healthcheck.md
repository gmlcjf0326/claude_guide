---
description: Health-check the COMPASS installation — hooks, state files, gates, and rule loading
---

Diagnose the installation with bash and report a table (component · status · fix). Silent degradation is the worst failure mode — this command makes it loud.
> 🇰🇷 시스템이 '조용히' 죽어있는 최악의 상태를 찾아내는 청진기.

0. **Command inventory (run it yourself)**: `ls .claude/commands/*.md` — all 14 files must exist: setup, spec, blueprint, next, inspect, checkpoint, restore, map, improve, advise, remember, healthcheck, research, secrets. Missing FILES = broken install (the hidden-folder copy trap, START_HERE §4) → re-copy `.claude/`.
0b. **Shadow check (needs the user)**: ASK the user to type `/` and report which of the 14 names are absent from the live list. A name whose file exists but doesn't appear means a NEW Claude Code built-in landed on it: rename the file in `.claude/commands/` and sweep references (rule in README §Command naming).
1. **settings.json** parses — `jq . .claude/settings.json` (no jq? `python3 -c "import json;json.load(open('.claude/settings.json'))"`), and each configured hook points at an existing file.
2. **Hooks behave** (mode-aware): `echo '{"tool_input":{"file_path":"x.pem"}}' | bash .claude/hooks/guard-secrets.sh; echo $?` → expect 2 in EVERY mode. Then `.env` (file and shell forms): `echo '{"tool_input":{"file_path":".env"}}' | bash .claude/hooks/guard-secrets.sh; echo $?` and `echo '{"tool_input":{"command":"cat .env"}}' | bash .claude/hooks/guard-secrets.sh; echo $?` → expect 2 when `.claude/secrets.unlock` is absent, 0 when present (that is the unlock working, NOT a failure). `echo '{"stop_hook_active":true}' | bash .claude/hooks/stop-gate.sh; echo $?` → expect 0. On Windows-without-bash, report the WSL/Git-Bash requirement from README.
3. **jq** present? (optional — grep fallbacks exist; recommend installing.)
3b. **Statusline renders**: `echo '{}' | bash .claude/hooks/statusline.sh` → expect a single `🧭 COMPASS …` line with no newline.
4. **docs/ complete**: PROJECT, SPEC, PLAN, TODO, PROGRESS, CODEBASE_MAP, DECISIONS, SESSION_LOG, BACKLOG all exist; flag if PROJECT.md is still unprofiled → suggest `/setup`.
4b. **Secrets mode**: report `.claude/secrets.unlock` state; if ON and older than 7 days, recommend `/secrets off` — test unlocks shouldn't fossilize.
5. **git**: repo initialized AND a remote configured (`git remote -v`) — checkpoints without a remote live on one fragile disk.
6. **Gates**: detect lint/typecheck/test commands for the active stack; list missing ones → suggest adding a Phase-0 task.
7. **Rule loading**: tell the user to run `/memory` and confirm CLAUDE.md plus the expected path-scoped rules appear; if a rule never loads, point at the README compatibility note (remove its `paths:` block as fallback).

End with: overall PASS/WARN, and the single highest-value fix first.
