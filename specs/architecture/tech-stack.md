# Tech Stack

**Status**: AGREED
**Last Updated**: 2026-04-16
**Depends On**: None

---

## 1. Overview

This spec defines the baseline technology choices for the archive platform.

The architectural default for this repo is:

- software is modeled with **DDD + DCB + CQRS**
- deployment is **cloud-native**
- infrastructure must stay **portable between AWS and Scaleway** where the archive capability allows it

The goal is not provider-neutrality at any cost. The goal is to keep the archive capability model stable while allowing provider-specific realization underneath it.

---

## 2. Hosting Model

The software is hosted as **containerized Kotlin services**.

This is the default deployment shape:

- `archive-api` runs as a stateless Ktor HTTP service in a container
- async processing runs in separate worker containers
- frontend assets are served as static web assets
- stateful concerns live in managed data/platform services, not inside the application containers

### Why This Hosting Model

- it keeps the software portable between AWS and Scaleway
- it fits DDD service boundaries and CQRS/DCB processing better than a provider-specific serverless-first shape
- it gives better dev/prod parity
- it avoids leaking cloud runtime assumptions into the software core

### Preferred Runtime Targets

The application should be designed once and then mapped onto provider runtimes.

Preferred order:

1. Kubernetes-compatible container hosting
2. Container service equivalents where operationally simpler

Provider mapping:

| Capability | AWS | Scaleway | Notes |
|-----------|-----|----------|-------|
| API service hosting | EKS or ECS/Fargate | Kapsule or Serverless Containers | Keep app image and runtime contract identical |
| Worker hosting | EKS or ECS/Fargate | Kapsule or Serverless Containers | Same worker image shape where possible |
| Static frontend hosting | S3 + CDN | Object Storage + CDN/static delivery | Exact delivery choice can differ by provider |

### Software Deployment Units

- `archive-api` — HTTP API, command/query entry points
- `archive-worker-ingest` — ingest orchestration, checksuming, extraction hooks, malware hooks
- `archive-worker-lifecycle` — retention, disposition, legal hold, restore-related jobs
- `archive-worker-projection` — optional projection/indexing/audit fan-out worker

---

## 3. Language and Core Frameworks

### Kotlin

**Version**: Kotlin 2.1+ stable

Kotlin is the primary language across backend, shared logic, and frontend.

Why:

- strong type system for value objects and domain modeling
- coroutine support for event-driven workflows
- good fit for explicit domain/application separation
- one language across the stack reduces translation overhead

### Backend Runtime

**Framework**: Ktor 3.x

Ktor is the backend default because it is lightweight, Kotlin-native, and does not force a heavy application model onto the domain.

Use:

- `ContentNegotiation`
- `StatusPages`
- `Authentication`
- `CallLogging`
- `RequestValidation` where helpful at the edge

Avoid pushing business rules into route plugins or framework annotations. Validation and policy decisions belong in the application/domain layers.

### Frontend

**Framework**: Compose Multiplatform targeting `wasmJs`

Frontend scope for this repo is primarily admin and operations UI.

Use:

- Compose Multiplatform
- Ktor Client
- `kotlinx.serialization`
- coroutines

The frontend should remain a consumer of software contracts, not a place where archive policy logic is reimplemented.

---

## 4. Software Architecture Style

### DDD

Use Domain-Driven Design to define:

- bounded parts
- ubiquitous language
- value objects
- policy concepts
- domain events
- explicit boundaries between archive behavior and infrastructure concerns

The domain model should describe archive behavior in provider-neutral terms such as:

- archive record
- retention policy
- legal hold
- retrieval request
- disposition decision
- audit evidence

### DCB

Use Dynamic Consistency Boundaries for decision-making on the write side.

That means:

- commands query the decision data they need
- decision models are built from prior events
- invariants are enforced from the queried decision state
- append conditions protect against races

This is preferred over forcing all archive rules into rigid aggregate boundaries.

