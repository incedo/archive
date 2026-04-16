#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

OS="$(uname -s)"
if [ "$OS" != "Darwin" ]; then
  echo "This installer currently supports macOS only. Detected: $OS" >&2
  exit 1
fi

INSTALL_PARENT="${INSTALL_PARENT:-$REPO_ROOT/tools}"
BIN_DIR="${BIN_DIR:-$REPO_ROOT/tools/bin}"
PKG_PATH="${PKG_PATH:-$REPO_ROOT/tools/downloads/AWSCLIV2.pkg}"
DOWNLOAD_URL="${DOWNLOAD_URL:-https://awscli.amazonaws.com/AWSCLIV2.pkg}"

mkdir -p "$INSTALL_PARENT" "$BIN_DIR" "$(dirname "$PKG_PATH")"

TARGET_PARENT="$INSTALL_PARENT"
if [[ "$TARGET_PARENT" == *" "* ]]; then
  echo "Install path cannot contain spaces: $TARGET_PARENT" >&2
  exit 1
fi

CHOICES_XML="$(mktemp)"
trap 'rm -f "$CHOICES_XML"' EXIT

cat > "$CHOICES_XML" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <array>
    <dict>
      <key>choiceAttribute</key>
      <string>customLocation</string>
      <key>attributeSetting</key>
      <string>$TARGET_PARENT</string>
      <key>choiceIdentifier</key>
      <string>default</string>
    </dict>
  </array>
</plist>
EOF

echo "Downloading AWS CLI installer from:"
echo "  $DOWNLOAD_URL"
curl -fL "$DOWNLOAD_URL" -o "$PKG_PATH"

echo "Installing AWS CLI into current user home context under:"
echo "  $TARGET_PARENT/aws-cli"
installer -pkg "$PKG_PATH" \
  -target CurrentUserHomeDirectory \
  -applyChoiceChangesXML "$CHOICES_XML"

AWS_BIN_SOURCE="$TARGET_PARENT/aws-cli/aws"
AWS_COMPLETER_SOURCE="$TARGET_PARENT/aws-cli/aws_completer"

if [ ! -x "$AWS_BIN_SOURCE" ]; then
  echo "AWS CLI binary not found after install: $AWS_BIN_SOURCE" >&2
  exit 1
fi

ln -sfn "$AWS_BIN_SOURCE" "$BIN_DIR/aws"
if [ -e "$AWS_COMPLETER_SOURCE" ]; then
  ln -sfn "$AWS_COMPLETER_SOURCE" "$BIN_DIR/aws_completer"
fi

echo
echo "Installed:"
echo "  $BIN_DIR/aws"
echo
echo "Verify with:"
echo "  $BIN_DIR/aws --version"
