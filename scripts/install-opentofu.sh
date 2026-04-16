#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TOFU_VERSION="${TOFU_VERSION:-1.10.6}"
INSTALL_ROOT="${INSTALL_ROOT:-$REPO_ROOT/tools/opentofu}"
DOWNLOAD_DIR="$INSTALL_ROOT/downloads"
BIN_DIR="$INSTALL_ROOT/bin"

OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Darwin) platform_os="darwin" ;;
  Linux) platform_os="linux" ;;
  *)
    echo "Unsupported OS: $OS" >&2
    exit 1
    ;;
esac

case "$ARCH" in
  arm64|aarch64) platform_arch="arm64" ;;
  x86_64|amd64) platform_arch="amd64" ;;
  *)
    echo "Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
esac

ARCHIVE_NAME="tofu_${TOFU_VERSION}_${platform_os}_${platform_arch}.zip"
ARCHIVE_PATH="$DOWNLOAD_DIR/$ARCHIVE_NAME"
DOWNLOAD_URL="https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/${ARCHIVE_NAME}"

mkdir -p "$DOWNLOAD_DIR" "$BIN_DIR"

echo "Installing OpenTofu $TOFU_VERSION for $platform_os/$platform_arch"
echo "Download URL: $DOWNLOAD_URL"

curl -fL "$DOWNLOAD_URL" -o "$ARCHIVE_PATH"
unzip -o "$ARCHIVE_PATH" -d "$BIN_DIR"
chmod +x "$BIN_DIR/tofu"

echo
echo "Installed:"
echo "  $BIN_DIR/tofu"
echo
echo "Verify with:"
echo "  $BIN_DIR/tofu version"
echo
echo "Or run the plan script with:"
echo "  TOFU_BIN=$BIN_DIR/tofu infra/live/aws/dev/archive-api/plan.sh"
