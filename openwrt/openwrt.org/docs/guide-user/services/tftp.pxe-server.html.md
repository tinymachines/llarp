The word NetBoot can be applied to multiple concepts, see [netboot\_pointers](/inbox/howto/netboot_pointers "inbox:howto:netboot_pointers"). This manual outlines how to use an external USB storage media on the OpenWRT router to serve boot images and a NFS root partition for a (presumably) diskless client. There is a simplified instruction on how to fix the OpenWRT router to serve a boot image on [Setting up OpenWRT to serve Archlinux NetBoot](/inbox/howto/setting_up_openwrt_to_serve_archlinux_netboot "inbox:howto:setting_up_openwrt_to_serve_archlinux_netboot")

# PXE-Boot network boot server

You can use your OpenWrt device as a PXE-Server to store network boot images for booting other devices over the network. Possibilities:

- Boot Ubuntu / Debian / CentOS Live Systems
- Install any Linux Distrib. or Windows (via winpe) over network
- Boot debugging tools like knoppix / gparted / clonezilla / backtrack
- boot a Windows image prepared for network boot (not described in this tutorial)

The following example shows how to provide PXE-Booting for Ubuntu Live System on an OpenWrt Router.

Basic idea:

- Connect USB Mass Storage to router to store PXE-Boot files and Live Images
- use dnsmasq service for dhcp &amp; tftp readonly booting
- use nfs for further service booting (required by e.g. ubuntu)

Booting other Linux based distributions is not very different, only the boot parameters differ and can be found everywhere on the internet.

The following instructions have been done step-by-step on an OpenWrt Attitude Adjustment 12.09 on a [tl-wdr3600\_v1](/toh/tp-link/tl-wdr3600_v1 "toh:tp-link:tl-wdr3600_v1")on 6th of December 2013

## 1. Install Mass Storage

Note: you can also check [usb-drives-quickstart](/docs/guide-user/storage/usb-drives-quickstart "docs:guide-user:storage:usb-drives-quickstart")

