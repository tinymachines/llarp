# LLARP Usage Guide

This guide provides comprehensive documentation for using the LLARP (LLM-Assisted Router Automation Platform) system.

## Table of Contents

1. [System Setup](#system-setup)
2. [Training System](#training-system)
3. [Workflow Engine](#workflow-engine)
4. [Legacy Tools](#legacy-tools)
5. [Configuration Reference](#configuration-reference)
6. [Troubleshooting](#troubleshooting)
7. [API Reference](#api-reference)

## System Setup

### Prerequisites

#### Software Requirements
- Python 3.8 or higher
- Ollama with language model support
- Git for repository management
- SSH client with key-based authentication

#### Python Environment Setup
```bash
# Clone repository
git clone https://github.com/tinymachines/llarp.git
cd llarp

# Activate virtual environment
source ~/.pyenv/versions/tinymachines/bin/activate

# Install dependencies
pip install paramiko requests
```

#### Ollama Configuration
```bash
# Install required models
ollama pull mistral-small3.2:24b
ollama pull nomic-embed-text

# Verify installation
curl http://127.0.0.1:11434/api/tags
```

#### Router Configuration
- SSH key authentication configured for root user
- UCI configuration system available
- Network connectivity between host and router
- Sufficient permissions for configuration changes

### Initial Validation

#### Connectivity Test
```bash
python3 test_router_connection.py
```
Expected output:
```
Router Connection Test
SSH to router: ✓ OK
Ollama + Mistral: ✓ OK
All systems ready for LLARP training!
```

#### System Component Test
```bash
python3 test_tag_stripping.py
python3 test_mistral_integration.py
```

## Training System

### Overview
The training system executes predefined test scenarios against OpenWRT routers, validating AI-generated configurations against ground truth expectations.

### Command Line Interface

#### Basic Usage
```bash
./llarp-train [command] [options]
```

#### Available Commands
- `list` - Display all available test scenarios
- `basic` - Execute basic difficulty tests only
- `intermediate` - Execute intermediate difficulty tests
- `advanced` - Execute advanced difficulty tests
- `category <name>` - Execute tests for specific category
- `full` - Execute complete training suite

#### Command Options
- `--router <ip>` - Specify router IP address (default: 192.168.100.1)
- `--ssh-key <path>` - Path to SSH private key file
- `--dry-run` - Show execution plan without running tests

### Training Categories

#### Basic System (basic_system)
- SYS001: Hostname modification
- SYS002: Timezone configuration
- SYS003: System logging setup

```bash
./llarp-train category basic_system
```

#### Network Basic (network_basic)
- NET001: LAN IP address configuration
- NET002: Static route configuration
- NET003: VLAN interface creation

```bash
./llarp-train category network_basic
```

#### Wireless (wireless)
- WIFI001: Basic WiFi network creation
- WIFI002: Radio configuration (channel, bandwidth)
- WIFI003: Guest network with isolation

```bash
./llarp-train category wireless
```

#### Firewall (firewall)
- FW001: SSH access from WAN
- FW002: HTTP port forwarding
- FW003: IP range blocking

```bash
./llarp-train category firewall
```

#### DHCP/DNS (dhcp_dns)
- DHCP001: DHCP range configuration
- DHCP002: Static DHCP lease
- DNS001: Custom DNS server configuration

```bash
./llarp-train category dhcp_dns
```

#### SSH Security (ssh_security)
- SSH001: Disable password authentication
- SSH002: Change SSH port

```bash
./llarp-train category ssh_security
```

### Training Execution

#### Single Category Training
```bash
# Execute wireless-specific tests
./llarp-train category wireless

# Execute with specific router
./llarp-train category firewall --router 10.0.1.1

# Dry run to preview actions
./llarp-train category network_basic --dry-run
```

#### Complete Training Suite
```bash
# Execute all 25 test scenarios
./llarp-train full

# With custom SSH key
./llarp-train full --ssh-key ~/.ssh/openwrt_key
```

#### Training Results Analysis
Training results are stored in JSON format with timestamp:
```bash
# View latest results
ls -la llarp_training_results_*.json

# Analyze results with Python
python3 -c "
import json
with open('llarp_training_results_YYYYMMDD_HHMMSS.json') as f:
    data = json.load(f)
    print(f'Success rate: {len([r for r in data[\"results\"] if \"SUCCESS\" in r[\"status\"]])/len(data[\"results\"])*100:.1f}%')
"
```

## Workflow Engine

### Overview
The workflow engine processes individual natural language requests through an 8-state machine, generating and executing OpenWRT configurations.

### Command Line Interface

#### Basic Usage
```bash
./llarp-workflow [command] [options]
```

#### Available Commands
- `process "<request>"` - Process single natural language request
- `interactive` - Enter interactive mode for ongoing conversation
- `test-models` - Test and select optimal Ollama models

#### Single Request Processing
```bash
# Process configuration request
./llarp-workflow process "Set router hostname to 'production-gateway'"

# Network configuration
./llarp-workflow process "Configure WiFi network 'CorpNet' with WPA2"

# Security configuration
./llarp-workflow process "Enable firewall rule for SSH from 192.168.1.0/24"
```

#### Interactive Mode
```bash
./llarp-workflow interactive
```
Interactive session example:
```
LLARP Workflow Engine - Interactive Mode
Enter your request (or 'quit' to exit): Configure static IP 192.168.5.1
[Workflow execution and results display]
Enter your request (or 'quit' to exit): quit
```

### Workflow States

#### State Progression
1. **INIT** - Validate input and initialize context
2. **DECOMPOSE** - Break request into actionable tasks using LLM
3. **SEARCH_KNOWLEDGE** - Query knowledge base for similar solutions
4. **PLAN** - Create execution plan combining existing and new components
5. **EXECUTE** - Generate scripts and execute on router
6. **REVIEW** - Validate results against expected outcomes
7. **ARCHIVE** - Store successful configurations as legos
8. **COMPLETE** - Return results with metrics

#### State Transition Monitoring
```bash
# Enable verbose output to see state transitions
export LLARP_VERBOSE=1
./llarp-workflow process "Create guest WiFi network"
```

## Legacy Tools

### Configuration Management Scripts

#### Router Scanning
```bash
# Scan single router
./openwrt-config-scan.sh 192.168.1.1

# Scan with custom output directory
./openwrt-config-scan.sh 192.168.1.1 /backup/routers
```

#### Configuration Application
```bash
# Apply configuration (dry run first)
./openwrt-config-apply.sh 192.168.1.2 ./configs/router1_backup --dry-run

# Apply with selective mode
./openwrt-config-apply.sh 192.168.1.2 ./configs/router1_backup --selective

# Force application without confirmation
./openwrt-config-apply.sh 192.168.1.2 ./configs/router1_backup --force
```

#### Batch Operations
```bash
# Create router list
echo -e "192.168.1.1\n192.168.1.2\n192.168.1.3" > routers.txt

# Batch scan
./openwrt-batch-scanner.sh routers.txt
```

### Network Routing Scripts

#### Inter-Router Communication Setup
```bash
# Configure routing between network segments
./configure-inter-router-communication.sh

# Verify connectivity
./verify-inter-router-communication.sh

# Rollback changes if needed
./rollback-inter-router-communication.sh
```

### USB Storage Scripts

#### Storage Setup
```bash
# Configure USB storage mounting
./setup-usb-storage-zephyr.sh

# Enable package installation to USB
./setup-usb-packages-zephyr.sh
```

## Configuration Reference

### Default Parameters

#### Router Connection Settings
```json
{
  "router_ip": "192.168.100.1",
  "ssh_user": "root",
  "ssh_port": 22,
  "connection_timeout": 10,
  "command_timeout": 30
}
```

#### Training Settings
```json
{
  "quality_threshold": 0.8,
  "max_execution_time": 300,
  "retry_attempts": 3,
  "snapshot_retention": "full_uci_backup"
}
```

#### Model Configuration
```json
{
  "primary_model": "mistral-small3.2:24b",
  "fallback_model": "llama3.2:latest",
  "embedding_model": "nomic-embed-text",
  "temperature": 0.1,
  "top_p": 0.9
}
```

### Environment Variables

#### System Configuration
```bash
export LLARP_ROUTER_IP="192.168.100.1"
export LLARP_SSH_KEY="~/.ssh/openwrt_key"
export LLARP_VERBOSE=1
export LLARP_MODEL="mistral-small3.2:24b"
```

#### Ollama Configuration
```bash
export OLLAMA_HOST="127.0.0.1:11434"
export OLLAMA_MODELS_PATH="/usr/share/ollama/.ollama/models"
```

### Custom Test Scenarios

#### Adding New Test Cases
Edit `llarp-ai/training_queries.json`:
```json
{
  "id": "CUSTOM001",
  "query": "Configure NTP server to pool.ntp.org",
  "category": "system",
  "subcategory": "time_sync",
  "difficulty": "intermediate",
  "expected_commands": [
    "uci set system.ntp=timeserver",
    "uci set system.ntp.enabled='1'",
    "uci add_list system.ntp.server='pool.ntp.org'",
    "uci commit system"
  ],
  "validation": {
    "check_command": "uci get system.ntp.enabled",
    "expected_output": "1"
  },
  "rollback": {
    "commands": [
      "uci set system.ntp.enabled='0'",
      "uci commit system"
    ]
  }
}
```

## Troubleshooting

### Common Issues

#### SSH Connection Failures
```bash
# Test manual SSH connection
ssh -i ~/.ssh/openwrt_key root@192.168.100.1

# Check SSH key permissions
chmod 600 ~/.ssh/openwrt_key

# Verify router SSH configuration
ssh root@192.168.100.1 "uci get dropbear.@dropbear[0].PasswordAuth"
```

#### Ollama Model Issues
```bash
# Check Ollama service status
curl http://127.0.0.1:11434/api/tags

# Restart Ollama service
systemctl restart ollama

# Verify model availability
ollama list
```

#### Training Failures
```bash
# Check router connectivity
ping 192.168.100.1

# Verify UCI system functionality
ssh root@192.168.100.1 "uci show system"

# Review training logs
tail -f llarp_training_results_*.json
```

### Performance Optimization

#### Model Response Time
- Use model caching for repeated queries
- Optimize prompt templates to reduce token count
- Consider using smaller models for simple tasks

#### Training Efficiency
- Run tests in parallel where dependencies allow
- Use category-specific training for focused improvements
- Implement smart retry logic with exponential backoff

### Debugging Tools

#### Verbose Logging
```bash
export LLARP_DEBUG=1
export LLARP_LOG_LEVEL=DEBUG
./llarp-train basic
```

#### Component Testing
```bash
# Test individual components
python3 test_router_connection.py
python3 test_mistral_integration.py
python3 test_single_scenario.py
```

## API Reference

### Python API Usage

#### Direct Training System Access
```python
from llarp_trainer import LLARPTrainer

# Initialize trainer
trainer = LLARPTrainer(router_ip="192.168.100.1")

# Run single test
result = trainer.run_single_test({
    "id": "TEST001",
    "query": "Set timezone to UTC",
    "validation": {"check_command": "uci get system.@system[0].zonename"}
})

print(f"Success: {result.status}")
print(f"Score: {result.ground_truth_score}")
```

#### Workflow Engine Integration
```python
from workflow_engine import WorkflowEngine

# Initialize engine
engine = WorkflowEngine()

# Process request
result = engine.run_workflow("Configure DHCP range 192.168.1.100-200")

if result['success']:
    print("Configuration applied successfully")
    print(f"Execution time: {result.get('duration', 0):.1f}s")
else:
    print(f"Failed: {result.get('error_message')}")
```

### REST API (Future Enhancement)
The system is designed to support REST API endpoints for remote training and workflow execution. Implementation planned for future releases.

## Performance Benchmarks

### Training Metrics (25 test baseline)
- Success rate: 48%
- Average execution time: 221 seconds per test
- Quality score distribution: 0.40 average (0.0-1.0 scale)
- Lego generation rate: 12% (3 high-quality scripts)

### Model Performance
- mistral-small3.2:24b: 48% success rate, 3.7min average response
- llama3.2:latest: 35% success rate, 2.1min average response (estimated)

### System Resource Usage
- Memory: ~500MB peak during training
- CPU: Variable based on model inference
- Network: Minimal, SSH command execution only
- Storage: ~1MB per training session (results + logs)