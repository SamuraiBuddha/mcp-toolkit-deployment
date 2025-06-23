# Docker Hub Container Images for MCP Tools on Lilith (192.168.50.10)

This comprehensive guide provides official Docker Hub container images and configurations for building a complete MCP (Model Context Protocol) tool environment. All containers are production-ready and designed to work together on a single host deployment.

## Memory and Database Systems

### Neo4j (Graph Database for Memory MCP)

**Official Pull Commands:**
```bash
docker pull neo4j:2025.05.0           # Latest stable community edition
docker pull neo4j:2025.05.0-enterprise # Enterprise edition
docker pull neo4j:latest              # Always latest version
```

**Configuration:**
- **Ports**: 7474 (HTTP), 7473 (HTTPS), 7687 (Bolt protocol)
- **Latest Stable**: 2025.05.0
- **Memory Settings**:
  ```yaml
  NEO4J_server_memory_pagecache_size: 4G
  NEO4J_server_memory_heap_max__size: 4G
  ```
- **Volumes**:
  - `/data` - Database files
  - `/logs` - Log files
  - `/conf` - Configuration
  - `/import` - Data import directory
  - `/plugins` - Plugin directory

### MongoDB (Document Store)

**Official Pull Commands:**
```bash
docker pull mongo:7.0     # Latest stable version
docker pull mongo:latest  # Current latest
```

**Configuration:**
- **Port**: 27017
- **Authentication**:
  ```yaml
  MONGO_INITDB_ROOT_USERNAME: admin
  MONGO_INITDB_ROOT_PASSWORD: password
  MONGO_INITDB_DATABASE: mcp_database
  ```
- **Volumes**: `/data/db` for persistence

### Redis (In-Memory Cache)

**Official Pull Commands:**
```bash
docker pull redis:7.2.3        # Specific stable version
docker pull redis:alpine3.16   # Lightweight Alpine variant
```

**Configuration:**
- **Port**: 6379
- **Memory Policy**: `REDIS_MAXMEMORY_POLICY=allkeys-lru`
- **Persistence**: AOF and RDB supported
- **Volume**: `/data`

## Container Management and UI Tools

### Portainer CE

**Official Pull Commands:**
```bash
docker pull portainer/portainer-ce:latest
docker pull portainer/portainer-ce:lts    # Long-term support
```

**Configuration:**
- **Ports**: 9443 (HTTPS UI), 8000 (Edge agent tunnel)
- **Volumes**:
  - `/var/run/docker.sock:/var/run/docker.sock` - Docker socket
  - `portainer_data:/data` - Persistent data

**Run Command:**
```bash
docker run -d -p 8000:8000 -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
```

### ComfyUI (AI/ML Interface)

**Recommended Images:**
```bash
docker pull yanwk/comfyui-boot:cu124-slim     # CUDA 12.4 slim version
docker pull yanwk/comfyui-boot:cu124          # Full version
docker pull ghcr.io/ai-dock/comfyui:latest    # AI-Dock version
```

**Configuration:**
- **Port**: 8188
- **GPU Requirements**: NVIDIA GPU with 6GB+ VRAM
- **Volumes**:
  - `/root` or `/workspace` - Main working directory
  - `/models` - AI model storage
  - `/output` - Generated outputs
- **GPU Access**:
  ```yaml
  deploy:
    resources:
      reservations:
        devices:
          - driver: nvidia
            count: all
            capabilities: [gpu]
  ```

## Development Tools

### Node.js Official Images

**Pull Commands:**
```bash
# LTS Versions
docker pull node:20              # Latest Node.js 20.x
docker pull node:18              # Latest Node.js 18.x
docker pull node:20-alpine       # Lightweight Alpine variant
docker pull node:20-slim         # Debian slim variant

# Specific versions
docker pull node:20.18.0-bullseye
docker pull node:18.20.4-alpine3.20
```

**Best Practices:**
- Use `node:20-slim` for production (smaller, Debian-based)
- Use `node:20-alpine` for minimal size (musl libc, may have compatibility issues)
- Use `node:20` only if building native modules

