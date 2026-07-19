---
description: One-time COMPASS onboarding — ingest reference docs, profile the project, tailor the system, seed the first tasks
---

ultrathink. Run once per project (or after a major pivot). If `docs/PROJECT.md` is already filled, this becomes a review of it, not a rewrite.
> 🇰🇷 범용 시스템을 '이 프로젝트 전용'으로 조준하는 1회성 명령. 참고 자료가 있으면 그것부터 깊이 읽는다.

## 0. INGEST reference material FIRST (docs/inputs/)
Before anything else, check `docs/inputs/`. If it contains files beyond README.md/.gitkeep:
1. Read them ALL — prioritize `_priority.md` / `00-*.md` if present, then the rest. For long files, read fully; these are the user's own research and carry high signal.
2. **Distill, don't dump**: extract into the right permanent homes —
   - product identity, stage, model, constraints, quality bias → `docs/PROJECT.md`
   - concrete requirements & acceptance criteria → a `docs/SPEC.md` DRAFT (mark it "draft from inputs, pending sign-off")
   - reusable technical findings (API shapes, chosen patterns, benchmarks) → `docs/research/<topic>.md` with a source note pointing back to the input file
   - open decisions the docs imply but don't resolve → note them for the interview
3. **Surface conflicts and gaps out loud**: if two documents disagree, or a critical dimension (users, monetization, deploy target) is unaddressed, list these — they become your interview questions. Never silently pick a side.
4. Leave the originals in `docs/inputs/` as source-of-truth; they are NOT loaded every session (zero idle cost).
> 🇰🇷 원본은 그대로 두고 핵심만 증류한다. 문서끼리 충돌하거나 빠진 부분은 조용히 정하지 말고 질문으로 꺼낸다.

If `docs/inputs/` is empty, skip to step 1 and run the normal interview.

## 1–7. Profile & tailor
1. **Detect before asking**: inspect what exists — `package.json` / `Cargo.toml` / `pyproject.toml` / `supabase/` / `Dockerfile` / git history (`git log --oneline -10`). Never ask what the repo or the ingested docs already answer.
2. **Interview — ONE round, 5–8 questions max**, choices offered (A/B/C). **Skip anything the inputs already answered** — ask only about genuine gaps, conflicts, and the dimensions still unknown: product one-liner & target user · stage · business model + pricing · deploy target · quality bias (what wins when goals conflict?) · non-negotiables · **(user-facing products) design preferences: brand color, font (default: Pretendard for KR), icon set, 2–3 reference apps/screenshots the user likes** · for existing code: top pain point.
3. **Write `docs/PROJECT.md`** from `templates/PROJECT.template.md`. Identity block ≤ 12 lines — injected every session.
3b. **Permanent directives**: ask about anything that must never be forgotten (language policy, forbidden deps, security invariants). Always offer the language directive explicitly — ask which language ALL conversation should use and write `All conversation, questions, and reports in <language> (code and identifiers stay in English)`; for Korean users the ready-made form is `모든 대화·질문·보고는 한국어로 한다 (코드·식별자는 영어)`. Write each to `.claude/rules/project-directives.md` (always-loaded). Design preferences from step 2 land in PROJECT.md and, if strong, as a directive (e.g., `아이콘은 lucide-react만 사용`).
3c. **Model access (once)**: ask whether the user's plan includes Opus. **YES** → copy `templates/settings.local.json.example` to `.claude/settings.local.json` (enables `opusplan`: Opus plans, Sonnet executes) and offer to pin `model: opus` in `.claude/agents/architect.md` and in the frontmatter of `.claude/commands/spec.md` / `blueprint.md` / `setup.md` so the highest-leverage reasoning moments always get the strongest model. **NO** → change nothing; everything runs on the plan's default model.
4. **Tailor**: record which `.claude/rules/*.md` apply vs never (idle cost ≈ 0 either way). **If the client/deploy target is Korean public-sector (공공기관·정부)**: seed the directive `공공 표준: templates/design/tokens-krds.css 사용 · KWCAG AA 4.5:1 하드게이트 · 매직넘버 ≥50 · Pretendard GOV 17px/150%/keep-all` into project-directives, ask 표준형(중앙부처) vs 확장형(자체 CI) — it decides palette freedom — and point PROJECT.md at `guides/16-public-sector-design.md`.
5. **Seed `docs/TODO.md` Phase 0**: gate-setup tasks for any missing verification (lint/typecheck/test); park CI in `docs/BACKLOG.md`.
6. **Existing codebase**: run the `/map` procedure (explorer-assisted) so the index exists before the first task.
7. Finish with an ≤ 10-line profile summary that explicitly notes: what was learned from inputs vs. from the interview, any unresolved conflicts, and the recommended next step — usually "review the SPEC draft, then `/blueprint`" (if inputs produced a draft) or "`/spec <goal>`" (if not).
