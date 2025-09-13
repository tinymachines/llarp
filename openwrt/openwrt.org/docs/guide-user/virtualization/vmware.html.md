# OpenWrt on VMware HowTo

This article describes how to use OpenWrt as a virtual machine with VMware virtualization.

## Tested with

- Barrier Breaker 14.07 in combination with VMware ESXi 5.5 Update 2 Build 2068190
- Chaos Calmer 15.05.1 with VMware Fusion and vSphere ESXi 6.0
- 19.07.0-rc2 in combination with VMware ESXi 6.7.0 Update 2 Build 13981272
- 19.07.5 in combination with VMware ESXi 6.7.0 Update 2 Build 16713306
- 21.02.0-rc3 on a VMware vSphere Client version 6.7.0.42000 machine
- 23.05.2 on a VMware vSphere VM VMware ESXi, 6.7.0, 20497097
- 24.10.0 on VMWare Fusion 13.6.2

### Things you need

- [https://downloads.openwrt.org/barrier\_breaker/14.07/x86/generic/openwrt-x86-generic-combined-ext4.img.gz](https://downloads.openwrt.org/barrier_breaker/14.07/x86/generic/openwrt-x86-generic-combined-ext4.img.gz "https://downloads.openwrt.org/barrier_breaker/14.07/x86/generic/openwrt-x86-generic-combined-ext4.img.gz") or
- [https://downloads.openwrt.org/chaos\_calmer/15.05/x86/64/openwrt-15.05-x86-64-combined-ext4.img.gz](https://downloads.openwrt.org/chaos_calmer/15.05/x86/64/openwrt-15.05-x86-64-combined-ext4.img.gz "https://downloads.openwrt.org/chaos_calmer/15.05/x86/64/openwrt-15.05-x86-64-combined-ext4.img.gz") or
- Generic x86/64, version COMBINED-EFI (EXT4) from [https://firmware-selector.openwrt.org/](https://firmware-selector.openwrt.org/ "https://firmware-selector.openwrt.org/")
- Linux machine with qemu-utils &amp; gunzip installed or MacOS machine with qemu installed (via [Homebrew](http://brew.sh "http://brew.sh"))
- Hypervisor with VMware ESXi, Fusion, Player, or Workstation installed

First of all, you need to download the image from list above on your machine. After that you extract &amp; convert it to a vmdk image:

```
gunzip openwrt-x86-generic-combined-ext4.img.gz
qemu-img convert -f raw -O vmdk openwrt-x86-generic-combined-ext4.img openwrt-x86-generic-combined-ext4.vmdk
```

or

```
yum -y install qemu-img
wget https://downloads.openwrt.org/chaos_calmer/15.05/x86/64/openwrt-15.05-x86-64-combined-ext4.img.gz
gunzip openwrt-15.05-x86-64-combined-ext4.img.gz
qemu-img convert -f raw -O vmdk openwrt-15.05-x86-64-combined-ext4.img openwrt-15.05-x86-64-combined-ext4.vmdk
```

or on a Mac

```
brew install qemu
qemu-img convert -f raw -O vmdk ~/Downloads/openwrt-15.05-x86-64-combined-ext4.img openwrt-15.05-x86-64-combined-ext4.vmdk
```

after that, just create a new VM in Fusion, Workstation, or ESXi with “Linux\\Other Linux 32-bit” with LSI BUS Logic &amp; add the vmdk there. Use Intel PRO/1000 Network adapters. This may require editing the .vmx file to include following definition: *(On Workstation 10, the e1000 gave a corrupted vmx file. Using V6 machine type did work. So it seems somewhere between V6.5 and V10 VMware dropped support for the e1000 driver and/or the virtualDev keyword.)*

```
ethernet0.virtualDev = "e1000"
```

On Fusion I had to use the IDE drive controller type. This also applies to recent ESXi versions, just switch the Virtual Device Node from default SCSI controller 0 to IDE 0. Also, recent OpenWRT and ESXi versions do support running VMXNET3 virtual NIC so you can achieve 10GE speeds.

## Quick Start

NB: The first network interface is LAN, and the second is WAN.

⚠️This info is obsolete⚠️

Follow these steps to get an Up to Date VM with the latest code running on ESX in 15 minutes:

01. you can download an OVA image from the following location: [https://www.dropbox.com/s/ao805tl33mqe0an/openwrt15cc.ova](https://www.dropbox.com/s/ao805tl33mqe0an/openwrt15cc.ova "https://www.dropbox.com/s/ao805tl33mqe0an/openwrt15cc.ova")  
    This image was made by Iben in September 2015 based on a July build of CHAOS CALMER 15.05 trunk r46767
02. Import the OVA to VMware ESXi (tested with latest version 6 in July 2016)  
    The base image only has 1 virtual NIC setup with DHCP
03. Power on the VM - observe the MAC Address - find that on you DHCP server
04. Confirm the OpenWrt VM's IP address by opening the console
05. Press enter to get a prompt
06. Type `ifconfig | more` to see the DHCP assigned IP address for the Bridge assigned to the NIC
07. If you don't have a DHCP server on your network you can set the IP Address manually: `vi /etc/config/network`  
    The whole goal here is to get the OpenWrt VM on the network so you can hit the LuCI Web User Interface with a web browser. This way we can update the base image.
08. Once you've logged in to the LuCI web interface set a root password so you can ssh in
09. With the Web UI navigate to the System/Flash Operations page and find this text: *Flash new firmware image - Upload a sysupgrade-compatible image here to replace the running firmware*. Check “Keep settings” to retain the current configuration (requires an OpenWrt compatible firmware image).
10. On your admin system with the web browser download the latest file to prepare for the flash upgrade of OpenWrt: [https://downloads.openwrt.org/chaos\_calmer/15.05.1/x86/generic/openwrt-15.05.1-x86-generic-combined-ext4.img.gz](https://downloads.openwrt.org/chaos_calmer/15.05.1/x86/generic/openwrt-15.05.1-x86-generic-combined-ext4.img.gz "https://downloads.openwrt.org/chaos_calmer/15.05.1/x86/generic/openwrt-15.05.1-x86-generic-combined-ext4.img.gz") ←- this was the most current available from [https://downloads.openwrt.org/](https://downloads.openwrt.org/ "https://downloads.openwrt.org/") dated 16 March 2016 (last checked 11 Sept 2016)
11. Then upload that to your running OpenWrt system and click “Flash Image...”
12. Reboot and login again.
13. Now you can add the second NIC to use the OpenWrt VM as a WAN router. I set mine up with both DHCP and Static IP addresses for the WAN - and the LAN interface was configured as a DHCP server.
14. To prepare for testing: install iperf3 and nmap from the System/Software page of the Web UI.
15. See the testing section below for details...
16. That's pretty much it. I'm very happy with this new setup. I was also looking at M0n0wall (monowall), and pfsense to run as VMs but OpenWrt has a lot more going for it as far as an Open Source eco-system and developer/vendor support.

### Testing

1. Start the server on OpenWrt: `iperf3 -s`
2. Download the iperf3 binaries for various Operating Systems from here: [https://iperf.fr/iperf-download.php](https://iperf.fr/iperf-download.php "https://iperf.fr/iperf-download.php")
3. Then install and run the client on other machines on your network.
4. `iperf3 -c <ip-address-of-the-server>`

Here are some results from my system:

- 2012 MacBook with 802.11n on 5GHz -→ 284 Mbits/sec
- 2011 MacMini with CentOS 7.1 -→ 958 Mbits/sec
- Ubuntu VM running on same old Dell T110 ESXi host and OpenWrt VM -→ 4.14 Gbits/sec

As you can see - the OpenWrt virtual machine running on VMware ESX is very capable of keeping up with your home internet router needs! And this is with only 1 virtual CPU and no tuning at all.

### ToDo List

Here's a wish list of things we would like to accomplish with OpenWrt - consider this technical debt.

(Is there a better place to make these requests?)

1. install open-vm-tools to enhance support on VMware hypervisors (possible via packages sources and LuCI or opkg)
2. use vmxnet3 paravirtualized network interface
3. learn how to create fresh builds from scratch
4. install cloud-init capabilities to allow auto-configuration on OpenStack based clouds like OPNFV
5. create jenkins job as part of CI to download and convert the raw image to vmdk with each build
6. create jenkins job as part of CI to download and convert the raw image to qcow2 with each build
7. do these conversions for both stable and trunk
8. integrate OpenWrt into the CI Pipeline for other network testing projects like OPNFV

## Disk Size Issues

Disk size and problems with veeam backup and enlarging the disk Veeam backup and VMware will complain about the size of the virtual disk provided by the OpenWrt download because the disk is not multiple of 1KB. (this means: no backups available, and could be crucial in production environments)

VMware won't let you enlarge the disk in the normal way, so one simple way is:

01. make a snapshot of the vm, for possible rollback
02. move the original disk (from OpenWrt downloads) on ide 0:1
03. add a new disk, with a whole size, like 128 MB , on ide 0:0
04. use `sysrescuecdiso`
05. start the vm with the iso
06. with dd copy the disc on ide 0:1 to ide 0:0 like `dd if=/dev/sdb of=/dev/sda`
07. enter `fdisk /dev/sda` and write the partition table (without making changes, this helps sysrescuecd to see the partitions properly)
08. do `fsck -f` on the sda2 partition
09. with `fdisk` resize the sda2 partition to occupy all the space available (but still starting with the same sector of before, normally 9135)
10. use `resize2fs /dev/sda2`
11. do `fsck -f /dev/sda2`
12. restart the machine and boot with OpenWrt check that the system uses the new partition
13. stop the machine, delete the previous hd (with less than 128MB)
14. restart the machine and verify that everything is ok.

## Community

Please use these images in your home and work labs and provide any feedback you might have.

Feel free to update this wiki page with your results.

There is some feedback that the newer images are not booting properly. Has anyone else run into this issue?

&lt;html&gt; &lt;blockquote class=“twitter-tweet” data-lang=“en”&gt;&lt;p lang=“en” dir=“ltr”&gt;&lt;a href=“[https://twitter.com/iben](https://twitter.com/iben "https://twitter.com/iben")”&gt;@iben&lt;/a&gt; learn , well, your quickstart ova works great. Following the instructions in the paragraph above it by the letter doesn&amp;#39;t. /shrug .&lt;/p&gt;&amp;mdash; Phoenixxl (@Phoenixxl) &lt;a href=“[https://twitter.com/Phoenixxl/status/775043516070260740](https://twitter.com/Phoenixxl/status/775043516070260740 "https://twitter.com/Phoenixxl/status/775043516070260740")”&gt;September 11, 2016&lt;/a&gt;&lt;/blockquote&gt; &lt;script async src=“*platform.twitter.com/widgets.js” charset=“utf-8”&gt;&lt;/script&gt; &lt;/html&gt; ==== Upgrade to 19.07.5 from ova ==== - Create a snapshot from ESXI UI to allow easy rollback in case of issues - Use the following image from LuCi: [https://downloads.openwrt.org/releases/19.07.5/targets/x86/generic/openwrt-19.07.5-x86-generic-combined-squashfs.img.gz](https://downloads.openwrt.org/releases/19.07.5/targets/x86/generic/openwrt-19.07.5-x86-generic-combined-squashfs.img.gz "https://downloads.openwrt.org/releases/19.07.5/targets/x86/generic/openwrt-19.07.5-x86-generic-combined-squashfs.img.gz") - You should be able to access console from ESXI, but no IPv4 network will be available - Beware of keyboard layout of the console which is qwerty, type ifconfig and find IPv6 address - From LuCi, go to Network/Interface and click edit on br-lan without doing any change, and save. The configuration will be automatically fixed. - Reboot your OpenWRT VM, you should then get the IPv4 address back. Here is an upgraded OVA VM export with version 19.07.5, using ext4 instead of squashfs and an extended /overlay filesystem, with DHCP enabled instead of a static IP for br-lan interface: [https://www.dropbox.com/s/4b0dy8d8iqf8a91/OpenWRT\_x86\_64\_19.07.05.ova?dl=0](https://www.dropbox.com/s/4b0dy8d8iqf8a91/OpenWRT_x86_64_19.07.05.ova?dl=0 "https://www.dropbox.com/s/4b0dy8d8iqf8a91/OpenWRT_x86_64_19.07.05.ova?dl=0") ---- ==== Upgraded/Updated OVA for OpenWRT21 ==== After import of the previous OVA-file to VMware Sphere, I was able to upgrade to the latest OpenWrt version (21-00-RC3). This machine,* OpenWRT-21 *has * 2 CPU * 2 GB * 2 NiCs * WAN defined as DHCP client * LAN static address 192.168.1.1 as DHCP server * Compatibility ESXi 5.0 and later (VM version 8) * Installed VMware tools, as well as vnet drivers*

*[https://www.dropbox.com/s/nljp8todp99qggn/OpenWRT21.ova](https://www.dropbox.com/s/nljp8todp99qggn/OpenWRT21.ova "https://www.dropbox.com/s/nljp8todp99qggn/OpenWRT21.ova")*

*==== Example Issues seen during VMWare Installs ==== VMDK (1st method): e1000 interface is found/loads intermittently. Corresponds to Seg Fault errors in **kmodloader** when loading **libuclibc**. === Build Summary === * VMWare ESXi 6.1 * 1 CPU * 512 MB Memory * Image Used for VMDK: [https://downloads.openwrt.org/chaos\_calmer/15.05/x86/64/openwrt-15.05-x86-64-combined-ext4.img.gz](https://downloads.openwrt.org/chaos_calmer/15.05/x86/64/openwrt-15.05-x86-64-combined-ext4.img.gz "https://downloads.openwrt.org/chaos_calmer/15.05/x86/64/openwrt-15.05-x86-64-combined-ext4.img.gz") * Extraneous devices (USB, etc) removed*
