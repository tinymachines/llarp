# IVG-HP203Y-AY

This board consist of Hi3516cv300 CPU and Sony IMX291 chip. Can be bought on [AliExpress](https://aliexpress.com/item/32980521726.html "https://aliexpress.com/item/32980521726.html") or other marketplaces.

This instruction is based on the information from [OpenIPC project](https://openipc.org/firmware/ "https://openipc.org/firmware/") and with the help of it's community.

**Currently not supported:**

\* Night mode (based on IR sensor and IR curtain shutter)

## Prepare TFTP server

Download and put all the binaries in the TFTP folder:

[openwrt-hi35xx-16cv300-u-boot.bin](https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-16cv300-u-boot.bin "https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-16cv300-u-boot.bin")

[openwrt-hi35xx-16cv300-default-uImage](https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-16cv300-default-uImage "https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-16cv300-default-uImage")

[openwrt-hi35xx-16cv300-default-root.squashfs](https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-16cv300-default-root.squashfs "https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-16cv300-default-root.squashfs")

### Connect using UART

Currently it is not possible to flash the board without UART access. Connect the UART terminal to the board.

## Get access to U-boot

Poweroff and turn on the board.

Press Ctrl+C in U-boot start

### Backup

\* From here on we will assume that the device will have 192.168.1.10 and TFTP server 192.168.1.254

Execute the following code in Uboot:

```
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0
mw.b 0x82000000 ff 2000000
sf read 0x82000000 0x0 0x2000000
tftp 0x82000000 fullflash.img 0x2000000
```

Check that TFTP server received the backup image.

NB! As the next step is important it is advised to run below mentioned commands in order they are grouped.

Also check that all binary images are downloaded successfully via TFTP.

Upon successful download there will be information of actually downloaded bytes. Example:

```
Downloading: #################################################
done
Bytes transferred = 3967018 (3c882a hex)
```

## Commands to be run in Uboot environment

```
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0; sf lock 0

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv300-u-boot.bin
sf erase 0x0 0x50000
sf write 0x82000000 0x0 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv300-default-uImage
sf erase 0x50000 0x200000
sf write 0x82000000 0x50000 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv300-default-root.squashfs
sf erase 0x250000 0x500000
sf write 0x82000000 0x250000 ${filesize}
```

## Commands after installation

### Clean u-boot env

```
flash_eraseall /dev/mtd1
reboot
```

#### Clean overlayfs

```
firstboot
reboot
```

#### Format overlayfs partition

```
flash_eraseall -j /dev/mtd4
reboot
```

#### Change MAC and other stuff

Change XX:XX:XX:XX:XX:XX for your original MAC address you wrote in the beginning.

```
fw_setenv ethaddr XX:XX:XX:XX:XX:XX
uci set network.lan.macaddr=XX:XX:XX:XX:XX:XX
fw_setenv sensor imx291_i2c_lvds
uci set ipcam.gpio.ircut1='53'
uci set ipcam.gpio.ircut2='54'
uci commit
reboot
```
