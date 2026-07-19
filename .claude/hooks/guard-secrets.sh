#!/usr/bin/env bash
# COMPASS guard-secrets — blocks secret-file access across file tools, Grep, AND shell commands;
# honors the explicit test unlock for .env (/secrets on|off).
# 🇰🇷 기본은 차단. 사용자가 /secrets on으로 명시 해제하면 .env만 읽기/쓰기 허용(테스트 모드).
#     인증서·개인키(.pem/.key/id_rsa/secrets/)는 어떤 모드·어떤 도구에서도 영구 차단.
set -u

INPUT="$(cat)"

UNLOCK="${CLAUDE_PROJECT_DIR:-.}/.claude/secrets.unlock"

# ---------- 1) Shell commands (Bash tool): scan the command string ----------
if command -v jq >/dev/null 2>&1; then
  CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
else
  CMD="$(printf '%s' "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//')"
fi

if [ -n "${CMD:-}" ]; then
  # Credentials/certificates: permanently blocked in every mode.
  if printf '%s' "$CMD" | grep -qE '\.pem([^A-Za-z0-9_]|$)|\.key([^A-Za-z0-9_.-]|$)|\.p12([^A-Za-z0-9_]|$)|\.pfx([^A-Za-z0-9_]|$)|\.keystore([^A-Za-z0-9_]|$)|id_rsa|(^|[/[:space:]"'"'"'=])secrets/'; then
    echo "BLOCKED by COMPASS Rule 11: this shell command references a credential/certificate file (.pem/.key/id_rsa/secrets/) — permanently locked in every mode. Reference it by name; ask the user to place/manage it themselves." >&2
    exit 2
  fi
  # .env family (except .example/.sample/.template): blocked unless the test unlock is ON.
  ENV_TOKENS="$(printf '%s' "$CMD" | grep -oE '(^|[^A-Za-z0-9_.])\.env(\.[A-Za-z0-9_.-]+)?' || true)"
  if [ -n "$ENV_TOKENS" ]; then
    REAL="$(printf '%s\n' "$ENV_TOKENS" | sed 's/^[^.]*//' | grep -vE '^\.env\.(example|sample|template)$' || true)"
    if [ -n "$REAL" ] && [ ! -f "$UNLOCK" ]; then
      echo "BLOCKED by COMPASS Rule 11: this shell command references '.env' — locked by default, and the lock applies to cat/head/tail/grep/sed/cp/source alike. If the user explicitly provided keys for TEST use, run '/secrets on' first (adds .gitignore guard + session-visible unlock), then apply the values without ever echoing them back." >&2
      exit 2
    fi
  fi
  exit 0
fi

# ---------- 2) File tools (Read/Edit/Write/MultiEdit) and Grep ----------
if command -v jq >/dev/null 2>&1; then
  FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // .tool_input.glob // empty' 2>/dev/null || true)"
else
  FILE_PATH="$(printf '%s' "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//')"
  [ -z "$FILE_PATH" ] && FILE_PATH="$(printf '%s' "$INPUT" | grep -o '"path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//')"
fi

[ -z "${FILE_PATH:-}" ] && exit 0

# Example/sample env files: always fine.
case "$FILE_PATH" in
  *.env.example|*.env.sample|*.env.template) exit 0 ;;
esac

case "$FILE_PATH" in
  *.env|*.env.*|*/.env|*/.env.*)
    if [ -f "$UNLOCK" ]; then
      exit 0   # test unlock ON — .env access permitted (values must still never be echoed to chat)
    fi
    echo "BLOCKED by COMPASS Rule 11: '.env' access is locked by default. If the user explicitly provided keys for TEST use, run '/secrets on' first (adds .gitignore guard + session-visible unlock), then apply the values without ever echoing them back." >&2
    exit 2
    ;;
  *.pem|*.key|*id_rsa*|*/secrets/*|*.p12|*.keystore|*.pfx)
    echo "BLOCKED by COMPASS Rule 11: '$FILE_PATH' is a credential/certificate file — permanently locked in every mode. Reference by name; ask the user to place/manage it themselves." >&2
    exit 2
    ;;
esac

exit 0
