#!/bin/bash
# Environment Setup for MCP Toolkit on Lilith
# Created by Claude for Jordan Ehrig
# June 23, 2025

# Exit on error
set -e

# Generate random passwords
NEO4J_PASSWORD=$(openssl rand -base64 12)
MONGO_PASSWORD=$(openssl rand -base64 12)
REDIS_PASSWORD=$(openssl rand -base64 12)
MINIO_PASSWORD=$(openssl rand -base64 12)

# Create .env file with secure passwords
cat > .env << EOF
# Database Passwords - KEEP SECURE
NEO4J_PASSWORD=$NEO4J_PASSWORD
MONGO_PASSWORD=$MONGO_PASSWORD
REDIS_PASSWORD=$REDIS_PASSWORD
MINIO_PASSWORD=$MINIO_PASSWORD

# Service Configuration
COMPOSE_PROJECT_NAME=mcp
NODE_ENV=production
EOF

echo "Created .env file with secure passwords"
echo "Make sure to back this up securely!"
