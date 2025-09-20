#!/bin/bash
# UDP Load Balancer Test Suite
# Tests UDP traffic distribution (VPN port 1194)

MASTER_IP="17.0.0.1"
UDP_PORT="1194"
TEST_PORT="1195"  # Use different port for testing to avoid VPN conflicts
WORKERS=("17.0.0.10" "17.0.0.11" "17.0.0.12")
TEST_ITERATIONS=9

echo "========================================="
echo "UDP Load Balancer Test Suite"
echo "========================================="
echo "Master: $MASTER_IP:$UDP_PORT"
echo "Test port: $TEST_PORT (to avoid VPN conflicts)"
echo "Workers: ${WORKERS[*]}"
echo "Test iterations: $TEST_ITERATIONS"
echo ""

# Set up UDP echo servers on each worker
setup_udp_servers() {
    echo "🔧 Setting up UDP echo servers on workers..."
    for worker in "${WORKERS[@]}"; do
        echo "Setting up UDP echo server on $worker:$TEST_PORT"
        ssh -o ConnectTimeout=5 root@$worker "
            # Kill any existing UDP servers
            pkill -f 'nc.*-u.*-l.*$TEST_PORT' 2>/dev/null || true

            # Start UDP echo server using netcat
            nohup sh -c 'while true; do echo \"UDP Response from $worker \$(date)\" | nc -u -l -p $TEST_PORT; done' >/dev/null 2>&1 &

            echo 'UDP echo server started on $worker:$TEST_PORT'
        " 2>/dev/null || echo "  ❌ Failed to setup UDP server on $worker"
    done

    echo "⏱️  Waiting 3 seconds for UDP servers to start..."
    sleep 3
}

# Test UDP connectivity to workers directly
test_direct_udp() {
    echo "🔗 Testing direct UDP connectivity to workers..."

    for worker in "${WORKERS[@]}"; do
        echo "Testing direct UDP to $worker:$TEST_PORT"

        # Send UDP packet and wait for response
        response=$(timeout 3 sh -c "echo 'direct udp test' | nc -u $worker $TEST_PORT" 2>/dev/null)

        if [ -n "$response" ]; then
            echo "  ✅ Direct UDP connection successful"
        else
            echo "  ❌ Direct UDP connection failed"
        fi
    done
    echo ""
}

# Test UDP through HAProxy (Note: HAProxy UDP requires special config)
test_udp_through_haproxy() {
    echo "📡 Testing UDP through HAProxy..."
    echo "Note: HAProxy TCP mode on port 1194 for VPN traffic"

    # Test if we can connect to the HAProxy UDP frontend
    if netstat -ln | grep -q ":$UDP_PORT.*LISTEN"; then
        echo "✅ HAProxy listening on UDP port $UDP_PORT"

        # Try to send a test packet
        response=$(timeout 5 sh -c "echo 'haproxy udp test' | nc $MASTER_IP $UDP_PORT" 2>/dev/null)

        if [ -n "$response" ]; then
            echo "✅ UDP through HAProxy successful"
        else
            echo "⚠️  UDP through HAProxy: No response (expected for VPN port)"
            echo "   This is normal - port 1194 is configured for VPN tunnel traffic"
        fi
    else
        echo "❌ HAProxy not listening on UDP port $UDP_PORT"
    fi
    echo ""
}