### GitHub Integration Tools

**Gitea (Lightweight Git Service):**
```bash
docker pull gitea/gitea:latest
```
- **Ports**: 3000 (web), 22 (SSH)
- **Volumes**: `/data`, `/etc/gitea`

**Act (GitHub Actions Runner):**
```bash
docker pull nektos/act:latest
```

### Code Development Environments

**code-server (VS Code in Browser):**
```bash
docker pull codercom/code-server:latest
```
- **Port**: 8080
- **Volume**: `/home/coder/project`

### Filesystem and Storage Tools

**MinIO (S3-Compatible Storage):**
```bash
docker pull minio/minio:latest
```
- **Ports**: 9000 (API), 9001 (Console)
- **Volumes**: `/data`

**FileBrowser:**
```bash
docker pull filebrowser/filebrowser:latest
```
- **Port**: 80
- **Volume**: `/srv` (files to browse)

**Syncthing:**
```bash
docker pull syncthing/syncthing:latest
```
- **Ports**: 8384 (Web UI), 22000 (Sync protocol)

## Orchestration and Time Tools

### Apache Airflow

**Official Pull Commands:**
```bash
docker pull apache/airflow:latest         # Latest version
docker pull apache/airflow:3.0.2          # Specific version
docker pull apache/airflow:slim-latest    # Slim variant
```

**Configuration:**
- **Ports**: 8080 (Web UI)
- **Services Required**: PostgreSQL, Redis
- **Volumes**: `/opt/airflow/dags`, `/opt/airflow/logs`

### Message Queue Systems

**RabbitMQ:**
```bash
docker pull rabbitmq:3-management
```
- **Ports**: 5672 (AMQP), 15672 (Management UI)

**Apache Kafka:**
```bash
docker pull confluentinc/cp-kafka:latest
```
- **Port**: 9092

### Time Synchronization

**Chrony NTP:**
```bash
docker pull cturra/ntp:latest
```
- **Port**: 123/udp

## Complete Docker Compose Configuration

Here's a production-ready `docker-compose.yml` for MCP tools on Lilith:

