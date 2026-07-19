# docs/inputs — 참고 자료 투입구 (reference material drop zone)
> 🇰🇷 여기에 당신이 미리 연구한 문서를 넣으세요. `/setup`(및 `/spec`)이 **가장 먼저** 이 폴더를 읽고 분석해 PROJECT.md·SPEC 초안·research/로 증류합니다. 이 폴더 자체는 항상 로드되지 않으므로(토큰 0), 원본이 아무리 길어도 안전합니다.

## What to put here
- 딥 리서치 결과물, 요구사항 정의서, 경쟁 분석, PRD 초안, 회의록, 기술 조사 (.md 권장; .txt/.pdf도 가능하나 md가 가장 잘 분석됨)
- 참고할 코드 스니펫, API 문서 발췌, 데이터 스키마 메모
- "이렇게 만들고 싶다"는 방향성 문서, 무드보드 설명, 레퍼런스 링크 모음

## How it's used
- `/setup` reads EVERYTHING here first, then interviews you only about what the documents DON'T already answer (no re-asking what you wrote).
- Long originals are distilled: key facts → `docs/PROJECT.md`, requirements → `docs/SPEC.md` draft, reusable findings → `docs/research/<topic>.md`. The originals stay here as the source of truth but are NOT loaded every session.
- Conflicts or gaps in your documents are surfaced as questions, not silently resolved.

## Naming (optional but helps)
- `requirements-*.md`, `research-*.md`, `competitive-*.md`, `prd-*.md`, `notes-*.md`
- A `_priority.md` or `00-*.md` file is read first if present — put your most important brief there.

## Not sure how to structure your docs?
Just drop them in as-is. Messy is fine — /setup extracts structure. The one thing that helps most: state your **goal** and **hard constraints** somewhere explicit.
