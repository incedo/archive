# Document Intake Registration

**Status**: DRAFT
**Last Updated**: 2026-04-16
**Slice Type**: Software
**Architecture Style**: DDD + DCB + CQRS
**Depends On**: [Feature 01 - Ingest](/Users/kees/data/projects/archive/specs/features/01-ingest.md)
**Related Infra Spec**: [Intake Archive Storage Foundation](/Users/kees/data/projects/archive/specs/infrastructure/requirements/01-intake-archive-storage-foundation.md)

---

## 1. Overview

This slice establishes the first software capability of the archive: accepting a document intake request and registering it as a controlled archive record.

It is the smallest useful software requirement because it creates the business identity of the document, records initial metadata, computes checksum state, and makes the intake result visible to later software and infrastructure slices.

Feature traceability:

- [Feature 01 - Ingest](/Users/kees/data/projects/archive/specs/features/01-ingest.md): `1.1` document upload, `1.2` basisvalidatie, `1.3` ingest statusregistratie, `1.4` integriteitsvaststelling
- [Feature 03 - Administration and Operations](/Users/kees/data/projects/archive/specs/features/03-administration-and-operations.md): `3.4` operationeel inzicht, for first intake status visibility
- [Feature 07 - Audit Trail](/Users/kees/data/projects/archive/specs/features/07-audit-trail.md): `7.1` audit event model and `7.2` kritieke acties loggen, for intake registration events

---

## 2. Scope

### In Scope
- receiving a document intake command
- receiving a compatibility-shaped intake request for migration/drop-in scenarios
- receiving document uploads as multipart form data
- validating required input metadata and file presence
- assigning a unique `DocumentId`
- recording initial ingest status
- recording checksum/hash result in software state
- exposing the intake result through a query model
- emitting audit-relevant domain events

### Out of Scope
- immutable storage enforcement
- malware scanning execution
- advanced classification
- metadata extraction from content
- retention execution
- legal hold behavior

Still intentionally deferred to later feature slices:

- [Feature 01 - Ingest](/Users/kees/data/projects/archive/specs/features/01-ingest.md): `1.5` malware scanning, `1.6` classificatie, `1.7` bronintegraties, `1.8` verrijkte metadata-extractie, `1.9` retention policy binding, `1.10` AI-assisted ingestverrijking
- [Feature 02 - Immutable Archiving](/Users/kees/data/projects/archive/specs/features/02-immutable-archiving.md): storage enforcement and immutability controls

---

## 3. Architectural Constraints

This slice is domain-first by default.

- Use **DDD** for the archive record, ingest request, metadata, and ingest status concepts.
- Use **DCB** so ingest acceptance and state transitions are based on event-derived decision state.
- Use **CQRS** so intake commands and intake status queries remain separate.
- Keep file storage and provider runtime details behind ports.
- Do not model AWS or Scaleway concepts in domain events or decision logic.
- Keep Alfresco-compatibility concerns in a transformation adapter, not in the domain model.

---

## 4. Domain Concepts

### Core Concepts
- `DocumentId`
- `IngestRequest`
- `ArchiveRecord`
- `IngestStatus`
- `Checksum`
- `DocumentMetadata`
- `DocumentClassificationHint`

### Value Objects

| Value Object | Type | Validation | Notes |
|-------------|------|------------|-------|
| `DocumentId` | `@JvmInline value class` | non-blank UUID | archive record identity |
| `Checksum` | value object | supported algorithm + non-blank hash | integrity reference |
| `DocumentTypeHint` | enum/string wrapper | optional but normalized | classification hint only |

---

## 5. Events and Commands

### Domain Events

| Event | Tags | Payload | Trigger |
|-------|------|---------|---------|
| `DocumentIntakeRequested` | `["document:{id}"]` | intake request metadata | intake accepted |
| `DocumentChecksumRecorded` | `["document:{id}"]` | checksum algorithm + hash | checksum computed |
| `DocumentIngestStatusUpdated` | `["document:{id}"]` | status transition | intake state changes |

### Commands

| Command | Fields | Required Decision Tags | Decision Model | Business Rules |
|---------|--------|------------------------|----------------|----------------|
| `RegisterDocumentIntake` | file reference, metadata, type hint | `["document:{id}"]` or none for create | `DocumentIntakeDecisionModel` | BR-1, BR-2, BR-3 |

### Transformation Inputs

The software exposes two intake shapes:

- a generic archive intake request
- an Alfresco-like compatibility request that is transformed into the generic intake command

The transformed command path is the same after mapping.

For the first implementation slice, both intake shapes should use multipart upload transport so document producers do not need to base64-encode files into JSON payloads.

---

## 6. Decision and Read Models

### Decision Models

| Decision Model | Queried Tags | State Built | Invariants Enforced |
|---------------|-------------|-------------|---------------------|
| `DocumentIntakeDecisionModel` | `["document:{id}"]` | existing state, current ingest status | BR-1 through BR-4 |

### Decision Model Behavior

```text
RegisterDocumentIntake arrives
  -> validate request fields
  -> create new DocumentId for accepted intake
  -> compute checksum or receive checksum result from a software port
  -> emit intake and status events
  -> expose resulting state via projection
```

