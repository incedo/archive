#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../" && pwd)"
TOFU_BIN="${TOFU_BIN:-tofu}"
OUTPUT_FILE="${OUTPUT_FILE:-$REPO_ROOT/deploy/scaleway/dev-db.env}"

if ! command -v "$TOFU_BIN" >/dev/null 2>&1; then
  echo "OpenTofu is not installed or not on PATH: $TOFU_BIN" >&2
  exit 1
fi

cd "$SCRIPT_DIR"
mkdir -p "$(dirname "$OUTPUT_FILE")"

private_network_id="$("$TOFU_BIN" output -raw private_network_id)"
database_instance_name="$("$TOFU_BIN" output -raw database_instance_name)"
jdbc_url="$("$TOFU_BIN" output -raw jdbc_url)"
jdbc_user="$("$TOFU_BIN" output -raw jdbc_user)"
jdbc_password="$("$TOFU_BIN" output -raw jdbc_password)"
jdbc_secret_name="$("$TOFU_BIN" output -raw jdbc_secret_name)"

cat > "$OUTPUT_FILE" <<EOF
SCW_PRIVATE_NETWORK_ID=$private_network_id
SCW_DATABASE_INSTANCE_NAME=$database_instance_name
ARCHIVE_JDBC_URL=$jdbc_url
ARCHIVE_JDBC_USER=$jdbc_user
ARCHIVE_JDBC_PASSWORD=$jdbc_password
SCW_JDBC_SECRET_NAME=$jdbc_secret_name
EOF

echo "Wrote $OUTPUT_FILE"
