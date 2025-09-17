#!/bin/bash
set -e

echo "[INFO] Checking for old Docker installation..."

# Stop Docker if running
if systemctl is-active --quiet docker; then
    echo "[INFO] Stopping Docker service..."
    systemctl stop docker
fi

# Remove old containers, images, volumes, and networks
if command -v docker &> /dev/null; then
    echo "[INFO] Cleaning up old Docker resources..."
    docker ps -aq | xargs -r docker stop
    docker ps -aq | xargs -r docker rm -f
    docker images -aq | xargs -r docker rmi -f
    docker volume ls -q | xargs -r docker volume rm -f
    docker network prune -f || true
fi

# Remove old docker packages
echo "[INFO] Removing old Docker packages (if any)..."
dnf remove -y docker \
              docker-client \
              docker-client-latest \
              docker-common \
              docker-latest \
              docker-latest-logrotate \
              docker-logrotate \
              docker-engine || true

# Setup Docker repo
echo "[INFO] Setting up Docker repository..."
dnf -y install dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker CE
echo "[INFO] Installing Docker CE..."
dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start and enable Docker
echo "[INFO] Starting and enabling Docker service..."
systemctl start docker
systemctl enable docker

# Verify
echo "[INFO] Docker version installed:"
docker --version
