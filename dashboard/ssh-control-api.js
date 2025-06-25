#!/usr/bin/env node

/**
 * EVA Network SSH Control API
 * Runs on Melchior to provide SSH access to all EVA nodes
 */

const express = require('express');
const { Client } = require('ssh2');
const path = require('path');
const fs = require('fs');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3333;

// Middleware
app.use(express.json());
app.use(cors());
app.use(express.static(path.join(__dirname, '../dashboard')));

// SSH Key Path (adjust for your setup)
const SSH_KEY_PATH = process.env.SSH_KEY_PATH || path.join(process.env.HOME, '.ssh/id_rsa');

// Node configurations
const nodeConfigs = {
    '192.168.50.10': { name: 'Lilith', user: 'samuraibuddha' },
    '192.168.50.11': { name: 'Adam', user: 'samuraibuddha' },
    '192.168.50.20': { name: 'Balthazar', user: 'samuraibuddha' },
    '192.168.50.21': { name: 'Caspar', user: 'samuraibuddha' },
    '192.168.50.30': { name: 'Melchior', user: 'samuraibuddha' }
};

// SSH Command Executor
function executeSSHCommand(host, command, user) {
    return new Promise((resolve, reject) => {
        const conn = new Client();
        let output = '';
        let errorOutput = '';
        
        conn.on('ready', () => {
            console.log(`SSH Connected to ${host}`);
            
            conn.exec(command, (err, stream) => {
                if (err) {
                    conn.end();
                    return reject(err);
                }
                
                stream.on('close', (code, signal) => {
                    conn.end();
                    if (code === 0) {
                        resolve({ 
                            success: true, 
                            output: output.trim(),
                            error: errorOutput.trim(),
                            code: code
                        });
                    } else {
                        resolve({ 
                            success: false, 
                            output: output.trim(),
                            error: errorOutput.trim() || `Command exited with code ${code}`,
                            code: code
                        });
                    }
                });
                
                stream.on('data', (data) => {
                    output += data.toString();
                });
                
                stream.stderr.on('data', (data) => {
                    errorOutput += data.toString();
                });
            });
        });
        
        conn.on('error', (err) => {
            reject({ success: false, error: err.message });
        });
        
        // Connect with SSH key
        try {
            const privateKey = fs.readFileSync(SSH_KEY_PATH);
            conn.connect({
                host: host,
                port: 22,
                username: user || nodeConfigs[host]?.user || 'samuraibuddha',
                privateKey: privateKey,
                readyTimeout: 10000,
                keepaliveInterval: 5000
            });
        } catch (err) {
            reject({ success: false, error: `Failed to read SSH key: ${err.message}` });
        }
    });
}

// API Routes

// Execute SSH command
app.post('/api/ssh', async (req, res) => {
    const { host, command, user } = req.body;
    
    if (!host || !command) {
        return res.status(400).json({ 
            success: false, 
            error: 'Host and command are required' 
        });
    }
    
    try {
        console.log(`Executing command on ${host}: ${command}`);
        const result = await executeSSHCommand(host, command, user);
        res.json(result);
    } catch (error) {
        console.error(`SSH Error:`, error);
        res.status(500).json({ 
            success: false, 
            error: error.message || 'SSH execution failed' 
        });
    }
});

// Batch execute commands
app.post('/api/ssh/batch', async (req, res) => {
    const { commands } = req.body;
    
    if (!Array.isArray(commands)) {
        return res.status(400).json({ 
            success: false, 
            error: 'Commands must be an array' 
        });
    }
    
    const results = [];
    
    for (const cmd of commands) {
        try {
            const result = await executeSSHCommand(cmd.host, cmd.command, cmd.user);
            results.push({ ...cmd, result });
        } catch (error) {
            results.push({ 
                ...cmd, 
                result: { success: false, error: error.message } 
            });
        }
    }
    
    res.json({ success: true, results });
});

// Node status check
app.get('/api/nodes/status', async (req, res) => {
    const statuses = {};
    
    for (const [ip, config] of Object.entries(nodeConfigs)) {
        try {
            const result = await executeSSHCommand(ip, 'echo "OK" && uptime', config.user);
            statuses[ip] = {
                name: config.name,
                online: result.success,
                uptime: result.success ? result.output.split('\n')[1] : null
            };
        } catch (error) {
            statuses[ip] = {
                name: config.name,
                online: false,
                error: error.message
            };
        }
    }
    
    res.json({ success: true, nodes: statuses });
});

