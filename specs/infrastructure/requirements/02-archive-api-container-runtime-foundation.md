# Archive API Container Runtime Foundation

**Status**: DRAFT
**Last Updated**: 2026-04-16
**Provider**: Shared
**Slice Type**: Infrastructure
**Deployment Style**: Cloud-native, provider-portable
**Depends On**: [Feature 03 - Administration and Operations](/Users/kees/data/projects/archive/specs/features/03-administration-and-operations.md)
**Related Software Spec**: [Document Intake Registration](/Users/kees/data/projects/archive/specs/software/requirements/01-document-intake-registration.md)

---

## 1. Overview

This infra slice provides the first managed runtime foundation for `archive-api` as a containerized service.

It establishes the minimum platform resources needed to publish the application image, run it as a stateless service, inject runtime configuration, and expose a stable deployment contract for CI/CD.

Feature traceability:

- [Feature 03 - Administration and Operations](/Users/kees/data/projects/archive/specs/features/03-administration-and-operations.md): `3.4` operationeel inzicht, `3.8` runbooks and recovery, `3.9` CI/CD and release management, `3.10` runtime configuration and secret delivery, `3.11` deployment governance and promotion
- [Feature 01 - Ingest](/Users/kees/data/projects/archive/specs/features/01-ingest.md): provides the first managed runtime for the intake API capability

---

## 2. Scope

### In Scope
- container image registry foundation for `archive-api`
- managed container runtime for `archive-api`
- runtime logging baseline
- workload IAM boundary for ECS-style execution
- runtime secret/config contract for database-backed execution
- software-facing outputs for deployment automation

### Out of Scope
- full VPC/network provisioning
- DNS, TLS, and public ingress setup
- managed PostgreSQL provisioning
- autoscaling and advanced rollout policies
- worker service provisioning

Still intentionally deferred to later slices:

- load balancer and ingress composition
- observability dashboards and alarms
- worker deployment units
- queue and storage integrations beyond the current API runtime contract

---

## 3. Portability Constraints

Infrastructure slices should be cloud-native without becoming provider-locked by default.

- Prefer managed container runtimes on each provider.
- Keep the capability definition as `archive API container runtime` rather than provider product names.
- Encode provider differences in provider-specific modules or stack composition.
- Document unavoidable asymmetry explicitly.

---

## 4. Drivers

### Functional Driver
- `archive-api` must run as a managed stateless service and be reachable by the deployment pipeline

### Security Driver
- runtime secrets must not be baked into images
- workload execution must use least-privilege IAM roles

### Compliance Driver
- release identity and runtime wiring must be auditable

### Operations Driver
- operators must be able to identify the running service, image source, and log stream

### Cost Driver
- the first runtime slice should prefer a simple single-service baseline over production-grade multi-service complexity

---

## 5. Target Resources

| Resource | Purpose | Provider Primitive | Notes |
|---------|---------|--------------------|-------|
| `archive-api-image-registry` | immutable image storage | ECR / Container Registry | repo per deployment unit |
| `archive-api-runtime-cluster` | service scheduling boundary | ECS cluster / Kapsule or Serverless Containers | provider-specific runtime host |
| `archive-api-service` | long-running API workload | ECS service / container service | stateless desired-count baseline |
| `archive-api-task-runtime` | task definition and IAM boundary | ECS task definition + IAM | includes secret/config binding |
| `archive-api-logs` | runtime log sink | CloudWatch Logs / provider logging | baseline operational visibility |

---

## 6. Configuration Model

| Config Item | Type | Default | Source | Validation |
|------------|------|---------|--------|------------|
| `archive_api_image_uri` | string | placeholder bootstrap value | variable or deploy workflow | non-empty |
| `archive_api_port` | number | `8080` | module variable | valid TCP port |
| `archive_api_desired_count` | number | `1` | module variable | `>= 1` |
| `archive_api_subnet_ids` | list(string) | none | environment variable/stack input | non-empty |
| `archive_api_security_group_ids` | list(string) | none | environment variable/stack input | non-empty |
| `archive_api_jdbc_secret_arn` | string | none | environment variable/stack input | valid secret ARN |

### Environment Differences
- names, subnet IDs, and secret ARNs differ per environment
- image contract and container port stay invariant across environments

### Provider Mapping

| Capability | AWS | Scaleway | Portability Notes |
|-----------|-----|----------|-------------------|
| image registry | ECR repository | Scaleway Container Registry | immutable image identity remains portable |
| API container runtime | ECS/Fargate service | Serverless Containers or Kapsule workload | same image and runtime contract should be reused |
| runtime logs | CloudWatch log group | Cockpit logs | operators should see service-level runtime logs in both providers |
| runtime secret delivery | Secrets Manager or SSM | Secret Manager | secret values stay outside image and repo |

