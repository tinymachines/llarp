# Distributed VPN Deployment Guide

This guide explains how to deploy a load-balanced VPN cluster using multiple Lazarus routers with HAProxy and mwan3 for traffic distribution across different VPN exits.

## Overview

The distributed VPN system consists of:
- **1 Master Router**: HAProxy load balancer with mwan3 multi-WAN orchestration
- **N Endpoint Routers**: Individual VPN exit points with different VPN providers
- **Load Balancing**: Round-robin distribution of TCP/UDP traffic across all VPN exits

## Architecture

### Switch-Based Setup (Recommended)

```
Client Traffic → Master Router (HAProxy) → Round-Robin Distribution
                      17.0.0.1
                         ↓
                   [Ethernet Switch]
                         ↓
    ┌────────────────────┼────────────────────┐
    ↓                    ↓                    ↓
17.0.0.10            17.0.0.11            17.0.0.12
Box 1 (VPN A)        Box 2 (VPN B)        Box 3 (VPN C)
```

**Benefits:**
- Single network segment (17.0.0.0/24)
- No USB adapters required
- Gigabit switching performance
- Easy to scale with more switch ports
- Standard ethernet connections

## Prerequisites

- OpenWRT-compatible hardware (Raspberry Pi 4+ recommended)
- USB-to-Ethernet adapters for additional network segments
- SSH access to all routers
- Different VPN provider accounts for each endpoint

## Phase 1: Master Router Configuration

### 1. Install Required Packages

```bash
ssh root@17.0.0.1 "
opkg update
opkg install haproxy mwan3
"
```

### 2. Configure Network Segments

```bash
ssh root@17.0.0.1 "
# Configure LAN2 interface for 17.1.0.0/24
uci set network.lan2=interface
uci set network.lan2.proto='static'
uci set network.lan2.ipaddr='17.1.0.1'
uci set network.lan2.netmask='255.255.255.0'
uci set network.lan2.device='eth1'

# Configure LAN3 interface for 17.2.0.0/24
uci set network.lan3=interface
uci set network.lan3.proto='static'
uci set network.lan3.ipaddr='17.2.0.1'
uci set network.lan3.netmask='255.255.255.0'
uci set network.lan3.device='eth2'

# Commit network changes
uci commit network
"
```

### 3. Configure HAProxy Load Balancer

Create `/etc/haproxy.cfg`:

```bash
ssh root@17.0.0.1 "cat > /etc/haproxy.cfg << 'EOF'
global
    maxconn 4096
    ulimit-n 65535
    nbthread 4
    log stdout local0

defaults
    mode tcp
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms
    option dontlognull
    retries 3

# TCP Load Balancer Frontend
frontend tcp_frontend
    bind *:8080
    mode tcp
    default_backend tcp_backend

# TCP Backend Pool
backend tcp_backend
    mode tcp
    balance roundrobin
    # Current Lazarus box on 17.0.0.0/24
    server lazarus1 17.0.0.10:8080 check
    # Future box 2 on 17.1.0.0/24
    server lazarus2 17.1.0.10:8080 check
    # Future box 3 on 17.2.0.0/24
    server lazarus3 17.2.0.10:8080 check

# UDP Load Balancer (for VPN traffic)
frontend udp_frontend
    bind *:1194 interface 17.0.0.1
    mode tcp
    default_backend udp_backend

backend udp_backend
    mode tcp
    balance roundrobin
    # OpenVPN/WireGuard endpoints
    server vpn1 17.0.0.10:1194 check
    server vpn2 17.1.0.10:1194 check
    server vpn3 17.2.0.10:1194 check

# Statistics Interface
frontend stats
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 30s
EOF"
```

### 4. Configure mwan3 Multi-WAN

