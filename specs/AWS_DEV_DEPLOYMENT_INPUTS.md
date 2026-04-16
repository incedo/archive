# AWS Dev Deployment Inputs

This document explains the remaining bootstrap inputs for the first `dev` deployment of `archive-api` to AWS using the GitHub Actions ECS workflow.

Project rule:

- AWS resources must be provisioned by IaC
- names and identifiers should be consumed from IaC outputs or generated env files
- manual cloud-console creation is not the intended steady-state

Related files:

- [deploy-aws.yml](/Users/kees/data/projects/archive/.github/workflows/deploy-aws.yml)
- [RUNTIME-CONTRACT.md](/Users/kees/data/projects/archive/apps/archive-api/RUNTIME-CONTRACT.md)
- [deployment.md](/Users/kees/data/projects/archive/specs/architecture/deployment.md)

## Goal

The first AWS baseline is:

- `archive-api` deployed as a container
- ECS on Fargate as runtime
- one existing `dev` ECS service updated by GitHub Actions
- runtime secrets injected by AWS, not baked into the image

This workflow does not create AWS infrastructure yet.
It assumes the `dev` environment already exists and that GitHub Actions is allowed to deploy into it.

The repository now also contains OpenTofu scaffolding for provisioning the first AWS dev runtime foundation:

- [infra/live/aws/dev/archive-api/README.md](/Users/kees/data/projects/archive/infra/live/aws/dev/archive-api/README.md)
- [infra/live/aws/dev/archive-api/dev.tfvars.example](/Users/kees/data/projects/archive/infra/live/aws/dev/archive-api/dev.tfvars.example)

That stack provisions the ECR repository and ECS service foundation, but still expects you to provide networking and database-secret inputs.

## What you need to provide

For the first working `dev` deployment, the automation layer eventually needs these seven values:

1. `AWS_DEPLOY_ROLE_ARN`
2. `aws_region`
3. `image_uri`
4. `ecs_cluster`
5. `ecs_service`
6. `ecs_task_family`
7. `container_name`

For ongoing automation, you should not type most of these values per deployment.
The preferred setup is:

- store AWS names in `deploy/aws/dev.env` or as GitHub `dev` environment variables
- store the deploy role as a GitHub `dev` environment secret
- let the automated workflow build, push, and deploy on `main`

In the target model, these values should come from:

- `OpenTofu` outputs
- generated `deploy/aws/dev.env`
- GitHub environment config populated from IaC-derived values

They should not be maintained by hand long-term.

## The values explained

### 1. `AWS_DEPLOY_ROLE_ARN`

What it is:

- the IAM role that GitHub Actions assumes through OIDC to run the deployment

Example:

```text
arn:aws:iam::123456789012:role/github-archive-dev-deploy
```

Where it goes:

- GitHub repository or environment secret named `AWS_DEPLOY_ROLE_ARN`

Who usually provides it:

- whoever manages AWS IAM for the account

What to ask for:

- an IAM role for GitHub Actions OIDC deployment to ECS `dev`
- trust policy limited to this repository and intended branch/environment
- permissions for:
  - `ecs:DescribeTaskDefinition`
  - `ecs:RegisterTaskDefinition`
  - `ecs:UpdateService`
  - `ecs:DescribeServices`
  - `iam:PassRole` for the ECS task execution/task roles used by this service

### 2. `aws_region`

What it is:

- the AWS region where the `dev` ECS service runs

Example:

```text
eu-west-1
```

How to find it:

- ask the platform owner
- or look at the region selector in the AWS console when viewing the ECS cluster

Recommendation:

- pick one region for `dev` and keep it stable

### 3. `image_uri`

What it is:

- the full immutable image reference to deploy

Example:

```text
123456789012.dkr.ecr.eu-west-1.amazonaws.com/archive-api:sha-3f2a8c1b7c...
```

Preferred form:

- image digest, if available

Example:

```text
123456789012.dkr.ecr.eu-west-1.amazonaws.com/archive-api@sha256:abc123...
```

Important:

- this should point to an image that already exists
- the deploy workflow updates ECS to use this exact image
- the workflow does not build or publish the image

### 4. `ecs_cluster`

What it is:

- the ECS cluster name containing the `archive-api` `dev` service

Example:

```text
archive-dev
```

How to find it:

- AWS Console -> ECS -> Clusters

What to ask for if someone else sets it up:

- the ECS cluster name for the `dev` environment

### 5. `ecs_service`

What it is:

- the ECS service name that should run `archive-api`

Example:

```text
archive-api
```

How to find it:

- AWS Console -> ECS -> selected cluster -> Services

Important:

- this service must already exist
- it must already be wired to networking, security groups, target group, and load balancer rules if external access is needed

### 6. `ecs_task_family`

What it is:

- the ECS task definition family used by the service

Example:

```text
archive-api-dev
```

How to find it:

- open the ECS service
- inspect the current task definition
- copy the family name, not just a revision like `archive-api-dev:12`

Important:

- the workflow fetches the current task definition from this family
- then it swaps only the target container image

### 7. `container_name`

What it is:

- the container name inside the ECS task definition JSON

Default recommendation:

```text
archive-api
```

How to find it:

- open the ECS task definition JSON or task definition screen
- look for the container definition name

Important:

- this must exactly match the task definition’s container name

## Minimal AWS resources that must already exist

Before the workflow can succeed, AWS must already have:

- an ECS cluster for `dev`
- an ECS service for `archive-api`
- an ECS task definition family for that service
- a task execution role for ECS
- a task role if the app needs AWS API access
- a container image registry path, usually ECR
- runtime secret/config delivery for database settings
- a reachable PostgreSQL database if you want persistent mode

Optional but normally expected:

