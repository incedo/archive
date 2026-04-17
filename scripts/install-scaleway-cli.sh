#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

INSTALL_DIR="${INSTALL_DIR:-$REPO_ROOT/tools/bin}"
SCW_VERSION="${SCW_VERSION:-2.54.0}"
OS="${OS:-darwin}"
ARCH="${ARCH:-arm64}"

case "$OS" in
  darwin|linux) ;;
  *)
    echo "Unsupported OS: $OS" >&2
    exit 1
    ;;
esac

case "$ARCH" in
  arm64|amd64) ;;
  *)
    echo "Unsupported ARCH: $ARCH" >&2
    exit 1
    ;;
esac

mkdir -p "$INSTALL_DIR"

archive_name="scaleway-cli_${SCW_VERSION}_${OS}_${ARCH}"
download_url="https://github.com/scaleway/scaleway-cli/releases/download/v${SCW_VERSION}/${archive_name}"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

echo "Downloading Scaleway CLI ${SCW_VERSION} from:"
echo "  $download_url"

curl -fsSL "$download_url" -o "$tmp_dir/scw"
chmod +x "$tmp_dir/scw"
mv "$tmp_dir/scw" "$INSTALL_DIR/scw"

echo "Installed Scaleway CLI to:"
echo "  $INSTALL_DIR/scw"

"$INSTALL_DIR/scw" version
