#!/bin/bash
# Comprehensive Test Runner for Distributed VPN Load Balancer
# Runs all test suites and generates summary report

TEST_DIR="$(dirname "$0")"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG_FILE="test_results_${TIMESTAMP}.log"

echo "========================================="
echo "🧪 DISTRIBUTED VPN CLUSTER TEST SUITE"
echo "========================================="
echo "Timestamp: $(date)"
echo "Log file: $LOG_FILE"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test result tracking
declare -A test_results

# Function to run a test and capture results
run_test() {
    local test_name="$1"
    local test_script="$2"
    local test_description="$3"

    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}🧪 Running: $test_name${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo "Description: $test_description"
    echo ""

    if [ ! -f "$test_script" ]; then
        echo -e "${RED}❌ Test script not found: $test_script${NC}"
        test_results["$test_name"]="MISSING"
        return 1
    fi

    # Make test executable
    chmod +x "$test_script"

    # Run test and capture output
    echo "Running test script: $test_script"
    echo ""

    if timeout 300 bash "$test_script" 2>&1 | tee -a "$LOG_FILE"; then
        test_results["$test_name"]="PASSED"
        echo -e "${GREEN}✅ $test_name completed successfully${NC}"
    else
        test_results["$test_name"]="FAILED"
        echo -e "${RED}❌ $test_name failed or timed out${NC}"
    fi

    echo ""
    echo "Press Enter to continue to next test..."
    read -r
}

# Pre-flight checks
preflight_checks() {
    echo -e "${BLUE}🔍 Pre-flight Checks${NC}"
    echo "==================="

    # Check if master router is accessible
    if ping -c 1 -W 2 17.0.0.1 >/dev/null 2>&1; then
        echo "✅ Master router (17.0.0.1) is reachable"
    else
        echo -e "${RED}❌ Master router (17.0.0.1) is not reachable${NC}"
        echo "Please ensure the master router is connected and accessible."
        exit 1
    fi

    # Check worker connectivity
    workers_online=0
    for worker in 17.0.0.10 17.0.0.11 17.0.0.12; do
        if ping -c 1 -W 2 $worker >/dev/null 2>&1; then
            echo "✅ Worker $worker is reachable"
            workers_online=$((workers_online + 1))
        else
            echo -e "${YELLOW}⚠️  Worker $worker is not reachable${NC}"
        fi
    done

    echo ""
    echo "Workers online: $workers_online/3"

    if [ $workers_online -eq 0 ]; then
        echo -e "${RED}❌ No workers are accessible. Cannot run tests.${NC}"
        exit 1
    elif [ $workers_online -lt 3 ]; then
        echo -e "${YELLOW}⚠️  Some workers are offline. Tests will run on available workers.${NC}"
    else
        echo -e "${GREEN}✅ All workers are accessible${NC}"
    fi

    echo ""
}

# Generate summary report
generate_summary() {
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}📋 TEST SUMMARY REPORT${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo "Test run completed: $(date)"
    echo "Log file: $LOG_FILE"
    echo ""

    echo "Test Results:"
    echo "============="

    local total_tests=0
    local passed_tests=0
    local failed_tests=0

    for test_name in "${!test_results[@]}"; do
        result="${test_results[$test_name]}"
        total_tests=$((total_tests + 1))

        case $result in
            "PASSED")
                echo -e "  ✅ $test_name: ${GREEN}PASSED${NC}"
                passed_tests=$((passed_tests + 1))
                ;;
            "FAILED")
                echo -e "  ❌ $test_name: ${RED}FAILED${NC}"
                failed_tests=$((failed_tests + 1))
                ;;
            "MISSING")
                echo -e "  ⚠️  $test_name: ${YELLOW}MISSING${NC}"
                failed_tests=$((failed_tests + 1))
                ;;
        esac
    done

    echo ""
    echo "Summary:"
    echo "========"
    echo "Total tests: $total_tests"
    echo -e "Passed: ${GREEN}$passed_tests${NC}"
    echo -e "Failed: ${RED}$failed_tests${NC}"

    if [ $failed_tests -eq 0 ]; then
        echo -e "${GREEN}🎉 All tests passed! Distributed VPN cluster is fully operational.${NC}"
    else
        echo -e "${YELLOW}⚠️  Some tests failed. Check the log file for details: $LOG_FILE${NC}"
    fi

    echo ""
    echo "Next Steps:"
    echo "==========="
    if [ $failed_tests -eq 0 ]; then
        echo "✅ System ready for production use"
        echo "✅ Ready to scale to more worker boxes"
        echo "✅ Configure different VPN providers for even more diversity"
    else
        echo "🔧 Review failed tests and fix issues"
        echo "🔧 Re-run individual test scripts for debugging"
    fi

    echo ""
    echo "Monitoring URLs:"
    echo "==============="
    echo "• HAProxy Statistics: http://17.0.0.1:8404/stats"
    echo "• LuCI Web Interface: http://17.0.0.1/cgi-bin/luci"
    echo ""
}

# Main test execution
main() {
    # Start logging
    echo "Test session started: $(date)" > "$LOG_FILE"
    echo "=========================================" >> "$LOG_FILE"

    preflight_checks

    echo -e "${BLUE}Starting comprehensive test suite...${NC}"
    echo ""

    # Run all test suites
    run_test "VPN Endpoints" \
             "$TEST_DIR/test-vpn-endpoints.sh" \
             "Tests VPN connections, external IPs, and routing"

    run_test "TCP Load Balancer" \
             "$TEST_DIR/test-tcp-load-balancer.sh" \
             "Tests TCP traffic distribution across workers"

    run_test "UDP Load Balancer" \
             "$TEST_DIR/test-udp-load-balancer.sh" \
             "Tests UDP configuration and VPN port setup"

    run_test "HTTP Load Balancer" \
             "$TEST_DIR/test-http-load-balancer.sh" \
             "Tests HTTP traffic and external IP diversity"

    # Generate final summary
    generate_summary

    echo "Test session completed: $(date)" >> "$LOG_FILE"
    echo "Full test output saved to: $LOG_FILE"
}

# Check if running in CI or automated environment
if [ "$1" = "--ci" ]; then
    # Run without interactive prompts for CI
    echo "Running in CI mode (non-interactive)"
    main | tee "$LOG_FILE"
else
    # Interactive mode
    main
fi