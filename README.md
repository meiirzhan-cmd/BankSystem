# Bank System — Learning Project

A microservices-based banking platform built **end-to-end as a learning exercise**.
The goal is not to ship a production bank — it's to walk through the same
architectural decisions a real fintech team makes, starting from a naive
implementation and progressively layering in the patterns that make a real
system safe, observable, and operable.

## Why this project exists

Most tutorials show you the finished pattern (JWT, encryption, event sourcing,
circuit breakers) without showing you the problem that pattern solves. This
project deliberately does the opposite: build the naive version first, feel
where it hurts, then refactor to the production pattern.

By the time the project is "done," every piece of complexity in it will exist
because we hit a concrete reason to add it — not because a blog post said so.

## Tech stack

- **Backend**: Spring Boot 4.0.6, Spring Cloud 2025.1.1, Java 21
- **Discovery**: Netflix Eureka
- **Gateway**: Spring Cloud Gateway (WebFlux)
- **Database**: PostgreSQL per service, Flyway migrations
- **Messaging**: Kafka (Spring Kafka)
- **Cache / Rate limiting**: Redis
- **Auth**: Keycloak (OAuth2 / OIDC, JWT)
- **Build**: Maven (via the wrapper — no global install needed)
- **Frontends (later)**: Nuxt 4 web, Expo + React Native mobile

## Current state

This is **starter-quality code**. It compiles and runs, but every module has
known shortcuts that we will revisit. Specifically:

| Area | Right now | What changes later |
|---|---|---|
| Card storage | Raw PAN in PostgreSQL | Encrypted via HashiCorp Vault transit engine; only tokens stored |
| Secrets | Hardcoded passwords in `application.yml` | Env vars + Vault / Docker secrets |
| Auth | OAuth2 config commented out | Keycloak running; JWT validated at the gateway |
| Authorization | None | Role-based (user / merchant / admin) via JWT claims |
| Inter-service auth | None | mTLS or service tokens between microservices |
| Observability | Console logs only | OpenTelemetry → Tempo / Loki / Prometheus |
| Resilience | None | Circuit breakers (Resilience4j) on every outbound call |
| Idempotency | None | Idempotency keys on all write endpoints |
| Events | Naive Kafka producer/consumer | Outbox pattern + schema registry |
| Tests | None yet | Unit + integration (Testcontainers) + contract (Pact) |
| CI/CD | None | GitHub Actions → build, test, container scan, deploy |

## Build order

The services were built in this order so each builds on the previous:

1. **discovery-service** — Eureka registry, port 8761
2. **shared-lib** — common DTOs, exceptions
3. **gateway** — Spring Cloud Gateway, port 8090
4. **account-service** — first domain service, port 8091 (wallets + cards)
5. *(coming)* docker-compose for the full local stack (Postgres, Redis, Kafka, Keycloak)
6. *(coming)* HashiCorp Vault for PAN encryption
7. *(coming)* Keycloak for real auth
8. *(coming)* Kafka events between services

## How to run (so far)

The Maven Wrapper is committed — you don't need Maven installed, only JDK 21.

```powershell
cd services
.\mvnw.cmd -pl discovery-service spring-boot:run
```

Then open http://localhost:8761 to see the Eureka dashboard.

Other services need Postgres / Redis / Kafka, which we'll wire up via Docker
Compose in the next phase.