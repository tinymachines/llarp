# Configuration Management Scripts

Detailed documentation for OpenWRT configuration scanning, backup, and application scripts.

## Script Overview

| Script | Purpose | Use Case |
|--------|---------|----------|
| `openwrt-config-scan.sh` | Scan and backup single router | Regular backups, troubleshooting |
| `openwrt-config-apply.sh` | Apply configuration to router | Clone settings, restore configs |
| `openwrt-batch-scanner.sh` | Scan multiple routers | Fleet management, inventory |

## openwrt-config-scan.sh

### Description
Comprehensive configuration scanner that collects all router settings, system information, and network configuration.

### Usage
```bash
./openwrt-config-scan.sh <router_ip> [output_directory]
```

### Parameters
- `router_ip` - IP address or hostname of the router
- `output_directory` - Optional custom output location (default: `./router_configs`)

### Output Structure
```
router_configs/
└── <hostname>_<ip>_<timestamp>/
    ├── configs/              # UCI and raw configuration files
    │   ├── uci_network.conf
    │   ├── uci_wireless.conf
    │   ├── uci_firewall.conf
    │   └── ...
    ├── system/               # Hardware and system information
    │   ├── kernel_version.txt
    │   ├── openwrt_release.txt
    │   ├── cpuinfo.txt
    │   └── ...
    ├── network/              # Network configuration and status
    │   ├── ip_addresses.txt
    │   ├── routes.txt
    │   ├── arp_table.txt
    │   └── ...
    ├── logs/                 # System and kernel logs
    │   ├── system_log.txt
    │   └── kernel_log.txt
    ├── services/             # Service status and processes
    │   ├── running_processes.txt
    │   └── enabled_services.txt
    ├── metadata.json         # Scan metadata with timestamps
    ├── summary_report.txt    # Human-readable summary
    └── inventory.json        # Machine-readable inventory
```

### Collected Data

#### Configuration Files
- UCI configurations (network, wireless, firewall, dhcp, system)
- Raw `/etc/config/*` files
- Custom configuration files

#### System Information
- Kernel version
- OpenWRT release
- CPU information
- Memory information
- Disk usage
- Installed packages
- Board information

#### Network Data
- IP addresses
- Routing tables (IPv4/IPv6)
- Firewall rules
- ARP tables
- DHCP leases
- Wireless configuration
- Active connections

### Examples

```bash
# Basic scan
./openwrt-config-scan.sh 192.168.1.1

# Scan with custom output
./openwrt-config-scan.sh 192.168.1.1 /backup/routers/

# Scan using hostname
./openwrt-config-scan.sh router.local
```

## openwrt-config-apply.sh

### Description
Applies saved configurations from one router to another, with options for selective application and dry-run testing.

### Usage
```bash
./openwrt-config-apply.sh <target_router_ip> <config_directory> [options]
```

### Parameters
- `target_router_ip` - Router to apply configuration to
- `config_directory` - Directory containing saved configuration

### Options
- `--dry-run` - Preview changes without applying
- `--selective` - Choose which configs to apply
- `--no-backup` - Skip backup of current config
- `--force` - Apply without confirmation

### Safety Features
1. **Automatic Backup** - Creates backup before applying
2. **Dry Run Mode** - Preview all changes
3. **Selective Application** - Choose specific configs
4. **Service Management** - Handles service restarts
5. **Validation** - Checks configuration compatibility

### Configuration Types

#### Network Configuration
- IP addresses
- Routes
- VLANs
- Bridge configuration

#### Wireless Settings
- SSIDs
- Security settings
- Channel configuration
- Power settings

#### Firewall Rules
- Zones
- Forwarding rules
- Port forwards
- Custom rules

#### System Settings
- Hostname
- Timezone
- NTP servers
- LED configuration

### Examples

```bash
# Preview changes (dry run)
./openwrt-config-apply.sh 192.168.1.2 ./router_configs/router1_backup --dry-run

# Apply all configurations
./openwrt-config-apply.sh 192.168.1.2 ./router_configs/router1_backup

# Selective application
./openwrt-config-apply.sh 192.168.1.2 ./router_configs/router1_backup --selective

# Force apply without confirmation
./openwrt-config-apply.sh 192.168.1.2 ./router_configs/router1_backup --force

# Apply without creating backup
./openwrt-config-apply.sh 192.168.1.2 ./router_configs/router1_backup --no-backup
```

## openwrt-batch-scanner.sh

### Description
Scans multiple routers in parallel and generates network-wide reports and inventories.

### Usage
```bash
./openwrt-batch-scanner.sh <router_list_file> [output_directory]
```

### Parameters
- `router_list_file` - Text file with router IPs (one per line)
- `output_directory` - Optional custom output location

### Input File Format
```
# routers.txt
192.168.1.1
192.168.1.2
10.0.0.1
router.local
```

### Features
1. **Parallel Scanning** - Scans multiple routers simultaneously
2. **HTML Report** - Visual network overview
3. **JSON Inventory** - Machine-readable data
4. **Comparison Tools** - Compare configurations
5. **Package Analysis** - Cross-router package report

### Output Files