### Read Models

| Read Model | Source Events | Key Fields | Purpose |
|-----------|---------------|------------|---------|
| `DocumentIngestView` | intake/status/checksum events | documentId, status, checksum, metadata summary | operator intake status and detail |

---

## 7. Business Rules

- **BR-1**: Intake must include the required baseline metadata fields — **Enforced by**: Validation
- **BR-2**: Intake must include a file or file reference that the software can process — **Enforced by**: Validation
- **BR-3**: A newly accepted intake receives exactly one `DocumentId` — **Enforced by**: Decision Model
- **BR-4**: Checksum information must be attached before the intake can be considered successfully registered — **Enforced by**: Decision Model / Application Flow

---

## 8. API and Integration Surface

### Command Endpoints

#### POST /api/v1/documents/intake
- **Command**: `RegisterDocumentIntake`
- **Transport**: `multipart/form-data`
- **Expected parts**:
  - `file`
  - `documentTypeHint` (optional)
  - `sourceSystem`
  - `businessKey`
- **Success Response**: `202 Accepted` or `201 Created` with `documentId` and initial status
- **Error Responses**: 400, 401, 403, 422

#### POST /alfresco/api/-default-/public/alfresco/versions/1/nodes/-root-/children
- **Purpose**: compatibility intake endpoint for upstream producers that currently speak an Alfresco-like API
- **Transport**: `multipart/form-data`
- **Transformation**: request is mapped into `RegisterDocumentIntake`
- **Success Response**: response is shaped to be compatibility-friendly while still reflecting the generic archive registration result
- **Error Responses**: 400, 401, 403, 422

### Query Endpoints

#### GET /api/v1/documents/{id}/ingest
- **Query**: `GetDocumentIngestStatus`
- **Response**: ingest status, checksum state, metadata summary

### Outbound Integrations
- checksum calculation port
- event store port
- read model store port
- optional storage handoff port for later infra-linked slices

### Transformation Layer
- compatibility request DTOs
- compatibility-to-generic mapper
- compatibility response mapper where needed for drop-in replacement behavior

Non-drift rule:

- the Alfresco-compat endpoint must not implement a separate ingest flow
- it must map onto the same generic registration path as `/api/v1/documents/intake`

Related feature expectations behind these ports:

- [Feature 02 - Immutable Archiving](/Users/kees/data/projects/archive/specs/features/02-immutable-archiving.md): later storage handoff and immutable archive registration
- [Feature 04 - Metadata Management](/Users/kees/data/projects/archive/specs/features/04-metadata-management.md): later metadata system-of-record enrichment

---

## 9. UI and Operator Views

### Intake Result View
- **Route**: `/documents/intake/{id}`
- **Users**: admin, operator
- **Layout**: intake summary with status, checksum, and metadata summary
- **Interactions**:
  - inspect intake result
  - inspect validation or processing failure state
- **State**: document intake state and metadata summary

---

## 10. Non-Functional Expectations

### Security
- intake endpoint requires authenticated and authorized caller
- metadata returned by the query view is limited to what the caller may see

### Auditability
- the system records that the intake was requested
- the system records the resulting ingest status and checksum provenance

### Operations
- failures in intake registration are visible as explicit status or error outcomes
- later async follow-up work can identify the registered document by `DocumentId`

### Cost Note
- this slice has limited direct cloud-cost impact beyond standard API, storage handoff, and event persistence operations

---

## 11. Completion Criteria

> These checkboxes are for software completion only.
> Infrastructure provisioning, object storage immutability, queue wiring, and runtime alarms belong in an infra spec.

### 11a. Unit Tests
- [ ] `DocumentId` and `Checksum` validate correctly
- [ ] intake validation rejects missing required metadata
- [ ] intake validation rejects missing file/file reference
- [ ] decision model enforces the intake registration invariants
- [ ] command handler emits the expected intake, checksum, and status events
- [ ] projection builds `DocumentIngestView` correctly

### 11b. Contract Tests
- [ ] intake endpoint request/response shape matches contract
- [ ] intake error response shape matches contract
- [ ] ingest status query response shape matches contract
- [ ] compatibility intake endpoint maps correctly onto the generic intake flow
- [ ] both intake endpoints accept multipart uploads

### 11c. BDD Tests
- [ ] scenario: register valid document intake
- [ ] scenario: reject intake with missing required metadata
- [ ] scenario: reject intake with missing file reference
- [ ] scenario: retrieve ingest status after successful registration

### 11d. UI Tests
- [ ] operator can submit intake and see resulting status
- [ ] operator can open the ingest detail view by `DocumentId`
- [ ] validation failure is visible to the operator

### 11e. Definition of Done
- [ ] all software verification criteria in 11a-11d pass
- [ ] code compiles for affected targets
- [ ] domain model stays provider-neutral
- [ ] related infrastructure dependencies are documented for later slices

---

## 12. Open Questions

- **Q-1**: Should checksum calculation happen inline in the API process for the first slice, or behind an async worker handoff? — **Decision**: Pending
- **Q-2**: How close should the compatibility response shape stay to Alfresco for the first migration slice? — **Decision**: Pending
