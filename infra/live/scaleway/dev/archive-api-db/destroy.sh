#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_DIR="$SCRIPT_DIR"
TFVARS_FILE="${TFVARS_FILE:-$STACK_DIR/dev.tfvars}"
TOFU_BIN="${TOFU_BIN:-tofu}"

if ! command -v "$TOFU_BIN" >/dev/null 2>&1; then
  echo "OpenTofu is not installed or not on PATH: $TOFU_BIN" >&2
  exit 1
fi

if [ ! -f "$TFVARS_FILE" ]; then
  echo "Missing tfvars file: $TFVARS_FILE" >&2
  exit 1
fi

cd "$STACK_DIR"

echo "Using stack directory: $STACK_DIR"
echo "Using tfvars file: $TFVARS_FILE"

"$TOFU_BIN" init
"$TOFU_BIN" destroy -auto-approve -var-file="$TFVARS_FILE"
