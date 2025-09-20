# Distributed VPN Load Balancer Usage Guide

This guide demonstrates how to use the distributed VPN load balancer cluster for various protocols and applications.

## Overview

The distributed VPN load balancer provides multiple access points for load-balanced traffic across different VPN exits:

```
Client → Master Router (17.0.0.1) → HAProxy Load Balancer
                    ↓
   ┌────────────────┼────────────────┐
   ↓                ↓                ↓
Worker 1         Worker 2         Worker 3
(17.0.0.10)     (17.0.0.11)     (17.0.0.12)
VPN Exit A      VPN Exit B      VPN Exit C
```

## Access Points

| Service | Port | Protocol | Purpose |
|---------|------|----------|---------|
| TCP Load Balancer | 8080 | TCP | General TCP traffic distribution |
| VPN Load Balancer | 8090 | TCP | VPN tunnel traffic distribution |
| HAProxy Statistics | 8404 | HTTP | Monitoring and management |
| LuCI Management | 80 | HTTP | Router web interface |

## Usage Examples

### HTTP Traffic Load Balancing

Route HTTP requests through different VPN exits:

```bash
# Single request (will be routed to one of 3 workers)
curl http://17.0.0.1:8080/

# Multiple requests to see load balancing
for i in {1..9}; do
    echo "Request $i:"
    curl -s http://17.0.0.1:8080/ | grep -o "Worker.*" || echo "Load balanced response"
    sleep 1
done
```

### TCP Traffic Distribution

Send TCP traffic through the load balancer:

```bash
# Simple TCP echo test
echo "Hello from client" | nc 17.0.0.1 8080

# Multiple TCP connections
for i in {1..5}; do
    echo "TCP test $i" | nc 17.0.0.1 8080
done

# Persistent TCP connection testing
{
    echo "persistent connection test"
    sleep 2
    echo "second message"
} | nc 17.0.0.1 8080
```

### VPN Tunnel Traffic

Route VPN or encrypted traffic through the VPN load balancer:

```bash
# Test VPN backend connectivity
echo "VPN health check" | nc 17.0.0.1 8090

# OpenVPN client configuration (client-side)
# Point your OpenVPN client to:
# remote 17.0.0.1 8090

# Or configure as VPN server endpoint
cat > client-to-cluster.ovpn << EOF
client
dev tun
proto tcp
remote 17.0.0.1 8090
# Additional OpenVPN client configuration...
EOF
```

### External IP Verification

Check which VPN exit point you're using:

```bash
# Check external IP through load balancer
curl http://17.0.0.1:8080/ -H "Host: ipinfo.io" || \
curl -x http://17.0.0.1:8080 ipinfo.io/ip

# Direct worker IP checking
ssh root@17.0.0.10 "curl -s ipinfo.io/ip && echo ' (Worker 1)'"
ssh root@17.0.0.11 "curl -s ipinfo.io/ip && echo ' (Worker 2)'"
ssh root@17.0.0.12 "curl -s ipinfo.io/ip && echo ' (Worker 3)'"

# Get detailed location info
for worker in 17.0.0.10 17.0.0.11 17.0.0.12; do
    echo "Worker $worker:"
    ssh root@$worker "curl -s ipinfo.io | jq -r '.ip + \" (\" + .city + \", \" + .region + \")\"'"
done
```

## Advanced Usage Scenarios

### 1. Web Scraping with Geographic Diversity

Rotate through different VPN exits for web scraping:

```bash
#!/bin/bash
# Web scraping script using distributed VPN exits

LOAD_BALANCER="17.0.0.1:8080"
TARGETS=("example1.com" "example2.com" "example3.com")

for target in "${TARGETS[@]}"; do
    echo "Scraping $target through VPN load balancer..."

    # Each request may go through a different VPN exit
    curl -s --max-time 30 \
         --proxy $LOAD_BALANCER \
         --user-agent "Mozilla/5.0 (compatible; research bot)" \
         "https://$target" > "${target}_data.html"

    echo "Data saved to ${target}_data.html"
    sleep 2  # Rate limiting
done
```

### 2. API Testing Across Regions

Test APIs from different geographic locations:

