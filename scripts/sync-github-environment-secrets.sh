#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PROVIDER="${PROVIDER:-${1:-scaleway}}"
ENVIRONMENT="${2:-dev}"
GH_BIN="${GH_BIN:-gh}"
REPO_SLUG="${REPO_SLUG:-}"
DRY_RUN="${DRY_RUN:-0}"

if ! command -v "$GH_BIN" >/dev/null 2>&1; then
  echo "GitHub CLI is not installed or not on PATH: $GH_BIN" >&2
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

case "$PROVIDER" in
  scaleway)
    ENV_FILE="${ENV_FILE:-$REPO_ROOT/config/local/scaleway-cli.env}"
    required_keys=(SCW_ACCESS_KEY SCW_SECRET_KEY)
    ;;
  *)
    echo "Unsupported provider for secret sync: $PROVIDER" >&2
    echo "Expected: scaleway" >&2
    exit 1
    ;;
esac

if [ ! -f "$ENV_FILE" ]; then
  echo "Missing environment file: $ENV_FILE" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
. "$ENV_FILE"
set +a

for key in "${required_keys[@]}"; do
  if [ -z "${!key:-}" ]; then
    echo "Missing required key in $ENV_FILE: $key" >&2
    exit 1
  fi
done

echo "Repository: $REPO_SLUG"
echo "Provider: $PROVIDER"
echo "Environment: $ENVIRONMENT"
echo "Env file: $ENV_FILE"

if [ "$DRY_RUN" = "1" ]; then
  for key in "${required_keys[@]}"; do
    echo "Would execute: $GH_BIN secret set --repo $REPO_SLUG --env $ENVIRONMENT $key"
  done
  exit 0
fi

"$GH_BIN" auth status >/dev/null

for key in "${required_keys[@]}"; do
  printf '%s' "${!key}" | "$GH_BIN" secret set --repo "$REPO_SLUG" --env "$ENVIRONMENT" "$key"
done

echo "Synchronized GitHub environment secrets for '$ENVIRONMENT'."
