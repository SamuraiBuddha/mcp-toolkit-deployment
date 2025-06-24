# MCP Toolkit Deployment with Orchestrator Proxy 🚀

**Simplified deployment using MCP Orchestrator Proxy - all MCPs managed by a single container!**

## Architecture Overview

This deployment uses the **MCP Orchestrator Proxy** to manage all MCP servers as subprocesses within a single container. This provides:

- **Unified Management**: One container manages all MCPs
- **On-Demand Spawning**: MCPs start only when needed
- **Resource Efficiency**: Unused MCPs don't consume resources
- **Process Control**: Automatic restart on failures
- **Simplified Configuration**: Single `registry.json` file

## What's Included

### Core Services
- **MCP Orchestrator Proxy**: Manages all MCP servers
- **Neo4j**: Graph database for memory system
- **MongoDB**: Document storage
- **Redis**: Caching layer
- **Portainer**: Container management UI (optional)

### Managed MCPs
- **Memory**: Blockchain-backed knowledge graph (Neo4j)
- **Time Precision**: Microsecond-accurate time operations
- **Filesystem**: File and directory operations
- **GitHub**: Repository and code management
- **Docker**: Container management
- **Sequential Thinking**: Step-by-step problem solving
- **Freshbooks**: Blockchain accounting

## Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/SamuraiBuddha/mcp-toolkit-deployment.git
cd mcp-toolkit-deployment
```

### 2. Configure Environment
```bash
cp .env.example .env
# Edit .env with your values:
# - NEO4J_PASSWORD
# - MONGO_PASSWORD
# - GITHUB_TOKEN
# - COMFYUI_URL (optional)
```

### 3. Deploy
```bash
docker-compose up -d
```

### 4. Configure Claude Desktop

Add to your Claude Desktop config (`claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "orchestrator": {
      "command": "docker",
      "args": ["exec", "-i", "mcp-orchestrator-proxy", "python", "-m", "mcp_orchestrator_proxy"],
      "env": {}
    }
  }
}
```

## How It Works

1. **Claude** sends requests to the Orchestrator Proxy
2. **Orchestrator** determines which MCP to use based on the request
3. **Proxy** spawns the MCP if not already running
4. **MCP** executes the tool and returns results
5. **Proxy** manages MCP lifecycle (idle timeout, restart on failure)

## Configuration

### Registry Configuration

Edit `config/registry.json` to:
- Add new MCPs
- Modify tool descriptions
- Update keywords for better discovery
- Configure environment variables

### Adding New MCPs

1. Add the MCP to the Dockerfile:
```dockerfile
RUN pip install your-new-mcp  # For Python MCPs
# OR
RUN npm install -g @your/new-mcp  # For Node.js MCPs
```

2. Add configuration to `config/registry.json`:
```json
{
  "mcps": {
    "your-mcp": {
      "description": "What it does",
      "command": "python",
      "args": ["-m", "your_mcp"],
      "tools": {
        // Tool definitions
      }
    }
  }
}
```

3. Rebuild and restart:
```bash
docker-compose build
docker-compose up -d
```

## Advanced Usage

### Scaling
- Adjust resource limits in `docker-compose.yml`
- Configure MCP spawn limits in orchestrator settings
- Use external databases for production

### Monitoring
- Access Portainer at http://localhost:9443
- Check orchestrator logs: `docker logs mcp-orchestrator-proxy`
- Monitor resource usage: `docker stats`

### Troubleshooting

**MCP not starting?**
```bash
docker exec mcp-orchestrator-proxy python -m your_mcp
```

**Connection issues?**
```bash
docker exec -it mcp-orchestrator-proxy bash
# Test connections to services
```

**Registry changes not taking effect?**
```bash
docker-compose restart mcp-orchestrator-proxy
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| NEO4J_PASSWORD | Neo4j password | secure_password_here |
| MONGO_PASSWORD | MongoDB password | secure_password |
| GITHUB_TOKEN | GitHub API token | (required) |
| COMFYUI_URL | ComfyUI server URL | http://localhost:8188 |

## Architecture Benefits

### vs Individual Containers
- **Before**: 7+ containers, each running an MCP
- **After**: 1 orchestrator container managing all MCPs
- **Result**: Lower resource usage, simpler management

### Process Management
- MCPs spawn on first use
- Automatic cleanup after idle timeout
- Restart on failure with backoff
- Resource limits per MCP

## Contributing

To add new MCPs or improve the deployment:
1. Fork the repository
2. Add your MCP to Dockerfile and registry.json
3. Test thoroughly
4. Submit a pull request

## License

MIT License - Perfect for your NAS deployment!

---

*For the standard discovery-only orchestrator (Claude Desktop with existing MCPs), see [mcp-orchestrator](https://github.com/SamuraiBuddha/mcp-orchestrator)*
