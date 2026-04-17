# Scaleway Dev `archive-api` Stack

This stack is the Scaleway counterpart to the AWS dev runtime foundation.

Provisioned resources:

- Serverless Containers namespace
- `archive-api` Serverless Container
- local wrapper scripts for `plan`, `apply`, auth check and env export

## Intended runtime model

- public HTTP endpoint via Scaleway Serverless Containers
- in-memory runtime by default for low-cost dev
- optional database connectivity through a separate stack
- non-secret runtime names generated from OpenTofu outputs

## Required inputs

You must still provide:

- `scaleway_project_id`

Optional but supported:

- `scaleway_region`
- `scaleway_zone`
- `service_name`
- `container_name`
- `container_port`
- `image_reference`
- `min_scale`
- `max_scale`
- `cpu_limit`
- `memory_limit`
- `privacy`
- `timeout`
- `max_concurrency`
- `protocol`
- `http_option`
- `health_check_path`
- `health_check_interval`
- `health_check_failure_threshold`
- `private_network_id`
- `jdbc_url`
- `jdbc_user`
- `jdbc_password`
- `tags`

## Example

Files:

```text
infra/live/scaleway/dev/archive-api/dev.tfvars
infra/live/scaleway/dev/archive-api/dev.tfvars.example
```

Typical commands:

```bash
cd infra/live/scaleway/dev/archive-api
TOFU_BIN=/Users/kees/data/projects/archive/tools/opentofu/bin/tofu ./plan.sh
TOFU_BIN=/Users/kees/data/projects/archive/tools/opentofu/bin/tofu ./apply.sh
```

Auth check:

```bash
cd infra/live/scaleway/dev/archive-api
TOFU_BIN=/Users/kees/data/projects/archive/tools/opentofu/bin/tofu ./scw-auth-check.sh
```

Export deploy env from stack outputs:

```bash
cd infra/live/scaleway/dev/archive-api
TOFU_BIN=/Users/kees/data/projects/archive/tools/opentofu/bin/tofu ./export-deploy-env.sh
```

## Outputs used by deployment automation

This stack currently outputs:

- Scaleway project ID
- Scaleway region
- Scaleway zone
- container namespace name and registry endpoint
- container ID, domain name and first public URL
- optional private network ID
- bootstrap image reference

Those outputs are enough to drive the next Scaleway deployment-automation slice.
