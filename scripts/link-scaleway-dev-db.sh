#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

ENV_FILE="${ENV_FILE:-$REPO_ROOT/deploy/scaleway/dev-db.env}"
APP_TFVARS_FILE="${APP_TFVARS_FILE:-$REPO_ROOT/infra/live/scaleway/dev/archive-api/dev.tfvars}"

if [ ! -f "$ENV_FILE" ]; then
  echo "Missing DB env file: $ENV_FILE" >&2
  exit 1
fi

if [ ! -f "$APP_TFVARS_FILE" ]; then
  echo "Missing app tfvars file: $APP_TFVARS_FILE" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
. "$ENV_FILE"
set +a

required_vars=(
  SCW_PRIVATE_NETWORK_ID
  ARCHIVE_JDBC_URL
  ARCHIVE_JDBC_USER
  ARCHIVE_JDBC_PASSWORD
)

for name in "${required_vars[@]}"; do
  if [ -z "${!name:-}" ]; then
    echo "Missing required variable in $ENV_FILE: $name" >&2
    exit 1
  fi
done

python3 - "$APP_TFVARS_FILE" <<'PY'
import pathlib
import re
import sys
import os

path = pathlib.Path(sys.argv[1])
text = path.read_text()

replacements = {
    "private_network_id": os.environ["SCW_PRIVATE_NETWORK_ID"],
    "jdbc_url": os.environ["ARCHIVE_JDBC_URL"],
    "jdbc_user": os.environ["ARCHIVE_JDBC_USER"],
    "jdbc_password": os.environ["ARCHIVE_JDBC_PASSWORD"],
}

for key, value in replacements.items():
    pattern = rf'^{key}\s*=.*$'
    replacement = f'{key} = "{value}"'
    text, count = re.subn(pattern, replacement, text, flags=re.MULTILINE)
    if count == 0:
        if not text.endswith("\n"):
            text += "\n"
        text += replacement + "\n"

path.write_text(text)
PY

echo "Updated $APP_TFVARS_FILE from $ENV_FILE"