```bash
#!/bin/bash
# Test API responses from different regions

API_ENDPOINT="https://api.example.com/geo-test"

echo "Testing API from different VPN exits..."

# Test through each worker directly
for worker in 17.0.0.10 17.0.0.11 17.0.0.12; do
    echo "Testing via Worker $worker:"

    response=$(ssh root@$worker "
        curl -s --max-time 15 '$API_ENDPOINT' | jq -r '.location // \"Unknown\"'
    ")

    echo "  Response: $response"
done

# Test through load balancer (random distribution)
echo "Testing via load balancer (random distribution):"
for i in {1..5}; do
    # This will randomly hit different workers
    curl -s --max-time 15 --proxy http://17.0.0.1:8080 "$API_ENDPOINT"
    sleep 1
done
```

### 3. Torrent Traffic Distribution

Distribute P2P traffic across multiple VPN exits:

```bash
#!/bin/bash
# Configure torrent client to use load-balanced VPN

# Example for transmission-daemon
cat > transmission-vpn.json << EOF
{
    "bind-address-ipv4": "17.0.0.1",
    "peer-port": 51413,
    "port-forwarding-enabled": false,
    "proxy": "http://17.0.0.1:8080",
    "proxy-auth-enabled": false,
    "proxy-enabled": true,
    "proxy-type": "http"
}
EOF

echo "Transmission configured to use VPN load balancer"
echo "Traffic will be distributed across all VPN exits"
```

### 4. Development and Testing

Use the cluster for development testing across regions:

```bash
#!/bin/bash
# Test application behavior from different locations

APP_URL="https://your-app.com/api/test"

echo "Testing application from multiple VPN exits..."

# Function to test via specific worker
test_via_worker() {
    local worker=$1
    local worker_name=$2

    echo "Testing via $worker_name ($worker):"

    response_time=$(ssh root@$worker "
        start_time=\$(date +%s%3N)
        curl -s --max-time 10 '$APP_URL' >/dev/null
        end_time=\$(date +%s%3N)
        echo \$((end_time - start_time))
    ")

    external_ip=$(ssh root@$worker "curl -s ipinfo.io/ip")
    location=$(ssh root@$worker "curl -s ipinfo.io/\$external_ip/city")

    echo "  Response time: ${response_time}ms"
    echo "  External IP: $external_ip ($location)"
    echo ""
}

# Test via each worker
test_via_worker "17.0.0.10" "Worker 1"
test_via_worker "17.0.0.11" "Worker 2"
test_via_worker "17.0.0.12" "Worker 3"

# Test via load balancer (random distribution)
echo "Testing via load balancer (random worker selection):"
for i in {1..3}; do
    response_time=$(curl -s --max-time 10 -w "%{time_total}" http://17.0.0.1:8080/ -o /dev/null)
    echo "  Request $i: ${response_time}s"
done
```

## Monitoring and Management

### HAProxy Statistics Dashboard

Access real-time load balancer statistics:

```bash
# View statistics in browser
open http://17.0.0.1:8404/stats

# Get backend status via CLI
curl -s http://17.0.0.1:8404/stats | grep -E "(lazarus[1-3]|vpn[1-3])" | grep UP

# Monitor connection counts
curl -s http://17.0.0.1:8404/stats | grep -o "Total</th><td>[0-9]*" | grep -o "[0-9]*"
```

### VPN Connection Monitoring

Monitor VPN connection status across workers:

```bash
#!/bin/bash
# VPN cluster monitoring script

echo "=== VPN Cluster Status ==="
echo "Timestamp: $(date)"
echo ""

for worker in 17.0.0.10 17.0.0.11 17.0.0.12; do
    worker_num=$(($(echo $worker | cut -d. -f4) - 9))
    echo "Worker $worker_num ($worker):"

    ssh -o ConnectTimeout=5 root@$worker "
        # VPN process status
        if ps | grep -q openvpn; then
            echo '  OpenVPN: ✅ Running'
        else
            echo '  OpenVPN: ❌ Down'
        fi

        # TUN interface status
        if ip link show tun0 >/dev/null 2>&1; then
            vpn_ip=\$(ip addr show tun0 | grep 'inet ' | awk '{print \$2}' | cut -d/ -f1)
            echo \"  VPN IP: \$vpn_ip\"
        else
            echo '  VPN IP: Not connected'
        fi

        # External IP and location
        external_ip=\$(curl -s --max-time 8 ipinfo.io/ip 2>/dev/null)
        if [ -n \"\$external_ip\" ]; then
            location=\$(curl -s --max-time 5 \"ipinfo.io/\$external_ip/city\" 2>/dev/null)
            echo \"  External: \$external_ip (\$location)\"
        else
            echo '  External: Unable to determine'
        fi

        # VPN server info
        server=\$(grep '^remote ' /etc/openvpn/client.conf | head -1 | awk '{print \$2}')
        echo \"  Server: \$server\"
    " 2>/dev/null || echo "  ❌ Connection failed"
    echo ""
done

# HAProxy backend health
echo "HAProxy Backend Health:"
healthy_backends=$(curl -s http://17.0.0.1:8404/stats | grep -c "UP</td>" 2>/dev/null)
echo "  Healthy backends: $healthy_backends"
```

