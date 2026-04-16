# Ralph Wiggum Loop Configuration

**Last Updated**: 2026-04-16

This document defines how the Ralph Wiggum autonomous loop operates against the spec framework.

The current loop configuration is primarily for software implementation specs that use [SOFTWARE_TEMPLATE.md](/Users/kees/data/projects/archive/specs/templates/software/SOFTWARE_TEMPLATE.md).

Infrastructure-as-code work should use [INFRA_TEMPLATE.md](/Users/kees/data/projects/archive/specs/templates/infrastructure/INFRA_TEMPLATE.md) and follow the separate infra rules in section 7 below.

Default architectural stance for this repo:

- software is modeled with DDD + DCB + CQRS
- infrastructure is cloud-native
- deployment choices should remain portable between AWS and Scaleway where the archive capability allows it

Default execution order for this repo:

1. software slice first
2. shared/provider-neutral infra slice second
3. AWS realization after that
4. Scaleway realization after that

This means the loop should not start with provider-specific infrastructure unless a software contract for that slice already exists.

Specification-first workflow for this repo:

1. change the relevant spec first
2. commit the spec change
3. only then start implementation work against that updated spec

This applies to software and infrastructure work alike.

---

## 1. Execution Model

The loop follows this cycle for each spec:

```
┌─────────────────────────────────────────────────┐
│                                                   │
│  1. Pick spec (status: IN_PROGRESS)               │
│           │                                       │
│           ▼                                       │
│  2. Read Completion Criteria (Section 6)          │
│           │                                       │
│           ▼                                       │
│  3. Identify unchecked criteria (- [ ])           │
│           │                                       │
│           ▼                                       │
│  4. Implement / improve code                      │
│           │                                       │
│           ▼                                       │
│  5. Run tests + compile all targets               │
│           │                                       │
│           ▼                                       │
│  6. Commit with spec reference                    │
│           │                                       │
│           ▼                                       │
│  7. Review git diff against spec                  │
│           │                                       │
│           ▼                                       │
│  8. Check: all criteria satisfied?                │
│           │                                       │
│      ┌────┴────┐                                  │
│      No       Yes                                 │
│      │         │                                  │
│      │         ▼                                  │
│      │    9. Mark spec SATISFIED                  │
│      │    10. Pick next spec → step 1             │
│      │                                            │
│      ▼                                            │
│  Back to step 3 (next iteration)                  │
│                                                   │
└─────────────────────────────────────────────────┘
```

### Spec Selection Priority
1. First, continue any spec already `IN_PROGRESS`
2. Then, promote the next `AGREED` spec (by dependency order from MASTER.md)
3. Never work on `DRAFT` specs — they need human agreement first

### Software-First Priority

When both software and infrastructure specs exist for the same capability:

1. implement the software requirement first
2. implement the shared/provider-neutral infra requirement second
3. implement provider-specific infra realization after the shared infra requirement

Use provider-specific infra work only after the software slice has made the required runtime contract explicit.

### Spec-First Priority

Before code or infrastructure is changed:

1. update the relevant spec
2. commit the spec update
3. treat that commit as the implementation baseline

Do not start implementation from unstated assumptions when the relevant spec has not yet been updated.

---

## 2. Commit Convention

Every commit message references the spec and specific criteria it addresses:

```
[spec:<path>] <action>: <description>

Examples:
[spec:domain/contacts] Implement BR-3: email format validation
[spec:domain/contacts] Fix: POST endpoint returning 500 instead of 400 on invalid input
[spec:domain/companies] Add: company list view with pagination
[spec:architecture/module-structure] Setup: KMP shared module with commonMain targets
```

### Commit Rules
- **One logical change per commit** — don't bundle unrelated fixes
- **Reference the spec path** relative to `/specs/` (e.g., `domain/contacts`)
- **Use action prefixes**: `Implement`, `Fix`, `Add`, `Refactor`, `Test`
- **Describe the specific criteria** addressed (BR number, endpoint, view name)

---

## 3. Iteration Budget

| Scope | Max Iterations | Escalation |
|-------|---------------|------------|
| Single business rule | 5 | If a BR fails after 5 attempts, flag it and move on |
| Single API endpoint | 8 | Include compilation + test iterations |
| Full entity spec | 30 | Sum of all criteria for that spec |
| Architecture/setup spec | 15 | Project skeleton + build configuration |

### Escalation Protocol
When the iteration budget is exhausted:
1. Mark the stalled criteria with `- [ ] ⚠️ STALLED: [reason]`
2. Add an entry to the spec's Open Questions section
3. Continue with remaining unchecked criteria
4. Report the stall to the human for review

---

## 4. Convergence Signals

The loop tracks these signals to assess whether it's making progress:

### Positive Convergence (keep going)
- Tests that previously failed now pass
- Compilation errors decrease between iterations
- New Completion Criteria checkboxes get checked
- Code coverage increases

### Negative Convergence / Stall Detection
- **Same test fails for 3+ consecutive iterations** → Stall. Needs human input.
- **Compilation error count is not decreasing** → Likely an architectural issue.
- **Loop is adding/reverting the same code** → Oscillation. Stop and escalate.
- **No new criteria satisfied in 5 iterations** → Reassess approach.

