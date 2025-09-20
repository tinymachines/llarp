#!/bin/bash
# HTTP/HTTPS Load Balancer Test Suite
# Tests web traffic distribution and external IP verification

MASTER_IP="17.0.0.1"
HTTP_PORT="80"
HTTPS_PORT="9443"
WORKERS=("17.0.0.10" "17.0.0.11" "17.0.0.12")
TEST_ITERATIONS=9

echo "========================================="
echo "HTTP/HTTPS Load Balancer Test Suite"
echo "========================================="
echo "Master: $MASTER_IP"
echo "Workers: ${WORKERS[*]}"
echo "Test iterations: $TEST_ITERATIONS"
echo ""

# Set up simple HTTP servers on each worker
setup_http_servers() {
    echo "🔧 Setting up HTTP servers on workers..."
    for worker in "${WORKERS[@]}"; do
        echo "Setting up HTTP server on $worker:$HTTP_PORT"
        ssh -o ConnectTimeout=5 root@$worker "
            # Kill any existing HTTP servers
            pkill -f 'uhttpd.*$HTTP_PORT' 2>/dev/null || true

            # Create simple index page with worker identification
            mkdir -p /tmp/www
            cat > /tmp/www/index.html << EOF
<!DOCTYPE html>
<html>
<head><title>Worker $worker</title></head>
<body>
    <h1>Worker $worker Response</h1>
    <p>Timestamp: \$(date)</p>
    <p>VPN Status: \$(ip addr show tun0 2>/dev/null | grep 'inet ' | awk '{print \$2}' || echo 'No VPN')</p>
    <p>External IP: <span id='external-ip'>Loading...</span></p>
    <script>
        fetch('https://ipinfo.io/ip').then(r=>r.text()).then(ip=>{
            document.getElementById('external-ip').innerText = ip;
        }).catch(()=>{
            document.getElementById('external-ip').innerText = 'Unable to fetch';
        });
    </script>
</body>
</html>
EOF

            # Start simple HTTP server using uhttpd
            uhttpd -f -p $HTTP_PORT -h /tmp/www &
            echo 'HTTP server started on $worker:$HTTP_PORT'
        " 2>/dev/null || echo "  ❌ Failed to setup HTTP server on $worker"
    done

    echo "⏱️  Waiting 3 seconds for servers to start..."
    sleep 3
}

