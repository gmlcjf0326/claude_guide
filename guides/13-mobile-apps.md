# 13 — Mobile Apps: Build, Ship, and Actually Make Money
> 🇰🇷 웹을 넘어 앱으로 — 스택 선택, 스토어 배포 파이프라인, 그리고 '현실적인' 수익화. 이 가이드의 숫자들은 2026년 실측 데이터(RevenueCat SOSA 2026: 115,000+ 앱, $16B 매출 분석 등)에서 왔다. 희망이 아니라 지형도다.

## 0. Reality first — the funnel you are entering

Read these numbers before writing a line of code; every decision below is shaped by them.

- New subscription apps launched per month grew ~7× (≈2,000 → 14,700+) between Jan 2022 and Jan 2026 — the AI-assisted "vibe coding era" flooded supply. Yet apps launched before 2020 still take **69% of all subscription revenue**; 2025-or-later launches take ~3%.
- Of newly launched apps, only **17.3% reach $1K MRR within two years. Only 4.6% reach $10K MRR.** Median time to $1K differs by category (games ~32 days; business apps ~113 days).
- The market pays the tails: median YoY MRR growth is 5.3%, the top decile grows 306%+, the bottom quartile shrinks >33%. There is no comfortable middle.
- Value per payer (median Year-1 realized LTV): ~$32 North America, ~$25 Western Europe, ~$23 global, ~$14 India/SEA. Median D35 download→paid conversion: ~2.6% (NA) to ~1.4% (IN/SEA).

**Strategic conclusions for a solo dev** (this is the honest playbook, not doom):
1. "A better product" alone does not clear the incumbency wall — you need a **distribution edge** (an audience, SEO from your web product, a community) or an **underserved niche**. Note: the *Business* category is repeatedly flagged as overlooked with the best monetization/retention — B2C polish + B2B pricing is a real solo-dev opening.
2. **Ship the web/desktop product first** where you have COMPASS-grade velocity, validate willingness-to-pay, then bring the proven feature set to mobile with the audience you built. Mobile-first from zero is the hardest mode.
3. Decide kill/persevere criteria before launch (see §6) — the data says you'll know within ~100 days whether a top-performer path exists.
> 🇰🇷 요지: 앱스토어는 복권이 아니라 유통 게임이다. 유통 우위(웹 SEO, 커뮤니티, B2B 영업)나 틈새 없이 들어가면 17.3%의 바깥에 설 확률이 높다.

## 1. Choosing the stack (COMPASS options)

| Option | Profile | Regret scenario |
|---|---|---|
| **A — Expo / React Native** (default) | 효율↑효과↑ for a TypeScript dev: your React/TS skills and shared packages carry over; New Architecture migration is complete; EAS handles builds/signing/submission/OTA updates; the richest mobile ecosystem for auth/IAP/push. | You maintain a second app shell; truly native-feel polish still takes platform care. |
| **B — Tauri 2 mobile** | Rust core + system WebView now targets iOS/Android alongside desktop (v2 stable since Oct 2024, actively updated). The right call when a **Tauri desktop app already exists** and the UI is webview-friendly — one codebase, five platforms (Windows·macOS·Linux·iOS·Android). | Best understood as "desktop-first with mobile reach": webview UI feel, large-payload IPC costs, and a younger mobile plugin ecosystem than RN. A phone-first consumer product will fight it. |
| **C — Flutter** | Excellent performance (Impeller), single codebase, largest cross-platform mindshare. | Dart is a new language + new ecosystem for you; your TS/web code shares nothing. |
| **D — PWA / web-first** | Zero store fees, instant updates, one deploy. | No store distribution/discovery, weaker push/offline on iOS, and "install" friction — fine as a stage, weak as the endgame for consumer mobile. |

**Recommendation:** **A (Expo)** for phone-first products; **B** only to extend an existing Tauri desktop product; **D** as the validation stage before either. Record in `docs/DECISIONS.md` with a revisit trigger ("revisit B if the desktop app ships and mobile is a companion view").

## 2. Architecture — share the brain, not the face

```
repo/
  packages/
    shared/        ← types, Zod schemas, API client, business logic  (the brain)
  apps/
    web/           ← Next.js etc.
    mobile/        ← Expo app — screens/navigation are platform-true (the face)
  supabase/        ← one backend serves both
```

