# INGESTED — 흡수 원장 (ingestion ledger)
> 🇰🇷 `docs/inputs/`의 어떤 파일을 **언제, 무엇으로 증류했는지**의 단일 기록. `/setup`과 `/spec`이 여기에 한 줄씩 추가하고, 다음 실행 때 이 표를 먼저 읽어 **이미 흡수한 파일은 다시 읽지 않습니다**(토큰 절약 + 신규/개정분 식별). 세션 시작 훅도 이 표에 없는 파일을 발견하면 "미흡수 자료 있음"을 알립니다.
> Written by `/setup` §0 and `/spec` §0. Never auto-loaded in full — the hook only compares filenames against it.

| File | Ingested | Distilled to | Note |
|---|---|---|---|
| _(none yet)_ | | | |

<!--
행 작성 요령 / How to write a row:
- **File**: `docs/inputs/` 기준 상대 경로 (하위 폴더 포함). 파일명이 그대로 적혀 있어야 훅이 흡수된 것으로 인식합니다.
- **Ingested**: YYYY-MM-DD.
- **Distilled to**: 착지한 곳을 전부 — `PROJECT.md(identity)`, `SPEC.md(MUST 1–7)`, `research/<topic>.md`, `DECISIONS.md(D-0003)`.
- **Note**: 통독/위임 여부, 변환 경로(`hwpx→xml`), 미해결로 남긴 부분.

예시 / Example:
| `rfp-2026.hwpx` | 2026-08-02 | PROJECT.md(identity), SPEC.md(MUST 1–7), research/nara-api.md | hwpx→xml 변환 · 120쪽이라 explorer 위임 · pp.12–18 요금 조항 충돌 → D-0003 |
| `notes-meeting-0715.md` | 2026-08-02 | SPEC.md(non-goals) | 통독 |

파일을 **개정**했다면 그 행의 Ingested 날짜를 갱신하세요 — 날짜가 파일보다 오래되면 훅이 `(revised)`로 다시 알립니다.
-->
