#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../" && pwd)"
TOFU_BIN="${TOFU_BIN:-tofu}"
OUTPUT_FILE="${OUTPUT_FILE:-$REPO_ROOT/deploy/aws/dev.env}"

if ! command -v "$TOFU_BIN" >/dev/null 2>&1; then
  echo "OpenTofu is not installed or not on PATH: $TOFU_BIN" >&2
  exit 1
fi

cd "$SCRIPT_DIR"
mkdir -p "$(dirname "$OUTPUT_FILE")"

aws_region="$("$TOFU_BIN" output -raw aws_region)"
ecr_repository_name="$("$TOFU_BIN" output -raw ecr_repository_name)"
ecs_cluster_name="$("$TOFU_BIN" output -raw ecs_cluster_name)"
ecs_service_name="$("$TOFU_BIN" output -raw ecs_service_name)"
ecs_task_family="$("$TOFU_BIN" output -raw ecs_task_family)"
ecs_container_name="$("$TOFU_BIN" output -raw ecs_container_name)"
github_actions_deploy_role_arn="$("$TOFU_BIN" output -raw github_actions_deploy_role_arn)"

cat > "$OUTPUT_FILE" <<EOF
AWS_REGION=$aws_region
AWS_DEPLOY_ROLE_ARN=$github_actions_deploy_role_arn
AWS_ECR_REPOSITORY=$ecr_repository_name
AWS_ECS_CLUSTER=$ecs_cluster_name
AWS_ECS_SERVICE=$ecs_service_name
AWS_ECS_TASK_FAMILY=$ecs_task_family
AWS_ECS_CONTAINER_NAME=$ecs_container_name
EOF

echo "Wrote $OUTPUT_FILE"