### Stall Response
When a stall is detected:
1. Stop the current approach
2. Review the last 3 commits via `git log` and `git diff`
3. If a different approach is viable, try it (counts toward iteration budget)
4. If not, escalate with a clear description of what's failing and why

---

## 5. Verification Commands

The loop runs tests in pyramid order — fast unit tests first, slow E2E tests last.

```bash
# 1. Compile all targets
./gradlew build

# 2. Unit tests (shared module — fast, run every iteration)
./gradlew :shared:allTests

# 3. Unit tests (backend)
./gradlew :backend:test --tests '*Unit*'

# 4. Contract tests (API shape verification)
./gradlew :backend:test --tests '*Contract*'

# 5. BDD tests (Cucumber/Gherkin scenarios)
./gradlew :backend:test --tests '*Cucumber*'

# 6. Frontend WASM compilation check
./gradlew :frontend:wasmJsBrowserDistribution

# 7. UI/E2E tests (Playwright — only after all above pass)
cd e2e && npx playwright test

# 8. Full check (compile + unit + contract + BDD)
./gradlew check
```

### Test Execution Strategy per Iteration
| Iteration Focus | Tests to Run |
|----------------|-------------|
| Domain model / value objects | Unit tests only (`shared:allTests`) |
| Command/query handlers | Unit tests (`shared:allTests`) |
| API endpoints | Unit + Contract + BDD (`backend:test`) |
| UI views | Compile check + UI tests (`playwright test`) |
| Cross-entity / integration | All layers |

### Test Naming Convention

Tests map to spec criteria across all four layers:

**Unit Tests** (kotlin.test / JUnit5):
| Spec Criteria | Test Class | Test Method |
|--------------|------------|-------------|
| BR-1 of Contacts (invariant) | `ContactDecisionModelTest` | `testBR1_[description]` |
| BR-2 of Contacts (validation) | `ContactValidationTest` | `testBR2_[description]` |
| CreateContact command handler | `ContactCommandHandlerTest` | `testCreateContact_emitsEvent` |
| ContactCreated projection | `ContactProjectionTest` | `testContactCreated_updatesView` |

**Contract Tests** (Pact / OpenAPI):
| Spec Criteria | Test Class | Test Method |
|--------------|------------|-------------|
| POST /contacts → 201 shape | `ContactContractTest` | `testCreateContact_responseShape` |
| GET /contacts → 200 shape | `ContactContractTest` | `testListContacts_paginationShape` |
| Error response shape | `ErrorContractTest` | `testValidationError_shape` |

**BDD Tests** (Cucumber):
| Spec Criteria | Feature File | Scenario |
|--------------|-------------|----------|
| Create contact flow | `contacts.feature` | `Create a new contact with all fields` |
| Duplicate email | `contacts.feature` | `Reject contact with duplicate email` |
| Full pipeline | `pipeline.feature` | `Full pipeline lifecycle — prospect to close` |

**UI Tests** (Playwright):
| Spec Criteria | Test File | Test |
|--------------|----------|------|
| Create contact via form | `contacts.spec.ts` | `test('create contact flow')` |
| Deal kanban drag | `deals.spec.ts` | `test('drag deal to next stage')` |
| OIDC login | `auth.spec.ts` | `test('login via OIDC')` |

---

## 6. Spec-to-Code Mapping (CQRS + DCB)

The loop generates code in predictable locations based on spec sections:

### Domain Layer (shared module)
| Spec Section | CQRS/DCB Concept | Code Location |
|-------------|-------------------|---------------|
| Value Objects | Typed IDs, Email, Money | `shared/.../domain/model/{ValueObject}.kt` |
| Domain Events | Events (source of truth) | `shared/.../domain/event/{entity}/{EventName}.kt` |
| Commands | Command data classes | `shared/.../domain/command/{entity}/{CommandName}.kt` |
| Queries | Query data classes | `shared/.../domain/query/{entity}/{QueryName}.kt` |
| Business Rules (invariants) | Decision Models | `shared/.../domain/decision/{Entity}DecisionModel.kt` |
| Business Rules (field validation) | Validation functions | `shared/.../domain/validation/{Entity}Validation.kt` |
| Ports | EventStore, ReadModelStore | `shared/.../domain/port/{PortName}.kt` |

### Application Layer (shared module)
| Spec Section | CQRS/DCB Concept | Code Location |
|-------------|-------------------|---------------|
| Command handling | Command Handler | `shared/.../application/command/{Entity}CommandHandler.kt` |
| Query handling | Query Handler | `shared/.../application/query/{Entity}QueryHandler.kt` |
| Read Model shape | View data class | `shared/.../application/readmodel/{Entity}View.kt` |
| Projection logic | Event → Read Model | `shared/.../application/projection/{Entity}Projection.kt` |

