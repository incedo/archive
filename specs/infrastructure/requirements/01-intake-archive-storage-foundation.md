# Intake Archive Storage Foundation

**Status**: DRAFT
**Last Updated**: 2026-04-16
**Provider**: Shared
**Slice Type**: Infrastructure
**Deployment Style**: Cloud-native, provider-portable
**Depends On**: [Feature 02 - Immutable Archiving](/Users/kees/data/projects/archive/specs/features/02-immutable-archiving.md)
**Related Software Spec**: [Document Intake Registration](/Users/kees/data/projects/archive/specs/software/requirements/01-document-intake-registration.md)

---

## 1. Overview

This infra slice provides the minimum storage and configuration foundation needed for the first document intake software slice to hand off or persist document payloads safely.

It does not attempt to complete the full immutable archive platform. It establishes the first archive storage boundary, encryption baseline, and software-facing integration contract in a provider-portable way.

Feature traceability:

- [Feature 02 - Immutable Archiving](/Users/kees/data/projects/archive/specs/features/02-immutable-archiving.md): `2.1` object storage archivering, `2.3` encryptie at rest
- [Feature 01 - Ingest](/Users/kees/data/projects/archive/specs/features/01-ingest.md): supports the storage handoff needed after initial intake registration
- [Feature 03 - Administration and Operations](/Users/kees/data/projects/archive/specs/features/03-administration-and-operations.md): minimal operator visibility into the storage target and runtime wiring

---

## 2. Scope

### In Scope
- archive-capable object storage foundation for ingested payloads
- encryption baseline for stored payloads
- software-facing bucket/container naming and access contract
- minimal IAM/access boundary for the intake software runtime
- basic evidence that the storage target is provisioned and usable

### Out of Scope
- full retention policy automation
- lifecycle tier transitions
- restore/retrieval from cold storage
- full audit/compliance reporting
- queue and worker runtime wiring beyond what storage integration needs

Still intentionally deferred to later feature slices:

- [Feature 02 - Immutable Archiving](/Users/kees/data/projects/archive/specs/features/02-immutable-archiving.md): `2.2` immutable opslag enforcement, `2.4` integriteitscontrole op opslag, `2.5` lifecycle naar cold storage, `2.7` retrieval uit cold storage, `2.8` replicatie en recovery, `2.9` bewijsbare opslagstatus
- [Feature 07 - Audit Trail](/Users/kees/data/projects/archive/specs/features/07-audit-trail.md): full independent audit storage and evidence export

---

## 3. Portability Constraints

Infrastructure slices should be cloud-native without becoming provider-locked by default.

- Prefer managed object storage on each provider.
- Keep the capability definition as `archive payload storage` rather than provider service names.
- Encode provider differences inside provider-specific modules or stack composition.
- Document any asymmetry in immutability or lifecycle capability explicitly.

---

## 4. Drivers

### Functional Driver
- the software must have a stable storage target for archive payload handoff during intake

### Security Driver
- only the intended workload may write intake payloads to the archive storage target
- encryption at rest must be enabled

### Compliance Driver
- the initial storage foundation must not block later immutability and retention enforcement

### Operations Driver
- operators must be able to identify the storage target and validate that the intake runtime can use it

### Cost Driver
- the first slice should use a simple hot storage baseline and defer tiering complexity

---

## 5. Target Resources

| Resource | Purpose | Provider Primitive | Notes |
|---------|---------|--------------------|-------|
| `archive-intake-storage` | initial archive payload target | S3 / Object Storage | baseline archive bucket/container |
| `archive-intake-key` | encryption key or managed encryption reference | KMS / Key Manager | if provider-managed key reference is used, document it |
| `archive-intake-access` | workload access boundary | IAM / policy binding | limited to required write/read actions |

---

## 6. Configuration Model

| Config Item | Type | Default | Source | Validation |
|------------|------|---------|--------|------------|
| `archive_intake_bucket_name` | string | none | module output | non-empty |
| `archive_intake_region` | string | env-specific | variable | valid provider region |
| `archive_intake_encryption_mode` | string | provider-managed | variable | allowed values only |

### Environment Differences
- bucket/container names differ per environment
- production may require stronger guardrails than local/dev

### Provider Mapping

| Capability | AWS | Scaleway | Portability Notes |
|-----------|-----|----------|-------------------|
| archive payload storage | S3 bucket | Object Storage bucket | software consumes only bucket name + S3-compatible contract |
| at-rest encryption | S3 encryption + KMS where chosen | Object Storage encryption + Key Manager where chosen | exact encryption controls may differ, capability remains the same |
| workload access boundary | IAM role/policy | IAM policy | express as least-privilege runtime access |

