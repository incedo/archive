#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

ENVIRONMENT="${1:-dev}"
ENV_FILE="${ENV_FILE:-$REPO_ROOT/deploy/aws/${ENVIRONMENT}.env}"
GH_BIN="${GH_BIN:-gh}"
REPO_SLUG="${REPO_SLUG:-}"
DRY_RUN="${DRY_RUN:-0}"

if ! command -v "$GH_BIN" >/dev/null 2>&1; then
  echo "GitHub CLI is not installed or not on PATH: $GH_BIN" >&2
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  echo "Missing environment file: $ENV_FILE" >&2
  exit 1
fi

if [ -z "$REPO_SLUG" ]; then
  origin_url="$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null || true)"

  case "$origin_url" in
    git@github.com:*.git)
      REPO_SLUG="${origin_url#git@github.com:}"
      REPO_SLUG="${REPO_SLUG%.git}"
      ;;
    https://github.com/*/.git)
      REPO_SLUG="${origin_url#https://github.com/}"
      REPO_SLUG="${REPO_SLUG%.git}"
      ;;
    https://github.com/*)
      REPO_SLUG="${origin_url#https://github.com/}"
      ;;
  esac
fi

if [ -z "$REPO_SLUG" ]; then
  echo "Unable to determine GitHub repository slug from origin remote. Set REPO_SLUG=owner/name." >&2
  exit 1
fi

required_keys=(
  AWS_REGION
  AWS_DEPLOY_ROLE_ARN
  AWS_ECR_REPOSITORY
  AWS_ECS_CLUSTER
  AWS_ECS_SERVICE
  AWS_ECS_TASK_FAMILY
  AWS_ECS_CONTAINER_NAME
)

missing_keys=()
for key in "${required_keys[@]}"; do
  if ! grep -Eq "^${key}=" "$ENV_FILE"; then
    missing_keys+=("$key")
  fi
done

if [ "${#missing_keys[@]}" -gt 0 ]; then
  printf 'Missing required keys in %s:\n' "$ENV_FILE" >&2
  printf '  %s\n' "${missing_keys[@]}" >&2
  exit 1
fi

echo "Repository: $REPO_SLUG"
echo "Environment: $ENVIRONMENT"
echo "Env file: $ENV_FILE"

if [ "$DRY_RUN" = "1" ]; then
  echo "Dry run enabled. Would execute:"
  echo "  $GH_BIN variable set --repo $REPO_SLUG --env $ENVIRONMENT -f $ENV_FILE"
  exit 0
fi

"$GH_BIN" auth status >/dev/null
"$GH_BIN" variable set --repo "$REPO_SLUG" --env "$ENVIRONMENT" -f "$ENV_FILE"

echo "Synchronized GitHub environment variables for '$ENVIRONMENT'."