### Service Management

Common management tasks:

```bash
# Restart all VPN connections
for worker in 17.0.0.10 17.0.0.11 17.0.0.12; do
    ssh root@$worker "/etc/init.d/openvpn restart"
done

# Change VPN profiles (get new exit points)
for worker in 17.0.0.10 17.0.0.11 17.0.0.12; do
    ssh root@$worker "
        /etc/init.d/openvpn stop
        cd /etc/openvpn
        ./select-random-profile.sh
        /etc/init.d/openvpn start
    "
done

# Restart HAProxy load balancer
ssh root@17.0.0.1 "/etc/init.d/haproxy restart"

# Update HAProxy configuration for more workers
./setup-cluster.sh haproxy 5  # Generate config for 5 workers
scp haproxy-cluster.cfg root@17.0.0.1:/etc/haproxy.cfg
ssh root@17.0.0.1 "/etc/init.d/haproxy restart"
```

## Client Configuration Examples

### HTTP Proxy Configuration

Configure applications to use the load balancer as an HTTP proxy:

```bash
# Environment variables
export http_proxy="http://17.0.0.1:8080"
export https_proxy="http://17.0.0.1:8080"

# wget with proxy
wget --proxy-on --proxy-user="" --proxy-password="" \
     -e http_proxy=17.0.0.1:8080 \
     https://example.com

# curl with proxy
curl --proxy http://17.0.0.1:8080 https://example.com
```

### Application Integration

#### Python Applications

```python
import requests

# Configure session to use VPN load balancer
session = requests.Session()
session.proxies = {
    'http': 'http://17.0.0.1:8080',
    'https': 'http://17.0.0.1:8080'
}

# All requests will be load balanced across VPN exits
response = session.get('https://ipinfo.io/ip')
print(f"External IP: {response.text}")
```

#### Node.js Applications

```javascript
const axios = require('axios');

// Configure axios to use VPN load balancer
const vpnClient = axios.create({
  proxy: {
    host: '17.0.0.1',
    port: 8080,
    protocol: 'http'
  },
  timeout: 10000
});

// Test request through VPN cluster
vpnClient.get('https://ipinfo.io/ip')
  .then(response => {
    console.log('External IP:', response.data);
  });
```

#### Browser Configuration

Configure browsers to use the VPN load balancer:

```bash
# Chrome with proxy
google-chrome --proxy-server="http://17.0.0.1:8080"

# Firefox proxy configuration
# Manual proxy configuration:
# HTTP Proxy: 17.0.0.1 Port: 8080
# Use this proxy server for all protocols: ✓
```

## UDP Traffic Examples

While the current setup uses TCP mode for HAProxy, here are examples for UDP traffic:

### Direct UDP to Workers

```bash
# Send UDP packets directly to workers (bypassing load balancer)
echo "UDP test message" | nc -u 17.0.0.10 53  # DNS query to Worker 1
echo "UDP test message" | nc -u 17.0.0.11 53  # DNS query to Worker 2
echo "UDP test message" | nc -u 17.0.0.12 53  # DNS query to Worker 3
```

### DNS Load Balancing

Set up DNS queries through different VPN exits:

