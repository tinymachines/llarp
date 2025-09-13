# How to Load Balance OpenWrt

## Introduction

This guide explains about how to manually load balance OpenWrt by fixing IRQs for specific ethernet ports and assigning one or more CPU cores for the networking queues.

## SMP IRQ affinity and bitmask setting

From : [https://www.kernel.org/doc/html/latest/core-api/irq/irq-affinity.html](https://www.kernel.org/doc/html/latest/core-api/irq/irq-affinity.html "https://www.kernel.org/doc/html/latest/core-api/irq/irq-affinity.html")

> /proc/irq/IRQ#/smp\_affinity and /proc/irq/IRQ#/smp\_affinity\_list specify which target CPUs are permitted for a given IRQ source. It’s a bitmask (smp\_affinity) or CPU list (smp\_affinity\_list) of allowed CPUs. It’s not allowed to turn off all CPUs, and if an IRQ controller does not support IRQ affinity then the value will not change from the default of all CPUs.

> /proc/irq/default\_smp\_affinity specifies default affinity mask that applies to all non-active IRQs. Once IRQ is allocated/activated its affinity bitmask will be set to the default mask. It can then be changed as described above. Default mask is 0xffffffff.

To set an IRQ to a specific CPU or group of CPU's requires a bit mask. So using binary we enable each CPU as required and then convert to hex to get the bitmask setting. This way we can restrict IRQs to specific CPUs to aid in load balancing or for heterogeneous SOCs use high/low power cores instead.

**Bitmasks for CPUs**

Binary Hex CPU 00000001 1 0 00000010 2 1 00000011 3 0,1 00000100 4 2 00000101 5 0,2 00000110 6 1,2 00000111 7 0,1,2 00001000 8 3 00001001 9 0,3 00001010 A 1,3 00001011 B 0,1,3 00001100 C 2,3 00001101 D 0,2,3 00001110 E 1,2,3 00001111 F 0,1,2,3 ... ... ... 00110000 30 4,5

## OpenWrt Defaults

OpenWrt routers have set defaults for multi CPU usage.

The following scripts are responsible for setting these up.

```
 cat /etc/hotplug.d/net/20-smp-packet-steering 
```

```
 cat /etc/hotplug.d/net/40-net-smp-affinity 
```

A more automated solution is to use [irqbalance](/docs/guide-user/services/irqbalance "docs:guide-user:services:irqbalance") to help spread the load.

> Irqbalance is a Linux daemon that distributes interrupts over multiple logical CPUs. This design intent being to improve overall performance which can result in a balanced load and power consumption.

However this does not always produce a predictable load distribution. Instead we can use manual tuning to improve load distribution.

## Interrupts

First of all we need to find and identify the interrupts.

In order to monitor settings or changes :

```
cat /proc/interrupts
```

The code below is from an [NanoPi R4S](/toh/friendlyarm/nanopi_r4s_v1 "toh:friendlyarm:nanopi_r4s_v1") which has 4 A53 cores (CPU 0-3) and 2 A72 cores (CPU 4 and 5)

```
root@OpenWrt:~# cat /proc/interrupts
           CPU0       CPU1       CPU2       CPU3       CPU4       CPU5
 23:   27142318   12185540    5391618    2352924  137831569  145154023     GICv3  30 Level     arch_timer
 25:   67873664   61308794   11619382    2662637   16876546   43550490     GICv3 113 Level     rk_timer
 26:          0          0          0          0          0          0  GICv3-23   0 Level     arm-pmu
 27:          0          0          0          0          0          0  GICv3-23   1 Level     arm-pmu
 28:          0          0          0          0          0          0     GICv3  37 Level     ff6d0000.dma-controller
 29:          0          0          0          0          0          0     GICv3  38 Level     ff6d0000.dma-controller
 30:          0          0          0          0          0          0     GICv3  39 Level     ff6e0000.dma-controller
 31:          0          0          0          0          0          0     GICv3  40 Level     ff6e0000.dma-controller
 32:          1          0          0          0          0          0     GICv3  81 Level     pcie-sys
 34:          0          0          0          0          0          0     GICv3  83 Level     pcie-client
 35:          0          0          0          0  165575364          0     GICv3  44 Level     eth0
 36:   20438175          0          0          0          0          0     GICv3  97 Level     dw-mci
 37:          0          0          0          0          0          0     GICv3  58 Level     ehci_hcd:usb1
 38:          0          0          0          0          0          0     GICv3  60 Level     ohci_hcd:usb3
 39:          0          0          0          0          0          0     GICv3  62 Level     ehci_hcd:usb2
 40:          0          0          0          0          0          0     GICv3  64 Level     ohci_hcd:usb4
 42:          0          0          0          0          0          0     GICv3  91 Level     ff110000.i2c
 43:          6          0          0          0          0          0     GICv3  67 Level     ff120000.i2c
 44:          0          0          0          0          0          0     GICv3  68 Level     ff160000.i2c
 45:          6          0          0          0          0          0     GICv3 132 Level     ttyS2
 46:          0          0          0          0          0          0     GICv3 129 Level     rockchip_thermal
 47:    6393498          0          0          0          0          0     GICv3  89 Level     ff3c0000.i2c
 50:          0          0          0          0          0          0     GICv3 147 Level     ff650800.iommu
 52:          0          0          0          0          0          0     GICv3 149 Level     ff660480.iommu
 56:          0          0          0          0          0          0     GICv3 151 Level     ff8f3f00.iommu
 57:          0          0          0          0          0          0     GICv3 150 Level     ff903f00.iommu
 58:          0          0          0          0          0          0     GICv3  75 Level     ff914000.iommu
 59:          0          0          0          0          0          0     GICv3  76 Level     ff924000.iommu
 69:          0          0          0          0          0          0     GICv3  59 Level     rockchip_usb2phy
 70:          0          0          0          0          0          0     GICv3 137 Level     xhci-hcd:usb5
 71:          0          0          0          0          0          0     GICv3 142 Level     xhci-hcd:usb7
 72:          0          0          0          0          0          0  rockchip_gpio_irq  21 Level     rk808
 78:          0          0          0          0          0          0     rk808   5 Edge      RTC alarm
 82:          0          0          0          0          0          0  rockchip_gpio_irq   7 Edge      fe320000.mmc cd
 84:          0          0          0          0          0          0   ITS-MSI   0 Edge      PCIe PME, aerdrv
 85:         10          0          0          0          0          0  rockchip_gpio_irq  10 Level     stmmac-0:01
 86:          0          0          0          0          0          0  rockchip_gpio_irq  22 Edge      gpio-keys
 87:          0          0          0          0          0 1156859750   ITS-MSI 524288 Edge      eth1
IPI0:   7085496   10371429    7027071    6124604     310818     114897       Rescheduling interrupts
IPI1:   2817025    2457651     882759     515246    2752519     543745       Function call interrupts
IPI2:         0          0          0          0          0          0       CPU stop interrupts
IPI3:         0          0          0          0          0          0       CPU stop (for crash dump) interrupts
IPI4:   5558568    4633615    2762056    1122565     763629    3435183       Timer broadcast interrupts
IPI5:    413711     300799     161541     117511     109020      76881       IRQ work interrupts
IPI6:         0          0          0          0          0          0       CPU wake-up interrupts
Err:          0
```

To find the IRQs for your ethernet ports :

```
grep eth /proc/interrupts
```

```
root@OpenWrt:~# grep eth /proc/interrupts
 35:          0          0          0          0  165661665          0     GICv3  44 Level     eth0
 87:          0          0          0          0          0 1157284700   ITS-MSI 524288 Edge      eth1
```

So here eth0 is IRQ 35 and eth1 is 87.

Interrupts can only be set one per core.

Set eth0 interrupt to core 0

```
 echo 1 > /proc/irq/35/smp_affinity 
```

Set eth1 interrupt to core 1

```
 echo 2 > /proc/irq/87/smp_affinity 
```

You could get the IRQ with a command instead of hard coding it:

```
#eth0 IRQ
echo f > /proc/irq/`grep eth0 /proc/interrupts|awk -F ':' '{print $1}'|xargs`/smp_affinity
#eth1 IRQ
echo f > /proc/irq/`grep eth1 /proc/interrupts|awk -F ':' '{print $1}'|xargs`/smp_affinity
```

The grep command prints the line from /proc/interrupts, awk prints the first column which is the IRQ number, and xargs trims the whitespace.

For kernel 5.15 need to use:

```
 echo -n #HEX# > /proc/irq/#IRQ-NUMBER#/smp_affinity 
```

If you restart [Smart Queue Management](/docs/guide-user/network/traffic-shaping/sqm "docs:guide-user:network:traffic-shaping:sqm") or change SQM settings, it will **reset** the CPU affinity and you will **need** to reset your settings or re-apply them.

## Network Queues

Reference: [Receive Packet Steering (RPS)](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/performance_tuning_guide/network-rps "https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/performance_tuning_guide/network-rps")

> Receive Packet Steering (RPS) is similar to RSS in that it is used to direct packets to specific CPUs for processing. However, RPS is implemented at the software level, and helps to prevent the hardware queue of a single network interface card from becoming a bottleneck in network traffic.

Network Queues can be spread across all CPUs if required or fixed to just one.

Set eth0 queue to core 3

```
 echo 4 > /sys/class/net/eth0/queues/rx-0/rps_cpus 
```

Set eth1 queue to core 4

```
 echo 8 > /sys/class/net/eth1/queues/rx-0/rps_cpus 
```

Set eth0 and eth1 to use all 6 cores

```
echo 3f > /sys/class/net/eth0/queues/rx-0/rps_cpus
echo 3f > /sys/class/net/eth1/queues/rx-0/rps_cpus
```

## Making it permanent

Either edit

```
 cat /etc/hotplug.d/net/40-net-smp-affinity 
```

or create your own script to run with your new values and insert that in

```
/etc/hotplug.d/net/
```

to run after the default script.

eg:

```
 /etc/hotplug.d/net/50-mysettings-for-net-smp-affinity 
```

```
#eth0 core 0
echo 1 > /proc/irq/35/smp_affinity

#eth1 core 2
echo 2 > /proc/irq/87/smp_affinity

#queues on all cores
echo 3f > /sys/class/net/eth0/queues/rx-0/rps_cpus
echo 3f > /sys/class/net/eth1/queues/rx-0/rps_cpus
```

Now reboot and check to ensure the settings have taken.

## Notes

**Thanks to the following for discussions/contributions** :

- mercygroundabyss
- moeller0
- walmartshopper
- xShARkx

**Reference threads** :

- [https://forum.openwrt.org/t/load-balancing-smp-irqs/129031](https://forum.openwrt.org/t/load-balancing-smp-irqs/129031 "https://forum.openwrt.org/t/load-balancing-smp-irqs/129031")
- [https://forum.openwrt.org/t/nanopi-r4s-rk3399-4g-is-a-great-new-openwrt-device/79143](https://forum.openwrt.org/t/nanopi-r4s-rk3399-4g-is-a-great-new-openwrt-device/79143 "https://forum.openwrt.org/t/nanopi-r4s-rk3399-4g-is-a-great-new-openwrt-device/79143")