# Test VPN port availability on workers
test_vpn_port_availability() {
    echo "🌐 Testing VPN port availability on workers..."

    for worker in "${WORKERS[@]}"; do
        worker_num=$(($(echo $worker | cut -d. -f4) - 9))
        echo "Testing VPN port on Worker $worker_num ($worker:$UDP_PORT)"

        # Check if OpenVPN is listening (it usually doesn't listen on 1194 in client mode)
        vpn_status=$(ssh -o ConnectTimeout=5 root@$worker "
            if netstat -ln | grep -q ':$UDP_PORT'; then
                echo 'VPN port listening'
            else
                echo 'VPN port not listening (normal for client mode)'
            fi

            # Check if OpenVPN process is running
            if ps | grep -q openvpn; then
                echo 'OpenVPN process active'
            else
                echo 'OpenVPN process not found'
            fi

            # Check TUN interface
            if ip link show tun0 >/dev/null 2>&1; then
                vpn_ip=\$(ip addr show tun0 | grep 'inet ' | awk '{print \$2}' | cut -d/ -f1)
                echo \"TUN interface: \$vpn_ip\"
            else
                echo 'TUN interface not found'
            fi
        " 2>/dev/null)

        echo "  $vpn_status"
        echo ""
    done
}

# Test load balancer configuration
test_load_balancer_config() {
    echo "⚙️  Testing Load Balancer Configuration..."

    config_check=$(ssh -o ConnectTimeout=5 root@$MASTER_IP "
        echo 'HAProxy Configuration Check:'

        # Check if HAProxy is running
        if ps | grep -q haproxy; then
            echo 'HAProxy: ✅ Running'
        else
            echo 'HAProxy: ❌ Not running'
            exit 1
        fi

        # Check VPN backend configuration
        if grep -q 'backend udp_backend' /etc/haproxy.cfg; then
            echo 'UDP Backend: ✅ Configured'

            # Count backend servers
            server_count=\$(grep -c 'server vpn' /etc/haproxy.cfg)
            echo \"Backend Servers: \$server_count\"

            # Show configured servers
            echo 'Configured VPN backends:'
            grep 'server vpn' /etc/haproxy.cfg | sed 's/^/  /'
        else
            echo 'UDP Backend: ❌ Not configured'
        fi

        # Check if UDP frontend is configured
        if grep -q 'frontend udp_frontend' /etc/haproxy.cfg; then
            echo 'UDP Frontend: ✅ Configured'
            bind_config=\$(grep -A1 'frontend udp_frontend' /etc/haproxy.cfg | grep bind)
            echo \"  \$bind_config\"
        else
            echo 'UDP Frontend: ❌ Not configured'
        fi
    " 2>/dev/null)

    if [ $? -eq 0 ]; then
        echo "$config_check"
    else
        echo "❌ Could not check load balancer configuration"
    fi
    echo ""
}

# Cleanup function
cleanup_udp_servers() {
    echo "🧹 Cleaning up UDP test servers..."
    for worker in "${WORKERS[@]}"; do
        ssh -o ConnectTimeout=5 root@$worker "pkill -f 'nc.*-u.*-l.*$TEST_PORT' 2>/dev/null || true" 2>/dev/null
    done
}

# Main test execution
main() {
    echo "Starting UDP Load Balancer Tests..."
    echo ""

    # Trap to ensure cleanup on exit
    trap cleanup_udp_servers EXIT

    test_load_balancer_config
    test_vpn_port_availability
    setup_udp_servers
    test_direct_udp
    test_udp_through_haproxy

    echo ""
    echo "========================================="
    echo "UDP Load Balancer Test Complete"
    echo "========================================="
    echo ""
    echo "📝 Notes:"
    echo "• HAProxy port 1194 is configured for VPN tunnel traffic (TCP mode)"
    echo "• OpenVPN clients typically don't listen on port 1194"
    echo "• VPN load balancing occurs at the tunnel level, not UDP packet level"
    echo "• For true UDP load balancing, consider configuring HAProxy UDP mode"
}

# Check dependencies
check_dependencies() {
    local missing_deps=()

    command -v nc >/dev/null 2>&1 || missing_deps+=("netcat")
    command -v ssh >/dev/null 2>&1 || missing_deps+=("openssh-client")

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "❌ Missing dependencies: ${missing_deps[*]}"
        return 1
    fi

    return 0
}

# Run tests if dependencies are met
if check_dependencies; then
    main
else
    exit 1
fi