```bash
#!/bin/bash
# DNS queries through different VPN exits

DOMAINS=("example.com" "google.com" "github.com")
WORKERS=("17.0.0.10" "17.0.0.11" "17.0.0.12")

for domain in "${DOMAINS[@]}"; do
    echo "Resolving $domain from different VPN exits:"

    for worker in "${WORKERS[@]}"; do
        result=$(ssh root@$worker "nslookup $domain | grep 'Address:' | tail -1")
        external_ip=$(ssh root@$worker "curl -s --max-time 5 ipinfo.io/ip")
        echo "  via $worker ($external_ip): $result"
    done
    echo ""
done
```

## Performance Testing

### Bandwidth Testing

Test bandwidth through each VPN exit:

```bash
#!/bin/bash
# Bandwidth testing through VPN cluster

echo "Testing bandwidth through each VPN exit..."

for worker in 17.0.0.10 17.0.0.11 17.0.0.12; do
    worker_num=$(($(echo $worker | cut -d. -f4) - 9))
    echo "Worker $worker_num ($worker):"

    # Download speed test
    ssh root@$worker "
        echo '  Testing download speed...'
        curl -s --max-time 30 -w 'Speed: %{speed_download} bytes/sec\n' \
             -o /dev/null http://speedtest.wdc01.softlayer.com/downloads/test10.zip
    "

    echo ""
done
```

### Latency Testing

Test latency through different VPN exits:

```bash
#!/bin/bash
# Latency testing script

TARGETS=("8.8.8.8" "1.1.1.1" "208.67.222.222")

echo "Testing latency through VPN cluster..."

for worker in 17.0.0.10 17.0.0.11 17.0.0.12; do
    worker_num=$(($(echo $worker | cut -d. -f4) - 9))
    external_ip=$(ssh root@$worker "curl -s --max-time 5 ipinfo.io/ip")

    echo "Worker $worker_num ($worker) - Exit: $external_ip"

    for target in "${TARGETS[@]}"; do
        latency=$(ssh root@$worker "ping -c 3 $target | grep 'avg' | cut -d'/' -f5")
        echo "  $target: ${latency}ms"
    done
    echo ""
done
```

## Load Balancing Verification

### Traffic Distribution Analysis

Verify that traffic is being distributed evenly:

```bash
#!/bin/bash
# Traffic distribution analysis

REQUESTS=30
LOAD_BALANCER="17.0.0.1:8080"

declare -A worker_counts

echo "Sending $REQUESTS requests through load balancer..."

for i in $(seq 1 $REQUESTS); do
    # Send request and identify which worker responded
    response=$(curl -s --max-time 5 http://$LOAD_BALANCER/)

    # Try to identify worker from response
    if echo "$response" | grep -q "17.0.0.10"; then
        worker_counts["17.0.0.10"]=$((${worker_counts["17.0.0.10"]:-0} + 1))
    elif echo "$response" | grep -q "17.0.0.11"; then
        worker_counts["17.0.0.11"]=$((${worker_counts["17.0.0.11"]:-0} + 1))
    elif echo "$response" | grep -q "17.0.0.12"; then
        worker_counts["17.0.0.12"]=$((${worker_counts["17.0.0.12"]:-0} + 1))
    else
        worker_counts["unknown"]=$((${worker_counts["unknown"]:-0} + 1))
    fi

    [ $((i % 10)) -eq 0 ] && echo "  Completed $i/$REQUESTS requests"
done

echo ""
echo "Distribution Results:"
for worker in 17.0.0.10 17.0.0.11 17.0.0.12 unknown; do
    count=${worker_counts[$worker]:-0}
    percentage=$((count * 100 / REQUESTS))
    echo "  $worker: $count requests ($percentage%)"
done
```

## Security Considerations

### VPN Provider Diversity

For maximum anonymity, configure different VPN providers on each worker:

```bash
# Example: Configure different providers
# Worker 1: ProtonVPN (already configured)
# Worker 2: ExpressVPN
# Worker 3: NordVPN

# This requires separate VPN provider accounts and configurations
```

### Traffic Isolation

Ensure traffic isolation between workers:

```bash
# Check that workers can't see each other's traffic
for worker in 17.0.0.10 17.0.0.11 17.0.0.12; do
    echo "Worker $worker network isolation:"
    ssh root@$worker "
        # Check routing - should not route to other workers' VPN traffic
        ip route show | grep -v '17.0.0.0/24'

        # Check firewall rules
        iptables -L INPUT | grep -E 'DROP|REJECT' || echo 'No explicit isolation rules'
    "
done
```

