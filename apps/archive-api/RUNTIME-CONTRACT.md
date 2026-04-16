# archive-api Runtime Contract

This document defines the runtime contract for the `archive-api` container.

## Container contract

- Entrypoint: `/app/bin/archive-api`
- Default port: `8080`
- Health endpoint: `GET /api/v1/admin/health`
- Runtime style: stateless containerized JVM service

## Configuration

### Required for persistent runtime

- `ARCHIVE_JDBC_URL`: JDBC connection string for PostgreSQL or compatible runtime database
- `ARCHIVE_JDBC_USER`: database username
- `ARCHIVE_JDBC_PASSWORD`: database password

### Optional

- `ARCHIVE_PORT`: HTTP listen port, defaults to `8080`

## Startup modes

### Ephemeral/test mode

If no JDBC settings are provided, the service starts with in-memory persistence. This is suitable for CI validation and local smoke tests only.

### Persistent environment mode

For `dev`, `test`, and `prod` deployments, JDBC settings are expected to be provided through environment-specific configuration and secret delivery.

## Release identity

- The immutable release identity is the full Git commit SHA.
- Container tags may include helper tags such as short SHA or branch labels for convenience.
- Promotion between environments must be based on the same built artifact, preferably by image digest.

## Deployment rules

- The container image must be built once and promoted without rebuild across environments.
- Secrets must be injected at runtime and must not be baked into the image.
- Provider-specific configuration binding belongs in deployment and infrastructure automation, not in the application binary.

## AWS ECS/Fargate baseline

The first AWS deployment baseline is ECS/Fargate.

Expected deployment contract:

- the deployment workflow receives a full immutable `image_uri`
- the target ECS service already exists for the selected environment
- runtime secrets are injected by AWS-native configuration, not by the image build
- rollout success is determined by ECS service stability and the application health endpoint
- AWS resource names can be provided as workflow inputs or through GitHub environment variables
- AWS resource names can also be provided through `deploy/aws/<environment>.env` for non-secret defaults
- the GitHub OIDC deploy role ARN is non-secret configuration and should be supplied from IaC outputs, not a hand-managed GitHub secret
- dev runtime start/stop automation may also consume an optional `AWS_RDS_INSTANCE_IDENTIFIER` when the environment uses a managed PostgreSQL instance

Operator guide:

- [AWS_DEV_DEPLOYMENT_INPUTS.md](/Users/kees/data/projects/archive/specs/AWS_DEV_DEPLOYMENT_INPUTS.md)