### Backend Adapters
| Spec Section | CQRS/DCB Concept | Code Location |
|-------------|-------------------|---------------|
| API Endpoints (POST/PUT/DELETE) | Inbound Adapter (commands) | `backend/.../adapter/inbound/rest/{Entity}Controller.kt` |
| API Endpoints (GET) | Inbound Adapter (queries) | `backend/.../adapter/inbound/rest/{Entity}Controller.kt` |
| Event persistence | Outbound Adapter | `backend/.../adapter/outbound/eventstore/{Impl}EventStore.kt` |
| Read model persistence | Outbound Adapter | `backend/.../adapter/outbound/readmodel/table/{Entity}ReadTable.kt` |

### Frontend Adapters
| Spec Section | Code Location |
|-------------|---------------|
| UI List View | `frontend/.../adapter/inbound/ui/screens/{entity}/{Entity}ListScreen.kt` |
| UI Detail View | `frontend/.../adapter/inbound/ui/screens/{entity}/{Entity}DetailScreen.kt` |
| UI Form | `frontend/.../adapter/inbound/ui/screens/{entity}/{Entity}FormScreen.kt` |
| API calls | `frontend/.../adapter/outbound/api/{Entity}Api.kt` |

### Tests (four layers — see architecture/testing.md)
| Test Layer | Spec Section | Code Location |
|-----------|-------------|---------------|
| **Unit** | Decision models (BRs) | `shared/commonTest/.../domain/decision/{Entity}DecisionModelTest.kt` |
| **Unit** | Validation (field rules) | `shared/commonTest/.../domain/validation/{Entity}ValidationTest.kt` |
| **Unit** | Command handlers | `shared/commonTest/.../application/command/{Entity}CommandHandlerTest.kt` |
| **Unit** | Query handlers | `shared/commonTest/.../application/query/{Entity}QueryHandlerTest.kt` |
| **Unit** | Projections | `shared/commonTest/.../application/projection/{Entity}ProjectionTest.kt` |
| **Unit** | Value objects | `shared/commonTest/.../domain/model/{ValueObject}Test.kt` |
| **Contract** | API shapes | `backend/test/.../contract/{Entity}ContractTest.kt` |
| **Contract** | Error shapes | `backend/test/.../contract/ErrorContractTest.kt` |
| **BDD** | Business scenarios | `specs/features/{entity}.feature` |
| **BDD** | Step definitions | `backend/test/.../bdd/steps/{Entity}Steps.kt` |
| **BDD** | Cross-entity flows | `specs/features/pipeline.feature` |
| **UI/E2E** | Main user flows | `e2e/tests/{entity}.spec.ts` |
| **UI/E2E** | Auth flows | `e2e/tests/auth.spec.ts` |

---

## 7. Infrastructure-as-Code Loop

Infrastructure work is not treated the same way as software entity or API work.

Use a separate infra spec when the slice is primarily about:

- buckets, queues, workflows, IAM, keys, policies
- observability plumbing
- network or environment composition
- retention, immutability, lifecycle, or compliance controls enforced by cloud primitives

### Infra Selection Rule

Pick an infra spec when the main risk is platform correctness rather than application behavior.

If a slice changes both software and infrastructure:

- keep the software acceptance criteria in the software spec
- keep the platform controls and provisioning criteria in the infra spec
- link both specs to the same feature or story where needed

### Infra Execution Model

The loop for infra specs follows this cycle:

1. Pick infra spec (status: `IN_PROGRESS`)
2. Read section 12 in [INFRA_TEMPLATE.md](/Users/kees/data/projects/archive/specs/templates/infrastructure/INFRA_TEMPLATE.md)
3. Identify unchecked verification criteria
4. Implement or adjust modules/stacks/policies
5. Run formatting, validation, linting, and plan verification
6. Review security, compliance, and cost impact
7. Commit with infra spec reference
8. Check whether all verification criteria are satisfied
9. Mark spec `SATISFIED` when complete

### Infra Verification Expectations

Infra work should prove:

- desired resources are created or updated intentionally
- destructive drift is absent or explicitly reviewed
- security and compliance controls are codified
- application integration points are documented
- operational signals and recovery expectations are visible

### Infra Commit Convention

Use the same commit shape as software specs, but describe the infra control or resource boundary explicitly.

Examples:

```text
[spec:infrastructure/archive-bucket] Implement IR-2: enforce object lock retention defaults
[spec:infrastructure/ingest-queue] Add: DLQ wiring and retry alarms
[spec:infrastructure/iam-backend] Fix: narrow metadata writer permissions
```

---

## 8. Working with Multiple Specs

### One Spec at a Time
The loop works on **one spec at a time** to avoid oscillation between specs. It fully satisfies (or stalls on) the current spec before moving to the next.

### Dependency Awareness
Before starting a spec, the loop checks its `Depends On` field:
- All dependencies must be `SATISFIED` or `IN_PROGRESS` with their shared models available
- If a dependency is `DRAFT` or `AGREED`, the dependent spec cannot start

### Regression Checks
After satisfying a spec, the loop runs the full test suite to verify no regressions in previously `SATISFIED` specs. If regressions are found:
1. Fix the regression (counts toward the current spec's iteration budget)
2. If the fix conflicts with the current spec's requirements, escalate to human
