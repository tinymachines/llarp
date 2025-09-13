# OpenWrt image conversion

If you wish to upgrade your firmware from OpenWrt without resetting to stock first then you might get:

```
The uploaded image file does not contain a supported format. Make sure that you choose the generic image format for your platform.
```

`.bin` files are for flashing from a stock firmware. `.trx` files are for flashing from OpenWrt. To convert from `.bin` to `.trx`, strip the 32-byte header from the `.bin` file:

```
dd if=openwrt-10.03.1-brcm47xx-wrt150n-squashfs.bin bs=32 skip=1 of=openwrt-10.03.1-brcm47xx-wrt150n-squashfs.trx
```

IMPORTANT: Verify that the output file is only 32 bytes smaller than the input file and that the `.trx` file begins with `HDR0`:

```
hd /tmp/openwrt-10.03.1-brcm47xx-wrt150n-squashfs.trx | head
```

NOTE: However, the `.trx` file that is offered for download is identical to the file that you produce with `dd`, so use the official `.trx` instead of this method if possible!

## Devices

The list of related devices: [bcm47xx](/tag/bcm47xx?do=showtag&tag=bcm47xx "tag:bcm47xx")
