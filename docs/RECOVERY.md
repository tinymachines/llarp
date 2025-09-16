# LLARP Recovery Guide

Comprehensive recovery procedures for OpenWRT routers in the LLARP system, including failsafe mode, IP discovery, and emergency communication methods.

## Router Connection Issues

### Symptoms
- SSH connection refused or timeout
- Router IP address changed unexpectedly
- Network configuration corrupted
- DHCP not providing IP addresses
- Complete loss of router communication

### Root Causes
- Configuration changes that broke network connectivity
- IP address modifications during training/testing
- Failed firmware updates
- Power loss during configuration changes
- Incorrect routing or firewall rules

## Recovery Methods (Priority Order)

### Method 1: Smart SSH Discovery

LLARP includes intelligent router discovery with multiple fallback mechanisms:

```bash
# Automatic router discovery and connection
./llarp-scripts/smart-ssh-connect.sh discover

# Execute command on discovered router
./llarp-scripts/smart-ssh-connect.sh exec "uci get system.@system[0].hostname"

# Connect interactively
./llarp-scripts/smart-ssh-connect.sh connect
```

**Discovery Process:**
1. **Cache Check**: Test previously known IP addresses
2. **Default IP Scan**: Test common router IPs (192.168.1.1, 192.168.100.1, etc.)
3. **Subnet Scan**: Scan common subnet ranges for router devices
4. **UDP Beacon**: Listen for router beacon responses
5. **Failsafe Detection**: Attempt connection to failsafe IP (192.168.1.1)

### Method 2: UDP Beacon System

Emergency communication system immune to IP address changes:

```bash
# Deploy beacon service to router (when accessible)
./llarp-scripts/router-beacon-system.sh deploy 192.168.1.1

# Listen for router beacons
./llarp-scripts/smart-ssh-connect.sh listen 30

# Send discovery broadcast
./llarp-scripts/smart-ssh-connect.sh beacon
```

**Beacon Protocol:**
- **Port**: UDP 31337 (discovery requests)
- **Response Port**: UDP 31338 (router responses)
- **Message Format**: `LLARP_ROUTER:hostname:lan_ip:wan_ip:uptime:load`
- **Broadcast**: Works across subnet boundaries
- **Automatic**: Runs as system service on router

### Method 3: OpenWRT Failsafe Mode

When all else fails, use OpenWRT's built-in failsafe recovery:

#### Entering Failsafe Mode
1. **Power Cycle**: Disconnect and reconnect power to router
2. **Watch for LED Pattern**: Wait for rapid blinking (5 blinks per second)
3. **Button Press**: Press and hold any button during 2-4 second window
4. **Failsafe Confirmation**: LED pattern changes, router boots to 192.168.1.1

#### Failsafe Connection
```bash
# Configure local interface for failsafe access
sudo ip addr add 192.168.1.100/24 dev eth0

# Connect to failsafe router
telnet 192.168.1.1

# Alternative SSH (if configured)
ssh root@192.168.1.1
```

#### Failsafe Recovery Commands
```bash
# Mount root filesystem read-write
mount_root

# Reset to factory defaults
firstboot

# Reboot to apply changes
reboot

# Manual configuration restore
uci import < /tmp/backup_config.uci
uci commit
reboot
```

### Method 4: Serial Console Access

For hardware-level recovery when network methods fail:

#### Serial Connection
```bash
# Connect via USB-to-serial adapter (typical settings)
screen /dev/ttyUSB0 115200

# Alternative with minicom
minicom -D /dev/ttyUSB0 -b 115200
```

#### Serial Recovery Commands
```bash
# Stop boot process at U-Boot prompt
# Press Ctrl+C during boot countdown

# Network configuration in U-Boot
setenv ipaddr 192.168.1.1
setenv serverip 192.168.1.100
saveenv

# TFTP recovery
tftpboot 0x80060000 openwrt-firmware.bin
erase 0x9f020000 +$filesize
cp.b 0x80060000 0x9f020000 $filesize
```

