# Back to original firmware

This page is *very* old and seems specific to “ancient” devices.

Consult the device page for more up-to-date and device-specific information.

There is little point in merely *uninstalling* OpenWrt, what you actually want to do, is to *replace* OpenWrt with the original firmware. You are probably here because the wiki-page for your device does not help you with that. So, first have a look at the [flash.layout](/docs/techref/flash.layout "docs:techref:flash.layout").

To replace OpenWrt with the original firmware, you *most probably* do not have to change the boot partition, or the partition containing specific information like `NVRAM` or `ART`, even if you overwrote the bootloader when you installed OpenWrt on your device.

## via OpenWrt CLI

Only experts with a full and detailed knowledge of their device and tools should ***ever*** write to low-level devices.

Tools such as \`dd\` and the various \`mtd\` and \`nand\` tools can quickly and irrecoverably brick a device permanently.

Non-developers should always use OpenWrt LuCI-based approaches when available.

You can use the program `mtd` for this:

```
cd /tmp
wget http://www.example.org/original_firmware_STRIPPED.bin
mtd -r write /tmp/original_firmware.bin firmware
```

> IMPORTANT: you MUST STRIP the original OEM firmware before using it with mtd, otherwise YOU MAY BRICK YOUR DEVICE

> If you want to remove DD-WRT, you should write to the device “linux” instead of “firmware”. (Tested on TP-Link TL-WR841ND V7):
> 
> ```
> mtd -r write /tmp/original_firmware.bin linux
> ```

> If you are flashing a [Linksys WRT-ACS series](/toh/linksys/wrt_ac_series "toh:linksys:wrt_ac_series"), you should write to the device “kernel1” instead of “firmware”. It is not necessary to convert the vendor-provided .img firmware file (Tested on WRT1900ACSv2):
> 
> ```
> mtd -e kernel1 -r write /tmp/original_firmware.bin linux
> ```

OpenWrt has no built-in “pleasantries” to prevent you from going back to original firmware. But sometimes you need to be careful, see e.g. [Back to original firmware](/toh/tp-link/tl-wr1043nd#back_to_original_firmware "toh:tp-link:tl-wr1043nd").

If you get a error message on the above mtd command like “no valid command given” you are using an old version of mtd which doesn't support the -r or -e parameters.

Download a newer statically compiled version

```
cd /tmp
wget http://www.freewrt.org/downloads/tools/mtd-static
chmod a+x mtd.static
wget http://www.example.org/original.trx
./mtd.static -e linux -r write original.trx linux
```

**TIP:** [PLEASE READ - Common mistakes](http://forum.openwrt.org/viewtopic.php?id=3474 "http://forum.openwrt.org/viewtopic.php?id=3474") thread section 2 also. It describes when you should use the `openwrt-brcm-2.4-squashfs.trx` image.

**Only flash a trx, never flash a bin file?**  
Note: It is no more necessary to cut off the vendor-provided firmware file on [Linksys WRT-ACS series](/toh/linksys/wrt_ac_series "toh:linksys:wrt_ac_series"). If you only have a Linksys `.bin` firmware file, this is not a problem, simply cut off 32 bytes of the header by using the commands below:

```
dd bs=32 skip=1 if=original.bin of=original.trx
```

See also [image.conversion](/docs/techref/hardware/soc/soc.broadcom.bcm47xx/image.conversion "docs:techref:hardware:soc:soc.broadcom.bcm47xx:image.conversion") for more info about .bin to .trx.

**TIP:** If your replacement firmware has a web interface, remember to flush your browser cache, sessions etc. This will avoid misleading 404 errors.

## via OpenWrt WebUI

## via Bootloader

To flash the original firmware back again via the bootloader, please follow the procedures already described in [Installing OpenWrt](/docs/guide-user/installation/generic.flashing "docs:guide-user:installation:generic.flashing"). They are basically the same.
