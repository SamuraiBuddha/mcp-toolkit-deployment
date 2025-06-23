#!/bin/bash
# MCP Toolkit Deployment Script for Lilith
# Created by Claude for Jordan Ehrig
# June 23, 2025

set -e

echo "===== MCP Toolkit Deployment Script for Lilith ====="
echo "Setting up MCP Toolkit on $(hostname)"

# Create directories
mkdir -p config

# Clone necessary repositories if they don't exist
for repo in mcp-orchestrator mcp-memory-blockchain mcp-time-precision; do
  if [ ! -d "$repo" ]; then
    echo "Cloning $repo..."
    git clone https://github.com/SamuraiBuddha/$repo.git
  else
    echo "$repo directory already exists, skipping clone"
  fi
done

# Check if ZFS datasets exist
echo "Checking ZFS datasets..."
if ! zfs list lilith-pool/docker/memory &>/dev/null; then
  echo "Creating ZFS dataset for memory..."
  sudo zfs create -o compression=lz4 lilith-pool/docker/memory
fi

# Deploy with Docker Compose
echo "Deploying services with Docker Compose..."
docker-compose build
docker-compose up -d

echo "===== Deployment Complete ====="
echo "Services running at:"
echo "- Orchestrator: http://$(hostname -I | awk '{print $1}'):3000"
echo "- Memory: http://$(hostname -I | awk '{print $1}'):3001"
echo "- Time Precision: http://$(hostname -I | awk '{print $1}'):3002"
echo ""
echo "To connect Claude Desktop to these services, update the config with these URLs."
