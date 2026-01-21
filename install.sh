#!/usr/bin/env bash
# Install al-compile to user's local bin directory

set -euo pipefail

INSTALL_DIR="${HOME}/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing al-compile to ${INSTALL_DIR}..."

# Create directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Copy script
cp "${SCRIPT_DIR}/al-compile" "${INSTALL_DIR}/al-compile"
chmod +x "${INSTALL_DIR}/al-compile"

echo "✓ Installed successfully!"
echo ""
echo "Make sure ${INSTALL_DIR} is in your PATH:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
echo ""
echo "Add to ~/.bashrc or ~/.zshrc to make permanent."
