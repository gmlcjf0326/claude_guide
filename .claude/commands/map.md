---
description: Create or refresh docs/CODEBASE_MAP.md — the curated, decision-level index of the codebase
---

Load the `codebase-map` skill and follow it. Key constraints:
> 🇰🇷 자동 생성 파일트리 금지. 사람이 읽고 판단할 수 있는 '결정 수준' 지도만.

1. Use the `explorer` subagent to scan structure — do not flood your own context.
2. The map is **decision-level**: what each area is for, where to add what, which invariants must hold. It is NEVER an exhaustive file tree (auto-generated trees measurably hurt agents and rot instantly).
3. Follow `templates/CODEBASE_MAP.template.md`. Preserve any hand-written notes already in the file.
4. Verify before writing: every path you mention must exist. Update the "last verified" footer with today's date.
