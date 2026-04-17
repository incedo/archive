#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../" && pwd)"
TOFU_BIN="${TOFU_BIN:-tofu}"
OUTPUT_FILE="${OUTPUT_FILE:-$REPO_ROOT/deploy/scaleway/dev.env}"
SCW_BIN="${SCW_BIN:-scw}"
LOCAL_SCW_ENV_FILE="${LOCAL_SCW_ENV_FILE:-$REPO_ROOT/config/local/scaleway-cli.env}"

if ! command -v "$TOFU_BIN" >/dev/null 2>&1; then
  echo "OpenTofu is not installed or not on PATH: $TOFU_BIN" >&2
  exit 1
fi

cd "$SCRIPT_DIR"
mkdir -p "$(dirname "$OUTPUT_FILE")"

scaleway_organization_id="${SCW_DEFAULT_ORGANIZATION_ID:-}"
if [ -z "$scaleway_organization_id" ] && [ -f "$LOCAL_SCW_ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  . "$LOCAL_SCW_ENV_FILE"
  set +a
  scaleway_organization_id="${SCW_DEFAULT_ORGANIZATION_ID:-}"
fi
if { [ -z "$scaleway_organization_id" ] || [ "$scaleway_organization_id" = "-" ]; } && command -v "$SCW_BIN" >/dev/null 2>&1; then
  scaleway_organization_id="$("$SCW_BIN" config get default-organization-id 2>/dev/null || true)"
fi

if [ -z "$scaleway_organization_id" ] || [ "$scaleway_organization_id" = "-" ]; then
  echo "Missing Scaleway organization id. Set SCW_DEFAULT_ORGANIZATION_ID or configure it in scw config." >&2
  exit 1
fi

scaleway_project_id="$("$TOFU_BIN" output -raw scaleway_project_id)"
scaleway_region="$("$TOFU_BIN" output -raw scaleway_region)"
scaleway_zone="$("$TOFU_BIN" output -raw scaleway_zone)"
container_namespace_name="$("$TOFU_BIN" output -raw container_namespace_name)"
container_name="$("$TOFU_BIN" output -raw container_name)"
container_id="$("$TOFU_BIN" output -raw container_id)"
container_registry_endpoint="$("$TOFU_BIN" output -raw container_registry_endpoint)"
container_domain_name="$("$TOFU_BIN" output -raw container_domain_name)"
private_network_id="$("$TOFU_BIN" output -raw private_network_id 2>/dev/null || true)"

cat > "$OUTPUT_FILE" <<EOF
SCW_DEFAULT_ORGANIZATION_ID=$scaleway_organization_id
SCALEWAY_PROJECT_ID=$scaleway_project_id
SCALEWAY_REGION=$scaleway_region
SCALEWAY_ZONE=$scaleway_zone
SCW_CONTAINER_NAMESPACE=$container_namespace_name
SCW_CONTAINER_NAME=$container_name
SCW_CONTAINER_ID=$container_id
SCW_CONTAINER_REGISTRY_ENDPOINT=$container_registry_endpoint
SCW_CONTAINER_DOMAIN=$container_domain_name
EOF

if [ -n "$private_network_id" ] && [ "$private_network_id" != "null" ]; then
  cat >> "$OUTPUT_FILE" <<EOF
SCW_PRIVATE_NETWORK_ID=$private_network_id
EOF
fi

echo "Wrote $OUTPUT_FILE"
