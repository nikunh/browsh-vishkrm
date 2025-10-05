#!/usr/bin/env zsh
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

    # Install Firefox from Mozilla's official APT repository (Docker-compatible, no snap required)
    echo "Adding Mozilla's official APT repository..."

    # Create keyrings directory if it doesn't exist
    sudo mkdir -p /etc/apt/keyrings

    # Add Mozilla's GPG key
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

    # Add Mozilla's APT repository
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null

    # Set package priority to prefer Mozilla's version over snap
    echo 'Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000' | sudo tee /etc/apt/preferences.d/mozilla > /dev/null

    # Install Firefox from Mozilla APT repository
    echo "Installing Firefox from Mozilla APT repository..."
    sudo apt-get update
    sudo apt-get install -y firefox

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
