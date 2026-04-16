# Module Structure — Archive Software

**Status**: AGREED
**Last Updated**: 2026-04-16
**Depends On**: [tech-stack.md](/Users/kees/data/projects/archive/specs/architecture/tech-stack.md)

---

## 1. Overview

This spec defines the archive-oriented module structure for the software stack.

It assumes:

- DDD for domain boundaries
- DCB for write-side decision logic
- CQRS for write/read separation
- ports and adapters for infrastructure boundaries
- provider-neutral software concepts

The structure must support:

- document intake
- immutable archive registration
- metadata management
- auditability
- retention and legal-hold evolution
- admin and operations UI

---

## 2. Top-Level Shape

```text
packages/
  domain/
  application/
  ports/
  adapters-api/
  adapters-compat/
  adapters-postgres/
  adapters-opensearch/
  adapters-s3/
  adapters-messaging/
  adapters-auth/
  frontend-common/
  design-system/

apps/
  archive-api/
  archive-worker-ingest/
  archive-worker-lifecycle/
  archive-worker-projection/
  archive-web/
```

### Dependency Direction

```text
apps
  -> adapters
  -> ports
  -> application
  -> domain
```

Rules:

- `domain` depends on nothing provider-specific
- `application` depends on `domain`
- `ports` define infrastructure-facing contracts used by `application`
- adapters implement `ports`
- apps compose adapters and expose runtime entry points

---

## 3. Core Software Modules

### `packages/domain`

Purpose:

- archive domain model
- value objects
- domain events
- decision models
- domain policies and invariants

Example areas:

- `document`
- `ingest`
- `metadata`
- `retention`
- `legalhold`
- `audit`

### `packages/application`

Purpose:

- command handlers
- query handlers
- projections
- application services that orchestrate domain decisions

This is where DCB command flow lives:

- query events
- build decision state
- decide
- append events
- trigger projection or async continuation

### `packages/ports`

Purpose:

- event store interfaces
- read model store interfaces
- object storage interfaces
- checksum service interface
- messaging interfaces
- identity/auth interfaces
- audit/evidence interfaces

Ports are the contract line between software and infra.

---

## 4. Adapter Modules

### `packages/adapters-api`

Purpose:

- HTTP routes/controllers
- request/response DTOs
- mapping between transport DTOs and application commands/queries

Example runtime consumers:

- `apps/archive-api`

### `packages/adapters-compat`

Purpose:

- Alfresco-like compatibility DTOs
- request/response transformation logic
- migration-friendly adapter layer for external producers

This module translates compatibility requests into generic archive commands.

### `packages/adapters-postgres`

Purpose:

- PostgreSQL event store implementation
- PostgreSQL read model implementation
- relational metadata/query persistence

### `packages/adapters-opensearch`

Purpose:

- metadata search indexing
- search query execution for operator/admin use cases

### `packages/adapters-s3`

Purpose:

- object storage adapter behind S3-compatible contract
- document payload handoff and retrieval integration

### `packages/adapters-messaging`

Purpose:

- queue publish/consume adapters
- retry and dead-letter integration
- event fan-out integration

### `packages/adapters-auth`

Purpose:

- OIDC/OAuth2 integration
- token validation
- identity claim mapping

---

## 5. Frontend Modules

### `packages/design-system`

Purpose:

- reusable design tokens and UI primitives
- archive admin and operations visual language

### `packages/frontend-common`

Purpose:

- shared screens
- UI state holders
- route/view models
- API client integration

### `apps/archive-web`

Purpose:

- web entry point
- browser-specific wiring
- static asset build target

The frontend should remain an archive administration and operations client, not a second policy engine.

---

## 6. Runtime Applications

### `apps/archive-api`

Contains:

- API runtime bootstrap
- dependency wiring
- synchronous command/query entry points

### `apps/archive-worker-ingest`

Contains:

- queue consumers for ingest-related async steps
- processing flow assembly for checksum, extraction, scan hooks, and follow-up events

### `apps/archive-worker-lifecycle`

Contains:

- retention and disposition job runners
- legal-hold aware lifecycle orchestration

### `apps/archive-worker-projection`

Contains:

- projection subscriptions
- read model updaters
- search indexing updaters

This worker may start as an in-process capability early on, but the module boundary should exist from the start.

---

## 7. Suggested Package Layout

### `packages/domain`

```text
packages/domain/src/commonMain/kotlin/archive/domain/
  document/
    model/
    event/
    decision/
    validation/
  ingest/
    model/
    event/
    decision/
    validation/
  metadata/
    model/
    event/
    decision/
  retention/
    model/
    event/
    decision/
  audit/
    model/
    event/
```

### `packages/application`

```text
packages/application/src/commonMain/kotlin/archive/application/
  command/
    document/
    ingest/
  query/
    document/
    metadata/
  projection/
    document/
    ingest/
    audit/
  readmodel/
```

### `packages/ports`

```text
packages/ports/src/commonMain/kotlin/archive/ports/
  eventstore/
  readmodel/
  objectstorage/
  checksum/
  messaging/
  identity/
  audit/
```

---

## 8. First Slice Mapping

For the first software slice, `Document Intake Registration`, the minimum modules involved are:

- `packages/domain`
- `packages/application`
- `packages/ports`
- `packages/adapters-api`
- `packages/adapters-postgres`
- `apps/archive-api`
- optionally `packages/frontend-common` and `apps/archive-web` for the first operator view

Not required for the very first slice:

- `packages/adapters-opensearch`
- `apps/archive-worker-lifecycle`
- advanced search UI

Optional depending on the checksum decision:

- `apps/archive-worker-ingest`
- `packages/adapters-messaging`

---

## 9. Architectural Rules

- Domain events are first-class Kotlin types and the source of truth
- Application services must not depend on AWS or Scaleway SDK types
- Object storage and queue semantics are accessed only through ports
- Search, storage, and messaging adapters must remain swappable
- UI modules consume query models and API contracts, not domain internals directly where avoidable
- Infra-specific naming or policy constructs must not appear in domain or application modules

---

## 10. Open Questions

- **Q-1**: Should `packages/domain`, `packages/application`, and `packages/ports` start as separate modules immediately, or collapse into one shared module for the first loop? — **Decision**: Pending
- **Q-2**: Should `archive-worker-projection` exist as a deployable app from the start, or be deferred until after the first ingest slice? — **Decision**: Pending
