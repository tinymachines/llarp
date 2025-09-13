# IPv4 firewall examples

This section contains a collection of useful [firewall](/docs/guide-user/firewall/overview "docs:guide-user:firewall:overview") configuration examples based on the UCI configuration files. All of these can be added on the LuCI *Network → Firewall → Traffic Rules* page.

In keeping with the underlying netfilter service, the first matching rule will run its target and (with a couple of exceptions) filtering stops; no subsequent rules are checked. LuCI has the capability to move rules up and down to sort them correctly.

See [Reference Network Topology](/docs/guide-user/firewall/fw3_configurations/fw3_ref_topo "docs:guide-user:firewall:fw3_configurations:fw3_ref_topo") for a visual representation of the network used to test the examples here. These examples cover only IPv4 networks.

The term **station** is used to refer to any electronic device that can source or sink packets through, or to/from, the router. This can be a web server, mobile phone, tablet, laptop, IoT device on the LAN-side or the WAN-side. The netfilter rules match stations and traffic types to allow packets to continue through the network stack or not.

Unless otherwise noted, all rules have been tested mostly with [netcat](https://en.wikipedia.org/wiki/Netcat "https://en.wikipedia.org/wiki/Netcat") and [curl](https://curl.haxx.se/ "https://curl.haxx.se/"). The `enabled` option in each rule is toggled between tests to verify the specific rule causes the expected behavior - on will cause packets to be accepted or not, off will cause the opposite behavior.

![:!:](/lib/images/smileys/exclaim.svg) Before modifying rules, be sure to back-up your current `/etc/config/firewall`!

## Opening ports on the OpenWrt router

The default configuration accepts all LAN traffic, but blocks all incoming WAN traffic on ports not currently used for connections or NAT. The reference topology blocks all LAN and WAN traffic, requiring a rule to open port(s) for a service.

```
config	rule
	option	target		'ACCEPT'
	option	src		'wan'
	option	proto		'tcp'
	option	dest_port	'22'
	option	name		'ACCEPT-SSH-WAN-DEVICE'
	option	enabled		'1'
```

This example enables stations on the WAN-side to use SSH to access the router (the default destination).

![:!:](/lib/images/smileys/exclaim.svg) If the WAN-side of the router is connected to the internet this rule allows any public site SSH access to your router. Once a portscanner discovers the open SSH port it will repeatedly try to break in - even with a strong pub key these attacks can be a nuisance.

## Opening ports for selected subnet/host

Use **src\_ip** and **dest\_ip** options to match on specific subnets.

```
config	rule
	option	target		'ACCEPT'
	option	src		'wan'
	option	family		'ipv4'
	option	proto		'tcp'
	option	src_ip		'192.168.3.0/24'
	option	dest_port	'22'
	option	name		'ACCEPT-SSH-INTERNAL-DEVICE'
	option	enabled		'1'
```

This example enables SSH access to the router from any station in the private `192.168.3.0/24` address block. It will not match any other src IP address.

![:!:](/lib/images/smileys/exclaim.svg) When using an IPv4 address set the family to **ipv4**, otherwise firewall warns `! Skipping due to different family of ip address`.

## Block WAN-side networks and ports

When public-facing servers run behind the firewall (e.g. mail server), each is susceptible to attacks: SSH probing, SPAM, screen-scraping, etc.

Customers of the large overseas ISPs (particular China and Vietnam) have made spam attacks into an artform, generating blocks of prose to confuse spam filters, sprinkling emails across many source stations and many subnets. The best way to counter this is to block the main originating network sending the spam.

```
config	rule
	option	src		'wan'
	option	dest		'lan'
	option	proto		'tcp'
	option	src_ip		'42.56.0.0/16'
	option	dest_port	'25'
	option	target		'DROP'
	option	name		'DROP-WAN-0001'
	option	enabled		'1'
```

In this example, stations in a Beijing network are sending email spam in bursts of three with different content incrementing ipv4 addresses across subnets! This rule DROPS all incoming traffic on port 25 (SMTP) from any station in their network. DROP silently discards the packet rather than REJECT which returns a response to the source.

![:!:](/lib/images/smileys/exclaim.svg) Once the number of blocked networks grows to more than a couple dozen (there are thousands of spamming sites), then adding each to the firewal config becomes prohibitive to manage. Two alternatives are:

- add individual netfilter rules to `/etc/firewall.user`
- use the `ipset` mechanism described in [ipset examples](/docs/guide-user/firewall/fw3_configurations/fw3_config_ipset "docs:guide-user:firewall:fw3_configurations:fw3_config_ipset")

## Using ipset to block LAN-side networks

The example below creates a rule in the netfilter FORWARD chain, rejecting traffic from the LAN-side to the WAN-side on the ports 1000-1100.

```
config	rule
	option	src		'lan'
	option	dest		'wan'
	option	dest_port	'1000-1100'
	option	proto		'tcp udp'
	option	target		'REJECT'
	option	name		'REJECT-LAN-WAN-PORTS'
	option	enabled		'1'
```

## Block LAN-side access to a specific site

The following rule blocks HTTP/S connections from all LAN-side stations to a single public site. Use a DNS utility (`dig` or `nslookup`) to map the public domain name to its IP address.

```
config	rule
	option	src		'lan'
	option	dest		'wan'
	option	proto		'tcp'
	option	family		'ipv4'
	option	dest_ip		'63.251.153.68'
	option	dest_port	'80 443'
	option	target		'REJECT'
	option	name		'REJECT-LAN-SITE-HTTP'
	option	enabled		'1'
```

Notice the **dest\_port** option has two ports: HTTP and HTTPS. When there is white space in the list it must be surrounded by single quotes.

If the source or destination is the router itself then the option is not explicitly defined in a rule. For reference, these rules are added to the netfilter INPUT (to the router) and OUTPUT (from the router) chains.

```
config	rule
	option	dest		'wan'
	option	dest_ip		'8.8.8.8'
	option	family		'ipv4'
	option	proto		'icmp'
	option	target		'REJECT'
	option	name		'REJECT-DEVICE-DNS'
	option	enabled		'1'
```

This rule causes netfilter to reject any icmp echo from the router (OUTPUT chain) to the public google DNS server. This rule is not particularly useful but serves as an illustrative example.

## Block access to certain domains based on their names

An example is give at [Blocking IPs based on their hostname](/docs/guide-user/firewall/fw3_configurations/fw3_parent_controls#blocking_ips_based_on_their_domainnames_fqdn_hostnames "docs:guide-user:firewall:fw3_configurations:fw3_parent_controls") This is really useful if large CDNs need to be filtered based on their names. It is also capable to filter DDNS hosts. It has also the advantage to allow for other subdomains (like www.) by just filtering the root-domain-name (like example.com).

## Block access to the Internet for a specific LAN station between certain times

The following rule can be used for parental access control.

```
config	rule
	option	src		'lan'
	option	dest		'wan'
	option	src_mac		'4C:EB:42:32:0C:9E'
	option	proto		'tcp udp'
	option	start_time	'21:00:00'
	option	stop_time	'09:00:00'
	option	utc_time	'0'
	option	weekdays	'Mon Tue Wed Thu Fri'
	option	target		'REJECT'
	option	name		'REJECT-LAN-WAN-TIME'
	option	enabled		'1'
```

When this rule is enabled, it will block all TCP and UDP access from STA2 to the internet on weekdays between 21:00 and 09:00. By default, the time will be UTC unless the `utc_time` option is cleared (`0`).

These time/date matches use the netfilter `xt_time` kernel module, which is included in the release. Check `/proc/modules` to confirm it is loaded.

From LuCI this rule can be added by following “Firewall→Traffic Rules” and creating a new rule with the desired MAC address and an action of “block” or “reject.”

![:!:](/lib/images/smileys/exclaim.svg) Remove the time and day options to always block WAN-side access for the station.

![:!:](/lib/images/smileys/exclaim.svg) This rule can be created for a single MAC address, not a range.

![:!:](/lib/images/smileys/exclaim.svg) this type of rule is very useful for mobile devices like smartphones and tablets. A lot can change in a smartphone but the wifi MAC is **almost** always programmed at the factory. The MAC **can** be modified by a sophisticated user by doing something similar to the Linux commands:

```
root> ip link set wlan0 down
root> ip link set address "de:ad:be:ef:00:01" wlan0
root> ip link set wlan0 up
```

An alternative mechanism to block multiple LAN MACs can be found in the LuCI “Wireless→Interface Edit→MAC Filter” section. Set the filter for “Allow all except listed” and add multiple LAN MACs. In the `/etc/config/wireless` file, this creates a “list maclist” entry for the interface.

## IPSec passthrough

This example enables proper forwarding of IPSec traffic through the wan. The protocol references are: * `ah` [IP Authentication Header](https://www.ietf.org/rfc/rfc2402.txt "https://www.ietf.org/rfc/rfc2402.txt") * `esp` [Encap Security Payload](https://www.ietf.org/rfc/rfc2406.txt "https://www.ietf.org/rfc/rfc2406.txt")

```
config	rule
	option	src		'wan'
	option	dest		'lan'
	option	proto		'ah'
	option	target		'ACCEPT'
 
config	rule
	option	src		'wan'
	option	dest		'lan'
	option	proto		'esp'
	option	target		'ACCEPT'
```

For some configurations you also have to open port 500/UDP for the ISAKMP protocol.

```
config	rule
	option	src		'wan'
	option	dest		'lan'
	option	proto		'udp'
	option	src_port	'500'
	option	dest_port	'500'
	option	target		'ACCEPT'
```

## Zone declaration for semi non-UCI interfaces, manually listed in the network config, and forwardings

Scenario: having one or more VPN tunnels using OpenVPN, with the need of defining a zone to forward the traffic between the VPN interfaces and the LAN.

First list the interfaces in **/etc/config/network**, for example, as written below. Be careful on the limits of interface naming in terms of name length, [read more](/docs/guide-user/network/network_configuration#section_interface "docs:guide-user:network:network_configuration"))

```
config	interface	'tun0'
	option	ifname		'tun0'
	option	proto		'none'
 
config	interface	'tun1'
	option	ifname		'tun1'
	option	proto		'none'
```

Then create the zone in **/etc/config/firewall**, for example one zone for all the vpn interfaces.

```
config	zone
	option	name		'vpn_tunnel'
	list	network		'tun0'
	list	network		'tun1'
	option	input		'ACCEPT'
	# the traffic towards the router from the interface will be accepted
	# (as for the lan communications)
	option	output		'ACCEPT'
	# the traffic from the router to the interface will be accepted
	option	forward		'REJECT'
	# traffic from this zone to other zones is normally rejected
```

Then we want to communicate with the “lan” zone, therefore we need forwardings in both ways (from lan to wan and viceversa).

```
config	forwarding
	option	src		'lan'
	option	dest		'vpn_tunnel'
	# if a packet from lan wants to go to the vpn_tunnel zone
	# let it pass
 
config	forwarding
	option	src		'vpn_tunnel'
	option	dest		'lan'
	# if a packet from vpn_tunnel wants to go to the lan zone
	# let it pass
```

In general remember that forwardings are relying how routing rules are defined, and afterwards which zones are defined on which interfaces.

## Zone declaration for non-UCI interfaces

This example declares a zone which matches any Linux network device whose name begins with “ppp”.

```
config	zone
	option	name		'example'
	option	input		'ACCEPT'
	option	output		'ACCEPT'
	option	forward		'REJECT'
	option	device		'ppp+'
```

## Zone declaration for a specific subnet and protocol

This example declares a zone which maches any TCP stream in the `10.21.0.0/16` subnet.

```
config	zone
	option	name		'example'
	option	input		'ACCEPT'
	option	output		'ACCEPT'
	option	forward		'REJECT'
	option	subnet		'10.21.0.0/16'
	option	extra		'-p tcp'
```

## Zone declaration for a specific protocol and port

This example declares a zone which maches any TCP stream from and to port `22`.

```
config	zone
	option	name		'example'
	option	input		'ACCEPT'
	option	output		'ACCEPT'
	option	forward		'REJECT'
	option	extra_src	'-p tcp --sport 22'
	option	extra_dest	'-p tcp --dport 22'
```

## Stateful firewall without NAT

I have not tested this, but it **seems** reasonable.

In reality, the monthly cost of a block of public IPv4 addresses makes sense for ISPs that distribute the addresses to customers for a fee and larger corporations that need public addresses for their internet presence (e.g. web, mail, name servers, remote offices)

If your LAN is running with public IP addresses, then you definitely don't want NAT (masquerading). But you may still want to run a stateful firewall on the router, so that stations on the LAN-side are not reachable from the WAN-side.

To do this, add the `conntrack` option to the WAN zone:

```
config	zone
	option	name		'wan'
	list	network		'wan'
	list	network		'wan6'
	option	input		'REJECT'
	option	output		'ACCEPT'
	option	forward		'REJECT'
	option	masq		'0'
	option	mtu_fix		'1'
	option	conntrack	'1'
```

## Allow HTTP/HTTPS access from Cloudflare

Here is an example that allows HTTP/HTTPS access from Cloudflare. Use if your webserver is behind the Cloudflare proxy.

```
cat << EOF >> /etc/firewall.user
uci -q delete firewall.cf_proxy.dest_ip
for IPV in 4 6
do for IP in $(wget -O - \
"https://www.cloudflare.com/ips-v${IPV}")
do uci add_list firewall.cf_proxy.dest_ip="${IP}"
done
done
service firewall reload
EOF
uci -q delete firewall.cf_proxy
uci set firewall.cf_proxy="rule"
uci set firewall.cf_proxy.name="Allow-Cloudflare-Proxy"
uci set firewall.cf_proxy.src="wan"
uci add_list firewall.cf_proxy.dest_port="80"
uci add_list firewall.cf_proxy.dest_port="443"
uci set firewall.cf_proxy.proto="tcp"
uci set firewall.cf_proxy.target="ACCEPT"
uci commit firewall
service firewall restart
```
