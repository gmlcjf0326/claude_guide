#!/usr/bin/env bash
# COMPASS statusline — persistent one-line situational display in the terminal.
# 🇰🇷 터미널 하단 상시 표시: 페이즈 · 열린/진행중 작업 · 체크포인트 이후 편집 수. jq 없어도 동작.
set -u
IN="$(cat 2>/dev/null || true)"

ROOT=""; MODEL=""
if [ -n "$IN" ]; then
  if command -v jq >/dev/null 2>&1; then
    ROOT="$(printf '%s' "$IN" | jq -r '.workspace.project_dir // .workspace.current_dir // .cwd // empty' 2>/dev/null)"
    MODEL="$(printf '%s' "$IN" | jq -r '.model.display_name // .model.id // empty' 2>/dev/null)"
  else
    ROOT="$(printf '%s' "$IN" | grep -o '"project_dir"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//')"
    [ -z "$ROOT" ] && ROOT="$(printf '%s' "$IN" | grep -o '"current_dir"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//')"
    MODEL="$(printf '%s' "$IN" | grep -o '"display_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//')"
  fi
fi
[ -z "${ROOT:-}" ] && ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
D="$ROOT/docs"

PHASE="-"; OPEN=0; WIP=0; EDITS=0
if [ -f "$D/PROGRESS.md" ]; then
  PHASE="$(grep -m1 -o '\*\*Phase:\*\*[^·|]*' "$D/PROGRESS.md" 2>/dev/null | sed 's/\*\*Phase:\*\*[[:space:]]*//; s/[[:space:]]*$//' | cut -c1-24)"
  [ -z "$PHASE" ] && PHASE="-"
fi
if [ -f "$D/TODO.md" ]; then
  OPEN="$(grep -cE '^[[:space:]]*[-*] \[ \]' "$D/TODO.md" 2>/dev/null)"
  WIP="$(grep -cE '^[[:space:]]*[-*] \[~\]' "$D/TODO.md" 2>/dev/null)"
fi
case "$OPEN" in (*[!0-9]*|"") OPEN=0;; esac
case "$WIP" in (*[!0-9]*|"") WIP=0;; esac
KEY="$(printf '%s' "$ROOT" | cksum | cut -d' ' -f1)"
CNT="${TMPDIR:-/tmp}/compass-copilot/$KEY.edits"
[ -f "$CNT" ] && EDITS="$(cat "$CNT" 2>/dev/null)"
case "$EDITS" in (*[!0-9]*|"") EDITS=0;; esac

OUT="🧭 COMPASS"
[ -n "${MODEL:-}" ] && OUT="$OUT · $MODEL"
OUT="$OUT · phase:$PHASE · ${OPEN}open/${WIP}wip · ${EDITS} edits since ckpt"
[ -f "$ROOT/.claude/secrets.unlock" ] && OUT="$OUT · UNLOCKED"
printf '%s' "$OUT"
