---
description: Independent self-review of the current diff before anything is called done
---

1. Invoke the `code-reviewer` subagent on the current diff. Wait for its structured verdict.
2. If **FAIL**: fix every blocking issue, re-run the gates, then invoke the reviewer again. Repeat until PASS (or explain precisely why a finding is a false positive).
3. If **PASS**: summarize in ≤ 5 lines — gates status, anything intentionally deferred (add those to `docs/BACKLOG.md`), and whether `docs/` state is current.
> 🇰🇷 리뷰어의 FAIL은 협상 대상이 아니다. 고치거나, 왜 오탐인지 증명하거나.
