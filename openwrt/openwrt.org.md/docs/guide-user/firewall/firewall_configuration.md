# Firewall configuration /etc/config/firewall

OpenWrt's firewall management application [firewall](/docs/guide-user/firewall/overview "docs:guide-user:firewall:overview") is mainly configured through `/etc/config/firewall`.

Most of the information in this wiki will focus on the configuration files and content. The LuCI and UCI interfaces are user abstractions, ultimately modifying the configuration files.

## Management

- **The main firewall config file is `/etc/config/firewall`, and this is edited to modify the firewall settings**
  
  - ![:!:](/lib/images/smileys/exclaim.svg) *Create a backup of the firewall config prior to making changes*
    
    - Should changes cause a loss-of-connectivity to the router, you will need to access it in [failsafe mode](/docs/guide-user/troubleshooting/failsafe_and_factory_reset#failsafe_mode "docs:guide-user:troubleshooting:failsafe_and_factory_reset") to restore the backup
  - Once the settings are changed, *and after double checking changes*, reload the firewall via `/etc/init.d/firewall reload`
    
    - This is a simple shell script calling `fw4 reload`, and will print diagnostics to the console as it parses the new firewall configuration. *Check for errors!*
- **Any line using `#` in the first character is not parsed**
  
  - Comments are utilized to describe, explain, or quickly comment out, a section
- **OpenWrt 22.03 and later** ships with **firewall4** by default, which uses nftables as a backend. It accepts the same UCI configuration syntax as fw3.
- **The UCI firewall configuration in `/etc/config/firewall` covers a reasonable subset of [NetFilter](/docs/guide-user/firewall/netfilter_iptables/netfilter_openwrt "docs:guide-user:firewall:netfilter_iptables:netfilter_openwrt") rules, but not all of them**
  
  - To provide more functionality, `include` mechanisms are available.
    
    - *You can either include a shell script with nftables commands, or include nftables snippets at different locations.*
      
      - See [Firewall examples](/docs/guide-user/firewall/fw3_configurations/fw3_config_examples "docs:guide-user:firewall:fw3_configurations:fw3_config_examples") for usage (might be outdated!)
- **Whenever possible, use the firewall UCI config `/etc/config/firewall`**
  
  - There are some scenarios where custom `nftables` rules are required
    
    - See [Netfilter in OpenWrt](/docs/guide-user/firewall/netfilter_iptables/netfilter_openwrt "docs:guide-user:firewall:netfilter_iptables:netfilter_openwrt") for more information

### Web interface instructions

[LuCI](/docs/guide-user/luci/start "docs:guide-user:luci:start") is a good mechanism to view and modify the firewall configuration.

- It is located under **Network → Firewall** and maps closely to the configuration file sections.
- It takes a little longer to modify the firewall configuration, but has a higher level of organization than the config files.

Make changes and reload using the `Save & Apply` button.

- ![:!:](/lib/images/smileys/exclaim.svg) LuCI will remove all comment \[`#`] lines from `/etc/config/firewall`!

### Command-line instructions

[UCI](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") is a low-level abstraction to the configuration files and can be accessed remotely through [SSH](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration").

```
uci add firewall rule
uci set firewall.@rule[-1].name='Reject VPN to LAN traffic'
uci set firewall.@rule[-1].src='vpn'
uci set firewall.@rule[-1].dest='lan'
uci set firewall.@rule[-1].proto='all'
uci set firewall.@rule[-1].target='REJECT'
uci commit firewall
service firewall restart
```

These would be presumed to be the final rules *(each `proto` creates a rule)* in the *VPN* → *LAN* forward chain, as all packets from VPN will be rejected.

Show firewall configuration:

```
# uci show firewall
firewall.@rule[20]=rule
firewall.@rule[20].name='Reject VPN to LAN traffic'
firewall.@rule[20].src='vpn'
firewall.@rule[20].dest='lan'
firewall.@rule[20].proto='all'
firewall.@rule[20].target='REJECT'
...
```

[UCI](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") is useful to view the firewall configuration, but not to do any meaningful modifications for the following reasons:

- Essential prior knowledge of where a firewall rule needs to go into the rule array in order to make it work.
- `uci` does not recognize content within the `/etc/firewall.user` script.
- `uci commit` is necessary to save the changes, but still needs `/etc/init.d/firewall reload` to reload new tables.

## Config sections

Below is an overview of the section types that may be defined in the firewall configuration.

- A minimal firewall configuration for a router usually consists of one *defaults* section, at least two *zones* (`lan` and `wan`), and one *forwarding* to allow traffic from `lan` to `wan`.
- *The forwarding section is not strictly required when there are no more than two zones, as the rule can then be set as the 'global default' for that zone.*

### Defaults

The `defaults` section declares global firewall settings which do not belong to specific zones:

```
config defaults
	option	input			'ACCEPT'
	option	output			'ACCEPT'
	option	forward			'REJECT'
	option	custom_chains		'1'
	option	drop_invalid		'1'
	option	synflood_protect	'1'
	option	synflood_rate		'25/s'
	option	synflood_burst		'50'
	option	tcp_ecn			'1'
	option	tcp_syncookies		'1'
	option	tcp_window_scaling	'1'
```

#### Options

Name Type Required Default Description `input` string no `ACCEPT` Set policy for the `INPUT` chain of the `filter` table. `output` string no `ACCEPT` Set policy for the `OUTPUT` chain of the `filter` table. `forward` string no `REJECT` Set policy for the `FORWARD` chain of the `filter` table. `drop_invalid` boolean no `0` Drop invalid packets (e.g. not matching any active connection). `syn_flood` boolean no `0` Enable [SYN flood](https://en.wikipedia.org/wiki/SYN%20flood "https://en.wikipedia.org/wiki/SYN flood") protection (obsoleted by `synflood_protect` setting). `synflood_protect` boolean no `0` Enable [SYN flood](https://en.wikipedia.org/wiki/SYN%20flood "https://en.wikipedia.org/wiki/SYN flood") protection. `synflood_rate` string no `25/s` Set rate limit (packets/second) for SYN packets above which the traffic is considered a flood. `synflood_burst` string no `50` Set burst limit for SYN packets above which the traffic is considered a flood if it exceeds the allowed rate. `tcp_syncookies` boolean no `1` Enable the use of [SYN cookies](https://en.wikipedia.org/wiki/SYN%20cookies "https://en.wikipedia.org/wiki/SYN cookies"). `tcp_ecn` integer no `0` `0` Disable, `1` Enable, `2` Enable when requested for ingress (but disable for egress) [Explicit Congestion Notification](https://en.wikipedia.org/wiki/Explicit_Congestion_Notification "https://en.wikipedia.org/wiki/Explicit_Congestion_Notification"). Affects only traffic originating from the router itself. Implemented upstream in Linux Kernel. See [kernel docs](https://docs.kernel.org/networking/ip-sysctl.html "https://docs.kernel.org/networking/ip-sysctl.html"). `tcp_window_scaling` boolean no `1` Enable [TCP window scaling](https://en.wikipedia.org/wiki/TCP_window_scale_option "https://en.wikipedia.org/wiki/TCP_window_scale_option"). `accept_redirects` boolean no `0` Accepts redirects. Implemented upstream in Linux Kernel. See [kernel docs](https://docs.kernel.org/networking/ip-sysctl.html "https://docs.kernel.org/networking/ip-sysctl.html"). `accept_source_route` boolean no `0` Implemented upstream in Linux Kernel. See [kernel docs](https://docs.kernel.org/networking/ip-sysctl.html "https://docs.kernel.org/networking/ip-sysctl.html"). `custom_chains` boolean no `1` Enable generation of custom rule chain hooks for user generated rules. User rules would be typically stored in firewall.user but some packages e.g. BCP38 also make use of these hooks. `disable_ipv6` boolean no `0` Disable IPv6 firewall rules. (not supported by fw4) `flow_offloading` boolean no `0` Enable software flow offloading for connections. (decrease cpu load / increase routing throughput) `flow_offloading_hw` boolean no `0` Enable hardware flow offloading for connections. (depends on flow\_offloading and hw capability) `tcp_reject_code` reject\_code no `0` Defined in [firewall3/options.h](https://lxr.openwrt.org/source/firewall3/options.h#L92 "https://lxr.openwrt.org/source/firewall3/options.h#L92"). Seems to determine method of packet rejection; ([tcp reset, or drop](https://en.wikipedia.org/wiki/TCP_reset_attack "https://en.wikipedia.org/wiki/TCP_reset_attack"), vs [ICMP Destination Unreachable, or closed](https://en.wikipedia.org/wiki/Internet_Control_Message_Protocol#Destination_unreachable "https://en.wikipedia.org/wiki/Internet_Control_Message_Protocol#Destination_unreachable")) `any_reject_code` reject\_code no `1` Defined in [firewall3/options.h](https://lxr.openwrt.org/source/firewall3/options.h#L92 "https://lxr.openwrt.org/source/firewall3/options.h#L92"). Seems to determine method of packet rejection; ([tcp reset, or drop](https://en.wikipedia.org/wiki/TCP_reset_attack "https://en.wikipedia.org/wiki/TCP_reset_attack"), vs [ICMP Destination Unreachable, or closed](https://en.wikipedia.org/wiki/Internet_Control_Message_Protocol#Destination_unreachable "https://en.wikipedia.org/wiki/Internet_Control_Message_Protocol#Destination_unreachable")) `auto_helper` bool no `1` Enable Conntrack helpers `auto_includes` bool no `1` (fw4 only, 22.03 and later) Enable automatic nftables includes under `/usr/share/nftables.d/`

### Zones

A `zone` section groups one or more *interfaces* and serves as a *source* or *destination* for *forwardings*, *rules* and *redirects*.

```
config zone
	option	name		'wan'
	option	network		'wan wan6'
	option	input		'REJECT'
	option	output		'ACCEPT'
	option	forward		'REJECT'
	option	masq		'1'
	option	mtu_fix		'1'
```

- **MASQUERADE** (NAT) of outgoing traffic (WAN) is controlled on a per-zone basis on the *outgoing* interface.
- **INPUT** rules for a zone describe what happens to traffic trying to reach the router itself through an interface in that zone.
- **OUTPUT** rules for a zone describe what happens to traffic originating from the router itself going through an interface in that zone.
- **FORWARD** rules for a zone describe what happens to traffic passing between different interfaces belonging in the same zone.

#### Options

Name Type Required Default Description `name` zone name yes *(none)* Unique zone name. 11 characters is the maximum working firewall zone name length. `network` list no *(none)* List of [*interfaces*](/docs/guide-user/network/network_configuration#section_interface "docs:guide-user:network:network_configuration") attached to this zone. If omitted and neither extra* options, subnets nor devices are given, the value of `name` is used by default. Alias interfaces defined in the network config cannot be used as valid 'standalone' networks. Use [list syntax](/docs/guide-user/base-system/basic#appending_or_deleting_values_on_a_list_option "docs:guide-user:base-system:basic"). `masq` boolean no `0` Specifies whether *outgoing* zone IPv4 traffic should be masqueraded. This is typically enabled on the *wan* zone. `masq6` boolean no `0` Specifies whether *outgoing* zone IPv6 traffic should be masqueraded. This is typically enabled on the *wan* zone. Available with fw4. Requires `sourcefilter=0` for DHCPv6 interfaces with missing GUA prefix. `masq_src` list of subnets no `0.0.0.0/0` Limit masquerading to the given source subnets. Negation is possible by prefixing the subnet with `!`; multiple subnets are allowed. `masq_dest` list of subnets no `0.0.0.0/0` Limit masquerading to the given destination subnets. Negation is possible by prefixing the subnet with `!`; multiple subnets are allowed. `masq_allow_invalid` boolean no `0` Do not add `DROP INVALID` rules, if masquerading is used. The `DROP` rules are supposed to prevent NAT leakage (see [commit in firewall3](https://git.lede-project.org/?p=project%2Ffirewall3.git%3Ba%3Dcommit%3Bh%3De751cde8954a09ea32f67a8bf7974b4dc1395f2e "https://git.lede-project.org/?p=project/firewall3.git;a=commit;h=e751cde8954a09ea32f67a8bf7974b4dc1395f2e")). `mtu_fix` boolean no `0` Enable MSS clamping for *outgoing* zone traffic. `input` string no From `defaults` section Policy (`ACCEPT`, `REJECT`, `DROP`) for *incoming* zone traffic. `output` string no From `defaults` section Policy (`ACCEPT`, `REJECT`, `DROP`) for *outgoing* zone traffic. `forward` string no From `defaults` section Policy (`ACCEPT`, `REJECT`, `DROP`) for *forwarded* zone traffic. `family` string no *(auto)* Specifies the address family (`ipv4`, `ipv6` or `any`) for which the rules are generated. If unspecified, matches the address family of other options in this section and defaults to `any`. `log` int no `0` Bit field to enable logging in the filter and/or mangle tables, bit 0 = filter, bit 1 = mangle. `log_limit` string no `10/minute` Limits the amount of log messages per interval. `device` list no *(none)* List of L3 network interface names attached to this zone, e.g. `tun+` or `ppp+` to match any TUN or PPP interface. This is specifically suitable for undeclared interfaces which lack built-in netifd support such as OpenVPN. Otherwise `network` is preferable and `device` should be avoided. `subnet` list no *(none)* List of IP subnets attached to this zone. `extra` string no *(none)* Extra arguments passed directly to iptables. Note that these options are passed to both source and destination classification rules, therefor direction-specific options like `--dport` should not be used here - in this case the `extra_src` and `extra_dest` options should be used instead. `extra_src` string no *Value of `extra`* Extra arguments passed directly to iptables for source classification rules. `extra_dest` string no *Value of `extra`* Extra arguments passed directly to iptables for destination classification rules. `custom_chains` bool no `1` Enable generation of custom rule chain hooks for user generated rules. Has no effect if disabled (0) in the `defaults` section (see above). `enabled` bool no yes if set to `0`, zone is disabled `auto_helper` bool no `1` for non-masq zone Add CT helpers for zone `helper` cthelper no *(none)* List of helpers to add to zone

### Forwardings

The `forwarding` sections control the traffic flow between *zones*.

```
config forwarding
	option	src		'lan'
	option	dest		'wan'
```

- Only one direction is covered by a `forwarding` rule. To allow bidirectional traffic flows between two *zones*, two *forwardings* are required, with `src` and `dest` reversed in each.

#### Options

Name Type Required Default Description `name` forward name no *(none)* Unique forwarding name. `src` zone name yes *(none)* Specifies the traffic *source zone*. Refers to one of the defined *zone names*. For typical port forwards this usually is 'wan'. `dest` zone name yes *(none)* Specifies the traffic *destination zone*. Refers to one of the defined *zone names*. `family` string no `any` Specifies the address family (`ipv4`, `ipv6` or `any`) for which the rules are generated. `enabled` bool no yes If set to `0`, forward is disabled. `ipset` string no *(none)* If specified, match traffic against the given [*ipset*](/docs/guide-user/firewall/firewall_configuration#ip_sets "docs:guide-user:firewall:firewall_configuration"). The match can be inverted by prefixing the value with an exclamation mark.

![:!:](/lib/images/smileys/exclaim.svg) The rules generated for this section rely on the *state match* which needs connection tracking to work.

- At least one of the `src` or `dest` zones needs to have *connection tracking* enabled through the `masq` option.

### Rules

The `rule` section is used to define basic accept, drop, or reject rules to allow or restrict access to specific ports or hosts.

```
config rule
	option	name		'Reject LAN to WAN for custom IP'
	option	src		'lan'
	option	src_ip		'192.168.1.2'
	option	src_mac		'00:11:22:33:44:55'
	option	src_port	'80'
	option	dest		'wan'
	option	dest_ip		'194.25.2.129'
	option	dest_port	'120'
	option	proto		'tcp'
	option	target		'REJECT'
```

Below example is based on a **inter zone forward case** (where zone forward is set to reject) where you have one firewall zone called `lan` with two interfaces. In one interface you have a server with IP address `172.30.100.1` and the other interface is the default lan interface with `192.168.1.0/24` IP range. This configuration case will allow IPv4 `tcp` traffic from all IP addresses in the default lan interface to specifically connect only to the server IP address and to the server port `22`.

```
config rule
	option name             'forward ssh to server'
	option family           'ipv4'
	option src              'lan'
	option src_ip           '192.168.1.0/24'
	option dest             'lan'
	option dest_ip          '172.30.100.1'
	option proto            'tcp'
	option dest_port        '22'
	option target           'ACCEPT'
```

- In OpenWrt firewall, the `src` and `dest` are tied to the target:
- If `src` and `dest` are given, the rule matches *forwarded* traffic
- If only `src` is given, the rule matches *incoming* traffic
- If only `dest` is given, the rule matches *outgoing* traffic
- If neither `src` nor `dest` are given, the rule defaults to an *outgoing* traffic rule
- IP address for `src_ip` and `dest_ip` can be a specific IP address or use CIDR notations to define a complete interface group of IP addresses as a source or destination, for instance `192.168.1.0/24`.
- Port ranges are specified as `start-stop`, for instance `6666-6670`.

#### Options

Name Type Required Default Description `name` string no *(none)* Name of rule `src` zone name no *(none)* Specifies the traffic *source zone*. Refers to one of the defined *zone names*, or `*` for any zone. If omitted, the rule applies to *output* traffic. `src_ip` ip address no *(none)* Match incoming traffic from the specified *source IP address*, CIDR notations can be used, see note above. `src_mac` mac address no *(none)* Match incoming traffic from the specified *MAC address* `src_port` port or range no *(none)* Match incoming traffic from the specified *source port* or *port range*, if relevant `proto` is specified. Multiple ports can be specified like '80 443 465' [1](https://forum.openwrt.org/viewtopic.php?pid=287271 "https://forum.openwrt.org/viewtopic.php?pid=287271"). `proto` protocol name or number no `tcp udp` Match incoming traffic using the given *protocol*. Can be one (or several when using list syntax) of `tcp`, `udp`, `udplite`, `icmp`, `esp`, `ah`, `sctp`, or `all` or it can be a numeric value, representing one of these protocols or a different one. A protocol name from `/etc/protocols` is also allowed. The number `0` is equivalent to `all`. `icmp_type` list of type names or numbers no any For *protocol* `icmp` select specific ICMP types to match. Values can be either exact ICMP type numbers or type names (see below). `dest` zone name no *(none)* Specifies the traffic *destination zone*. Refers to one of the defined *zone names*, or `*` for any zone. If specified, the rule applies to *forwarded* traffic; otherwise, it is treated as *input* rule. `dest_ip` ip address no *(none)* Match incoming traffic directed to the specified *destination IP address*, CIDR notations can be used, see note above. With no dest zone, this is treated as an input rule! `dest_port` port or range no *(none)* Match incoming traffic directed at the given *destination port or port range*, if relevant `proto` is specified. Multiple ports can be specified like '80 443 465' [1](https://forum.openwrt.org/viewtopic.php?pid=287271 "https://forum.openwrt.org/viewtopic.php?pid=287271"). `ipset` string no *(none)* If specified, match traffic against the given [*ipset*](/docs/guide-user/firewall/firewall_configuration#ip_sets "docs:guide-user:firewall:firewall_configuration"). The match can be inverted by prefixing the value with an exclamation mark. You can specify the direction as 'setname src' or 'setname dest'. The default if neither src nor dest are added is to assume src `mark` mark/mask no *(none)* If specified, match traffic against the given firewall mark, e.g. `0xFF` to match mark 255 or `0x0/0x1` to match any even mark value. The match can be inverted by prefixing the value with an exclamation mark, e.g. `!0x10` to match all but mark #16. `start_date` date (`yyyy-mm-dd`) no *(always)* If specifed, only match traffic after the given date (inclusive). `stop_date` date (`yyyy-mm-dd`) no *(always)* If specified, only match traffic before the given date (inclusive). `start_time` time (`hh:mm:ss`) no *(always)* If specified, only match traffic after the given time of day (inclusive). `stop_time` time (`hh:mm:ss`) no *(always)* If specified, only match traffic before the given time of day (inclusive). `weekdays` list of weekdays no *(always)* If specified, only match traffic during the given week days, e.g. `sun mon thu fri` to only match on sundays, mondays, thursdays and Fridays. The list can be inverted by prefixing it with an exclamation mark, e.g. `! sat sun` to always match but on Saturdays and sundays. `monthdays` list of dates no *(always)* If specified, only match traffic during the given days of the month, e.g. `2 5 30` to only match on every 2nd, 5th and 30rd day of the month. The list can be inverted by prefixing it with an exclamation mark, e.g. `! 31` to always match but on the 31st of the month. `utc_time` boolean no `0` Treat all given time values as UTC time instead of local time. `target` string yes `DROP` Firewall action (`ACCEPT`, `REJECT`, `DROP`, `MARK`, `NOTRACK`) for matched traffic. `set_mark` mark/mask yes for target `MARK` *(none)* Zeroes out the bits given by mask and ORs value into the packet mark. If mask is omitted, `0xFFFFFFFF` is assumed. `set_xmark` Zeroes out the bits given by mask and XORs value into the packet mark. If mask is omitted, `0xFFFFFFFF` is assumed. `family` string no *(auto)* Specifies the address family (`ipv4`, `ipv6` or `any`) for which the rules are generated. If unspecified, matches the address family of other options in this section and defaults to `any`. `limit` string no *(none)* Maximum average matching rate; specified as a number, with an optional `/second`, `/minute`, `/hour` or `/day` suffix. Examples: `3/minute`, `3/min` or `3/m`. `limit_burst` integer no `5` Maximum initial number of packets to match, allowing a short-term average above `limit`. `extra` string no *(none)* Extra arguments to pass to iptables. Useful mainly to specify additional match options, such as `-m policy --dir in` for IPsec. `enabled` boolean no yes Enable or disable rule. `device` string no ![FIXME](/lib/images/smileys/fixme.svg) ![FIXME](/lib/images/smileys/fixme.svg) `direction` direction no ![FIXME](/lib/images/smileys/fixme.svg) ![FIXME](/lib/images/smileys/fixme.svg) *direction\_out* `set_helper` cthelper no ![FIXME](/lib/images/smileys/fixme.svg) ![FIXME](/lib/images/smileys/fixme.svg) `helper` cthelper no ![FIXME](/lib/images/smileys/fixme.svg) ![FIXME](/lib/images/smileys/fixme.svg)

#### ICMP name types

`address-mask-reply` `host-redirect` `pong` `time-exceeded` `address-mask-request` `host-unknown` `port-unreachable` `timestamp-reply` `any` `host-unreachable` `precedence-cutoff` `timestamp-request` `communication-prohibited` `ip-header-bad` `protocol-unreachable` `TOS-host-redirect` `destination-unreachable` `network-prohibited` `redirect` `TOS-host-unreachable` `echo-reply` `network-redirect` `required-option-missing` `TOS-network-redirect` `echo-request` `network-unknown` `router-advertisement` `TOS-network-unreachable` `fragmentation-needed` `network-unreachable` `router-solicitation` `ttl-exceeded` `host-precedence-violation` `parameter-problem` `source-quench` `ttl-zero-during-reassembly` `host-prohibited` `ping` `source-route-failed` `ttl-zero-during-transit`

### Redirects

Port forwardings (DNAT) are defined by `redirect` sections. *Port Redirects are also commonly known as “port forwarding” or “virtual servers”.*

- All *incoming* traffic on the specified *source zone* which matches the given rules will be directed to the specified internal host.
- Port ranges are specified as `start-stop`, for instance `6666-6670`.

#### Destination NAT

See also: [IPv6 port forwarding](/docs/guide-user/firewall/fw3_configurations/fw3_ipv6_examples#ipv6_port_forwarding "docs:guide-user:firewall:fw3_configurations:fw3_ipv6_examples")

```
config redirect
	option	name		'DNAT WAN to LAN for SSH'
	option	src		'wan'
	option	src_dport	'19900'
	option	dest		'lan'
	option	dest_ip		'192.168.1.1'
	option	dest_port	'22'
	option	proto		'tcp'
	option	target		'DNAT'
```

![:!:](/lib/images/smileys/exclaim.svg) If a `src_dport` is not included in the config section, packets matching the other config options, *on any port*, will be forwarded to the destination port specified in that config section. This could pose a security risk to the application running on the destination port the config section opens. One way to test for this issue, is to use [*Gibson Research Corporation's*](https://www.grc.com/default.htm "https://www.grc.com/default.htm") ShieldsUP! service, and probe the desired ports on your router. The response could be *open*, *closed*, or *stealth* (drop). In cases of open or closed ports, packets are reaching a destination host, and are sending ack/reply packets back. Whereas stealthed ports drop packets; from the perspective of the probing system (Gibson Research), that system cannot definitively know if those packets may, or may not be reaching the destination host.

#### Source NAT

Masquerade is the most common form of SNAT, changing the source of traffic to WAN to the router's public IP. SNAT can also be done manually:

```
config redirect
	option	name		'SNAT DMZ 192.168.1.250 to WAN 1.2.3.4 for ICMP'
	option	src		'dmz'
	option	src_ip		'192.168.1.250'
	option	src_dip		'1.2.3.4'
	option	dest		'wan'
	option	proto		'icmp'
	option	target		'SNAT'
```

#### Options

See also: [List of SNAT options @ OpenWrt SNAPSHOT](https://git.openwrt.org/?p=project%2Ffirewall3.git%3Ba%3Dblob%3Bf%3Dsnats.c%3Bhb%3DHEAD#l22 "https://git.openwrt.org/?p=project/firewall3.git;a=blob;f=snats.c;hb=HEAD#l22")

Name Type Required Default Description `name` string no *string* Name of redirect `src` zone name yes for `DNAT` target *(none)* Specifies the traffic *source zone*. Refers to one of the defined *zone names*. For typical port forwards this usually is `wan`. `src_ip` ip address no *(none)* Match incoming traffic from the specified *source IP address*. `src_dip` ip address yes for `SNAT` target *(none)* For *DNAT*, match incoming traffic directed at the given *destination IP address*. For *SNAT* rewrite the *source address* to the given address. `src_mac` mac address no *(none)* Match incoming traffic from the specified *MAC address*. `src_port` port or range no *(none)* Match incoming traffic originating from the given *source port or port range* on the client host. `src_dport` port or range no *(none)* For *DNAT*, match incoming traffic directed at the given *destination port or port range* on this host. For *SNAT* rewrite the *source ports* to the given value. `proto` protocol name or number no *tcp udp* Match incoming traffic using the given *protocol*. Can be one (or several when using list syntax) of `tcp`, `udp`, `udplite`, `icmp`, `esp`, `ah`, `sctp`, or `all` or it can be a numeric value, representing one of these protocols or a different one. A protocol name from `/etc/protocols` is also allowed. The number `0` is equivalent to `all`. `dest` zone name yes for `SNAT` target *(none)* Specifies the traffic *destination zone*. Refers to one of the defined *zone names*. Irrelevant for *DNAT* target. `dest_ip` ip address no *(none)* For *DNAT*, redirect matches incoming traffic to the specified internal host. For *SNAT*, it matches traffic directed at the given address. For *DNAT*, if the `dest_ip` is not specified, the rule is translated in a redirect rule, otherwise it is a *DNAT* rule. `dest_port` port or range no *(none)* For *DNAT*, redirect matched incoming traffic to the given port on the internal host. For *SNAT*, match traffic directed at the given ports. Only a single port or range can be specified, not disparate ports as with Rules (below). `ipset` string no *(none)* If specified, match traffic against the given [*ipset*](/docs/guide-user/firewall/firewall_configuration#ip_sets "docs:guide-user:firewall:firewall_configuration"). The match can be inverted by prefixing the value with an exclamation mark. Unsupported in firewall4. `mark` string no *(none)* If specified, match traffic against the given firewall mark, e.g. `0xFF` to match mark 255 or `0x0/0x1` to match any even mark value. The match can be inverted by prefixing the value with an exclamation mark, e.g. `!0x10` to match all but mark #16. `start_date` date (`yyyy-mm-dd`) no *(always)* If specifed, only match traffic after the given date (inclusive). `stop_date` date (`yyyy-mm-dd`) no *(always)* If specified, only match traffic before the given date (inclusive). `start_time` time (`hh:mm:ss`) no *(always)* If specified, only match traffic after the given time of day (inclusive). `stop_time` time (`hh:mm:ss`) no *(always)* If specified, only match traffic before the given time of day (inclusive). `weekdays` list of weekdays no *(always)* If specified, only match traffic during the given week days, e.g. `sun mon thu fri` to only match on Sundays, Mondays, Thursdays and Fridays. The list can be inverted by prefixing it with an exclamation mark, e.g. `! sat sun` to always match but on Saturdays and sundays. `monthdays` list of dates no *(always)* If specified, only match traffic during the given days of the month, e.g. `2 5 30` to only match on every 2nd, 5th and 30rd day of the month. The list can be inverted by prefixing it with an exclamation mark, e.g. `! 31` to always match but on the 31st of the month. `utc_time` boolean no `0` Treat all given time values as UTC time instead of local time. `target` string no `DNAT` NAT target (`DNAT` or `SNAT`) to use when generating the rule. `family` string no *(auto)* Specifies the address family (`ipv4`, `ipv6` or `any`) for which the rules are generated. If unspecified, matches the address family of other options in this section and defaults to `ipv4`. `reflection` boolean no `1` Activate NAT reflection for this redirect - applicable to `DNAT` targets. `reflection_src` string no `internal` The source address to use for NAT-reflected packets if `reflection` is `1`. This can be `internal` or `external`, specifying which interface’s address to use. Applicable to `DNAT` targets. `reflection_zone` list of zone names no *(none)* List of zones for which reflection should be enabled. Applicable to `DNAT` targets. `limit` string no *(none)* Maximum average matching rate; specified as a number, with an optional `/second`, `/minute`, `/hour` or `/day` suffix. Examples: `3/second`, `3/sec` or `3/s`. `limit_burst` integer no `5` Maximum initial number of packets to match, allowing a short-term average above `limit`. `extra` string no *(none)* Extra arguments to pass to iptables. Useful mainly to specify additional match options, such as `-m policy --dir in` for IPsec. `enabled` string no `1` or `yes` Enable the redirect rule or not. `helper` cthelper no ![FIXME](/lib/images/smileys/fixme.svg) ![FIXME](/lib/images/smileys/fixme.svg)

### IP sets

See also: [IP set examples](/docs/guide-user/firewall/fw3_configurations/fw3_config_ipset "docs:guide-user:firewall:fw3_configurations:fw3_config_ipset")

fw4 supports referencing or creating [IP sets](https://wiki.nftables.org/wiki-nftables/index.php/Sets "https://wiki.nftables.org/wiki-nftables/index.php/Sets") to simplify matching of large address or port lists without the need for creating one rule per item to match. fw4 [supports fewer options](https://git.openwrt.org/?p=project%2Ffirewall4.git%3Ba%3Dblob%3Bf%3Droot%2Fusr%2Fshare%2Fucode%2Ffw4.uc%3Bh%3D47e86cd7dd2a0f87caeccde51710330199905fd3%3Bhb%3D47e86cd7dd2a0f87caeccde51710330199905fd3#l3189 "https://git.openwrt.org/?p=project/firewall4.git;a=blob;f=root/usr/share/ucode/fw4.uc;h=47e86cd7dd2a0f87caeccde51710330199905fd3;hb=47e86cd7dd2a0f87caeccde51710330199905fd3#l3189") (see [below](/docs/guide-user/firewall/firewall_configuration#options_fw4 "docs:guide-user:firewall:firewall_configuration")).

#### Options (fw3)

Name Type Required Default Description `enabled` boolean no `1` Allows to disable the declaration of the ipset without the need to delete the section. `external` string no *(none)* If the `external` option is set to a name, the firewall will simply reference an already existing ipset pointed to by the name. If the `external` option is unset, the firewall will create the ipset on start and destroy it on stop. `name` string yes if `external` is unset  
no if `external` is set *(none)* if `external` is unset  
value of `external` if `external` is set Specifies the firewall internal name of the ipset which is used to reference the set in rules or redirects. `family` string no `ipv4` Specifies the address family (`ipv4` or `ipv6`) for which the IP set is created. Only applicable to storage types `hash` and `list`, the `bitmap` type implies `ipv4`. `storage` string no *varies* Specifies the storage method (`bitmap`, `hash` or `list`) used by the ipset, the default varies depending on the used datatypes (see `match` option below). In most cases the storage method can be automatically inferred from the datatype combination but in some cases multiple choices are possible (e.g. `bitmap:ip` vs. `hash:ip`). ![:!:](/lib/images/smileys/exclaim.svg) This is only required by fw3 and must be removed from the fw4 configuration. `match` list of direction/type tuples yes *(none)* Specifies the matched data types (`ip`, `port`, `mac`, `net` or `set`) and their direction (`src` or `dest`). The direction is joined with the datatype by an underscore to form a tuple, e.g. `src_port` to match source ports or `dest_net` to match destination CIDR ranges. When using ipsets matching on multiple elements, e.g. `hash:ip,port`, specify the packet fields to match on in quotes or comma-separated (i.e. “match dest\_ip dest\_port”). `iprange` IP range yes for storage type `bitmap` with datatype `ip` *(none)* Specifies the IP range to cover, see [ipset(8)](http://ipset.netfilter.org/ipset.man.html "http://ipset.netfilter.org/ipset.man.html"). Only applicable to the `hash` storage type. `portrange` Port range yes for storage type `bitmap` with datatype `port` *(none)* Specifies the port range to cover, see [ipset(8)](http://ipset.netfilter.org/ipset.man.html "http://ipset.netfilter.org/ipset.man.html"). Only applicable to the `hash` storage type. `netmask` integer no `32` If specified, network addresses will be stored in the set instead of IP host addresses. Value must be between `1` and `32`, see [ipset(8)](http://ipset.netfilter.org/ipset.man.html "http://ipset.netfilter.org/ipset.man.html"). Only applicable to the `bitmap` storage type with match `ip` or the `hash` storage type with match `ip`. `maxelem` integer no `65536` Limits the number of items that can be added to the set, only applicable to the `hash` and `list` storage types. `hashsize` integer no `1024` Specifies the initial hash size of the set, only applicable to the `hash` storage type. `timeout` integer no `0` Specifies the default timeout for entries added to the set. A value of `0` means enabling the timeout capability flag on a set, but do not put the timeout to entries. `entry` setentry no *(none)* The IP address, CIDR, or MAC. Each list entry is a single CIDR, or IP etc when not using ranges or masks etc above. `loadfile` string no *(none)* A path URL on the openwrt filesystem to a file containing a list of CIDRs.

#### Options (fw4)

Name Type Required Default Description `enabled` boolean no `1` Allows to disable the declaration of the ipset without the need to delete the section. `comment` boolean no *(none)* Seems like a bug: should be a string for user defined comment. `name` string yes *(none)* Specifies the firewall internal name of the ipset which is used to reference the set in rules or redirects. `family` string no `ipv4` Specifies the address family (`ipv4` or `ipv6`) for which the IP set is created. `match` list of ipsettypes yes *(none)* Specifies the matched data types (`ip`, `port`, `mac`, `net` or `set`) and their direction (`src` or `dest`). The direction is joined with the datatype by an underscore to form a tuple, e.g. `src_port` to match source ports or `dest_net` to match destination CIDR ranges. `maxelem` integer no `65536` Limits the number of items that can be added to the set. `timeout` integer no `0` Specifies the default timeout for entries added to the set. A value of `0` means enabling the timeout capability flag on a set, but do not put the timeout to entries. `entry` List of `entry` no The IP address, CIDR, or MAC. Each list entry is a single CIDR, or IP etc. `loadfile` string no *(none)* A path URL on the openwrt filesystem to a file containing a list of CIDRs.

#### IP set types

`prefix_suffix`

Prefix, aka direction Suffix aka datatype Notes src\_* Source matching of `suffix` dest\_* Destination matching of `suffix` \_ip IP addresses \_port TCP/UDP ports \_mac MAC addresses \_net Subnets \_set Unsupported in firewall4

#### Storage / Match options

The order of datatype matches is significant

Family Storage Match Notes `ipv4` `bitmap` `ip` Requires `iprange` option `ipv4` `bitmap` `ip mac` Requires `iprange` option `ipv4` `bitmap` `port` Requires `portrange` option *any* `hash` `ip` - *any* `hash` `net` - *any* `hash` `ip port` - *any* `hash` `net port` - *any* `hash` `ip port ip` - *any* `hash` `ip port net` - - `list` `set` Meta type to create a set-of-sets

### Includes (22.03 and later with fw4)

`fw4` has several ways to include custom firewall rules. In all cases, the custom rules need to be written in nftables-style.

#### Config include section with nftables snippets

One way is to include `nftables` snippets. There are several possible positions in the nftables structure.

For example, to add custom logging to the `input_wan` chain:

```
# /etc/config/firewall
config include
	option	type		'nftables'
	option	path		'/etc/my_custom_firewall_rule.nft'
	option	position	'chain-pre'
	option	chain		'input_wan'
 
# /etc/my_custom_firewall_rule.nft
tcp dport 0-1023 log prefix "Inbound WAN connection attempt to low TCP port: "
```

To add one or more custom chains:

```
config include
	option	type		'nftables'
	option	path		'/etc/my_custom_firewall_chain.nft'
	option	position	'table-post'
```

Supported options:

Name Type Required Default Description `enabled` boolean no `1` Allows to disable the corresponding include without having to delete the section `type` string no `script` Specifies the type of the include, either `script` for compatibility with fw3 (shell script, see below) or `nftables` for nftables snippets `path` file name yes - Specifies the filename to include `position` string yes (if type is nftables) `table-post` Specifies the position at which the rules will be inserted (see below for allowed values) `chain` string yes (if position matches `chain-*`) - Specifies the chain in which the rules will be inserted

The possible positions for nftables snippets are:

Position Meaning `ruleset-pre` At the very beginning, before the fw4 table definition `ruleset-post` At the very end, after the fw4 table definition `table-pre` At the beginning of the fw4 table, before any chain definition `table-post` At the end of the fw4 table, after all chains definition `chain-pre` At the beginning of $chain (defined in `option chain`), before rules in this chain `chain-post` At the end of $chain (defined in `option chain`), after rules in this chain

Run `fw4 print` to understand the table / chain / rules structure.

Note that `-pre` can also be written as `-prepend`, and `-post` can also be written as `-postpend` or `-append`.

#### Config include section with shell script

Custom rule inclusion through a shell script works similarly as fw3, but the script should use nftables. Option `fw4_compatible` is required when the path is `/etc/firewall.user` to indicate to fw4 that the script is compatible with nftables.

```
config include
	option	enabled		1
	option	type		'script'
	option	path		'/etc/firewall.user'
	option	fw4_compatible	1
```

Options `family` and `reload` from fw3 are no longer supported with fw4.

#### Default drop-in includes

fw4 includes `/etc/nftables.d/*.nft` by default, at the beginning of the fw4 table (equivalent to the `table-pre` position)

It means that custom chains can be created by adding a file ending in `.nft` in the `/etc/nftables.d/` directory.

#### Drop-in includes for package authors

For package authors that need custom firewall rules, it is possible to add nftables snippets in the following directories, depending on the desired position:

Path Position `/usr/share/nftables.d/ruleset-pre/*.nft` Included at the very beginning, before the fw4 table definition `/usr/share/nftables.d/ruleset-post/*.nft` Included at the very end, after the fw4 table definition `/usr/share/nftables.d/table-pre/*.nft` Included at the beginning of the fw4 table, before any chain definition `/usr/share/nftables.d/table-post/*.nft` Included at the end of the fw4 table, after all chains definition `/usr/share/nftables.d/chain-pre/${chain}/*.nft` Included at the beginning of `${chain}` (a valid fw4 chain name), before rules in this chain `/usr/share/nftables.d/chain-post/${chain}/*.nft` Included at the end of `${chain}` (a valid fw4 chain name), after rules in this chain

Snippets need to be readable files and their name must end with `.nft`.

### Includes (21.02 and earlier with fw3)

It is possible to include custom firewall scripts by specifying one or more `include` sections in the firewall configuration:

```
config include
	option	path		'/etc/firewall.user'
```

The `/etc/firewall.user` script is empty by default.

#### Options

Name Type Required Default Description `enabled` boolean no `1` Allows to disable the corresponding include without having to delete the section. `type` string no `script` Specifies the type of the include, can be `script` for traditional shell script includes or `restore` for plain files in *iptables-restore* format. `path` file name yes `/etc/firewall.user` Specifies a shell script to execute on boot or firewall restarts. `family` string no `any` Specifies the address family (`ipv4`, `ipv6` or `any`) for which the include is called. `reload` boolean no `0` Specifies whether the include should be called on reload. This is only needed if the include injects rules into internal chains.

Includes of type `script` may contain arbitrary commands, for example advanced nftables rules or tc commands required for traffic shaping.
