# Load balancing UDP/TCP traffic across OpenWrt Raspberry Pi VPN routers

Creating a robust load balancing solution for UDP/TCP traffic across multiple OpenWrt Raspberry Pi devices connected via VPN requires careful consideration of hardware capabilities, software solutions, and network architecture. This comprehensive research reveals multiple viable approaches, from enterprise-grade solutions to lightweight implementations optimized for resource-constrained environments.

## The optimal solution architecture

Based on extensive research and performance testing data, the most practical implementation combines **HAProxy or nginx stream module** for Layer 4 load balancing with **WireGuard VPN** connections managed through **OpenWrt's mwan3 package**. This configuration delivers **300-500 Mbps throughput** on Raspberry Pi 4 hardware while maintaining reasonable CPU utilization and supporting thousands of concurrent connections.

## Software load balancers for Layer 4 traffic

### HAProxy emerges as the leading solution

HAProxy provides robust TCP load balancing through its core stream module, achieving **15,000-25,000 requests per second** on properly optimized Raspberry Pi 4 hardware. The configuration is straightforward for TCP traffic, using `mode tcp` with various load distribution algorithms including round-robin, least connections, and consistent hashing for session persistence. UDP support requires HAProxy Enterprise for production use, though the enterprise UDP module demonstrates impressive performance, handling **3.8 million syslog messages per second** on high-end hardware.

The practical implementation on OpenWrt involves installing the HAProxy package and configuring frontend/backend sections for each service type. Health checking mechanisms ensure backend availability through TCP connection tests, custom send/expect patterns, or even HTTP checks for TCP services. Session persistence uses IP-based hashing to maintain connection consistency, crucial for stateful applications and VPN traffic.

### nginx stream module offers versatility

The nginx stream module presents a compelling alternative, supporting both TCP and UDP in the open-source version since inclusion of the `--with-stream` compilation flag. Configuration proves more intuitive for administrators familiar with nginx syntax, and the event-driven architecture efficiently handles **18,000-22,000 requests per second** on Raspberry Pi 4. UDP load balancing works out-of-the-box with proxy_responses configuration for protocols expecting multiple response packets.

A significant advantage lies in nginx's ability to combine load balancing with content serving, reducing the software stack complexity when static content delivery is also required. The stream module implements sophisticated load balancing algorithms including least time (based on connection establishment or data transfer speeds), making it particularly effective for geographically distributed backends.

### Kernel-level solutions for maximum performance

Linux Virtual Server (LVS) operates at kernel level, offering three operational modes that trade complexity for performance. Direct Routing mode achieves the highest throughput by allowing backend servers to respond directly to clients, bypassing the load balancer for return traffic. This approach minimizes CPU usage on the Raspberry Pi but requires all servers on the same network segment. NAT mode provides simpler configuration at the cost of processing both inbound and outbound traffic through the load balancer.

For extreme performance requirements, solutions like Facebook's Katran leverage eBPF and XDP for kernel bypass, potentially achieving millions of packets per second. However, these technologies require significant expertise and may exceed typical Raspberry Pi deployment scenarios.

## OpenWrt and Raspberry Pi integration specifics

### Hardware recommendations shape the implementation

**Raspberry Pi 4 Model B** represents the minimum viable hardware for gigabit load balancing applications, delivering **940+ Mbps** throughput on optimized configurations. The quad-core ARM Cortex-A72 processor handles network interrupts efficiently when properly configured with IRQ affinity distribution across cores. The 4GB RAM model provides sufficient memory for handling **5,000-8,000 concurrent VPN connections** with appropriate tuning.

**Raspberry Pi 5** significantly improves cryptographic performance through ARMv8 Crypto Extensions, achieving **45x faster** encryption operations compared to Pi 4. This translates to **500-700 Mbps VPN throughput** compared to 300-500 Mbps on Pi 4, making it strongly recommended for VPN-heavy workloads. The improved memory bandwidth (17 GB/s vs 6-8 GB/s) also reduces bottlenecks in high-connection scenarios.

