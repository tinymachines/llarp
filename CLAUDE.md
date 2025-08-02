# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an OpenWRT configuration management toolkit designed to scan, backup, compare, and apply configurations across multiple OpenWRT routers. The repository contains three main bash scripts that work together to provide comprehensive router fleet management.

## Key Scripts and Commands

### 1. Configuration Scanner
```bash
# Scan a single router
./openwrt-config-scan.sh <router_ip> [output_directory]

# Example
./openwrt-config-scan.sh 192.168.1.1
```

### 2. Configuration Applier
```bash
# Apply configuration from one router to another
./openwrt-config-apply.sh <target_router_ip> <config_directory> [options]

# Options:
#   --dry-run     Preview changes without applying
#   --selective   Choose which configs to apply
#   --no-backup   Skip backup of current config
#   --force       Apply without confirmation

# Example - dry run first
./openwrt-config-apply.sh 192.168.1.2 ./router_configs/router1_config --dry-run
```

### 3. Batch Scanner
```bash
# Scan multiple routers
./openwrt-batch-scanner.sh <router_list_file> [output_directory]

# Create router list first
cat > routers.txt << EOF
192.168.1.1
192.168.1.2
10.0.0.1
EOF

# Run batch scan
./openwrt-batch-scanner.sh routers.txt
```

### Script Permissions
```bash
# Make scripts executable
chmod +x openwrt-*.sh
```

## Architecture and Data Flow

### Script Dependencies
- All scripts require SSH access to routers (root@<router_ip>)
- Scripts use standard OpenWRT UCI commands and filesystem locations
- No external dependencies beyond standard Unix tools (bash, ssh, scp, diff)

### Data Organization
```
router_configs/
├── <hostname>_<ip>_<timestamp>/
│   ├── configs/          # UCI and raw configuration files
│   ├── system/           # Hardware and system information
│   ├── network/          # Network configuration and status
│   ├── logs/             # System and kernel logs
│   ├── services/         # Service status and processes
│   ├── metadata.json     # Scan metadata
│   ├── summary_report.txt # Human-readable summary
│   └── inventory.json    # Machine-readable inventory
└── compare_routers.sh    # Auto-generated comparison script
```

### Key OpenWRT Paths and Commands Used
- UCI configs: `/etc/config/*`
- UCI commands: `uci show`, `uci export`, `uci set`, `uci commit`
- System info: `/proc/cpuinfo`, `/proc/meminfo`, `/etc/openwrt_release`
- Network data: `ip addr`, `ip route`, `iptables-save`, `iw dev`
- Service management: `/etc/init.d/`, `service <name> restart`

### Workflow Pattern
1. Scanner collects complete router state into organized directory structure
2. Configurations are stored as both UCI exports and raw files for maximum compatibility
3. Applier can selectively apply configurations with automatic service restart handling
4. Batch scanner generates network-wide reports and inventories

### SSH Connection Handling
- Scripts use SSH options: `-o ConnectTimeout=10 -o StrictHostKeyChecking=no`
- Assumes SSH key authentication is configured for root@<router_ip>
- Connection testing performed before operations begin

### Error Handling
- Failed commands create `.error` files with error details
- Scripts continue operation on non-critical failures
- Color-coded output indicates success/failure status