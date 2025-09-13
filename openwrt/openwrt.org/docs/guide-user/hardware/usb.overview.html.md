# Turning USB power on and off

On some routers, it is possible to turn USB power on and off using [GPIO](/docs/techref/hardware/port.gpio "docs:techref:hardware:port.gpio"), like this:

On:

```
echo 1 > /sys/class/gpio/gpioN/value
```

Off:

```
echo 0 > /sys/class/gpio/gpioN/value
```

Get current state:

```
cat /sys/class/gpio/gpioN/value
```

Here, `N` should be replaced with pin number, which depends on router model. Here are some known pin numbers:

Model Pin number(s) [TP-Link TL-WR703N](/toh/tp-link/tl-wr703n "toh:tp-link:tl-wr703n") 8 [TP-Link TL-WR842ND](/toh/tp-link/tl-wr842nd "toh:tp-link:tl-wr842nd") 6 (v1), 4 (v2) [TP-Link TL-WDR3600](/toh/tp-link/tl-wdr3600_v1 "toh:tp-link:tl-wdr3600_v1") 21, 22 [TP-Link TL-WDR4300](/toh/tp-link/tl-wdr4300_v1 "toh:tp-link:tl-wdr4300_v1") 21, 22 [TP-Link TL-WR1043ND](/toh/tp-link/tl-wr1043nd "toh:tp-link:tl-wr1043nd") 21 (v2), 8 (v3, v4) [TP-Link Archer C2600](/toh/tp-link/archer_c2600_v1 "toh:tp-link:archer_c2600_v1") V1.1 23, 25 [Astoria networks ARV7510PW22](/toh/astoria/arv7510pw22 "toh:astoria:arv7510pw22") 8

If your model is not listed, you may try to find `N` by trial and error. For some `N`, the directory `/sys/class/gpio/gpioN` might not exist, in this case it can be created like this:

```
echo N > /sys/class/gpio/export
```

You may also look at [this forum thread](https://forum.openwrt.org/viewtopic.php?id=44909 "https://forum.openwrt.org/viewtopic.php?id=44909").

![:!:](/lib/images/smileys/exclaim.svg) Some routers might have difficulties providing full USB power output.

![:!:](/lib/images/smileys/exclaim.svg) On a TP-Link Archer A7 v5 running OpenWRT 19.07, the USB power can be switched by echoing 1 or 0 to `/sys/class/gpio/tp-link:power:usb/value`. This may be true of other models as well. Run `ls -al /sys/class/gpio/` to check for the existence of a similar predefined symbolic link on your router.

![:!:](/lib/images/smileys/exclaim.svg) On D-Link DIR-645 running OpenWrt 21.2.1 the USB power can be switched off using `echo 0 > /sys/class/gpio/usb/value`
