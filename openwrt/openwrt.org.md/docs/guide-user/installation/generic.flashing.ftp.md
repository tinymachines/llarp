# Installing OpenWrt over FTP (generic)

Go back to [generic.flashing](/docs/guide-user/installation/generic.flashing "docs:guide-user:installation:generic.flashing")

**Warning!**  
This section describes actions that might damage your device or firmware. Proceed with care!

## Bootloader contains FTP server

One example of a bootloader containing a FTP-server is the [ADAM2/EVA](/docs/techref/bootloader/adam2 "docs:techref:bootloader:adam2")-bootloader, used by Texas Instruments hardware. One device, regarding to which this howto is written, is the [AVM FRITZ!Box Fon WLAN 7570](/toh/avm/fritz.box.wlan.7570 "toh:avm:fritz.box.wlan.7570"). No, this is not supported by OpenWrt, and probably will never be!

Said box has the default IP address of 192.168.1.1, but the bootloader has a different default IP address: 192.168.178.1. Since we connect to the bootloader, and not to the firmware, this is the one relevant here.

1. give your PC a static IP address out of 192.168.178.1/24, besides the 1, e.g. use `192.168.178.2`
2. install a FTP-client software, e.g. the standard POSIX ftp-client
3. place the files you want to upload to the router in some directory, e.g. `~/images` and change into that directory `cd ~/image`
4. connect your PC with a LAN-Port of the Router
5. power cycle the router and after about 3 seconds enter the following:
   
   ```
   ftp -n 192.168.178.1
   ```
   
   (read [ftp](http://man.cx/ftp "http://man.cx/ftp") for the meaning of the `-n`.
6. once successfully connected to the bootloader, you will be asked for *username* and *password*. In this case *username* is `adam2` and the *password* is also `adam2`. Enter them as prompted and then issue the following commands:
   
   ```
   binary
   debug
   passive
   quote MEDIA FLSH
   put empty.file mtd3
   put empty.file mtd4
   put kernel.image mtd1
   reboot
   ```
   
   (On the AVM FRITZ!Box Fon WLAN 7170 the last command must be replaced by `quote REBOOT`.)

The \`passive\` command above is only relevant for older clients. Newer clients use the passive mode by default.

Depending on what firmware you install, it may be necessary to additionally change a certain parameter in the bootloader environment:

```
quote SETENV firmware_version "hansenet"
```

**`Note0:`** In case of the AVM/Fritz! with EVA-bootloader, at least on the 7360, do `not` change the environment-variable firmware-version. Doing so makes the ethernet interface fail (only access is via the console), some of the AVM-daemons crash and after 160 seconds the hardware watchdog kicks in, causing the box to reboot over and over. At least on the international version of the 7360, the correct value is

```
Eva_AVM >setenv firmware_version avme
Eva_AVM >restart
```

**`Note1:`** In case of the EVA-bootloader, do not issue any other commands. This bootloader is broken by design, if you issue some harmless command like say `quote GETENV firmware_version`, the upload process will not function any longer afterwards. You would need to disconnect from it, and connect again, and then try again. Such quirks are not very common, and thus a major PITA if you do not know about them. When using unmaintained and sloppily programed closed source software, like EVA, you really should expect anything ![;-)](/lib/images/smileys/wink.svg)

**`Note2:`** the files `empty.file` and `kernel.image` are the ones located in `~/images`. In order for the FTP client to find them, you need to change into that directory either before starting the FTP client or after that by issuing `lcd ~/image` into the ftp-client.

**`Note3:`** should you decide to use `ncftp` instead of `ftp`, you need to connect with `ncftp -u adam2 192.168.178.1`. That is why, you should read the manpage for the software you are employing!

**`Note4:`** You can use a python flash script from “Freifunk Darmstadt” - a german non-commercial initiative for free wireless networks - to flash AVM devices. [flashing instruction](https://fritz-tools.readthedocs.io/en/latest/flashing/ubuntu_1804.html "https://fritz-tools.readthedocs.io/en/latest/flashing/ubuntu_1804.html") [direct download python script](https://raw.githubusercontent.com/freifunk-darmstadt/fritz-tools/master/fritzflash.py "https://raw.githubusercontent.com/freifunk-darmstadt/fritz-tools/master/fritzflash.py")

### Examples

- [D-Link DSL-5xxT and DSL-G6xxT - ADAM2 Installation Guide](/toh/d-link/dsl-5xxt-6xxt-adam2 "toh:d-link:dsl-5xxt-6xxt-adam2")

## Bootloader contains FTP client

TODO
