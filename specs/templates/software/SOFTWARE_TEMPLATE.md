# [Software Slice Name]

**Status**: DRAFT
**Last Updated**: YYYY-MM-DD
**Slice Type**: Software
**Architecture Style**: DDD + DCB + CQRS
**Depends On**: [list of other spec files, or "None"]
**Related Infra Spec**: [path or "None"]

---

## 1. Overview

[Describe the software slice in 2-3 sentences. Explain which archive capability it delivers, who uses it, and which behavior becomes possible because of it.]

---

## 2. Scope

### In Scope
- [Application behavior]
- [Application behavior]

### Out of Scope
- [Explicit exclusion]
- [Explicit exclusion]

---

## 3. Architectural Constraints

This repo treats software slices as domain-first by default.

- Use **DDD** to define bounded parts, ubiquitous language, aggregates, value objects, and domain boundaries.
- Use **DCB** so decisions are made from event-derived decision state rather than mutable shared state.
- Use **CQRS** to keep write-side intent and invariants separate from read-side projections and query models.
- Do not let cloud-provider details leak into domain concepts, domain events, or decision models.
- Keep provider-specific resource names, SDK choices, and deployment mechanics behind ports/adapters or infra contracts.

---

## 4. Domain Concepts

### Core Concepts
- [Document, archive record, policy, retrieval request, legal hold, etc.]
- [Only include concepts this slice actually changes]

### Value Objects

| Value Object | Type | Validation | Notes |
|-------------|------|------------|-------|
| [DocumentId] | `@JvmInline value class` | Non-blank UUID | Typed identifier |
| | | | |

---

## 5. Events and Commands

### Domain Events

> Events are the source of truth for software state changes. Each event is `@Serializable` and carries queryable tags where needed.

| Event | Tags | Payload | Trigger |
|-------|------|---------|---------|
| [DocumentRegistered] | `["document:{id}"]` | [snapshot] | [Create or intake command] |
| [MetadataUpdated] | `["document:{id}"]` | [changed fields] | [Update command] |

### Commands

> Commands express intent to change state and should reference the decision data they need.

| Command | Fields | Required Decision Tags | Decision Model | Business Rules |
|---------|--------|------------------------|----------------|----------------|
| [RegisterDocument] | [fields] | `["document:{id}"]` | [DocumentDecisionModel] | BR-1, BR-2 |
| [UpdateMetadata] | [fields] | `["document:{id}"]` | [DocumentDecisionModel] | BR-3 |

---

## 6. Decision and Read Models

### Decision Models

| Decision Model | Queried Tags | State Built | Invariants Enforced |
|---------------|-------------|-------------|---------------------|
| [DocumentDecisionModel] | `["document:{id}"]` | [current state] | BR-1 through BR-N |

### Decision Model Behavior

```text
Command arrives
  -> Query decision data by tags
  -> Fold events into current decision state
  -> Check business invariants
  -> If valid: append new event(s)
  -> If invalid: return domain or validation error
```

### Read Models

| Read Model | Source Events | Key Fields | Purpose |
|-----------|---------------|------------|---------|
| [DocumentView] | [relevant events] | [denormalized fields] | [API/UI query use] |

---

## 7. Business Rules

- **BR-1**: [Rule description] — **Enforced by**: Validation / Decision Model
- **BR-2**: [Rule description] — **Enforced by**: Validation / Decision Model
- **BR-3**: [Rule description] — **Enforced by**: Decision Model / Policy Check

---

## 8. API and Integration Surface

### Command Endpoints

#### POST /api/v1/[resource]
- **Command**: [RegisterDocument]
- **Request Body**:
  ```json
  {
  }
  ```
- **Success Response**: [201/202 and response shape]
- **Error Responses**: 400, 401, 403, 409, 422 as applicable

#### PUT /api/v1/[resource]/{id}
- **Command**: [UpdateMetadata]
- **Request Body**: [partial/full update shape]
- **Success Response**: [200]
- **Error Responses**: 400, 404, 409 as applicable

### Query Endpoints

#### GET /api/v1/[resource]
- **Query**: [ListDocuments]
- **Parameters**: `page`, `size`, `sort`, `filter`
- **Response**: [list shape]

#### GET /api/v1/[resource]/{id}
- **Query**: [GetDocument]
- **Response**: [detail shape]

### Outbound Integrations
- [Queue, storage, search, or audit integration the software depends on]
- [Expected contract with infra-provisioned resources]

---

## 9. UI and Operator Views

### [View Name]
- **Route**: `[route]`
- **Users**: [admin, operator, service user]
- **Layout**: [what the user sees]
- **Interactions**:
  - [Action 1]
  - [Action 2]
- **State**: [state handled here]

---

## 10. Non-Functional Expectations

### Security
- [Authorization expectation]
- [Sensitive data handling]

### Auditability
- [What must be recorded]
- [What must be explainable or traceable]

### Operations
- [Signals, failure states, retries, dashboards]

### Cost Note
- [Any meaningful impact on storage, search, compute, logs, retrieval]

---

## 11. Completion Criteria

> These checkboxes are for software completion only.
> Infrastructure provisioning, IAM, object lock, lifecycle, alarms, and other platform controls belong in the linked infra spec.

### 11a. Unit Tests
- [ ] Value objects validate correctly
- [ ] Events serialize/deserialize correctly
- [ ] Decision models enforce each relevant business rule
- [ ] Validation rejects invalid command fields
- [ ] Command handlers append the correct events
- [ ] Query handlers return the correct read models
- [ ] Projections update read models on each relevant event

### 11b. Contract Tests
- [ ] Command endpoint request/response shapes match contract
- [ ] Query endpoint response shapes match contract
- [ ] Error responses are consistent and correct

### 11c. BDD Tests
- [ ] Main success scenario passes
- [ ] Main validation/error scenario passes
- [ ] Authorization or policy scenario passes
- [ ] Cross-component scenario passes where relevant

### 11d. UI Tests
- [ ] Main user flow works end-to-end
- [ ] Search/filter/detail/update flow works where relevant
- [ ] Failure or permission behavior is visible to the user where relevant

### 11e. Definition of Done
- [ ] All software verification criteria in 11a-11d pass
- [ ] Code compiles for affected targets
- [ ] Domain/application code does not embed infrastructure provisioning logic
- [ ] Domain model remains provider-neutral while adapters consume infra-provided contracts
- [ ] Related infra dependencies are documented
- [ ] No regressions appear in previously satisfied software specs

---

## 12. Open Questions

- **Q-1**: [Question] — **Decision**: Pending
