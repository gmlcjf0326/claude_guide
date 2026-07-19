---
name: codebase-map
description: Create and maintain docs/CODEBASE_MAP.md — the curated, decision-level index of where things live in the codebase and why. Use when the map is missing, when structure changed (files/modules added, moved, removed), when /map is invoked, when a search reveals the map disagrees with reality, or whenever the codebase has grown enough that finding things is slow. This is the antidote to "too many files, can't find anything".
---

# Codebase Map

As files multiply, retrieval cost explodes — unless a map keeps every lookup cheap. But the wrong kind of map is worse than none.
> 🇰🇷 파일이 늘수록 찾는 비용이 폭발한다. 지도가 그 비용을 상수로 눌러준다 — 단, '올바른 종류'의 지도만.

## The Prime Rule: decision-level, never file-tree

Research on repository context files found that auto-generated structural overviews *reduced* agent task success in most settings while inflating cost — while concise human-curated ones helped. The lesson:

- **Never** generate an exhaustive file tree. It rots the moment a file moves, and it answers no question a `Glob` can't.
- **Do** capture what a tree cannot: *purpose*, *boundaries*, *invariants*, and *where new things go*.

A good map entry survives a file rename. A bad one dies with it.

## Map Anatomy (see templates/CODEBASE_MAP.template.md)

1. **Overview** — 3–5 sentences: what this system is, the major moving parts, how data flows between them.
2. **Area table** — one row per feature/area (NOT per file): `Area | Path | Purpose | Key entry points | Notes/Invariants`. Aim for 5–20 rows. If you need 50, your rows are too granular.
3. **Invariants & Boundaries** — the load-bearing truths: "All authorization decisions happen in `src/features/auth` — UI never checks roles directly." "Only the `db/` layer touches SQL." These are the map's highest-value lines.
4. **Where to add X** — a lookup table for future work: new API endpoint → here; new background job → here; new Tauri command → here.
5. **Footer** — `Last verified: <date> against commit <short-sha>`.

## Update Contract (Core Rule 6)

Structure changed → map updated **in the same commit**. "Structure changed" means: area added/removed, module moved or repurposed, a boundary or invariant changed. Editing lines inside an existing file does NOT require a map update — that noise is what kills map discipline.
> 🇰🇷 구조 변경과 같은 커밋에서 지도 갱신. 단, 파일 내부 수정은 해당 없음 — 과잉 갱신이 지도 규율을 죽인다.

## Maintenance Procedure

1. Delegate scanning to the `explorer` subagent — keep your own context clean.
2. **Verify before writing**: every path mentioned must exist right now. Spot-check 3 random existing entries against reality; if 2+ are stale, do a full pass.
3. Preserve hand-written notes and invariants already in the file — they are the accumulated judgment; only correct them if provably wrong.
4. Update the footer date + commit sha.

## Smells

- Map longer than ~150 lines → it's becoming a file tree; collapse rows to area level.
- Entries describing *how code works internally* → that belongs in the code/docstrings; the map says *where and why*.
- Nobody (including you) consulted the map this week → entries are answering questions nobody asks; restructure around "Where to add X".