```bash
ssh root@17.0.0.1 "
# Interface 1 (current LAN)
uci set mwan3.wan1=interface
uci set mwan3.wan1.enabled='1'
uci set mwan3.wan1.count='2'
uci set mwan3.wan1.timeout='2'
uci set mwan3.wan1.interval='5'
uci set mwan3.wan1.down='3'
uci set mwan3.wan1.up='8'
uci add_list mwan3.wan1.track_ip='8.8.8.8'
uci add_list mwan3.wan1.track_ip='1.1.1.1'

# Interface 2 (future LAN2)
uci set mwan3.wan2=interface
uci set mwan3.wan2.enabled='1'
uci set mwan3.wan2.count='2'
uci set mwan3.wan2.timeout='2'
uci set mwan3.wan2.interval='5'
uci set mwan3.wan2.down='3'
uci set mwan3.wan2.up='8'
uci add_list mwan3.wan2.track_ip='8.8.8.8'
uci add_list mwan3.wan2.track_ip='1.1.1.1'

# Interface 3 (future LAN3)
uci set mwan3.wan3=interface
uci set mwan3.wan3.enabled='1'
uci set mwan3.wan3.count='2'
uci set mwan3.wan3.timeout='2'
uci set mwan3.wan3.interval='5'
uci set mwan3.wan3.down='3'
uci set mwan3.wan3.up='8'
uci add_list mwan3.wan3.track_ip='8.8.8.8'
uci add_list mwan3.wan3.track_ip='1.1.1.1'

# Members for load balancing
uci set mwan3.wan1_m1_w3=member
uci set mwan3.wan1_m1_w3.interface='wan1'
uci set mwan3.wan1_m1_w3.metric='1'
uci set mwan3.wan1_m1_w3.weight='3'

uci set mwan3.wan2_m1_w3=member
uci set mwan3.wan2_m1_w3.interface='wan2'
uci set mwan3.wan2_m1_w3.metric='1'
uci set mwan3.wan2_m1_w3.weight='3'

uci set mwan3.wan3_m1_w3=member
uci set mwan3.wan3_m1_w3.interface='wan3'
uci set mwan3.wan3_m1_w3.metric='1'
uci set mwan3.wan3_m1_w3.weight='3'

# Load balancing policy
uci set mwan3.balanced=policy
uci add_list mwan3.balanced.use_member='wan1_m1_w3'
uci add_list mwan3.balanced.use_member='wan2_m1_w3'
uci add_list mwan3.balanced.use_member='wan3_m1_w3'
uci set mwan3.balanced.last_resort='unreachable'

# Rule to apply load balancing
uci set mwan3.default_rule=rule
uci set mwan3.default_rule.dest_ip='0.0.0.0/0'
uci set mwan3.default_rule.use_policy='balanced'
uci set mwan3.default_rule.proto='all'

# Commit mwan3 configuration
uci commit mwan3
"
```

### 5. Enable Services

```bash
ssh root@17.0.0.1 "
# Enable and start HAProxy
/etc/init.d/haproxy enable
/etc/init.d/haproxy start

# Enable and start mwan3
/etc/init.d/mwan3 enable
/etc/init.d/mwan3 start

# Reload network configuration
/etc/init.d/network reload
"
```

## Phase 2: Image Preparation and Deployment

### 1. Image the Master Router

The master router is now ready for imaging. Create a disk image using your preferred method (dd, Win32DiskImager, etc.).

### 2. Flash Images to Additional Hardware

Flash the master image to additional Raspberry Pi devices that will serve as VPN endpoints.

### 3. Configure Endpoint Boxes

Use the provided configuration scripts to convert cloned images into VPN endpoints:

#### Box 2 Configuration Script

Create `configure-box2.sh`:

```bash
#!/bin/bash
# Configuration script for Lazarus Box 2
# Run this on the cloned image to convert it to Box 2

echo "Configuring Lazarus Box 2..."

# Change network configuration
uci set network.lan.ipaddr='17.1.0.10'
uci set network.lan.gateway='17.0.0.1'
uci delete network.lan2
uci delete network.lan3

# Remove load balancer services (this box is VPN endpoint only)
/etc/init.d/haproxy stop
/etc/init.d/haproxy disable
/etc/init.d/mwan3 stop
/etc/init.d/mwan3 disable

# Clean up HAProxy and mwan3 configs
rm -f /etc/haproxy.cfg
uci delete mwan3.wan1 2>/dev/null || true
uci delete mwan3.wan2 2>/dev/null || true
uci delete mwan3.wan3 2>/dev/null || true
uci delete mwan3.wan1_m1_w3 2>/dev/null || true
uci delete mwan3.wan2_m1_w3 2>/dev/null || true
uci delete mwan3.wan3_m1_w3 2>/dev/null || true
uci delete mwan3.balanced 2>/dev/null || true
uci delete mwan3.default_rule 2>/dev/null || true

# Change hostname
uci set system.@system[0].hostname='lazarus-box2'

# Commit all changes
uci commit network
uci commit system
uci commit mwan3

# Restart network
/etc/init.d/network restart

echo "Box 2 configuration complete!"
echo "IP: 17.1.0.10"
echo "Gateway: 17.0.0.1"
echo "Role: VPN Endpoint"
```

#### Box 3 Configuration Script

Create `configure-box3.sh`:

```bash
#!/bin/bash
# Configuration script for Lazarus Box 3
# Run this on the cloned image to convert it to Box 3

echo "Configuring Lazarus Box 3..."

# Change network configuration
uci set network.lan.ipaddr='17.2.0.10'
uci set network.lan.gateway='17.0.0.1'
uci delete network.lan2
uci delete network.lan3

# Remove load balancer services (this box is VPN endpoint only)
/etc/init.d/haproxy stop
/etc/init.d/haproxy disable
/etc/init.d/mwan3 stop
/etc/init.d/mwan3 disable

# Clean up HAProxy and mwan3 configs
rm -f /etc/haproxy.cfg
uci delete mwan3.wan1 2>/dev/null || true
uci delete mwan3.wan2 2>/dev/null || true
uci delete mwan3.wan3 2>/dev/null || true
uci delete mwan3.wan1_m1_w3 2>/dev/null || true
uci delete mwan3.wan2_m1_w3 2>/dev/null || true
uci delete mwan3.wan3_m1_w3 2>/dev/null || true
uci delete mwan3.balanced 2>/dev/null || true
uci delete mwan3.default_rule 2>/dev/null || true

# Change hostname
uci set system.@system[0].hostname='lazarus-box3'

# Commit all changes
uci commit network
uci commit system
uci commit mwan3

# Restart network
/etc/init.d/network restart

echo "Box 3 configuration complete!"
echo "IP: 17.2.0.10"
echo "Gateway: 17.0.0.1"
echo "Role: VPN Endpoint"
```

