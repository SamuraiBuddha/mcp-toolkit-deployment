#!/bin/bash

# MCP Toolkit Deployment Script
# Deploys the MCP Orchestrator Proxy stack

set -e

echo "🚀 MCP Toolkit Deployment with Orchestrator Proxy"
echo "================================================"

# Check if .env exists
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        echo "Creating .env from .env.example..."
        cp .env.example .env
        echo "⚠️  Please edit .env with your configuration values!"
        echo "Press Enter to continue after editing..."
        read -r
    else
        echo "❌ No .env or .env.example found!"
        exit 1
    fi
fi

# Build the orchestrator proxy image
echo "🔨 Building MCP Orchestrator Proxy image..."
docker-compose build

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose down

# Start the stack
echo "🚀 Starting MCP Toolkit stack..."
docker-compose up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to be healthy..."
sleep 10

# Check status
echo "📊 Checking service status..."
docker-compose ps

# Show logs for orchestrator
echo ""
echo "📝 Recent orchestrator logs:"
docker logs --tail 20 mcp-orchestrator-proxy

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📌 Next steps:"
echo "1. Add the orchestrator to your Claude Desktop config"
echo "2. Access Portainer at http://localhost:9443"
echo "3. Monitor logs with: docker logs -f mcp-orchestrator-proxy"
echo ""
echo "🎉 MCP Toolkit is ready to use!"
