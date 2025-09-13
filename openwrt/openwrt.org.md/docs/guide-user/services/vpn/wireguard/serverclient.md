# WireGuard peers

WireGuard creates a point-to-point VPN between two or more peers/endpoints. The protocol itself treats all peers equally, so in theory there is nothing that distinguishes a server from a client. In practice however, it often degrades to the [client-server](https://en.wikipedia.org/wiki/Client%E2%80%93server_model "https://en.wikipedia.org/wiki/Client–server_model") model due to IPv4 and NAT connectivity limitations and gateway firewall restrictions. Thus, one of the peers typically needs to take the server role with a public IP address, a statically configured VPN port and a port opening firewall rule. The other peers can take the client roles with private IP addresses, dynamic VPN ports and don't need port opening firewall rules.

## VPN server

A VPN server listens for a connection initiated by another host/device/service. Your OpenWrt router acts as a server when you install WireGuard to enable remote administration and/or remote access to network services on your LAN. Your WireGuard server at home can also provide a measure of security when on public networks or bypass geo-restrictions when traveling since your traffic is encrypted through a tunnel to your server and then appears to be originating from your home. A commercial VPN provider's WireGuard peer would be considered a server as well.

## VPN client

A VPN client initiates a connection to another peer. Your computer or mobile device acts as a client when it connects back to your OpenWrt router as a WireGuard endpoint from outside. Alternatively, if you configure your OpenWrt router to connect to a commercial VPN service, then the OpenWrt peer itself may be considered a client.

## Site-to-site

WireGuard can create a site-to-site tunnel between two or more separate networks such that they act as one. Here, either or both sides may initiate a connection, and both sides listen for that data. This lets you administer and/or share network resources between the two networks. A common use case for this scenario is linking two remote office networks together.
