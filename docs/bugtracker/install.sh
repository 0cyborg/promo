#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://0cyborg.github.io/promo/bugtracker/releases/latest"
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/bugtracker"
BINARY_NAME="bugtracker"

os="$(uname -s)"
case "$os" in
  Linux)
    if grep -qi microsoft /proc/version 2>/dev/null; then
      platform="WSL"
    else
      platform="Linux"
    fi
    asset="bugtracker-linux-x86_64"
    ;;
  Darwin)
    platform="macOS"
    asset="bugtracker-darwin-x86_64"
    ;;
  *)
    echo "error: unsupported platform '$os' (this installer supports Linux, macOS, and WSL)" >&2
    exit 1
    ;;
esac

arch="$(uname -m)"
if [ "$arch" != "x86_64" ]; then
  echo "error: unsupported architecture '$arch' (only x86_64 builds are published)" >&2
  exit 1
fi

if ! curl -fsSL --head "$BASE_URL/$asset" -o /dev/null; then
  echo "error: no $platform build is published yet — check https://0cyborg.github.io/promo/bugtracker/ for updates" >&2
  exit 1
fi

mkdir -p "$INSTALL_DIR" "$CONFIG_DIR"

echo "Downloading BugTracker for $platform..."
curl -fsSL "$BASE_URL/$asset" -o "$INSTALL_DIR/$BINARY_NAME"
chmod +x "$INSTALL_DIR/$BINARY_NAME"

echo "Installing license key..."
curl -fsSL "$BASE_URL/license.key" -o "$CONFIG_DIR/license.key"

echo
echo "BugTracker installed to $INSTALL_DIR/$BINARY_NAME"
case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *) echo "Add it to your PATH: export PATH=\"$INSTALL_DIR:\$PATH\"" ;;
esac
echo "Run '$BINARY_NAME' to get started."