## Automated Recovery Integration

### Smart Connection Wrapper

LLARP includes an intelligent connection system that handles IP discovery automatically:

```python
# Python integration
from llarp_scripts.smart_ssh import SmartSSHConnection

conn = SmartSSHConnection()
result = conn.execute_command("uci show system")

if result.success:
    print(f"Connected to {result.router_ip}")
    print(f"Router: {result.hostname}")
else:
    print(f"Connection failed: {result.error}")
```

### Training System Integration

The LLARP training system automatically handles connection issues:

```bash
# Training with automatic recovery
./llarp-train basic --auto-discover

# Force failsafe mode detection
./llarp-train basic --failsafe-mode

# Use specific recovery method
./llarp-train basic --connection-method beacon
```

## Network Troubleshooting

### Common Configuration Issues

#### Invalid IP Address Configuration
```bash
# Symptoms: Router unreachable, DHCP not working
# Recovery: Connect via failsafe, reset network config

mount_root
uci set network.lan.ipaddr='192.168.1.1'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.proto='static'
uci commit network
/etc/init.d/network restart
```

#### Firewall Lockout
```bash
# Symptoms: SSH refused, web interface blocked
# Recovery: Disable firewall temporarily

mount_root
/etc/init.d/firewall stop
uci set firewall.@defaults[0].input='ACCEPT'
uci commit firewall
/etc/init.d/firewall start
```

#### WiFi Configuration Corruption
```bash
# Symptoms: WiFi not starting, interface errors
# Recovery: Reset wireless configuration

mount_root
uci delete wireless.@wifi-iface[0]
uci set wireless.@wifi-device[0].disabled='0'
uci commit wireless
wifi
```

#### DHCP Service Issues
```bash
# Symptoms: No IP leases, DHCP requests fail
# Recovery: Reset DHCP configuration

mount_root
uci set dhcp.lan.start='100'
uci set dhcp.lan.limit='150'
uci set dhcp.lan.leasetime='12h'
uci commit dhcp
/etc/init.d/dnsmasq restart
```

## Emergency Recovery Procedures

### Complete Configuration Reset

When router is accessible but configuration is corrupted:

```bash
# Method 1: UCI reset (preserves packages)
./llarp-scripts/smart-ssh-connect.sh exec "
    uci export system > /tmp/system_backup.uci
    for config in network wireless firewall dhcp dropbear; do
        uci delete \$config
        uci commit \$config
    done
    /etc/init.d/network restart
"

# Method 2: Factory reset (removes all changes)
./llarp-scripts/smart-ssh-connect.sh exec "firstboot && reboot"

# Method 3: Firmware reflash (complete wipe)
scp openwrt-firmware.bin root@192.168.1.1:/tmp/
./llarp-scripts/smart-ssh-connect.sh exec "sysupgrade -n /tmp/openwrt-firmware.bin"
```

### Training System Recovery

When LLARP training causes router issues:

```bash
# Automatic rollback (if snapshots available)
./llarp-train rollback --test-id SYS001

# Manual state restoration
./llarp-scripts/smart-ssh-connect.sh exec "
    uci import system < /tmp/backup_system.uci
    uci import network < /tmp/backup_network.uci
    uci commit
    reboot
"

# Emergency training stop
pkill -f llarp_trainer.py
./llarp-scripts/smart-ssh-connect.sh exec "killall -9 uci"
```

## Prevention Strategies

### Pre-Training Safeguards

```bash
# Create comprehensive backup before training
./openwrt-config-scan.sh $(./llarp-scripts/smart-ssh-connect.sh discover | grep CURRENT_IP | cut -d: -f2)

# Deploy beacon system for emergency access
./llarp-scripts/router-beacon-system.sh deploy $(./llarp-scripts/smart-ssh-connect.sh discover | head -1)

# Set up serial console access (hardware dependent)
# Configure rescue SSH on alternate port
```

