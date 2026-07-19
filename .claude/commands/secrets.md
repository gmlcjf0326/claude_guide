---
description: Toggle test-mode secrets handling — lets Claude write user-provided keys into .env and read it back (test use only)
argument-hint: on | off | status
---

Manage the unlock marker `.claude/secrets.unlock` for: $ARGUMENTS
> 🇰🇷 사용자가 채팅으로 직접 준 키는 이미 노출된 값 — 테스트 목적이면 .env 적용을 막을 이유가 없다. 단, 켜짐이 '보이도록' 명시 모드로 운영한다.

**on**:
1. Verify `.gitignore` contains `.env*` (and `!.env.example`) — add the lines if missing. No gitignore guard, no unlock.
2. `mkdir -p .claude && date > .claude/secrets.unlock` and ensure `.claude/secrets.unlock` itself is gitignored.
3. Confirm to the user: unlocked = `.env`/`.env.*` read & write via tools; still forbidden in every mode = echoing secret VALUES into chat/logs (confirm by key NAME only: "STRIPE_KEY 저장됨"), committing env files, and touching `.pem`/`.key`/`id_rsa`/`secrets/` (permanent block).
4. One-time reminder (once, not nagging): keys pasted in chat are test-grade — rotate before production.

**off**: delete `.claude/secrets.unlock`, confirm locked.

**status** (or no argument): report ON/OFF; if ON, show marker age and suggest `off` if stale.

Working rules while ON: when writing keys, read-merge-write `.env` preserving existing entries (one `KEY=value` per line); after applying, prove usage by running the thing that needed the key (test/curl) and show that output — never the values.
