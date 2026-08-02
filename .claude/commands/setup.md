---
description: One-time COMPASS onboarding — ingest reference docs, profile the project, tailor the system, seed the first tasks
---

ultrathink. Run once per project (or after a major pivot). If `docs/PROJECT.md` is already filled, this becomes a review of it, not a rewrite.
> 🇰🇷 범용 시스템을 '이 프로젝트 전용'으로 조준하는 1회성 명령. 참고 자료가 있으면 그것부터 깊이 읽는다.

## 0. INGEST reference material FIRST (docs/inputs/)
Before anything else, work `docs/inputs/`. This section is the canonical ingest procedure — `/spec` §0 and any mid-project drop refer back to it.
> 🇰🇷 원본은 그대로 두고 핵심만 증류한다. 목록부터 보고, 이미 흡수한 건 다시 읽지 않고, 충돌은 조용히 정하지 말고 질문으로 꺼낸다.

**0a. Inventory before reading.** `ls -laR docs/inputs/`, then read `docs/inputs/INGESTED.md` (the ledger). Anything already listed there and not modified since is DONE — do not re-read it; reuse what it says was distilled. Work only the unlisted and the revised. If nothing remains, skip to step 1. Order what remains: `_priority.md` / `00-*.md` first, then the rest.

**0b. Format ladder — convert, never guess, never silently skip.**

| Format | How to read it |
|---|---|
| `.md` `.txt` | directly |
| `.pdf` | `pdftotext -layout <f> -` · fallback: the Read tool's `pages` argument (scanned/image PDFs need this) |
| `.docx` `.pptx` `.xlsx` | `pandoc -t markdown <f>` · fallback: `unzip -p <f> 'word/document.xml'` (`ppt/slides/*.xml`, `xl/sharedStrings.xml`) and strip tags |
| `.hwpx` | it is a zip of XML: `unzip -p <f> 'Contents/section*.xml'` then strip tags |
| `.hwp` (binary v5) | **no reliable text path — do not guess.** Ask the user to re-export as `.hwpx` / `.pdf` / `.docx` |
| images (`.png` `.jpg` …) | open with the Read tool and describe them; moodboards/screenshots are design intent → PROJECT.md design notes, not requirements |

`pdftotext` and `pandoc` are frequently NOT installed — check with `command -v` before relying on them and go to the fallback without ceremony; the Read tool and `unzip` need no installation. If a file cannot be converted by any rung, **say so by name and ask** — an input silently skipped becomes a requirement silently lost.

**0c. Large-document triage.** A file over ~1,500 lines / ~100KB does NOT get read into this context. Hand it to the `explorer` subagent with an extraction brief (goal · hard constraints · requirements with acceptance criteria · integrations · open questions) and take back the distillation. In your step-7 summary, state which files you read in full and which you delegated — the user must know where the fidelity is lower.

**0d. Distill to permanent homes, with provenance.** Every distilled line carries `[src: <file>#<section>]` so any requirement can be traced back later.
- product identity, stage, model, constraints, quality bias → `docs/PROJECT.md`
- concrete requirements & acceptance criteria → a `docs/SPEC.md` DRAFT, header `Source: docs/inputs/<files> · draft from inputs, pending sign-off`, and `Signed off by user: ☐` left UNCHECKED
- reusable technical findings (API shapes, chosen patterns, benchmarks) → `docs/research/<topic>.md`
- open decisions the docs imply but don't resolve → carry into the interview