Critical hardware limitations include the single onboard Gigabit Ethernet port, necessitating **USB 3.0 to Ethernet adapters** for multi-WAN configurations. The TP-Link UE300 with RTL8153 chipset proves reliable in production deployments, though inconsistent USB device naming requires MAC address-based interface configuration for stability.

### mwan3 provides multi-WAN orchestration

OpenWrt's **mwan3 package** serves as the primary solution for multi-WAN load balancing and failover, supporting up to 250 WAN interfaces with sophisticated policy-based routing. The hotplug-driven architecture minimizes resource usage, activating only during interface state changes. Configuration through UCI (Unified Configuration Interface) allows defining weighted load balancing policies, with traffic distribution based on connection tracking marks.

Real-world deployments demonstrate successful implementations with 3+ WAN connections, including mixed media types like Starlink satellite, LTE, and fixed wireless. The interface health monitoring uses configurable ping tests to multiple tracking IPs, automatically failing over connections when reliability thresholds aren't met. Integration with VPN services requires careful metric configuration to ensure proper routing table priorities.

### Performance optimization requires system tuning

Kernel parameters significantly impact load balancing performance on ARM hardware. Network buffer sizing (`net.core.rmem_max` and `wmem_max` at 64MB) prevents packet drops under load. Connection handling optimization through `net.core.somaxconn` (65535) and `net.ipv4.tcp_max_syn_backlog` (65535) enables high concurrent connection counts. The BBR congestion control algorithm (`net.ipv4.tcp_congestion_control`) improves throughput over variable-quality links common in multi-WAN scenarios.

CPU scheduling adjustments (`kernel.sched_min_granularity_ns`) reduce context switching overhead, while memory management tuning (`vm.dirty_ratio` at 5%) prevents excessive disk I/O that could impact network performance. These optimizations collectively improve throughput by 20-30% over default configurations.

## VPN integration strategies

### Protocol selection impacts architecture

**WireGuard** emerges as the optimal VPN protocol for Raspberry Pi deployments, achieving **500 Mbps throughput** on Pi 4 with only 10-25% CPU utilization. The protocol's simplicity reduces overhead, though its cryptorouting principle (one IP:port maps to one peer) complicates load balancing, requiring multiple WireGuard interfaces with policy-based routing for distributing connections across VPN endpoints.

**OpenVPN** provides built-in load balancing and failover capabilities, supporting multiple server configurations in client profiles for automatic failover. TAP interface bonding enables true bandwidth aggregation across multiple tunnels. However, performance suffers significantly, achieving only **38-100 Mbps** on Pi 4, making it unsuitable for high-throughput requirements.

### Network topology determines scalability

The **hub-and-spoke topology** with a central load balancer distributing to multiple VPN endpoints provides straightforward management but creates a single point of failure. This design suits small deployments where simplicity outweighs redundancy concerns.

**Transit gateway architecture** implements a more robust solution, with multiple load balancers sharing a virtual IP address for high availability. Backend VPN endpoints connect through a shared transit network, enabling horizontal scaling and graceful degradation during failures.

For maximum redundancy, **partial mesh topologies** establish direct VPN connections between high-traffic endpoint pairs while maintaining hub connections for less-frequent communications. This balances full mesh complexity against hub-and-spoke limitations.

### Load distribution methods affect application behavior

**Per-flow load balancing** using 5-tuple hashing (source/destination IP and ports plus protocol) maintains packet ordering within connections, preventing TCP reordering issues. This approach works well for general internet traffic and business applications requiring connection consistency.

**Per-packet distribution** maximizes bandwidth utilization by spreading individual packets across all available paths but risks packet reordering that disrupts TCP and real-time protocols. This method requires careful consideration of application tolerance and may necessitate reordering buffers at endpoints.

**Session-based distribution** assigns entire user sessions to specific VPN tunnels, ensuring all related traffic follows the same path. While this simplifies troubleshooting and maintains application state, it may create uneven load distribution with long-lived sessions.

