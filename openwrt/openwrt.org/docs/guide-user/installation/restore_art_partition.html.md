# How to restore ART partition

Backing up your ART data is a wise precaution as it is irreplaceable.

**This procedure does not apply to copying ART data from a current router to another!**

Current routers' ART data are usually specific to the instance of the router and contain calibration data.

While your router may seem to work, it is quite possible that it is operating poorly, potentially out-of-spec.

Out-of-spec operation is often illegal, and can cause interference to other wireless devices, yours and your neighbors.

Note also that the tooling specified is inappropriate for NAND-based routers and may cause further damage, if used.

**Whole procedure was tested on Netgear WNDAP360 and BUFFALO WZR-HP-AG300H**

**Make sure offsets are the same on your partition / device!! (by verifying MAC)**

While playing on my router I managed to break my ART partition.

If the ART partition is wiped or corrupted, ath radios will not come up anymore.

ART partition contains calibration data so if you didn't make a backup of your own then your radios might not perform as well as before (I still think it's better to have radios performing not 100% than not performing at all :) ).

## Prerequisite

Well, ideal situation is when you have backed up your ART partition, this is easy to do in OpenWrt and at least some stock firmwares which you can access via console and are linux based. On device find art partition:

```
cat /proc/mtd
```

Look for art or ART (Let's say for me it is mtd5) Then make a dump:

```
dd if=/dev/mtd5 of=/tmp/art.backup
```

Copy this dump to your PC (via SSH or some other way)

If you have your own backup, move section 'Flashing ART partition' if not.. well you will need some luck and a bit more work.

## Modifying MAC on art partition

Considering that you didn't make a backup of your own ART partition, you need to get art partition from someone that has same device as you (I didn't try with art from different models). Since MAC is saved on this partition you will have to modify it, thing to keep in mind while doing this is the fact that checksum of some sections of partition need to be 0xffff (according to ath9k driver), if checksum is wrong radios will not come up.

On your PC open a art partition dump file (let's call it art.backup) in your favorite HEX editor (I used ghex).

Since my device has two radios, it has two macs and two checksums, to change mac:

Go to offset 0x120c for radio0 (2.4Ghz in my case) and change mac to yours (make sure you don't change more bytes!).

Go to offset 0x520c for radio1 (5Ghz in my case) and change mac to yours (I added 1 to mac from 2.4Ghz)(make sure you don't change more bytes!).

Now, you need to erase checksum bytes, go to offset 0x1202 (for radio0) and erase two bytes (so insert 'FF FF'), go to offset 0x5202 and do the same.

Now, save file, flash it into your ART partition (Refer to the next section for information how to do it).

Boot your box, wifi interfaces will not come up as their checksum is wrong, there will be two messages about this like: 'Bad EEPROM checksum: 0xad22' (on console and dmesg / logread)

Note the checksum values for both radios.

Now, back to hex editor, go to offset 0x1202 (radio0) and put two bytes from above message (so in this case 'AD 22'), go to offset 0x5202 and do the same for radio1 accordingly.

Save, flash to router, enjoy working WiFi with correct MAC.

## Flashing ART partition back

This can be flashed from OS level (if partition is NOT readonly).

If it is readonly you can:

- get or build package **kmod-mtd-rw** and enable mtd writing temporarly with command “insmod mtd-rw.ko i\_want\_a\_brick=1”
- or re-define this in OpenWrt source and re-compile kernel
- or via uboot.

### Flashing via OpenWrt

This is simple enough, you need to place your art partition dump into /tmp, and then:

```
mtd -r write /tmp/art.backup art
```

Above command will perform reboot after flashing, this is needed.

If on the other hand your partition is read-only and you have no console you have to make it RW my changing it's definition in images/Makefile than recompile and put new image on your device. Also you can use kernel module to write ART without recompiling, see **kmod-mtd-rw**. After you fixed your art partition I **HIGHLY** advice to put a proper image back (with art partition as read-only)

### Flashing via uBoot

**IMPORTANT** If you make mistake here you might BRICK your device for good!!

If you have working console and your partition in read-only (I guess in most cases) you might prefer to do this, exact steps might vary per router but overall guide is:

**Before you begin** Make sure where you know where your art partition starts, refer to your dmesg / logread you will see entries like this:

```
0x000000000000-0x000000040000 : "u-boot"
0x000000040000-0x000000050000 : "u-boot-env"
0x000000050000-0x000000200000 : "kernel"
0x000000200000-0x0000007f0000 : "rootfs"
0x0000003f0000-0x0000007f0000 : "rootfs_data"
0x0000007f0000-0x000000800000 : "art"
0x000000050000-0x0000007f0000 : "firmware"
```

So in my case art starts here: 0x0000007f0000 which on my platform (Atheros - AR7161) in uboot translates to:

```
0xbf7f0000
```

**For this you need a working TFTP server with static address that your uboot has configured as serverip (check this with command 'printenv' in uboot**

Check what is your memory starting address:

```
bdinfo
```

Let's say for me it is:

```
0x80000000
```

Now, let's download image to memory:

```
ar7100> tftpboot 0x80000000 art.backup
Trying eth0
Using eth0 device
TFTP from server 192.168.1.1; our IP address is 192.168.1.2
Filename 'art.backup'.
Load address: 0x8000000
Loading: #################################################################
done
Bytes transferred = 65536 (10000 hex) 
```

In above output the size of file you downloaded: 10000 hex

When above is done you need to erase what ever is left on your art partition (Note partition starting address from your partition layout as above) be sure to set correct amount/size from above, just prefix it with +0x:

```
erase 0xbf7f0000 +0x10000
```

Now, let's copy from memory to flash (basically: cp.b &lt;from where in memory&gt; &lt;to where on flash&gt; &lt;how much - use same size as above but without +):

```
cp.b 0x8000000 0xbf7f0000 0x10000
```

And you're done! :)
