# mwan3 (Multi WAN load balancing/failover)

- 23.05: Latest release: [2.11.8](/packages/pkgdata/mwan3 "packages:pkgdata:mwan3")
- 22.03: Latest release: 2.11.7
- 21.02: Latest release: 2.10.13-1

### About mwan3

The `mwan3` package provides the following functionality and capabilities:

- Outbound WAN traffic load balancing or fail-over with multiple WAN interfaces based on a numeric weight assignment
- Monitors each WAN connection using repeated tests and can automatically route outbound traffic to another WAN interface if the first WAN interface loses connectivity
- Creating outbound traffic rules to customize which outbound connections should use which WAN interface (policy based routing). This can be customised based on source IP, destination IP, source port(s), destination port(s), type of IP protocol etc
- Physical and/or logical WAN interfaces are supported
- The firewall mask (default `0x3F00`) which is used to mark outgoing traffic can be configured in the `/etc/config/mwan3` globals section. This is useful if you also use other packages (nodogsplash) which use the firewall masking feature. This value is also used to set how many interfaces are supported.

#### Overview of how routing with mwan3 works

The following steps are taken to route a packet with mwan3:

Every incoming packet (this includes router originated traffic) is handled by the iptables mwan3\_hook. This hook takes 5 steps:

1. Restore mark if previous set. If successful marked, goto step 5.
2. Check if the packet arrives on a wan interface. If originated from a local connected ip network, then mark packet with default iface\_id. If the packet is from another (non-local) network and arrives on wan interface, then mark it with iface\_id. If successful marked, goto step 5.
3. Check if packet destined for a known ip network (has a route for it other than default). If so then mark packet with default iface\_id and goto step 5.
4. Check if packet source address is that of a wan interface. If so use that wan interface for routing regardless of user defined rules and mark packet with iface\_id of corresponding wan.
5. Apply user rules and mark with configured iface\_id. If no match leave unmarked.
6. If marked then save mark.

Remember that iptables only marks the packet, it does not make routing decisions. Next in line are the ip rules. In following order they are:

1. Ip rules 1001 till 1250 are for wan interface 1 till 250 respectively. This rule says: If packet is incoming from wan interface use main routing table, regardless of mark.
2. Ip rules 2001 till 2250 are for wan interface 1 till 250 respectively. This rule says: If packet is marked with iface\_id \[1-252], use the corresponding wan interface routing table.
3. Ip rule 2253 is a blackhole rule. This rule states: If packet is marked with iface\_id 253 (blackhole), silently drop packet.
4. Ip rule 2254 is a blackhole/unreachable rule. This rule states: If packet is marked with iface\_id 254 (unreachable), drop packet and return icmp unreachable.

Next up are the routing tables. These are really simple. There is just the standard main routing table and one routing table containing one gateway for each wan interface. Route table 1 for the first wan, route table 2 for the second and so on. Hopes this make troubleshooting easier.

#### Why should I use mwan3?

- If you have multiple internet connections and you want to control what traffic goes through which specific WAN interface.
- Mwan3 can handle multiple levels of primary and backup interfaces, load-balanced or not. Different sources can have different primary or backup WANs.
- Mwan3 uses netfilter mark mask to be compatible with other packages (such as OpenVPN, PPTP VPN, QoS-script, Tunnels, etc) as you can configure traffic to use the default routing table.
- Mwan3 can also load-balance traffic originating from the router itself

#### How mwan3 load-balancing works

- mwan3 uses normal Linux policy routing to balance outgoing traffic over multiple WAN connections
- Linux outgoing network traffic load-balancing is performed on a per-IP connection basis -- it is not channel-bonding, where a single connection (e.g. a single download) will use multiple WAN connections simultaneously
- As such load-balancing will help speed multiple separate downloads or traffic generated from a group of source PCs all accessing different sites but it will not speed up a single download from one PC (unless the download is spread across multiple IP streams such as by using a download manager)

#### Architecture of mwan3

- mwan3 is triggered by [hotplug-events](/docs/guide-user/base-system/hotplug "docs:guide-user:base-system:hotplug"). When an interface comes up, it creates a custom routing table and iptables rules. A new routing table is created for each interface. It then sets up iptables rules and uses iptables MARK to mark certain traffic. Based on these rules, the kernel determines which routing table to use. When an interface goes down, mwan3 deletes all the rules and routes to that interface.
- Once all the routes and rules are initially set up, mwan3 exits. The kernel takes care of all the routing decisions. If a new interface hotplug event occurs, mwan3 will run again to adjust route and tables as needed.
- A monitoring script (mwan3track) runs in the background checking if each WAN interface is up using a connectivity test (default is ping). If an interface goes down, the script issues a hotplug event to cause mwan3 to adjust the routing tables of the interface that has gone down.
- Any routing table changes are constantly monitored by an another component (mwan3rtmon) which is responsible for keeping the main routing table in sync with the interface routing tables.

## Prerequisites

Ensure no other multiple WAN or policy routing packages are installed such as `multiwan`. Having `multiwan` installed at the same time as mwan3 is known not to work and is an obsolete package. Equally make sure you aren't using an other package that makes use of the same firewall mask value mwan3 uses as this will cause conflicts. The firewall mask value used by mwan3 is able to be changed in the configuration to avoid this problem.

### OpenWrt version

#### 23.05

The mwan3 package is mostly unchanged between 22.03 and 23.05, with some additional fixes but otherwise mostly the same.

**Known issues:**

