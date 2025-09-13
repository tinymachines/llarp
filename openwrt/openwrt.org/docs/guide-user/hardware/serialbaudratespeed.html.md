# Change UART serial port speed (baud rate) on OpenWrt

**Related documentation:**

- [port.serial](/docs/techref/hardware/port.serial "docs:techref:hardware:port.serial")
- [uboot.config](/docs/techref/bootloader/uboot.config "docs:techref:bootloader:uboot.config")
- [https://dev.openwrt.org/ticket/1509](https://dev.openwrt.org/ticket/1509 "https://dev.openwrt.org/ticket/1509")

I saw a lot of forum questions asking “how to change serial port speed”, and I thought it was easy, but it is not that easy.

OpenWrt has uart serial port baudrade speed set via kernel command line option, so it is hardwired into kernel, and as far as I know this method is the only way to change baudrate speed of serial port.

## If you are lucky

If you are lucky maybe your kernel supports changing serial port speeds, then you can just try `stty` or `mgetty` commands:

```
mgetty -s 19200 /dev/ttyS0 
```

OR

```
stty -F /dev/ttyS0 9600 clocal cread cs8 -cstopb -parenb 
```

For reading serial port settings use:

```
stty -F /dev/ttyS0 -a 
```

In recent builds, you can easilly install stty from packages as follows:

```
opkg update
opkg install coreutils-stty
```

You will find stty in your menuconfig under

```
Base system -> busybox -> Coreutils -> stty
```

## First method

For example for TP-Link WR741ND V4.x it is set to: “console=ttyATH0,115200”

Now the question is how to change this kernel command line, only way to do this is to compile your own kernel with different “console=” line.

First you need to know which speed you need to set. In this example we use TP-LINK WR741ND which uses has it's uart serial port baudrate speed set to 115200 and we need to change it to 19200.

First check check what baudrate and which port your current router uses, telnet or ssh to your router and then find out your current settings. Usual uart serial ports are `ttyS0` or `ttyATH0`.

Use these command to check your serial port settings

- `fw_printenv`
  
  - baudrate=115200
  - console=console=ttyS0,115200
- OR: `logread | grep tty`
  
  - ...

find where is your config file:

- grep ttyATH0 ./trunk/target/linux/ar71xx/ -R

edit file before [building](/docs/guide-developer/toolchain/start "docs:guide-developer:toolchain:start") your own image:

- ./trunk/target/linux/ar71xx/image/Makefile

find line for your modem:

- tlwr740\_cmdline=board=TL-WR741ND console=ttyS0,115200
- tlwr740v4\_cmdline=board=TL-WR741ND-v4 console=ttyATH0,115200

Change “console=ttyATH0,115200” to speed you need:

- tlwr740\_cmdline=board=TL-WR741ND console=ttyS0,19200
- tlwr740v4\_cmdline=board=TL-WR741ND-v4 console=ttyATH0,19200

## Second method

You can change the Kernel command line within kernel\_menuconfig:

- kernel\_menuconfig &gt; Kernel hacking &gt; Default kernel command string

Then you have to recompile the Kernel with 'make target/clean world' and reflash.

## Forum discussion

[https://forum.openwrt.org/viewtopic.php?id=38419](https://forum.openwrt.org/viewtopic.php?id=38419 "https://forum.openwrt.org/viewtopic.php?id=38419")
