#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

AWS_BIN="${AWS_BIN:-$REPO_ROOT/tools/bin/aws}"
AWS_CONFIG_FILE="${AWS_CONFIG_FILE:-$HOME/.aws/config}"

SSO_SESSION_NAME="${SSO_SESSION_NAME:-incedo}"
SSO_START_URL="${SSO_START_URL:-https://d-99674643ea.awsapps.com/start}"
SSO_REGION="${SSO_REGION:-eu-central-1}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-642108038603}"
AWS_ROLE_NAME="${AWS_ROLE_NAME:-AdministratorAccess}"
AWS_PROFILE_NAME="${AWS_PROFILE_NAME:-incedo-admin}"
DEFAULT_REGION="${DEFAULT_REGION:-eu-central-1}"
DEFAULT_OUTPUT="${DEFAULT_OUTPUT:-json}"

if [ ! -x "$AWS_BIN" ]; then
  echo "AWS CLI binary not found or not executable: $AWS_BIN" >&2
  exit 1
fi

mkdir -p "$(dirname "$AWS_CONFIG_FILE")"
touch "$AWS_CONFIG_FILE"

python3 - <<'PY' "$AWS_CONFIG_FILE" "$SSO_SESSION_NAME" "$SSO_START_URL" "$SSO_REGION" "$AWS_PROFILE_NAME" "$AWS_ACCOUNT_ID" "$AWS_ROLE_NAME" "$DEFAULT_REGION" "$DEFAULT_OUTPUT"
import configparser
import os
import sys

(
    config_path,
    sso_session_name,
    sso_start_url,
    sso_region,
    profile_name,
    account_id,
    role_name,
    default_region,
    default_output,
) = sys.argv[1:]

config = configparser.RawConfigParser()
config.optionxform = str
config.read(config_path)

sso_section = f"sso-session {sso_session_name}"
profile_section = f"profile {profile_name}"

if not config.has_section(sso_section):
    config.add_section(sso_section)
config.set(sso_section, "sso_start_url", sso_start_url)
config.set(sso_section, "sso_region", sso_region)
config.set(sso_section, "sso_registration_scopes", "sso:account:access")

if not config.has_section(profile_section):
    config.add_section(profile_section)
config.set(profile_section, "sso_session", sso_session_name)
config.set(profile_section, "sso_account_id", account_id)
config.set(profile_section, "sso_role_name", role_name)
config.set(profile_section, "region", default_region)
config.set(profile_section, "output", default_output)

with open(config_path, "w") as f:
    config.write(f)
PY

echo "Configured AWS SSO profile:"
echo "  profile: $AWS_PROFILE_NAME"
echo "  start URL: $SSO_START_URL"
echo "  sso region: $SSO_REGION"
echo "  account: $AWS_ACCOUNT_ID"
echo "  role: $AWS_ROLE_NAME"
echo
echo "Config file:"
echo "  $AWS_CONFIG_FILE"
echo
echo "Next command:"
echo "  $AWS_BIN sso login --profile $AWS_PROFILE_NAME"