### CQRS

Use CQRS across the software core:

- commands for write-side intent
- queries for read-side access
- projections for query-optimized models
- read models treated as disposable views

Write-side and read-side code should remain separate even when deployed inside the same service.

---

## 5. Module Boundaries

The codebase should be structured around explicit ports and adapters.

### Core Modules

- `packages/domain` — value objects, domain events, policy concepts, decision models
- `packages/application` — command handlers, query handlers, projections, use-case orchestration
- `packages/ports` — event store, object storage, search, messaging, identity, audit, metadata store contracts

### Adapter Modules

- `packages/adapters-api`
- `packages/adapters-postgres`
- `packages/adapters-opensearch`
- `packages/adapters-s3`
- `packages/adapters-messaging`
- `packages/adapters-auth`

### Application Assemblies

- `apps/archive-api`
- `apps/archive-worker-ingest`
- `apps/archive-worker-lifecycle`
- `apps/archive-worker-projection`
- `apps/archive-web`

Provider-specific SDKs must not appear in `domain` or `application`.

---

## 6. Event-Driven Application Model

The archive platform is event-driven by default.

### Write Path

```text
HTTP/API command
  -> command handler
  -> query decision events
  -> build decision model
  -> enforce invariants
  -> append domain event(s)
  -> trigger projection or async follow-up
```

### Read Path

```text
HTTP/API query
  -> query handler
  -> read model store
  -> response DTO/view
```

### Async Processing

Use events and queues for:

- ingest workflows
- extraction/malware hooks
- metadata indexing
- retention/disposition jobs
- restore processing
- audit fan-out and operational signals

Prefer synchronous flows only where they materially simplify the system without weakening auditability or operations.

---

## 7. Event Store and Metadata Persistence

### Event Store

**Decision**: PostgreSQL custom event store

PostgreSQL is the default event store implementation because it is portable, operationally familiar, and sufficient for DCB query patterns when backed by the right indexes.

Use:

- immutable event table
- event tag index table
- append-condition checks for optimistic concurrency

Why not a provider-native database for the core write model:

- it would make the portability goal weaker
- it would leak provider-specific data modeling into the software core
- the archive domain does not require that compromise at the baseline level

### Metadata and Read Models

**Decision**: PostgreSQL

Use PostgreSQL for:

- metadata system of record where relational integrity matters
- projection/read model tables
- operator/admin query views
- audit-supporting relational views where useful

Read models remain rebuildable from the event log where applicable.

---

## 8. Search and Object Storage

### Search

**Decision**: OpenSearch

Use OpenSearch for:

- metadata-first search
- filters and retrieval-oriented lookup
- search result shaping for admin workflows

Do not make full document content indexing the default assumption. The archive remains metadata-led unless a specific feature requires otherwise.

### Object Storage

**Decision**: S3-compatible object storage

Use S3-compatible APIs as the storage contract for archived payloads.

Provider mapping:

| Capability | AWS | Scaleway | Notes |
|-----------|-----|----------|-------|
| Archive object storage | S3 | Object Storage | Use S3-compatible behavior as the software-facing contract |
| Immutability | S3 Object Lock | Object Lock support | Infra spec must document exact provider behavior and caveats |
| Lifecycle tiering | S3 Lifecycle + Glacier tiers | Lifecycle Rules + provider tiers | Keep capability language stable, map tier details per provider |

Object storage behavior such as immutability, lifecycle, and retention enforcement belongs in IaC and infra specs, not in the domain code.

---

## 9. Messaging and Workflow

The messaging layer should remain provider-portable at the capability level.

Required capabilities:

- async queue boundary
- retry handling
- dead-letter routing
- event fan-out where needed
- workflow orchestration for longer-running archive processes

Provider mapping:

