#!/bin/bash
# Memory Migration Script for MCP Toolkit
# Created by Claude for Jordan Ehrig
# June 23, 2025

set -e

SOURCE_HOST=$1
SOURCE_PORT=${2:-3001}
TARGET_PORT=${3:-3001}

if [ -z "$SOURCE_HOST" ]; then
  echo "Usage: ./migrate_memory.sh SOURCE_HOST [SOURCE_PORT] [TARGET_PORT]"
  echo ""
  echo "Examples:"
  echo "  ./migrate_memory.sh 192.168.50.70      # Migrate from 192.168.50.70:3001 to localhost:3001"
  echo "  ./migrate_memory.sh 192.168.50.70 3005 3001  # Migrate from 192.168.50.70:3005 to localhost:3001"
  exit 1
fi

echo "===== MCP Memory Migration Tool ====="
echo "Migrating memory from $SOURCE_HOST:$SOURCE_PORT to localhost:$TARGET_PORT"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
MEMORY_FILE="$TEMP_DIR/memory_export.json"

echo "1. Exporting memory from source..."
curl -s -X POST http://$SOURCE_HOST:$SOURCE_PORT/memory/export > "$MEMORY_FILE"

# Check if export was successful
if [ ! -s "$MEMORY_FILE" ]; then
  echo "Error: Memory export failed or returned empty file"
  rm -rf "$TEMP_DIR"
  exit 1
fi

# Count entities in export
ENTITY_COUNT=$(grep -o '"type":"entity"' "$MEMORY_FILE" | wc -l)
echo "   Exported $ENTITY_COUNT entities successfully"

echo "2. Importing memory to target..."
IMPORT_RESULT=$(curl -s -X POST http://localhost:$TARGET_PORT/memory/import \
  -H "Content-Type: application/json" \
  -d @"$MEMORY_FILE")

echo "3. Verifying import..."
VERIFICATION=$(curl -s -X GET http://localhost:$TARGET_PORT/memory/stats)
echo "   Import complete: $VERIFICATION"

# Cleanup
rm -rf "$TEMP_DIR"

echo "===== Memory Migration Complete ====="
echo "You can now update all Claude Desktop instances to connect to Lilith's memory service"
