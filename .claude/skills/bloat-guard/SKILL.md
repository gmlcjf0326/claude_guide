---
name: bloat-guard
description: Code-bloat prevention and the file-splitting protocol. Use whenever the post-edit hook fires a BLOAT BUDGET warning, whenever a file approaches 300 lines or a function approaches 50, before adding a new responsibility to an existing module, during /improve sweeps, and when deciding where new code should live. Enforces feature-based module splitting so the codebase stays navigable as it grows.
---

# Bloat Guard

Files do not become 2,000 lines in one commit. They get there 30 "just one more function" decisions at a time. This skill is the interrupt.
> 🇰🇷 2천 줄 파일은 한 번에 생기지 않는다. "함수 하나만 더"가 서른 번 쌓인 결과다. 이 스킬이 그 인터럽트다.

## Budgets (Core Rule 5 — hook-enforced)

| Unit | Soft | Hard | On breach |
|---|---|---|---|
| File | 300 lines | 500 lines | Soft: plan the split this task. Hard: split BEFORE adding anything. |
| Function | 50 lines | 80 lines | Extract steps into named helpers |
| Module (folder) | one feature | — | New feature → new folder, never a new wing on an old one |
| Function params | 4 | — | Pass an options object / struct |

Budgets are heuristics, not physics — but overriding one requires saying *why* out loud (e.g., a generated file, a cohesive state machine, a lookup table). Silence is not an override.

## Organize by feature, not by layer (vertical slices)

```
src/features/billing/        src-tauri/src/features/billing/
  api.ts        ← routes/handlers          mod.rs
  service.ts    ← business logic           commands.rs   ← #[tauri::command] thin layer
  store.ts      ← data access              service.rs    ← logic
  types.ts                                 types.rs
  index.ts      ← ONLY public surface
```

Why: a feature folder is a self-contained context an agent (or you) can load whole. Layer folders (`controllers/`, `services/`, `utils/`) scatter one feature across the repo and turn every change into a five-file hunt. `shared/` exists but must earn every entry (see Rule of Three).

## The Split Protocol

1. **Find the seams.** In order of preference: by sub-feature → by lifecycle stage (parse / validate / execute / persist) → by data type. Never split "top half / bottom half".
2. **Name the pieces by intent**: `invoice-builder.ts`, not `helpers2.ts`. If you can't name it, you haven't found a real seam — look again.
3. **Extract with tests green** at every step: move code → fix imports → run tests → commit. Small moves, never a big-bang reshuffle.
4. **Shrink the public surface**: after splitting, re-export only what outsiders need through the folder's `index.ts` / `mod.rs`. Internal pieces stay internal.
5. **Update `docs/CODEBASE_MAP.md`** in the same commit if an area boundary moved (Rule 6).

## Rule of Three (against premature abstraction)

First occurrence: write it inline. Second: copy it, add a `// dup: <where>` comment. Third: NOW extract the abstraction — three call sites reveal the real shape. Abstracting at one call site is how `utils/` becomes a landfill of wrong guesses.
> 🇰🇷 중복 제거보다 나쁜 것은 잘못된 추상화다. 세 번째 등장에서 추상화하라.

## When NOT to split

A cohesive algorithm that reads top-to-bottom · a generated file · a table/config whose length is data, not logic · splitting that would create circular imports. In these cases, state the reason and move on — the budget bends to judgment declared out loud.
