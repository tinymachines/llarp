# Network Routing Configuration Guide

This guide explains how to set up inter-router communication between multiple OpenWRT routers on different network segments.

## Overview

The network routing scripts enable communication between isolated network segments by configuring static routes and firewall rules on OpenWRT routers.

## Network Topology Example

```
[Zephyr Lab Network]
    15.0.0.0/24
         |
    15.0.0.1 (Zephyr LAN)
         |
    13.0.0.73 (Zephyr WAN)
         |
[ATT Network 13.0.0.0/24]
         |
    13.0.0.254 (ATT Gateway) --> Internet
         |
    13.0.0.250 (Spydr WiFi Client)
         |
    192.168.1.1 (Spydr LAN)
         |
[Spydr Network]
    192.168.1.0/24
```

## Scripts

### configure-inter-router-communication.sh

Sets up routing tables and firewall rules to enable communication between routers.

**Features:**
- Automatic router detection
- Static route configuration
- Firewall zone setup
- Persistent configuration (survives reboots)
- Connection testing

**Usage:**
```bash
./configure-inter-router-communication.sh
```

**What it configures:**

1. **On Zephyr Router:**
   - Default route to internet via ATT gateway (13.0.0.254)
   - Static route to Spydr network (192.168.1.0/24) via 13.0.0.250
   - Firewall rules to allow Spydr traffic

2. **On Spydr Router:**
   - Static route to Zephyr network (15.0.0.0/24) via 13.0.0.73
   - Firewall rules to allow Zephyr traffic
   - Default route maintained via ATT gateway

### verify-inter-router-communication.sh

Tests connectivity between all configured networks.

**Features:**
- Comprehensive connectivity matrix
- DNS resolution testing
- ARP table verification
- Routing table display
- Visual network topology

**Usage:**
```bash
./verify-inter-router-communication.sh
```

**Test Matrix:**
- Zephyr → Spydr LAN
- Zephyr → ATT Gateway
- Zephyr → Internet
- Spydr → Zephyr LAN
- Spydr → ATT Gateway
- Spydr → Internet

## Configuration Details

### UCI Configuration

Routes are configured using UCI (Unified Configuration Interface):

```bash
# Example: Add route on Zephyr to Spydr network
uci set network.route_spydr=route
uci set network.route_spydr.interface='wan'
uci set network.route_spydr.target='192.168.1.0/24'
uci set network.route_spydr.gateway='13.0.0.250'
uci commit network
```

### Manual Route Configuration

If you need to manually add routes:

```bash
# Add route immediately (non-persistent)
ip route add 192.168.1.0/24 via 13.0.0.250 dev wan

# Make persistent via UCI
uci set network.route_name=route
uci set network.route_name.target='192.168.1.0/24'
uci set network.route_name.gateway='13.0.0.250'
uci set network.route_name.interface='wan'
uci commit network
/etc/init.d/network restart
```

## Firewall Configuration

The scripts automatically configure firewall zones, but you can also do it manually:

```bash
# Create zone for remote network
uci set firewall.remote=zone
uci set firewall.remote.name='remote'
uci set firewall.remote.input='ACCEPT'
uci set firewall.remote.output='ACCEPT'
uci set firewall.remote.forward='ACCEPT'
uci add_list firewall.remote.subnet='192.168.1.0/24'

# Add forwarding rules
uci set firewall.lan_remote=forwarding
uci set firewall.lan_remote.src='lan'
uci set firewall.lan_remote.dest='remote'

uci commit firewall
/etc/init.d/firewall restart
```

## Troubleshooting

### Routes Not Working

1. **Check route is active:**
   ```bash
   ip route show
   ```

2. **Verify gateway is reachable:**
   ```bash
   ping -c 2 <gateway_ip>
   ```

3. **Check firewall logs:**
   ```bash
   logread | grep -i drop
   ```

### Connection Timeouts

1. **Check firewall rules:**
   ```bash
   uci show firewall | grep -E "zone|forwarding|rule"
   ```

2. **Test with firewall disabled (temporary):**
   ```bash
   /etc/init.d/firewall stop
   # Test connectivity
   /etc/init.d/firewall start
   ```

### DNS Issues

1. **Check DNS servers:**
   ```bash
   cat /etc/resolv.conf
   ```

2. **Test DNS resolution:**
   ```bash
   nslookup google.com
   ```

3. **Configure DNS manually:**
   ```bash
   uci set network.wan.dns='8.8.8.8 1.1.1.1'
   uci commit network
   /etc/init.d/network restart
   ```

## Advanced Configuration

### Multiple Router Setup

For more than two routers, create a routing table on each router pointing to all other networks:

```bash
# Router A (10.0.0.0/24)
uci set network.route_b.target='10.1.0.0/24'
uci set network.route_b.gateway='<router_b_gateway>'
uci set network.route_c.target='10.2.0.0/24'
uci set network.route_c.gateway='<router_c_gateway>'

# Repeat for each router
```

### VLAN Configuration

If using VLANs, ensure VLAN interfaces are properly configured before setting up routes:

```bash
# Create VLAN interface
uci set network.vlan10=interface
uci set network.vlan10.ifname='eth0.10'
uci set network.vlan10.proto='static'
uci set network.vlan10.ipaddr='10.10.0.1'
uci set network.vlan10.netmask='255.255.255.0'
```

## Best Practices

1. **Document your network topology** - Keep a diagram of your network layout
2. **Use meaningful route names** - e.g., `route_lab_network` instead of `route1`
3. **Test after changes** - Always run verification script after modifications
4. **Backup before changes** - Use `openwrt-config-scan.sh` before major changes
5. **Monitor logs** - Check `/var/log/messages` or `logread` for issues

## Related Documentation

- [OpenWRT Routing Documentation](https://openwrt.org/docs/guide-user/network/routing/start)
- [UCI System Documentation](https://openwrt.org/docs/guide-user/base-system/uci)
- [Firewall Configuration](https://openwrt.org/docs/guide-user/firewall/firewall_configuration)