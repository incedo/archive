# AWS Stories - Feature 03 Administration and Operations

Feature source: [03-administration-and-operations.md](/Users/kees/data/projects/archive/features/03-administration-and-operations.md)

## AWS components

- API Gateway
- Lambda
- admin UI
- CloudWatch
- CloudTrail

## Stories

- `AWS-03-01` Policy administration for retention, classification and lifecycle rules.
- `AWS-03-02` Role and scope administration aligned to archive governance.
- `AWS-03-03` Metadata rule administration per document type.
- `AWS-03-04` Operational dashboards for ingest, failures, jobs and cold-storage restores.
- `AWS-03-05` Admin console for governance and operational tasks.
- `AWS-03-06` Exception handling and controlled reprocessing flows.
- `AWS-03-07` AI configuration management for confidence thresholds and review gates.
- `AWS-03-08` Runbooks and recovery support integrated with AWS observability.
- `AWS-03-09` GitHub Actions based CI validates Gradle build, tests and container image creation for `archive-api` and later worker images.
- `AWS-03-10` Immutable container images are published to AWS-compatible registry targets and versioned per commit SHA and release identifier.
- `AWS-03-11` Deployment pipeline promotes the same approved image digest across `dev`, `test` and `prod` without rebuilding.
- `AWS-03-12` AWS deployment targets are defined for container-first runtime delivery, with ECS/Fargate as first operational baseline and EKS as later optional evolution.
- `AWS-03-13` Runtime configuration and secrets are delivered through AWS-native mechanisms without embedding secret values in repository or workflow code.
- `AWS-03-14` Deployment status, rollout health, failed releases and rollback actions are visible in CloudWatch and linked operational dashboards.
- `AWS-03-15` CI/CD uses short-lived AWS authentication from the delivery platform to deploy infrastructure and workloads without long-lived static credentials.
- `AWS-03-16` Runbooks define rollback, re-deploy, failed migration handling and environment recovery for AWS-hosted archive services.

## Acceptance focus

- governance configuration is not hidden in code
- operators can see backlog, exceptions and restore behavior
- admin actions are auditable
- release flow is reproducible from source to deployed runtime
- the same release artifact can be promoted between AWS environments without rebuild
- deployment and rollback activity is operationally visible and auditable

## Recommended delivery order

1. `AWS-03-09`: CI baseline for Gradle build, test and container validation
2. `AWS-03-10`: image publication and immutable versioning
3. `AWS-03-13`: runtime configuration and secret delivery contract
4. `AWS-03-12`: first AWS runtime target baseline for container delivery
5. `AWS-03-11`: environment promotion across `dev`, `test` and `prod`
6. `AWS-03-14`: rollout and deployment visibility in operations tooling
7. `AWS-03-15`: short-lived deployment authentication for CI/CD
8. `AWS-03-16`: rollback and recovery runbooks

Execution note:

- use ECS/Fargate as the first deployable AWS baseline unless later specs force Kubernetes-specific behavior
- keep the release artifact identical across AWS environments; only config, secrets and infra bindings should vary
- AWS resource provisioning and runtime naming must come from IaC; manual console setup is bootstrap-only at most and not the target operating model
