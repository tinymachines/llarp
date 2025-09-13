# Generic flashing over the Serial port

#### Technical references

- [port.serial](/docs/techref/hardware/port.serial "docs:techref:hardware:port.serial")
- Platform *ar71xx* bootloader [*Das U-Boot*](/docs/techref/bootloader/uboot "docs:techref:bootloader:uboot"): [TL-WR1043ND](/toh/tp-link/tl-wr1043nd#installation "toh:tp-link:tl-wr1043nd")

#### Actual procedure

- first, launch a tftp server running on address *192.168.1.234*, serving the openwrt firmware file, renamed to *firm.bin*

```
mkdir -p /tmp/tftp/
cp openwrt-...-factory.bin /tmp/tftp/firm.bin

sudo ip addr add 192.168.1.234/24 dev eth0
sudo dnsmasq -d --port=0 --enable-tftp --tftp-root=/tmp/tftp/
```

- then, on another console, run a serial terminal program (e.g. screen or minicom) set to **115200 8N1**, no flow control

```
screen /dev/ttyUSB0 115200
```

- finally, instruct the bootloader to transfer the *firm.bin* from the tftp server on your computer and save it to RAM memory (0x81000000); then erase *0x7c0000* bytes (7.75 MiB) from the flash (starting at 0xbf020000); finally copy the image stored in RAM to flash

![](/_media/meta/icons/tango/48px-dialog-warning.svg.png?w=20&h=20&tok=dc529c) DO NOT USE THESE VALUES. FIND OUT THE RIGHT ONES! NO, NOT KIDDING.

- 0x7c0000: size of the firmware (be aware that you may have a different size thus bricking your router)
- in GNU-Linux OS distro `Terminal` window, find-out serial port list with below command**:**
  
  - list all serial/TTY devices+ports**:** `ll /sys/class/tty`
  - list serial/TTY devices that have *device/driver* entry**:** `ll /sys/class/tty/*/device/driver`
- in Windows `Command-Prompt` window, find-out serial port list with below command**:**
  
  - list ports &amp; device names**:** `chgport`
  - list all serial ports**:** `reg query HKLM\HARDWARE\DEVICEMAP\SERIALCOMM`
  - list all CON (console), available COM &amp; LPT devices**:** `mode`
- in macOS `Terminal` utility app/window, find-out serial port list with this command**:** `ls /dev/{tty,cu}.*`

Commands:

```
setenv serverip 192.168.1.234
tftpboot 0x81000000 firm.bin
erase 0xbf020000 +0x7c0000
cp.b 0x81000000 0xbf020000 0x7c0000
bootm 0xbf020000
```

To get a rough idea of the process, check [an example serial console log during the whole procedure](/toh/tp-link/tl-wr1043nd/flashlog "toh:tp-link:tl-wr1043nd:flashlog")

#### Kermit

You can use a client using the [Kermit (protocol)](https://en.wikipedia.org/wiki/Kermit%20%28protocol%29 "https://en.wikipedia.org/wiki/Kermit (protocol)") to transfer the new image. It may take forever and a half (15-20min) to copy. But it's easier and more secure than running a [tftpd server](/docs/guide-user/troubleshooting/tftpserver "docs:guide-user:troubleshooting:tftpserver"). These instructions assume you're using a Linux system, but they will give you all you need to do the same on a Windows box.

Requirements:

- terminal program (e.g. minicom) set to **115200 8N1**, no flow control
- file named *code.bin* containing openwrt firmware.
- Kermit client (these instructions will involve using C-Kermit under Linux)

![](/_media/meta/icons/tango/48px-dialog-warning.svg.png?w=20&h=20&tok=dc529c) DO NOT USE THESE VALUES. FIND OUT THE RIGHT ONES! NO, NOT KIDDING.

```
erase 0xbf020000 +7c0000 # 7c0000: size of the firmware (be aware that you may have a different size thus bricking your router)
loadb 0x81000000
```

Fire up C-Kermit and run the following commands (or configure your Kermit client to these parameters):

```
set line /dev/ttyUSB0 # Just make sure you got the right USB interface
set speed 115200
set carrier-watch off
set handshake none
set flow-control none
robust
set file type bin
set file name lit
set rec pack 1000
set send pack 1000
set window 5
send code.bin # Make sure you include a proper path to the file. That's why I just kept it in /home/$user
```

After the 15-20min file transfer, the new firmware should be on your router and you can continue in terminal:

![](/_media/meta/icons/tango/48px-dialog-warning.svg.png?w=20&h=20&tok=dc529c) DO NOT USE THESE VALUES. FIND OUT THE RIGHT ONES! NO, NOT KIDDING.

```
cp.b 0x81000000 0xbf020000 0x7c0000
bootm 0xbf020000
```

Note: This serial transfer method doesn't solve the “chicken or the egg” dilemma (if your Ethernet port is not working on U-Boot) because you cannot use tftpboot to transfer code.bin to u-boot. Fortunately U-Boot supports serial transfer using modem protocol: [http://acassis.wordpress.com/2009/10/23/transfering-file-to-u-boot-over-serial/](http://acassis.wordpress.com/2009/10/23/transfering-file-to-u-boot-over-serial/ "http://acassis.wordpress.com/2009/10/23/transfering-file-to-u-boot-over-serial/")