| Capability | AWS | Scaleway | Notes |
|-----------|-----|----------|-------|
| Queue | SQS | Queues | Default async boundary |
| Event fan-out | EventBridge | queue/topic pattern or equivalent | Use only where the slice benefits from fan-out |
| Workflow orchestration | Step Functions | app-managed orchestration or provider services | Keep orchestration semantics outside domain code |

The software should depend on messaging ports, not on SQS or provider-specific queue clients directly.

---

## 10. Identity, Security, and Secrets

### Identity

Use OIDC/OAuth2-based identity for admin and operator access.

The archive software should consume validated identity claims and roles, not own user credential handling.

### Authorization

Authorization remains part of the software policy layer:

- roles and scopes are interpreted in application/domain logic
- provider IAM protects workloads and infrastructure boundaries
- user-facing RBAC and policy checks remain explicit in the software

### Secrets and Keys

Use provider-native secret and key management through infra modules.

Provider mapping:

| Capability | AWS | Scaleway |
|-----------|-----|----------|
| Secret storage | Secrets Manager / Parameter Store | Secret Manager |
| Key management | KMS | Key Manager |

The software consumes secrets and key references through configuration contracts, never by embedding provider behavior in the core model.

---

## 11. Infrastructure as Code

**Decision**: OpenTofu

Use OpenTofu to define:

- object storage
- queues and workflow primitives
- IAM and policy wiring
- observability wiring
- search and database infrastructure
- environment composition

Recommended layout:

```text
infra/
  modules/
    archive-storage/
    archive-queues/
    archive-search/
    archive-postgres/
    archive-iam/
  live/
    aws/
      dev/
      prod/
    scaleway/
      dev/
      prod/
```

The capability model should stay stable even when provider modules differ internally.

---

## 12. Deployment Topology

### Baseline Topology

```text
Users / Operators
  -> CDN / ingress
  -> archive-web
  -> archive-api
  -> PostgreSQL / OpenSearch / Object Storage / Queueing / Secrets
  -> async workers
```

### Platform Shape

- stateless application containers
- managed databases and storage where practical
- queue-backed async workers
- provider-native monitoring and audit plumbing attached by infra

### What We Are Not Choosing as Baseline

- provider-locked backend runtime model
- Lambda-first or Functions-first architecture
- domain logic embedded in workflow definitions
- provider-native database as the core domain write model

Serverless components can still be used selectively in infra where they are the best fit, but they are not the primary software hosting model.

---

## 13. Build and Delivery

**Build System**: Gradle with Kotlin DSL and version catalog

Use:

- `libs.versions.toml`
- reproducible container builds
- CI pipelines that compile, test, and build images for services and workers

Suggested baseline libraries:

| Library | Purpose |
|--------|---------|
| Kotlinx Serialization | JSON/event serialization |
| Kotlin Coroutines | concurrency and async workflows |
| Ktor | HTTP runtime |
| Exposed or jOOQ | PostgreSQL access in adapters |
| OpenSearch client | search adapter |
| Testcontainers | integration tests |

For database access, prefer a Kotlin-friendly adapter approach. The final choice can be `Exposed` or `jOOQ`, but it must remain confined to adapter modules.

---

## 14. Testing Strategy

The stack should support the software/infra split already defined elsewhere.

### Software

- unit tests for value objects, decisions, and handlers
- contract tests for API shapes
- BDD/integration tests for archive flows
- UI tests for admin/operator journeys

### Infrastructure

- `fmt` / `validate`
- plan verification
- control verification for retention, immutability, IAM, encryption
- runtime verification for queues, storage, and observability wiring

---

## 15. Open Questions

- **Q-1**: Database adapter choice for PostgreSQL-backed ports — `Exposed` or `jOOQ`? — **Decision**: Pending
- **Q-2**: Default container runtime target per provider — Kapsule/EKS first, or container-service-first? — **Decision**: Pending
- **Q-3**: Projection execution model — in-process after append, async worker, or mixed by slice? — **Decision**: Pending
