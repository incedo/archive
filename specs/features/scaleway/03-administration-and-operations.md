# Scaleway Stories - Feature 03 Administration and Operations

Feature source: [03-administration-and-operations.md](/Users/kees/data/projects/archive/features/03-administration-and-operations.md)

## Scaleway components

- admin API on Serverless Containers
- optional admin UI
- Cockpit
- Audit Trail

## Stories

- `SCW-03-01` Policy administration for retention, classification and lifecycle rules.
- `SCW-03-02` Role and scope administration aligned to archive governance.
- `SCW-03-03` Metadata rule administration per document type.
- `SCW-03-04` Operational dashboards for ingest, failures, jobs and cold-storage restores.
- `SCW-03-05` Admin console for governance and operational tasks.
- `SCW-03-06` Exception handling and controlled reprocessing flows.
- `SCW-03-07` AI configuration management for confidence thresholds and review gates.
- `SCW-03-08` Runbooks and recovery support integrated with Scaleway observability.
- `SCW-03-09` GitHub Actions based CI validates Gradle build, tests and container image creation for `archive-api` and later worker images.
- `SCW-03-10` Immutable container images are published to Scaleway Container Registry and versioned per commit SHA and release identifier.
- `SCW-03-11` Deployment pipeline promotes the same approved image digest across `dev`, `test` and `prod` without rebuilding.
- `SCW-03-12` Scaleway deployment targets are defined for container-first runtime delivery, with Serverless Containers as first operational baseline and Kapsule as later optional evolution.
- `SCW-03-13` Runtime configuration and secrets are delivered through Scaleway-native mechanisms without embedding secret values in repository or workflow code.
- `SCW-03-14` Deployment status, rollout health, failed releases and rollback actions are visible through Cockpit and related operational dashboards.
- `SCW-03-15` CI/CD uses scoped deployment authentication for Scaleway infrastructure and workload rollout without long-lived broad credentials.
- `SCW-03-16` Runbooks define rollback, re-deploy, failed migration handling and environment recovery for Scaleway-hosted archive services.

## Acceptance focus

- governance configuration is not hidden in code
- operators can see backlog, exceptions and restore behavior
- admin actions are auditable
- release flow is reproducible from source to deployed runtime
- the same release artifact can be promoted between Scaleway environments without rebuild
- deployment and rollback activity is operationally visible and auditable

## Recommended delivery order

1. `SCW-03-09`: CI baseline for Gradle build, test and container validation
2. `SCW-03-10`: image publication and immutable versioning
3. `SCW-03-13`: runtime configuration and secret delivery contract
4. `SCW-03-12`: first Scaleway runtime target baseline for container delivery
5. `SCW-03-11`: environment promotion across `dev`, `test` and `prod`
6. `SCW-03-14`: rollout and deployment visibility in operations tooling
7. `SCW-03-15`: scoped deployment authentication for CI/CD
8. `SCW-03-16`: rollback and recovery runbooks

Execution note:

- use Serverless Containers as the first deployable Scaleway baseline unless later runtime constraints require Kapsule
- keep the release artifact identical across Scaleway environments; only config, secrets and infra bindings should vary
- Scaleway resource provisioning and runtime naming must come from IaC; manual console setup is bootstrap-only at most and not the target operating model