### Monitoring During Training

```bash
# Monitor training progress with automatic intervention
./llarp-train basic --monitor --auto-rollback

# Set training timeouts
./llarp-train basic --max-test-time 300 --max-total-time 3600

# Enable verbose logging
./llarp-train basic --verbose --log-file /tmp/training.log
```

## Hardware-Specific Recovery

### Device Reset Methods

#### TP-Link Devices
- Reset button: Hold 10 seconds while powered
- Failsafe: Power on, wait for LED pattern, press WPS button

#### Linksys Devices
- Reset button: Hold 10 seconds while powered
- Failsafe: Power on, press reset button when power LED blinks

#### Netgear Devices
- Reset button: Hold 7 seconds while powered
- Failsafe: Power on, press reset during boot LED sequence

#### GL.iNet Devices
- Reset button: Hold 4 seconds for reset, 10 seconds for U-Boot
- Failsafe: Available via web recovery at 192.168.1.1

### Serial Console Pinouts

Common serial console configurations for hardware recovery:

```
Standard 3.3V TTL Serial (Most Devices):
Pin 1: VCC (3.3V) - Usually not connected
Pin 2: TX (Transmit from router)
Pin 3: RX (Receive to router)
Pin 4: GND (Ground)

Connection: USB-to-TTL adapter
Speed: 115200 baud, 8N1
```

## Recovery Scripts Integration

### Automated Recovery Tools

```bash
# Complete recovery suite
./llarp-scripts/auto-recovery.sh --scan-and-connect
./llarp-scripts/auto-recovery.sh --deploy-beacons
./llarp-scripts/auto-recovery.sh --test-all-methods

# Emergency factory reset
./llarp-scripts/emergency-reset.sh --router-ip auto-discover

# Bulk router recovery
./llarp-scripts/bulk-recovery.sh --router-list routers.txt
```

### Integration with Training System

The recovery system integrates directly with LLARP training:

- **Automatic snapshots** before each test
- **Real-time connection monitoring** during training
- **Immediate rollback** on connection loss
- **Emergency beacon activation** for lost routers
- **Multi-method discovery** for IP changes

## Troubleshooting Decision Tree

```
Router Not Responding
├── Can ping IP?
│   ├── Yes → SSH connection issue
│   │   ├── Try smart-ssh-connect.sh discover
│   │   ├── Check SSH service: ssh user@ip 'ps | grep dropbear'
│   │   └── Try alternate ports: ssh -p 2222 user@ip
│   └── No → IP or network issue
│       ├── Try router discovery scan
│       ├── Check DHCP lease table on upstream router
│       └── Attempt failsafe mode entry
├── Training in Progress?
│   ├── Yes → Check for test-specific IP changes
│   ├── Stop training: pkill llarp_trainer
│   └── Rollback last test changes
└── Complete Loss of Contact?
    ├── Try UDP beacon discovery
    ├── Attempt serial console access
    ├── Physical reset button (10 seconds)
    └── Factory reset via failsafe mode
```

## Preventive Measures

### System Hardening
- Deploy beacon system during initial setup
- Configure backup SSH on alternate port (2222)
- Set up serial console access where possible
- Create automated backup schedules
- Implement connection monitoring with alerts

### Training Safety
- Always create snapshots before configuration changes
- Set reasonable timeouts for all operations
- Monitor router responsiveness during training
- Implement automatic rollback on connection loss
- Use dry-run mode for untested scenarios

## Emergency Contact Methods

When standard recovery fails:

1. **Serial Console**: Hardware-level access via TTL adapter
2. **TFTP Recovery**: Network-based firmware recovery via U-Boot
3. **JTAG**: Hardware debug interface (advanced, device-specific)
4. **Physical Reset**: Button-based factory reset
5. **Firmware Recovery Mode**: Manufacturer-specific web recovery

This recovery system ensures LLARP training can proceed safely with multiple backup plans for router connectivity issues.