## Practical implementation configurations

### HAProxy configuration for TCP/UDP load balancing

A production-ready HAProxy configuration for OpenWrt begins with global settings optimized for ARM processors. Setting `maxconn 4096` and `ulimit-n 65535` handles thousands of concurrent connections while `nbthread 4` utilizes all Raspberry Pi 4 cores. The TCP load balancer frontend binds to port 1194 for VPN traffic, with backend servers defined using health checks at 2-second intervals. The configuration includes a statistics interface on port 8404 for real-time monitoring of backend health and traffic distribution.

### nginx stream module implementation

The nginx approach requires stream block configuration outside the standard HTTP context. Upstream groups define backend servers with weighting and connection limits. The TCP proxy configuration includes timeout settings and transparent binding to preserve client IPs. UDP proxying requires explicit `proxy_responses` configuration to handle protocols expecting multiple response packets. Connection persistence uses consistent hashing on client IP addresses to maintain session affinity.

### mwan3 multi-WAN setup

OpenWrt's mwan3 configuration defines interfaces with tracking IPs (typically public DNS servers), reliability requirements, and ping parameters. Member definitions assign metrics and weights to each WAN connection, influencing traffic distribution. Policies combine members into load-balanced or failover groups, while rules match traffic patterns to policies. A balanced policy might assign weights of 3:2:1 across three WAN connections, proportionally distributing new connections.

### Docker containerization for flexibility

Container deployment using Docker Compose simplifies management and enables easy scaling. HAProxy containers use the official `haproxytech/haproxy-alpine` image optimized for ARM architecture. The compose file defines backend services and networks, with HAProxy configuration mounted as a read-only volume. This approach enables blue-green deployments and simplifies backup/restore operations.

## Performance expectations and limitations

### Realistic throughput benchmarks

With proper optimization, **Raspberry Pi 4** delivers **300-500 Mbps combined VPN and load balancing throughput** while handling **2,000-5,000 concurrent connections**. CPU utilization typically reaches 60-85% under full load, with 2-8ms additional latency compared to direct connections.

**Raspberry Pi 5** improves these figures to **500-700 Mbps throughput** and **5,000-10,000 concurrent connections**, primarily due to hardware cryptographic acceleration. The BCM2712's ARMv8 Crypto Extensions provide near-linear scaling for VPN workloads, making it strongly recommended for production deployments.

### Scaling considerations

Small deployments (<100 concurrent connections) run comfortably on a single Pi 4 with basic optimization, achieving 400-600 Mbps combined throughput. Medium scale (100-1000 connections) benefits from Pi 5 hardware or clustered Pi 4 deployments with load distribution across multiple devices. Large scale deployments (>1000 connections) should consider purpose-built ARM platforms like NanoPi R5C or transition to x86 hardware for predictable performance.

### Critical bottlenecks

CPU cryptographic processing dominates resource usage at 60-80% of total CPU cycles for VPN traffic. Memory bandwidth becomes limiting above 600 Mbps aggregate throughput on Pi 4, though Pi 5's improved memory subsystem pushes this ceiling to approximately 1 Gbps. Network interrupt processing on a single core creates bottlenecks without proper IRQ affinity configuration, reducing achievable throughput by 30-40%.

## Implementation recommendations

For production deployments, combine **HAProxy or nginx** for load balancing with **WireGuard VPN** on **Raspberry Pi 4 (8GB) or Pi 5** hardware running **OpenWrt 23.05+**. Install the **mwan3 package** for multi-WAN orchestration with quality **USB 3.0 Gigabit Ethernet adapters** for additional WAN connections. Apply comprehensive kernel tuning for network performance, implement active cooling to prevent thermal throttling, and establish monitoring for throughput, latency, and connection metrics.

This architecture provides a cost-effective, manageable solution for distributed VPN load balancing that scales from home labs to small business deployments. The open-source software stack ensures long-term sustainability while maintaining flexibility for future enhancements as requirements evolve.