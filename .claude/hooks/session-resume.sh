#!/usr/bin/env bash
# COMPASS session-resume — injects durable state AND a situation-aware next-step suggestion.
# 🇰🇷 세션 시작 시 상태 주입 + 현재 상황을 진단해 '다음 명령 딱 하나'를 제안하는 코파일럿 브리핑.
# SessionStart hook: stdout is added to Claude's context. Fires on startup/restore/clear/compact.
set -u

ROOT="${CLAUDE_PROJECT_DIR:-.}"
D="$ROOT/docs"
if [ ! -d "$D" ]; then
  # Never degrade silently: no docs/ means a partial install or a fresh project.
  echo "=== COMPASS: docs/ not found. If COMPASS was just installed, the docs/ folder may not have been copied (see START_HERE §4 install trap) — restore it, or run /setup to begin. ==="
  exit 0
fi

FOUND=0
echo "=== COMPASS AUTO-RESUME (from docs/) ==="

# --- Project identity (only if profiled) ---
PROFILED=0
if [ -f "$D/PROJECT.md" ]; then
  ID_BLOCK="$(awk '/^## Identity/{f=1;next} /^## /{if(f)exit} f' "$D/PROJECT.md" | head -n 14)"
  if [ -n "$ID_BLOCK" ] && ! printf '%s' "$ID_BLOCK" | grep -q "run /setup"; then
    echo "--- PROJECT (identity) ---"
    printf '%s\n' "$ID_BLOCK"
    PROFILED=1; FOUND=1
  fi
fi

[ -f "$D/PROGRESS.md" ] && { echo "--- PROGRESS.md (last 30 lines) ---"; tail -n 30 "$D/PROGRESS.md"; FOUND=1; }
[ -f "$D/TODO.md" ] && { echo "--- TODO.md (open items) ---"; grep -E '^[[:space:]]*[-*] \[( |~|!)\]' "$D/TODO.md" | head -n 25; FOUND=1; }

# --- Situation engine: first match wins, exactly ONE suggestion ---
SUGGEST=""; WHY=""
WIP_LINE="$(grep -m1 -E '^[[:space:]]*[-*] \[~\]' "$D/TODO.md" 2>/dev/null | sed 's/^[[:space:]]*[-*][[:space:]]*//')"
OPEN_LINE="$(grep -m1 -E '^[[:space:]]*[-*] \[ \]' "$D/TODO.md" 2>/dev/null | sed 's/^[[:space:]]*[-*][[:space:]]*//')"
GIT_DIRTY=""
git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1 && GIT_DIRTY="$(git -C "$ROOT" status --porcelain 2>/dev/null | head -1)"
SPEC_EMPTY=0
{ [ ! -f "$D/SPEC.md" ] || grep -q "<project / feature name>" "$D/SPEC.md"; } 2>/dev/null && SPEC_EMPTY=1

if [ "$PROFILED" -eq 0 ]; then
  SUGGEST="/setup"; WHY="project is not profiled yet — one short interview aims the whole system at this project"
elif [ -n "$WIP_LINE" ]; then
  SUGGEST="continue the in-flight task"; WHY="TODO has an unfinished [~] item: ${WIP_LINE}"
elif [ -n "$GIT_DIRTY" ]; then
  SUGGEST="/checkpoint"; WHY="uncommitted changes exist from a previous session — inspect the diff, then save the game before new work"
elif [ "$SPEC_EMPTY" -eq 1 ]; then
  SUGGEST="/spec <first goal>"; WHY="no SPEC yet — define what we're building before building"
elif [ -n "$OPEN_LINE" ]; then
  SUGGEST="/next"; WHY="top open task: ${OPEN_LINE}"
else
  SUGGEST="/spec <next goal> or /improve"; WHY="no open tasks — start the next goal, or invest in the codebase"
fi

# Away detection (>7 days since last session log write) — prepend a deep-restore hint.
# Requires at least one REAL dated entry, so a fresh unzip (shipped mtimes) never false-fires.
AWAY=""
if [ -f "$D/SESSION_LOG.md" ] && grep -qE '^## 20[0-9]{2}-' "$D/SESSION_LOG.md" 2>/dev/null; then
  [ -n "$(find "$D/SESSION_LOG.md" -mtime +7 -print 2>/dev/null)" ] && AWAY="yes"
fi

# Map staleness heuristic: TODO moved while the map didn't, across ≥5 completed tasks
MAP_NOTE=""
if [ -f "$D/CODEBASE_MAP.md" ] && [ "$D/TODO.md" -nt "$D/CODEBASE_MAP.md" ] 2>/dev/null; then
  DONE_COUNT="$(grep -cE '^[[:space:]]*[-*] \[x\]' "$D/TODO.md" 2>/dev/null)"
  case "$DONE_COUNT" in (*[!0-9]*|"") DONE_COUNT=0;; esac
  [ "$DONE_COUNT" -ge 5 ] && MAP_NOTE="Note: CODEBASE_MAP.md is older than recent task activity — spot-check it, consider /map."
fi

if [ -f "$ROOT/.claude/secrets.unlock" ]; then
  echo "--- SECURITY ---"
  echo "SECRETS UNLOCK: ON (test mode) since $(cat "$ROOT/.claude/secrets.unlock" 2>/dev/null | head -1). .env read/write allowed; values must never be echoed. Turn off with /secrets off when testing ends."
fi
echo "--- CO-PILOT ---"
[ -n "$AWAY" ] && echo "You've been away 7+ days: run /restore first for the deep restore."
echo "Situation: $WHY"
echo "Suggested next: $SUGGEST"
[ -n "$MAP_NOTE" ] && echo "$MAP_NOTE"
echo "(Open your first reply by relaying this suggestion to the user in one line, then proceed. Respond in the user's language, honoring any language directive in .claude/rules/project-directives.md.)"

if [ "$FOUND" -eq 0 ]; then
  echo "=== No durable state yet. First time here? run /setup. ==="
fi
exit 0
