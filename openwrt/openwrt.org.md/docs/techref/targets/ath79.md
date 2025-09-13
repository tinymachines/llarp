# ath79

ath79 is the successor of [ar71xx](/docs/techref/targets/ar71xx "docs:techref:targets:ar71xx"). It's modernization under the hood, with the main goal to bring the code into a form that is acceptable for Linux upstream, so that all (most) of the whole ar71xx supported devices can be handled by an upstream, unpatched Linux kernel.[1)](#fn__1)

There might be a slight decrease in kernel image size, but the general bloat of newer versions will likely eat that up completely.

In case your device was previously on the ar71xx target, see [**Upgrade from ar71xx to ath79**](/docs/guide-user/installation/ar71xx.to.ath79 "docs:guide-user:installation:ar71xx.to.ath79") for instructions.

- See [Latest git commits for this target](https://git.openwrt.org/?p=openwrt%2Fopenwrt.git&a=search&h=HEAD&st=commit&s=ath79%3A "https://git.openwrt.org/?p=openwrt/openwrt.git&a=search&h=HEAD&st=commit&s=ath79:")
- [ath79 status](https://forum.openwrt.org/t/ath79-target-status/18614 "https://forum.openwrt.org/t/ath79-target-status/18614") discussion in the OpenWrt forum
- [Porting guide ar71xx to ath79](https://forum.openwrt.org/t/porting-guide-ar71xx-to-ath79/13013 "https://forum.openwrt.org/t/porting-guide-ar71xx-to-ath79/13013") discussion in the OpenWrt forum

## ar71xx-ath79 transition

Release Target(s) 18.06.x (and earlier) ar71xx only 19.07.x ar71xx + ath79 21.02.x (and later) ath79 only

## Flow offloading

The main page: [Flow offloading](/docs/guide-user/perf_and_log/flow_offloading "docs:guide-user:perf_and_log:flow_offloading").

While ath79 platform does not support hardware offloading, starting from OpenWRT 24.10 you can also enable hardware offloading checkbox for additional reduction of software offload processing requirements and some additional speedup.

User could benefit from OpenWRT's support of Flow offloading (both software and hardware), which significantly increases throughput. It worth to try to enable it:

- If using LuCI: `Network → Firewall` and select “Software flow offloading” or “Hardware flow offloading”, then hit “Save &amp; Apply”.
- CLI: edit `/etc/config/firewall` and insert the following under the config defaults section and make sure to restart the firewall after making the `/etc/init.d/firewall restart`:

```
config defaults
…
  option flow_offloading '1'
  option flow_offloading_hw '1'
```

## Devices with this target

[Filter: Target](#folded_67e9d6e8d0f2934d84d5f8745f62df99_1)

- [ar71xx-ath79(31)](/docs/techref/targets/ath79?dataflt%5B0%5D=target_%3Dar71xx-ath79 "Show pages matching 'ar71xx-ath79'")
- [ath79(528)](/docs/techref/targets/ath79?dataflt%5B0%5D=target_%3Dath79 "Show pages matching 'ath79'")

[Filter: Subtarget](#folded_67e9d6e8d0f2934d84d5f8745f62df99_2)

- [generic(465)](/docs/techref/targets/ath79?dataflt%5B0%5D=subtarget_%3Dgeneric "Show pages matching 'generic'")
- [mikrotik(33)](/docs/techref/targets/ath79?dataflt%5B0%5D=subtarget_%3Dmikrotik "Show pages matching 'mikrotik'")
- [nand(31)](/docs/techref/targets/ath79?dataflt%5B0%5D=subtarget_%3Dnand "Show pages matching 'nand'")
- [tiny(29)](/docs/techref/targets/ath79?dataflt%5B0%5D=subtarget_%3Dtiny "Show pages matching 'tiny'")
- [¿(1)](/docs/techref/targets/ath79?dataflt%5B0%5D=subtarget_%3D%C2%BF "Show pages matching '¿'")

[1)](#fnt__1)

[Ath79 builds with all kmod packages through opkg \[flow offloading\]](https://forum.openwrt.org/t/ath79-builds-with-all-kmod-packages-through-opkg-flow-offloading/15897/126 "https://forum.openwrt.org/t/ath79-builds-with-all-kmod-packages-through-opkg-flow-offloading/15897/126")