---

## 7. Provisioning Rules

- **IR-1**: The storage target must exist before the intake runtime is configured to use it.
- **IR-2**: Encryption at rest must be enabled or explicitly provider-managed by policy.
- **IR-3**: Only the intended intake workload identity may write payloads to the storage target.
- **IR-4**: The storage naming and access contract must be produced as IaC outputs, not hardcoded in the application.
- **IR-5**: The baseline storage configuration must remain compatible with later immutability and retention enforcement.

---

## 8. Module and State Layout

### OpenTofu/Terraform Modules
- `modules/archive-storage` — archive storage capability
- `modules/archive-iam` — workload access policies
- `live/[provider]/[env]/archive-foundation` — composition root for the first intake storage slice

### Inputs
- environment name
- region
- naming prefix
- encryption mode
- workload identity reference

### Outputs
- archive intake bucket/container name
- encryption reference or mode
- workload access reference

### State Boundaries
- storage and its immediate access boundary belong in the same first-slice stack
- broader queueing, observability, and lifecycle stacks can remain separate

---

## 9. Security and Compliance Controls

| Control Area | Required Control | Enforcement |
|-------------|------------------|-------------|
| Identity | least-privilege runtime write/read access | IAM policy/binding |
| Encryption | at-rest encryption enabled | bucket/storage config + key integration |
| Immutability readiness | configuration does not preclude later object lock/retention controls | module design review + provider mapping |
| Auditability | storage access and change events can be traced at the platform level | provider audit/logging integration |

---

## 10. Operational Behavior

### Deployment
- provision storage foundation before deploying the software slice that depends on it
- prefer forward-fix over manual out-of-band bucket mutations

### Monitoring
- bucket/container existence and configuration are visible in plan/apply outputs
- access failures from the runtime are diagnosable

### Failure Modes
- missing bucket/container prevents intake payload handoff
- missing permissions cause explicit runtime write failures

### Recovery
- the storage foundation can be reprovisioned from IaC
- the application contract can be restored from module outputs and environment wiring

---

## 11. Application Integration Points

| Consumer | Integration | Contract |
|---------|-------------|----------|
| `archive-api` | env var / config for storage target | bucket/container name and write permissions |
| `archive-worker-ingest` | optional shared storage contract | same naming and access contract if checksum/storage handoff becomes async |
| operators | infra outputs / cloud console / dashboards | storage target and access wiring are identifiable |

These integration points primarily support:

- [Document Intake Registration](/Users/kees/data/projects/archive/specs/software/requirements/01-document-intake-registration.md)
- [Feature 01 - Ingest](/Users/kees/data/projects/archive/specs/features/01-ingest.md)
- [Feature 02 - Immutable Archiving](/Users/kees/data/projects/archive/specs/features/02-immutable-archiving.md)

---

## 12. Verification Criteria

### 12a. Static Verification
- [ ] formatting and validation pass
- [ ] module inputs and outputs are documented
- [ ] provider mapping is documented

### 12b. Plan Verification
- [ ] plan shows intended creation of archive storage resources only
- [ ] security-sensitive changes are visible in the plan
- [ ] no destructive changes appear unintentionally

### 12c. Control Verification
- [ ] encryption settings are enforced
- [ ] runtime access is least privilege for the intake slice
- [ ] the configuration remains compatible with later immutability controls

### 12d. Portability Verification
- [ ] the slice is described in provider-neutral terms first
- [ ] AWS and Scaleway mappings are both documented
- [ ] provider-specific caveats are noted explicitly

### 12e. Runtime Verification
- [ ] the provisioned storage target is usable by the intended workload
- [ ] configuration values needed by the software slice are exported cleanly
- [ ] storage access failures are diagnosable

### 12f. Definition of Done
- [ ] all verification criteria in 12a-12e pass
- [ ] resource naming and environment conventions are consistent
- [ ] the software-facing integration contract is documented
- [ ] cost-impact note is captured

---

## 13. Evidence to Collect

- plan output showing storage and access resources
- policy diff or access summary
- provider mapping note
- proof that the software-facing storage output is available
- cost-impact note

---

## 14. Open Questions

- **Q-1**: Should the first slice enable full object lock immediately, or stop at object-lock-compatible storage foundation and add enforcement in the next infra slice? — **Decision**: Pending
