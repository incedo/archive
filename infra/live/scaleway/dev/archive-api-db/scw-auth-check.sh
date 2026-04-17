#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOFU_BIN="${TOFU_BIN:-tofu}"
SCW_BIN="${SCW_BIN:-scw}"

if ! command -v "$TOFU_BIN" >/dev/null 2>&1; then
  echo "OpenTofu is not installed or not on PATH: $TOFU_BIN" >&2
  exit 1
fi

if ! command -v "$SCW_BIN" >/dev/null 2>&1; then
  echo "Scaleway CLI is not installed or not on PATH: $SCW_BIN" >&2
  exit 1
fi

cd "$SCRIPT_DIR"

echo "Checking Scaleway CLI auth..."
"$SCW_BIN" info

echo
echo "Checking OpenTofu provider auth path..."
"$TOFU_BIN" plan -refresh=false -lock=false -input=false -var-file=dev.tfvars >/tmp/archive-tofu-scaleway-db-auth-check.txt 2>&1 || true

if rg -q "authentication|unauthorized|invalid credential|forbidden" /tmp/archive-tofu-scaleway-db-auth-check.txt; then
  cat /tmp/archive-tofu-scaleway-db-auth-check.txt
  exit 1
fi

echo "Scaleway credentials are visible to both Scaleway CLI and OpenTofu."
