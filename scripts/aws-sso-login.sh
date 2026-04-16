#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

AWS_BIN="${AWS_BIN:-$REPO_ROOT/tools/bin/aws}"
AWS_PROFILE_NAME="${AWS_PROFILE_NAME:-incedo-admin}"

if [ ! -x "$AWS_BIN" ]; then
  echo "AWS CLI binary not found or not executable: $AWS_BIN" >&2
  exit 1
fi

echo "Starting AWS SSO login for profile: $AWS_PROFILE_NAME"
"$AWS_BIN" sso login --profile "$AWS_PROFILE_NAME"

echo
echo "Verifying caller identity..."
"$AWS_BIN" sts get-caller-identity --profile "$AWS_PROFILE_NAME"
