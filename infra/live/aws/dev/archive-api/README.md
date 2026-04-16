# AWS Dev `archive-api` Stack

This stack provisions the first AWS runtime foundation for `archive-api`.

Provisioned resources:

- VPC
- public subnets
- internet gateway and public routing
- security group
- JDBC Secrets Manager secret
- ECR repository
- ECS cluster
- CloudWatch log group
- ECS task execution role
- ECS task role
- ECS task definition
- ECS/Fargate service
- GitHub Actions OIDC provider
- GitHub Actions deploy role

It does not provision:

- load balancer
- PostgreSQL
- DNS/TLS

## Required inputs

You must still provide:

- `aws_region`
- `image_uri`

Optional but supported:

- `vpc_cidr`
- `public_subnet_cidrs`
- `allowed_ingress_cidrs`
- `jdbc_url`
- `jdbc_user`
- `jdbc_password`
- `target_group_arn`
- `assign_public_ip`
- `desired_count`
- `cpu`
- `memory`
- `tags`

## Bootstrap note

The ECS service needs an image URI even on the first apply.

For bootstrap you can use:

- a temporary public image to prove the service wiring, or
- the first pushed `archive-api` image once CI publishing is ready

This stack defaults `desired_count` to `0` so the infrastructure can be provisioned before the real application image and database values are ready.

After that, GitHub Actions deployment should update the task definition image through ECS deployment automation.

## Example

Files:

```text
infra/live/aws/dev/archive-api/dev.tfvars
infra/live/aws/dev/archive-api/dev.tfvars.example
```

Typical commands:

```bash
cd infra/live/aws/dev/archive-api
TOFU_BIN=/Users/kees/data/projects/archive/tools/opentofu/bin/tofu ./plan.sh
TOFU_BIN=/Users/kees/data/projects/archive/tools/opentofu/bin/tofu tofu apply -var-file=dev.tfvars
```

Wrapper script:

```bash
cd infra/live/aws/dev/archive-api
TOFU_BIN=/Users/kees/data/projects/archive/tools/opentofu/bin/tofu ./plan.sh
```

Auth check:

```bash
cd infra/live/aws/dev/archive-api
TOFU_BIN=/Users/kees/data/projects/archive/tools/opentofu/bin/tofu ./aws-auth-check.sh
```

Apply and export deploy env:

```bash
cd infra/live/aws/dev/archive-api
TOFU_BIN=/Users/kees/data/projects/archive/tools/opentofu/bin/tofu ./apply.sh
```

Export deploy env from stack outputs:

```bash
cd infra/live/aws/dev/archive-api
chmod +x export-deploy-env.sh
TOFU_BIN=/Users/kees/data/projects/archive/tools/opentofu/bin/tofu ./export-deploy-env.sh
```

## Outputs used by deployment automation

This stack outputs:

- AWS region
- VPC ID
- public subnet IDs
- archive-api security group ID
- JDBC secret ARN
- ECR repository name and URL
- ECS cluster name
- ECS service name
- ECS task family
- ECS container name
- GitHub Actions deploy role ARN

Those values should match the deployment workflow configuration for the `dev` environment.
