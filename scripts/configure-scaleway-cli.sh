#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SCW_BIN="${SCW_BIN:-$REPO_ROOT/tools/bin/scw}"
ENV_FILE="${ENV_FILE:-$REPO_ROOT/config/local/scaleway-cli.env}"
ACCESS_KEY="${SCW_ACCESS_KEY:-${1:-}}"
SECRET_KEY="${SCW_SECRET_KEY:-${2:-}}"
DEFAULT_PROJECT_ID="${SCW_DEFAULT_PROJECT_ID:-e52de29f-0493-4437-9107-a4881d33ef54}"
DEFAULT_REGION="${SCW_DEFAULT_REGION:-nl-ams}"
DEFAULT_ZONE="${SCW_DEFAULT_ZONE:-nl-ams-1}"

if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  set -a
  . "$ENV_FILE"
  set +a

  ACCESS_KEY="${SCW_ACCESS_KEY:-${ACCESS_KEY}}"
  SECRET_KEY="${SCW_SECRET_KEY:-${SECRET_KEY}}"
  DEFAULT_PROJECT_ID="${SCW_DEFAULT_PROJECT_ID:-${DEFAULT_PROJECT_ID}}"
  DEFAULT_REGION="${SCW_DEFAULT_REGION:-${DEFAULT_REGION}}"
  DEFAULT_ZONE="${SCW_DEFAULT_ZONE:-${DEFAULT_ZONE}}"
fi

if ! command -v "$SCW_BIN" >/dev/null 2>&1; then
  echo "Scaleway CLI is not installed or not on PATH: $SCW_BIN" >&2
  exit 1
fi

if [ -z "$ACCESS_KEY" ]; then
  echo "Missing access key." >&2
  echo "Pass it as the first argument or set SCW_ACCESS_KEY." >&2
  exit 1
fi

if [ -z "$SECRET_KEY" ]; then
  echo "Missing secret key." >&2
  echo "Pass it as the second argument or set SCW_SECRET_KEY." >&2
  exit 1
fi

"$SCW_BIN" config set \
  access-key="$ACCESS_KEY" \
  secret-key="$SECRET_KEY" \
  default-project-id="$DEFAULT_PROJECT_ID" \
  default-region="$DEFAULT_REGION" \
  default-zone="$DEFAULT_ZONE"

echo "Configured Scaleway CLI:"
echo "  env-file            = ${ENV_FILE}"
echo "  default-project-id = $DEFAULT_PROJECT_ID"
echo "  default-region     = $DEFAULT_REGION"
echo "  default-zone       = $DEFAULT_ZONE"
