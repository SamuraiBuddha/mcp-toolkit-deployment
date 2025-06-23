#!/bin/bash

# Deploy MCP Toolkit on EVA Network Node
# Usage: ./deploy.sh [node_name]

# Check if node name is provided
if [ -z "$1" ]; then
  echo "Usage: ./deploy.sh [lilith|caspar|balthazar]"
  exit 1
fi

NODE_NAME=$1
CONFIG_FILE=""

# Set config file based on node name
case $NODE_NAME in
  lilith)
    CONFIG_FILE="config/claude_desktop_config.json"
    ;;
  caspar)
    CONFIG_FILE="config/claude_desktop_config_caspar.json"
    ;;
  balthazar)
    CONFIG_FILE="config/claude_desktop_config_balthazar.json"
    ;;
  *)
    echo "Invalid node name. Use lilith, caspar, or balthazar."
    exit 1
    ;;
esac

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Config file $CONFIG_FILE not found!"
  exit 1
fi

echo "Deploying MCP Toolkit on $NODE_NAME using $CONFIG_FILE..."

# Copy config file to appropriate location
mkdir -p $HOME/.config/claude
cp $CONFIG_FILE $HOME/.config/claude/config.json

# Pull latest docker images
echo "Pulling latest Docker images..."
docker-compose pull

# Start services
echo "Starting MCP Toolkit services..."
docker-compose up -d

echo "Deployment complete! MCP Toolkit is now running on $NODE_NAME."
echo "Access the services at the URLs specified in $CONFIG_FILE"
