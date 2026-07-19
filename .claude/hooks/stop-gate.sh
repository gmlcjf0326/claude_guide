#!/usr/bin/env bash
# COMPASS stop-gate — Claude may not finish while tasks dangle in [~] limbo *unsaved*.
# 🇰🇷 [~] 진행중 작업이 있어도, 체크포인트(PROGRESS 갱신)가 그보다 나중이면 '저장하고 떠나는 것'
#     이므로 통과. TODO만 만지고 상태 저장 없이 끝내려 할 때만 차단한다.
# Stop hook: exit 2 = keep working. Loop-safe via stop_hook_active (harness also caps at 8).
set -u

INPUT="$(cat)"

if command -v jq >/dev/null 2>&1; then
  ACTIVE="$(printf '%s' "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null || echo false)"
else
  printf '%s' "$INPUT" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && ACTIVE=true || ACTIVE=false
fi
[ "$ACTIVE" = "true" ] && exit 0

D="${CLAUDE_PROJECT_DIR:-.}/docs"
T="$D/TODO.md"
P="$D/PROGRESS.md"
[ -f "$T" ] || exit 0

# Checkpoint-aware: state saved AFTER the last TODO change → intentional carry-over, allow.
if [ -f "$P" ] && [ "$P" -nt "$T" ]; then
  exit 0
fi

if grep -qE '^[[:space:]]*[-*] \[~\]' "$T"; then
  echo "STOP-GATE (COMPASS Rule 4): docs/TODO.md has [~] in-progress task(s) and no state save since. Either finish it, mark it [!] blocked with a one-line reason, or — to carry it to the next session on purpose — update docs/PROGRESS.md (run the /checkpoint flow) so the save is newer than the TODO edit. Honest saved state beats an optimistic goodbye." >&2
  exit 2
fi

exit 0
