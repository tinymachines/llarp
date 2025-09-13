# Flow offloading

**Under Construction!**  
This page is currently under construction. You can edit the article to help completing it.

## Intro

The *Flow offload* may significantly increases throughput of device with slow CPU.

Some facts:

- Technically, the *software flow offload* is just a firewall rule.
- Neither flow forwarding offload is directly related to network adapter offload functions controlled by `ethtool -k/-K`.
- Flow offloading applies to forwarded connections, including those to containers like [LXC](/lxc_openwrt_host "lxc_openwrt_host") or [podman](/packages/pkgdata/podman "packages:pkgdata:podman"), but not locally running web-server.
- *Hardware offload* bypasses QoS traffic controls at high priority making former ineffective.
- *Hardware offload* can handle very limited number of connections at once, e.g. 64, thus will not significantly help p2p, returning surplus connections to software offload pool.
- *Software offload* typically increases forwarding bandwidth 2-3x over firewall filtering each packet, sometimes that relieves fully loaded CPU and improves overall latency/jitter.

Abbreviations:

- HFO — hardware flow offloading.
- WED — wireless offloading, wireless Ethernet dispatch.
- PPE — kernel interface for hardware flow offload, monitored via `/sys/kernel/debug/ppe0/entries` special file.

## How to enable

### LuCI web UI

Using LuCI web UI: `Network → Firewall` and select “Software flow offloading” or “Hardware flow offloading”, then hit “Save &amp; Apply”.

### UCI

CLI with [UCI](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") (choose the one option you want):

```
uci set 'firewall.@defaults[0].flow_offloading=1'
uci set 'firewall.@defaults[0].flow_offloading_hw=1'
uci commit
/etc/init.d/firewall restart
```

### CLI

CLI: edit `/etc/config/firewall` and insert the following under the config defaults section (choose the one option you want):

```
config defaults
…
  option flow_offloading '1'
  option flow_offloading_hw '1'
```

Then restart the firewall:

```
/etc/init.d/firewall restart
```

## Hardware implementation

### MediaTek mt76

The main page about MediaTek chipsets: [soc.mediatek](/docs/techref/hardware/soc/soc.mediatek "docs:techref:hardware:soc:soc.mediatek").

Hardware offloading is supported on [mt76](/docs/techref/driver.wlan/mt76 "docs:techref:driver.wlan:mt76") platforms starting from [SoC](/docs/techref/hardware/soc "docs:techref:hardware:soc") mt7621.

WED enablement (i.e hardware offloading for Wi-Fi): TODO.

## Known issues

- The *Hardware offload* is supported by limited amount of platforms.
- Stale connections/freezes when changing Wi-Fi band (for example from 2.4 GHz to 5 GHz).
- Prevents Wi-Fi roaming by keeping stale connection mappings.

## Links

- [Netfilter’s flowtable infrastructure](https://www.kernel.org/doc/html/v5.15/networking/nf_flowtable.html "https://www.kernel.org/doc/html/v5.15/networking/nf_flowtable.html") — the Linux kernel documentation with description of both *Software flow offload* and *Hardware offload* and with a list of limitations.
