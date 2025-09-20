#!/bin/bash
# Master Router Configuration Script
# Applies all manual tweaks and optimizations for distributed VPN load balancer

MASTER_IP="17.0.0.1"

echo "=========================================="
echo "Configuring Master Router for VPN Load Balancing"
echo "=========================================="
echo "Master IP: $MASTER_IP"
echo "Role: HAProxy Load Balancer + VPN Orchestrator"
echo "=========================================="

read -p "Continue with master router configuration? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Configuration cancelled."
    exit 1
fi

echo "Starting master router configuration..."

# 1. Install required packages
echo "📦 Installing required packages..."
opkg update
opkg install haproxy curl netcat

# 2. Install USB ethernet drivers (for future USB adapter support)
echo "🔌 Installing USB ethernet drivers..."
opkg install kmod-usb-net kmod-usb-net-asix-ax88179

# 3. Fix LuCI web interface for OpenWRT 24.x
echo "🌐 Fixing LuCI web interface..."
uci delete uhttpd.main.lua_prefix 2>/dev/null || true
uci set uhttpd.main.cgi_prefix='/cgi-bin'
uci set uhttpd.main.rfc1918_filter='0'
uci commit uhttpd
/etc/init.d/uhttpd restart

# 4. Configure HAProxy for switch-based load balancing
echo "⚖️  Configuring HAProxy load balancer..."
cat > /etc/haproxy.cfg << 'EOF'
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
EOF

# 5. Enable and start HAProxy
echo "🚀 Starting HAProxy service..."
/etc/init.d/haproxy enable
/etc/init.d/haproxy start

# 6. Verify services are running
echo "✅ Verifying services..."
sleep 5

echo "Service Status:"
echo "==============="

# Check HAProxy
if /etc/init.d/haproxy status | grep -q "running"; then
    echo "✅ HAProxy: Running"
else
    echo "❌ HAProxy: Not running"
fi

# Check LuCI
if curl -s http://localhost/cgi-bin/luci | grep -q "luci"; then
    echo "✅ LuCI: Accessible"
else
    echo "❌ LuCI: Not accessible"
fi

# Check listening ports
echo ""
echo "Listening Ports:"
echo "==============="
netstat -ln | grep -E ':8080|:8090|:8404|:80' | sed 's/^/  /'

echo ""
echo "=========================================="
echo "Master Router Configuration Complete!"
echo "=========================================="
echo "Services:"
echo "• TCP Load Balancer: http://17.0.0.1:8080"
echo "• VPN Load Balancer: tcp://17.0.0.1:8090"
echo "• HAProxy Statistics: http://17.0.0.1:8404/stats"
echo "• LuCI Management: http://17.0.0.1/cgi-bin/luci"
echo ""
echo "Next Steps:"
echo "1. Image this router for worker deployment"
echo "2. Use configure-worker-box.sh to set up workers"
echo "3. Connect all devices via ethernet switch"
echo "4. Run ./tests/run-all-tests.sh to verify"
echo "=========================================="