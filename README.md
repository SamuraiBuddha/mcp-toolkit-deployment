# MCP Toolkit Deployment

This repository contains configurations for deploying the Model Context Protocol (MCP) toolkit across the EVA Network infrastructure. The toolkit includes orchestrator, memory, time precision, and other essential MCP services.

## 🔄 Host Network Mode Update

The Docker Compose configuration now uses **host network mode** for all services to ensure seamless connectivity between Lilith (NAS) and the MAGI nodes (Melchior, Balthazar, Caspar).

### Why Host Network Mode?

Host network mode eliminates bridge network isolation issues that were preventing proper communication between the NAS containers and remote nodes. With host networking:

- All container ports are directly exposed on the host's network interface
- No port mapping/translation is needed
- Services correctly announce the actual host IP
- Inter-container communication is simplified
- Performance is improved by removing bridge network overhead

## 🖥️ MAGI Node Configuration

### Caspar and Balthazar Setup

1. Copy the appropriate config file to your Claude Desktop config location:
   - Windows: `%APPDATA%\Claude\claude_desktop_config.json`
   - macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
   - Linux: `~/.config/claude/claude_desktop_config.json`

2. Ensure SSH key authentication is set up:
   ```bash
   # Generate ED25519 key if needed
   ssh-keygen -t ed25519 -C "samuraibuddha@[machine-name]"
   
   # Copy key to Lilith (replace with your actual path)
   ssh-copy-id -i C:\Users\SamuraiBuddha\.ssh\id_ed25519 samuraibuddha@192.168.50.10
   ```

3. Test the SSH connection:
   ```bash
   ssh samuraibuddha@192.168.50.10 echo "Connection successful"
   ```

4. Restart Claude Desktop to apply changes

## 🚀 Deployment on Lilith

1. Clone this repository:
   ```bash
   git clone https://github.com/SamuraiBuddha/mcp-toolkit-deployment.git
   cd mcp-toolkit-deployment
   ```

2. Deploy the stack:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

3. Verify services are running:
   ```bash
   docker-compose ps
   ```

## 🔍 Troubleshooting

If you encounter issues:

1. Check container logs:
   ```bash
   docker-compose logs mcp-orchestrator
   ```

2. Verify SSH connection from MAGI nodes:
   ```bash
   # From Caspar/Balthazar
   ssh -i C:\Users\SamuraiBuddha\.ssh\id_ed25519 samuraibuddha@192.168.50.10 docker ps
   ```

3. Check network connectivity:
   ```bash
   # From MAGI nodes
   ping 192.168.50.10
   ```

4. Restart Docker service on Lilith if needed:
   ```bash
   sudo systemctl restart docker
   docker-compose up -d
   ```

## 🔄 System Architecture

- **Lilith (192.168.50.10)**: Primary AI/Dev NAS with all MCP services
- **Adam (192.168.50.11)**: Business storage NAS
- **Balthazar (192.168.50.20)**: GPU compute node
- **Caspar (192.168.50.21)**: Bridge node
- **Melchior (192.168.50.30)**: Development workstation

## Available Services

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