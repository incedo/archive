#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  aws-runtime-control.sh <start|stop> [environment]

Behavior:
  - Resolves config from deploy/aws/<environment>.env by default
  - Starts or stops the ECS service for the target environment
  - Optionally starts/stops an RDS instance when AWS_RDS_INSTANCE_IDENTIFIER is configured

Config keys:
  AWS_REGION
  AWS_ECS_CLUSTER
  AWS_ECS_SERVICE
  AWS_ECS_CONTAINER_NAME   # optional, informational only
  AWS_RDS_INSTANCE_IDENTIFIER  # optional

Overrides:
  AWS_BIN
  AWS_PROFILE
  ENV_FILE
  START_DESIRED_COUNT      # default 1 when action=start
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

ACTION="${1:-}"
ENVIRONMENT="${2:-dev}"

if [ -z "$ACTION" ]; then
  usage >&2
  exit 1
fi

case "$ACTION" in
  start|stop) ;;
  *)
    echo "Unsupported action: $ACTION" >&2
    usage >&2
    exit 1
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AWS_BIN="${AWS_BIN:-$REPO_ROOT/tools/bin/aws}"
ENV_FILE="${ENV_FILE:-$REPO_ROOT/deploy/aws/${ENVIRONMENT}.env}"
START_DESIRED_COUNT="${START_DESIRED_COUNT:-1}"

if [ ! -x "$AWS_BIN" ]; then
  echo "AWS CLI binary not found or not executable: $AWS_BIN" >&2
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  echo "Missing environment file: $ENV_FILE" >&2
  exit 1
fi

set -a
. "$ENV_FILE"
set +a

required_vars=(
  AWS_REGION
  AWS_ECS_CLUSTER
  AWS_ECS_SERVICE
)

missing=()
for name in "${required_vars[@]}"; do
  if [ -z "${!name:-}" ]; then
    missing+=("$name")
  fi
done

if [ "${#missing[@]}" -gt 0 ]; then
  printf 'Missing required values in %s:\n' "$ENV_FILE" >&2
  printf '  %s\n' "${missing[@]}" >&2
  exit 1
fi

aws_cmd=("$AWS_BIN" "--region" "$AWS_REGION")
if [ -n "${AWS_PROFILE:-}" ]; then
  aws_cmd+=("--profile" "$AWS_PROFILE")
fi

describe_service_desired_count() {
  "${aws_cmd[@]}" ecs describe-services \
    --cluster "$AWS_ECS_CLUSTER" \
    --services "$AWS_ECS_SERVICE" \
    --query 'services[0].desiredCount' \
    --output text
}

wait_for_rds_status() {
  local expected_status="$1"
  local waiter="$2"
  local identifier="$3"

  echo "Waiting for RDS instance '$identifier' to become $expected_status..."
  "${aws_cmd[@]}" rds "$waiter" --db-instance-identifier "$identifier"
}

if [ "$ACTION" = "start" ]; then
  if [ -n "${AWS_RDS_INSTANCE_IDENTIFIER:-}" ]; then
    current_db_status="$("${aws_cmd[@]}" rds describe-db-instances \
      --db-instance-identifier "$AWS_RDS_INSTANCE_IDENTIFIER" \
      --query 'DBInstances[0].DBInstanceStatus' \
      --output text)"
    echo "RDS instance '$AWS_RDS_INSTANCE_IDENTIFIER' status: $current_db_status"
    if [ "$current_db_status" = "stopped" ]; then
      echo "Starting RDS instance '$AWS_RDS_INSTANCE_IDENTIFIER'..."
      "${aws_cmd[@]}" rds start-db-instance --db-instance-identifier "$AWS_RDS_INSTANCE_IDENTIFIER" >/dev/null
      wait_for_rds_status "available" "wait db-instance-available" "$AWS_RDS_INSTANCE_IDENTIFIER"
    fi
  else
    echo "AWS_RDS_INSTANCE_IDENTIFIER not configured. Skipping database start."
  fi

  echo "Scaling ECS service '$AWS_ECS_SERVICE' in cluster '$AWS_ECS_CLUSTER' to desired count $START_DESIRED_COUNT..."
  "${aws_cmd[@]}" ecs update-service \
    --cluster "$AWS_ECS_CLUSTER" \
    --service "$AWS_ECS_SERVICE" \
    --desired-count "$START_DESIRED_COUNT" >/dev/null

  echo "Waiting for ECS service stability..."
  "${aws_cmd[@]}" ecs wait services-stable \
    --cluster "$AWS_ECS_CLUSTER" \
    --services "$AWS_ECS_SERVICE"

  final_count="$(describe_service_desired_count)"
  echo "Runtime started. ECS desired count: $final_count"
  exit 0
fi

echo "Scaling ECS service '$AWS_ECS_SERVICE' in cluster '$AWS_ECS_CLUSTER' to desired count 0..."
"${aws_cmd[@]}" ecs update-service \
  --cluster "$AWS_ECS_CLUSTER" \
  --service "$AWS_ECS_SERVICE" \
  --desired-count 0 >/dev/null

echo "Waiting for ECS service stability..."
"${aws_cmd[@]}" ecs wait services-stable \
  --cluster "$AWS_ECS_CLUSTER" \
  --services "$AWS_ECS_SERVICE"

if [ -n "${AWS_RDS_INSTANCE_IDENTIFIER:-}" ]; then
  current_db_status="$("${aws_cmd[@]}" rds describe-db-instances \
    --db-instance-identifier "$AWS_RDS_INSTANCE_IDENTIFIER" \
    --query 'DBInstances[0].DBInstanceStatus' \
    --output text)"
  echo "RDS instance '$AWS_RDS_INSTANCE_IDENTIFIER' status: $current_db_status"
  if [ "$current_db_status" = "available" ]; then
    echo "Stopping RDS instance '$AWS_RDS_INSTANCE_IDENTIFIER'..."
    "${aws_cmd[@]}" rds stop-db-instance --db-instance-identifier "$AWS_RDS_INSTANCE_IDENTIFIER" >/dev/null
    wait_for_rds_status "stopped" "wait db-instance-stopped" "$AWS_RDS_INSTANCE_IDENTIFIER"
  fi
else
  echo "AWS_RDS_INSTANCE_IDENTIFIER not configured. Skipping database stop."
fi

final_count="$(describe_service_desired_count)"
echo "Runtime stopped. ECS desired count: $final_count"