**0e. Conflicts and gaps become questions — and their answers become records.** If two documents disagree, or a critical dimension (users, monetization, deploy target) is unaddressed, list it out loud. Never silently pick a side. When the user resolves a conflict, append a `docs/DECISIONS.md` entry (Options = each document's position · Chose · Why · Revisit when). A conflict settled only in chat is a conflict that will return.

**0f. Write the ledger.** Append one row per file handled to `docs/inputs/INGESTED.md` — file, date, where it landed, and how it was read (full / delegated / converted-from). This is what makes the next run cheap and lets the session hook stop nagging.

Leave the originals in `docs/inputs/` as source-of-truth; they are NOT loaded every session (zero idle cost).

## 1–7. Profile & tailor
1. **Detect before asking**: inspect what exists — `package.json` / `Cargo.toml` / `pyproject.toml` / `go.mod` / `pom.xml`·`build.gradle(.kts)` / `Gemfile` / `composer.json` / `*.csproj` / `mix.exs` / `supabase/` / `Dockerfile` / git history (`git log --oneline -10`). Never ask what the repo or the ingested docs already answer.
2. **Interview — ONE round, 5–8 questions max**, choices offered (A/B/C). **Skip anything the inputs already answered** — ask only about genuine gaps, conflicts, and the dimensions still unknown: product one-liner & target user · stage · business model + pricing · deploy target · quality bias (what wins when goals conflict?) · non-negotiables · **(user-facing products) design preferences: brand color, font (default: Pretendard for KR), icon set, 2–3 reference apps/screenshots the user likes** · for existing code: top pain point.
3. **Write `docs/PROJECT.md`** from `templates/PROJECT.template.md`. Identity block ≤ 12 lines — injected every session.
3b. **Permanent directives**: ask about anything that must never be forgotten (language policy, forbidden deps, security invariants). Always offer the language directive explicitly — ask which language ALL conversation should use and write `All conversation, questions, and reports in <language> (code and identifiers stay in English)`; for Korean users the ready-made form is `모든 대화·질문·보고는 한국어로 한다 (코드·식별자는 영어)`. Write each to `.claude/rules/project-directives.md` (always-loaded). Design preferences from step 2 land in PROJECT.md and, if strong, as a directive (e.g., `아이콘은 lucide-react만 사용`).
3c. **Model access (once)**: ask whether the user's plan includes Opus. **YES** → copy `templates/settings.local.json.example` to `.claude/settings.local.json` (enables `opusplan`: Opus plans, Sonnet executes) and offer to pin `model: opus` in `.claude/agents/architect.md` and in the frontmatter of `.claude/commands/spec.md` / `blueprint.md` / `setup.md` so the highest-leverage reasoning moments always get the strongest model. **NO** → change nothing; everything runs on the plan's default model.
4. **Tailor**: record which `.claude/rules/*.md` apply vs never (idle cost ≈ 0 either way). **If the client/deploy target is Korean public-sector (공공기관·정부)**: seed the directive `공공 표준: templates/design/tokens-krds.css 사용 · KWCAG AA 4.5:1 하드게이트 · 매직넘버 ≥50 · Pretendard GOV 17px/150%/keep-all` into project-directives, ask 표준형(중앙부처) vs 확장형(자체 CI) — it decides palette freedom — and point PROJECT.md at `guides/16-public-sector-design.md`.
4b. **Legacy codebases**: if this is a pre-existing repo (most files predate COMPASS), offer to write `.claude/compass.conf` with relaxed bloat budgets (e.g. `COMPASS_BLOAT_SOFT=400`, `COMPASS_BLOAT_HARD=800`) — the hook already warns only when an over-budget file GROWS, so history isn't nagged; record the choice in PROJECT.md. Also record the incumbent toolchain (package manager, formatter, test runner) as a directive so stack rules defer to it.
4c. **Gate permissions**: for the detected stack, add its verify commands to `.claude/settings.local.json` `permissions.allow` (e.g. `Bash(go test:*)`, `Bash(./gradlew test:*)`, `Bash(dotnet test:*)`) so the /next loop runs prompt-free.
5. **Seed `docs/TODO.md` Phase 0**: gate-setup tasks for any missing verification (lint/typecheck/test); park CI in `docs/BACKLOG.md`.
6. **Existing codebase**: run the `/map` procedure (explorer-assisted) so the index exists before the first task.
7. Finish with an ≤ 10-line profile summary that explicitly notes: what was learned from inputs vs. from the interview, which input files were read in full vs. delegated (§0c), any unresolved conflicts, and the recommended next step. If §0 produced a SPEC draft, the next step is **`/spec` to verify the draft against the user** — documents are evidence, not sign-off, and `/blueprint` will refuse an unsigned SPEC. If there is no draft: "`/spec <goal>`".