- pnpm workspaces; `shared` is imported by both apps; **all validation schemas live once** in shared and guard both clients and the API boundary.
- Auth, DB, storage: the same Supabase/Postgres backend serves web and mobile — RLS rules (serverless.md) protect both identically.
- UI does NOT share: navigation patterns, sheets, and typography follow Apple HIG on iOS and Material on Android (design.md rule). Shared logic, platform-true skin.
- Offline: mobile users expect grace on bad networks — cache reads, queue writes where the domain allows, and show honest sync states (the three orphan states, again).

## 3. The shipping pipeline (what actually happens)

1. **Accounts**: Apple Developer $99/year; Google Play $25 one-time. Register early — Apple identity verification can take days.
2. **Signing & builds**: let **EAS Build** manage certificates/profiles/keystores (hand-managing Apple signing is a rite of passage nobody needs). CI builds on tags.
3. **Test rings**: internal build → **TestFlight** (iOS) / **Play internal → closed testing** (Android) with 20–50 real users → phased production rollout (start 10%, watch crash rate, ramp).
4. **Store review — the classic rejection traps**, avoid on the first submission:
   - *Incompleteness*: crashes, placeholder content, broken links, demo accounts missing for review.
   - *Payment rules*: digital goods must use IAP where required (see §4) — a Stripe checkout for digital content inside the iOS app is an instant rejection outside the sanctioned paths.
   - *Privacy*: App Privacy labels (iOS) and Data Safety form (Android) must match actual SDK behavior; account **deletion** must be available in-app if accounts exist.
   - *Minimum functionality*: a webview wrapper around your website gets rejected — mobile must earn its shell.
5. **Updates**: JS/asset-only changes ship instantly via **expo-updates (OTA)**; anything touching native modules requires a store release — batch native changes, ship JS fixes continuously. Keep release notes honest; reviewers read them.
6. **Ops from day one**: crash reporting (Sentry) wired before launch, not after the first 1-star "it crashes" review; a minimal analytics event set (activation, paywall view, trial start, conversion) — decisions in §5 depend on these.

## 4. Commission math — what the stores take (2026 state)

| Channel | Rate | Notes |
|---|---|---|
| Apple, standard | 30% | Applies above $1M proceeds/yr |
| **Apple Small Business Program** | **15%** | <$1M prior-year proceeds; new devs qualify; **enroll in App Store Connect on day one** — it's free margin |
| Apple subscriptions, year 2+ | 15% | Per-subscriber after 12 paid months — retention literally halves the fee |
| Google Play, first $1M/yr | 15% | Program enrollment; above → 30% (until below) |
| Google Play subscriptions | 15% from day one | And announced: standard → **20%**, subscriptions → **10%** in EU/UK/US from June 30 2026, global by end 2027 |
| US external payment links | 0% + processor (~2.9%+30¢) | Court-opened (2025); **pending Supreme Court review — treat as upside, not a plan** |
| Korea / India user-choice billing | ~26% + processor | Regulated alternative billing — run the math; often not cheaper |
| EU (DMA terms) | layered | Core Technology Commission etc. — read current terms before relying on it |
| Web checkout (outside app) | 0% + processor | Legal everywhere for purchases made on the web; you just can't *steer* to it from inside the app in most regions |

**The solo-dev hybrid strategy**: IAP inside the app (it converts best and keeps review friction zero) at 15% via the Small Business Program, **plus** a normal web subscription page for traffic that starts on your website — same entitlements, verified server-side. Revisit external-link tactics only past ~$200K ARR, where the saved points outweigh the conversion loss.
> 🇰🇷 결론: 초기에는 "SBP 15% + 웹 구독 페이지 병행"이 최적. 외부결제 링크 최적화는 매출이 커진 뒤의 문제다.

### Korea-market notes (한국 시장 메모)
- Google Play in Korea runs under a **user-choice billing** mandate (third-party billing at ~26% + your processor fees) — run the math before assuming it beats the standard 15% tier; it usually doesn't at solo scale.
- **원스토어(ONE store)** is a real additional Android channel in Korea with lower fees — treat it as a post-traction expansion, not a launch requirement.
- Login expectations: **Kakao/Naver OAuth** materially lift Korean consumer sign-up conversion; note Apple's rule that offering any third-party social login on iOS requires offering **Sign in with Apple** too.
- Web-payment side of the hybrid strategy: **Toss Payments / KG이니시스** are the local Stripe-equivalents for the web subscription page; Stripe itself has limited local-method coverage in Korea.


