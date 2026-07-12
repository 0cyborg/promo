#!/usr/bin/env bash
set -euo pipefail

API_URL="https://api.github.com/repos/0cyborg/promo/contents/docs/bugtracker/releases/latest"
RAW_BASE="https://raw.githubusercontent.com/0cyborg/promo/main/docs/bugtracker/releases/latest"
PAGES_BASE="https://0cyborg.github.io/promo/bugtracker/releases/latest"
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
    keyword="linux"
    ;;
  Darwin)
    platform="macOS"
    keyword="darwin"
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

# Release filenames are version-stamped (e.g. bugtracker_0.9.9_linux-x86-64),
# so the exact name changes every release. Rather than requiring a duplicate
# unversioned copy to be maintained by hand, ask the GitHub API for the
# current directory listing and pick out the raw binary by its naming
# pattern: lowercase "bugtracker_", the platform keyword, and no file
# extension (distinguishes it from the "BugTracker_..." .AppImage/.deb
# packages sitting alongside it).
listing="$(curl -fsSL "$API_URL")" || {
  echo "error: could not reach the release listing" >&2
  exit 1
}

asset="$(printf '%s\n' "$listing" \
  | grep -oE '"name": *"[^"]+"' \
  | sed -E 's/"name": *"(.*)"/\1/' \
  | grep -E "^bugtracker_[^\"]*_${keyword}-x86-64\$" \
  | head -n1)"

if [ -z "$asset" ]; then
  echo "error: no $platform build is published yet — check https://0cyborg.github.io/promo/bugtracker/ for updates" >&2
  exit 1
fi

mkdir -p "$INSTALL_DIR" "$CONFIG_DIR"

echo "Downloading BugTracker for $platform ($asset)..."
curl -fsSL "$RAW_BASE/$asset" -o "$INSTALL_DIR/$BINARY_NAME"
chmod +x "$INSTALL_DIR/$BINARY_NAME"

echo "Installing license key..."
curl -fsSL "$PAGES_BASE/license.key" -o "$CONFIG_DIR/license.key"

echo
echo "BugTracker installed to $INSTALL_DIR/$BINARY_NAME"
case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *) echo "Add it to your PATH: export PATH=\"$INSTALL_DIR:\$PATH\"" ;;
esac
echo "Run '$BINARY_NAME' to get started."