---

## 7. Provisioning Rules

- **IR-1**: The image registry must exist before automated publishing is enabled.
- **IR-2**: The ECS service must be backed by a task definition that consumes runtime secrets, not embedded secret values.
- **IR-3**: Runtime execution and task roles must be least privilege for the current service behavior.
- **IR-4**: Service naming, task family naming, and registry naming must be output by IaC, not manually reconstructed.
- **IR-5**: Provider-specific runtime implementation must preserve the same application image and runtime configuration contract.

---

## 8. Module and State Layout

### OpenTofu/Terraform Modules
- `infra/modules/aws/archive_api_service` — AWS runtime module for ECR + ECS/Fargate + IAM + logging
- `infra/live/aws/dev/archive-api` — composition root for the first AWS dev runtime slice

### Inputs
- project name
- environment name
- AWS region
- image URI bootstrap value
- subnet IDs
- security group IDs
- JDBC secret ARN

### Outputs
- ECR repository URL
- ECS cluster name
- ECS service name
- ECS task definition family
- ECS container name

### State Boundaries
- ECR, ECS cluster, task definition, service, and immediate IAM/logging belong in the same first runtime stack
- networking, database, and ingress remain separate for now

---

## 9. Security and Compliance Controls

| Control Area | Required Control | Enforcement |
|-------------|------------------|-------------|
| Identity | least-privilege execution/task roles | IAM roles and policy attachments |
| Secret delivery | JDBC settings injected from secret store | ECS task definition `secrets` block |
| Image provenance | image identity is explicit and mutable only through deployment | task definition image reference + CI/CD contract |
| Auditability | runtime changes visible through plan/apply and ECS revisioning | IaC outputs + ECS task revisions |

---

## 10. Operational Behavior

### Deployment
- provision the runtime foundation before enabling automated `main -> dev` deploys
- prefer forward-fix over manual console edits

### Monitoring
- cluster, service, task family, and log group are visible in outputs
- ECS service stability determines deployment success

### Failure Modes
- missing subnet or security group inputs prevent service provisioning
- missing secret ARN prevents valid runtime configuration
- invalid image URI causes task launch failures

### Recovery
- the runtime foundation can be reprovisioned from IaC
- the service can be redeployed with a known image URI without rebuilding the application

---

## 11. Application Integration Points

| Consumer | Integration | Contract |
|---------|-------------|----------|
| `archive-api` | ECS runtime env + secrets | `ARCHIVE_PORT`, JDBC secret fields |
| GitHub Actions deploy workflow | IaC outputs / configured names | cluster, service, task family, container name |
| operators | ECS + CloudWatch + outputs | runtime identity and basic logs are discoverable |

These integration points primarily support:

- [Feature 03 - Administration and Operations](/Users/kees/data/projects/archive/specs/features/03-administration-and-operations.md)
- [Document Intake Registration](/Users/kees/data/projects/archive/specs/software/requirements/01-document-intake-registration.md)

---

## 12. Verification Criteria

### 12a. Static Verification
- [ ] formatting and validation pass
- [ ] module inputs and outputs are documented
- [ ] provider mapping is documented

### 12b. Plan Verification
- [ ] plan shows intended creation of ECR, ECS, IAM, and logging resources only
- [ ] security-sensitive changes are visible in the plan
- [ ] no destructive changes appear unintentionally

### 12c. Control Verification
- [ ] runtime secret delivery is enforced through secret references
- [ ] task and execution roles are least privilege for the current slice
- [ ] log retention and runtime log sink are configured

### 12d. Portability Verification
- [ ] the slice is described in provider-neutral terms first
- [ ] AWS and Scaleway mappings are both documented
- [ ] provider-specific caveats are noted explicitly

### 12e. Runtime Verification
- [ ] the provisioned ECR repository is usable by CI/CD
- [ ] the ECS service can consume the configured image URI
- [ ] configuration values needed by deployment automation are exported cleanly

### 12f. Definition of Done
- [ ] all verification criteria in 12a-12e pass
- [ ] resource naming and environment conventions are consistent
- [ ] the software-facing integration contract is documented
- [ ] cost-impact note is captured

---

## 13. Evidence to Collect

- plan output showing ECR, ECS, IAM, and logging resources
- output values for repository URL, cluster, service, and task family
- proof that JDBC configuration is delivered by secret references
- cost-impact note

---

## 14. Open Questions

- **Q-1**: Should the first ECS service include a load balancer target group in this slice, or remain a network-only service until the ingress slice is defined? — **Decision**: Deferred

