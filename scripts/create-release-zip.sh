#!/bin/bash
# Create a release zip that extracts to 'fail2ban-whm' (not the GitHub default repo-tag format)
# Usage: ./scripts/create-release-zip.sh [VERSION]
#   VERSION defaults to v1.0.0
# Output: fail2ban-whm-{VERSION}.zip in the current directory

set -e
VERSION="${1:-v1.0.0}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_NAME="fail2ban-whm-${VERSION}.zip"
TMP_DIR="$(mktemp -d)"

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

mkdir -p "$TMP_DIR/fail2ban-whm"
rsync -a --exclude='.git' --exclude='*.zip' "$REPO_ROOT/" "$TMP_DIR/fail2ban-whm/"

cd "$TMP_DIR"
zip -r "$REPO_ROOT/$OUTPUT_NAME" fail2ban-whm

echo "Created: $REPO_ROOT/$OUTPUT_NAME"
echo "Extracts to: fail2ban-whm/"
