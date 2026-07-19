---
paths:
  - "**/*.{ts,tsx,mts,cts}"
---

# TypeScript / Node Rules
> 🇰🇷 TS/Node 작업 시 자동 적용되는 컨벤션.

## Compiler is the first reviewer
`tsconfig.json` must include — never weaken these to silence an error; fix the code:
```jsonc
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

## Types
- `any` is forbidden. Unknown shape → `unknown` + explicit narrowing.
- Validate ALL external data (HTTP bodies, env, file, LLM output) with Zod at the boundary, then trust the inferred type inside. Parse, don't validate twice.
- Derive types from values where possible (`z.infer`, `as const`, `ReturnType`) instead of writing parallel type declarations that drift.
- Model absence explicitly (`T | null`), never sentinel values (`-1`, `""`).

## Structure
- Feature folders: `src/features/<name>/{api,service,store,types,index}.ts` — the folder's `index.ts` is its ONLY public surface.
- Named exports only; no default exports (breaks rename-refactors and auto-imports).
- No cross-feature deep imports (`features/a/internal/x`) — go through the feature's index or promote to `shared/` (Rule of Three applies).

## Errors & async
- Never swallow: every `catch` either handles meaningfully, rethrows with context, or logs-and-degrades explicitly. Empty catch blocks are bugs.
- No floating promises — `await`, `void` with a comment, or `.catch` every promise.
- Throw `Error` subclasses (or return typed results), never strings.

## Toolchain
- Package manager: **pnpm**. Lockfile committed; `pnpm install --frozen-lockfile` in CI.
- Lint/format: **Biome** by default (one fast tool); use ESLint flat config + Prettier only when a specific plugin (react-hooks, a11y) is required. The post-edit hook auto-formats — never hand-format.
- Tests: **Vitest**. Test files co-located: `thing.test.ts` next to `thing.ts`.
- Env access in exactly ONE module (`src/config.ts`) that Zod-validates `process.env` at startup and exports typed config. `process.env` anywhere else is a violation.
