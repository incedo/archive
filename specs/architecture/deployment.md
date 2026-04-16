# Deployment Architecture

**Status**: AGREED
**Last Updated**: 2026-04-16
**Depends On**: [tech-stack.md](/Users/kees/data/projects/archive/specs/architecture/tech-stack.md), [auth.md](/Users/kees/data/projects/archive/specs/architecture/auth.md)

---

## 1. Overview

This spec defines how the archive software is deployed.

The baseline deployment model is:

- containerized Kotlin services
- cloud-native runtime
- portable between AWS and Scaleway
- managed platform services where practical

The deployment architecture must preserve the software architecture choices already agreed:

- DDD in the software core
- DCB on the write side
- CQRS separation between write and read concerns
- provider-specific realization kept below the software boundary

---

## 2. Deployment Principles

### Container-First

The software is deployed as containers, not as provider-specific functions by default.

Why:

- one packaging model across providers
- fewer runtime assumptions in the application
- cleaner portability for API and worker services
- simpler parity across local, test, and production environments

### Stateless Services

Application services should be stateless.

State belongs in:

- PostgreSQL
- OpenSearch
- S3-compatible object storage
- queueing/workflow infrastructure
- secrets/key management systems

### Managed Services Around the App

Use managed data and platform services where they fit the archive problem.

This keeps operational burden lower while preserving a portable software core.

### Provider Differences Stay in Infra

The deployment model must allow AWS and Scaleway to use different managed services internally without changing the application’s business meaning.

---

## 3. Software Deployment Units

The baseline software runtime is split into explicit deployment units.

### `archive-api`

Responsibilities:

- HTTP API entry point
- command and query dispatch
- auth/authz enforcement at the edge and application boundary
- synchronous request handling

### `archive-worker-ingest`

Responsibilities:

- ingest-triggered async processing
- checksuming and validation hooks
- extraction hooks
- malware-scan integration hooks
- metadata enrichment handoff

### `archive-worker-lifecycle`

Responsibilities:

- retention jobs
- disposition preparation and execution
- legal hold-sensitive lifecycle behavior
- restore workflow steps

### `archive-worker-projection`

Responsibilities:

- projection updates
- metadata index updates
- audit/event fan-out
- operational denormalizations where needed

This worker can be merged into another deployment early on, but the architecture should treat it as separable.

### `archive-web`

Responsibilities:

- admin and operations web UI
- static asset delivery
- API consumption only

---

## 4. Baseline Topology

```text
Users / Operators
  -> CDN / ingress
  -> archive-web
  -> archive-api
  -> PostgreSQL
  -> OpenSearch
  -> Object Storage
  -> Queue / Workflow services
  -> archive-worker-ingest
  -> archive-worker-lifecycle
  -> archive-worker-projection
```

### Traffic Shape

- browser traffic reaches `archive-web`
- API traffic reaches `archive-api`
- async work is triggered through queue/event boundaries
- workers consume platform-managed async primitives

### State Boundaries

- application containers do not keep authoritative business state
- business truth lives in event and metadata persistence
- archived payloads live in object storage
- query views and search indexes are rebuildable or derivable where applicable

---

## 5. Runtime Targets

### Preferred Baseline

Design for **Kubernetes-compatible deployment first**.

This gives the cleanest portability across providers and keeps the deployment shape stable.

### Acceptable Provider Runtime Equivalents

| Capability | AWS | Scaleway | Notes |
|-----------|-----|----------|-------|
| API runtime | EKS or ECS/Fargate | Kapsule or Serverless Containers | Prefer the same container image and config contract |
| Worker runtime | EKS or ECS/Fargate | Kapsule or Serverless Containers | Workers stay independently deployable |
| Web runtime | container or static hosting | container or static hosting | Delivery can differ if the web artifact contract stays stable |

### What Is Not the Baseline

- Lambda-first deployment
- Functions-first deployment
- server-side Kotlin/WASM runtime
- provider-specific orchestration as the primary application host

These can be used selectively later, but they are not the reference model.

---

## 6. Provider Mapping

### AWS Mapping

- container hosting: EKS or ECS/Fargate
- object storage: S3
- immutability: S3 Object Lock
- queueing: SQS
- event routing: EventBridge where useful
- workflow orchestration: Step Functions where useful
- search: OpenSearch Service
- relational persistence: PostgreSQL-compatible managed database
- secrets: Secrets Manager / Parameter Store
- keys: KMS

