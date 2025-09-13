# IPv6 troubleshooting

IPv6 networks have more configuration options, and more failure modes, than IPv4 networks. This page has suggestions on how to troubleshoot issues such as:

- Devices cannot obtain IPv6 addresses on the local network
- Devices cannot communicate with each other over IPv6
- Outbound requests to IPv6 addresses hang or are rejected

The discussion in [this forum thread](https://forum.openwrt.org/t/ipv6-routing-does-not-work-on-lan-but-does-work-from-router/192472 "https://forum.openwrt.org/t/ipv6-routing-does-not-work-on-lan-but-does-work-from-router/192472") was used as a starting point for creating this wiki page.

### Basic concepts

It is very helpful to understand the concepts involved in IPv6 networking, as they are more complex than those involved in IPv4.

- There is more than one type of IPv6 address.
  
  - Globally-unique address (GUA): identifies a device or subnet globally on the internet. These are in the `2000::/7` block (from `2000::` to `2800::`).
  - Unique local address (ULA): identifies a device or subnet only within a local network. These are in the `fd00::/8` block (from `fd00::` to `fe00::`).
  - Link-local address: identifies a device within a single link (subnetwork that a device is connected to). These are in the `fe80::/64` block (from `fe80::` to `fe80:0000:0000:1::`).
- Under IPv6, an ISP delegates an entire address block (prefix) to your router, rather than assigning it a single address as under IPv4. The most common block sizes are /56, /60, and /64. There is no such thing as an IPv6 network smaller than /64, so the ideal situation is to subnet within the delegated address block and not use any address translation. If only a /64 is delegated, then address translation is required to subnet.
- Under IPv4, devices typically have only one address. Under IPv6, devices always have a link-local address, and they may additionally have either a GUA or ULA or both, depending on network configuration. Using only GUAs is generally preferred, as it avoids the need for address translation. Bugs have been reported in how OpenWrt handles both GUAs and ULAs assigned on a network in some circumstances, so it is preferable to disable ULA assignment unless it is necessary.

### Configuration

In a typical setup you will want the ISP to delegate a prefix to your `wan6` interface, but disable `wan6` from delegating prefixes further to `lan` and other subnetworks, because those subnetworks have only individual devices on them, and not further routers. To implement a setup like that, use the following settings:

- ULA assignment: disabled (see Network &gt; Interfaces &gt; Global network options)
- “Request IPv6-address”: try
- “Request IPv6-prefix of length”: set to /64, verify that a block is assigned; set to /60, see if a block is still assigned; repeat until largest possible block is determined. Alternatively, set to automatic to use the default from the ISP
- “Do not send a Release when restarting”: enable
- “Delegate IPv6 prefixes”: enable on `wan6`, disable everywhere else
- “IPv6 assignment length”: disable on `wan6`, enable and set to 64 on `lan` and other local subnetworks
- “IPv6 assignment hint”: set to successive integers on each local subnetwork (this determines the /64 ranges that will be assigned to each subnetwork from your prefix delegation)
- “RA-Service”: disable on `wan6`, set to server mode on `lan` and other subnetworks
- “DHCPv6-Service”: disable on `wan6`, set to server mode on `lan` and other subnetworks
- “NDP-Proxy”: set to relay mode

In the case that you can only get a /64 from your ISP, but still want to subnetwork, then you can instead:

- Disable “Delegate IPv6 prefixes” (because you would only be able to delegate a prefix to one subnetwork)
- Disable “IPv6 assignment length” on all interfaces
- Change “RA-Service” and “DHCPv6-Service” to relay mode so that IP addresses are requested directly from the ISP instead of from local DHCPv6 server (OpenWrt keeps track of the two VLANs but they will have addresses from the same CIDR block)

To troubleshoot, a good first step is to compare your settings to the ones above and consider whether any differences are intended based on your network setup.

#### Bad settings

The following settings (or settings combinations) are probably not desired for simple setups (but might be required for advanced configurations):

- ULA assignment enabled: on some devices for unknown reasons, causes outbound IPv6 connectivity to fail, as discussed [on the GitHub issue tracker](https://github.com/openwrt/openwrt/issues/9881#issuecomment-1711820408 "https://github.com/openwrt/openwrt/issues/9881#issuecomment-1711820408")
- Request IPv6-prefix of length 64: will prevent subnetting and prefix delegation without additional configuration. Before proceeding with this, verify that a larger prefix cannot be obtained from the ISP
- Delegate IPv6 prefixes enabled on interfaces other than `wan6`: unless you have routers with further subnetworks on `lan` etc, this doesn't make much sense
- IPv6 assignment length on `lan` set to same as IPv6-prefix length on `wan`: this works, but means you can only have one local subnetwork, as the entire available prefix will be assigned to only one of the available subnetworks and there will be no addresses for the others

### Expected appearance

You should expect to see the following in a properly configured IPv6 enabled network:

- The `wan6` interface should have at least a /60 block delegated to it, this will be displayed as “IPv6-PD” on the interfaces list page in LuCI.
- The `lan` interface (and interfaces for any other subnetworks you have created) should have IPv6 addresses assigned to them, which will be displayed as something like `xxxx:xxxx:xxxx:xxxx::1/64` in the LuCI interfaces list, indicating that a /64 block has been assigned to that subnetwork and the router has been assigned the first valid address in that block, similar to how it works in IPv4.
- Interfaces will have GUAs shown if and only if prefix delegation and address assignment is working properly. Interfaces will have ULAs shown if and only if ULA assignment is enabled in the global network options (this doesn't depend on the ISP).

### Gathering more data

In the case that the problem can't be resolved by inspection, consider using the following diagnostic approaches to help identify at which stage the problem is occurring:

- Check the address ranges assigned to each interface in LuCI. If there is no GUA assignment for `lan`, then it won't be able to contact the public internet unless you have ULA assignment enabled and address translation properly configured.
- Check whether devices on the network have IPv6 addresses assigned, and if so, whether they have GUAs, ULAs, or both. On Linux, use `ip -6 addr` to check. Devices will have addresses assigned from the address ranges on the interfaces that they are connected to.
- Check whether devices on the network can contact the public internet over IPv6 (see [Test IPv6](https://test-ipv6.com/ "https://test-ipv6.com/") or try `curl -v -6 https://example.com`), and separately, check whether the router can do the same (consider `wget -O- -6 https://example.com` when connected over SSH). Also, can devices on the network contact the router over IPv6?
- Check the routing tables on individual devices as well as on the router. On Linux (including OpenWrt), use `ip -6 route`. You can also see the same graphically at Status &gt; Routing on LuCI. Depending on whether IPv6 source routing is enabled, you should expect to see source filters on the forwarding rules based on the assigned address ranges for each interface. If any routing table is missing a default route, connectivity to the internet surely will not be functional.
- You can use Wireshark and filter for IPv6 packets when connecting to wifi/ethernet on a device to see the RS/RA handshake, which shows explicitly the default routes being advertised to devices on DHCPv6.
- Consider making use of `traceroute` to see at what stage traffic is being dropped. You can also use Wireshark to see the packets that are sent out, and potentially the ICMP replies from the router or other network nodes.
