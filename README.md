# EVA Network MCP Toolkit Deployment

Deployment files for setting up the MCP toolkit across all nodes in the EVA network (Lilith, Caspar, Balthazar).

## Available Configurations

- `config/claude_desktop_config.json` - Configuration for Lilith (192.168.50.10)
- `config/claude_desktop_config_caspar.json` - Configuration for Caspar (192.168.50.21)
- `config/claude_desktop_config_balthazar.json` - Configuration for Balthazar (192.168.50.20)

## Quick Start

1. SSH into the target EVA node:
   ```bash
   # For Lilith
   ssh samuraibuddha@192.168.50.10
   
   # For Caspar (note the port)
   ssh samuraibuddha@192.168.50.21 -p 9222
   
   # For Balthazar
   ssh samuraibuddha@192.168.50.20
   ```

2. Clone this repository:
   ```bash
   git clone https://github.com/SamuraiBuddha/mcp-toolkit-deployment.git
   cd mcp-toolkit-deployment
   ```

3. Make the deployment script executable:
   ```bash
   chmod +x deploy.sh
   ```

4. Run the deployment script with the appropriate node name:
   ```bash
   ./deploy.sh [lilith|caspar|balthazar]
   ```

This will:
- Copy the appropriate configuration file to the Claude Desktop config location
- Pull the latest Docker images
- Start all the MCP Toolkit services

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
   sudo zfs create -o compression=lz4 [pool-name]/docker/memory
   ```

3. Deploy with Docker Compose:
   ```bash
   docker-compose build
   docker-compose up -d
   ```

## Services

The MCP Toolkit includes these services:
- MCP Orchestrator
- MCP Memory
- MCP Time Precision
- ComfyUI
- Portainer Bridge
- Neo4j
- MongoDB
- Redis
- MinIO
- Traefik

## Architecture

Each EVA node runs an identical stack with node-specific configurations.

- **Lilith (192.168.50.10)**: Primary AI NAS
- **Caspar (192.168.50.21)**: Bridge node 
- **Balthazar (192.168.50.20)**: GPU node
- **Adam (192.168.50.11)**: Business storage (no MCP Toolkit)
- **Melchior (192.168.50.30)**: Development workstation

## Accessing Services

Once deployed, services can be accessed at:
- Orchestrator: http://[node-ip]:3000
- Memory: http://[node-ip]:3001
- Time Precision: http://[node-ip]:3002
- ComfyUI: http://[node-ip]:3003
- Portainer Bridge: http://[node-ip]:3004

## Connecting Multiple Claude Instances

Configure each Claude Desktop to connect to the appropriate EVA node's MCP services by using the config files provided in this repository.

## Troubleshooting

- If containers fail to start, check Docker logs: `docker-compose logs`
- Verify ZFS datasets are created correctly: `zfs list | grep [pool-name]`
- Ensure ports are accessible: `sudo netstat -tulpn | grep LISTEN`
