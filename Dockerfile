FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    nodejs \
    npm \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install mcp-orchestrator-proxy
RUN git clone https://github.com/SamuraiBuddha/mcp-orchestrator-proxy.git /app && \
    pip install -e .

# Install Python-based MCPs from GitHub
RUN git clone https://github.com/SamuraiBuddha/mcp-memory-blockchain.git /tmp/mcp-memory-blockchain && \
    cd /tmp/mcp-memory-blockchain && \
    pip install -e . && \
    cd /app

RUN git clone https://github.com/SamuraiBuddha/mcp-time-precision.git /tmp/mcp-time-precision && \
    cd /tmp/mcp-time-precision && \
    pip install -e . && \
    cd /app

RUN git clone https://github.com/SamuraiBuddha/mcp-freshbooks-blockchain.git /tmp/mcp-freshbooks-blockchain && \
    cd /tmp/mcp-freshbooks-blockchain && \
    pip install -e . && \
    cd /app

# Install Node.js-based MCPs
RUN npm install -g \
    @modelcontextprotocol/server-filesystem \
    @modelcontextprotocol/server-github \
    @modelcontextprotocol/server-docker \
    @modelcontextprotocol/server-sequential-thinking

# Copy configuration
COPY config/registry.json /app/config/

# Expose the orchestrator API port
EXPOSE 8080

# Run the orchestrator proxy
CMD ["python", "-m", "mcp_orchestrator_proxy"]
