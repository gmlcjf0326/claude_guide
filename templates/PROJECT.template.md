# PROJECT — <name>
> 🇰🇷 프로젝트 헌장 — 이 프로젝트가 '무엇인지'를 시스템 전체에 알려주는 조준 장치. /setup이 작성하고, Identity 블록은 세션마다 자동 주입된다. 피벗 등 크게 바뀔 때만 갱신.

## Identity (auto-injected every session — keep ≤ 12 lines)
- **Product:** <one line — what, for whom>
- **Stage:** idea | validating | MVP | revenue | scaling
- **Business model:** <subscription B2B SaaS / one-time license / internal tool / …>
- **Stack:** <e.g., TypeScript + Next.js + Supabase(Postgres); Tauri desktop; Expo mobile (later)>
- **Deploy target:** cloud / on-premise / app stores / mixed
- **Quality bias:** <e.g., ship-speed > polish (pre-PMF) · security > everything (on-prem)>
- **Non-negotiables:** <e.g., RLS on every table · Korean+English UI · offline-capable>

## Context (read during /spec and /blueprint)
- **Users & market:**
- **Monetization plan & pricing hypothesis:**
- **Key risks:**
- **Active rules for this project:** <e.g., typescript, serverless, postgres, design (+docker in CI)>
- **Irrelevant rules (never load here):** <e.g., java, python — cost ≈ 0 either way; listing them is about clarity>

Last reviewed: YYYY-MM-DD
