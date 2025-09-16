# LLARP - LLM-Assisted Router Automation Platform

LLARP is an AI-powered training and automation system for OpenWRT configuration management. It uses large language models to generate, execute, validate, and store network configuration scripts with automatic rollback capabilities.

## Core Features

- **AI-Driven Configuration Generation**: Natural language to OpenWRT UCI commands via LLM inference
- **Real Hardware Validation**: Execute and test configurations on production OpenWRT devices
- **Automated Quality Assessment**: Ground truth validation with numerical scoring (0.0-1.0)
- **State Management**: Snapshot-based rollback system for safe configuration changes
- **Lego Library**: Automatic storage and categorization of proven configuration scripts
- **Multi-Model Support**: Extensible architecture supporting various LLMs (Mistral, Claude, etc.)

## Architecture

```
User Query → LLM Analysis → Script Generation → Router Execution → Validation → Storage/Rollback
```

### Workflow States
1. **INIT** - Request validation and initialization
2. **DECOMPOSE** - Break complex requests into actionable tasks
3. **SEARCH_KNOWLEDGE** - Query vector database for similar solutions
4. **PLAN** - Create execution plan combining existing and new components
5. **EXECUTE** - Deploy configuration changes to target router
6. **REVIEW** - Validate results against expected outcomes
7. **ARCHIVE** - Store successful configurations as reusable components
8. **COMPLETE** - Return results with quality metrics

## System Requirements

### Software Dependencies
- Python 3.8+
- OpenWRT target device with SSH access
- Ollama with supported language models
- paramiko (SSH client library)
- requests (HTTP client library)

### Hardware Requirements
- OpenWRT router with UCI configuration system
- SSH key-based authentication configured
- Network connectivity between host and router

### Supported Models
- mistral-small3.2:24b (primary)
- mistral-small3.1:24b
- llama3.2:latest (fallback)

## Quick Start

### Installation
```bash
git clone https://github.com/tinymachines/llarp.git
cd llarp
source ~/.pyenv/versions/tinymachines/bin/activate
pip install paramiko requests
```

### Configuration
```bash
# Test connectivity
python3 test_router_connection.py

# View available training scenarios
./llarp-train list

# Execute basic configuration tests
./llarp-train basic
```

### Usage Examples
```bash
# Single configuration request
./llarp-workflow process "Set router hostname to 'production-gw'"

# Complete training suite
./llarp-train full

# Category-specific training
./llarp-train category wireless

# Interactive workflow mode
./llarp-workflow interactive
```

## Training System

### Test Categories
- **basic_system**: Hostname, timezone, logging configuration
- **network_basic**: IP addressing, routing, VLAN management
- **wireless**: WiFi networks, radio configuration, guest access
- **firewall**: Rules, port forwarding, access control
- **dhcp_dns**: DHCP ranges, static leases, DNS configuration
- **ssh_security**: Authentication, port configuration, hardening
- **package_management**: Software installation and configuration
- **monitoring_diagnostics**: SNMP, logging, connectivity testing
- **advanced_networking**: Bridging, QoS, complex topologies

### Quality Metrics
- **Success Rate**: Percentage of tests achieving expected outcomes
- **Quality Score**: Numerical assessment of configuration correctness (0.0-1.0)
- **Execution Time**: Duration from request to completion
- **Validation Results**: Detailed comparison of expected vs. actual outcomes

## Project Structure

```
llarp/
├── llarp-ai/                    # Core AI training system
│   ├── workflow_engine.py       # State machine implementation
│   ├── llarp_trainer.py         # Training orchestration
│   ├── knowledge_bridge.py      # Vector search integration
│   └── training_queries.json    # Test scenario definitions
├── llarp-scripts/               # Proven configuration scripts
├── docs/                        # Documentation
├── llarp-train                  # Training execution CLI
├── llarp-workflow              # General workflow CLI
└── test_*.py                   # Validation and testing tools
```

## Configuration Management

### Router Connection
Default configuration expects:
- Router IP: 192.168.100.1
- User: root
- Authentication: SSH key-based
- Port: 22

### Training Parameters
- Default timeout: 300 seconds per test
- Quality threshold for lego storage: 0.8
- Maximum retry attempts: 3
- State snapshot retention: Full UCI configuration backup

## Results and Metrics

### Training Output
Results are stored in JSON format with the following structure:
```json
{
  "timestamp": "2025-09-15T20:43:37.162319",
  "router_ip": "192.168.100.1",
  "total_tests": 25,
  "results": [
    {
      "test_id": "SYS001",
      "query": "Change the router hostname to 'llarp-test'",
      "status": "SUCCESS|FAILED|PARTIAL",
      "execution_time": 167.71,
      "ground_truth_score": 0.8,
      "generated_script": "...",
      "validation_result": {...}
    }
  ]
}
```

### Performance Benchmarks
Based on initial training run (25 tests, mistral-small3.2:24b):
- Success rate: 48%
- Average execution time: 221 seconds
- Average quality score: 0.40/1.0
- Lego generation rate: 12% (3 of 25 tests)

## Legacy Tools

LLARP also includes traditional OpenWRT management scripts:
- `openwrt-config-scan.sh` - Configuration backup and analysis
- `openwrt-config-apply.sh` - Configuration deployment
- `openwrt-batch-scanner.sh` - Multi-router management
- USB storage and network routing utilities

See `docs/USAGE_GUIDE.md` for comprehensive documentation.

## Development

### Testing
```bash
# Component testing
python3 test_tag_stripping.py
python3 test_mistral_integration.py

# End-to-end validation
python3 test_single_scenario.py

# Full system test
./llarp-train test
```

### Extending Training Scenarios
Add new test cases to `llarp-ai/training_queries.json`:
```json
{
  "id": "NEW001",
  "query": "Configuration request in natural language",
  "category": "system|network|wireless|firewall|etc",
  "difficulty": "basic|intermediate|advanced|expert",
  "expected_commands": ["uci command 1", "uci command 2"],
  "validation": {
    "check_command": "uci get system.@system[0].parameter",
    "expected_output": "expected_value"
  }
}
```

## License

MIT License - see LICENSE file for details.

## Contributing

See CONTRIBUTING.md for development guidelines and submission process.