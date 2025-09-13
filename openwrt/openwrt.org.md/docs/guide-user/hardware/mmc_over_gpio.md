# MMC/SD card over GPIO howto

This is a short guide to get an MMC/SD card working with OpenWrt Kamikaze 8.09 and an 2.6 Kernel. The driver can be configured using either UCI CLI or the LuCI WebUI.

## GPIO Pinouts

```
Description                GPIO
------------------------------------
PIN 1, CS - Chip Select    GPIO 7
PIN 2, DI - Data In        GPIO 1
PIN 3, VSS - Ground        GND
PIN 4, VDD - 3.3 Volts     3.3 Volts
PIN 5, CLK - Clock         GPIO 3
PIN 7, DO - Data Out       GPIO 4
```

## GPIO Solder Points

Images from PCB.

## Configuration using UCI CLI

### Install packages

Required packages:

- kmod-mmc-over-gpio
- kmod-fs-ext4/kmod-fs-vfat/.... (we use the EXT3 file system here)
- cfdisk/fdisk (we use cfdisk here)
- e2fsprogs (for formating SD card to EXT3)

```
opkg update
opkg install kmod-mmc-over-gpio kmod-fs-ext4 cfdisk e2fsprogs kmod-nls-base kmod-nls-cp437 kmod-nls-iso8859-1
```

Nice to have packages:

- blkid

```
opkg install blkid
```

### Configure GPIOs

```
uci set mmc_over_gpio.@mmc_over_gpio[0].enabled=1
uci set mmc_over_gpio.@mmc_over_gpio[0].DI_pin=1
uci set mmc_over_gpio.@mmc_over_gpio[0].DO_pin=4
uci set mmc_over_gpio.@mmc_over_gpio[0].CLK_pin=3
uci set mmc_over_gpio.@mmc_over_gpio[0].CS_pin=7
uci commit mmc_over_gpio
/etc/init.d/mmc_over_gpio enable
/etc/init.d/mmc_over_gpio start
```

If you ger an error saying “can't create /config/gpiommc/ directory” then first reboot the device.

### Mount the MMC/SD card via fstab

To get partition mounted automatically you have to edit and change START=20 to START=98 in the /etc/init.d/fstab init script.

```
uci add fstab mount
uci set fstab.@mount[0].enabled=1
uci set fstab.@mount[0].fstype=ext3
uci set fstab.@mount[0].device=/dev/mmcblk0p1
uci set fstab.@mount[0].target=/mnt/mmc
uci set fstab.@mount[0].options=rw,sync,noatime
uci commit fstab
/etc/init.d/fstab restart
```
