# Irqbalance

Irqbalance is a Linux daemon that distributes interrupts over multiple logical CPUs and is used to improve system performance.

### Installation

To get started [install](/docs/guide-user/additional-software/managing_packages#web_interface "docs:guide-user:additional-software:managing_packages") the package:

```
opkg update && opkg install irqbalance
```

For the LuCI page install: `luci-app-irqbalance`.

This will not be enabled by default. Enable via the LuCI page at Services → irqbalance, or via SSH by setting the enabled line to 1, save and close:

```
nano /etc/config/irqbalance
```

Now start the daemon:

```
/etc/init.d/irqbalance start
```

You're done! Performance should be improved for multi-core targets.

### Advanced Usage

In general, the items below are not necessary for irqbalance to function, however they are used for affinity, interrupt options, and status checks.

To check the status of irqbalance simply use service:

```
service irqbalance
```

To set an IRQ to run on a specific CPU core, use echo to write the CPU mask, as a hexadecimal number, to the smp\_affinity entry of the IRQ. In this example, we are instructing the interrupt with IRQ number 142 to run on CPU0:

```
echo 1 > /proc/irq/124/smp_affinity
```

To set the core affinity use a bitmask, e.g.: 1 = CPU0, 2 = CPU1, 3 = CPU1 and 2.

```
cat /proc/irq/default_smp_affinity
3
```

To monitor the irqbalance load across cores check:

```
cat /proc/interrupts
```

### Caution

Irqbalance will result in performance benefits for multicore targets where there is enough CPU overhead to handle context switching. However on 2core targets, outside of benchmarking alone, there may be performance losses. This can happen if affinity selection is not done strategically (e.g. pinning ethernet to cpu0 and wireless to cpu1). This may result in increased latency or overhead such as with simultaneous users on LAN and WLAN. Irqbalance is more viable on 4core systems and up. See forum discussion [here](https://forum.openwrt.org/t/kong-pro-firmware-for-ipq806x-r7500-r7800-ea8500/55694/395 "https://forum.openwrt.org/t/kong-pro-firmware-for-ipq806x-r7500-r7800-ea8500/55694/395").

### Examples

Below are `/proc/interrupts` outputs for some common targets. Notice that for some targets irqbalance has minimal impact, spending most of its time rescheduling irqs than actually improving performance, with others it has a larger impact with tasks being more spread evenly. Your mileage may vary:

[GL-MT6000](/toh/gl.inet/gl-mt6000 "toh:gl.inet:gl-mt6000"):

```
           CPU0       CPU1       CPU2       CPU3
 11:   16551560   20157052   19935182   23408532     GICv3  30 Level     arch_timer
 24:          0          0          0          0   mt-eint   9 Edge      keys
 61:         13          0          0          0   mt-eint  46 Level     mdio-bus:01
 62:          2          0          0          0   mt-eint  47 Level     mdio-bus:07
 81:        197          0          0          0   mt-eint  66 Level     mt7530
116:         13          0          0          0     GICv3 155 Level     ttyS0
120:        694    3183777          0          0     GICv3 229 Level     15100000.ethernet
121:        898          0          0    6763107     GICv3 230 Level     15100000.ethernet
122:          0          0          0          0     GICv3 142 Level     wdt_bark
123:      14597          0          0          0     GICv3 175 Level     11230000.mmc
124:         65          0          0          0    mt7530   0 Edge      mt7530-0:00
125:         69          0          0          0    mt7530   1 Edge      mt7530-0:01
126:         63          0          0          0    mt7530   2 Edge      mt7530-0:02
127:          0          0          0          0    mt7530   3 Edge      mt7530-0:03
128:     107124          0          0          0     GICv3 205 Level     xhci-hcd:usb1
129:          0          0          0          0     GICv3 148 Level     10320000.crypto
130:          0          0          0          0     GICv3 149 Level     10320000.crypto
131:          0          0          0          0     GICv3 150 Level     10320000.crypto
132:          0          0          0          0     GICv3 151 Level     10320000.crypto
133:  173634407          0          0          0     GICv3 245 Level     mt7915e
IPI0:    288589     266593     276638     313485       Rescheduling interrupts
IPI1:  20552734   87786560   76321777   89129681       Function call interrupts
IPI2:         0          0          0          0       CPU stop interrupts
IPI3:         0          0          0          0       CPU stop (for crash dump) interrupts
IPI4:         0          0          0          0       Timer broadcast interrupts
IPI5:         0          0          0          0       IRQ work interrupts
IPI6:         0          0          0          0       CPU wake-up interrupts
Err:          0
```

[WRT32X](/toh/linksys/wrt_ac_series "toh:linksys:wrt_ac_series"):

```
           CPU0       CPU1       
 17:          0          0     GIC-0  27 Edge      gt
 18:   31286472   45819630     GIC-0  29 Edge      twd
 19:          0          0      MPIC   5 Level     armada_370_xp_per_cpu_tick
 21:   22209654          0     GIC-0  34 Level     mv64xxx_i2c
 22:         21          0     GIC-0  44 Level     ttyS0
 36:   15572107          0      MPIC   8 Level     eth1
 37:    2380424          0      MPIC  12 Level     eth0
 38:       8759          0     GIC-0  50 Level     ehci_hcd:usb1
 39:          0          0     GIC-0  51 Level     f1090000.crypto
 40:          0          0     GIC-0  52 Level     f1090000.crypto
 41:          0          0     GIC-0  58 Level     ahci-mvebu[f10a8000.sata]
 42:      40796          0     GIC-0 116 Level     f10d0000.flash
 43:     211416          0     GIC-0  57 Level     mmc0
 44:     453943          0     GIC-0  49 Level     xhci-hcd:usb2
 45:          2          0     GIC-0  54 Level     f1060800.xor
 46:          2          0     GIC-0  97 Level     f1060900.xor
 47:          0          0  f1018100.gpio  24 Edge      gpio-keys
 48:          0          0  f1018100.gpio  29 Edge      gpio-keys
 49:       1430   22168991     GIC-0  61 Level     mwlwifi
 50:   24566424          0     GIC-0  65 Level     mwlwifi
IPI0:          0          1  CPU wakeup interrupts
IPI1:          0          0  Timer broadcast interrupts
IPI2:    6069090    6516981  Rescheduling interrupts
IPI3:      27303    7712031  Function call interrupts
IPI4:          0          0  CPU stop interrupts
IPI5:          0          0  IRQ work interrupts
IPI6:          0          0  completion interrupts
Err:           0
```

[R7800](/toh/netgear/r7800 "toh:netgear:r7800"):

```
           CPU0       CPU1       
 16:    4855869   10819277     GIC-0  18 Edge      gp_timer
 18:         33          0     GIC-0  51 Edge      qcom_rpm_ack
 19:          0          0     GIC-0  53 Edge      qcom_rpm_err
 20:          0          0     GIC-0  54 Edge      qcom_rpm_wakeup
 29:          0          0     GIC-0 202 Level     adm_dma
 30:   29055904    1445708     GIC-0 255 Level     eth0
 31:   42474368     940190     GIC-0 258 Level     eth1
 32:       8903        628     GIC-0 130 Level     bam_dma
 33:          0          0     GIC-0 128 Level     bam_dma
 34:      31042       2157     GIC-0 136 Level     mmci-pl18x (cmd)
 36:          0          0   PCI-MSI   0 Edge      aerdrv
 38:          0          0   PCI-MSI 134217728 Edge      aerdrv
 39:          7          0     GIC-0 184 Level     msm_serial0
 40:     386087          0     GIC-0 187 Level     1a280000.spi
 41:          1          0   msmgpio  53 Edge      keys
 42:          2          0   msmgpio  54 Edge      keys
 43:          2          0   msmgpio  65 Edge      keys
 44:          0          0     GIC-0 142 Level     xhci-hcd:usb1
 45:     182350      12826     GIC-0 237 Level     xhci-hcd:usb3
 46:    8891000          0   PCI-MSI 524288 Edge      ath10k_pci
 47:   16305129          0   PCI-MSI 134742016 Edge      ath10k_pci
IPI0:          0          0  CPU wakeup interrupts
IPI1:          0          0  Timer broadcast interrupts
IPI2:    1328451    4837561  Rescheduling interrupts
IPI3:       1110   17065108  Function call interrupts
IPI4:          0          0  CPU stop interrupts
IPI5:    5436588    7683214  IRQ work interrupts
IPI6:          0          0  completion interrupts
Err:           0
```

[Raspberry Pi 4](/toh/raspberry_pi_foundation/raspberry_pi "toh:raspberry_pi_foundation:raspberry_pi"):

```
           CPU0       CPU1       CPU2       CPU3
  3:    7646504    8443043    8250258     670362     GICv2  30 Level     arch_timer
 11:     172894          0          0          0     GICv2  65 Level     fe00b880.mailbox
 14:          2          0          0          0     GICv2 153 Level     uart-pl011
 17:       1705          0          0          0     GICv2 114 Level     DMA IRQ
 24:          7          0          0          0     GICv2  66 Level     VCHIQ doorbell
 25:      19817          0     938869          0     GICv2 158 Level     mmc1, mmc0
 31:   16988884          0          0          0     GICv2 189 Level     eth0
 32:       1497   10540404          0          0     GICv2 190 Level     eth0
 38:          0          0          0          0     GICv2 175 Level     PCIe PME, aerdrv
 39:   30845207          0          0          0  BRCM STB PCIe MSI 524288 Edge      xhci_hcd
IPI0:    518033     734978     575403     839272       Rescheduling interrupts
IPI1:     11257    7960888    8129528      11536       Function call interrupts
IPI2:         0          0          0          0       CPU stop interrupts
IPI3:         0          0          0          0       CPU stop (for crash dump) interrupts
IPI4:         0          0          0          0       Timer broadcast interrupts
IPI5:    466242     475458     500626     321304       IRQ work interrupts
IPI6:         0          0          0          0       CPU wake-up interrupts
Err:          0
```

### Notes

1. Man page: [https://linux.die.net/man/1/irqbalance](https://linux.die.net/man/1/irqbalance "https://linux.die.net/man/1/irqbalance")
2. Upstream github: [https://github.com/Irqbalance/irqbalance/](https://github.com/Irqbalance/irqbalance/ "https://github.com/Irqbalance/irqbalance/")
