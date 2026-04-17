#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SCW_BIN="${SCW_BIN:-scw}"
STACK_DIR="${STACK_DIR:-$REPO_ROOT/infra/live/scaleway/dev/archive-api}"
TFVARS_FILE="${TFVARS_FILE:-$STACK_DIR/dev.tfvars}"
TFVARS_EXAMPLE="${TFVARS_EXAMPLE:-$STACK_DIR/dev.tfvars.example}"
SCW_PROFILE="${SCW_PROFILE:-}"

if ! command -v "$SCW_BIN" >/dev/null 2>&1; then
  echo "Scaleway CLI is not installed or not on PATH: $SCW_BIN" >&2
  exit 1
fi

if [ ! -f "$TFVARS_EXAMPLE" ]; then
  echo "Missing tfvars example file: $TFVARS_EXAMPLE" >&2
  exit 1
fi

scw_cmd=("$SCW_BIN")
if [ -n "$SCW_PROFILE" ]; then
  scw_cmd+=("-p" "$SCW_PROFILE")
fi

get_config() {
  local key="$1"
  "${scw_cmd[@]}" config get "$key" 2>/dev/null | tr -d '\r'
}

project_id="${SCW_DEFAULT_PROJECT_ID:-$(get_config default-project-id)}"
region="${SCW_DEFAULT_REGION:-$(get_config default-region)}"
zone="${SCW_DEFAULT_ZONE:-$(get_config default-zone)}"

if [ -z "$project_id" ]; then
  echo "Unable to determine Scaleway project ID from CLI config." >&2
  echo "Run 'scw login' or set SCW_DEFAULT_PROJECT_ID." >&2
  exit 1
fi

if [ -z "$region" ]; then
  region="nl-ams"
fi

if [ -z "$zone" ]; then
  zone="${region}-1"
fi

mkdir -p "$STACK_DIR"
cp "$TFVARS_EXAMPLE" "$TFVARS_FILE"

python3 - "$TFVARS_FILE" "$project_id" "$region" "$zone" <<'PY'
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
project_id = sys.argv[2]
region = sys.argv[3]
zone = sys.argv[4]

text = path.read_text()
replacements = {
    r'^scaleway_project_id\s*=.*$': f'scaleway_project_id  = "{project_id}"',
    r'^scaleway_region\s*=.*$': f'scaleway_region      = "{region}"',
    r'^scaleway_zone\s*=.*$': f'scaleway_zone        = "{zone}"',
}

for pattern, replacement in replacements.items():
    text, count = re.subn(pattern, replacement, text, flags=re.MULTILINE)
    if count != 1:
        raise SystemExit(f"Expected to replace exactly one line for pattern: {pattern}")

path.write_text(text)
PY

echo "Wrote $TFVARS_FILE"
echo "  scaleway_project_id = $project_id"
echo "  scaleway_region     = $region"
echo "  scaleway_zone       = $zone"