### 4. Deploy Configuration Scripts

```bash
# Make scripts executable
chmod +x configure-box*.sh

# Deploy to Box 2 (initially accessible at 17.0.0.1 before configuration)
scp configure-box2.sh root@17.0.0.1:/tmp/
ssh root@17.0.0.1 "/tmp/configure-box2.sh"

# Deploy to Box 3 (initially accessible at 17.0.0.1 before configuration)
scp configure-box3.sh root@17.0.0.1:/tmp/
ssh root@17.0.0.1 "/tmp/configure-box3.sh"
```

## Phase 3: Hardware Connection

### 1. Connect USB Ethernet Adapters

- Connect USB-to-Ethernet adapter 1 to master router
- Connect USB-to-Ethernet adapter 2 to master router
- Verify they appear as eth1 and eth2

### 2. Connect Endpoint Boxes

- Connect Box 2 ethernet to USB adapter 1 (17.1.0.0/24 network)
- Connect Box 3 ethernet to USB adapter 2 (17.2.0.0/24 network)

## Phase 4: VPN Configuration

Configure different VPN providers on each endpoint box:

### Box 1 (17.0.0.10)
- Configure VPN Provider A (e.g., NordVPN, ExpressVPN)
- Ensure VPN traffic routes through tun0

### Box 2 (17.1.0.10)
- Configure VPN Provider B (different from Box 1)
- Ensure VPN traffic routes through tun0

### Box 3 (17.2.0.10)
- Configure VPN Provider C (different from Boxes 1 & 2)
- Ensure VPN traffic routes through tun0

## Monitoring and Management

### HAProxy Statistics

Access load balancer statistics at: `http://17.0.0.1:8404/stats`

### mwan3 Status

Check multi-WAN status:
```bash
ssh root@17.0.0.1 "mwan3 status"
```

### Service Management

```bash
# Restart HAProxy
ssh root@17.0.0.1 "/etc/init.d/haproxy restart"

# Restart mwan3
ssh root@17.0.0.1 "/etc/init.d/mwan3 restart"

# Check service status
ssh root@17.0.0.1 "/etc/init.d/haproxy status"
ssh root@17.0.0.1 "/etc/init.d/mwan3 status"
```

## Scaling to More Boxes

To add additional VPN endpoints:

1. **Extend network configuration** on master router:
   ```bash
   # Add LAN4 for 17.3.0.0/24
   uci set network.lan4=interface
   uci set network.lan4.proto='static'
   uci set network.lan4.ipaddr='17.3.0.1'
   uci set network.lan4.netmask='255.255.255.0'
   uci set network.lan4.device='eth3'
   ```

2. **Update HAProxy configuration** to include new backend
3. **Add mwan3 interface and member** for the new network
4. **Create configuration script** for the new box
5. **Connect additional USB ethernet adapter**

## Performance Expectations

- **Raspberry Pi 4**: 300-500 Mbps combined throughput
- **Raspberry Pi 5**: 500-700 Mbps combined throughput
- **Concurrent connections**: 2,000-5,000 per box
- **Additional latency**: 2-8ms compared to direct connection

## Troubleshooting

### Common Issues

1. **HAProxy not starting**: Check configuration syntax with `haproxy -c -f /etc/haproxy.cfg`
2. **mwan3 not working**: Verify interface names match actual devices
3. **No connectivity**: Check USB adapter detection and network configuration
4. **VPN conflicts**: Ensure each box uses different VPN providers/servers

### Debug Commands

```bash
# Check network interfaces
ip link show

# Check routing table
ip route show

# Check HAProxy logs
logread | grep haproxy

# Check mwan3 status
mwan3 status

# Test connectivity between boxes
ping 17.1.0.10
ping 17.2.0.10
```

## Security Considerations

- Use strong SSH keys for router access
- Configure firewall rules to restrict management access
- Regularly update OpenWRT and packages
- Monitor VPN connection logs for anomalies
- Use different VPN provider accounts to avoid correlation

## Conclusion

This distributed VPN setup provides load-balanced, fault-tolerant VPN connectivity with automatic failover and traffic distribution across multiple exit points. The architecture scales easily by adding more endpoint boxes and can handle significant traffic loads on Raspberry Pi hardware.