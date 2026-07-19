---
description: Consult the Opus architect subagent with a structured brief about a hard design question
argument-hint: [the question or decision you want judged]
---

Prepare a structured brief, then invoke the `architect` subagent with it:
> 🇰🇷 오퍼스 어드바이저 소환. 브리핑이 부실하면 판정도 부실하다.

- **Context**: one paragraph on the project and current state
- **Question**: $ARGUMENTS
- **Options considered so far**: with your current leaning
- **Constraints**: pull the relevant lines from docs/SPEC.md

Relay the architect's verdict verbatim (VERDICT / WHY / RISKS / MISSED ALTERNATIVES / RECOMMENDATION), then add your one-paragraph synthesis: agree, disagree-with-reasons, or what to verify next. If the decision is made here, append it to docs/DECISIONS.md.
