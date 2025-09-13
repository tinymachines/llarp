# Parental controls

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This article describes common methods to perform parental control of internet access.
- Be sure to apply restrictions to all source zones if you are using a firewall-based method.

## Restrict / deny / block access to certain web pages

### Blocking servers by blacklisting their IP

Follow: [Firewall rule to block a site](/docs/guide-user/firewall/fw3_configurations/fw3_config_examples#block_lan-side_access_to_a_specific_site "docs:guide-user:firewall:fw3_configurations:fw3_config_examples")

If a server is running at a single IP or just uses a small set of IPs, blocking these IPs in fw3 is a very efficient way to block this site. It is the quickest and most efficient way of blocking websites and is well supported even in the web interface. Assuming OpenWrt operates with a LAN and WAN zone a filter in the FORWARD chain that rejects packets is enough. ASN lists could be used to block large numbers of IPs belonging to certain companies. A script would be used to fetch all current IPs assigned to a certain company and this information is used to update the firewall accordingly.

Drawbacks:

- To circumvent these IP based restrictions an internet proxy or Tor could be used.
- Dynamic hosts change their IP on a regular basis, invalidating the blacklist

### Blocking name resolution (DNS) by Adblockers

Follow: [Ad blocking](/docs/guide-user/services/ad-blocking "docs:guide-user:services:ad-blocking"), [DNS filtering](/docs/guide-user/base-system/dhcp_configuration#dns_filtering "docs:guide-user:base-system:dhcp_configuration")

This method voids DNS lookups so, for example, `www.youtube.com` does not generate the desired IP address. Adblock can be used to blacklist certain domain names and prevent the DNS server handing out the right IP. Alternatively Dnsmasq can be configured to return a NXDOMAIN answer in case a blacklisted domain name is queried. Another option is to use Pi-hole in the LAN and divert DNS requests to Pi-hole.

Drawbacks:

- If the IP of the server is known, it can be reached directly without using DNS altogether.
- These restrictions can be foiled quite easily by using another internet site to lookup the IP address for the site and bypassing DNS altogether.
- If several DNS are in the LAN just changing the local settings to the unfiltered DNS renders this control useless.

### Blocking IPs based on their domain names (FQDN, host names)

Follow: [banIP](/docs/guide-user/services/banip "docs:guide-user:services:banip"), [Filtering traffic with IP sets by DNS](/docs/guide-user/firewall/fw3_configurations/dns_ipset "docs:guide-user:firewall:fw3_configurations:dns_ipset")

Since OpenWrt in a typical setup with a LAN and WAN zone does the name resolution and the firewall at the same time, all information is there to match domain names, their current IPs as they are handed out to the LAN-hosts and act accordingly in the firewall. This is essential if a single domain might resolve to several IPs. For instance websites that operate with a CDN can be blocked by their name instead of finding out each and every IP the CDN might be using.

Drawbacks:

- This will block all sites sharing the same IP with the targeted, so use carefully for domains which rely on [CDNs](https://en.wikipedia.org/wiki/Content_delivery_network "https://en.wikipedia.org/wiki/Content_delivery_network").
- Completely blocking sites that use localized domains is problematic.

### Blocking sites by using proxy servers

Follow: [Proxy server overview](/docs/guide-user/services/proxy/overview "docs:guide-user:services:proxy:overview")

A proxy server like [Squid](/docs/guide-user/services/proxy/proxy.squid "docs:guide-user:services:proxy:proxy.squid") or [Tinyproxy](/docs/guide-user/services/proxy/tinyproxy "docs:guide-user:services:proxy:tinyproxy") can be used to block access to websites. It can check HTTP(S) specific details. The huge benefit of this option is to have the finest level of control. It can even distinguish in cases where a single server with a single IP runs for example a blacklisted and whitelisted domain at once.

Squid offers many features like SNI HTTPS based filtering, SSL-bump and splice. However, for typical resource constrained devices, Tinyproxy offers the most important options (filtering websites) as well. For parental control, due to ease of setup and low RAM/Flash requirements, consider Tinyproxy first.

Drawbacks:

- If not everything else except the proxy is blocked, it can be circumvented. The firewall must block the client-device from accessing the internet directly.
- The clients need to configure the proxy in their browser.

## Time restriction of internet access

Block internet access for MAC or IP addresses (or everyone) on week days during specific time interval.

- Verify that your router has the correct time and timezone.
- Apply the following workarounds to ensure reliable operation:
  
  - [Reorder firewall rules](/docs/guide-user/firewall/fw3_configurations/dns_ipset#established_connections "docs:guide-user:firewall:fw3_configurations:dns_ipset") to enforce time restrictions for already established connections.
  - [Reload kernel timezone](/docs/guide-user/base-system/system_configuration#daylight_saving_time "docs:guide-user:base-system:system_configuration") to handle DST-related changes.

### Web interface instructions

Adjust the parameters according to your configuration.

1. Navigate to **LuCI → Network → Firewall → Traffic Rules**.
2. Click **Add** and specify:
   
   - Name: `Filter-Parental-Controls`
   - Protocol: Any
   - Source zone: `lan`
   - Destination zone: `wan`
   - Action: reject
3. (Optional) If you want to add a MAC or IP limitation, on the **Advanced Settings** tab specify:
   
   - Source MAC address: `00:11:22:33:44:55`
   - Source IP address: `192.168.1.2`
4. On the **Time Restrictions** tab specify:
   
   - Week Days: Monday, Tuesday, Wednesday, Thursday, Friday
   - Start Time: `21:30:00`
   - Stop Time: `07:00:00`
5. Click **Save**, then **Save &amp; Apply**.

You can add another rule to apply time restrictions on weekend.

### Command-line instructions

Add a new firewall rule. Edit the following example code block to suit your needs and then copy-paste it into the terminal. Check for errors the service restart output!

```
# Configure firewall
uci add firewall rule
uci set firewall.@rule[-1].name="Filter-Parental-Controls"
uci set firewall.@rule[-1].src="lan"
uci set firewall.@rule[-1].src_mac="00:11:22:33:44:55"
uci set firewall.@rule[-1].dest="wan"
uci set firewall.@rule[-1].start_time="21:30:00"
uci set firewall.@rule[-1].stop_time="07:00:00"
uci set firewall.@rule[-1].weekdays="Mon Tue Wed Thu Fri"
uci set firewall.@rule[-1].target="REJECT"
uci commit firewall
service firewall restart
```

## Restrict access to Wi-Fi by MAC address

Restrict access to your Wi-Fi by MAC address. The primary motivation for this capability is a family member gives out the SSID and passphrase to a friend while in your home. Later you no longer want to allow the person to use your Wi-Fi.

There are several solutions to this problem with decreasing labor and effectiveness.

1. The most comprehensive is to create a [guest Wi-Fi](/docs/guide-user/network/wifi/guestwifi/start "docs:guide-user:network:wifi:guestwifi:start").
2. Change the passphrase for the interfaces.
3. Only allow/deny LAN access for devices with matching MAC addresses.

This section focuses on the last option using the wireless interface MAC filter option. This is a simple solution that can be invalidated by a smart hacker changing the MAC address of their device.

### Web interface instructions

1. Navigate to **LuCI → Network → Wireless**.
2. Click **Edit** on a selected interface.
3. On the **MAC Address Filter** tab specify:
   
   - MAC Address Filter:
     
     - Allow listed only
     - Allow all except listed
   - MAC List:
     
     - `11:22:33:44:55:66`
     - `aa:bb:cc:dd:ee:ff`
4. Click **Save**, then **Save &amp; Apply**.

### Command-line instructions

```
# Use allow-type or deny-type filter
uci set wireless.@wifi-iface[0].macfilter="allow"
uci set wireless.@wifi-iface[0].macfilter="deny"
 
# Append the MAC address to the list
uci add_list wireless.@wifi-iface[0].maclist="11:22:33:44:55:66"
uci add_list wireless.@wifi-iface[0].maclist="aa:bb:cc:dd:ee:ff"
 
# Check settings
uci show wireless.@wifi-iface[0]
 
# Save and apply
uci commit wireless
wifi reload
```

You need to apply this for all wireless interfaces accessible by the user. Typically the 5 Ghz band is `@wifi-iface[0]` and the 2.4 Ghz band is `@wifi-iface[1]`.
