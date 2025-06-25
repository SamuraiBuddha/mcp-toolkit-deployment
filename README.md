# MCP Toolkit Deployment - Distributed Architecture 🚀

**Distributed deployment across your EVA network with centralized management!**

## 🌐 Architecture Overview

This deployment uses a **distributed architecture** that optimizes service placement across your EVA network:

### Network Topology
```
┌─────────────────────────────────────────────────────────────────┐
│                         EVA Network                              │
├─────────────────────┬──────────────────┬───────────────────────┤
│   Lilith (.10)      │   Adam (.11)     │   MAGI Nodes          │
│   Primary NAS       │   Business NAS   │   GPU Workstations    │
│   ┌──────────────┐  │   ┌──────────┐  │   ┌──────────────┐   │
│   │ Shared Svcs  │  │   │ Storage  │  │   │ Melchior(.30)│   │
│   │ - Databases  │  │   │ - RAIDZ1 │  │   │ - ComfyUI    │   │
│   │ - Orchestr.  │  │   │ - Samba  │  │   │ - Local GPU  │   │
│   │ - Auth/APIs │  │   │ - Backup │  │   │ - IDE Tools  │   │
│   │ - Monitoring │  │   └──────────┘  │   └──────────────┘   │
│   └──────────────┘  │                  │   ┌──────────────┐   │
│                     │                  │   │ Caspar (.21) │   │
│                     │                  │   │ Balthazar(.20)│   │
└─────────────────────┴──────────────────┴───────────────────────┘
```

## 🎯 Service Distribution Strategy

### Centralized on NAS (Lilith)
- **Databases**: Neo4j, PostgreSQL, MongoDB, Redis, Qdrant, Supabase
- **Orchestration**: MCP Orchestrator Proxy
- **Authentication**: Keycloak (future)
- **API Gateway**: Kong/Traefik (future)
- **Monitoring**: Prometheus, Grafana
- **Object Storage**: MinIO (future)
- **Embedding Models**: Small, frequently-reused models

### Local on GPU Nodes
- **ComfyUI**: Direct GPU access for image generation
- **LLMs**: Full language models remain on GPU nodes
- **IDE Tools**: Machine-specific development tools
- **Desktop MCPs**: Local filesystem access

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/SamuraiBuddha/mcp-toolkit-deployment.git
cd mcp-toolkit-deployment
git checkout distributed-architecture
```

### 2. Deploy on Lilith (NAS)
```bash
# SSH into Lilith
ssh samuraibuddha@192.168.50.10

# Deploy shared services
docker-compose -f docker-compose.nas.yml up -d
```

### 3. Deploy on GPU Nodes
```bash
# On Melchior/Caspar/Balthazar
docker-compose -f docker-compose.local.yml up -d
```

### 4. Configure Claude Desktop

Each node needs its specific configuration:

**For Melchior (configs/melchior.json):**
```json
{
  "mcpServers": {
    "orchestrator": {
      "command": "ssh",
      "args": [
        "samuraibuddha@192.168.50.10",
        "docker", "exec", "-i", "mcp-orchestrator-proxy",
        "python", "-m", "mcp_orchestrator_proxy"
      ]
    },
    "comfyui": {
      "command": "docker",
      "args": ["exec", "-i", "comfyui-mcp", "python", "-m", "mcp_comfyui"]
    }
  }
}
```

## 🎮 EVA Network Management Dashboard

Access the unified dashboard at: `http://192.168.50.30:3000` (or any GPU node)

### Features
- **Real-time Status**: Monitor all 5 EVA nodes
- **Container Management**: Start/stop/restart containers remotely
- **SSH Integration**: Execute commands across the network
- **Service Health**: Visual indicators for all services
- **Matrix Rain Effect**: Because style matters! 🔥

### Dashboard Deployment
```bash
cd eva-dashboard
docker-compose up -d
```

## 📁 Repository Structure

