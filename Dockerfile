FROM python:3.10-slim

# Fix for externally-managed-environment error
ENV PIP_BREAK_SYSTEM_PACKAGES=1

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
# NOTE: Blockchain MCPs temporarily removed - will be added back later

RUN git clone https://github.com/SamuraiBuddha/mcp-time-precision.git /tmp/mcp-time-precision && \
    cd /tmp/mcp-time-precision && \
    pip install -e . && \
    cd /app

# NOTE: Node.js MCPs removed temporarily - need to verify correct package names
# The orchestrator proxy can still discover and route to MCPs installed elsewhere

# Copy configuration
COPY config/registry.json /app/config/

# Expose the orchestrator API port
EXPOSE 8080

# Run the orchestrator proxy
CMD ["python", "-m", "mcp_orchestrator_proxy"]
