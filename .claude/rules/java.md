---
paths:
  - "**/*.java"
---

# Java / Spring Boot Rules (brief)
> 🇰🇷 Java 작업 시 자동 적용 (간결판).
> Spring-specific items (annotations, slice tests, @Transactional) apply only when Spring Boot is actually on the build path — plain-Java, Android, and library projects keep the structural rules (constructor injection, package-by-feature, records) and skip the Spring items.
> Defaults for NEW code. In an existing repository, the repo's established tooling and conventions win — record the deviation once in `.claude/rules/project-directives.md` instead of fighting the codebase.

- **Constructor injection only** — no field `@Autowired`; dependencies are `final`. Enables plain-JUnit construction.
- **Package by feature** (`com.app.billing`), not by layer (`controllers/`, `services/` at root scatter every feature).
- Controllers thin: validate (`@Valid` + Bean Validation on request records) → service → response DTO. Never expose entities directly.
- `record` for DTOs and value objects; entities stay mutable-minimal.
- One `@RestControllerAdvice` translates domain exceptions to HTTP problem responses — no try/catch pyramids in controllers.
- Transactions (`@Transactional`) live on service methods, never on controllers; keep them short.
- Tests: JUnit 5 + AssertJ; slice tests (`@WebMvcTest`, `@DataJpaTest`) by default; Testcontainers for real-DB integration paths.
- Nulls: return `Optional<T>` from finders; never pass `Optional` as a parameter.
