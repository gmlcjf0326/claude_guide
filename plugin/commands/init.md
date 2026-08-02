---
description: Install COMPASS into this project, or safely upgrade an existing install (docs/ and permanent directives always preserved)
argument-hint: "[--dry-run]"
---

Install or upgrade COMPASS in the CURRENT project from this plugin's payload at `${CLAUDE_PLUGIN_ROOT}`.
> 🇰🇷 이 명령이 zip 복사를 대체합니다 — 숨김폴더 누락 함정도, 업그레이드 덮어쓰기 함정도 구조적으로 사라집니다. `docs/`와 영구 지침은 어떤 경우에도 보존됩니다.

## 0. Detect the situation

- `NEW` install: no `./CLAUDE.md` and no `./.claude/commands/` in the project.
- `UPGRADE`: both exist. Report the versions: project version = last line of `./README.md` (if COMPASS's), payload version = `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json` → `version`.
- If the project has a `CLAUDE.md` that is clearly NOT COMPASS's (no "Operating State Machine" heading): STOP and ask the user before touching it — offer to merge instead of replace.
- With `--dry-run` in $ARGUMENTS: only report what would be copied/preserved, change nothing.

## 1. Copy the system layer (NEW and UPGRADE)

From `${CLAUDE_PLUGIN_ROOT}` into the project root, replacing existing copies:

```
CLAUDE.md
guides/            (entire directory)
templates/         (entire directory)
.claude/settings.json
.claude/hooks/     (entire directory)
.claude/commands/  (entire directory)
.claude/skills/    (entire directory)
.claude/agents/    (entire directory)
.claude/rules/     — EVERY file EXCEPT project-directives.md (see step 2)
```

Do NOT copy: `.claude-plugin/`, `plugin/`, `.git*`, `README.md`, `START_HERE*.md`, `COMPASS-USAGE-GUIDE*.md`, `LICENSE` (reference docs stay in the plugin; copy them only if the user asks for offline copies).

## 2. Preserve the user's data (UPGRADE — non-negotiable)

- `docs/` — never overwrite existing files. Copy only files that do NOT exist yet (e.g. a newly introduced state file or `docs/research/` seed).
- `.claude/rules/project-directives.md` — never overwrite if present. On NEW install, copy the pristine one.
- `.claude/settings.local.json`, `.claude/compass.conf`, `.claude/secrets.unlock` — never touch.
- If `.claude/settings.json` differs from the payload on UPGRADE, show the diff before replacing — the user may have customized permissions; offer to merge their `allow`/`deny` additions into the new file.

## 3. NEW install only — seed the state layer

Copy `docs/` from the payload wholesale (it ships pre-seeded), then verify `.gitignore` contains `.claude/settings.local.json`, `.claude/secrets.unlock`, `.env*`, `!.env.example` — append any missing lines.

## 4. Verify and hand off

1. Run the project healthcheck basics yourself: `ls .claude/commands/*.md` (expect 14), `bash -n .claude/hooks/*.sh`, and the guard probe `X=pem; echo "{\"tool_input\":{\"file_path\":\"x.$X\"}}" | bash .claude/hooks/guard-secrets.sh; echo $?` → expect 2. (Build the payload via `$X`: a literal `.pem` in the command string trips the guard's shell scanner and the probe never reaches the file-path branch.)
2. Tell the user: hooks and the statusline activate on the NEXT session start (settings.json is read at startup) — restart `claude` in this project.
3. Report what was installed/preserved in ≤ 8 lines (versions, preserved files, gitignore changes).
4. Suggest the next step: NEW → "restart claude, then run /setup"; UPGRADE → "restart claude, then run /healthcheck".

Note: the project-level commands installed here are invoked WITHOUT a namespace (`/setup`, `/spec`, …). This plugin's own command stays namespaced (`/compass:init`) and is only needed again for future upgrades (`/plugin update compass` → `/compass:init`).
