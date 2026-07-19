---
description: Structured deep research on a topic — findings persisted to docs/research/ so they never need re-searching
argument-hint: <question or topic>
---

Research this properly, then make it permanent: $ARGUMENTS
> 🇰🇷 조사는 한 번, 활용은 영원히 — 결과는 docs/research/에 착지한다.

1. **Sharpen the question**: what decision does this research serve, and what evidence would change the answer? One sentence each.
2. **Apply the `research` skill's source ladder**: installed packages → package CLIs → Context7 MCP → official docs via WebFetch/WebSearch → cross-checked secondary. Typically 3–8 sources; primary sources outrank volume.
3. **Write `docs/research/<kebab-slug>.md`** (`mkdir -p docs/research` first if needed):
   - Question · TL;DR (≤ 5 lines) · Findings (each claim with source + date) · Implications for THIS project · Open questions · footer: "Verified against <version(s)> on <date>".
4. **Reply** with the TL;DR and the file path. If it informs a pending decision, reference the research file from the `docs/DECISIONS.md` entry.

Do not paste walls of raw search results into chat — distill; the file holds the detail.
