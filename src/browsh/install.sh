#!/bin/bash
set -e

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

# Install Browsh and dependencies
if ! command -v browsh &>/dev/null; then
  # Install Firefox (required by Browsh)
  if [ ! -f firefox.tar.bz2 ]; then
    wget "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" -O firefox.tar.bz2
  fi
  if [ ! -d /opt/firefox ]; then
    tar -xvf firefox.tar.bz2
    sudo mv firefox /opt/ || true
  fi
  if [ ! -f /usr/local/bin/firefox ]; then
    sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox
  fi
  # Install Browsh
  ARCH=$(get_architecture)
  BROWSH_FILE="browsh_1.8.0_linux_${ARCH}.deb"
  if [ ! -f ./$BROWSH_FILE ]; then
    wget https://github.com/browsh-org/browsh/releases/download/v1.8.0/$BROWSH_FILE
  fi
  sudo apt-get update
  sudo apt-get install -y ./$BROWSH_FILE
  rm ./$BROWSH_FILE firefox.tar.bz2
fi

# Clean up
sudo apt-get clean
