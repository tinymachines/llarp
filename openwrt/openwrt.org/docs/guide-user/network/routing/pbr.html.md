# PBR (Policy-Based Routing)

See also: [Routing and PBR basics](/docs/guide-user/network/routing/basics#policy-based_routing "docs:guide-user:network:routing:basics"), [Multi-WAN](/docs/guide-user/network/wan/multiwan/start "docs:guide-user:network:wan:multiwan:start")

[PBR](https://en.wikipedia.org/wiki/Policy-based_routing "https://en.wikipedia.org/wiki/Policy-based_routing") is a technique used to make routing decisions based on policies set by the network administrator. There are different methods to implement PBR with their own pros and cons, and some methods can be more suitable than others depending on your goal.

## Solutions

### PBR app

See also: [PBR app](/docs/guide-user/network/routing/pbr_app "docs:guide-user:network:routing:pbr_app")

PBR app helps overcome routing issues for the following scenarios:

- Utilize split tunneling to route your traffic to VPN/WAN selectively for some of hosts/subnets/domains.
- Implement port forwarding on the WAN interface when traffic is routed to VPN by default.
- Run VPN server and client simultaneously and route traffic to the VPN client.
- Provide web interface to manage routing policies.

### PBR with netifd

See also: [PBR with netifd](/docs/guide-user/network/routing/pbr_netifd "docs:guide-user:network:routing:pbr_netifd")

PBR with netifd helps to utilize different routing tables to route traffic to a specific interface based on traffic parameters like ingress/egress interface, source/destination address, firewall mark, etc.:

- Relies on the built-in netifd functionality and requires no extra software installation.
- Suitable for managed and unmanaged interfaces declared in the network configuration.
- Works well with interfaces, subnets, IP addresses and ports, but not domains.

### mwan3

See also: [mwan3](/docs/guide-user/network/wan/multiwan/mwan3 "docs:guide-user:network:wan:multiwan:mwan3")

mwan3 provides load balancing and failover with multiple WAN interfaces.