- [mwan3: ipset functionality broken on 23.05](https://github.com/openwrt/packages/issues/22474 "https://github.com/openwrt/packages/issues/22474"). [Workaround init script available](/docs/guide-user/network/wan/multiwan/mwan3#nft2ipset_init_script "docs:guide-user:network:wan:multiwan:mwan3").

#### 22.03

22.03 switched to firewall4/nftables for firewall management, mwan3 has not been updated to natively support nftables yet and therefore needs the `iptables-nft` and `ip6tables-nft` packages installed for a iptables compatibility layer for firewall rules to work. [See installation steps](/docs/guide-user/network/wan/multiwan/mwan3#installation "docs:guide-user:network:wan:multiwan:mwan3") for more information.

**Known issues:**

There are a few regressions between 2.10 and 2.11 identified with sticky rules and ipset. An issue with fwmark and tunnel connections can cause traffic to be incorrectly routed e.g. L2TP, 6in4 and IPv6 traffic within the tunnel is also present under certain configurations.

- [mwan3: Legacy rules detected](https://github.com/openwrt/packages/issues/19472 "https://github.com/openwrt/packages/issues/19472") (See installation steps)
- [mwan3: fix addition of routes to mwan3\_connected ipset](https://github.com/openwrt/packages/pull/20900 "https://github.com/openwrt/packages/pull/20900")
- [mwan3: fix addition of iptables rules for mwan3 sticky rules](https://github.com/openwrt/packages/pull/20901 "https://github.com/openwrt/packages/pull/20901")
- [mwan3: fix some tunnels assigned the wrong mark](https://github.com/openwrt/packages/pull/20923 "https://github.com/openwrt/packages/pull/20923")

#### 21.02

**No longer supported.**

The version of mwan3 in 21.02 is 2.10.13-1, it has a lot of improvements over the version in 19.07 for both performance and stability.

For those running some form of tunnel based protocol e.g. L2TP, 6in4 and IPv6 traffic within the tunnel may encounter routing issues due to fwmark behaviour that unintentionally marks all incoming traffic which can break routing in many cases.

**Known issues:**

- [mwan3: fix some tunnels assigned the wrong mark](https://github.com/openwrt/packages/pull/20923 "https://github.com/openwrt/packages/pull/20923")

Older versions beyond the old and current stable are no longer supported and unlikely to receive support.

You can find the current open issues for mwan3 on the [OpenWrt packages repository](https://github.com/openwrt/packages/issues?q=is%3Aissue%20is%3Aopen%20in%3Atitle%20mwan3 "https://github.com/openwrt/packages/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+mwan3"). User feedback is welcome to help with identifying bugs and issues found with different network setups. Features requests or contributions are also welcome!

### Hardware requirements

Any router that is officially supported by OpenWrt should be suitable to run mwan3. Preferably using a supported router with working [VLAN support](/docs/guide-user/network/vlan/switch_configuration "docs:guide-user:network:vlan:switch_configuration") would be recommended. This is because the simplest way to create additional WAN interfaces is to use VLANs by putting individual LAN switch ports into their own VLAN, thus each becoming separate interfaces.

Check the [table of hardware list](/toh/start "toh:start") and device page for details on your router to confirm what is supported.

#### Single WAN Port

If having LAN ports repurposed as WAN ports is not possible, it is also possible create virtual eths with **kmod-macvlan**.

```
opkg update
opkg install kmod-macvlan
```

Here is a basic example of creating virtual eth interfaces.

[/etc/config/network](/_export/code/docs/guide-user/network/wan/multiwan/mwan3?codeblock=1 "Download Snippet")

```
config device 'veth5'
    option name 'veth5'
    option type 'macvlan'
    option ifname 'eth1'
 
config device 'veth7'
    option name 'veth7'
    option type 'macvlan'
    option ifname 'eth1'
```

## Installation

### Command line (SSH)

```
opkg update
opkg install mwan3
opkg install luci-app-mwan3
```

`luci-app-mwan3` is optional, if you don't wish to manage rules through LuCI.

For routers using 22.03 or above the default firewall uses firewall4/nftables, the packages `iptables-nft` and `ip6tables-nft` are needed for mwan3 functionality to work. mwan3 does not currently natively support nftables, but does function with the iptables compatibility backend which will translate rules to be compatible with nftables.

**For 22.03 or later:**

```
opkg install iptables-nft
opkg install ip6tables-nft
```

### Web interface (LuCI)

- Go to System → Software
  
  - click “Update lists” to get the latest package databases
  - In the “Download and install package:” box, enter `luci-app-mwan3` and click OK to download and install the package, dependencies including mwan3 itself will be installed.
  - For 22.03: Install the `iptables-nft` and `ip6tables-nft` backend which is required for translating mwan3 rules to work with nftables.

#### Restart LuCI or reboot if needed

To ensure the new menu item for mwan3 appears, logout of your existing session and restart the service hosting the LuCI interface i.e. uhttpd or just reboot the router.

- Go to System &gt; Startup
  
  - click the “Restart” button next to the process running LuCI i.e. uhttpd, nginx etc.
  - Login into the web interface again.

A new menu entry “Network &gt; MultiWAN Manager” should now be present. In older versions of `luci-app-mwan3` this will be labelled as “Load Balancing”.

### Upgrading

If there is a newer version of mwan3 available, you can upgrade mwan3 through either opkg or LuCI.

```
opkg upgrade mwan3
```

Or through LuCI: **System** → **Software** → **Updates**

Your existing configuration will not be modified and instead if there any changes from the default, these will be able to be viewed in a `mwan3-opkg` file alongside your mwan3 configuration file in `/etc/config`. Occasionally there may be changes to the configuration options so it is a good idea to inspect the default configuration on upgrades to ensure your configuration has the latest changes in various sections.

### IPv6 support

Using mwan3 with load balancing or failover routing policies for IPv6 requires additional configuration such as NETMAP, NPTv6 or NAT66. None of these methods are currently implemented in mwan3 directly and hence requires additional configuration.

**Using IPv6 with mwan3:**

1. Newer versions of mwan3 have better IPv6 support, ensure you are running a supported OpenWrt version, as various IPv6 related areas have been addressed in recent versions.
2. You will need to split your WAN network interfaces, so one interface has your IPv4 WAN and another for the IPv6 WAN. A common example convention is wan and wan6 (default with OpenWrt), along with an additional WAN interfaces such as wanb and wanb6 etc. Your IPv6 interface can be an alias interface in most cases. You then define each interface in mwan3 with the address family of either `ipv4` or `ipv6` and create a member profile for each to be used in policies assigned to your rules so IPv4 and IPv6 traffic is handled. mwan3 cannot currently handle IPv4 and IPv6 configuration on a single interface.
3. You will likely need to implement some form of IPv6 masquerading such as NETMAP or NPTv6 or [NAT66](/docs/guide-user/network/ipv6/ipv6.nat6 "docs:guide-user:network:ipv6:ipv6.nat6") for mwan3 and IPv6 traffic to work properly across multiple WAN interfaces.

NETMAP, NPTv6 and NAT66 all are configuration options that can work with mwan3, but it is up to you to implement the IPv6 configuration required. mwan3 does not currently implement any IPv6 masquerading by itself.

The [default configuration that ships with mwan3](#default_configuration_example "docs:guide-user:network:wan:multiwan:mwan3 ↵") provides an example configuration of having two WAN interfaces with dual-stack connectivity (note that the second example interface is not enabled by default). This is a good template to start with if you wish to explore routing IPv6 with mwan3.

#### Disable mwan3 from routing IPv6 traffic

You can prevent mwan3 from routing IPv6 traffic by declaring `option family 'ipv4'` [on all rules](#rule_configuration "docs:guide-user:network:wan:multiwan:mwan3 ↵") and removing the default IPv6 rule. This will prevent any mwan3 IPv6 routing rules being created by mwan3. You should also add `option last_resort 'default'` on your policies to fall back to the main routing table to allow IPv6 traffic (if present). However, doing this means your IPv6 traffic cannot be balanced or fail over if not handled by mwan3.

## Pre-configuration

You will need a minimum of two WAN interfaces for mwan3 to work effectively. While mwan3 is primarily designed for physical and independent WAN connections it can also be used with logical interfaces like OpenVPN or Wireguard.

### Creating additional WAN interfaces

The simplest way to create more WAN interfaces is to have a VLAN-capable router. This will allow you to convert existing LAN ports into individual ports to become its own separate interface and act as a WAN.

Here is the general procedure using LuCI to create a new VLAN and assign a single port to it in order to create a second WAN interface.

#### Routers using swconfig

1. Go to **Network &gt; Switch**
2. Remove a single physical port from the default VLAN 1; this port will be the new physical WANB port
   
   1. Assign the port to a new VLAN number such as 3 and set the port to be untagged in this single new VLAN and off in all other VLANs (note this VLAN, as with all VLANs, should also include the built-in CPU port as a tagged member, so there are a total of two ports in the new VLAN)
   2. Reboot the router for the new VLAN interface to become active (e.g. eth0.3 for what will be the new WANB interface)
3. Go to Network &gt; Interfaces and add a new interface name for the new eth0.x adapter
   
   1. Name the new VLAN physical interface “wanb”
   2. Configure the new wanb interface IP details
   3. Assign the new wanb interface to the wan firewall zone

For routers that have more than one CPU, make sure to only tag one of the CPUs for any new VLAN created. One methodology for dual-CPU routers is that CPU1 will often be assigned to the built in WAN port, and you can tag CPU0 for any VLANs you wish to create.

#### Routers using Distributed Switch Architecture (DSA)

From 21.02 onwards most targets will use [DSA](/docs/techref/hardware/switch "docs:techref:hardware:switch") which is different and not compatible with the instructions for swconfig. You can find a [converting to DSA guide](/docs/guide-user/network/dsa/converting-to-dsa "docs:guide-user:network:dsa:converting-to-dsa") for additional guidance for switch/VLAN management for router targets using DSA.

1. Go to **Network &gt; Interfaces** and select the Devices tab. Click configure on the br-lan device.
   
   1. Remove a lan port from the switch bridge ports option by selecting the menu and unchecking a switch port such as “lan1”. This port will become it's own WAN port.
   2. Apply these changes to remove the selected LAN port from the LAN bridge.
2. While still on the Devices page, scroll down and click the “Add device configuration”
   
   1. For device type select “VLAN (802.1q)”
   2. For base device select the lan port e.g. lan1 which was removed from the LAN bridge earlier.
   3. Assign the desired VLAN ID for this device.
   4. Save the changes and apply.
3. Go to **Network &gt; Interfaces** and “Add new interface”
   
   1. Give the interface a name such as “wanb”
   2. Select whatever protocol is required for this interface DHCP, PPPoE etc. For device select the lan port you removed from br-lan earlier.
   3. Assign the new interface to the wan firewall zone
   4. Apply any remaining changes.

**Note for PPPoE WAN interfaces:** If you are using PPPoE for multiple ADSL lines from the same company or provider, you may need to use `option macaddr 'XX:XX:XX:XX:XX:XX'` to give each interface a unique MAC. A symptom of not doing is that the ISP will drop the connection on one line when another connects with the same (default) MAC.

#### The routable loopback (self) interface

**If you are using 19.07 or newer this part is not required**. Router initiated traffic can also be load-balanced or use failover correctly. A new service [mwan3rtmon](https://github.com/openwrt/packages/commits/master/net/mwan3/files/usr/sbin/mwan3rtmon?author=ptpt52 "https://github.com/openwrt/packages/commits/master/net/mwan3/files/usr/sbin/mwan3rtmon?author=ptpt52") was added by [Chen Minqiang](https://github.com/ptpt52 "https://github.com/ptpt52"). The service is responsible for syncing the main routing table with the interface routing tables. Also as inbound traffic has no dedicated firewall tables anymore. This is now working out of the box without any workarounds needed.

On routers with just one WAN interface (and one default route), there is no issue on which source address to use for new initiated sessions. But with two or more wWAN interfaces you may wish to have control over this. Up until version 2.0, mwan3 did not respect the already set source address of router originated packets. Packets were load-balanced regardless of source address, based on configured user rules.

As of version 2.0 mwan3 does respect the already set source address. The advantage of this is that an applications can have control over which WAN interface to use. The downside of this is that when an application does not specify which source address to use (most of the time) the kernel will pick a source address based on the routing table. In practice this means the default route with the lowest metric is used to determine which source address to use. So if you don't configure a routable loopback address with corresponding more preferred default route, all traffic originating from the router itself will leave the primary WAN with the source address of that wan interface, regardless of configured user mwan3 rules.

This however only effects router initiated traffic. **Traffic from LAN clients will always be balanced based on mwan3 configured rules even if no routable loopback address is configured**.

**Configuring a routable loopback (lede-17.01):**

Add the following interface to `/etc/config/network`.

```
config interface 'self'
	option ifname 'lo'
	option proto 'static'
	option ipaddr '192.168.1.1'
	option netmask '255.255.255.255'
	option gateway '192.168.1.1'
```

After this all traffic originating from router itself (if no more specific route is found) will have source address of 192.168.1.1 (before NAT).

Extra advantage is that configuring mwan3 rules for router only traffic is much easier.

**Configuring a routable loopback (openwrt-18.06):**

You have to add into “/etc/config/mwan3” the option “local\_source”. The value must be one of the interfaces in `/etc/config/network`. Normally this would be **lan**.

```
config globals 'globals'
	option local_source 'lan'
	option mmx_mask '0x3F00'
```

After this all traffic originating from router itself (if no more specific route is found) will have source address of the `lan` interface (before NAT).

The address will be configured to the loopback interface **lo** by netifd on the \*ifup/ifdown* hotplug script.

Extra advantage is that configuring mwan3 rules for router only traffic is much easier.

### Prepare and verify the default routing table for WAN interfaces

Before doing anything with mwan3 (installing or configuring), ensure that each WAN interface is working and that the default routing table is correctly configured for each WAN connection. Test each interface with a manual ping before installing mwan3! It is strongly recommended to do some pre-configuration and test your connectivity for each WAN interface prior to enabling mwan3, this will help with troubleshooting and ensure your WAN interfaces are correctly configured before using mwan3.

#### Configure a different metric for each WAN interface

Ensure that every WAN interface has a gateway IP and metric defined! This is very important as otherwise mwan3 will likely not work!

- You must configure each WAN interface with a **different** routing metric. This metric will only have an effect on the default routing table, not on the mwan3 routing tables.
- The default (primary) WAN interface should have the lowest metric (e.g. 10) and each additional WAN interface a higher metric (e.g. 20, 30, etc.). Values are not important, but should always be unique.
- Every WAN interface should have a **default gateway configured**.

**Note:** PPPoE connections only show the “Use gateway metric” option if “Use default gateway” option is enabled.

#### WAN setting

WAN is the default wan interface in this example, and so will get a metric of 10.

- Network &gt; Interfaces
  
  - WAN &gt; Edit
    
    - Advanced Settings
- Use default gateway: enabled
- Use gateway metric: 10
  
  - Save &amp; Apply

#### WANB setting

WANB is the second wan interface in this example, and so will get the a metric of 20.

- Network &gt; Interfaces
  
  - wanb &gt; Edit
    
    - Advanced Settings
- Use default gateway: enabled
- Use gateway metric: 20
  
  - Save &amp; Apply

#### Verify the routing table

If configured correctly, you should have a default gateway (the lines with a target address of 0.0.0.0/0) with a unique metric set for each WAN interface. For example:

```
# ip route show
default via 10.0.3.2 dev eth1  proto static  src 10.0.3.15  metric 10 
default via 10.0.4.2 dev eth2  proto static  src 10.0.4.15  metric 20
```

### Verify outbound traffic on each WAN interface

Check that each WAN interfaces works by trying to ping [www.google.com](http://www.google.com "http://www.google.com") out from each interface. Ensure all interfaces are correctly sending and receiving traffic before proceeding.

#### Test the WAN connection

- WAN is hardware interface eth0.1 in this example:

```
# ping -c 1 -I eth0.1 www.google.com
PING www.google.com (209.85.148.103): 56 data bytes
64 bytes from 209.85.148.103: seq=0 ttl=54 time=19.637 ms
 
--- www.google.com ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 19.637/19.637/19.637 ms
```

- Ensure the single ping is successful on this interface (“1 packets transmitted, 1 packets received, 0% packet loss” should be displayed)

#### Test the WANB connection

- WANB is hardware interface eth0.2 in this example:

```
# ping -c 1 -I eth0.2 www.google.com
PING www.google.com (209.85.148.99): 56 data bytes
64 bytes from 209.85.148.99: seq=0 ttl=56 time=25.552 ms
 
--- www.google.com ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 25.552/25.552/25.552 ms
```

- Ensure the single ping is successful on this interface (“1 packets transmitted, 1 packets received, 0% packet loss” should be displayed)

#### Test all other WAN connections

- Repeat as above to ensure every WAN connection that has been created is working

### Test external DNS/mail/etc. servers for access from each WAN interface

When implementing mwan3 you may experience issues with your ISPs DNS or email services depending your setup. This is due to many ISPs configuring their DNS/email servers to only allow source IP addresses within their network. Any attempts to use such services from “unknown” IP addresses will likely result in the traffic being dropped due to the source address not matching the ISP network.

##### ISP DNS resolvers

For DNS, you can either use [public open DNS resolvers](#reliable_public_ip_addresses_to_ping "docs:guide-user:network:wan:multiwan:mwan3 ↵") outside of your ISP network to avoid this problem, or alternatively implement a specific rule in mwan3 to make sure DNS traffic goes over the right WAN interface for such requests. An example rule in mwan3 could be:

```
config rule 'example_dns_wan'
	option dest_ip '194.168.4.100,194.168.8.100'
	option family 'ipv4'
	option use_policy 'wan_only'
```

Here I am using Virgin Media UK as the example ISP. Their DNS resolvers are *194.168.4.100* and *194.168.8.100*. Any request to these destination IPs are made to use the specific WAN interface this connection goes through, in order for the traffic to correctly traverse the right WAN. You could adapt this rule to be more specific with UDP and port 53, however for easy debugging, this would also work for traceroute, ping etc. The disadvantage to having such a rule however is this traffic can not be load balanced or failover, given a specific WAN policy has been set. Using public DNS resolvers would be the best solution to maintain this, unless you really need to have your ISPs DNS working for your configuration.

##### ISP mail servers

In a similar fashion to DNS. An ISP mail server will typically only accept POP3/IMAP/SMTP traffic from IP addresses within their network and block any attempt of sending mail from unknown IP addresses. You will have to ensure mail traffic goes through the right interface as well:

```
config rule 'example_mail_wan'
	option dest_ip '62.254.26.219'
	option family 'ipv4'
	option use_policy 'wan_only'
```

This is the IP of *smtp.virginmedia.com*, you may need to add more IP addresses in order to cover IMAP, POP3 and other SMTP servers if used. You could also add use the `proto` and `dest_port` on rules to limit it to mail related ports.

## mwan3 configuration

The mwan3 configuration consists of five main sections:

- Globals - Global settings that apply to mwan3 overall.
- Interfaces - Network interfaces to be used/tracked by mwan3, the interfaces configured in mwan3 need to match what is set in `/etc/config/network`.
- Members - For a network interface to be used in mwan3, it must be defined as a member, which can then be used in policies.
- Policies - How the traffic should be routed according to the metric value and weight set in the member configuration. This allows you to define configurations like load balancing/failover or forcing traffic through a specific WAN.
- Rules - Defining one or more specific routing rules according to the defined policy set. A variety of rules can be configured using source/destination IP/port, domain names (using ipset) and more.

### Globals configuration

The globals configuration provides the following options.

Name Type Required Default Description `mmx_mask` string yes `0x3F00` Firewall mask value `logging` boolean no `0` Global firewall logging. This must be enabled for any rule specific logging to occur. `loglevel` `emerg`  
`alert`  
`crit`  
`error`  
`warning`  
`notice`  
`info`  
`debug` No `notice` Firewall loglevel `rtmon_interval` number No `5` How often should mwan3rtmon update the interface routing table (in seconds)  
![:!:](/lib/images/smileys/exclaim.svg) **Deprecated since v2.9.0** `rt_table_lookup` number No *(none)* Specify an additional routing table to be scanned for connected networks

Since version 2.9.0 `rtmon_interval` has been deprecated and will no longer have any effect in configurations. The way routing table changes are monitored was refactored and no longer requires an interval being set.

### Interface configuration

For each WAN interface configure an interface section and define how each WAN interface is tested for up/down status. Each interface section must have a name that corresponds with the interface name in your network config. The settings are described below.

Name Type Required Default Description Interface name string yes *(none)* The OpenWrt interface name as defined in `/etc/config/network`. Do not use interface names like `pppoe-wanX` `track_method` `ping`  
`arping`  
`httping`  
`nping-tcp`  
`nping-udp`  
`nping-icmp`  
`nping-arp` no `ping` Tracking method for mwan3track `enabled` boolean no `0` Should mwan3 run on/track this interface? `track_ip` list of ip addresses no *(none)* The host(s) to test if interface is still alive. If this value is missing the interface is always considered up `flush_conntrack` list no *(none)* Flush global firewall conntrack table on interface events. See [alerts/notifications](#alertsnotifications "docs:guide-user:network:wan:multiwan:mwan3 ↵") for a list of interface events `reliability` number no `1` Number of track\_ip hosts that must reply for the test to be considered as successful. Ensure there are at least this many `track_ip` hosts defined or the interface will always be considered down `count` number no `1` Number of checks to send to each host with each test `timeout` seconds no `4` Number of seconds to wait for an echo-reply after an echo-request `interval` seconds no `10` Number of seconds between each test `failure_interval` seconds no `<interval>` Number of seconds between each test during teardown on failure detection `recovery_interval` seconds no `<interval>` Number of seconds between each test during tearup on recovery detection `keep_failure_interval` boolean no `0` In the event of an error, keep the number of seconds between each test during teardown (failure detection) `check_quality` boolean no `0` In addition to the interface being up, the `check_quality` options can check the overall link quality with packet loss and/or latency measurements `failure_latency` number no `1000` Maximum packet latency milliseconds when `check_quality` is enabled `recovery_latency` number no `500` Minimum packet latency in milliseconds when `check_quality` is enabled `failure_loss` number no `40` Maximum packet loss as a percentage when `check_quality` is enabled `recovery_loss` number no `10` Minimum packet loss as a percentage when `check_quality` is enabled `initial_state` `online`  
`offline` no `online` If the value is **offline**, then traffic goes via this interface only if mwan3track checked the connection first. If the value is **online**, then the mwan3track test is not waited for and the interface is marked as online immediately. `family` `ipv4`  
`ipv6` no `ipv4` The specific protocol family this interface handles `max_ttl` number no `60` Time to live (TTL) or hop limit. Only valid if `track_method` is ping `size` number no `56` Size of ping packets to use in bytes. Only valid if `track_method` is ping `up` number no `5` Number of successful tests to considered link as alive `down` number no `5` Number of failed tests to considered link as dead

In most cases the default values should work for most configurations. The primary reason to change the default settings is to shorten the time before an interface is failed-over (by reducing the ping interval and number of pings before the interface is down) or lengthen the time to avoid a false link failure report. Please note that if you change the timeout value on low bandwidth interfaces (e.g. 3G) or busy interfaces, that false positives of marking a WAN down can occur. A timeout value of less then 2 seconds is not recommended.

A typical interface section using the default tracking method of ping looks like this, mostly using the default values of all options described above:

```
config interface 'wan'
	option enabled '1'
	list track_ip '1.0.0.1'
	list track_ip '1.1.1.1'
	list track_ip '208.67.222.222'
	list track_ip '208.67.220.220'
	option family 'ipv4'
```

#### Reliable public IP addresses to ping

Below are a collection of public IPv4 and IPv6 endpoints that accept ICMP and can be used with mwan3track for tracking the connection state of interfaces if using the ping tracking method. These are [public DNS resolvers](https://en.wikipedia.org/wiki/Public_recursive_name_server "https://en.wikipedia.org/wiki/Public_recursive_name_server") with high availability and generally reliable to use as endpoints to confirm network connectivity. Alternatively you can also use your ISPs DNS resolvers, but these are often limited to [source networks originating from the ISP](#test_external_dnsmailetc_servers_for_access_from_each_wan_interface "docs:guide-user:network:wan:multiwan:mwan3 ↵") and on average can be less reliable.

**Note:** Some public DNS services may not respond to ICMP requests or intermittently drop requests due to throttling or rate limiting. This has been seen with Google public DNS, but can occur with any provider depending on their policy. You may see mwan3track ping failures due to this behaviour. To avoid this scenario marking an interface as down, ensure you have multiple `track_ip` options configured across different providers and that the `reliability` setting is set to a value to tolerate occasional failures without triggering the WAN interface to be marked as down.

DNS service IPv4 resolvers IPv6 resolvers Level 3 communications 209.244.0.3  
209.244.0.4  
4.2.2.1  
4.2.2.2  
4.2.2.3  
4.2.2.4  
4.2.2.5  
4.2.2.6 Google DNS 8.8.4.4  
8.8.8.8 2001:4860:4860::8844  
2001:4860:4860::8888 Facebook 173.252.120.6 OpenDNS 208.67.220.220  
208.67.222.222 2620:0:ccc::2  
2620:0:ccd::2 Cloudflare 1.1.1.1  
1.0.0.1 2606:4700:4700::1111  
2606:4700:4700::1001 Hurricane Electric (HE.net) 74.82.42.42 2001:470:20::2 Quad9 9.9.9.9  
149.112.112.112 2620:fe::fe  
2620:fe::9

#### Flushing conntrack

In some cases you may need to have the global firewall conntrack table flushed on interface events such as `ifup` for traffic to correctly flow with mwan3 enabled. This can be achieved by adding the following option to your interface configuration.

```
config interface 'wan'
    option enabled '1'
    ...
    list flush_conntrack 'ifup'
```

This will trigger the conntrack table to be flushed on the `ifup` event.

It has been observed that in some cases inbound traffic can end up being routed over the wrong WAN interface. [One example is inbound ICMP](https://github.com/openwrt/packages/issues/13909 "https://github.com/openwrt/packages/issues/13909"), but it is likely it can occur with other protocols and traffic that is inbound. If you are having problems with ICMP or port forwarding you might want to use tcpdump to inspect the traffic and investigate if this the case i.e. traffic is received but replied to over the wrong interface. As a test, you can quickly flush conntrack outside of mwan3 with `conntrack -F`, if this resolves the issue, configure mwan3 to flush conntrack on an `ifup` event as above automatically to avoid this problem.

### Member configuration

Each member represents an interface with a metric and a weight value. Members are referenced in policies to define a pool of interfaces with corresponding metric and load-balancing weight. Members can't be used for rules directly. The default settings are described below:

Name Type Required Default Description Member name string yes *(none)* The name of this member configuration, which is then referenced in policies `interface` string yes *(none)* Member applies to this interface (use the same interface name as used in the mwan3 interface section, above) `metric` number no `1` Members within one policy with a lower metric have precedence over higher metric members `weight` number no `1` Members with same metric will distribute load based on this weight value

A typical member section looks like this:

```
config member 'wan_m1_w3'
	option interface 'wan'
	option metric '1'
	option weight '3'
```

- A working mwan3 config has at least 2 members configured.

### Policy configuration

Policies define how traffic is routed through the different WAN interface(s). Every policy has to have one or more members assigned to it, which defines the policy's traffic behaviour. If a policy has a single member, traffic will only go out that member. If a policy has more than one member, it will either load-balance among members or use one member but fail-over to another, depending on how the members are configured.

If there is more than one member assigned to a policy, members within the policy with a lower metric have precedence over higher metric members. Members with the same metric will load-balance. Load-balancing members (with same metric) will distribute load based on assigned weights values.

**Key points about policies:**

- Policies are profiles grouping one or more members controlling how MWAN distributes traffic
- Member interfaces with lower metrics are used first
- Member interfaces with the same metric will be load-balanced
- Load-balanced member interfaces distribute more traffic out those with higher weights
- Names may contain characters A-Z, a-z, 0-9, _ and no spaces
- Names **must be 15 characters or less**
- Policies may not share the same name as configured interfaces, members or rules

Name Type Required Default Description Policy name string yes *(none)* Unique name for the policy.  
![:!:](/lib/images/smileys/exclaim.svg) **Must be no more than 15 characters** Members assigned string yes *(none)* One or more [members assigned to this policy](#member_configuration "docs:guide-user:network:wan:multiwan:mwan3 ↵") `last_resort` `unreachable` (reject)  
`blackhole` (drop)  
`default` (use main routing table) no `unreachable` Determine the fallback routing behaviour if all WAN members in the policy are down

A typical policy section looks like this:

```
config policy 'balanced'
	list use_member 'wan_m1_w3'
	list use_member 'wanb_m1_w3'
	list use_member 'wan6_m1_w3'
	list use_member 'wanb6_m1_w3'
	option last_resort 'unreachable'
```

- If a policy is not referenced by a specific traffic rule, the policy will not do anything, so it is fine to leave unused policies in place in case they are desired in the future.
- If you have a traffic rule that matches a policy, but all the members (interfaces) for that policy are down, the exit strategy for that policy defaults to `unreachable`.
- A working mwan3 config has at least 1 policy configured.

### Rule configuration

A rule describes what traffic to match and what policy to assign for that traffic.

**Key points about rules:**

- Rules specify which traffic will use a particular policy.
- Rules are based on IP address, port or protocol.
- Rules are matched from top to bottom.
- Rules below a matching rule are ignored.
- Traffic not matching any defined rule will be routed using the main routing table.
- Traffic destined for known (other than default) networks is handled by the main routing table.
- Traffic matching a rule where all interfaces for that policy are down will be blackholed.
- Rule names may contain characters A-Z, a-z, 0-9, _ and no spaces.
- Rules may not share the same name as configured interfaces, members or policies.

Name Type Required Default Description Rule name string yes *(none)* The unique name of the rule.  
![:!:](/lib/images/smileys/exclaim.svg) **Must be no more than 15 characters** `use_policy` string yes *(none)* Use this policy for traffic that matches or set to `default` to use the default routing table to lookup `src_ip` IP address no *any* Match traffic from the specified source IP address `src_port` port or range no *any* Match traffic from the specified source port or port range, if relevant `proto` is specified `proto` `tcp`  
`udp`  
`icmp`  
`all` no `all` Match traffic using the given protocol. `dest_ip` IP address no *any* Match traffic directed to the specified destination IP address `dest_port` port or range no *any* Match traffic directed at the given destination port or port range, if relevant `proto` is specified `ipset` string no *(none)* Match traffic directed at the given destination IP address to an ipset set `sticky` boolean no `0` Allow traffic from the same source IP address within the timeout limit to use same wan interface as prior session `timeout` number no `600` Stickiness timeout value in seconds `family` `ipv4`  
`ipv6`  
`any` no `any` Address family for which to apply the rule. `logging` boolean no `0` Enables firewall rule logging (global mwan3 logging setting must also be enabled)

The default configuration provides three standard rules, a https sticky rule for both IPv4 and IPv6 and two default rules (one for IPv4 and one for IPv6) to match any other traffic which would not have been matched by any preceding rules. You can add your rules above these or modify them as needed.

A typical rule section looks like this:

```
config rule 'default_rule_v4'
	option dest_ip '0.0.0.0/0'
	option family 'ipv4'
	option use_policy 'wan_wanb'
```

It is also possible to group multiple ports or source/destination IP addresses under a single rule using a comma.

```
config rule 'multi_ip_rule'
       option dest_ip '1.1.1.1,2.2.2.2,3.3.3.3,4.4.4.4'
       option family 'ipv4'
       option use_policy 'wan_only'
```

*The comma will be translated by `iptables` and correctly create the required entries from a single rule.*

For rules that require a large amount of destination IP addresses, it is recommended to use ipset as this more optimised to group large amounts of IP addresses, or CIDR ranges.

#### Sticky support

Sticky (or sticky sessions) can be enabled on a per-rule basis and lets you route a new session over the same WAN interface as the previous session, as long as the time between the new and the previous session is shorter then the specified timeout value. This is mainly useful for load balanced routing and can solve some problems with HTTPS sites which don't allow a new source address within the same cookie/HTTPS session.

By default mwan3 treats all https traffic with a sticky rule.

```
config rule 'https'
    option sticky '1'
    option dest_port '443'
    option proto 'tcp'
    option use_policy 'balanced'
```

With sticky set to 1, this rule now uses sticky sessions. When a packet for a new session matches this rule, its source IP address and interface mark are stored in an ipmark. When a packet for a second new session from the same LAN host within the timeout period matches this rule, it will use the same WAN interface as the first packet and the timeout counter is reset back to specified timeout value. The default timeout value is 600 seconds.

#### ipset support

ipset functionality is broken in 23.05 due to the `dnsmasq-full` package no longer being compiled with ipset support in favour of nftables. As mwan3 does not currently support nftables natively, this functionality no longer works. [More information and further discussion](https://forum.openwrt.org/t/23-05-dnsmasq-ipsets-and-mwan3-incompatibility/174926 "https://forum.openwrt.org/t/23-05-dnsmasq-ipsets-and-mwan3-incompatibility/174926"). A [workaround init script that converts nfset to ipset is available](/docs/guide-user/network/wan/multiwan/mwan3#nft2ipset_init_script "docs:guide-user:network:wan:multiwan:mwan3") to use until mwan3 is updated to natively support nfset.

ipset is designed to store multiple IP addresses in a single collection, while being performant and easier to maintain. Common usages of ipset include storing large amounts of IP addresses or ranges in a single set as well as conditional routing by domain. As routing ultimately works at the IP layer, being able to use ipset with domain based policies is useful for many websites or services which use multiple IP addresses or large Content Delivery Networks which means the IP address of that domain is constantly changing, individually adding these IP addresses would become unmanageable very quickly, ipset can help maintain this for you.

A set can be populated manually, by a DNS resolver (triggered by a DNS lookup), or your own script. Rules enabled with ipset option will check for the existence of the destination address in the ipset chain defined in the rule to determine what routing needs to take place. If the destination address is found, the packet will be routed according to the policy, otherwise the ipset policy will not apply.

```
config rule 'youtube'
    option ipset 'youtube'
    option sticky '1'
    option dest_port '80,443'
    option proto 'tcp'
    option use_policy 'balanced'
```

**Tip:** ipset rules also support sticky sessions.

The example creates an ipset rule for a collection called youtube, with an additional rule of only matching destination ports TCP 80/443 i.e. HTTP/HTTPS. If the ipset chain does not already exist, mwan3 will create the ipset set for you. However to ensure all network conditions are met, you should ensure ipset collections are created on router startup.

For having ipset collections automatically populated on DNS lookups matching the domain required, you will need to add an ipset configuration to your DNS resolver, two common DNS resolvers dnsmasq (default in OpenWrt) or Adguard Home.

**dnsmasq:**

**Note:** dnsmasq-full is required for ipset functionality.

```
config dnsmasq
    ....
    list ipset '/youtube.com/youtube'
```

Or add directly to `/etc/dnsmasq.conf`

```
ipset=/youtube.com/youtube
```

Add more domains by separating each domain with a `/` character.

**AdGuard Home:**

Add to `/etc/adguardhome.yaml`.

```
dns:
 ipset:
 - youtube.com/youtube
...
```

Add more domains by separating each domain with a `,` character.

Restart your DNS resolver and make a DNS lookup for the domain in the ipset. To check the contents of an ipset collection you can run the command:

```
ipset -L youtube
```

If all is working correctly, you should see the resolved IP address or addresses in the ipset collection.

Be aware if the domain has been recently resolved by your DNS resolver, it may return a cache response which may not hit the ipset collection, clear the DNS cache and confirm your lookup is not a cached result.

### Default configuration example

This is a copy of the example configuration that is provided in the mwan3 package. By default only a single WAN interface is enabled, but it provides the necessary configuration for having two WAN interfaces that have both IPv4 and IPv6 connectivity. You can adapt this configuration to your specific needs.

[/etc/config/mwan3](/_export/code/docs/guide-user/network/wan/multiwan/mwan3?codeblock=24 "Download Snippet")

```
config globals 'globals'
	option mmx_mask '0x3F00'
 
config interface 'wan'
	option enabled '1'
	list track_ip '1.0.0.1'
	list track_ip '1.1.1.1'
	list track_ip '208.67.222.222'
	list track_ip '208.67.220.220'
	option family 'ipv4'
	option reliability '2'
 
config interface 'wan6'
	option enabled '0'
	list track_ip '2606:4700:4700::1001'
	list track_ip '2606:4700:4700::1111'
	list track_ip '2620:0:ccd::2'
	list track_ip '2620:0:ccc::2'
	option family 'ipv6'
	option reliability '2'
 
config interface 'wanb'
	option enabled '0'
	list track_ip '1.0.0.1'
	list track_ip '1.1.1.1'
	list track_ip '208.67.222.222'
	list track_ip '208.67.220.220'
	option family 'ipv4'
	option reliability '1'
 
config interface 'wanb6'
	option enabled '0'
	list track_ip '2606:4700:4700::1001'
	list track_ip '2606:4700:4700::1111'
	list track_ip '2620:0:ccd::2'
	list track_ip '2620:0:ccc::2'
	option family 'ipv6'
	option reliability '1'
 
config member 'wan_m1_w3'
	option interface 'wan'
	option metric '1'
	option weight '3'
 
config member 'wan_m2_w3'
	option interface 'wan'
	option metric '2'
	option weight '3'
 
config member 'wanb_m1_w2'
	option interface 'wanb'
	option metric '1'
	option weight '2'
 
config member 'wanb_m1_w3'
	option interface 'wanb'
	option metric '1'
	option weight '3'
 
config member 'wanb_m2_w2'
	option interface 'wanb'
	option metric '2'
	option weight '2'
 
config member 'wan6_m1_w3'
	option interface 'wan6'
	option metric '1'
	option weight '3'
 
config member 'wan6_m2_w3'
	option interface 'wan6'
	option metric '2'
	option weight '3'
 
config member 'wanb6_m1_w2'
	option interface 'wanb6'
	option metric '1'
	option weight '2'
 
config member 'wanb6_m1_w3'
	option interface 'wanb6'
	option metric '1'
	option weight '3'
 
config member 'wanb6_m2_w2'
	option interface 'wanb6'
	option metric '2'
	option weight '2'
 
config policy 'wan_only'
	list use_member 'wan_m1_w3'
	list use_member 'wan6_m1_w3'
 
config policy 'wanb_only'
	list use_member 'wanb_m1_w2'
	list use_member 'wanb6_m1_w2'
 
config policy 'balanced'
	list use_member 'wan_m1_w3'
	list use_member 'wanb_m1_w3'
	list use_member 'wan6_m1_w3'
	list use_member 'wanb6_m1_w3'
 
config policy 'wan_wanb'
	list use_member 'wan_m1_w3'
	list use_member 'wanb_m2_w2'
	list use_member 'wan6_m1_w3'
	list use_member 'wanb6_m2_w2'
 
config policy 'wanb_wan'
	list use_member 'wan_m2_w3'
	list use_member 'wanb_m1_w2'
	list use_member 'wan6_m2_w3'
	list use_member 'wanb6_m1_w2'
 
config rule 'https'
	option sticky '1'
	option dest_port '443'
	option proto 'tcp'
	option use_policy 'balanced'
 
config rule 'default_rule_v4'
	option dest_ip '0.0.0.0/0'
	option use_policy 'balanced'
	option family 'ipv4'
 
config rule 'default_rule_v6'
	option dest_ip '::/0'
	option use_policy 'balanced'
	option family 'ipv6'
```

## Testing/verification

Once mwan3 has been configured and is enabled you will want to verify that mwan3 is working and correctly routing traffic according to your policies and rules.

### Interface status

- Status &gt; MultiWAN Manager
  
  - Overview
    
    - MWAN3 Multi-WAN Interface Live Status
- this area should show all WAN interfaces as “ONLINE”
  
  - MWAN3 Multi-WAN Interface System log
- this area will show recent mwan3 log messages

**Note:** Older versions of mwan3 will use the label “Load Balancing” in LuCI.

### Routing tables

- `ip route show table x` (where x is interface ID) should show a routing table specifically for that interface -- these tables are generated by mwan3.

### Verification of WAN interface load balancing

- Go to Network &gt; Interfaces
  
  - Send traffic from a test inside PC
    
    - **Note: Load-balancing is connection-based (not channel bonding), so use multiple programs accessing different servers to generate traffic (such as two downloads, each from a separate site)**
  - Observe the interface packet counts (counters are updated automatically)
  - Verify that traffic is going out all expected WAN interfaces

### Verification of WAN interface failover

- Go to Network &gt; Load Balancing &gt; Overview
  
  - Manually disconnect a WAN connection
  - Wait for interface failure detection to happen -- the mwan3 status display should update

<!--THE END-->

- Go to Network &gt; Interfaces
  
  - Send traffic from a test inside PC and observe the interface packet counts to ensure traffic is now going out the alternate WAN port (counters are updated automatically)
  - Check that the external IP address has changed to the wanb interface (such as by going to [http://whatismyip.com](http://whatismyip.com "http://whatismyip.com"))

#### Test WAN interface recovery

- Restore the primary WAN connection
- Wait for detection that the WAN link is back up
- Repeat the same tests as above to ensure traffic has moved back to the now-working WAN interface

## Administration

### Command line (CLI)

There are various CLI commands to help you troubleshoot or show the current mwan3 configuration:

```
# mwan3
Syntax: mwan3 [command]

Available commands:
        start              Load iptables rules, ip rules and ip routes
        stop               Unload iptables rules, ip rules and ip routes
        restart            Reload iptables rules, ip rules and ip routes
        ifup <iface>       Load rules and routes for specific interface
        ifdown <iface>     Unload rules and routes for specific interface
        interfaces         Show interfaces status
        policies           Show currently active policy
        connected          Show directly connected networks
        rules              Show active rules
        status             Show all status
        use <iface> <cmd>  Run a command bound to <iface> and avoid mwan3 rules
```

**Changes in version 2.10.0:**

`mwan3 use` was added in version 2.10. This additional option is designed to allow you test network commands like `ping`, `iperf3` etc by binding the command to a specific interface reliably. A common side effect with mwan3 is it can skew the output of commands that rely on binding to specific interfaces, as traffic will be routed according to the rules defined in `/etc/config/mwan3` and essentially override the desired scenario in some cases.

```
mwan3 use <IFACE> <COMMAND>
```

**Ping using the primary WAN interface:**

```
mwan3 use wan ping -4 google.co.uk
```

**iperf3 using the secondary WAN interface:**

```
mwan3 use wanb iperf3 -4 -c speed.nimag.net -R
```

**Changes in version 2.8.11:**

```
# mwan3 interfaces
Interface status:
 interface wan is online 50h:39m:26s, uptime 345h:27m:03s and tracking is active
 interface wan6 is online 50h:39m:27s, uptime 345h:26m:05s and tracking is active
 interface wanb is online 50h:39m:26s, uptime 256h:12m:17s and tracking is active
 interface wanb6 is online 50h:39m:28s, uptime 256h:12m:14s and tracking is active
```

In version 2.8.11 and above the `mwan3 interfaces` command shows the online time and the overall interface uptime. This is not shown on older versions.

The key command will be `mwan3 status` which will show the overall status of interfaces, policies, rules and connected networks

```
# mwan3 status
Interface status:
 interface wan is online 00h:00m:54s, uptime 71h:53m:14s and tracking is active
 interface wan6 is online 00h:00m:54s, uptime 71h:51m:35s and tracking is active
 interface wanb is online 00h:00m:54s, uptime 71h:53m:15s and tracking is active
 interface wanb6 is online 00h:00m:54s, uptime 71h:53m:11s and tracking is active
 
Current ipv4 policies:
wan_only:
 wan (100%)
wan_wanb:
 wan (100%)
wanb_only:
 wanb (100%)
wanb_wan:
 wanb (100%)
 
Current ipv6 policies:
wan_only:
 wan6 (100%)
wan_wanb:
 wan6 (100%)
wanb_only:
 wanb6 (100%)
wanb_wan:
 wanb6 (100%)
 
Directly connected ipv4 networks:
192.168.1.0/24
192.168.225.0/24
192.168.100.0/24
192.168.2.0/24
172.16.0.0/12
224.0.0.0/3
127.0.0.0/8
192.168.0.0/16
10.0.0.0/8
192.168.10.0/24
 
Directly connected ipv6 networks:
fd77:550d:5fb8::/64
fd77:550d:5fb8:10::/64
fc00:bbbb:bbbb:bb01::3:d260
fe80::/64
fc00:bbbb:bbbb:bb01::1:611c
 
Active ipv4 user rules:
   11   851 S https  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            multiport dports 443 
   72 12381 - wan_wanb  all  --  *      *       0.0.0.0/0            0.0.0.0/0            
 
Active ipv6 user rules:
   14  1120 S https  tcp      *      *       ::/0                 ::/0                 multiport dports 443 
    2   184 - wan_wanb  all      *      *       ::/0                 ::/0     
```

### LuCI (Web interface)

`luci-app-mwan3` provides a LuCI front end to mwan3 functionality. It will add additional options within the Status and Network top menus:

- Status &gt; MultiWAN Manager
- Network &gt; MultiWAN Manager

In previous versions of `luci-app-mwan3` the label in the status and network section was “Load balancing”. This was changed to be more representative of the functionality mwan3 offers.

- The status section is designed to show the same information from mwan3 using CLI directly in LuCI with diagnostics and troubleshooting information.
- The network section allows for editing the mwan3 configuration through LuCI, being able change any part of the config file.

**Note:** The `luci-app-mwan3` interface currently lacks a lot of IPv6 awareness for interface configurations and will typically show warnings about no default route being present. This is most likely false, due to the LuCI package not being IPv6 aware. In addition diagnostics information is also mainly limited to IPv4 only at present.

## Alerts/notifications

mwan3 includes in a `/etc/mwan3.user` file in OpenWrt version 18.06 and above which is interpreted as a shell script. Here you can extend mwan3 to perform additional actions or notifications on certain hotplug events for one or more interfaces which mwan3 is tracking. e.g. When an interface goes down or up.

This file provides the following environment variables for use with additional custom logic requirements.

### Environment variables

Variable name Definition `$ACTION` Hotplug events mwan3 uses. Which are `ifdown`, `ifup`, `connected`, `disconnected` `$INTERFACE` Name of the interface which an hotplug event relates to (e.g. `wan` or `wwan`) `$DEVICE` Physical device name which an hotplug event relates to (e.g. `eth0` or `wwan0`)

The `/etc/mwan3.user` file in some cases will also be able to target [additional iface hotplug events](/docs/guide-user/base-system/hotplug "docs:guide-user:base-system:hotplug") that mwan3 doesn't directly use but netifd does e.g. ifupdate. While these events are not directly used by mwan3track, they are still available to hook into in this script.

**Note:** `$DEVICE` is not populated on an `ifdown` event, use `$INTERFACE` instead for this event.

There are various use cases for the `/etc/mwan3.user` file. One might be implementing custom notifications when an interface state changes i.e. email notifications. Be mindful when implementing something like notifications without limiting what `$ACTION` you wish to target you will have multiple notifications per interface when the state changes. This will further increase for each interface you have configured with mwan3track. You can use conditional statements to limit your custom logic only applying to certain events, below are a couple of examples of demonstrating this.

#### Example 1: Target ifup event on the wan interface

```
if [ "${ACTION}" = "ifup" ] && [ "${INTERFACE}" = "wan" ] ; then
   # Do something on an ifup event for the wan interface only
fi
```

#### Example 2: Target any ifup and ifdown events excluding certain interfaces

```
if [ "${ACTION}" = "ifdown" ] || [ "${ACTION}" = "ifup" ] ; then
 # Only on either an ifdown or ifup event for any interface
 if [ "${INTERFACE}" != "loopback" ] && [ "${INTERFACE}" != "self" ] ; then
 # Exclude events for interfaces loopback and self
   (/bin/sleep 180; /usr/bin/mailsend -to alerts@example.com -from alerts@example.com -ssl -port 465 -auth \
   -smtp mail.example.com -sub "$HOSTNAME $ACTION $INTERFACE $DEVICE" +cc +bc -user "alerts@example.com" \
   -pass "user_password" -cs "us-ascii" -enc-type "7bit" -M "mwan3: $ACTION $INTERFACE $DEVICE" >/dev/null) &
 fi
fi
```

Some notes about the last example:

- The “sleep 180” statement, a somewhat artificial delay, is required in cases when /etc/mwan3.user gets executed before connectivity is completely “settled” (for instance: ifup of the first active wan interface)
- mailsend with SSL support was chosen as mail client, for other options and SMTP clients: [smtp.client](/docs/guide-user/services/email/smtp.client "docs:guide-user:services:email:smtp.client")
- Finally observe that the whole sleep/mailsend statement is parenthesis enclosed and ended with and &amp; (ampersand) sending its execution to background so that /etc/mwan3.user finishes in a timely manner

## Controlling the mapping between internal IP sources and external IPs and interfaces

When using multiple WAN connections, there will be multiple external IPs which can be used as the external IP for outgoing NATed traffic. In particular, an external interface might have a block of external IPs that should be mapped in a particular way to specified internal servers. For example, the internal mail server should send out traffic on the same external IP identified in its MX record. This is the procedure to do this.

### Step 1: Set mwan3 rules to send traffic out the right interface

Add an mwan3 traffic rule that directs the specific desired source IP out the correct WAN interface. Rules are processed in top-down order, so be sure this specific rule is higher in the list (thus higher priority) than more general rules below that implement load-balancing or failover in the default case.

- Define a mwan3 interface member setting for the desired external interface (called “wanb” in the example below)
- Create a mwan3 policy that only sends traffic out the external interface that has the desired external IP

```
config policy 'wanb_only'
	list use_member 'wanb_m1_w2'
	list use_member 'wanb6_m1_w2'
```

- Create a mwan3 rule to have traffic from the internal IP 172.16.1.20 always go out the interface named wanb using the policy “wanb\_only”

```
config rule 'mailserver_uses_wanb_only'
	option src_ip '172.16.1.20'
	option family 'ipv4'
	option use_policy 'wanb_only'
```

If the external WAN interface only has a single external IP, this is all that is needed. If the interface has multiple external IPs, both the next two steps are also needed.

### Step 2: Assign multiple external IP addresses selected interface (optional)

- References
  
  - 12.09: see [https://dev.openwrt.org/ticket/12379](https://dev.openwrt.org/ticket/12379 "https://dev.openwrt.org/ticket/12379")

This step is only needed if the desired external interface needs to have multiple external IP addresses assigned to it.

The specified external interface may have multiple IPs assigned to it. For OpenWrt 12.09, the preferred way to do this is using multiple interface definitions -- see reference.

- Network &gt; Interfaces &gt; Add new interface...
  
  - Create Interface
    
    - Name of the new interface: e.g. “wan3\_2”, “wan3\_3”, ...
    - Protocol of the new interface: Static address
    - Create a bridge over multiple interfaces: do not enable
    - Cover the following interface: select the physical interface that will have this (additional) IP address, e.g. eth0.2
  - Submit

<!--THE END-->

- Network &gt; Interfaces &gt; Interfaces - (new interface name)
  
  - Common Configuration &gt; General Setup
    
    - Protocol: Static address
    - IPv4 address: (enter the desired additional external IP)
    - IPv4 netmask: select or enter the correct netmask
    - IPv4 gateway: (leave blank as the already defined default gateway will be used)
    - IPv4 broadcast: (leave blank to auto-set this)
    - Use custom DNS servers: (leave blank as DNS servers should be set through the WAN interface settings)
  - Common Configuration &gt; Firewall Settings
    
    - Create / Assign firewall-zone: select the desired firewall zone, usually “wan” for an additional external IP
  - Save &amp; Apply

### Step 3: Set OpenWrt NAT rules to send traffic out the right IP on the selected interface (optional)

This step is only needed if the desired external interface has multiple external IP addresses assigned to it.

With multiple external IP addresses, we want to control which address is used when sending out traffic from particular servers. This is configured using a source NAT rule in OpenWrt.

Note that *both* a mwan3 rule to select the interface and an SNAT rule to select the specific IP on that interface are needed to correctly send traffic out a specific external IP.

- Network &gt; Firewall &gt; Traffic Rules
  
  - Source NAT
    
    - add a source NAT rule and edit details to specify the desired inside source IP and the desired external IP -- the following code block is an example of the resulting configuration in /etc/config/firewall

```
config redirect
	option target 'SNAT'
	option name 'Mail server goes out 170.53.100.25'
	option src 'lan'
	option dest 'wan'
	option src_ip '172.16.1.20'
	option src_dip '170.53.100.25'
	option proto 'all'
```

## mwan3 and other programs

### ddns-scripts

- Related pages:
  
  - [client](/docs/guide-user/services/ddns/client "docs:guide-user:services:ddns:client")

#### Example 1: Register the external IP of the active WAN interface

This is the case where you want external clients using a DDNS name to automatically reconnect to the alternate WAN interface if the primary WAN interface fails.

- Configure ddns-scripts to use the “web” update mechanism as this will reflect the current active external IP

#### Example 2: Register the external IP of a specific WAN interface using the "interface" source

This is the case where you want each specific WAN interface to register its own DDNS name and the WAN interface in question has an external IP directly assigned to it.

- Configure ddns-scripts to use the “interface” source and specify the desired WAN physical interface name (e.g. eth0.50)

#### Example 3: Register the external IP of a specific WAN interface using the "web" source

This is the case where you want each specific WAN interface to register its own DDNS name but the WAN interface in question is behind a NAT device and so does not directly have the correct external IP.

This is tricky when the WAN interface is not the default WAN interface, as ddns-scripts cannot be configured to use a specific interface to check its IP.

##### Option 1: use a static route

- Looking up the dyndns.org checkip.dyndns.org hostname shows there are four valid IPs for this DNS name
- Choose one of them and create a static route to that specific IP through the desired (non-default) WAN interface
  
  - Do a traceroute to the IP to verify traffic is going out the desired WAN interface
- Change the ddns-scripts ip\_url to be this specific IP, e.g. `http://91.198.22.70/`
- Ensure any other web update ddns-scripts configurations don't use the hostname checkip.dyndns.org, as this may be forced out the specified WAN interface using the static route without realizing

##### Option 2: use curl

- ddns-scripts has the option of using curl instead of wget to check a web site to retrieve an IP address
- curl has an option (--interface) to force it to use a specified interface
- This involves installing curl and configuring ddns-scripts specifying which interface curl must use
- Tested on OpenWRT/Lede 17.01.7, should work on newer releases, perhaps in earlier versions too, relevant configuration below.

```
      /etc/config/ddns
              config ddns 'global'
                      option use_curl '1'
                      ... (other options)
              config service 'mwan3ddns'
                      option interface 'wanb'
                      option ip_source 'web'
                      option ip_url 'http://checkip.dyndns.org'
                      option bind_network 'wanb'
                      ... (other options)
```

### OpenVPN

- Related pages:
  
  - [server](/docs/guide-user/services/vpn/openvpn/server "docs:guide-user:services:vpn:openvpn:server")

#### Possible problems

If the openwrt system is an openvpn client and a zone 'vpn' is defined on the vpn interface and this zone has the masquerading active, for reasons (yet) unknown the traffic from the internal lan to the vpn will be able to reach the destination and go back to the router but then will be not dispatched back to the lan clients. Disabling mwan3, instead, let the traffic be dispatched properly.

It could be a misconfiguration, more testing is needed.

#### Example 1: Have OpenVPN Server be accessible through multiple WAN interfaces (server mode)

If load-balancing between multiple WAN interfaces, it is desirable to have OpenVPN clients be able to connect through all active WAN interfaces.

In a multiple WAN interface failover scenario, OpenVPN will not accept client connections on the secondary WAN interface after a failover, as it started listening on the primary WAN interface when it was started.

The following configuration will allow multiple WAN interface to be used with OpenVPN Server.

##### Step 1: Listen only on the internal LAN interface

- Configure OpenVPN Server to listen on the **internal** LAN interface only, not on any WAN interface. The internal LAN interface will not go down or change, and so it provides a stable listening interface for OpenVPN.

```
vi /etc/openvpn/my-vpn.conf
```

```
...
# Which local IP address should OpenVPN
# listen on? (optional)
;local a.b.c.d
## Customization: have OpenVPN listen on the internal LAN interface IP only to allow client re-connections after a WAN interface failover
local 192.168.1.1
 
...
```

##### Step 2: Set up port-forward(s)

- Configure a port-forward on the “wan” source zone to OpenVPN Server listening on the internal LAN interface. The port-forward will be active on every WAN interface and work the same way regardless of what WAN interface is active.
- Create a firewall rule like the following:
  
  - Network &gt; Firewall &gt; Port Forwards
    
    - Name: OpenVPN forward to unchanging inside IP
    - Protocol: UDP
    - Source zone: wan
    - Source IP address: any
    - External IP address: any
    - External port: 1194 (the default OpenVPN UDP port)
    - Internal zone: lan
    - Internal IP address: (the internal LAN interface IP address) . Careful on this point. If the internal LAN ip address mentioned is the same of the one mentioned in `ifconfig`, the redirect will transform in a DNAT+input accept rule, and the vpn server would be reachable. If the router has more than one ip address on the LAN interface, using one of them not mentioned in the `ifconfig` will cause the firewall application to transform it in a DNAT+forward rule and this means that the packet will be **not** routed on the router itself, therefore showing that then vpn port is unreachable.
    - Internal port: 1194 (this is not really needed)
    - Enable NAT Loopback: enabled (the default)

OpenWrt 15.05.x (Chaos Calmer) note: Unfortunately, the above approach doesn't work for UDP port-forwards to the router's LAN interface fail to work. TCP port-forwards are fine. This bug report talks about the issue: [https://dev.openwrt.org/ticket/18057](https://dev.openwrt.org/ticket/18057 "https://dev.openwrt.org/ticket/18057"). Apparently the change in the firewall3 package that broke this functionality has been reverted but the fix happened after the 15.05.x CC release.

##### Step 3: OpenVPN client and DNS configuration

- If load-balancing between multiple active WAN interfaces, the suggested approach is to register multiple DNS A records for the same DNS name. Clients will use just one of the IPs. As per the OpenVPN man page description of the --remote client parameter, “If host is a DNS name which resolves to multiple IP addresses, one will be randomly chosen, providing a sort of basic load-balancing and failover capability.”
- If failing over from a primary to a secondary WAN interface, one approach is to use ddns-scripts to update the IP of the DNS name used by OpenVPN clients

#### Example 2: Use OpenVPN tunnels as virtual wan(s) (client mode)

If you want to use your OpenVPN client tunnels as virtual wan interfaces in mwan3, you have to make sure that you set a default route with different metric for each tunnel interface. Also most commercial VPN solutions push two static routes to override the standard default gateway. In most cases you don't want this override when using OpenVPN client tunnels in conjunction with mwan3.

As a solution you can add the following lines to your OpenVPN client config:

```
route-nopull
route 0.0.0.0 0.0.0.0 vpn_gateway 20
```

This example will ignore the routes pushed from the OpenVPN server and will add a default route with metric 20 over the OpenVPN tunnel interface.

### privoxy transparent HTTP proxy

- References:
  
  - Forum posts from headless.cross and Adze, see [https://forum.openwrt.org/viewtopic.php?pid=209805#p209805](https://forum.openwrt.org/viewtopic.php?pid=209805#p209805 "https://forum.openwrt.org/viewtopic.php?pid=209805#p209805")

<!--THE END-->

- Related pages:
  
  - [privoxy](/docs/guide-user/services/proxy/privoxy "docs:guide-user:services:proxy:privoxy")

Transparent HTTP proxying relies on using iptables rules to transparently redirect outgoing traffic to port 80 first through the local proxy at another port number.

For example, here is a OpenWrt redirect rule to redirect outgoing traffic to TCP 80 port and re-send it to the local proxy listening on TCP port 8118. This will go into iptables NAT table rules.

```
config redirect
    option target 'DNAT'
    option dest 'lan'
    option proto 'tcp'
    option src 'lan'
    option src_dip '!10.0.2.1'
    option src_dport '80'
    option dest_ip '10.0.2.1'
    option dest_port '8118'
    option name 'Transparent Proxy [privoxy]'
    option enabled '1'
```

The problem is that mwan3 adds rules to the iptables's MANGLE table, and this is handled before the NAT table. So when a client makes a request to fetch a web page, it is first marked by mwan3. Mwan3 decides based on your mwan3 rules which wan interface to exit and marks the session accordingly.

Next, iptable nat rule handling takes place and diverts the web page request to privoxy. The reply from privoxy however is part of the same session and is already marked to leave a wan interface. The reply from privoxy is then send over the internet, which is obviously incorrect.

To fix this add the following rules to your mwan3 config:

```
config rule 'rule1'
    option proto 'tcp'
    option dest_port '80'
    option src_ip '10.0.2.1'
    option dest_ip '0.0.0.0/0'
    option family 'ipv4'
    option use_policy 'wan_wanb_loadbalanced'
 
config rule 'rule2'
    option proto 'tcp'
    option dest_port '80'
    option src_ip '10.0.2.0/24'
    option dest_ip '0.0.0.0/0'
    option family 'ipv4'
    option use_policy 'default'
 
config rule 'rule3'
    option dest_ip '0.0.0.0/0'
    option family 'ipv4'
    option use_policy 'wan_wanb_loadbalanced'
```

The policy “wan\_wanb\_loadbalanced” is just an example. Change it to whatever policy you like.

### NoDogSplash

Since NoDogSplash v3.1.0, mwan3 and NoDogSplash work fine together without any configuration changes. Both use iptables mark bits but NoDogSplash defaults to using bits carefully chosen for compatibility with other packages. A common symptom of any incompatibility would be the NoDogSplash splash page appearing for every page even as an authenticated client.

It is possible to change the settings for NoDogSplash in the UCI config file (/etc/config/nodogsplash).

The default settings are shown in this section from the config file:

```
  # Nodogsplash uses specific HEXADECIMAL values to mark packets used by iptables as a bitwise mask.
  # This mask can conflict with the requirements of other packages such as mwan3, sqm etc
  # Any values set here are interpreted as in hex format.
  #
  # Option: fw_mark_authenticated
  # Default: 30000 (0011|0000|0000|0000|0000 binary)
  #
  # Option: fw_mark_trusted
  # Default: 20000 (0010|0000|0000|0000|0000 binary)
  #
  # Option: fw_mark_blocked
  # Default: 10000 (0001|0000|0000|0000|0000 binary)
  #
  #option fw_mark_authenticated '30000'
  #option fw_mark_trusted '20000'
  #option fw_mark_blocked '10000'
```

These values let NoDogSplash work with mwan3, SQM etc. but can be changed if necessary.

### iperf3

Testing WAN links using iperf3 with mwan3 enabled can be a little tricky due to the fact mwan3 routing rules will often override the desired behaviour. More recently [iperf3 has been updated to support SO\_BINDTODEVICE](https://github.com/esnet/iperf/pull/1097 "https://github.com/esnet/iperf/pull/1097") which should make it more compatible with mwan3, version 3.10 and above now implements SO\_BINDTODEVICE.

In order to be able to use iperf3 successfully with mwan3 enabled you have a few options

1. Upgrade to iperf3 version 3.10 or later, this may not be available in all OpenWrt package repositories currently.
2. Upgrade to mwan3 2.10.0 or above, which provides the `mwan3 use` command to be able to specifically bind network commands to the interface required regardless of SO\_BINDTODEVICE support.
3. Implement custom mwan3 rules in `/etc/config/mwan3` that targets iperf3 traffic to use the main routing table, or set a specific interface policy.

As an example you can have something like this:

```
config rule 'iperf3_default'
	option dest_port '5201'
	option proto 'tcp'
	option use_policy 'default'
```

This rule targets any iperf3 test both IPv4 and IPv6 using the default TCP port of 5201 and makes mwan3 use the main routing table for this traffic.

You may also need to specifically implement rules that target a WAN interface directly in some cases:

```
config rule 'iperf3_wanb'
	option dest_port '5201'
	option src_ip 'xx.xx.xx.xx' # External WAN IP of WANB
	option proto 'tcp'
	option family 'ipv4'
	option use_policy 'wanb_only'
```

### nft2ipset init script

Due to the default firewall (fw4) now being based on nftables (rather than iptables), the ipset functionality commonly used in conjunction with dnsmasq and mwan3 no longer works in 23.05 releases. This is due to mwan3 not being fully compatible with nftables and requiring iptables compatibility/translation packages (see installation steps). While ipset functionality works in 23.02 without any changes, since the 23.05 release an important dnsmasq compile flag was changed to remove all ipset support in favour of nfset. To restore near like for like functionality a custom init script can be used, [credit @Kishi on the OpenWrt community forum](https://forum.openwrt.org/t/23-05-dnsmasq-ipsets-and-mwan3-incompatibility/174926/40 "https://forum.openwrt.org/t/23-05-dnsmasq-ipsets-and-mwan3-incompatibility/174926/40"). This script monitors changes to nftables/nfset and creates or updates ipset equivalents, essentially replicating the behaviour of what dnsmasq would do with ipset support enabled.

You will need to use nfset with dnsmasq for ipset polices to be created, which mwan3 only supports at this time. mwan3 currently does not support nfset in rules directly, hence the need to create ipset policies.

For help with this init script, please message @Kishi on the forum thread and also thank them if you found this useful!

The script is [published as gist on GitHub](https://gist.github.com/Kishi85/b7f379f9aa19f4878af28b8e1a8887ab "https://gist.github.com/Kishi85/b7f379f9aa19f4878af28b8e1a8887ab") so the full code can be inspected and reviewed before installing.

**Installation instructions:**

```
wget -O /etc/init.d/nft2ipset https://gist.github.com/Kishi85/b7f379f9aa19f4878af28b8e1a8887ab/raw/
chmod +x /etc/init.d/nft2ipset
service nft2ipset enable
service nft2ipset start
```

**Usage:**

1. Define the nftables sets in LuCI “Firewall → IP Sets” first. **Use the correct family (IPv4 or IPv6) there, match on dest\_ip and define separate sets for IPv4 and IPv6 if necessary**. Adding a timeout helps clearing old entries out of the ipsets automatically.
2. Then add those sets to dnsmasq resolving under “DHCP &amp; DNS → IP Sets” (Note: add both the IPv4 and the IPv6 set to the IP set option of the element as necessary. (Multiple nftables sets are possible to be specified for each group).
3. Finally add them to mwan3 rules. I use specific, separate rules for IPv4/IPv6, but IPv4+IPv6 works as well because it'll match the family if the ipset anyway (which is IPv4 by default if not explicitly defined under “Firewall → IPsets” as it is the default family for ipset).

## Original creators/authors

- Forum member Adze wrote mwan3
- Forum member Arfett wrote luci-app-mwan3

### Current maintainers

- [Florian Eckert](https://github.com/feckert "https://github.com/feckert")
- [Aaron Goodman](https://github.com/aaronjg "https://github.com/aaronjg")

## References

- There is documentation available for policy routing on Linux, e.g. [Policy Routing With Linux - Online Edition by Matthew G. Marsh](http://www.policyrouting.org/PolicyRoutingBook/ONLINE/TOC.html "http://www.policyrouting.org/PolicyRoutingBook/ONLINE/TOC.html")
- Source code for [mwan3](https://github.com/openwrt/packages/tree/master/net/mwan3 "https://github.com/openwrt/packages/tree/master/net/mwan3")
- Source code for [luci-app-mwan3](https://github.com/openwrt/luci/tree/master/applications/luci-app-mwan3 "https://github.com/openwrt/luci/tree/master/applications/luci-app-mwan3")