```yaml
version: '3.8'

networks:
  mcp_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16

volumes:
  neo4j_data:
  neo4j_logs:
  mongodb_data:
  redis_data:
  portainer_data:
  comfyui_data:
  minio_data:

services:
  # Reverse Proxy
  traefik:
    image: traefik:v3.1
    container_name: traefik
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik:/etc/traefik
    networks:
      - mcp_network
    command:
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"

  # Neo4j Memory System
  neo4j:
    image: neo4j:2025.05.0
    container_name: neo4j
    restart: unless-stopped
    ports:
      - "7474:7474"
      - "7687:7687"
    environment:
      - NEO4J_AUTH=neo4j/secure_password_here
      - NEO4J_server_memory_pagecache_size=2G
      - NEO4J_server_memory_heap_max__size=2G
    volumes:
      - neo4j_data:/data
      - neo4j_logs:/logs
    networks:
      - mcp_network
    healthcheck:
      test: ["CMD", "cypher-shell", "-u", "neo4j", "-p", "secure_password_here", "RETURN 1"]
      interval: 30s
      timeout: 10s
      retries: 3

  # MongoDB Document Store
  mongodb:
    image: mongo:7.0
    container_name: mongodb
    restart: unless-stopped
    ports:
      - "27017:27017"
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=secure_password
      - MONGO_INITDB_DATABASE=mcp
    volumes:
      - mongodb_data:/data/db
    networks:
      - mcp_network
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Redis Cache
  redis:
    image: redis:7.2.3-alpine
    container_name: redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes --maxmemory 2gb --maxmemory-policy allkeys-lru
    volumes:
      - redis_data:/data
    networks:
      - mcp_network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 3

  # Portainer Management
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    ports:
      - "9443:9443"
      - "8000:8000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    networks:
      - mcp_network

  # ComfyUI
  comfyui:
    image: yanwk/comfyui-boot:cu124-slim
    container_name: comfyui
    restart: unless-stopped
    ports:
      - "8188:8188"
    volumes:
      - comfyui_data:/root
      - ./models:/root/ComfyUI/models
      - ./output:/root/ComfyUI/output
    environment:
      - CLI_ARGS=""
    networks:
      - mcp_network
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]

  # Node.js MCP Server
  mcp-server:
    image: node:20-slim
    container_name: mcp-server
    restart: unless-stopped
    ports:
      - "3000:3000"
    working_dir: /app
    volumes:
      - ./mcp-server:/app
      - /app/node_modules
    environment:
      - NODE_ENV=production
      - NEO4J_URI=bolt://neo4j:7687
      - NEO4J_USER=neo4j
      - NEO4J_PASSWORD=secure_password_here
      - REDIS_URL=redis://redis:6379
      - MONGODB_URI=mongodb://admin:secure_password@mongodb:27017/mcp?authSource=admin
    networks:
      - mcp_network
    command: npm start
    depends_on:
      neo4j:
        condition: service_healthy
      redis:
        condition: service_healthy
      mongodb:
        condition: service_healthy

  # MinIO Object Storage
  minio:
    image: minio/minio:latest
    container_name: minio
    restart: unless-stopped
    ports:
      - "9000:9000"
      - "9001:9001"
    environment:
      - MINIO_ROOT_USER=minioadmin
      - MINIO_ROOT_PASSWORD=minioadmin
    volumes:
      - minio_data:/data
    networks:
      - mcp_network
    command: server /data --console-address ":9001"

  # Apache Airflow (Optional Orchestrator)
  airflow-webserver:
    image: apache/airflow:latest
    container_name: airflow
    restart: unless-stopped
    ports:
      - "8081:8080"
    environment:
      - AIRFLOW__CORE__EXECUTOR=LocalExecutor
      - AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres/airflow
    networks:
      - mcp_network
    depends_on:
      - postgres
    command: webserver

  # PostgreSQL for Airflow
  postgres:
    image: postgres:13
    container_name: postgres
    restart: unless-stopped
    environment:
      - POSTGRES_USER=airflow
      - POSTGRES_PASSWORD=airflow
      - POSTGRES_DB=airflow
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - mcp_network

volumes:
  postgres_data:
```

## Deployment Instructions

1. **Create Directory Structure:**
```bash
mkdir -p ~/mcp-docker/{mcp-server,models,output,traefik}
cd ~/mcp-docker
```

2. **Create .env File:**
```bash
cat > .env << EOF
# Database Passwords
NEO4J_PASSWORD=your_secure_neo4j_password
MONGO_PASSWORD=your_secure_mongo_password
REDIS_PASSWORD=your_secure_redis_password

# Service Configuration
COMPOSE_PROJECT_NAME=mcp
NODE_ENV=production
EOF
```

3. **Deploy Stack:**
```bash
docker-compose up -d
```

4. **Access Services:**
- Portainer: https://192.168.50.10:9443
- Neo4j Browser: http://192.168.50.10:7474
- ComfyUI: http://192.168.50.10:8188
- MCP Server: http://192.168.50.10:3000
- MinIO Console: http://192.168.50.10:9001

## Network Configuration for Multiple Claude Instances

To allow multiple Claude instances to access these services:

1. **Internal DNS**: Add entries to your DNS server or hosts files:
```
192.168.50.10 lilith.local
192.168.50.10 neo4j.lilith.local
192.168.50.10 mcp.lilith.local
```

2. **Firewall Rules**: Ensure ports are accessible from Claude client machines
3. **SSL/TLS**: Use Traefik with Let's Encrypt for secure connections

## Resource Requirements

- **CPU**: Minimum 8 cores recommended
- **RAM**: 32GB minimum (Neo4j: 4GB, ComfyUI: 8GB, others: 16GB)
- **Storage**: 500GB+ SSD recommended
- **GPU**: NVIDIA GPU with 8GB+ VRAM for ComfyUI

This configuration provides a robust, scalable foundation for running MCP tools in a containerized environment accessible by multiple Claude instances.