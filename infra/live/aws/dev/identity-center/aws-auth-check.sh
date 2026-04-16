#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOFU_BIN="${TOFU_BIN:-tofu}"

if ! command -v "$TOFU_BIN" >/dev/null 2>&1; then
  echo "OpenTofu is not installed or not on PATH: $TOFU_BIN" >&2
  exit 1
fi

if ! command -v aws >/dev/null 2>&1; then
  echo "AWS CLI is not installed or not on PATH." >&2
  exit 1
fi

cd "$SCRIPT_DIR"

echo "Checking AWS caller identity..."
aws sts get-caller-identity

echo
echo "Checking OpenTofu provider auth path..."
"$TOFU_BIN" plan -refresh=false -lock=false -input=false -var-file=dev.tfvars >/tmp/archive-identity-center-auth-check.txt 2>&1 || true

if rg -q "No valid credential sources found" /tmp/archive-identity-center-auth-check.txt; then
  cat /tmp/archive-identity-center-auth-check.txt
  exit 1
fi

echo "AWS credentials are visible to both AWS CLI and OpenTofu."