#### Network Report (HTML)
- Router summary table
- Package statistics
- Network topology
- Configuration differences
- Health status

#### Inventory (JSON)
```json
{
  "scan_date": "2024-01-01T12:00:00Z",
  "total_routers": 3,
  "routers": [
    {
      "hostname": "router1",
      "ip": "192.168.1.1",
      "version": "OpenWRT 23.05",
      "packages": 142,
      "uptime": "5 days"
    }
  ],
  "common_packages": [...],
  "unique_packages": {...}
}
```

### Examples

```bash
# Create router list
cat > routers.txt << EOF
192.168.1.1
192.168.1.2
192.168.1.3
EOF

# Run batch scan
./openwrt-batch-scanner.sh routers.txt

# Scan with custom output
./openwrt-batch-scanner.sh routers.txt /backup/network/

# Scan from existing list
./openwrt-batch-scanner.sh production_routers.txt
```

## Automation Examples

### Scheduled Backups

Create a cron job for regular backups:

```bash
# Add to crontab
0 2 * * * /path/to/openwrt-config-scan.sh 192.168.1.1 /backup/daily/
```

### Backup Script

```bash
#!/bin/bash
# backup-all-routers.sh

ROUTERS="192.168.1.1 192.168.1.2 192.168.1.3"
BACKUP_DIR="/backup/routers/$(date +%Y%m%d)"

mkdir -p "$BACKUP_DIR"

for router in $ROUTERS; do
    echo "Backing up $router..."
    ./openwrt-config-scan.sh "$router" "$BACKUP_DIR"
done

echo "Backups complete: $BACKUP_DIR"
```

### Configuration Sync

```bash
#!/bin/bash
# sync-configs.sh

MASTER="192.168.1.1"
SLAVES="192.168.1.2 192.168.1.3"
TEMP_DIR="/tmp/master_config"

# Get master configuration
./openwrt-config-scan.sh "$MASTER" "$TEMP_DIR"

# Apply to slaves
for slave in $SLAVES; do
    echo "Syncing to $slave..."
    ./openwrt-config-apply.sh "$slave" "$TEMP_DIR/$(ls -t $TEMP_DIR | head -1)"
done
```

### Difference Monitoring

```bash
#!/bin/bash
# monitor-changes.sh

ROUTER="192.168.1.1"
BASELINE="/backup/baseline"
CURRENT="/tmp/current"

# Scan current state
./openwrt-config-scan.sh "$ROUTER" "$CURRENT"

# Compare with baseline
diff -r "$BASELINE" "$CURRENT/$(ls -t $CURRENT | head -1)" > changes.txt

if [ -s changes.txt ]; then
    echo "Configuration changes detected!"
    mail -s "Router Config Changed" admin@example.com < changes.txt
fi
```

## Best Practices

### Backup Strategy
1. **Regular Schedules** - Daily/weekly automated backups
2. **Before Changes** - Always backup before modifications
3. **Version Control** - Store configs in git
4. **Offsite Storage** - Keep copies on separate system
5. **Test Restores** - Regularly verify backup integrity

### Security Considerations
1. **Secure Storage** - Encrypt sensitive backups
2. **Access Control** - Limit script permissions
3. **SSH Keys** - Use key-based authentication
4. **Audit Logs** - Track configuration changes
5. **Sensitive Data** - Exclude passwords from commits

### Organization
1. **Naming Convention** - Use consistent naming
2. **Documentation** - Document custom changes
3. **Change Log** - Maintain modification history
4. **Directory Structure** - Organize by date/router
5. **Cleanup Policy** - Remove old backups

## Troubleshooting

### Common Issues

#### Connection Timeout
```bash
# Increase SSH timeout
ssh -o ConnectTimeout=30 root@router-ip
```

#### Large Configurations
```bash
# Compress during transfer
ssh root@router-ip "tar -czf - /etc/config" > config.tar.gz
```

#### Permission Errors
```bash
# Ensure proper permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

### Debug Mode

Run scripts with debug output:
```bash
bash -x openwrt-config-scan.sh 192.168.1.1
```

### Logging

Enable detailed logging:
```bash
./openwrt-config-scan.sh 192.168.1.1 2>&1 | tee scan.log
```

## Integration

### Git Integration

```bash
# Initialize repository
cd router_configs
git init
git add .
git commit -m "Initial router configurations"

# Track changes
./openwrt-config-scan.sh 192.168.1.1
git add .
git commit -m "Updated router1 configuration"
```

### CI/CD Pipeline

```yaml
# .gitlab-ci.yml example
backup-routers:
  script:
    - ./openwrt-batch-scanner.sh routers.txt
    - git add router_configs/
    - git commit -m "Automated backup $(date)"
    - git push
  schedule:
    - cron: "0 2 * * *"
```

### Monitoring Integration

```bash
# Nagios/Zabbix check script
#!/bin/bash
LAST_BACKUP=$(find /backup -name "*.tar.gz" -mtime -1 | wc -l)
if [ "$LAST_BACKUP" -eq 0 ]; then
    echo "CRITICAL: No recent backups"
    exit 2
fi
echo "OK: Backups current"
exit 0
```