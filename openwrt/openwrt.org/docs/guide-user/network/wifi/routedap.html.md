# Routed AP

In the default configuration, OpenWrt bridges the wireless network to the LAN of the device. The advantage of bridging is that broadcast traffic from Wireless to LAN and vice versa works without further changes.

In order to separate the wireless network from LAN, a new network with the corresponding DHCP and firewall settings must be created. This document outlines the steps necessary to implement such a setup.

[![](/_media/doc/recipes/routed.ap_v3.png)](/_detail/doc/recipes/routed.ap_v3.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Aroutedap "doc:recipes:routed.ap_v3.png")

## Configuration

The changes below assume an OpenWrt default configuration, the relevant files are:

- [/etc/config/network](/docs/guide-user/base-system/basic-networking "docs:guide-user:base-system:basic-networking")
- [/etc/config/wireless](/docs/guide-user/network/wifi/basic "docs:guide-user:network:wifi:basic")
- [/etc/config/dhcp](/docs/guide-user/base-system/dhcp "docs:guide-user:base-system:dhcp")
- [/etc/config/firewall](/docs/guide-user/firewall/firewall_configuration "docs:guide-user:firewall:firewall_configuration")

### Step 1: Define a new network

Edit `/etc/config/network` and define a new `interface` section:

```
config 'interface' 'wifi'
        option 'proto'      'static'
        option 'ipaddr'     '192.168.2.1'
        option 'netmask'    '255.255.255.0'
```

Note that no `ifname/device` option is set here, it is not required since the wireless network will reference this section later.

![](/_media/meta/48px-dialog-warning.svg.png) **Make sure** that the chosen IP address is in a **different subnet** than the one used by the `lan` interface. For instance, if your lan is in 192.168.**1**.x space, the wifi must be in the 192.168.**2**; be aware that the same restrictions may apply regarding your WAN interface

### Step 2: Change the existing wireless network

In `/etc/config/wireless`, locate the existing `wifi-iface` section and change its network option to point to the newly created interface section.

```
config 'wifi-iface'
        option 'device'     'wl0'
        option 'network'    'wifi'
        option 'mode'       'ap'
        option 'ssid'       'OpenWrt'
        option 'encryption' 'none'
```

In the existing section, `network` was changed to point to the `wifi` interface defined in the previous step.

Optionally change the last line for `option encryption 'psk2`' and add the line `option key 'secret key`' to enable [WPA encryption](/docs/guide-user/network/wifi/encryption#wpaencryption "docs:guide-user:network:wifi:encryption")

### Step 3: Define a new DHCP pool (optional)

Since wireless is not bridged to LAN anymore, no DHCP leases are served to wireless clients yet. In order to support DHCP on wireless as well, a new `dhcp` pool must be defined in `/etc/config/dhcp`:

```
config 'dhcp'  'wifi'
        option 'interface'  'wifi'
        option 'start'      '100'
        option 'limit'      '150'
        option 'leasetime'  '12h' 
```

### Step 4: Adjust firewall settings

By default, traffic originating from the wireless network is not allowed to reach the WAN or the LAN interface. There is also no firewall zone defined for it yet, so only the default policies apply to the wireless network.

Edit `/etc/config/firewall` and add new `zone` section covering the `wifi` interface:

```
config zone
        option name       wifi
        list   network    'wifi'
        option input      ACCEPT
        option output     ACCEPT
        option forward    REJECT
```

Now that the zone is defined, traffic forwarding control for the wireless network can be implemented. To allow wireless clients to use the WAN interface, add the following `forwarding` section:

```
config 'forwarding'
        option 'src'        'wifi'
        option 'dest'       'wan' 
```

If LAN clients should be able to contact wireless clients, add the following forwarding:

```
config 'forwarding'
        option 'src'        'lan'
        option 'dest'       'wifi'
```

To allow wireless clients to reach the LAN network, add the reversed rule below as well:

```
config 'forwarding'
        option 'src'        'wifi'
        option 'dest'       'lan'
```

To allow replies from wan to wifi client add option masq 1 to the lan 'lan' firewall option:

```
 
config zone                                            
        option name             lan           
        list   network          'lan'        
        option input            ACCEPT    
        option output           ACCEPT             
        option forward          ACCEPT             
        option masq 1 
```

### Apply changes

1. Enable the new wireless network
   
   ```
   ifup wifi
   wifi
   ```
2. Restart the firewall
   
   ```
   /etc/init.d/firewall restart
   ```
3. Restart the DHCP service
   
   ```
   /etc/init.d/dnsmasq restart
   ```

## IPv6 prefix delegation

If you are using IPv6 prefix delegation for subnetting on the LAN side, you might have to adjust the interface parameter `ip6assign`, which sets the prefix size delegated downstream. For each of `lan` and `wifi` in the example, a value of `ip6assign` must be chosen such that the combined size of these subnets does not exceed the size of the IPv6 prefix available from upstream. Otherwise, one of the assignments would fail. The IPv6 page explains [downstream configuration](/docs/guide-user/network/ipv6/start#downstream_configuration_for_lan-interfaces "docs:guide-user:network:ipv6:start") in more detail.

## More tweaks

- In some case, you cannot access Internet from “wifi” network clients (though you can do from the router), then you can replace the firewall setting with this [https://forum.openwrt.org/viewtopic.php?pid=166701#p166701](https://forum.openwrt.org/viewtopic.php?pid=166701#p166701 "https://forum.openwrt.org/viewtopic.php?pid=166701#p166701")