// Docker service status
app.post('/api/docker/status', async (req, res) => {
    const { host, service } = req.body;
    
    if (!host) {
        return res.status(400).json({ 
            success: false, 
            error: 'Host is required' 
        });
    }
    
    const command = service 
        ? `docker ps -a --filter "name=${service}" --format "json"`
        : `docker ps -a --format "json"`;
    
    try {
        const result = await executeSSHCommand(host, command);
        if (result.success) {
            // Parse JSON output lines
            const containers = result.output
                .split('\n')
                .filter(line => line.trim())
                .map(line => {
                    try {
                        return JSON.parse(line);
                    } catch (e) {
                        return null;
                    }
                })
                .filter(Boolean);
            
            res.json({ success: true, containers });
        } else {
            res.json(result);
        }
    } catch (error) {
        res.status(500).json({ 
            success: false, 
            error: error.message 
        });
    }
});

// Deploy services
app.post('/api/deploy', async (req, res) => {
    const { host, type } = req.body;
    
    if (!host || !type) {
        return res.status(400).json({ 
            success: false, 
            error: 'Host and type are required' 
        });
    }
    
    let command;
    switch (type) {
        case 'nas':
            command = 'cd /storage/mcp-toolkit && docker-compose -f docker-compose.nas.yml up -d';
            break;
        case 'gpu':
            command = 'cd /storage/mcp-toolkit && docker-compose -f docker-compose.local.yml up -d';
            break;
        case 'update':
            command = 'cd /storage/mcp-toolkit && git pull && docker-compose pull';
            break;
        default:
            return res.status(400).json({ 
                success: false, 
                error: 'Invalid deployment type' 
            });
    }
    
    try {
        const result = await executeSSHCommand(host, command);
        res.json(result);
    } catch (error) {
        res.status(500).json({ 
            success: false, 
            error: error.message 
        });
    }
});

// Memory migration endpoint
app.post('/api/migrate/memory', async (req, res) => {
    const commands = [
        {
            host: '192.168.50.30', // Melchior
            command: 'docker exec neo4j-memory neo4j-admin dump --database=neo4j --to=/backup/neo4j-backup.dump'
        },
        {
            host: '192.168.50.30',
            command: 'scp /var/lib/docker/volumes/neo4j_data/_data/backup/neo4j-backup.dump samuraibuddha@192.168.50.10:/tmp/'
        },
        {
            host: '192.168.50.10', // Lilith
            command: 'docker exec neo4j-memory neo4j-admin load --database=neo4j --from=/tmp/neo4j-backup.dump --force'
        }
    ];
    
    const results = [];
    for (const cmd of commands) {
        try {
            const result = await executeSSHCommand(cmd.host, cmd.command);
            results.push({ command: cmd.command, result });
            
            if (!result.success) {
                break; // Stop on first failure
            }
        } catch (error) {
            results.push({ 
                command: cmd.command, 
                result: { success: false, error: error.message } 
            });
            break;
        }
    }
    
    res.json({ 
        success: results.every(r => r.result.success), 
        steps: results 
    });
});

// Health check
app.get('/api/health', (req, res) => {
    res.json({ 
        success: true, 
        service: 'EVA Network SSH Control API',
        uptime: process.uptime(),
        memory: process.memoryUsage()
    });
});

// Serve dashboard
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../dashboard/eva-command-center.html'));
});

// Error handling
app.use((err, req, res, next) => {
    console.error('Server error:', err);
    res.status(500).json({ 
        success: false, 
        error: 'Internal server error' 
    });
});

// Start server
app.listen(PORT, () => {
    console.log(`EVA Network SSH Control API running on http://localhost:${PORT}`);
    console.log(`Dashboard available at http://localhost:${PORT}/`);
    console.log(`Using SSH key from: ${SSH_KEY_PATH}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down gracefully...');
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('SIGINT received, shutting down gracefully...');
    process.exit(0);
});
