#!/usr/bin/env bash
# COMPASS guard-secrets — blocks secret-file access; honors the explicit test unlock for .env.
# 🇰🇷 기본은 차단. 사용자가 /secrets on으로 명시 해제하면 .env만 읽기/쓰기 허용(테스트 모드).
#     인증서·개인키(.pem/.key/id_rsa/secrets/)는 어떤 모드에서도 영구 차단.
set -u

INPUT="$(cat)"

if command -v jq >/dev/null 2>&1; then
  FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)"
else
  FILE_PATH="$(printf '%s' "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//')"
fi

[ -z "${FILE_PATH:-}" ] && exit 0

# Example/sample env files: always fine.
case "$FILE_PATH" in
  *.env.example|*.env.sample|*.env.template) exit 0 ;;
esac

UNLOCK="${CLAUDE_PROJECT_DIR:-.}/.claude/secrets.unlock"

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
