# docs/inputs — 참고 자료 투입구 (reference material drop zone)
> 🇰🇷 여기에 당신이 미리 연구한 문서를 넣으세요. `/setup`(및 `/spec`)이 **가장 먼저** 이 폴더를 읽고 분석해 PROJECT.md·SPEC 초안·research/로 증류합니다. 이 폴더 자체는 항상 로드되지 않으므로(토큰 0), 원본이 아무리 길어도 안전합니다.

## What to put here
- 딥 리서치 결과물, 요구사항 정의서, 제안요청서(RFP), 경쟁 분석, PRD 초안, 회의록, 기술 조사
- 참고할 코드 스니펫, API 문서 발췌, 데이터 스키마 메모
- "이렇게 만들고 싶다"는 방향성 문서, 무드보드·스크린샷, 레퍼런스 링크 모음

## 언제 넣어도 됩니다 — 시작 시점이 아니어도
프로젝트 도중에 넣어도 됩니다. 세션 시작 훅이 **원장(`INGESTED.md`)에 없는 파일**을 발견하면 다음 세션 브리핑에 "미흡수 자료 있음"으로 알립니다. 바로 반영하고 싶으면 그렇게 말하면 되고(자연어로 충분), 기능 단위면 `/spec`, 프로젝트 전반이면 `/setup`입니다.

## 지원 포맷 — .md가 가장 정확하지만, md가 아니어도 됩니다
| 포맷 | 처리 방식 |
|---|---|
| `.md` `.txt` | 그대로 읽음 (가장 정확) |
| `.pdf` | `pdftotext -layout` → 실패 시 Read 도구가 페이지 단위로 직독 (스캔본 포함) |
| `.docx` `.pptx` `.xlsx` | `pandoc -t markdown` → 실패 시 내부 XML 언집 |
| `.hwpx` | zip+XML 구조라 `Contents/section*.xml` 언집으로 추출 |
| `.hwp` (구 바이너리) | **자동 추출 경로가 없습니다** — `.hwpx`/`.pdf`/`.docx`로 내보내 주세요. 추측해서 읽지 않습니다 |
| 이미지 (`.png` `.jpg` …) | 직접 보고 해석 — 무드보드·스크린샷은 요구사항이 아니라 **디자인 의도**로 PROJECT.md에 기록됩니다 |

`pdftotext`·`pandoc`은 설치 안 된 환경이 흔합니다 — 없으면 즉시 대체 경로로 갑니다(Read 도구와 `unzip`은 별도 설치가 필요 없습니다). 어떤 경로로도 변환이 안 되면 **조용히 건너뛰지 않고 파일명을 말하며 물어봅니다.** 말없이 넘어간 입력은 말없이 사라진 요구사항이기 때문입니다.

## 대용량 문서 (수백 쪽 RFP 등)
1,500줄 / 100KB를 넘는 파일은 본 대화에 통째로 올리지 않고 `explorer` 서브에이전트에 추출 브리프를 주어 위임합니다. 어떤 파일을 통독했고 어떤 파일을 위임했는지 요약에 명시하므로, 정밀도가 낮은 지점을 당신이 알 수 있습니다.

## How it's used
- 인벤토리 → 원장(`INGESTED.md`) 대조 → **미흡수분만** 읽기 → 증류 → 원장 기록. 같은 파일을 두 번 읽지 않습니다.
- 증류 착지점: 핵심 사실 → `docs/PROJECT.md` · 요구사항 → `docs/SPEC.md` 초안 · 재사용 가능한 기술 발견 → `docs/research/<topic>.md`. 모든 줄에 `[src: 파일#절]` 출처가 붙어 나중에 역추적됩니다.
- 문서에서 뽑은 SPEC은 **초안**(`Signed off by user: ☐`)입니다. 문서는 증거일 뿐 서명이 아니므로, `/spec`이 항목별 확인을 받기 전까지 `/blueprint`가 계획 수립을 거부합니다.
- 문서끼리 충돌하거나 빠진 부분은 질문으로 꺼냅니다. 당신이 판정하면 그 결과가 `docs/DECISIONS.md`에 남습니다 — 채팅에서만 정리된 결론은 사라지니까요.
- 원본은 여기 그대로 남고, 매 세션 로드되지 않습니다.

## Naming (optional but helps)
- `requirements-*.md`, `research-*.md`, `competitive-*.md`, `prd-*.md`, `notes-*.md`
- A `_priority.md` or `00-*.md` file is read first if present — put your most important brief there.

## Not sure how to structure your docs?
Just drop them in as-is. Messy is fine — /setup extracts structure. The one thing that helps most: state your **goal** and **hard constraints** somewhere explicit.
