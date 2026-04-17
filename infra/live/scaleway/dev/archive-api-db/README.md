# Scaleway Dev `archive-api-db` Stack

This stack provisions the optional PostgreSQL layer for the low-cost Scaleway
dev setup.

Provisioned resources:

- Private Network
- Managed PostgreSQL
- Secret Manager secret
- Secret Manager secret version with JDBC payload
- local wrapper scripts for `plan`, `apply`, auth check and env export

Use this stack only when you need persistent database-backed integration
behavior. The default low-cost dev path is the separate
[archive-api](/Users/kees/data/projects/archive/infra/live/scaleway/dev/archive-api/README.md:1)
stack without a database.

## Typical flow

1. Apply this DB stack when you need persistent dev data.
2. Export the generated JDBC values to a local env file.
3. Feed `private_network_id`, `jdbc_url`, `jdbc_user`, and `jdbc_password`
   into the app stack.
4. Destroy this DB stack when you no longer need it.

## Example

Files:

```text
infra/live/scaleway/dev/archive-api-db/dev.tfvars
infra/live/scaleway/dev/archive-api-db/dev.tfvars.example
```

Commands:

```bash
cd infra/live/scaleway/dev/archive-api-db
TOFU_BIN=/Users/kees/data/projects/archive/tools/opentofu/bin/tofu ./plan.sh
TOFU_BIN=/Users/kees/data/projects/archive/tools/opentofu/bin/tofu ./apply.sh
TOFU_BIN=/Users/kees/data/projects/archive/tools/opentofu/bin/tofu ./destroy.sh
```
