#!/usr/bin/env bash
# COMPASS post-edit — auto-format, bloat budget, and the unprotected-work counter.
# 🇰🇷 편집마다: 자동 포맷 + 비대화 예산 점검 + '마지막 상태 갱신 이후 편집 수'를 세어
#     25/50/75회 도달 시 체크포인트를 제안한다. (건강한 /next 사이클은 매번 PROGRESS를
#     갱신하므로, 카운터가 25를 넘는 것 자체가 '무보호 작업 누적' 신호다.)
set -u

INPUT="$(cat)"
if command -v jq >/dev/null 2>&1; then
  FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"
else
  FILE_PATH="$(printf '%s' "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//')"
fi
[ -z "${FILE_PATH:-}" ] && exit 0
[ -f "$FILE_PATH" ] || exit 0

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$ROOT" 2>/dev/null || true
MSGS=""

# Optional per-project overrides — /setup writes this for legacy codebases etc.
# shellcheck disable=SC1091
[ -f "$ROOT/.claude/compass.conf" ] && . "$ROOT/.claude/compass.conf" 2>/dev/null
SOFT="${COMPASS_BLOAT_SOFT:-300}"; HARD="${COMPASS_BLOAT_HARD:-500}"
case "$SOFT" in (*[!0-9]*|"") SOFT=300;; esac
case "$HARD" in (*[!0-9]*|"") HARD=500;; esac

# --- Unprotected-work counter (before anything that could exit) ---
STATE_DIR="${TMPDIR:-/tmp}/compass-copilot"
mkdir -p "$STATE_DIR" 2>/dev/null
KEY="$(printf '%s' "$ROOT" | cksum | cut -d' ' -f1)"
CNT="$STATE_DIR/$KEY.edits"
PROG="$ROOT/docs/PROGRESS.md"
if [ -f "$PROG" ] && [ -f "$CNT" ] && [ "$PROG" -nt "$CNT" ]; then
  echo 0 > "$CNT"   # state was refreshed since last count → reset
fi
N=0; [ -f "$CNT" ] && N="$(cat "$CNT" 2>/dev/null || echo 0)"
case "$N" in (*[!0-9]*|"") N=0;; esac
N=$((N+1)); echo "$N" > "$CNT" 2>/dev/null
if [ "$N" -ge 25 ] && [ $((N % 25)) -eq 0 ]; then   # 25, 50, 75, 100, … — never goes silent
  MSGS="CO-PILOT: $N edits since the last PROGRESS/checkpoint update — unprotected work is accumulating. Finish the current small step, then run /checkpoint (and /compact if the session is long). Relay this suggestion to the user."
fi

# --- Auto-format (silent; only if the project already uses the tool) ---
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.json|*.css|*.md)
    if [ -f biome.json ] || [ -f biome.jsonc ]; then
      npx --no-install @biomejs/biome format --write "$FILE_PATH" >/dev/null 2>&1
    elif ls .prettierrc* >/dev/null 2>&1 || [ -f prettier.config.js ] || [ -f prettier.config.mjs ]; then
      npx --no-install prettier --write "$FILE_PATH" >/dev/null 2>&1
    fi
    ;;
  *.rs) command -v rustfmt >/dev/null 2>&1 && rustfmt "$FILE_PATH" >/dev/null 2>&1 ;;
  *.go) command -v gofmt >/dev/null 2>&1 && gofmt -w "$FILE_PATH" >/dev/null 2>&1 ;;
  *.py)
    if command -v ruff >/dev/null 2>&1; then ruff format "$FILE_PATH" >/dev/null 2>&1
    elif command -v black >/dev/null 2>&1; then black -q "$FILE_PATH" >/dev/null 2>&1; fi
    ;;
esac

# --- Bloat budget (source files only) ---
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.rs|*.py|*.java|*.go|*.kt|*.swift|*.php|*.rb|*.cs|*.c|*.cpp|*.h|*.scala|*.vue|*.svelte|*.dart|*.ex)
    LINES="$(wc -l < "$FILE_PATH" 2>/dev/null | tr -d ' ')"
    if [ -n "$LINES" ]; then
      MARK_DIR="${TMPDIR:-/tmp}/compass-bloat"; mkdir -p "$MARK_DIR" 2>/dev/null
      PREV_FILE="$MARK_DIR/$KEY-$(printf '%s' "$FILE_PATH" | cksum | cut -d' ' -f1).lines"
      PREV=0; [ -f "$PREV_FILE" ] && PREV="$(cat "$PREV_FILE" 2>/dev/null)"
      case "$PREV" in (*[!0-9]*|"") PREV=0;; esac
      if [ "$LINES" -gt "$HARD" ]; then
        # Grew-only: legacy files over budget are grandfathered until they GROW again.
        if [ "$LINES" -gt "$PREV" ]; then
          MSGS="${MSGS}${MSGS:+
}BLOAT BUDGET (HARD): $FILE_PATH is now $LINES lines (> $HARD). STOP adding to this file. Apply the split protocol in the bloat-guard skill before continuing. (COMPASS Rule 5; thresholds: .claude/compass.conf)"
        fi
      elif [ "$LINES" -gt "$SOFT" ]; then
        MARK="$MARK_DIR/$(printf '%s' "$FILE_PATH" | tr '/ ' '__')-$(date +%Y%m%d)"
        if [ ! -f "$MARK" ]; then
          touch "$MARK" 2>/dev/null
          MSGS="${MSGS}${MSGS:+
}BLOAT BUDGET (soft): $FILE_PATH is $LINES lines (> $SOFT). Plan a split before it grows — see the bloat-guard skill. (COMPASS Rule 5)"
        fi
      fi
      echo "$LINES" > "$PREV_FILE" 2>/dev/null
    fi
    ;;
esac

if [ -n "$MSGS" ]; then
  printf '%s\n' "$MSGS" >&2
  exit 2
fi
exit 0
