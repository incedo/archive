# Software Components

**Status**: AGREED
**Last Updated**: 2026-04-16
**Depends On**: [tech-stack.md](/Users/kees/data/projects/archive/specs/architecture/tech-stack.md), [module-structure.md](/Users/kees/data/projects/archive/specs/architecture/module-structure.md)

---

## 1. Overview

This spec refines the software side of the archive platform into concrete component boundaries.

These components are software responsibilities only. They do not define cloud resources or infrastructure realization.

The architectural assumptions are fixed:

- domain-first modeling with DDD
- write-side decisions with DCB
- CQRS separation between write and read models
- provider-neutral business language

The software component boundaries in this document primarily support:

- [Feature 01 - Ingest](/Users/kees/data/projects/archive/specs/features/01-ingest.md)
- [Feature 03 - Administration and Operations](/Users/kees/data/projects/archive/specs/features/03-administration-and-operations.md)
- [Feature 04 - Metadata Management](/Users/kees/data/projects/archive/specs/features/04-metadata-management.md)
- [Feature 07 - Audit Trail](/Users/kees/data/projects/archive/specs/features/07-audit-trail.md)

---

## 2. Core Software Components

### 2.1 Intake API

Responsibilities:

- receive document intake requests
- validate request shape and required metadata
- create the initial command for ingest
- return the initial archive/document identifier and state

Does not own:

- object storage lifecycle rules
- malware engine runtime
- bucket-level immutability enforcement

### 2.1a Compatibility Transformation Layer

Responsibilities:

- accept intake requests shaped as close as practical to Alfresco-facing client expectations
- transform compatibility payloads into the generic archive intake command
- keep compatibility concerns out of the core domain model

Rules:

- internal domain naming stays generic
- compatibility DTOs and mappers live in adapter code only
- this layer exists to ease migration and drop-in replacement for upstream document producers

### 2.2 Ingest Application Service

Responsibilities:

- orchestrate the write-side ingest flow
- build decision state needed for ingest acceptance
- emit initial domain events for document receipt and validation result
- hand off follow-up async work where needed

### 2.3 Document Domain Model

Responsibilities:

- define archive record concepts
- define document identifiers, status, checksum concepts, metadata references
- enforce ingest invariants and state transitions

### 2.4 Metadata Service

Responsibilities:

- manage baseline metadata attached to the archive record
- distinguish required, optional, derived, and later-enriched metadata
- expose metadata query views

### 2.5 Policy Binding Service

Responsibilities:

- connect document classification and metadata to policy inputs
- expose policy-relevant state to later retention/legal-hold logic

This does not need to fully execute retention logic in the first slice.

### 2.6 Audit Event Service

Responsibilities:

- produce auditable software events for critical business actions
- expose provenance for intake decisions and status changes

### 2.7 Query and Projection Service

Responsibilities:

- build operator-facing read models
- provide list/detail/status views
- expose ingest status and metadata state for follow-up components

### 2.8 Admin and Operations UI

Responsibilities:

- show intake result and current status
- show baseline metadata
- show validation or exception outcome where applicable

---

## 3. First Implementation Boundary

The first software slice should stay small and unblock later features.

Recommended first slice:

- accept a document intake request
- validate basic metadata and input shape
- register the document as received
- compute and store checksum information in software state
- expose the resulting intake status through a query view
- emit an audit-relevant domain event

This slice intentionally does not require:

- full classification
- full metadata extraction
- retention execution
- legal hold behavior
- advanced search

Feature traceability for this first boundary:

- [Feature 01 - Ingest](/Users/kees/data/projects/archive/specs/features/01-ingest.md): `1.1` document upload, `1.2` basisvalidatie, `1.3` ingest statusregistratie, `1.4` integriteitsvaststelling
- [Feature 03 - Administration and Operations](/Users/kees/data/projects/archive/specs/features/03-administration-and-operations.md): `3.4` operationeel inzicht, in minimale vorm
- [Feature 07 - Audit Trail](/Users/kees/data/projects/archive/specs/features/07-audit-trail.md): `7.1` audit event model, `7.2` kritieke acties loggen, in minimale vorm

Delivery pattern for external producers:

- external systems may use a compatibility-shaped intake endpoint
- the compatibility layer transforms that payload into the generic archive intake command
- the generic intake flow remains the single software path for registration

---

## 4. Primary Domain Concepts

- `DocumentId`
- `ArchiveRecord`
- `IngestRequest`
- `IngestStatus`
- `Checksum`
- `DocumentMetadata`
- `DocumentClassificationHint`
- `AuditEvent`

These concepts should remain valid regardless of whether the runtime is AWS or Scaleway.

---

## 5. Software Dependency Shape

The software dependency direction should be:

```text
archive-web / archive-api
  -> application services
  -> domain model + decision models
  -> ports
  -> adapters
```

The software core may depend on:

- domain value objects
- domain events
- command/query models
- policy concepts
- port contracts

The software core must not depend on:

- AWS SDK types
- Scaleway SDK types
- OpenTofu concepts
- bucket policy documents
- queue resource definitions

---

## 6. First Requirement Candidate

The first implementable software requirement is:

`Document Intake Registration`

Why this first:

- it is the start of the archive lifecycle
- it unblocks immutable storage, audit, metadata, and retention follow-up work
- it is small enough for an initial software slice
- it exercises the software architecture without forcing full platform breadth immediately
