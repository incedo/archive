# [Infrastructure Slice Name]

**Status**: DRAFT
**Last Updated**: YYYY-MM-DD
**Provider**: AWS | Scaleway | Shared
**Slice Type**: Infrastructure
**Deployment Style**: Cloud-native, provider-portable
**Depends On**: [list of other spec files, or "None"]
**Related Software Spec**: [path or "None"]

---

## 1. Overview

[Describe the infrastructure slice in 2-3 sentences. Explain which archive capability it enables, which platform primitives it relies on, and why it exists.]

---

## 2. Scope

### In Scope
- [Resource or platform capability]
- [Resource or platform capability]

### Out of Scope
- [Explicitly excluded concern]
- [Explicitly excluded concern]

---

## 3. Portability Constraints

Infrastructure slices should be cloud-native without becoming provider-locked by default.

- Prefer managed cloud primitives that fit the archive problem well on each provider.
- Keep the **capability model** portable between AWS and Scaleway even when the underlying service names differ.
- Encode provider differences in provider-specific modules, stacks, or adapters, not in the business meaning of the slice.
- Define the desired capability in neutral terms first: immutable object storage, async workflow boundary, searchable metadata store, audit trail, key management.
- Document any unavoidable provider asymmetry explicitly.

---

## 4. Drivers

### Functional Driver
- [Which application behavior depends on this infrastructure]

### Security Driver
- [Least privilege, encryption, network boundary, key control]

### Compliance Driver
- [Immutability, retention, legal hold, evidence, auditability]

### Operations Driver
- [Observability, recoverability, retry behavior, operator workflow]

### Cost Driver
- [Storage tiering, request costs, compute, logs, retrieval]

---

## 5. Target Resources

| Resource | Purpose | Provider Primitive | Notes |
|---------|---------|--------------------|-------|
| [archive bucket] | Immutable document storage | [S3 / Object Storage] | [Object Lock, versioning, lifecycle] |
| [event queue] | Async workflow boundary | [SQS / Queues] | [DLQ, retry semantics] |

---

## 6. Configuration Model

| Config Item | Type | Default | Source | Validation |
|------------|------|---------|--------|------------|
| `archive_retention_years` | number | [value] | variable | `> 0` |
| `kms_key_alias` | string | [value] | variable | non-empty |

### Environment Differences
- [What may differ between dev, test, prod]
- [What must remain invariant across environments]

### Provider Mapping

| Capability | AWS | Scaleway | Portability Notes |
|-----------|-----|----------|-------------------|
| [Immutable archive storage] | [service] | [service] | [behavioral equivalence and caveats] |
| [Async workflow boundary] | [service] | [service] | [behavioral equivalence and caveats] |

---

## 7. Provisioning Rules

- **IR-1**: [Resource must exist before dependent resource is applied]
- **IR-2**: [Immutable storage settings cannot be disabled after activation]
- **IR-3**: [Only approved workloads may write/read/manage]
- **IR-4**: [Lifecycle, retention, and encryption settings are codified only through IaC]
- **IR-5**: [Provider-specific implementation preserves the same archive capability boundary across AWS and Scaleway]

---

## 8. Module and State Layout

### OpenTofu/Terraform Modules
- `modules/[name]` — [responsibility]
- `live/[provider]/[env]/[stack]` — [composition root]

### Inputs
- [Required input]
- [Optional input]

### Outputs
- [Output consumed by application or another stack]
- [Output consumed by operators]

### State Boundaries
- [What belongs in this state file/stack]
- [What is intentionally in another stack]

---

## 9. Security and Compliance Controls

| Control Area | Required Control | Enforcement |
|-------------|------------------|-------------|
| Identity | [Least privilege role/policy] | [IAM / policy document] |
| Encryption | [At rest / in transit requirement] | [KMS / SSE / TLS] |
| Immutability | [Object lock / retention guard] | [Bucket setting / policy] |
| Auditability | [Trail/log/evidence requirement] | [CloudTrail / Cockpit / logs] |

---

## 10. Operational Behavior

### Deployment
- [Apply order or dependency]
- [Rollback or forward-fix expectation]

### Monitoring
- [Metrics]
- [Alerts]
- [Dashboards]

### Failure Modes
- [Failure case and expected signal]
- [Failure case and expected operator action]

### Recovery
- [Restore, replay, rebuild, or replacement strategy]

---

## 11. Application Integration Points

| Consumer | Integration | Contract |
|---------|-------------|----------|
| [backend service] | [env var / secret / queue / bucket / endpoint] | [what the app expects] |
| [operations/admin] | [dashboard / audit trail / output] | [what operators expect] |

---

## 12. Verification Criteria

### 12a. Static Verification
- [ ] Formatting and validation pass (`fmt`, `validate`)
- [ ] Linting/policy checks pass
- [ ] Module inputs and outputs are documented

### 12b. Plan Verification
- [ ] Plan shows only intended resource changes
- [ ] Destructive changes are either absent or explicitly approved
- [ ] Security-sensitive changes are visible in plan output

### 12c. Control Verification
- [ ] Encryption settings are enforced
- [ ] Retention/immutability settings are enforced
- [ ] IAM/policy scope is least privilege for intended workloads
- [ ] Logging/audit controls are enabled

### 12d. Portability Verification
- [ ] The slice describes the capability in provider-neutral terms
- [ ] AWS and Scaleway mappings are both documented, or the missing side is explicitly noted
- [ ] Provider-specific deviations and limits are recorded

### 12e. Runtime Verification
- [ ] Provisioned resources are reachable/usable by intended workloads
- [ ] Failure routing, retry, or DLQ behavior is observable
- [ ] Dashboards/alerts expose the main operational states

### 12f. Definition of Done
- [ ] All verification criteria in 12a-12e pass
- [ ] Resource naming, tags, and environment conventions are consistent
- [ ] Application integration points are documented and consumable
- [ ] Capability mapping remains portable between AWS and Scaleway
- [ ] Cost-impact note is captured
- [ ] Remaining manual steps, if any, are explicitly documented

---

## 13. Evidence to Collect

- [Plan output or summary]
- [Policy diff or control proof]
- [Provider mapping note or portability decision]
- [Screenshot or command output proving monitoring/audit wiring]
- [Cost-impact note]

---

## 14. Open Questions

- **Q-1**: [Question] — **Decision**: Pending
