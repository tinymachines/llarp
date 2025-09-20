#!/bin/bash
# TCP Load Balancer Test Suite
# Tests round-robin distribution across worker boxes

MASTER_IP="17.0.0.1"
TCP_PORT="8080"
WORKERS=("17.0.0.10" "17.0.0.11" "17.0.0.12")
TEST_ITERATIONS=12

echo "========================================="
echo "TCP Load Balancer Test Suite"
echo "========================================="
echo "Master: $MASTER_IP:$TCP_PORT"
echo "Workers: ${WORKERS[*]}"
echo "Test iterations: $TEST_ITERATIONS"
echo ""

# First, set up a simple TCP echo server on each worker
setup_echo_servers() {
    echo "🔧 Setting up TCP echo servers on workers..."
    for worker in "${WORKERS[@]}"; do
        echo "Setting up echo server on $worker:$TCP_PORT"
        ssh -o ConnectTimeout=5 root@$worker "
            # Kill any existing echo servers
            pkill -f 'nc.*-l.*$TCP_PORT' 2>/dev/null || true

            # Start TCP echo server using netcat
            nohup sh -c 'while true; do echo \"Response from $worker \$(date)\" | nc -l -p $TCP_PORT; done' >/dev/null 2>&1 &

            echo 'Echo server started on $worker:$TCP_PORT'
        " 2>/dev/null || echo "  ❌ Failed to setup echo server on $worker"
    done

    echo "⏱️  Waiting 3 seconds for servers to start..."
    sleep 3
}

# Test TCP load balancing distribution
test_tcp_distribution() {
    echo "🧪 Testing TCP load balancing distribution..."
    echo "Sending $TEST_ITERATIONS requests to $MASTER_IP:$TCP_PORT"
    echo ""

    declare -A response_counts

    for i in $(seq 1 $TEST_ITERATIONS); do
        # Send request through load balancer
        response=$(timeout 5 sh -c "echo 'test request $i' | nc $MASTER_IP $TCP_PORT" 2>/dev/null)

        if [ -n "$response" ]; then
            # Extract worker IP from response
            worker_ip=$(echo "$response" | grep -o '17\.0\.0\.[0-9]*')
            if [ -n "$worker_ip" ]; then
                response_counts[$worker_ip]=$((${response_counts[$worker_ip]:-0} + 1))
                echo "Request $i: Routed to $worker_ip"
            else
                echo "Request $i: Unknown response format"
            fi
        else
            echo "Request $i: No response (timeout/error)"
        fi

        # Small delay between requests
        sleep 0.5
    done

    echo ""
    echo "📊 Distribution Results:"
    echo "----------------------"
    total_responses=0
    for worker in "${WORKERS[@]}"; do
        count=${response_counts[$worker]:-0}
        total_responses=$((total_responses + count))
        percentage=$(( count * 100 / TEST_ITERATIONS ))
        echo "Worker $worker: $count requests ($percentage%)"
    done

    echo ""
    if [ $total_responses -eq $TEST_ITERATIONS ]; then
        echo "✅ All requests received responses"
    else
        echo "⚠️  $((TEST_ITERATIONS - total_responses)) requests failed"
    fi

    # Check if distribution is roughly even (within 40-60% range for 3 workers)
    expected_per_worker=$((TEST_ITERATIONS / 3))
    balanced=true
    for worker in "${WORKERS[@]}"; do
        count=${response_counts[$worker]:-0}
        if [ $count -lt $((expected_per_worker - 2)) ] || [ $count -gt $((expected_per_worker + 2)) ]; then
            balanced=false
        fi
    done

    if [ "$balanced" = true ]; then
        echo "✅ Load balancing appears to be working correctly"
    else
        echo "⚠️  Load balancing may not be evenly distributed"
    fi
}

# Test individual worker connectivity
test_worker_connectivity() {
    echo "🔗 Testing direct worker connectivity..."
    for worker in "${WORKERS[@]}"; do
        echo "Testing direct connection to $worker:$TCP_PORT"
        response=$(timeout 3 sh -c "echo 'direct test' | nc $worker $TCP_PORT" 2>/dev/null)
        if [ -n "$response" ]; then
            echo "  ✅ Direct connection successful"
        else
            echo "  ❌ Direct connection failed"
        fi
    done
    echo ""
}

# Clean up echo servers
cleanup_echo_servers() {
    echo "🧹 Cleaning up echo servers..."
    for worker in "${WORKERS[@]}"; do
        ssh -o ConnectTimeout=5 root@$worker "pkill -f 'nc.*-l.*$TCP_PORT' 2>/dev/null || true" 2>/dev/null
    done
    echo "Cleanup completed."
}

# Main test execution
main() {
    echo "Starting TCP Load Balancer Tests..."
    echo ""

    # Trap to ensure cleanup on exit
    trap cleanup_echo_servers EXIT

    setup_echo_servers
    test_worker_connectivity
    test_tcp_distribution

    echo ""
    echo "========================================="
    echo "TCP Load Balancer Test Complete"
    echo "========================================="
}

# Check if netcat is available
if ! command -v nc >/dev/null 2>&1; then
    echo "❌ Error: netcat (nc) is required for TCP testing"
    echo "Install with: opkg install netcat"
    exit 1
fi

# Run tests
main