- an Application Load Balancer
- a target group
- DNS and TLS
- CloudWatch log group

## Minimal runtime configuration for `archive-api`

For a persistent AWS `dev` environment, the container needs:

- `ARCHIVE_JDBC_URL`
- `ARCHIVE_JDBC_USER`
- `ARCHIVE_JDBC_PASSWORD`
- optionally `ARCHIVE_PORT=8080`

Recommendation:

- keep `ARCHIVE_PORT` at `8080`
- inject the JDBC values through ECS task definition `secrets` and/or environment values backed by AWS Secrets Manager or SSM Parameter Store

## What you need in GitHub

### GitHub environment

Create a GitHub Actions environment named:

```text
dev
```

Why:

- the workflow uses the selected environment name directly
- this lets you scope secrets and approvals per environment

### GitHub environment variables

Add these variables to the `dev` environment:

```text
AWS_REGION
AWS_DEPLOY_ROLE_ARN
AWS_ECR_REPOSITORY
AWS_ECS_CLUSTER
AWS_ECS_SERVICE
AWS_ECS_TASK_FAMILY
AWS_ECS_CONTAINER_NAME
```

Recommended values:

```text
AWS_REGION=eu-west-1
AWS_DEPLOY_ROLE_ARN=arn:aws:iam::123456789012:role/archive-dev-github-actions-deploy
AWS_ECR_REPOSITORY=archive-api
AWS_ECS_CLUSTER=archive-dev
AWS_ECS_SERVICE=archive-api
AWS_ECS_TASK_FAMILY=archive-api-dev
AWS_ECS_CONTAINER_NAME=archive-api
```

Why:

- these names stay configurable without changing workflow code
- manual deployment can use them as defaults
- the automated `main -> dev` flow can run without retyping AWS names

### Repo env file

You can also store the non-secret AWS names in:

```text
deploy/aws/dev.env
```

Template:

- [deploy/aws/dev.env.example](/Users/kees/data/projects/archive/deploy/aws/dev.env.example)

Supported keys:

```text
AWS_REGION
AWS_ECR_REPOSITORY
AWS_ECS_CLUSTER
AWS_ECS_SERVICE
AWS_ECS_TASK_FAMILY
AWS_ECS_CONTAINER_NAME
```

Rule:

- keep secrets out of this file
- use this file for stable environment names and other non-secret deploy config
- `AWS_DEPLOY_ROLE_ARN` is non-secret and should come from IaC outputs

### Sync script

The repository includes a sync script that pushes the local env file into GitHub environment variables:

```bash
./scripts/sync-github-environment-vars.sh dev
```

Dry run:

```bash
DRY_RUN=1 ./scripts/sync-github-environment-vars.sh dev
```

This script:

- reads `deploy/aws/dev.env`
- infers the repository from the `origin` remote unless `REPO_SLUG` is set
- writes the values into the GitHub `dev` environment with `gh variable set`

## What to ask an AWS/platform engineer for

If someone else owns AWS, send them this checklist:

1. Create an ECR repository for `archive-api`
2. Create an ECS/Fargate `dev` service for `archive-api`
3. Provide the AWS region
4. Provide the ECS cluster name
5. Provide the ECS service name
6. Provide the ECS task definition family
7. Confirm the container name inside the task definition
8. Create an IAM role for GitHub Actions OIDC deploys
9. Share the role ARN for GitHub environment variable `AWS_DEPLOY_ROLE_ARN`
10. Configure runtime secrets for `ARCHIVE_JDBC_URL`, `ARCHIVE_JDBC_USER`, and `ARCHIVE_JDBC_PASSWORD`
11. Confirm the ECR repository name to use for automated `main -> dev` deploys

## Recommended naming

If you still have freedom to choose names, use something predictable:

```text
Region: eu-west-1
Cluster: archive-dev
Service: archive-api
Task family: archive-api-dev
Container name: archive-api
GitHub environment: dev
Deploy role: github-archive-dev-deploy
```

## First deployment example

Example manual workflow input set:

```text
environment: dev
image_uri: 123456789012.dkr.ecr.eu-west-1.amazonaws.com/archive-api:sha-3f2a8c1
aws_region: eu-west-1
ecs_cluster: archive-dev
ecs_service: archive-api
ecs_task_family: archive-api-dev
container_name: archive-api
```

## Automation now supported

The repository now supports two AWS deployment modes:

### 1. Manual deployment

Workflow:

```text
Deploy AWS ECS
```

Usage:

- provide `environment` and `image_uri`
- optionally override region or ECS names
- otherwise the workflow reads the names from GitHub environment variables

### 2. Automatic `main -> dev` deployment

Workflow:

```text
AWS Dev Auto Deploy
```

Behavior:

- runs on push to `main`
- runs tests
- builds the Docker image
- pushes it to ECR
- deploys the pushed image digest to the `dev` ECS service

Required GitHub `dev` environment setup:

- environment variables:
  - `AWS_REGION`
  - `AWS_DEPLOY_ROLE_ARN`
  - `AWS_ECR_REPOSITORY`
  - `AWS_ECS_CLUSTER`
  - `AWS_ECS_SERVICE`
  - `AWS_ECS_TASK_FAMILY`
  - `AWS_ECS_CONTAINER_NAME`
- recommended source:
  - generate `deploy/aws/dev.env` from OpenTofu outputs
  - run `./scripts/sync-github-environment-vars.sh dev`

## What this workflow does not solve yet

This first deployment baseline does not yet define:

- ECR image publishing
- ECS infrastructure creation
- database creation
- load balancer creation
- DNS/TLS provisioning
- automatic promotion from `dev` to `test` or `prod`
- rollback automation beyond ECS service redeploying a known image

Those are the next layers after the first `dev` target is known and stable.
