# Setting up DAWN and band-steering

[DAWN](https://github.com/berlin-open-wireless-lab/DAWN "https://github.com/berlin-open-wireless-lab/DAWN") is a “Decentralized Wifi Controller” which can be used for band-steering in OpenWrt.

This can be useful for improved WiFi performance when you have a network with multiple APs. Especially on EAP networks, it is highly recommended to set up [802.11r](/docs/guide-user/network/wifi/basic#fast_bss_transition_options_80211r "docs:guide-user:network:wifi:basic") also.

## WiFi Roaming

An summary of WiFi roaming technologies can be found on the [roaming](/docs/guide-user/network/wifi/roaming "docs:guide-user:network:wifi:roaming") page.

## Prerequisites

The following items are required to setup DAWN:

- One or more OpenWrt based APs (and routers).
- install the full version of wpad
- install and configure required packages for DAWN

## Setting up DAWN

To setup DAWN:

- configure 802.11k and 802.11v on all WiFi AP-nodes.
- install and configure required packages for DAWN
- reboot all nodes (or just restart the network if no wpad packages have been changed).

### Configure 802.11k and 802.11v on all AP-nodes

SSH into each of your wifi/AP nodes and add the following config-lines in `/etc/config/wireless` to each of your SSIDs:

```
      option bss_transition '1'
      option ieee80211k '1'
```

### Install and configure required packages

We need to install DAWN and umdns. Note in OpenWrt 21.02 (older releases) none of these packages works out of the box, and need fixing before we can use them.

First of all, SSH into all the AP-nodes in your network and install the required packages. If you have a dedicated router (without AP functionality enabled) and you would like to get DAWN dashboards in Luci there too, you need to install these packages here as well:

```
 opkg update && opkg install dawn
```

umdns is a dependency of dawn and will be installed automatically too.

At this point you have all the packages you need, but they may be in need of additional configuration.

### Configure umdns (Optional)

If you have a setup that doesn't use “lan” as the interface being used by umdns, it is necessary to update the /etc/config/umdns file with the correct interface name.

For instance, if your interface name is called “VLAN10”, the configuration file would look like this

```
config umdns
      option jail 1
      list network VLAN10
```

Refer to [mdns](/docs/guide-developer/mdns "docs:guide-developer:mdns") for more information on umdns.

### Fixing umdns (OpenWrt 21.02 only)

Since dawn in network mode 2 (umdns + tcp) depends on umdns, ensure umdns is working correctly first. On all nodes where you installed dawn, try the following command:

```
 /etc/init.d/umdns restart
```

If this command completes without error, umdns is working correctly. If it fails, we can disable the umdns seccomp profile:

```
 mv /etc/seccomp/umdns.json /etc/seccomp/umdns.json.disable
```

Restarting or starting umdns should now succeed.

Do this for all nodes in your “DAWN”-netwwrk.

### Configuring DAWN

**Warning!** This is NOT needed if you stick to the default “network\_option” of 2 (umdns + tcp). It is recommended to stick with the defaults and ignore this section due to issues with the other UDP-based network mode options offered by DAWN as it sends packets that are larger interface MTU causing corrupted data to be received on the other end.

dawn's config-file /etc/config/dawn specifies which subnet is used for broadcasts to discover other nodes. By default this is specified as “10.0.0.255”. If your OpenWrt has a default 192.168.1.x LAN-subnet, you will need to change this file.

In /etc/config/dawn, change this line:

```
  option broadcast_ip '10.0.0.255'
```

To this line:

```
  option broadcast_ip '192.168.1.255'
```

Also, consider changing the default password to something else, but make sure the same password is used on all nodes!

After making this change, restart dawn:

```
  /etc/init.d/dawn restart
```

Again, do this on all nodes in your “DAWN”-network.

### Configuration Tips

#### Using "rssi\_weight" and "rssi\_center" for Improved Target Selection

Two key parameters, “rssi\_weight” and “rssi\_center,” helps in fine tuning DAWN in kick method 1 (RSSI Comparison) or 3 (default, RSSI Comparison and Absolute RSSI).

In kick methods 1 and 3, adjusting default scoring parameters like “ht\_support,” “vht\_support,” “rssi,” “low\_rssi,” “chan\_util,” and “max\_chan\_util” to 0 is recommended. This will allow for a completely dynamic scoring calculation based solely on the RSSI reducing complexity and chance of misconfiguration, this means the calculation will solely become:

`new_score = initial_score + (rssi - rssi_center) * rssi_weight`

For instance, if the initial score is 100, rssi is -47, rssi\_weight is 2, and rssi\_center is -20, the new score would be 46. Experimenting with these parameters in a spreadsheet can help.

The benefit of this approach lies in avoiding fixed values in parameters like “rssi” and “low\_rssi” that are based solely on the threshold defined in “rssi\_val” and “low\_rssi\_val.” In scenarios where two APs are in close proximity, but one has a 20 RSSI difference, the dynamic scoring prevents identical scores, ensuring the selection of the superior AP. This might not be the case if those two APs happen to both classify as within the “low\_rssi\_val” threshold, for instance.

#### Kick Method Considerations

- **Kick Method 2 and 3:** Special attention is required when selecting “rssi\_center” as it serves as the threshold for client kicks, disregarding the score and RSSI comparison with other APs. For this reason, kick method 1 (RSSI Comparison) is generally preferred, while kick method 2 (Absolute RSSI) and kick method 3 (Both RSSI Comparison and Absolute RSSI) are to be avoided.
- **Default Kicking Method Consideration:** The default kicking method may not be suitable, as it may continue to kick clients below the “rssi\_center” even when there is no alternative AP the client may connect to. Kick method 1 is often more appropriate as it considers other APs when making such decisions and wouldn't kick if no better option exists for the client.
- **Misconception Clarification:** There is a common misconception on forums that kick method 3 requires both RSSI comparison and absolute RSSI to be satisfied. However, a closer look at the code shows that this is not the case: [https://github.com/berlin-open-wireless-lab/DAWN/blob/e036905ae3a5d079f899bbe46461fc78b4566349/src/storage/datastorage.c#L509-L543](https://github.com/berlin-open-wireless-lab/DAWN/blob/e036905ae3a5d079f899bbe46461fc78b4566349/src/storage/datastorage.c#L509-L543 "https://github.com/berlin-open-wireless-lab/DAWN/blob/e036905ae3a5d079f899bbe46461fc78b4566349/src/storage/datastorage.c#L509-L543")

#### Increasing Frequency of Kicking

DAWN decides to kick a client at every `update_client` interval. This means that reducing this number to “1” from the default “20,” would cause DAWN to make its calculations on whether to kick a client every 1 second (with `min_number_to_kick` still being considered as usual).

### Optional (Dashboard)

You may also optionally install “luci-app-dawn”. luci-app-dawn provides a network overview inside Luci, and can be useful to ensure your setup works correctly.

You can install it on any node you like, *including your main router, even if that does not provide wifi*.

Installing it on all nodes can be useful, as it lets you verify that you get the same DAWN information on all nodes, and thus that they are communicating together correctly.

On the nodes where you want a DAWN dashboard in luci, enter the following command:

```
  opkg install luci-app-dawn
```

### Restarting (network on) all nodes

After making these changes you need to restart networking on all nodes to make changes effective.

You can either reboot/power-cycle the device, or just SSH into the node and issue:

```
  /etc/init.d/network restart
```

Once this has been done on all nodes, you should be able to get a nice dashboard in luci showing you your network topology:

![](/_media/media/dawn.png?w=600&tok=ec6987)

Mission accomplished!
