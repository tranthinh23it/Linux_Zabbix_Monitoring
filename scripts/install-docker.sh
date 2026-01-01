#!/bin/bash

# Docker Installation Script for Ubuntu

set -e

echo "🐳 Installing Docker and Docker Compose on Ubuntu..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Please don't run this script as root${NC}"
    exit 1
fi

# Update package index
echo -e "${YELLOW}Updating package index...${NC}"
sudo apt update

# Install prerequisites
echo -e "${YELLOW}Installing prerequisites...${NC}"
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

# Add Docker's official GPG key
echo -e "${YELLOW}Adding Docker GPG key...${NC}"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo -e "${YELLOW}Adding Docker repository...${NC}"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
sudo apt update

# Install Docker Engine
echo -e "${YELLOW}Installing Docker Engine...${NC}"
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to docker group
echo -e "${YELLOW}Adding user to docker group...${NC}"
sudo usermod -aG docker $USER

# Install Docker Compose (standalone)
echo -e "${YELLOW}Installing Docker Compose...${NC}"
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create docker-compose symlink
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Enable and start Docker service
echo -e "${YELLOW}Starting Docker service...${NC}"
sudo systemctl enable docker
sudo systemctl start docker

# Test Docker installation
echo -e "${YELLOW}Testing Docker installation...${NC}"
if sudo docker run --rm hello-world > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker installed successfully!${NC}"
else
    echo -e "${RED}❌ Docker installation failed${NC}"
    exit 1
fi

# Test Docker Compose
echo -e "${YELLOW}Testing Docker Compose...${NC}"
if docker-compose --version > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker Compose installed successfully!${NC}"
else
    echo -e "${RED}❌ Docker Compose installation failed${NC}"
    exit 1
fi

# Configure Docker daemon
echo -e "${YELLOW}Configuring Docker daemon...${NC}"
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

# Restart Docker to apply configuration
sudo systemctl restart docker

echo -e "${GREEN}"
echo "=============================================="
echo "🎉 Docker installation completed!"
echo "=============================================="
echo "Docker version: $(docker --version)"
echo "Docker Compose version: $(docker-compose --version)"
echo ""
echo "⚠️  IMPORTANT: Please log out and log back in"
echo "   to use Docker without sudo, or run:"
echo "   newgrp docker"
echo "=============================================="
echo -e "${NC}"

echo -e "${YELLOW}Next steps:${NC}"
echo "1. Log out and log back in (or run 'newgrp docker')"
echo "2. Test with: docker run hello-world"
echo "3. Run the Zabbix setup: make setup"