### Scaleway Mapping

- container hosting: Kapsule or Serverless Containers
- object storage: Object Storage
- immutability: Object Lock support
- queueing: Queues
- workflow/orchestration: application-managed or provider services where appropriate
- search: OpenSearch
- relational persistence: Managed PostgreSQL
- secrets: Secret Manager
- keys: Key Manager

### Portability Rule

Every deployment slice should describe the capability first and the provider mapping second.

Examples:

- “immutable archive storage” first, `S3 Object Lock` or `Object Lock` second
- “async workflow boundary” first, `SQS` or `Queues` second
- “searchable metadata index” first, `OpenSearch Service` or `OpenSearch` second

---

## 7. Networking and Exposure

### External Entry Points

- web UI endpoint
- API endpoint
- identity provider endpoints where needed

### Internal Connectivity

- API can reach PostgreSQL, OpenSearch, object storage, secrets, and queue endpoints
- workers can reach the same managed services as required by their slice
- internal services should use private networking where the provider/runtime allows it

### Ingress

Use ingress/load-balancer routing to separate:

- web traffic
- API traffic
- identity/auth flows where applicable

TLS is required outside local development.

---

## 8. Configuration and Secrets

### Configuration Model

Application containers receive configuration through:

- environment variables
- mounted configuration where needed
- secret references

Configuration should cover:

- database connection info
- queue endpoints
- object storage bucket names
- search endpoints
- auth issuer/client settings
- feature flags where justified

### Secrets

Secrets must come from provider-native secret systems or approved secret injection mechanisms.

Secrets must not be:

- hardcoded in images
- committed in repo config
- modeled as domain concepts

---

## 9. Async Execution Model

Async boundaries are part of the deployment architecture, not an implementation afterthought.

Use queues/events for:

- ingest continuation
- retryable document-processing steps
- projection fan-out
- lifecycle execution
- restore and retrieval-related background work

Required characteristics:

- retry support
- dead-letter handling
- observability of stuck or failing work
- explicit operator visibility for exceptions

---

## 10. Observability and Operations

Every deployment environment must provide:

- structured application logs
- infrastructure logs where relevant
- metrics for API and worker health
- queue backlog/failure visibility
- traces or correlation capability where feasible
- audit-supporting operational evidence

Provider-native observability services may differ, but the operational capability must remain equivalent.

---

## 11. Local Development

Local development does not need to mirror production perfectly, but it must preserve the main deployment contracts.

Recommended local baseline:

- application services run as containers
- supporting infrastructure runs locally or in disposable dev environments
- local ingress/routing should approximate web/API separation

Possible local approaches:

1. Docker Compose for fast local iteration
2. Local Kubernetes for deployment-parity testing

Local Kubernetes is useful, but it is not the defining architecture. It is only one way to exercise the deployment model.

### Local Priorities

- quick developer feedback
- reproducible startup
- easy rebuild/redeploy of API and workers
- enough parity to catch config and networking issues

---

## 12. Deployment Layout Recommendation

Recommended repository shape:

```text
infra/
  modules/
    archive-api-runtime/
    archive-worker-runtime/
    archive-storage/
    archive-postgres/
    archive-search/
    archive-queues/
    archive-identity/
    archive-observability/
  live/
    aws/
      dev/
      prod/
    scaleway/
      dev/
      prod/

deploy/
  local/
    compose/
    kubernetes/
```

This separates:

- reusable IaC modules
- provider/live environment composition
- local developer deployment assets

---

## 13. Completion Criteria

- [ ] `archive-api`, `archive-web`, and the worker deployment units are explicitly modeled
- [ ] The baseline deployment shape is container-first and provider-portable
- [ ] AWS and Scaleway mappings are documented for each major runtime capability
- [ ] Stateful dependencies are externalized from application containers
- [ ] Async boundaries are explicitly represented in deployment architecture
- [ ] Configuration and secret handling are defined without embedding provider logic in the software core
- [ ] Observability and operational visibility requirements are defined
- [ ] Local development approach is documented as secondary to the production deployment model

---

## 14. Open Questions

- **Q-1**: Default production runtime on AWS — EKS first or ECS/Fargate first? — **Decision**: Pending
- **Q-2**: Default production runtime on Scaleway — Kapsule first or Serverless Containers first? — **Decision**: Pending
- **Q-3**: Should the first implementation loop keep projections in the API process or deploy `archive-worker-projection` from the start? — **Decision**: Pending
