# Codebase Map
> 🇰🇷 결정 수준 색인 — 어디에 무엇이 '왜' 있는가. 파일트리 금지 (자동 생성 트리는 에이전트 성능을 해친다).
> Contract (Rule 6): structure changed → this file updated in the SAME commit.

## Overview
<!-- 3–5 sentences: what this system is, its moving parts, how data flows. -->

## Areas
| Area | Path | Purpose | Entry points | Invariants / notes |
|---|---|---|---|---|
| <feature> | src/features/<x> | <what it owns> | index.ts | <load-bearing truth> |

## Invariants & Boundaries
- <!-- e.g., "All authz decisions in features/auth — UI never checks roles." -->

## Where to add X
| Adding… | Goes in |
|---|---|
| a new API endpoint | <path + convention> |
| a new background job | <path + registration step> |
| a new table/migration | <path + RLS reminder> |

---
Last verified: YYYY-MM-DD against commit <sha>
