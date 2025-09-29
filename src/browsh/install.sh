#!/bin/bash
set -e

# Logging mechanism for debugging
LOG_FILE="/tmp/browsh-install.log"
log_debug() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] $*" >> "$LOG_FILE"
}

# Initialize logging
log_debug "=== BROWSH INSTALL STARTED ==="
log_debug "Script path: $0"
log_debug "PWD: $(pwd)"
log_debug "Environment: USER=$USER HOME=$HOME"

# Set DEBIAN_FRONTEND to noninteractive to prevent prompts
export DEBIAN_FRONTEND=noninteractive

# Function to get system architecture
get_architecture() {
    local arch="$(uname -m)"
    case "$arch" in
        x86_64|amd64) echo "amd64" ;;
        aarch64|arm64) echo "arm64" ;;
        *) echo "Unsupported architecture: $arch" >&2; exit 1 ;;
    esac
}

echo "Installing Browsh CLI browser..."

# Install Browsh and dependencies
if ! command -v browsh &>/dev/null; then
    echo "Installing required dependencies..."

    # Install snapd for Firefox installation
    sudo apt-get update
    sudo apt-get install -y snapd

    # Install Firefox via Snap (Ubuntu 22.04 preferred method)
    echo "Installing Firefox via Snap..."
    sudo snap install firefox

    # Create firefox symlink for browsh compatibility
    sudo ln -sf /snap/bin/firefox /usr/local/bin/firefox

    # Install Browsh binary directly (avoid .deb dependency issues)
    echo "Installing Browsh binary..."
    ARCH=$(get_architecture)
    BROWSH_VERSION="1.8.0"
    BROWSH_URL="https://github.com/browsh-org/browsh/releases/download/v${BROWSH_VERSION}/browsh_${BROWSH_VERSION}_linux_${ARCH}"

    # Download browsh binary
    wget -O /tmp/browsh "${BROWSH_URL}"
    chmod +x /tmp/browsh
    sudo mv /tmp/browsh /usr/local/bin/browsh

    echo "Browsh installation completed successfully"
else
    echo "Browsh is already installed"
fi

# Verify installation
if command -v browsh &>/dev/null && command -v firefox &>/dev/null; then
    echo "✅ Browsh and Firefox installed successfully"
    browsh --version || echo "Browsh version check skipped"
else
    echo "❌ Installation verification failed"
    exit 1
fi

# Clean up
sudo apt-get clean

log_debug "=== BROWSH INSTALL COMPLETED ==="
