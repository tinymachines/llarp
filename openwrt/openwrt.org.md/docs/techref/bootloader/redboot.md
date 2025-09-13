# RedBoot

[RedBoot](https://en.wikipedia.org/wiki/RedBoot "https://en.wikipedia.org/wiki/RedBoot") is an open source application that uses the [eCos](https://en.wikipedia.org/wiki/eCos "https://en.wikipedia.org/wiki/eCos") real-time operating system Hardware Abstraction Layer to provide bootstrap firmware for embedded systems.

RedBoot allows download and execution of embedded applications via serial or Ethernet, including embedded Linux and eCos applications. It provides debug support in conjunction with GDB to allow development and debugging of embedded applications. It also provides an interactive command line interface to allow management of the Flash images, image download, RedBoot configuration, etc., accessible via serial or ethernet. For unattended or automated startup, boot scripts can be stored in Flash allowing for example loading of images from Flash, hard disk, or a TFTP server.

It is FOSS and has an [online manual](http://sources.redhat.com/ecos/docs-latest/redboot/redboot-guide.html "http://sources.redhat.com/ecos/docs-latest/redboot/redboot-guide.html").

## Available Patches

If somebody writes a patche for the bootloader implementation of a particular device, you will find links to this on the wiki-page for that device. Yet we additionally accumulate all the patches wrote for a particular bootloader on his own page. Hopefully you can get a better comprehension of the functionality of the bootloader by having a look at them.

- [REDBOOT-sourcecode-blue5g.tar.gz](https://drive.google.com/uc?export=download&id=0B-EMoBe-_OdBa1BNajBvaGhEZU0 "https://drive.google.com/uc?export=download&id=0B-EMoBe-_OdBa1BNajBvaGhEZU0") : BCM6348 modded Redboot

## Configuration

The RedBoot configuration is stored as ordered pairs in an mtd block.

### Within OpenWrt

The fconfig package can read from and write to the RedBoot. To determine which block to use, look at the output of

```
dmesg
```

or

```
cat /proc/mtd
```

, or listing each block with

```
fconfig
```

, e.g.

```
fconfig -l -d /dev/mtdX
```

. The configuration has either a magic number or a checksum, so provided the mtd block has already been initialized, the command will only work on a block with a RedBoot configuration.

To list all ordered pairs, use this:

```
fconfig -l -d /dev/mtdX
```

To read a single ordered pair, use this:

```
fconfig -r -d /dev/mtd3 -n bootp
```

To write an ordered pair, do this:

```
fconfig -w -d /dev/mtd3 -n bootp -x TRUE
```

Caveat:

```
mtd
```

and the library it uses might not let you write to that mtd device. The lock is a software lock, implemented to prevent the mtd block following the RedBoot config from being erased as [the config spans only a partial flash erase block](http://forum.openwrt.org/viewtopic.php?pid=72704#p72704 "http://forum.openwrt.org/viewtopic.php?pid=72704#p72704"). There is a patch that removes this limitation, but it requires replacing the kernel.

The

```
-v
```

flag increased verbosity.

**Warning:** for some (maybe all?) devices, */dev/mtdblockX* needs to be used in the commands above instead of */dev/mtdX*, especially when changing RedBoot configuration. The reason is that “the mtd device can only be used by nand/nor aware tools/filesystems. Otherwise you can only flip ones to zero and not the other way around” as it was explained in [this ticket](https://dev.openwrt.org/ticket/7530 "https://dev.openwrt.org/ticket/7530"). It's strongly recommended to create a backup of the RedBoot configuration partition before making any changes with the fconfig tool. In case the configuration is broken already without any backups it's vital to know that RedBoot usually defaults to ask for an IP address through BOOTP. This IP address might be looked up easily on the BOOTP server using the device's MAC address. Connecting to this IP on port 9000 using a telnet client should help to gain access to the RedBoot shell and recover the configuration.

### Within RedBoot

RedBoot, itself, also uses the

```
fconfig
```

command, albeit a bit differently.

```
RedBoot> fconfig    //Press enter//
Run script at boot: true    //Press enter//
Boot script:
.. fis load -l vmlinux.bin.l7
.. exec
Enter script, terminate with empty line
>> fis load -l linux    //Enter command and press enter//
>> exec    //Enter command and press enter//
>>    //Press enter//
Boot script timeout (1000ms resolution): 10    //Press enter//
Use BOOTP for network configuration: false    //Press enter//
Gateway IP address:    //Press enter//
Local IP address: 192.168.1.254    //Press enter//
Local IP address mask: 255.255.255.0    //Press enter//
Default server IP address:    //Press enter//
Console baud rate: 9600    //Press enter//
GDB connection port: 9000    //Press enter//
Force console for special debug messages: false    //Press enter//
Network debug at boot time: false    //Press enter//
Update RedBoot non-volatile configuration - continue (y/n)? y    //Enter 'y' and press enter//
… Erase from 0xa87e0000-0xa87f0000: .
… Program from 0×80ff0000-0×81000000 at 0xa87e0000: .
```

### Configuration variables

I'm guessing, here.

value description reasonable setting boot\_script Use a boot script to boot the device? true boot\_script\_data The script .. fis load -l vmlinux.bin.l7 .. exec boot\_script\_timeout How long to wait before booting; boot\_wait 3 bootp Obtain an IP address from bootp? false bootp\_my\_gateway\_ip 0.0.0.0 bootp\_my\_ip IP address to listen on for telnet connections? 192.168.1.1 bootp\_my\_ip\_mask Subnet mask of above address 255.255.255.0 bootp\_server\_ip 0.0.0.0 console\_baud\_rate Baud rate of the serial console 9600 gdb\_port Port to listen on for a telnet connection 9000 info\_console\_force false net\_debug false

```
fconfig boot_script true
fconfig boot_script_timeout 10
fconfig bootp false
fconfig bootp_my_gateway_ip 192.168.1.1
fconfig bootp_my_ip 192.168.1.1
fconfig bootp_my_ip_mask 255.255.255.0
fconfig bootp_server_ip 192.168.1.254
fconfig console_baud_rate 9600
fconfig gdb_port 9000
fconfig info_console_force false
fconfig net_debug false
```

## Connecting to RedBoot

RedBoot supports an internal serial connection and telnet sessions, though telnet sessions aren't always enabled (see above sections for how to enable it).

The default telnet login seems to be 192.168.1.254:9000, and serial connections might use 9600 baud, 8 bit, no parity, no flow control.

For both telnet and serial, reset the device. RedBoot needs to receive Ctrl+c to pause the boot process. For telnet connections, once a connection is established following the reset (a few seconds), hit Ctrl+c. For serial connections, hit Ctrl+c until you see this:

```
== Executing boot script in 8.530 seconds - enter ^C to abort
^C
RedBoot>
```

- [dir-300](/toh/d-link/dir-300 "toh:d-link:dir-300")