```
mcp-toolkit-deployment/
├── docker-compose.nas.yml      # Lilith deployment
├── docker-compose.local.yml    # GPU node deployment
├── docker-compose.dashboard.yml # EVA dashboard
├── configs/
│   ├── melchior.json          # Melchior Claude config
│   ├── caspar.json            # Caspar Claude config
│   ├── balthazar.json         # Balthazar Claude config
│   └── lilith.json            # Lilith Claude config
├── eva-dashboard/
│   ├── index.html             # Dashboard UI
│   ├── api-server.js          # SSH backend
│   └── Dockerfile
├── scripts/
│   ├── setup-nas.sh           # Lilith setup
│   ├── setup-gpu-node.sh      # GPU node setup
│   └── migrate-memory.sh      # Neo4j migration
└── registry.json              # MCP discovery config
```

## 🔧 Configuration

### Environment Variables
Create `.env` files on each node:

**Lilith (.env.nas):**
```env
NODE_TYPE=nas
NODE_IP=192.168.50.10
NEO4J_PASSWORD=your_secure_password
MONGO_PASSWORD=your_secure_password
GITHUB_TOKEN=your_github_token
```

**GPU Nodes (.env.local):**
```env
NODE_TYPE=gpu
NAS_IP=192.168.50.10
COMFYUI_URL=http://localhost:8188
```

### Network Requirements
- All nodes must be on `192.168.50.0/24` network
- SSH access between nodes (port 22)
- Firewall rules for service ports:
  - 8080: Orchestrator Proxy
  - 7474/7687: Neo4j
  - 5432: PostgreSQL
  - 27017: MongoDB
  - 6379: Redis
  - 3000: EVA Dashboard

## 📊 Monitoring

### Portainer
Access at `http://192.168.50.10:9443` for container management

### Logs
```bash
# View orchestrator logs
docker logs -f mcp-orchestrator-proxy

# View all logs on Lilith
ssh samuraibuddha@192.168.50.10 "docker-compose -f docker-compose.nas.yml logs -f"
```

### Resource Usage
```bash
# Check resource usage on any node
docker stats
```

## 🚨 Troubleshooting

### Service Discovery Issues
```bash
# Test orchestrator from Melchior
ssh samuraibuddha@192.168.50.10 "docker exec mcp-orchestrator-proxy python -m mcp_orchestrator list"
```

### Network Connectivity
```bash
# Test SSH connection
ssh -v samuraibuddha@192.168.50.10

# Test service connectivity
curl http://192.168.50.10:8080/health
```

### Container Issues
```bash
# Restart services on Lilith
ssh samuraibuddha@192.168.50.10 "docker-compose -f docker-compose.nas.yml restart"
```

## 🔄 Migration Guide

### From Single-Host to Distributed

1. **Backup Current Data**
   ```bash
   ./scripts/backup-neo4j.sh
   ```

2. **Deploy NAS Services**
   ```bash
   ssh samuraibuddha@192.168.50.10
   cd mcp-toolkit-deployment
   docker-compose -f docker-compose.nas.yml up -d
   ```

3. **Migrate Memory Database**
   ```bash
   ./scripts/migrate-memory.sh
   ```

4. **Update Claude Configs**
   - Replace local configs with network-aware versions
   - Point to Lilith's orchestrator

5. **Test Everything**
   ```bash
   # From any Claude Desktop
   # Try: "What do you remember about our projects?"
   ```

## 🎯 Performance Optimization

### Why This Architecture?
- **Latency**: GPU workloads stay local for minimal latency
- **Sharing**: Databases centralized for cross-node access
- **Backup**: All persistent data on ZFS with snapshots
- **Scaling**: Add more GPU nodes without database duplication

### Resource Allocation
- **Lilith**: High CPU for database operations
- **GPU Nodes**: Maximum GPU/RAM for AI workloads
- **Network**: 1Gbps minimum, 10Gbps recommended

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/awesome-addition`
3. Test on your EVA network
4. Submit pull request

## 📝 License

MIT License - Built for the EVA network community!

---

*Part of the EVA Network Infrastructure - Where AI meets Evangelion! 🤖*

*For standard Claude Desktop deployments, see [mcp-orchestrator](https://github.com/SamuraiBuddha/mcp-orchestrator)*