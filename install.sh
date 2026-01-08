#!/usr/bin/env bash
#
# ClaudeGo Installer
# Downloads and runs the ClaudeGo setup script
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/ankurkakroo2/claudeGo/main/install.sh | bash
#
set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/ankurkakroo2/claudeGo/main"
SCRIPT_NAME="claudego"
INSTALL_DIR="${HOME}/.local/bin"

echo "ClaudeGo Installer"
echo "=================="
echo

# Create install directory if needed
mkdir -p "$INSTALL_DIR"

# Download the script
echo "Downloading ClaudeGo..."
if command -v curl &>/dev/null; then
    curl -fsSL "${REPO_URL}/${SCRIPT_NAME}" -o "${INSTALL_DIR}/${SCRIPT_NAME}"
elif command -v wget &>/dev/null; then
    wget -q "${REPO_URL}/${SCRIPT_NAME}" -O "${INSTALL_DIR}/${SCRIPT_NAME}"
else
    echo "Error: curl or wget is required"
    exit 1
fi

# Make executable
chmod +x "${INSTALL_DIR}/${SCRIPT_NAME}"

echo "Downloaded to: ${INSTALL_DIR}/${SCRIPT_NAME}"
echo

# Check if install dir is in PATH
if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
    echo "Adding ${INSTALL_DIR} to PATH..."
    echo "export PATH=\"\$PATH:${INSTALL_DIR}\"" >> "${HOME}/.bashrc"
    export PATH="$PATH:${INSTALL_DIR}"
fi

echo "Running ClaudeGo setup..."
echo
exec "${INSTALL_DIR}/${SCRIPT_NAME}"