Install USB-Support (you may also need to install a filesystem module like \`kmod-fs-vfat\`)

```
root@OpenWrt:~# opkg install usbutils kmod-usb-storage  block-mount
```

Show connected USB-Devices

```
root@OpenWrt:~# lsusb
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 002: ID 05e3:0608 Genesys Logic, Inc. USB-2.0 4-Port HUB
Bus 001 Device 003: ID 0951:1600 Kingston Technology DataTraveler G3 4GB
```

Verify the USB-device in /dev

We assume that the USB-device is plugged in and has been formatted to FAT32 or EXT2,3

If you have a NTFS filesystem please install NTFS support: opkg install ntfs-3g For more information on NTFS see [writable\_ntfs](/docs/guide-user/storage/writable_ntfs "docs:guide-user:storage:writable_ntfs")

```
root@OpenWrt:~# ls -l /dev/sd*
brw-r--r--    1 root    root        8,   0 Jan  1  1970 /dev/sda
brw-r--r--    1 root    root        8,   1 Dec  6 17:52 /dev/sda1
```

Create mountpoint for usbdevice

```
root@OpenWrt:~# mkdir /mnt/extstorage
```

Enable automatic mounting of external USB Storage. For additional Information see [fstab](/docs/guide-user/storage/fstab "docs:guide-user:storage:fstab")

```
root@OpenWrt:~# vim /etc/config/fstab
config global automount
        option from_fstab 1
        option anon_mount 1

config global autoswap
        option from_fstab 1
        option anon_swap 0

config mount
        option target   /mnt/extstorage
        option device   /dev/sda1
        option enabled  1
        option enabled_fsck 0
```

Now enable start of fstab-service on boot of OpenWrt

```
root@OpenWrt:~# /etc/init.d/fstab enable
```

Start fstab this time manually

```
root@OpenWrt:~# /etc/init.d/fstab start
```

Verify that the USB Mass Storage /dev/sda1 is mounted to /mnt/extstorage

```
root@OpenWrt:~# mount | grep extstorage
/dev/sda1 on /mnt/extstorage type fuseblk (rw,relatime,user_id=0,group_id=0,allow_other,blksize=4096)
```

For testing purposes, touch a file on the usb-stick and reboot OpenWrt router:

```
root@OpenWrt:~# touch /mnt/extstorage/test.txt
root@OpenWrt:~# reboot
```

After the reboot you should be able to verify again that the USB Mass Storage is mounted to /mnt/extstorage and that the test.txt exists.

## 2. Prepare files for PXE-Booting

Generate TFTP-Boot folder structure and files:

```
root@OpenWrt:~# cd /mnt/extstorage
root@OpenWrt:~# mkdir tftp tftp/pxelinux.cfg tftp/disks tftp/disks/ubuntu1604-64
```

Now you have to download syslinux. Download [Syslinux](https://www.kernel.org/pub/linux/utils/boot/syslinux/ "https://www.kernel.org/pub/linux/utils/boot/syslinux/") Direct-Link to 13-Oct-2013 [Syslinux v6.03](https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.gz "https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.gz")

The basic wget from OpenWrt does NOT support wget from [https://.](https://. "https://.") The following steps could be done by downloading the syslinux to your pc and transfer the required files manually to your usb-stick.

Because the basic OpenWrt wget does not support https, we have to install the package wget (thanks to theoradicus for giving this important hint) and the extended tar command to extract the compressed archive afterwards:

```
root@OpenWrt:~# opkg update
root@OpenWrt:~# opkg install wget tar
```

Now we can download the syslinux archive and extract it. We do not have the public SSL-CAs on our OpenWrt so we have to NOT check the server-certificate:

```
root@OpenWrt:~# mkdir /mnt/extstorage/syslinux-download
root@OpenWrt:~# cd /mnt/extstorage/syslinux-download
root@OpenWrt:/mnt/extstorage/syslinux-download# wget --no-check-certificate https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.gz
root@OpenWrt:/mnt/extstorage/syslinux-download# tar -xzf syslinux-6.03.tar.gz
```

You have to copy the following files from the syslinux to your tftp-folder:

- ./bios/core/pxelinux.0
- ./bios/com32/elflink/ldlinux/ldlinux.c32
- ./bios/com32/menu/vesamenu.c32
- ./bios/com32/lib/libcom32.c32
- ./bios/com32/libutil/libutil.c32

As one single long copy-command:

```
root@OpenWrt:~# cd /mnt/extstorage/syslinux-download/syslinux-6.03/bios
root@OpenWrt:/mnt/extstorage/syslinux-download/syslinux-6.03/bios# cp core/pxelinux.0 com32/elflink/ldlinux/ldlinux.c32 com32/menu/vesamenu.c32 com32/lib/libcom32.c32 com32/libutil/libutil.c32 /mnt/extstorage/tftp
```

**Hint**: We do a BIOS / Legacy PXE Boot - NOT an UEFI boot, this is something completely different!

Now we create our default menu-file:

```
root@OpenWrt:~# vim /mnt/extstorage/tftp/pxelinux.cfg/default
DEFAULT vesamenu.c32
PROMPT 0
MENU TITLE OpenWrt PXE-Boot Menu

label Ubuntu
        MENU LABEL Ubuntu Live 16.04 64-Bit
        KERNEL disks/ubuntu1604-64/casper/vmlinuz.efi
        APPEND boot=casper ide=nodma netboot=nfs nfsroot=192.168.1.1:/mnt/extstorage/tftp/disks/ubuntu1604-64/ initrd=disks/ubuntu1604-64/casper/initrd.lz
        TEXT HELP
                Starts the Ubuntu Live-CD - Version 16.04 64-Bit
        ENDTEXT
```

As you can see we need nfs for this operating system. Other operating systems like clonezilla can be fully booted via TFTP an do not need an additional nfs service.

We now have to download and extract the Ubuntu 16.04 to the USB-Drive.

One Option is to do this directly on the OpenWrt itself, but I downloaded the Ubuntu ISO on my computer and plugged in the USB-Drive from OpenWrt and put only the extracted files onto the USB-Drive

Finally, you should have something like the following folder structure:

```
root@OpenWrt:~#  cd ..
root@OpenWrt:~# # find /mnt/extstorage/tftp/
/mnt/extstorage/tftp/
/mnt/extstorage/tftp/disks
/mnt/extstorage/tftp/disks/ubuntu1604-64
/mnt/extstorage/tftp/disks/ubuntu1604-64/pics
...
/mnt/extstorage/tftp/disks/ubuntu1604-64/EFI
...
/mnt/extstorage/tftp/disks/ubuntu1604-64/README.diskdefines
/mnt/extstorage/tftp/disks/ubuntu1604-64/casper
/mnt/extstorage/tftp/disks/ubuntu1604-64/casper/filesystem.size
/mnt/extstorage/tftp/disks/ubuntu1604-64/casper/initrd.lz
/mnt/extstorage/tftp/disks/ubuntu1604-64/casper/vmlinuz.efi
/mnt/extstorage/tftp/disks/ubuntu1604-64/casper/filesystem.manifest
/mnt/extstorage/tftp/disks/ubuntu1604-64/casper/filesystem.manifest-remove
/mnt/extstorage/tftp/disks/ubuntu1604-64/casper/filesystem.squashfs
/mnt/extstorage/tftp/disks/ubuntu1604-64/isolinux
...
/mnt/extstorage/tftp/disks/ubuntu1604-64/pool
...
/mnt/extstorage/tftp/disks/ubuntu1604-64/preseed
...
/mnt/extstorage/tftp/disks/ubuntu1604-64/md5sum.txt
/mnt/extstorage/tftp/disks/ubuntu1604-64/install
/mnt/extstorage/tftp/disks/ubuntu1604-64/install/mt86plus
/mnt/extstorage/tftp/disks/ubuntu1604-64/dists
...
/mnt/extstorage/tftp/disks/ubuntu1604-64/ubuntu
/mnt/extstorage/tftp/disks/ubuntu1604-64/boot
...
/mnt/extstorage/tftp/ldlinux.c32
/mnt/extstorage/tftp/libcom32.c32
/mnt/extstorage/tftp/libutil.c32
/mnt/extstorage/tftp/pxelinux.0
/mnt/extstorage/tftp/pxelinux.cfg
/mnt/extstorage/tftp/pxelinux.cfg/default
/mnt/extstorage/tftp/vesamenu.c32
```

## 3. Enable TFTP and NFS Service

Configure dnsmasq service to enable read-only tftp-service

```
root@OpenWrt:~# vim /etc/config/dhcp
config dnsmasq
         ... a lot of config done before...
        option enable_tftp '1'
        option tftp_root '/mnt/extstorage/tftp'
        ... a lot more config

config boot linux
        option filename 'pxelinux.0'
        option serveraddress '192.168.1.1'
        option servername 'OpenWrt'

root@OpenWrt:~# /etc/init.d/dnsmasq restart
```

Some devices requires two additional lines in section *config boot linux*:

```
        list dhcp_option '209,pxelinux.cfg/default'
        option force '1'
```

Without this parameters some PXE devices won't boot to default menu.

Now we have to install and configure the NFS-Service:

```
root@OpenWrt:~# opkg install nfs-kernel-server
```

Configure NFS-Share now

```
root@OpenWrt:~# vim /etc/exports
/mnt/extstorage/tftp/disks  *(ro,async,no_subtree_check)
```

Now enable portmap and nfsd and (re)start them

```
root@OpenWrt:~# /etc/init.d/portmap enable
root@OpenWrt:~# /etc/init.d/portmap restart
root@OpenWrt:~# /etc/init.d/nfsd enable
root@OpenWrt:~# /etc/init.d/nfsd restart
```

## 4. Testing it out

And now we are ready to go! Just grab a computer (or Virtual Machine) and PXE Boot - you should be able to fully boot into Ubuntu 16.04 via your OpenWrt Router ![:-D](/lib/images/smileys/biggrin.svg) Hint: you often have to enable PXE-Booting in BIOS and press e.g. F12 to get into the Boot-Menu.

Note: It will help immensely to check your sys.log to see what path is actually being used to pull the pxelinux.0, vmlinuz.efi (kernel file), initrd.lz (which are transferred via tftp), etc...but of course you have to set that up on the router as well.

For instance in sys.log I received the following messages when I got mine working:

```
Tue Nov  7 19:28:20 2017 daemon.err dnsmasq-tftp[16313]: error 0 TFTP Aborted received from 192.168.1.235
Tue Nov  7 19:28:20 2017 daemon.info dnsmasq-tftp[16313]: failed sending /mnt/extstorage/tftp/pxelinux.0 to 192.168.1.235
Tue Nov  7 19:28:20 2017 daemon.info dnsmasq-tftp[16313]: sent /mnt/extstorage/tftp/pxelinux.0 to 192.168.1.235
Tue Nov  7 19:28:20 2017 daemon.info dnsmasq-tftp[16313]: sent /mnt/extstorage/tftp/ldlinux.c32 to 192.168.1.235
Tue Nov  7 19:28:20 2017 daemon.err dnsmasq-tftp[16313]: file /mnt/extstorage/tftp/pxelinux.cfg/44454c4c-4e00-104e-8038-b6c04f4a4431 not found
Tue Nov  7 19:28:20 2017 daemon.err dnsmasq-tftp[16313]: file /mnt/extstorage/tftp/pxelinux.cfg/01-00-1c-23-86-01-07 not found
Tue Nov  7 19:28:20 2017 daemon.err dnsmasq-tftp[16313]: file /mnt/extstorage/tftp/pxelinux.cfg/C0A801EB not found
Tue Nov  7 19:28:20 2017 daemon.err dnsmasq-tftp[16313]: file /mnt/extstorage/tftp/pxelinux.cfg/C0A801E not found
Tue Nov  7 19:28:20 2017 daemon.err dnsmasq-tftp[16313]: file /mnt/extstorage/tftp/pxelinux.cfg/C0A801 not found
Tue Nov  7 19:28:20 2017 daemon.err dnsmasq-tftp[16313]: file /mnt/extstorage/tftp/pxelinux.cfg/C0A80 not found
Tue Nov  7 19:28:20 2017 daemon.err dnsmasq-tftp[16313]: file /mnt/extstorage/tftp/pxelinux.cfg/C0A8 not found
Tue Nov  7 19:28:20 2017 daemon.err dnsmasq-tftp[16313]: file /mnt/extstorage/tftp/pxelinux.cfg/C0A not found
Tue Nov  7 19:28:20 2017 daemon.err dnsmasq-tftp[16313]: file /mnt/extstorage/tftp/pxelinux.cfg/C0 not found
Tue Nov  7 19:28:20 2017 daemon.err dnsmasq-tftp[16313]: file /mnt/extstorage/tftp/pxelinux.cfg/C not found
Tue Nov  7 19:28:20 2017 daemon.info dnsmasq-tftp[16313]: sent /mnt/extstorage/tftp/pxelinux.cfg/default to 192.168.1.235
Tue Nov  7 19:28:20 2017 daemon.info dnsmasq-tftp[16313]: sent /mnt/extstorage/tftp/vesamenu.c32 to 192.168.1.235
Tue Nov  7 19:28:20 2017 daemon.info dnsmasq-tftp[16313]: sent /mnt/extstorage/tftp/libcom32.c32 to 192.168.1.235
Tue Nov  7 19:28:20 2017 daemon.info dnsmasq-tftp[16313]: sent /mnt/extstorage/tftp/libutil.c32 to 192.168.1.235
Tue Nov  7 19:28:20 2017 daemon.info dnsmasq-tftp[16313]: sent /mnt/extstorage/tftp/pxelinux.cfg/default to 192.168.1.235
Tue Nov  7 19:28:34 2017 daemon.info dnsmasq-tftp[16313]: sent /mnt/extstorage/tftp/disks/ubuntu1604-64/casper/vmlinuz.efi to 192.168.1.235
Tue Nov  7 19:28:42 2017 daemon.info dnsmasq-tftp[16313]: sent /mnt/extstorage/tftp/disks/ubuntu1604-64/casper/initrd.lz to 192.168.1.235
Tue Nov  7 19:29:24 2017 daemon.info dnsmasq-dhcp[16313]: DHCPDISCOVER(br-lan) 00:1c:23:86:01:07 
Tue Nov  7 19:29:24 2017 daemon.info dnsmasq-dhcp[16313]: DHCPOFFER(br-lan) 192.168.1.235 00:1c:23:86:01:07 
Tue Nov  7 19:29:24 2017 daemon.info dnsmasq-dhcp[16313]: DHCPREQUEST(br-lan) 192.168.1.235 00:1c:23:86:01:07 
Tue Nov  7 19:29:24 2017 daemon.info dnsmasq-dhcp[16313]: DHCPACK(br-lan) 192.168.1.235 00:1c:23:86:01:07 
Tue Nov  7 19:29:24 2017 daemon.notice rpc.mountd[16219]: authenticated mount request from 192.168.1.235:777 for /mnt/extstorage/tftp/disks/ubuntu1604-64 (/mnt/extstorage/tftp/disks)
```

## 5. Trouble shooting

```
>>Checking Media Presence......
>>Media Present......
>>Start PXE over IPv4.
  Station IP address is 192.168.1.239
  
  Server IP address is 192.168.1.1
  NBP filename is pxelinux.0
  NBP filesize is 0 Bytes
  PXE-E23: Client received TFTP error from...
```

Check that your tftp-server is up and running and serves the file 'pxelinux.0':

```
user@server:~# opkg update
user@server:~# opkg install atftp
user@server:~# atftp 192.168.1.1
tftp> get pxelinux.0
tftp> error received from server <file /mnt/extstorage/tftp/pxelinux.0> not found
tftp> aborting
tftp>
```

If the file pxelinux.0 is at the expected location, try restarting the tftp server:

```
user@server:~# /etc/init.d/dnsmasq restart
udhcpc: started, v1.35.0
udhcpc: broadcasting discover
udhcpc: no lease, failing
user@server:~#
```
