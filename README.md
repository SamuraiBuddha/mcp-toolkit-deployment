# MCP Toolkit Deployment for Lilith

Deployment files for setting up the MCP toolkit on Lilith (EVA network node) for connecting multiple Claude instances.

## Quick Start

1. SSH into Lilith:
   ```bash
   ssh samuraibuddha@192.168.50.10
   ```

2. Clone this repository:
   ```bash
   git clone https://github.com/SamuraiBuddha/mcp-toolkit-deployment.git
   cd mcp-toolkit-deployment
   ```

3. Make the setup script executable:
   ```bash
   chmod +x setup.sh
   ```

4. Run the setup script:
   ```bash
   ./setup.sh
   ```

## Manual Setup

If you prefer to set up components manually:

1. Clone the necessary repositories:
   ```bash
   git clone https://github.com/SamuraiBuddha/mcp-orchestrator.git
   git clone https://github.com/SamuraiBuddha/mcp-memory-blockchain.git
   git clone https://github.com/SamuraiBuddha/mcp-time-precision.git
   ```

2. Create ZFS datasets if needed:
   ```bash
   sudo zfs create -o compression=lz4 lilith-pool/docker/memory
   ```

3. Deploy with Docker Compose:
   ```bash
   docker-compose build
   docker-compose up -d
   ```

## Connecting Claude Desktop

Update your Claude Desktop configuration to point to Lilith's MCP services:

1. Copy the `config/claude_desktop_config.json` to your Claude Desktop installation
2. Adjust IP addresses and ports if necessary
3. Restart Claude Desktop

## Additional MCPs

The docker-compose.yml includes commented sections for additional MCPs:
- ComfyUI
- Portainer Bridge

Uncomment these sections to deploy these additional services as needed.

## Memory Migration

To migrate memory from an existing Claude Desktop to Lilith:

```bash
# On your existing Claude Desktop machine
curl -X POST http://localhost:3001/memory/export > memory_export.json

# Transfer the file to Lilith

# On Lilith
curl -X POST http://localhost:3001/memory/import -H "Content-Type: application/json" -d @memory_export.json
```

## Connecting Multiple Claude Instances

Configure each Claude Desktop to connect to Lilith's MCP services by updating their config files with Lilith's IP address (192.168.50.10) and the appropriate ports.

## Troubleshooting

- If containers fail to start, check Docker logs: `docker-compose logs`
- Verify ZFS datasets are created correctly: `zfs list | grep lilith-pool`
- Ensure ports are accessible: `sudo netstat -tulpn | grep LISTEN`