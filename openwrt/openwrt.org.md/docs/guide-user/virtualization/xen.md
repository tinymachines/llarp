# OpenWrt as a Xen DomU guest

This documents describes how to run the OpenWrt x86 port as a Xen domU guest.

## Prerequisites

- A Xen dom0 host
- An OpenWrt/LEDE image with Xen domU support

## Get pre-built OpenWrt/LEDE images

For OpenWrt Chaos Calmer, there is a specific subtarget: [https://archive.openwrt.org/chaos\_calmer/15.05.1/x86/xen\_domu/](https://archive.openwrt.org/chaos_calmer/15.05.1/x86/xen_domu/ "https://archive.openwrt.org/chaos_calmer/15.05.1/x86/xen_domu/")

For LEDE 17.01, Xen domU support is directly included in the generic x86 image: [http://downloads.lede-project.org/releases/17.01.1/targets/x86/generic/](http://downloads.lede-project.org/releases/17.01.1/targets/x86/generic/ "http://downloads.lede-project.org/releases/17.01.1/targets/x86/generic/")

In both cases, you need either the `“combined-ext4.img.gz”` image, or the `“vmlinuz”` file containing the kernel + the `“rootfs-ext4.img.gz”` image.

Then extract the image:

```
gunzip *-ext4.img.gz
```

## Configure Xen

On the dom0 guest, create a domain configuration file, `Xen-OpenWrt.conf`, with the following contents:

```
name = "owrt"
vcpus = 2
memory = 256

bootloader = "/usr/lib/xen-4.4/bin/pygrub"
disk = ['file:/etc/xen/openwrt-15.05.1-x86-xen_domu-combined-ext4.img,xvda,w']

on_reboot = 'restart'
on_crash = 'destroy'
```

This method uses `pygrub` to find the grub config on the ext4 image. If for some reason you cannot use `pygrub`, use an external kernel:

```
# Alternative that uses a separate kernel + rootfs (no need for pygrub)

name = "owrt"
vcpus = 2
memory = 256

disk = ['file:/etc/xen/openwrt-15.05.1-x86-xen_domu-rootfs-ext4.img,xvda,w']
kernel = "openwrt-15.05.1-x86-xen_domu-vmlinuz"
root = "/dev/xvda rw"

on_reboot = 'restart'
on_crash = 'destroy'
```

## Configure networking

There exist many ways to configure networking within Xen. The technique that this document describes bridges between the dom0 guest's physical interface and a virtual interface that connects to the domU guest. This results in the domU guest receiving a connection on the same network as the dom0 guest.

We will create two bridges, one for LAN and one for WAN. The WAN of the OpenWrt domU will be bridged to the physical interface of the dom0 (to get access to the internet), while the LAN will only be accessible from the dom0 itself.

```
brctl addbr owrt-lan
ip link set owrt-lan up
ip addr add 192.168.1.42/24 dev owrt-lan

brctl addbr owrt-wan
ip link set dev eth0 up
brctl addif owrt-wan eth0
ip link set owrt-wan up
```

Ensure the device eth0 does not have an IP address because it is bridged to `owrt-wan`. If you need access to the Internet from the dom0, obtain an IP address using `dhclient owrt-wan` or assign a static IP address.

Finally, add the following configuration to the Xen domain configuration file:

```
vif = [ "mac=00:16:3e:12:34:56,bridge=owrt-lan",
        "mac=00:16:3e:78:9a:bc,bridge=owrt-wan" ]
```

## Run the domU

To run the domU with a serial console:

```
xl create -c Xen-OpenWrt.conf
```

or, depending on your toolstack:

```
xm create -c Xen-OpenWrt.conf
```

The OpenWrt domU should automatically use the first (virtual) interface as LAN and the second one as WAN.

You should be able to reach your virtual router through SSH at `192.168.1.1`, or using IPv6:

```
ping6 -L -I owrt-lan ff02::1
ssh root@fe80::XX%owrt-lan    # replace fe80::XX by the address given by the ping
```