## Troubleshooting Commands

### Check VPN Status

```bash
# Quick status check
./tests/quick-test.sh

# Detailed VPN status
./tests/test-vpn-endpoints.sh

# Check specific worker
ssh root@17.0.0.10 "
    ps | grep openvpn
    ip addr show tun0
    ip route show | grep tun0
    curl -s ipinfo.io/ip
"
```

### Restart Problematic Workers

```bash
# Restart specific worker VPN
ssh root@17.0.0.11 "
    /etc/init.d/openvpn stop
    sleep 5
    cd /etc/openvpn
    ./select-random-profile.sh
    /etc/init.d/openvpn start
"

# Check if routing needs fixing
ssh root@17.0.0.11 "
    if ip link show tun0 >/dev/null 2>&1; then
        ip route del default via 13.0.0.254 dev phy0-sta0 2>/dev/null || true
        ip route add default via 10.96.0.1 dev tun0 metric 50
    fi
"
```

### HAProxy Management

```bash
# View HAProxy configuration
ssh root@17.0.0.1 "cat /etc/haproxy.cfg"

# Check HAProxy logs
ssh root@17.0.0.1 "logread | grep haproxy"

# Test HAProxy health checks
ssh root@17.0.0.1 "haproxy -c -f /etc/haproxy.cfg"

# Restart HAProxy
ssh root@17.0.0.1 "/etc/init.d/haproxy restart"
```

## Performance Optimization

### Connection Tuning

Optimize for high-throughput applications:

```bash
# Increase HAProxy connection limits
ssh root@17.0.0.1 "
sed -i 's/maxconn 4096/maxconn 8192/' /etc/haproxy.cfg
sed -i 's/ulimit-n 65535/ulimit-n 131072/' /etc/haproxy.cfg
/etc/init.d/haproxy restart
"

# Optimize network buffer sizes on workers
for worker in 17.0.0.10 17.0.0.11 17.0.0.12; do
    ssh root@$worker "
        echo 'net.core.rmem_max = 67108864' >> /etc/sysctl.conf
        echo 'net.core.wmem_max = 67108864' >> /etc/sysctl.conf
        sysctl -p
    "
done
```

### Load Balancing Algorithms

Switch between different load balancing methods:

```bash
# Round-robin (default)
sed -i 's/balance .*/balance roundrobin/' /etc/haproxy.cfg

# Least connections
sed -i 's/balance .*/balance leastconn/' /etc/haproxy.cfg

# Source IP hashing (session persistence)
sed -i 's/balance .*/balance source/' /etc/haproxy.cfg

# Apply changes
ssh root@17.0.0.1 "/etc/init.d/haproxy restart"
```

## Scaling Operations

### Adding More Workers

Use the cluster management scripts to add workers:

```bash
# Configure additional workers (4-10)
./setup-cluster.sh configure 4   # Worker 4 → 17.0.0.13
./setup-cluster.sh configure 5   # Worker 5 → 17.0.0.14

# Generate updated HAProxy configuration
./setup-cluster.sh haproxy 5     # Update for 5 workers

# Apply new configuration
scp haproxy-cluster.cfg root@17.0.0.1:/etc/haproxy.cfg
ssh root@17.0.0.1 "/etc/init.d/haproxy restart"
```

### Automated Deployment

```bash
#!/bin/bash
# Automated cluster expansion script

TOTAL_WORKERS=$1

if [ -z "$TOTAL_WORKERS" ]; then
    echo "Usage: $0 <total_workers>"
    echo "Example: $0 8  # Deploy 8-worker cluster"
    exit 1
fi

echo "Deploying $TOTAL_WORKERS worker cluster..."

# Generate HAProxy configuration for desired size
./setup-cluster.sh haproxy $TOTAL_WORKERS

# Apply to master router
scp haproxy-cluster.cfg root@17.0.0.1:/etc/haproxy.cfg
ssh root@17.0.0.1 "/etc/init.d/haproxy restart"

echo "Cluster configuration updated for $TOTAL_WORKERS workers"
echo "Connect and configure additional worker boxes as needed"
```

This usage guide provides comprehensive examples for leveraging your distributed VPN load balancer for various protocols and applications.