# Tunneling interface protocols

This page describes all available tunneling protocol usable in `/etc/config/network` and their options. Some example configurations are provided at the end of the page.

Note that, for most protocols, installing an opkg package is required for protocol support.

Most OpenWrt protocol handlers add a protocol-specific prefix to the UCI interface names. There is a default 15-character limit for interface names in the Linux kernel.

With prefixes seen at least as long as `gre4t-` and allowing possibility of using .VLAN notation, declared names should be kept under four (4) characters.

`abcd.NNNN` ⇒ `gre4t-abcd.NNNN` (15 characters)

This article may contain network configuration that depends on migration to DSA in OpenWrt 21.02

- Check if your device uses DSA or swconfig as not all devices have been migrated
- ifname@interface has been moved to device sections
- [DSA Networking](/docs/guide-user/network/dsa/start "docs:guide-user:network:dsa:start")
- [Mini tutorial for DSA network config](https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998 "https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998") on the forum
- [DSA in the 21.02 release notes](https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change "https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change")

## Protocol "pptp" (Point-to-Point Tunneling Protocol)

![:!:](/lib/images/smileys/exclaim.svg) The package [ppp-mod-pptp](/packages/pkgdata/ppp-mod-pptp "packages:pkgdata:ppp-mod-pptp") must be installed to use this protocol.

Name Type Required Default Description `server` ip address yes *(none)* Remote PPtP server `username` string no(?) *(none)* Username for PAP/CHAP authentication `password` string no(?) *(none)* Password for PAP/CHAP authentication `keepalive` integer no ? Number of attempts to reconnect `defaultroute` boolean no 1 Whether to create a default route over the tunnel `peerdns` boolean no 1 Use PPTP-provided DNS server(s) `delegate` boolean no ? Use builtin IPv6-management `iface` string no(?) `pptp-<ifname>` Name of the physical interface. Defaults to `pptp-<ifname>` no matter what you use where `<ifname>` is the name of the logical interface

### PPTP configs

Common PPTP and PPP configuration locations:

Name Description `/etc/ppp/options.pptpd` [PPTP options](/docs/guide-user/network/tunneling_interface_protocols#pptp_options "docs:guide-user:network:tunneling_interface_protocols") `/var/etc/options.pptpd` `/etc/ppp/chap-secrets` [PPTP secrets](/docs/guide-user/network/tunneling_interface_protocols#pptp_secrets "docs:guide-user:network:tunneling_interface_protocols") `/var/etc/chap-secrets` `/etc/ppp/peers` [PPTP peers](/docs/guide-user/network/tunneling_interface_protocols#pptp_peers "docs:guide-user:network:tunneling_interface_protocols") `/etc/ppp/ip-up` [Tunnel up scripts](/docs/guide-user/network/tunneling_interface_protocols#ppp_scripts "docs:guide-user:network:tunneling_interface_protocols") `/etc/ppp/ip-up.d` `/etc/ppp/ip-down` [Tunnel down scripts](/docs/guide-user/network/tunneling_interface_protocols#ppp_scripts "docs:guide-user:network:tunneling_interface_protocols") `/etc/ppp/ip-down.d`

### PPTP options

PPTP options are configured using :

Name Description `lcp-echo-failure n` Keep-alive, maximum number of echo attempts before considering the link to be dead `lcp-echo-interval n` Keep-alive, time between each echo attempt in seconds `idle n` Terminated tunnel after n seconds of inactivity, set to 0 to disable `refuse-eap` Refuse to authenticate using EAP, needed with some recent servers, try it if you see EAP responses in debug log `persist` Do not exit after a connection is terminated; instead try to reopen the connection `mppe required,no40,no56` Forces 128-bit encryption `demand` Reconnect on demand

### PPTP secrets

Name Description `[<domain>\\]<user>` Matches `name` in `/etc/ppp/peers/<peer_name>` `<peer_name>` Matches `remotename` in `/etc/ppp/peers/<peer_name>` `<password>` Matches password given by the owner of the PPTP server, blanks or special characters should be enclosed in double quotes if any `*` Allow the tunnel use any IP address, normally the PPTP server determines the address

```
umask go=
cat << "EOF" > /etc/ppp/chap-secrets
[<domain>\\]<user> <peer_name> <password> *
EOF
```

### PPTP peers

Name Description `pty "pptp <hostname_or_ip> --nolaunchpppd"` Instruct pppd to launch pptp to connect to the VPN server `mppe required,stateless` Require that the connection be encrypted, using stateless encryption `name [<domain>\\]<user>` Define the username for the VPN connection, assuming that the password is stored in `chap-secrets` `remotename <peer_name>` Specify the account and password in `chap-secrets` `replacedefaultroute` Redirect default gateway to the VPN `ipparam <peer_name>` A parameter for the PPP scripts to distinguish particular peer `file <path>` Include PPTP options, e.g. `/etc/ppp/options.pptpd`

```
umask go=
mkdir -p /etc/ppp/peers
cat << "EOF" > /etc/ppp/peers/<peer_name>
...
EOF
```

### PPP scripts

PPP script parameters:

\# Name Description `1` `IFNAME` Interface name used by pppd, e.g. `ppp3` `2` `DEVICE` TTY device name `3` `SPEED` TTY device speed `4` `IPLOCAL` Local tunnel IP address `5` `IPREMOTE` Remote tunnel IP address `6` *(none)* Client IP address, or `ipparam` parameter *(none)* `PEERNAME` Client `username` parameter

An example script to invoke peer-specific code:

```
cat << "EOF" > /etc/ppp/ip-up
#!/bin/sh
case ${PEERNAME} in
(USERNAME1) ... ;;
(*) ... ;;
esac
EOF
chmod +x /etc/ppp/ip-up
```

## Protocol "relay" (Relayd Pseudo Bridge)

![:!:](/lib/images/smileys/exclaim.svg) The package [relayd](/packages/pkgdata/relayd "packages:pkgdata:relayd") must be installed to use this protocol.

Name Type Required Default Description `network` list of *logical interface names* yes *(none)* Specifies the networks between which traffic is relayed `gateway` IPv4 address no *(network default)* Override the gateway address sent to clients within DHCP responses `expiry` integer no 30 Host expiry timeout in seconds `retry` integer no 5 Number of ARP ping retries before a host is considered dead `table` integer no 16800 Table ID for automatically added routes `forward_bcast` boolean no 1 Enables forwarding of broadcast traffic, `0` disables it `forward_dhcp` boolean no 1 Enables forwarding of DHCP requests and responses, `0` disables it

## Common options for GRE protocols

![:!:](/lib/images/smileys/exclaim.svg) The package [gre](/packages/pkgdata/gre "packages:pkgdata:gre") must be installed to use this protocol. Additionally, you need [kmod-gre](/packages/pkgdata/kmod-gre "packages:pkgdata:kmod-gre") and/or [kmod-gre6](/packages/pkgdata/kmod-gre6 "packages:pkgdata:kmod-gre6").

GRE support has been introduced in Barrier Breaker. Four protocols are defined (“gre”, “gretap”, grev6“, and “grev6tap”), which will generate GRE interfaces named:

Protocol GRE type Interface name gre `IPv4 GRE` gre4-&lt;logical interface name&gt; gretap `GRE-TAP IPv4` gre4t-&lt;logical interface name&gt; grev6 `GRE IPv6` gre6-&lt;logical interface name&gt; grev6tap `GRE-TAP IPv6` gre6t-&lt;logical interface name&gt;

All four protocols accept the following common options:

Name Type Required Default Description `mtu` integer no 1280 MTU `ttl` integer no 64 TTL of the encapsulating packets `tunlink` logical interface name no *(none)* Bind the tunnel to this interface (`dev` option of “ip tunnel”) `zone` zone name no `wan` Firewall zone to which the interface will be added `tos` string no *(none)* Type of Service (IPv4), Traffic Class (IPv6): either “inherit” (the outer header inherits the value of the inner header) or an hexadecimal value (Chaos Calmer and later only) `ikey` integer no 0 key for incoming packets `okey` integer no 0 key for outgoing packets `icsum` boolean no 0 require incoming checksum `ocsum` boolean no 0 compute outgoing checksum `iseqno` boolean no 0 require incoming packets serialization `oseqno` boolean no 0 perform outgoing packets serialization

## Protocol "gre" (GRE tunnel over IPv4)

The following options are supported, in addition to all common options above:

Name Type Required Default Description `ipaddr` IPv4 address no WAN IP Local endpoint `peeraddr` IPv4 address yes *(none)* Remote endpoint `df` boolean no 1 Set “Don't Fragment” flag on encapsulating packets

## Protocol "gretap" (Ethernet GRE tunnel over IPv4)

The following options are supported, in addition to all common options above:

Name Type Required Default Description `ipaddr` IPv4 address no WAN IP Local endpoint `peeraddr` IPv4 address yes *(none)* Remote endpoint `df` boolean no 1 Set “Don't Fragment” flag on encapsulating packets `network` logical interface name no *(none)* Logical network to which the tunnel will be added (bridged)

`ipaddr` *may* be required in some setups. Repeated log entries about “setting up now” and “now down” may be related to this.

Additionally, the `resolveip` package may also be needed. `./gre.sh: eval: line 1: resolveip: not found` in the logs are an indication of the need.

## Protocol "grev6" (GRE tunnel over IPv6)

The following options are supported, in addition to all common options above:

Name Type Required Default Description `ip6addr` IPv6 address no WAN IP Local endpoint `peer6addr` IPv6 address yes *(none)* Remote endpoint `weakif` logical interface name no `lan` Logical network from which to select the local endpoint if ip6addr parameter is empty and no WAN IP is available

## Protocol "grev6tap" (Ethernet GRE tunnel over IPv6)

The following options are supported, in addition to all common options above:

Name Type Required Default Description `ip6addr` IPv6 address no WAN IP Local endpoint `peer6addr` IPv6 address yes *(none)* Remote endpoint `weakif` logical interface name no `lan` Logical network from which to select the local endpoint if ip6addr is empty and no WAN IP is available `network` logical interface name no *(none)* Logical network to which the tunnel will be added (bridged)

## Protocol "ieee8021xclient" (IEEE 802.1X client)

![:!:](/lib/images/smileys/exclaim.svg) The package [ieee8021xclient](/packages/pkgdata/ieee8021xclient "packages:pkgdata:ieee8021xclient") must be installed to use this protocol.

Name Type Required Default Description `identity` string yes(?) *(none)* Username for IEEE 802.1X authentication `password` string yes(?) *(none)* Password for IEEE 802.1X authentication `ca_cert` string no *(none)* Specifies the path the CA certificate used for authentication `client_cert` string no *(none)* Specifies the client certificate used for the authentication `private_key` string no *(none)* Specifies the path to the private key file used for authentication `private_key_passwd` string no *(none)* Password to unlock the private key file, only works in conjunction with *private\_key*

See alse [wpa\_enterprise\_client](/docs/guide-user/network/wifi/basic#wpa_enterprise_client "docs:guide-user:network:wifi:basic").

## Protocol "vti" (VTI tunnel over IPv4)

VTI Tunnels are IPsec policies with a fwmark set. The traffic is redirected to the matching VTI interface.

Name Type Required Default Description `ipaddr` IPv4 address no WAN IP Local endpoint `peeraddr` IPv4 address yes *(none)* Remote endpoint `mtu` integer no 1280 MTU `tunlink` logical interface name no *(none)* Bind the tunnel to this interface (`dev` option of “ip tunnel”) `zone` zone name no `wan` Firewall zone to which the interface will be added `ikey` integer no 0 key/fwmark for incoming packets `okey` integer no 0 key/fwmark for outgoing packets

## Protocol "vti6" (VTI tunnel over IPv6)

The following options are supported, in addition to all common options above:

Name Type Required Default Description `ip6addr` IPv6 address no WAN IP Local endpoint `peer6addr` IPv6 address yes *(none)* Remote endpoint `mtu` integer no 1280 MTU `tunlink` logical interface name no *(none)* Bind the tunnel to this interface (`dev` option of “ip tunnel”) `zone` zone name no `wan` Firewall zone to which the interface will be added `ikey` integer no 0 key/fwmark for incoming packets `okey` integer no 0 key/fwmark for outgoing packets

## Protocol "vxlan" (VXLAN layer 2 virtualization over layer 3 network)

A working VXLAN configuration consists of two interface definitions. One is the actual VXLAN interface, the other one is an alias interface. The following options can be used in the VXLAN interface definition (with `option proto 'vxlan`'):

Name Type Required Default Description `peeraddr` string no *(none)* IP address of the peer to connect to or a multicast address for a group of peers. Use `vxlan_peer` as described below for multiple peers `port` integer no 8472 or 4789 Port for VXLAN connection, IANA-assigned default is '4789', several Linux distros use '8472' for historical reasons  `srcportmin` integer no *(none)* range of port numbers to use as UDP source ports to communicate to the remote VXLAN tunnel endpoint `srcportmax` integer no *(none)* range of port numbers to use as UDP source ports to communicate to the remote VXLAN tunnel endpoint `vid` integer yes *(none)* VXLAN identifier used to identify a VXLAN network and properly convey frames `ageing` integer no *(none)* lifetime in seconds of FDB entries learned by the kernel `maxaddress` integer no *(none)* maximum number of FDB entries `tunlink` logical interface name yes *(none)* Bind the VXLAN tunnel to this interface `macaddr` MAC address no *(dynamically generated)* Specify the MAC address of this interface manually `mtu` integer no 1280 Manually specify the Maximum Transmission Unit of the VXLAN interface (VXLAN extends the length of the network frame, make sure it still fits the MTU of the underlying network) `ttl` integer no 64 TTL of the encapsulation packets `tos` integer no ? Type of Service (IPv4) or Traffic Class (IPv6) `rxcsum` boolean no 1 Use checksum validation in RX (receiving) direction (0 = inactive, 1 = active) `txcsum` boolean no 1 Use checksum validation in TX (transmission) direction (0 = inactive, 1 = active) `force_link` boolean no 0 Set interface properties regardless of the link carrier (If set, carrier sense events do not invoke hotplug handlers) (0 = inactive, 1 = active) `delegate` boolean no 1 Use built-in IPv6 management (0 = inactive, 1 = active) `learning` boolean no *(none)* enable/disable entering unknown source link layer addresses and IP addresses into the VXLAN device FDB. `rsc` boolean no 0 Route short-circuit: If destination MAC refers to router, replace it with destination MAC address `proxy` boolean no *(none)* ARP proxy: reply on Neighbor request `l2miss` boolean no *(none)* Layer 2 miss: Emits netlink LLADDR miss notifications `l3miss` boolean no *(none)* Layer 3 miss: Emits netlink IP ADDR miss notifications `gbp` boolean no *(none)* Group Based Policy

![:!:](/lib/images/smileys/exclaim.svg) `ipaddr` can be specified, but it does not have the effect of setting the IP address of the VXLAN interface. For correct configuration see the example `VXLAN example configuration` at the end of the page.

Multiple peers can be configured with `config vxlan_peer` entries:

```
config vxlan_peer
        option vxlan vxlan0
        option dst '10.0.0.2'
 
config vxlan_peer
        option vxlan vxlan0
        option dst '10.0.0.3'
```

All available options for `config vxlan_peer`:

Name Type Required Default Description `vxlan` string yes *(none)* which vxlan interface to add peer to `lladdr` MAC address no `00:00:00:00:00:00` L2 (MAC) address of peer. Uses source-address learning when `00:00:00:00:00:00` is specified `dst` IP address yes *(none)* the IP address of the remote VXLAN tunnel endpoint where the MAC address (lladdr) resides or a multicast address for a group of peers. For multicast, an outgoing interface needs to be specified (`via`) `port` integer no *(none)* the UDP destination port number to use to connect to the remote VXLAN tunnel endpoint `via` logical interface name no *(none)* name of the outgoing interface to reach the remote VXLAN tunnel endpoint `vni` integer no *(none)* the VXLAN VNI Network Identifier (or VXLAN Segment ID) to use to connect to the remote VXLAN tunnel endpoint `src_vni` integer no *(none)* the source VNI Network Identifier (or VXLAN Segment ID) this entry belongs to. Used only when the vxlan device is in external or collect metadata mode

## Protocol "xfrm" (XFRM tunnel interface)

XFRM Tunnel interfaces are bound to if\_id set in the sa policy.

Name Type Required Default Description `ifid` integer yes *(none)* if\_id set in ipsec sa policy `tunlink` logical interface name yes *(none)* Bind the tunnel to this interface (`dev` option of “ip tunnel”) `mtu` integer no 1280 MTU `zone` zone name no `wan` Firewall zone to which the interface will be added

## Protocol "openconnect" (OpenConnect VPN)

![:!:](/lib/images/smileys/exclaim.svg) The package [openconnect](/packages/pkgdata/openconnect "packages:pkgdata:openconnect") must be installed to use this protocol.

Name OpenConnect CLI option Description `server` `--server` Server address, FQDN or IP; required until `uri` is in use `port` (part of server) Server port number. Default is 443 `uri` `--server` Complete server URI, like `https://vpn.example.com:4443/?mysecretkey` `juniper` `--juniper` Connect to a Juniper server. DEPRECATED, 8.0 uses `--protocol=nc` instead. `serverhash` `--servercert=`; `--no-system-trust` Force trust of server's certificate based only on hash matching `authgroup` `--authgroup=` Group membership to request from the server `username` `--user=` Login username for user/pass authentication `password` (passed via stdin) Password for user/pass authentication `password2` (passed via stdin) Second password for 2 factor `token_mode` `--token-mode=` `rsa`, `totp` or `hotp` to internally compute a two-factor token as passwd2 `token_secret` `--token-secret=` Crypto secret required by token\_mode `token_script` `--token-script=` Local shell script that will dynamically produce passwd2 `os` `--os=` Operating system to report to the server. Default is `Linux` `interface` N/A Outgoing local interface (used to create a netifd host dependency) `csd_wrapper` `--csd-wrapper=` Run this instead of any binary or script that the server pushes us to run `defaultroute` N/A Create default route over the tunnel, boolean, default is 1 `peerdns` N/A Use provided DNS servers, boolean, default is 1

Most of these options are passed directly to the OpenConnect executive, so see [openconnect](http://man.cx/openconnect%288%29 "http://man.cx/openconnect%288%29") for details.

Certificates and keys files must be in the [PEM](https://en.wikipedia.org/wiki/Privacy-Enhanced_Mail "https://en.wikipedia.org/wiki/Privacy-Enhanced_Mail") format and named as shown below where `<ifname>` is the name of the logical interface.

Name OpenConnect CLI option Description `/etc/openconnect/ca-vpn-<ifname>.pem` `--cafile=` CA certificate used to verify the server's certificate. `/etc/openconnect/user-cert-vpn-<ifname>.pem` `--certificate=` Client certificate, signed by a CA that the server knows. `/etc/openconnect/user-key-vpn-<ifname>.pem` `--sslkey=` Private key of the client certificate, Must not be encrypted.

## Protocol "pppossh" (Point-to-Point over SSH)

![:!:](/lib/images/smileys/exclaim.svg) The package [pppossh](/packages/pkgdata/pppossh "packages:pkgdata:pppossh") must be installed to use this protocol.

Name Type Required Default Description *server* string yes *(none)* SSH server name *port* integer no 22 SSH server port *sshuser* string yes *(none)* SSH login username *identity* list no `~/.ssh/id_{rsa,dsa}` list of client private key files. The defaults will be used if no identity file was specified and at least one of them must be valid for the public key authentication to proceed. *ipaddr* string yes *(none)* local ip address to be assigned *peeraddr* string yes *(none)* peer ip address to be assigned *ssh\_options* list yes *(none)* peer ip address to be assigned *use\_hostdep* bool no 1 set it to 0 to disable the use of proto\_add\_host\_dependency. This is mainly for the case that the appropriate route to server is not registered to netifd and thus causing a incorrect route being setup

For configuration see current [README](https://github.com/openwrt/packages/blob/master/net/pppossh/README.md "https://github.com/openwrt/packages/blob/master/net/pppossh/README.md").

## Protocol "vpnc" (VPNC client)

![:!:](/lib/images/smileys/exclaim.svg) The package [vpnc](/packages/pkgdata/vpnc "packages:pkgdata:vpnc") must be installed to use this protocol.

For configuration see current [README](https://github.com/openwrt/packages/blob/master/net/vpnc/README "https://github.com/openwrt/packages/blob/master/net/vpnc/README").

## Protocol "wireguard" (WireGuard VPN)

![:!:](/lib/images/smileys/exclaim.svg) The package [wireguard-tools](/packages/pkgdata/wireguard-tools "packages:pkgdata:wireguard-tools") must be installed to use this protocol.

Each WireGuard interface is configured in two parts:

- the configuration relative to the interface itself (private key, MTU, UDP port to bind to, etc.)
- configuration relative to each peer (public key, IP address, etc.)

Interface configuration (using `proto wireguard`):

Name Type Required Default Description `private_key` string yes *(none)* WireGuard private key, generated with `wg genkey` `listen_port` int no *wireguard-specific* UDP port used for outgoing and incoming packets `addresses` list of IPs no *(none)* IPv4 or IPv6 addresses to assign to this interface `mtu` integer no *wireguard-specific* Interface MTU `fwmark` string no *derived from listen\_port* Firewall mark to apply to tunnel endpoint packets `ip6prefix` list of prefixes no *(none)* IPv6 prefixes to delegate to other interfaces `nohostroute` boolean no 0 Do not add routes to ensure the tunnel endpoints are routed via non-tunnel device `tunlink` string no *(none)* Bind the tunnel to the specified interface, OpenWrt 21.02+

The name of the network interface will be the name of the configuration section.

### WireGuard peers

Peer configuration, for each peer:

Name Type Required Default Description `public_key` string yes *(none)* Public key of the peer `preshared_key` string no *(none)* Optional shared secret, to provide an additional layer of symmetric-key cryptography for post-quantum resistance `allowed_ips` list of prefixes yes *(none)* IP addresses and prefixes that this peer is allowed to use inside the tunnel, also used for WireGuard's internal routing table. Works for both IPv4 and IPv6 `route_allowed_ips` boolean no 0 Automatically create a route for each Allowed IPs for this peer `endpoint_host` string no *(none)* IP address or hostname of the peer. If not specified, WireGuard will wait for connections from the peer `endpoint_port` int no 51820 UDP port of the peer `persistent_keepalive` int no 0 Number of second between keepalive messages, 0 means disabled

The name of a peer section must be `wireguard_<ifname>` where `<ifname>` is the name of the logical interface.

## Examples

Below are a few examples for special, non-standard interface configurations.

### VPN interfaces

![:!:](/lib/images/smileys/exclaim.svg) Avoid OpenVPN tunnel interface declaration to prevent the [race condition](https://forum.openwrt.org/t/openvpn-client-tun-adapter-loses-its-ip-address-on-network-restart/13825 "https://forum.openwrt.org/t/openvpn-client-tun-adapter-loses-its-ip-address-on-network-restart/13825") with netifd service.

If you still want to manage VPN interface such as `tun0` via UCI configuration and LuCI:

```
# /etc/config/network
config interface 'vpn'
	option device 'tun0'
	option proto 'none'
```

### 6in4 Tunnel

Follow [IPv4/IPv6 Transition Technologies](/docs/guide-user/network/ipv6_ipv4_transitioning "docs:guide-user:network:ipv6_ipv4_transitioning").

### L2TP Tunnel

Support for L2TP is provided by `xl2tpd` package. The username and password are for PPP authentication.

```
config interface 'l2tpwan'
	option proto 'l2tp'
	option server '1.2.3.4'
	option username 'mylogin'
	option password 'mypassword'
	option keepalive '30'
```

### L2TPv3 Pseudowire bridged to LAN

This example establishes a Pseudowire Tunnel and bridges it to the LAN ports. The existing lan interface is reused with protocol `l2tp` instead of `static`.

```
config interface 'lan'
	option proto     'l2tp'
	option type      'bridge'
	option ifname    'eth0'
	option ipaddr    '192.168.1.1'
	option netmask   '255.255.255.0'
	option localaddr '178.24.154.19'
	option peeraddr  '89.44.33.61'
	option encap     'udp'
	option sport     '4000'
	option dport     '5410'
```

### Relay between LAN and Wireless Station

This example sets up a `relayd` pseudo bridge between a wireless client network and LAN, so that it works similarly to the Broadcom Bridged Client mode.

Wireless configuration (excerpt):

```
config wifi-iface
	option device     'radio0'
	option mode       'sta'
	option ssid       'Some Wireless Network'
	option encryption 'psk2'
	option key	'12345678'
	option network    'wwan'
```

Network configuration (excerpt):  
![:!:](/lib/images/smileys/exclaim.svg) Note that the LAN subnet must be different from the one used by wireless network's DHCP.

```
config interface 'lan'
	option ifname     'eth0.1'
	option proto      'static'
	option ipaddr     '192.168.1.1'
	option netmask    '255.255.255.0'
 
config interface 'wwan'
	option proto      'dhcp'
 
config interface 'stabridge'
	option proto      'relay'
	option network    'lan wwan'
```

In contrast to true bridging, traffic forwarded in this manner is affected by firewall rules, therefore both the wireless client network and the lan network should be covered by the same LAN firewall zone with forward policy set to `accept` to allow traffic flow between both interfaces:

```
config zone
	option name	'lan'
	option network     'lan wwan'  # Important
	option input       'ACCEPT'
	option forward     'ACCEPT'    # Important
	option output      'ACCEPT'
```

### Static addressing of a GRE tunnel

Create a GRE tunnel with static address 10.42.0.253/30, adding it to an existing firewall zone called `tunnels`:

*See warning on top of page about interface-name length. Previous interface names here were too long and silently fail.*

```
config interface 'tunA'
	option proto    'gre'
	option zone     'tunnels'
	option peeraddr '198.51.100.42'
 
config interface 'tunAA'
	option proto    'static'
	option ifname   '@tunA'
	option ipaddr   '10.42.0.253'
	option netmask  '255.255.255.252'
	# Fixes IPv6 multicast (long-standing bug in kernel).
	# Useful if you run Babel or OSPFv3.
	option ip6addr  'fe80::42/64'
```

### Static addressing of a IPSEC VTI tunnel

This adds support for configuring VTI interfaces within /etc/config/network. VTI interfaces are used to create IPsec tunnel interfaces. These interfaces may be used for routing and other purposes.

```
config interface 'vti1'
	option proto 'vti'
	option mtu '1500'
	option tunlink 'wan'
	option peeraddr '192.168.5.16'
	option zone 'VPN'
	option ikey 2
	option okey 2
 
config interface 'vti1_static'
	option proto 'static'
	option ifname '@vti1'
	option ipaddr '192.168.7.2/24'
```

The options ikey and okey correspond to the fwmark value of an ipsec policy. This may be null if you do not want a fwmark. Also peeraddr may be 0.0.0.0 if you want all ESP packets go through the interface.

Example strongswan config:

```
conn vti
	left=%any
	leftcert=peer2.test.der
	leftid=@peer2.test
	right=192.168.5.16
	rightid=@peer3.test
	leftsubnet=0.0.0.0/0
	rightsubnet=0.0.0.0/0
	mark=2
	auto=route
```

### Static addressing of WireGuard tunnel

An example of WireGuard server configuration.

```
config interface 'vpn'
	option proto 'wireguard'
	option private_key 'SERVER_PRIVATE_KEY'
	option listen_port '51820'
	list addresses '192.168.9.1/24'
	list addresses 'fd00:9::1/64'
 
config wireguard_vpn 'wgclient'
	option public_key 'CLIENT_PUBLIC_KEY'
	option preshared_key 'PRESHARED_KEY'
	list allowed_ips '192.168.9.2'
	list allowed_ips 'fd00:9::2'
```

An example of WireGuard client configuration.

```
config interface 'vpn'
	option proto 'wireguard'
	option private_key 'CLIENT_PRIVATE_KEY'
	list addresses '192.168.9.2/24'
	list addresses 'fd00:9::2/64'
 
config wireguard_vpn 'wgserver'
	option public_key 'SERVER_PUBLIC_KEY'
	option preshared_key 'PRESHARED_KEY'
	option endpoint_host 'SERVER_ADDRESS'
	option endpoint_port '51820'
	option route_allowed_ips '1'
	option persistent_keepalive '25'
	list allowed_ips '0.0.0.0/0'
	list allowed_ips '::/0'
```

Create a WireGuard tunnel interface named `foo` that connects to one peer (VPN server at vpn.example.com) and allows another peer (e.g. road warrior) to connect. Peer configurations are managed via one or more `wireguard_<ifname>` sections.

```
config interface 'foo'
	option proto 'wireguard'
	option private_key 'qLvQnx5CpXPDo6oplzdIvXLNqkbgpXip3Yv4ouHWZ0Q='
	list addresses 'fd00:13:37:ffff::1/64'
 
config wireguard_foo
	option public_key '9mD+mTiOp7SGIkB4t3ZfWAcfp5iA/WwQRdVypKKwrjY='
	option route_allowed_ips '1'
	list allowed_ips 'fd00:13:37::/64'
	option endpoint_host 'vpn.example.com'
	option persistent_keepalive '25'
 
config wireguard_foo
	option public_key '4mLeSytW6/y4UcOT6rNorw1Ae9nXSxhXUjxsdzMWkUA='
	option preshared_key 'M1IbkkDVwXsQbFbURiMXiVe/iUCjC5TKHCmemVs+oLQ='
	list allowed_ips 'fd00:13:37:ffff::2'
```

### VXLAN example configuration

Here is an example configuration for a VXLAN tunnel. Only the required options are used, optional ones can be specified additionally.

VXLAN interface definition:

```
config interface 'vxlan0'
	option proto 'vxlan'
	option peeraddr '10.10.222.1'
	option port '4789'
	option vid '8'
	option tunlink 'eth0'
```

Now it is necessary to create an alias interface for `vxlan0` to assign an IP address as this is not possible with `option ipaddr`:

```
config interface 'l2vpn'
	option ifname '@vxlan0'
	option proto 'static'
	option ipaddr '10.10.0.1'
	option netmask '255.255.255.0'
	option layer '2'
```

### How to create Ethernet VPN port using VXLAN

An Ethernet adapter is being inserted into the port, its Ethernet frame is send to the distant br-lan.

It will obtain an IP address in the 192.168.200.x range from a distant DHCP server via a Layer 2 VPN.

Assuming you are using VLAN on your router.

Assuming you have setup site-to-site VPN with subnet routing with Wireguard or Tailscale.

VLAN ID 100 is native LAN.

VLAN ID 1000 is used to short circuit VXLAN to port and only avaliable on sender.

Sender :

- detach ethernet port from any VLAN ID
- create a new VLAN ID, not join to existing VLAN ID and short circuit Ethernet port to VXLAN interface

Overview of Bridge device br-lan:

```
--------------------------------------------------------------------------------------
| VLAN ID | Local | br-lan.100 | br-lan.1000 | lan1 | lan2 | lan3 | lan4 | vxlan100  |
--------------------------------------------------------------------------------------
|         |       | Connected  | Connected   |      |      |      |      | Connected |
--------------------------------------------------------------------------------------
| 100     | Yes   | T          | -           | U    | U    | U    | -    |           |
--------------------------------------------------------------------------------------
| 1000    | Yes   | -          | -           | -    | -    | -    | U    | U         |
--------------------------------------------------------------------------------------
```

Add vxlan100 interface to the br-lan bridge.

```
config device
	option name 'br-lan'
	option type 'bridge'
	option bridge_empty '1'
	list ports 'lan1'
	list ports 'lan2'
	list ports 'lan3'
	list ports 'lan4'
	list ports 'vxlan100'
	list ports 'br-lan.100'
```

Don't use “option tunlink”, it is not working with Wireguard and Tailscale with VLAN/subnet routing.

```
config interface 'vxlan100'
	option proto 'vxlan'
	option peeraddr '192.168.200.1'
	option ipaddr '192.168.100.1'
	option port '4789'
	option vid '100'
 
config bridge-vlan
	option device 'br-lan'
	option vlan '1000'
	list ports 'lan4'
	list ports 'vxlan100'
```

Receiver:

- Join VXLAN datagram to destination VLAN ID.

Overview of Bridge device br-lan:

```
------------------------------------------------------------------------
| VLAN ID | Local | br-lan.100 | lan1 | lan2 | lan3 | lan4 | vxlan100  |
------------------------------------------------------------------------
|         |       | Connected  |      |      |      |      | Connected |
------------------------------------------------------------------------
| 100     | Yes   | T          | U    | U    | U    | U    | U         |
------------------------------------------------------------------------
```

Add vxlan100 interface to the br-lan bridge.

```
config device
	option name 'br-lan'
	option type 'bridge'
	option bridge_empty '1'
	list ports 'lan1'
	list ports 'lan2'
	list ports 'lan3'
	list ports 'lan4'
	list ports 'vxlan100'
	list ports 'br-lan.100'
```

Join VXLAN datagram to the native LAN, VLAN ID 100

```
config bridge-vlan
	option device 'br-lan'
	option vlan '100'
	list ports 'br-lan.100:t'
	list ports 'lan1'
	list ports 'lan2'
	list ports 'lan3'
	list ports 'lan4'
	list ports 'vxlan100'
 
config interface 'vxlan100'
	option proto 'vxlan'
	option peeraddr '192.168.100.1'
	option ipaddr '192.168.200.1'
	option port '4789'
	option vid '100'
```

You can set up bidirectional layer 2 VPN on port4 with the same approach and use difference VXLAN VNI.

Site one's port4 is send to site two's br-lan and site two's port4 is send to site one's br-lan.
