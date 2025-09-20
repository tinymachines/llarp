# Distributed VPN Load Balancer Test Suite

This test suite validates the functionality of the distributed VPN load balancer cluster.

## Test Architecture

```
Test Client → Master Router (17.0.0.1) → HAProxy Load Balancer
                              ↓
            ┌─────────────────┼─────────────────┐
            ↓                 ↓                 ↓
      Worker 1            Worker 2            Worker 3
    (17.0.0.10)         (17.0.0.11)         (17.0.0.12)
    ProtonVPN Exit      ProtonVPN Exit      ProtonVPN Exit
```

## Available Tests

### 1. Quick Test (`quick-test.sh`)
**Purpose**: Basic functionality verification
**Duration**: ~10 seconds
**Tests**:
- Worker connectivity
- HAProxy statistics access
- VPN connection status
- Load balancer port availability

```bash
./tests/quick-test.sh
```

### 2. VPN Endpoints Test (`test-vpn-endpoints.sh`)
**Purpose**: Comprehensive VPN functionality testing
**Duration**: ~60 seconds
**Tests**:
- VPN connection verification
- External IP diversity analysis
- VPN routing configuration
- Backend health status
- Basic performance metrics

```bash
./tests/test-vpn-endpoints.sh
```

### 3. TCP Load Balancer Test (`test-tcp-load-balancer.sh`)
**Purpose**: TCP traffic distribution testing
**Duration**: ~45 seconds
**Tests**:
- Round-robin distribution across workers
- TCP echo server setup and testing
- Load balancing effectiveness
- Direct worker connectivity

```bash
./tests/test-tcp-load-balancer.sh
```

### 4. UDP Load Balancer Test (`test-udp-load-balancer.sh`)
**Purpose**: UDP configuration and VPN port testing
**Duration**: ~30 seconds
**Tests**:
- UDP port configuration
- VPN port availability
- HAProxy UDP backend setup
- Load balancer configuration validation

```bash
./tests/test-udp-load-balancer.sh
```

### 5. HTTP Load Balancer Test (`test-http-load-balancer.sh`)
**Purpose**: HTTP traffic distribution and external IP verification
**Duration**: ~90 seconds
**Tests**:
- HTTP request distribution
- External IP diversity through VPN
- Web server response validation
- HAProxy statistics verification

```bash
./tests/test-http-load-balancer.sh
```

### 6. Comprehensive Test Suite (`run-all-tests.sh`)
**Purpose**: Run all tests with detailed reporting
**Duration**: ~5 minutes
**Features**:
- Sequential execution of all test suites
- Detailed logging and reporting
- Interactive mode with pause between tests
- CI mode for automated testing

```bash
# Interactive mode
./tests/run-all-tests.sh

# CI mode (non-interactive)
./tests/run-all-tests.sh --ci
```

## Test Results

Each test generates:
- **Real-time output** with color-coded results
- **Summary statistics** for load balancing effectiveness
- **Performance metrics** where applicable
- **Detailed logs** saved to timestamped files

## Expected Results

### Successful Test Indicators:
- ✅ All workers reachable and responding
- ✅ HAProxy statistics accessible
- ✅ Each worker has different external IP (VPN diversity)
- ✅ Load balancing distributes traffic evenly
- ✅ All VPN connections active with TUN interfaces
- ✅ Response times under 1000ms

### Common Issues:
- ❌ **Auth failures**: VPN credentials may need updating
- ❌ **No TUN interface**: VPN connection not established
- ❌ **Same external IP**: Multiple workers using same VPN exit
- ❌ **Uneven distribution**: Load balancing not working correctly

## Troubleshooting

### VPN Connection Issues:
```bash
# Check OpenVPN logs on worker
ssh root@17.0.0.10 "logread | grep openvpn | tail -10"

# Restart VPN service
ssh root@17.0.0.10 "/etc/init.d/openvpn restart"

# Select new random profile
ssh root@17.0.0.10 "cd /etc/openvpn && ./select-random-profile.sh"
```

### Load Balancer Issues:
```bash
# Check HAProxy configuration
ssh root@17.0.0.1 "haproxy -c -f /etc/haproxy.cfg"

# Restart HAProxy service
ssh root@17.0.0.1 "/etc/init.d/haproxy restart"

# View HAProxy statistics
curl http://17.0.0.1:8404/stats
```

### Network Connectivity Issues:
```bash
# Check routing tables
ssh root@17.0.0.10 "ip route show"

# Test inter-worker communication
ping 17.0.0.10
ping 17.0.0.11
ping 17.0.0.12
```

## Dependencies

Tests require the following tools on the test client:
- `curl` - HTTP testing
- `nc` (netcat) - TCP/UDP testing
- `ssh` - Remote command execution
- `ping` - Network connectivity testing

Install missing dependencies:
```bash
# Ubuntu/Debian
sudo apt-get install curl netcat-openbsd openssh-client iputils-ping

# OpenWRT (on routers)
opkg install curl netcat
```

## Scaling Tests

When adding more worker boxes, update the `WORKERS` array in each test script:

```bash
# Example for 5 workers
WORKERS=("17.0.0.10" "17.0.0.11" "17.0.0.12" "17.0.0.13" "17.0.0.14")
```

## Monitoring Integration

Test results can be integrated with monitoring systems:
- **Prometheus**: Parse test output for metrics
- **Nagios**: Use exit codes for service monitoring
- **Grafana**: Visualize load balancing distribution
- **Custom dashboards**: Parse JSON output from tests