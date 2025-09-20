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

### Automated Master Setup

Use the provided configuration script to apply all required tweaks:

```bash
# Run the master configuration script
./configure-master-router.sh
```

### Manual Master Configuration (Alternative)

If you prefer manual configuration, follow these steps:

#### 1. Install Required Packages

```bash
ssh root@17.0.0.1 "
opkg update
opkg install haproxy curl netcat kmod-usb-net kmod-usb-net-asix-ax88179
"
```

#### 2. Fix LuCI Web Interface (OpenWRT 24.x)

```bash
ssh root@17.0.0.1 "
# Fix uhttpd configuration for OpenWRT 24.x ucode
uci delete uhttpd.main.lua_prefix 2>/dev/null || true
uci set uhttpd.main.cgi_prefix='/cgi-bin'
uci set uhttpd.main.rfc1918_filter='0'
uci commit uhttpd
/etc/init.d/uhttpd restart
"
```

#### 3. Configure HAProxy Load Balancer

```bash
ssh root@17.0.0.1 "cat > /etc/haproxy.cfg << 'EOF'
global
    maxconn 4096
    ulimit-n 65535
    nbthread 4

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

# TCP Backend Pool - Switch-based setup
backend tcp_backend
    mode tcp
    balance roundrobin
    server lazarus1 17.0.0.10:80 check
    server lazarus2 17.0.0.11:80 check
    server lazarus3 17.0.0.12:80 check

# VPN Load Balancer Frontend
frontend vpn_frontend
    bind *:8090
    mode tcp
    default_backend vpn_backend

backend vpn_backend
    mode tcp
    balance roundrobin
    server vpn1 17.0.0.10:8090 check
    server vpn2 17.0.0.11:8090 check
    server vpn3 17.0.0.12:8090 check

# Statistics Interface
frontend stats
    bind *:8404
    mode http
    stats enable
    stats uri /stats
    stats refresh 10s
EOF"

#### 4. Enable HAProxy Service

```bash
ssh root@17.0.0.1 "
/etc/init.d/haproxy enable
/etc/init.d/haproxy start
/etc/init.d/haproxy status
"
```

## Phase 2: Image Preparation and Deployment

### 1. Image the Master Router

The master router is now ready for imaging. Create a disk image using your preferred method (dd, Win32DiskImager, etc.).

### 2. Flash Images to Additional Hardware

Flash the master image to additional Raspberry Pi devices that will serve as VPN endpoints.

### 3. Configure Endpoint Boxes

Use the provided parameterized configuration script to convert cloned images into VPN endpoints:

#### Automated Worker Configuration

```bash
# Configure workers using the parameterized script
./configure-worker-box.sh 1    # Worker 1 → 17.0.0.10
./configure-worker-box.sh 2    # Worker 2 → 17.0.0.11
./configure-worker-box.sh 3    # Worker 3 → 17.0.0.12

# Or use the cluster management script
./setup-cluster.sh configure 1
./setup-cluster.sh configure 2
./setup-cluster.sh configure 3
```

#### Legacy Individual Configuration Scripts

For backward compatibility, individual scripts are also available:

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

### Switch-Based Connection (Recommended)

1. **Connect ethernet switch** to master router
2. **Connect all worker boxes** to the same ethernet switch
3. **Power on all devices** and verify connectivity

All devices will be on the same 17.0.0.0/24 network segment.

## Phase 4: VPN Configuration

### Fix OpenVPN Profiles and Setup

All worker boxes come with ProtonVPN profiles pre-configured. Fix the authentication paths:

```bash
# On each worker box, fix auth-user-pass paths
for worker in 17.0.0.10 17.0.0.11 17.0.0.12; do
  ssh root@$worker "
    cd /etc/openvpn/profiles
    for profile in *.ovpn; do
      sed -i 's|auth-user-pass /home/bisenbek/shared/vpn/pass.txt|auth-user-pass /etc/openvpn/auth.txt|' \$profile
      sed -i 's|^auth-user-pass\$|auth-user-pass /etc/openvpn/auth.txt|' \$profile
    done

    # Create DNS update script
    cat > /etc/openvpn/update-resolv-conf << 'EOF'
#!/bin/sh
interface=\$1
script_context=\$6
case \$script_context in
    up) echo 'nameserver 10.2.0.1' > /tmp/resolv.conf.openvpn; echo 'nameserver 10.2.0.2' >> /tmp/resolv.conf.openvpn ;;
    down) rm -f /tmp/resolv.conf.openvpn ;;
esac
exit 0
EOF
    chmod +x /etc/openvpn/update-resolv-conf

    # Install curl for external IP testing
    opkg update && opkg install curl

    # Select random profile and start OpenVPN
    cd /etc/openvpn
    ./select-random-profile.sh
    /etc/init.d/openvpn enable
    /etc/init.d/openvpn start
  "
done
```

### Configure VPN Routing

Set up proper routing to use VPN as default gateway:

```bash
# Allow initial VPN connection through original route, then switch to VPN
for worker in 17.0.0.10 17.0.0.11 17.0.0.12; do
  ssh root@$worker "
    # Wait for VPN to establish, then set as default route
    sleep 30
    if ip link show tun0 >/dev/null 2>&1; then
      ip route del default via 13.0.0.254 dev phy0-sta0 2>/dev/null || true
      ip route add default via 10.96.0.1 dev tun0 metric 50
      echo 'VPN routing configured for $worker'
    fi
  "
done
```

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

## Testing and Validation

### Comprehensive Test Suite

The system includes a comprehensive test suite in the `tests/` directory:

```bash
# Quick functionality test (10 seconds)
./tests/quick-test.sh

# Full comprehensive testing (5 minutes)
./tests/run-all-tests.sh

# Individual test components
./tests/test-vpn-endpoints.sh      # VPN connections and diversity
./tests/test-tcp-load-balancer.sh  # TCP traffic distribution
./tests/test-http-load-balancer.sh # HTTP traffic and external IPs
./tests/test-udp-load-balancer.sh  # UDP configuration validation
```

### Expected Test Results

- ✅ All workers reachable and VPN-connected
- ✅ HAProxy statistics accessible at http://17.0.0.1:8404/stats
- ✅ Each worker showing different external IP addresses
- ✅ Load balancing distributing traffic across workers
- ✅ Response times under 100ms for local traffic

## Usage and Integration

See `docs/DISTRIBUTED-VPN-USAGE.md` for detailed usage examples including:
- HTTP/TCP/UDP traffic routing
- Client application integration
- Performance monitoring
- Scaling operations

## Conclusion

This distributed VPN setup provides load-balanced, fault-tolerant VPN connectivity with automatic failover and traffic distribution across multiple geographic exit points. The architecture scales easily by adding more endpoint boxes and can handle significant traffic loads on Raspberry Pi hardware.

Key benefits:
- **Geographic VPN diversity** across multiple locations
- **Automatic failover** if VPN connections drop
- **Round-robin load balancing** for optimal performance
- **Simple scaling** with configuration scripts
- **Comprehensive monitoring** via HAProxy statistics