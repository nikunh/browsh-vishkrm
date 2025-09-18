#!/bin/bash
set -e

# Set DEBIAN_FRONTEND to noninteractive to prevent prompts
export DEBIAN_FRONTEND=noninteractive

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
  if [ ! -f ./browsh_1.8.0_linux_amd64.deb ]; then
    wget https://github.com/browsh-org/browsh/releases/download/v1.8.0/browsh_1.8.0_linux_amd64.deb
  fi
  sudo apt-get update
  sudo apt-get install -y ./browsh_1.8.0_linux_amd64.deb
  rm ./browsh_1.8.0_linux_amd64.deb firefox.tar.bz2
fi

# Clean up
sudo apt-get clean