## 5. Monetization playbook — what the data actually says

**Model**: subscription is the default for tool/utility/AI products. One-time purchase only for genuinely finished tools; ads only with large DAU (they are a floor, not a business, at solo scale).

**Paywall placement — the myth-buster**: hard paywalls (pay/trial before use) convert downloads→paid at a **10.7% median vs 2.1% for freemium — a 5× gap** — while 12-month retention is statistically identical (~27–28% on annual plans). Freemium isn't "safer"; it's slower. Default to a hard paywall with a trial; earn freemium only if your product has a viral/network loop that needs free users.

**Trials**: longer converts better — 17–32-day trials convert at a **42.5% median vs 25.5% for <4-day trials** (~70% better). The herd is moving the other way (short trials rose to 46.5% of apps) — this gap is a documented edge for those who follow the data.

**Onboarding is the business**: 60%+ of conversions happen in week one, ~⅓ on Day 0; for 3-day trials, 84% of cancellations happen by Day 1. The first session must reach the "aha" before the paywall asks. Spend `/improve` cycles here before anywhere else.

**Pricing**: anchor annual (default-selected) against monthly at ~2–2.5× the monthly×12 discount illusion; **localize by purchasing power**, not FX conversion (the $14-vs-$32 LTV geography means one global price mis-serves everyone). Sanity-check any paid acquisition against the ~$23 global median Y1 LTV per payer — at solo scale, organic/ASO/content beats paid ads almost always.

**Billing health is silent revenue**: billing errors cause **32.2% of Google Play cancellations vs 15.2% on iOS** — enable grace periods and retry states in Play Console / App Store Connect and handle the `BILLING_ERROR` states in-app. This is free retention.

**If your app is AI-powered**: AI apps show **+41% Year-1 LTV per payer** ($30 vs $21 median) but **markedly worse retention** (12-mo annual retention 21.1% vs 30.7% for non-AI). Translation: novelty monetizes, then churns. Use the early revenue to build the durable non-AI core (data, workflow lock-in, content) — an AI gimmick without a spine is a 6-month business.

**Implementation**: RevenueCat (or StoreKit 2 + Play Billing directly) with **server-side entitlements as the single source of truth** — the client asks "what am I entitled to?", never decides it. Webhooks → your Postgres `entitlements` table (RLS-protected) → both web and mobile read the same truth. Receipt validation server-side only. This is also what makes the hybrid web+IAP strategy coherent.

## 6. The 90-day solo launch plan

| Days | Focus | Exit gate |
|---|---|---|
| 1–30 | One vertical slice with the paywall built in from day one (test the *business*, not just the software); TestFlight to 20–50 users by day 30 | Activation ("aha") observed in real sessions |
| 31–60 | Onboarding iteration (the Day-0 numbers above), pricing test (annual anchor), ASO basics: keyword-bearing title/subtitle, screenshots that sell the outcome (they're your real paywall), review prompts after success moments | D35 download→paid ≥ ~2% (category-dependent) |
| 61–90 | Phased production rollout; weekly releases; watch conversion, D30 retention, crash-free rate | Honest trajectory read |
| Day ~100 | **Kill/persevere checkpoint** (pre-committed in docs/DECISIONS.md): on a $1K-MRR path per your category's median timeline → double down; flat → the data says pivot the niche or the distribution, not the button colors | Decision logged |

## 7. COMPASS wiring

- `/spec` for a mobile feature must answer: platform(s), offline expectations, monetization touchpoint, and store-policy constraints (they are requirements, not afterthoughts).
- The stack choice, paywall model, and pricing all go through `/blueprint` + `tradeoff-analysis` and land in `docs/DECISIONS.md` — each with the revisit triggers this guide's data suggests (e.g., "revisit external payments at $200K ARR", "revisit freemium if K-factor > 0.4").
- Store assets, privacy labels, and the release checklist live as tasks in `docs/TODO.md` like any other work — review rejections are almost always process failures, and process is what COMPASS does.
