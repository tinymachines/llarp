#!/bin/bash
# VPN Endpoint Test Suite
# Tests VPN connectivity, external IPs, and routing

MASTER_IP="17.0.0.1"
WORKERS=("17.0.0.10" "17.0.0.11" "17.0.0.12")

echo "========================================="
echo "VPN Endpoint Test Suite"
echo "========================================="
echo "Testing VPN connectivity and external IP diversity"
echo "Workers: ${WORKERS[*]}"
echo ""

# Test VPN connection status
test_vpn_connections() {
    echo "🔍 Testing VPN Connection Status..."
    echo "=================================="

    for worker in "${WORKERS[@]}"; do
        echo "Worker $(($(echo $worker | cut -d. -f4) - 9)) ($worker):"

        result=$(ssh -o ConnectTimeout=5 root@$worker "
            # Check OpenVPN process
            if ps | grep -q 'openvpn.*client'; then
                echo 'OpenVPN: ✅ Running'
            else
                echo 'OpenVPN: ❌ Not running'
                exit 1
            fi

            # Check TUN interface
            if ip link show tun0 >/dev/null 2>&1; then
                vpn_ip=\$(ip addr show tun0 | grep 'inet ' | awk '{print \$2}' | cut -d/ -f1)
                echo \"TUN0: ✅ Active (\$vpn_ip)\"
            else
                echo 'TUN0: ❌ Not found'
                exit 1
            fi

            # Check VPN routing
            if ip route show | grep -q 'via.*tun0'; then
                echo 'VPN Routes: ✅ Configured'
            else
                echo 'VPN Routes: ⚠️  May not be fully configured'
            fi

            # Get current profile
            if [ -f /etc/openvpn/client.conf ]; then
                server=\$(grep '^remote ' /etc/openvpn/client.conf | head -1 | awk '{print \$2}')
                echo \"VPN Server: \$server\"
            fi
        " 2>/dev/null)

        if [ $? -eq 0 ]; then
            echo "$result"
        else
            echo "  ❌ VPN connection test failed"
        fi
        echo ""
    done
}

# Test external IP addresses
test_external_ips() {
    echo "🌍 Testing External IP Addresses..."
    echo "=================================="

    declare -A external_ips
    declare -A ip_locations

    for worker in "${WORKERS[@]}"; do
        worker_num=$(($(echo $worker | cut -d. -f4) - 9))
        echo "Checking external IP for Worker $worker_num ($worker)..."

        # Test multiple IP detection services
        external_ip=$(ssh -o ConnectTimeout=10 root@$worker "
            # Try multiple services in case one is blocked
            curl -s --max-time 8 ipinfo.io/ip 2>/dev/null ||
            curl -s --max-time 8 ifconfig.me 2>/dev/null ||
            curl -s --max-time 8 icanhazip.com 2>/dev/null ||
            echo 'Unable to fetch'
        " 2>/dev/null)

        if [ -n "$external_ip" ] && [ "$external_ip" != "Unable to fetch" ]; then
            external_ips[$worker]=$external_ip
            echo "  External IP: $external_ip"

            # Get location info
            location=$(ssh -o ConnectTimeout=10 root@$worker "
                curl -s --max-time 8 'ipinfo.io/$external_ip/city' 2>/dev/null ||
                echo 'Unknown'
            " 2>/dev/null)
            ip_locations[$worker]=$location
            echo "  Location: $location"
        else
            echo "  ❌ Could not determine external IP"
        fi
        echo ""
    done

    # Analyze IP diversity
    echo "📊 VPN Diversity Analysis:"
    echo "========================="

    unique_ips=$(printf '%s\n' "${external_ips[@]}" | sort -u | wc -l)
    total_workers=${#external_ips[@]}

    echo "Workers with external IPs: $total_workers"
    echo "Unique external IPs: $unique_ips"

    if [ $unique_ips -eq $total_workers ] && [ $total_workers -gt 1 ]; then
        echo "✅ Perfect! Each worker has a different external IP"
        echo "✅ VPN diversity is working correctly"
    elif [ $unique_ips -gt 1 ]; then
        echo "⚠️  Partial VPN diversity ($unique_ips different exits)"
    else
        echo "❌ No VPN diversity detected"
    fi

    echo ""
    echo "External IP Summary:"
    for worker in "${!external_ips[@]}"; do
        worker_num=$(($(echo $worker | cut -d. -f4) - 9))
        echo "  Worker $worker_num: ${external_ips[$worker]} (${ip_locations[$worker]})"
    done
    echo ""
}

# Test VPN routing and DNS
test_vpn_routing() {
    echo "🛣️  Testing VPN Routing Configuration..."
    echo "======================================"

    for worker in "${WORKERS[@]}"; do
        worker_num=$(($(echo $worker | cut -d. -f4) - 9))
        echo "Worker $worker_num ($worker):"

        ssh -o ConnectTimeout=5 root@$worker "
            # Check default route
            default_route=\$(ip route show default | head -1)
            if echo \"\$default_route\" | grep -q tun; then
                echo '  Default Route: ✅ Through VPN tunnel'
            else
                echo '  Default Route: ⚠️  Not through VPN'
            fi

            # Check VPN gateway
            vpn_gateway=\$(ip route show | grep 'tun0' | grep 'via' | head -1 | awk '{print \$3}')
            if [ -n \"\$vpn_gateway\" ]; then
                echo \"  VPN Gateway: \$vpn_gateway\"
            fi

            # Test DNS resolution
            if nslookup google.com >/dev/null 2>&1; then
                echo '  DNS Resolution: ✅ Working'
            else
                echo '  DNS Resolution: ❌ Failed'
            fi
        " 2>/dev/null || echo "  ❌ Connection failed"
        echo ""
    done
}

# Test load balancer backend health
test_backend_health() {
    echo "🏥 Testing Backend Health Checks..."
    echo "=================================="

    # Check if HAProxy sees backends as healthy
    stats_output=$(curl -s --max-time 5 http://$MASTER_IP:8404/stats 2>/dev/null)

    if [ -n "$stats_output" ]; then
        echo "HAProxy Backend Status:"

        # Parse stats for each backend
        for worker in "${WORKERS[@]}"; do
            worker_num=$(($(echo $worker | cut -d. -f4) - 9))

            # Check TCP backend
            if echo "$stats_output" | grep -q "lazarus$worker_num.*UP"; then
                echo "  Worker $worker_num TCP: ✅ Healthy"
            else
                echo "  Worker $worker_num TCP: ❌ Down/Unhealthy"
            fi

            # Check VPN backend
            if echo "$stats_output" | grep -q "vpn$worker_num.*UP"; then
                echo "  Worker $worker_num VPN: ✅ Healthy"
            else
                echo "  Worker $worker_num VPN: ❌ Down/Unhealthy"
            fi
        done
    else
        echo "❌ Could not access HAProxy statistics"
    fi
    echo ""
}

# Performance test
test_performance() {
    echo "⚡ Basic Performance Test..."
    echo "==========================="

    echo "Testing response times through load balancer..."

    total_time=0
    successful_requests=0

    for i in $(seq 1 5); do
        start_time=$(date +%s%3N)
        response=$(curl -s --max-time 5 http://$MASTER_IP:$HTTP_PORT/ 2>/dev/null)
        end_time=$(date +%s%3N)

        if [ -n "$response" ]; then
            response_time=$((end_time - start_time))
            total_time=$((total_time + response_time))
            successful_requests=$((successful_requests + 1))
            echo "  Request $i: ${response_time}ms"
        else
            echo "  Request $i: Failed"
        fi
    done

    if [ $successful_requests -gt 0 ]; then
        avg_time=$((total_time / successful_requests))
        echo ""
        echo "Average response time: ${avg_time}ms"
        echo "Success rate: $successful_requests/5 requests"

        if [ $avg_time -lt 1000 ]; then
            echo "✅ Good performance (< 1000ms)"
        else
            echo "⚠️  High latency (> 1000ms)"
        fi
    else
        echo "❌ All requests failed"
    fi
    echo ""
}

# Cleanup function
cleanup() {
    echo "🧹 Cleaning up test servers..."
    for worker in "${WORKERS[@]}"; do
        ssh -o ConnectTimeout=5 root@$worker "
            pkill -f 'uhttpd.*$HTTP_PORT' 2>/dev/null || true
            rm -rf /tmp/www 2>/dev/null || true
        " 2>/dev/null
    done
}

# Main test execution
main() {
    echo "Starting VPN Endpoint Tests..."
    echo ""

    # Trap to ensure cleanup on exit
    trap cleanup EXIT

    test_vpn_connections
    test_external_ips
    test_vpn_routing
    test_backend_health
    test_performance

    echo ""
    echo "========================================="
    echo "VPN Endpoint Test Complete"
    echo "========================================="
}

# Check dependencies
check_dependencies() {
    local missing_deps=()

    command -v curl >/dev/null 2>&1 || missing_deps+=("curl")
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