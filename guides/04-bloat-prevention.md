# 04 — Bloat Prevention: Small Modules, Findable Code
> 🇰🇷 비대화 방지의 원리 — 왜 300/500줄인가, 어떻게 쪼개는가, 스택별 구조는 어떤가.

The operational protocol (budgets, split steps, Rule of Three) lives in the `bloat-guard` skill. This guide covers the reasoning and per-stack shapes.

## Why numeric budgets, and why these numbers

Agents (and humans) edit most reliably when the whole unit of work fits in view. Past ~300 lines, a file usually hosts more than one responsibility; past ~500, edits start colliding and searches slow. The numbers aren't sacred — the *tripwire* is. A budget you can name is a budget a hook can enforce, and the post-edit hook does: soft warning >300 (once per file per day), hard warning >500 (every time). The point isn't the warning; it's that the split conversation happens at 320 lines instead of 1,400.

## Smells table

| Smell | What it predicts | First move |
|---|---|---|
| File named `utils.ts` / `helpers.rs` growing | landfill forming | Relocate each function to the feature that owns it |
| `&&`-shaped names (`parseAndValidateAndSave`) | function doing 3 jobs | Split at each "and" |
| Import list longer than a screen | module knows too much | Check for a hidden second feature inside |
| Same 10 lines in 3 places | missing abstraction (Rule of Three: NOW extract) | Extract to the owning feature, or `shared/` if truly cross-cutting |
| One giant `types.ts` for the whole app | types divorced from behavior | Co-locate types with their feature |

## Per-stack vertical slices

**TypeScript**: `src/features/<name>/{api,service,store,types,index}.ts` — `index.ts` is the only import surface. App-level glue in `src/app/`; true cross-cutting code in `src/shared/` (which must earn every entry).

**Rust/Tauri**: `src-tauri/src/features/<name>/{mod,commands,service,types}.rs`. `commands.rs` stays a thin IPC skin; `lib.rs` only wires builders and `generate_handler!`.

**Python/FastAPI**: `app/features/<name>/{router,service,repo,schemas}.py`; `main.py` only includes routers.

The shared property: deleting a feature means deleting one folder plus a handful of registrations — that's the test of true modularity.
> 🇰🇷 진짜 모듈화의 시험: 기능 하나를 지울 때 "폴더 하나 + 등록 몇 줄"만 지우면 되는가.

## A split, walked through

`src/features/export/service.ts` hits 540 lines: CSV shaping, XLSX shaping, PDF shaping, plus shared column logic. Seams are by data type. Moves (tests green after each): (1) extract `columns.ts` (shared logic); (2) extract `csv.ts`, `xlsx.ts`, `pdf.ts`, each exposing one `render*` function; (3) `service.ts` shrinks to a 60-line dispatcher; (4) `index.ts` re-exports only `exportDocument()`; (5) map updated in the same commit (the export area's entry now notes "one renderer file per format — add new formats as sibling files"). Total public surface: unchanged. Internal findability: transformed.

## The counterweight

Bloat prevention has a failure mode of its own: confetti — 40 five-line files where 4 coherent ones would do, and premature abstractions built for one caller. The Rule of Three and the "when NOT to split" list in the skill are the counterweight. Optimize for *findability and safe editing*, not for minimal line counts.
