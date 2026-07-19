---
description: Permanently persist a directive so it survives compaction, /clear, and every future session
argument-hint: <the instruction to make permanent>
---

Make this permanent: $ARGUMENTS
> 🇰🇷 대화는 휘발된다. 이 명령은 지침을 '디스크의 올바른 집'에 넣어 영구화한다.

Classify it, write it to exactly ONE home, then confirm:

| Kind of instruction | Permanent home | Why there |
|---|---|---|
| Project-wide behavior ("in this project, always/never …") | `.claude/rules/project-directives.md` — append, numbered | always-loaded, every session |
| Stack convention (tied to a file type) | the matching `.claude/rules/<stack>.md` | loads whenever those files are touched |
| Identity fact (what the product is, quality bias, non-negotiable) | `docs/PROJECT.md` | identity block auto-injected each session |
| A choice among alternatives ("we use X, not Y, because…") | `docs/DECISIONS.md` entry | keeps the why + a revisit trigger |
| Must happen mechanically, zero judgment involved | **propose a hook** (recipe: guides/10) — offer, never silently create | prompts are advisory; hooks are law |

Steps:
1. Classify with one sentence of reasoning. If it's ambiguous, ask one question instead of guessing.
2. Write it — imperative voice, ≤ 2 lines. For project-directives.md: keep the file ≤ 40 lines; if adding would exceed, propose a merge/prune first.
3. Confirm back: where it went, the exact line as written, and that it now survives compact/clear/new sessions.
4. If it also deserves hook enforcement (tier 3 on the promotion ladder), say so and offer to wire it.

Never settle for "noted" in conversation — the conversation is the one place that does not survive.