# Test HTTP load balancing
test_http_distribution() {
    echo "🧪 Testing HTTP load balancing distribution..."
    echo "Sending $TEST_ITERATIONS HTTP requests to $MASTER_IP:$HTTP_PORT"
    echo ""

    declare -A response_counts

    for i in $(seq 1 $TEST_ITERATIONS); do
        # Send HTTP request through load balancer
        response=$(timeout 5 curl -s http://$MASTER_IP:$HTTP_PORT/ 2>/dev/null)

        if [ -n "$response" ]; then
            # Extract worker IP from HTML response
            worker_ip=$(echo "$response" | grep -o 'Worker 17\.0\.0\.[0-9]*' | grep -o '17\.0\.0\.[0-9]*')
            if [ -n "$worker_ip" ]; then
                response_counts[$worker_ip]=$((${response_counts[$worker_ip]:-0} + 1))
                echo "HTTP Request $i: Routed to $worker_ip"
            else
                echo "HTTP Request $i: Could not identify worker"
            fi
        else
            echo "HTTP Request $i: No response (timeout/error)"
        fi

        sleep 0.5
    done

    echo ""
    echo "📊 HTTP Distribution Results:"
    echo "----------------------------"
    total_responses=0
    for worker in "${WORKERS[@]}"; do
        count=${response_counts[$worker]:-0}
        total_responses=$((total_responses + count))
        percentage=$(( count * 100 / TEST_ITERATIONS ))
        echo "Worker $worker: $count requests ($percentage%)"
    done

    if [ $total_responses -gt 0 ]; then
        echo "✅ HTTP load balancing functional"
    else
        echo "❌ HTTP load balancing not working"
    fi
}

# Test external IP diversity through VPN
test_external_ip_diversity() {
    echo "🌍 Testing VPN external IP diversity..."
    echo "Checking external IPs through each worker's VPN..."
    echo ""

    declare -A external_ips

    for worker in "${WORKERS[@]}"; do
        echo "Checking external IP via $worker..."

        # Get external IP by connecting directly to worker
        external_ip=$(ssh -o ConnectTimeout=5 root@$worker "
            curl -s --max-time 10 ipinfo.io/ip 2>/dev/null ||
            curl -s --max-time 10 ifconfig.me 2>/dev/null ||
            echo 'Unable to fetch'
        " 2>/dev/null)

        if [ -n "$external_ip" ] && [ "$external_ip" != "Unable to fetch" ]; then
            external_ips[$worker]=$external_ip
            echo "  Worker $worker: External IP $external_ip"
        else
            echo "  Worker $worker: ❌ Could not determine external IP"
        fi
    done

    echo ""
    echo "🔍 VPN Exit Diversity Analysis:"
    echo "------------------------------"

    # Check for unique external IPs
    unique_ips=$(printf '%s\n' "${external_ips[@]}" | sort -u | wc -l)
    total_workers=${#external_ips[@]}

    echo "Total workers with external IPs: $total_workers"
    echo "Unique external IPs: $unique_ips"

    if [ $unique_ips -eq $total_workers ] && [ $total_workers -gt 1 ]; then
        echo "✅ Excellent! Each worker has a different external IP (VPN diversity working)"
    elif [ $unique_ips -gt 1 ]; then
        echo "⚠️  Some VPN diversity present ($unique_ips different IPs)"
    else
        echo "❌ No VPN diversity - all workers may be using same exit"
    fi

    # List all external IPs
    echo ""
    echo "External IP List:"
    for worker in "${!external_ips[@]}"; do
        echo "  $worker → ${external_ips[$worker]}"
    done
}

# Test HAProxy statistics
test_haproxy_stats() {
    echo "📈 Testing HAProxy statistics interface..."

    stats_response=$(curl -s --max-time 5 http://$MASTER_IP:8404/stats 2>/dev/null)

    if [ -n "$stats_response" ]; then
        echo "✅ HAProxy statistics accessible at http://$MASTER_IP:8404/stats"

        # Check for backend status
        if echo "$stats_response" | grep -q "tcp_backend"; then
            echo "✅ TCP backend configured in statistics"
        fi

        if echo "$stats_response" | grep -q "udp_backend"; then
            echo "✅ UDP backend configured in statistics"
        fi

        # Count active servers
        active_servers=$(echo "$stats_response" | grep -c "UP</td>")
        echo "Active backend servers: $active_servers"

    else
        echo "❌ HAProxy statistics not accessible"
    fi
    echo ""
}

# Cleanup function
cleanup_http_servers() {
    echo "🧹 Cleaning up HTTP test servers..."
    for worker in "${WORKERS[@]}"; do
        ssh -o ConnectTimeout=5 root@$worker "pkill -f 'uhttpd.*$HTTP_PORT' 2>/dev/null || true" 2>/dev/null
    done
}

# Main test execution
main() {
    echo "Starting HTTP Load Balancer Tests..."
    echo ""

    # Trap to ensure cleanup on exit
    trap cleanup_http_servers EXIT

    test_haproxy_stats
    setup_http_servers
    test_http_distribution
    test_external_ip_diversity

    echo ""
    echo "========================================="
    echo "HTTP Load Balancer Test Complete"
    echo "========================================="
}

# Check dependencies
check_dependencies() {
    local missing_deps=()

    command -v curl >/dev/null 2>&1 || missing_deps+=("curl")
    command -v nc >/dev/null 2>&1 || missing_deps+=("netcat")

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "❌ Missing dependencies: ${missing_deps[*]}"
        echo "Install with: apt-get install ${missing_deps[*]}"
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