#!/bin/bash

set -e

echo "📦 Checking for existing Docker installation..."
if command -v docker &> /dev/null; then
    echo "⚠️ Docker is already installed. Removing old version..."
    sudo apt remove -y docker docker-engine docker.io containerd runc || true
fi

echo "🔧 Installing dependencies..."
sudo apt update
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    jq \
    git

echo "🔐 Setting up Docker GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "📦 Adding Docker repo..."
echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "📥 Updating and installing Docker packages..."
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "🚀 Docker version: $(docker --version)"
echo "🔧 Docker Compose version: $(docker compose version)"

echo "🧹 Removing any previous Immich clone..."
rm -rf Immich-server
git clone https://github.com/immich-app/immich.git Immich-server
cd Immich-server

UPLOAD_PATH="./photos"
read -p "📁 Do you want to change the default upload folder (./photos)? [y/n]: " CHANGE_PATH

if [[ "$CHANGE_PATH" == "y" ]]; then
    read -e -p "👉 Enter full path to your upload directory: " USER_UPLOAD_PATH
    UPLOAD_PATH="$USER_UPLOAD_PATH"
fi

echo "📂 Setting upload location to: $UPLOAD_PATH"

# Update the docker-compose.yml upload path
sed -i "s|\${UPLOAD_LOCATION}|$UPLOAD_PATH|g" docker/docker-compose.yml

echo "🔧 Starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "📦 Bringing up Immich server with Docker Compose..."
cd docker
sudo docker compose up -d

echo "✅ Immich is now running!"
echo "🌐 Access it at: http://localhost:2283 (or http://<your-ip>:2283)"
