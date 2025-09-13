# How to use OpenWrt behind a Freebox Crystal with IPv6 bridge

This HOWTO explains how to configure OpenWrt to work with a [Freebox Crystal](https://www.free.fr/freebox/freebox-crystal/ "https://www.free.fr/freebox/freebox-crystal/").

If you have a newer model of Freebox please refer to [How to use OpenWrt behind a Freebox with IPv6 delegation](/docs/guide-user/network/ipv6/freebox "docs:guide-user:network:ipv6:freebox"). The method described on that page is more complex than the below and is stated not to work on a Freebox Crystal.

As described in the page linked above, the Freebox Crystal is limited in it's IPv6 functionality. It is, however, able to function as a bridge for Router Advertisement, DHCPv6, etc. so the below explains how to configure OpenWrt to take advantage of that. Your local IPv6 boxes will obtain full public IPv6 addresses, but as they are behind the OpenWrt firewall can be protected if required (in fact, that is the case with default OpenWrt configuration at time of writing).

## On your Freebox Subscriber Space

If you have not already disabled router mode on your Freebox **the below will likely break your Internet connection** so be sure to have everything in place and prepared before doing this:

1. Login to your Freebox Subscriber space.
2. Under 'Ma Freebox'/'Paramétrer mon routeur Freebox' disable router &amp; DHCP ('Etat du routeur' = 'non' &amp; 'Etat du DHCP' = 'non'). Note that this isn't strictly necessary but is considered good practice as turning off router functionality on the Freebox prevents double NAT on IPv4.
3. Under 'Ma Freebox'/'Passer au protocole IPv6' enable IPv6 ('Support IPv6' = 'oui').
4. Reboot your Freebox.

## Physical connections

As we have just disabled the router &amp; DHCP functions of the Freebox disconnect all other devices aside from your OpenWrt box.

## On OpenWrt

Upon reboot of the Freebox your OpenWrt router should now get both IPv4 and IPv6 addresses from the Freebox. Note that as the Freebox Router function is disabled the OpenWrt router should obtain a public IPv4 address rather than a 192.168.x.x range. It should also obtain an IPv6 address on this interface.

### LAN DHCP

Visit your LAN interface settings in LUCI and set the following DHCP IPv6 settings to 'relay mode':

- Router Advertisement-Service
- DHCPv6-Service
- NDP-Proxy

### WAN DHCP

We now simply have to associate the above LAN relay with the WAN port. This is done by editing `/etc/config/dhcp` on your OpenWrt router and adding the following options:

```
config dhcp 'wan'                  
        ...
        option dhcpv6 'relay'
        option ra 'relay'                  
        option ndp 'relay'                       
        option master '1'
```

Edited: prefer to set IP in fixed way, so you do not lost the dhcpv6 parameters and can set them in the luci interface... Also was the only method that make all “it works” for me !

## Verify IPv6 Functionality

That's it. Devices on the LAN should now obtain full public IPv6 addresses from your ISP. They will not be reachable from outside world though, as OpenWrt blocks incoming IPv6 packets by default.

Visit [https://ipv6-test.com/](https://ipv6-test.com/ "https://ipv6-test.com/") to confirm this functionality.

## LAN DNS

As discussed this solution is using the Freebox as a relay for various IPv6 functionality. In this state, hosts on the LAN will obtain IPv6 DNS servers via that relay and use them for DNS resolution. Ie. the ISP's IPv6 DNS servers will be used directly by LAN hosts. This might not be desirable if you want to resolve a local domain, include some other DNS based features (such as [Adblock](/docs/guide-user/services/ad-blocking "docs:guide-user:services:ad-blocking")) or simply have a LAN based DNS for efficiency.

In order to have the OpenWrt router service DNS requests from the LAN the following two changes are necessary:

1. Edit the LAN network interface and assign an IPv6 address. The Free ISP allocates a /64 block to each customer so copy that subnet and add `::1:fe` to the end to get something like `2a01:e35:xxxx:xxxx::1:fe` (as suggested in [How to use OpenWrt behind a Freebox with IPv6 delegation](/docs/guide-user/network/ipv6/freebox "docs:guide-user:network:ipv6:freebox")). Just add this address - there is no need to enter IPv6 gateway, routed prefix, etc.
2. In the 'IPv6 Settings' tab of 'DHCP Server' below add this IPv6 address set on the LAN interface to 'Announced DNS servers' setting.

Now LAN clients should be provided with the LAN IPv6 address of OpenWrt router and it should service requests normally. You are free to set local LAN domain names, use Adblock, etc.
