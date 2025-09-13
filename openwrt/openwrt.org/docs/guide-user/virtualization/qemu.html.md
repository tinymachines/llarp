# OpenWrt in QEMU

QEMU is an an open source processor emulator (and virtualizer). This document describes how to run OpenWrt in QEMU. If you are looking to use OpenWrt as a QEMU host, see [Running QEMU guests on OpenWrt](/docs/guide-user/virtualization/qemu_host "docs:guide-user:virtualization:qemu_host").

It is mixed descriptions from Windows and Linux, so please read through all of it before starting.

![:!:](/lib/images/smileys/exclaim.svg) Choosing different emulation settings can affect performance greatly.

Example: 30s iperf-s@openwrt (QEMU running on host) to host

```
ne2k_pci:0.0-31.3 sec  14.6 MBytes  3.92 Mbits/sec
pcnet: 0.0-30.0 sec  2.38 GBytes   682 Mbits/sec
e1000: 0.0-30.0 sec  6.23 GBytes  1.79 Gbits/sec
vmxnet3: 0.0-30.0 sec  8.67 GBytes  2.48 Gbits/sec
virtio-net-pci:  0.0-30.0 sec  44.6 GBytes  12.8 Gbits/sec
```

- ![FIXME](/lib/images/smileys/fixme.svg) Trunk: test kernel image with rootfs
- ![FIXME](/lib/images/smileys/fixme.svg) Trunk: use SD card with rootfs, NFS rootfs, NBD rootfs
- ![FIXME](/lib/images/smileys/fixme.svg) Trunk: no sound, pcibus, USB emulation in QEMU possible?

## Getting QEMU

QEMU runs on many different systems.

### Ubuntu Linux

Many Linux distributions like Debian, Ubuntu, SUSE, and Fedora provide a QEMU package in their package repositories.

Example for Debian 9 (Stretch):

```
sudo apt-get install qemu
```

![:!:](/lib/images/smileys/exclaim.svg) QEMU is rapidly developing so features and syntax might change between versions.

### Windows version

The [QEMU Wiki Links](http://wiki.qemu.org/Links "http://wiki.qemu.org/Links") page provides you with several unofficial download links of Windows builds.

### MacOS version

Use homebrew. The [homebrew qemu](https://formulae.brew.sh/formula/qemu "https://formulae.brew.sh/formula/qemu") page provides variants for different hardware and MacOS versions.

## OpenWrt in QEMU ARM

For OpenWrt releases 22 and older, use the [armvirt](https://archive.openwrt.org/releases/22.03.7/targets/armvirt/ "https://archive.openwrt.org/releases/22.03.7/targets/armvirt/") target with QEMU to emulate an ARM system. For releases 23 and newer (including snapshots), use the [armsr](https://https://downloads.openwrt.org/releases/24.10.1/targets/armsr/ "https://https://downloads.openwrt.org/releases/24.10.1/targets/armsr/") target instead.

### Boot with initramfs

This is the simplest method that can be used to test an image. However, it runs entirely in RAM: any modification made is lost upon reboot.

To use this boot method, here with 64 MB of RAM, run:

```
qemu-system-arm -nographic -M virt -m 64 -kernel openwrt-armvirt-zImage-initramfs
```

## OpenWrt in QEMU aarch64

aarch64 is used by many modern Arm CPUs. The instruction set is called armv8. The target is [armsr armv8 variant](https://https://downloads.openwrt.org/releases/24.10.1/targets/armsr/ "https://https://downloads.openwrt.org/releases/24.10.1/targets/armsr/").

![:!:](/lib/images/smileys/exclaim.svg) Needs steps update from 22.03 to current: armvirt-64 to armsr-armv8 ![:!:](/lib/images/smileys/exclaim.svg)

```
qemu-system-aarch64 -m 1024 -smp 2 -cpu cortex-a57 -M virt -nographic \
-kernel openwrt-19.07.3-armvirt-64-Image-initramfs \
-drive if=none,file=disk.img,id=hd0 -device virtio-blk-device,drive=hd0
```

Here's an example with network interface and persistent storage:

```
qemu-system-aarch64 --enable-kvm -M virt -nographic -nodefaults \
-m 128 \
-cpu host -smp 2 \
-kernel openwrt-armvirt-64-Image -append "root=fe00" \
-blockdev driver=raw,node-name=hd0,cache.direct=on,file.driver=file,file.filename=openwrt-armvirt-64-root.ext4 \
-device virtio-blk-pci,drive=hd0 \
-netdev type=tap,id=nic1,ifname=kvm0,script=no,downscript=no \
-device virtio-net-pci,disable-legacy=on,disable-modern=off,netdev=nic1,mac=ba:ad:1d:ea:01:02 \
-device qemu-xhci,id=xhci,p2=8,p3=8 \
-device usb-host,vendorid=0x7392,productid=0x7822
```

- kernel without initrd will automatically attempt to mount ext4 partition, but it has to be told where it is with the `-append “root=fe00”` parameter (if you don't specify this, the kernel will list available block devices and reboot)
- `-blockdev` followed by `-device` is the new way of specifying block devices in qemu - I could've used -drive, but I copied most of the config from elsewhere
- `-netdev` binds a virtual NIC to host tap interface kvm0, which should be created before starting qemu; if you need multiple NICs, just copy the `-netdev` and `-device virtion-net-pci` lines and adjust ifname (tap device on host), id (device id, ties -netdev and -device together) and mac address
- last two lines add a USB3 controller and attach a physical USB WiFi dongle to the VM

### OpenWrt in QEMU aarch64 on Apple Silicon (MacOS, M1+ hardware, Native)

It is possible to use native virtualisation on Apple arm64 hardware under MacOS (high performance variant)

The target is [armsr armv8 variant](https://downloads.openwrt.org/snapshots/targets/armsr/armv8/ "https://downloads.openwrt.org/snapshots/targets/armsr/armv8/")

Non-persistent variant (with **openwrt-armvirt-64-Image-initramfs**):

```
qemu-system-aarch64 -m 1024 -smp 2 -cpu host -M virt,highmem=off \
-nographic \
-accel hvf \
-kernel openwrt-armvirt-64-Image-initramfs \
-device virtio-net,netdev=net0 -netdev user,id=net0,net=192.168.1.0/24,hostfwd=tcp:127.0.0.1:1122-192.168.1.1:22 \
-device virtio-net,netdev=net1 -netdev user,id=net1,net=192.0.2.0/24
```

Persistent (squashfs) variant (with **openwrt-armvirt-64-Image** and **openwrt-armvirt-64-rootfs-squashfs.img**):

```
qemu-system-aarch64 -m 1024 -smp 2 -cpu host -M virt,highmem=off \
-nographic \
-accel hvf \
-kernel openwrt-armvirt-64-Image \
-drive file=openwrt-armvirt-64-rootfs-squashfs.img,format=raw,if=virtio \
-append root=/dev/vda \
-device virtio-net,netdev=net0 -netdev user,id=net0,net=192.168.1.0/24,hostfwd=tcp:127.0.0.1:1122-192.168.1.1:22 \
-device virtio-net,netdev=net1 -netdev user,id=net1,net=192.0.2.0/24
```

Both variants provide two network interfaces to OpenWrt:

1. eth0 (LAN)
2. eth1 (WAN). qemu dhcp-server will allocate 192.0.2.15 IP address for OpenWrt host and provide IPv4 Internet access

To access OpenWrt via SSH from host:

```
ssh -p1122 root@127.0.0.1
```

It is possible to connect from OpenWrt guest to host by IP 192.168.1.2 (via eth0) or 192.0.2.2 (via eth1)

## OpenWrt in QEMU MIPS

![:!:](/lib/images/smileys/exclaim.svg) Use QEMU &gt;= 2.2 (earlier versions can have bugs with MIPS16) [ticket 16881](https://dev.openwrt.org/ticket/16881 "https://dev.openwrt.org/ticket/16881") - Ubuntu 14.03.x LTS uses QEMU 2.0 which is has this bug.

The “[malta](/docs/techref/targets/malta "docs:techref:targets:malta")” platform is meant for use with QEMU for emulating a MIPS system.

The `malta` target supports both big and little-endian variants, pick the matching files and qemu version (`qemu-system-mips`, or `qemu-system-mipsel`).

```
qemu-system-mipsel \
-kernel openwrt-malta-le-vmlinux-initramfs.elf \
-nographic -m 256
```

In recent enough versions one can enable ext4 root filesystem image building, and since [r46269](https://dev.openwrt.org/changeset/46269 "https://dev.openwrt.org/changeset/46269") (![:!:](/lib/images/smileys/exclaim.svg) only in trunk, it's not part of the 15.05 CC release) it's possible to boot straight from that image (without an initramfs):

```
qemu-system-mipsel -M malta \
-hda openwrt-malta-le-root.ext4 \
-kernel openwrt-malta-le-vmlinux.elf \
-nographic -append "root=/dev/sda console=ttyS0"
```

## OpenWrt in QEMU RISC-V

Use the build documentation found on the HiFive Unleashed page. The process described there will generate the bbl.qemu (BBL+vmlinux) image required to boot with QEMU. For reference, use [https://git.openwrt.org/?p=openwrt/staging/wigyori.git;a=shortlog;h=refs/heads/riscv-201810](https://git.openwrt.org/?p=openwrt%2Fstaging%2Fwigyori.git%3Ba%3Dshortlog%3Bh%3Drefs%2Fheads%2Friscv-201810 "https://git.openwrt.org/?p=openwrt/staging/wigyori.git;a=shortlog;h=refs/heads/riscv-201810")

Until 4.19 support is merged into openwrt/trunk, the port itself cannot be merged into trunk, and manual builds are required.

RISC-V support is in mainline qemu, refer to [https://wiki.qemu.org/Documentation/Platforms/RISCV](https://wiki.qemu.org/Documentation/Platforms/RISCV "https://wiki.qemu.org/Documentation/Platforms/RISCV")

The suggested QEMU startup is:

```
$ qemu-system-riscv64 -nographic -machine virt \
  -kernel bbl.qemu -append "root=/dev/vda2 ro console=ttyS0" \
  -drive file=sdcard.img,format=raw,id=hd0 \
  -device virtio-blk-device,drive=hd0 \
  -device virtio-net-device,netdev=net0 -netdev user,id=net0 \
  -smp 2
```

## OpenWrt in QEMU x86-64

The x86-64 target has support for ESXi images by default. Booting the VMDK / VDI images might not work with newer QEMU versions.

![:!:](/lib/images/smileys/exclaim.svg) IMG/VDI/VMDK with “-hda” switch do not work with QEMU 2.x.

pc-q35-2.0 / q35 emulates a different machine. With new syntax (no -hda , -net) the IMG / VDI / VMDK works here. Some emulated network cards might have performance issues.

Features:

- 2 HDDs (1 OpenWrt image, 1 data)
- 1 drive per bus, 6 bus available (until ide.5)
- 2 Network cards : 1 bridged to host (need higher permission) and 1 “user” (default, NAT 10.x.x.x)

### Preparation

Unpack the archive and expand the F2FS data partition if necessary. This partition is generated on first boot and needs the drive to have free space available. Perform [hard factory reset](/docs/guide-user/troubleshooting/failsafe_and_factory_reset#hard_factory_reset "docs:guide-user:troubleshooting:failsafe_and_factory_reset") if F2FS is corrupted or failed to set up properly. The exact expanding method depends on your virtualization system.

#### KVM/QEMU

If you are using KVM/QEMU virtualization.

```
gunzip openwrt-*.img.gz
qemu-img resize -f raw openwrt-*.img 300M
```

#### Resizing rootfs on combined EFI image

Increase base image size to 512M:

```
qemu-img resize -f raw openwrt-x86-64-generic-squashfs-combined-efi.img 512M
```

Loop mount the base image so it can be modified:

```
loop_device=$(losetup -f)
sudo losetup $loop_device openwrt-x86-64-generic-squashfs-combined-efi.img
```

Fix the GPT partition and increase the root partition size to 100% (512M):

```
echo -e "OK\nFix" | sudo parted ---pretend-input-tty "$loop_device" print
sudo parted "$loop_device" resizepart 2 100%
sudo parted "$loop_device" print
```

Remove the loop mount device

```
sudo losetup -d $loop_device
```

#### libvirt + KVM/QEMU

If you are using KVM/QEMU with libvirt management framework. Import the image as-is and stop the first boot on the GRUB screen. Then expand the block device online as follows and continue the boot.

```
virsh blockresize openwrt vda 300M
virsh vol-resize openwrt 300M default
```

#### Other virtualization systems

If you are using other virtualization systems like Proxmox, VMWare ESXi/Workstation, VirtualBox, XenServer/XCP-ng, and any other self-respecting virtualization software it is also possible to expand the drive but you will have to look at its own documentation for guidance.

### Configuration examples

```
qemu-system-x86_64 \
-enable-kvm \
-M pc-q35-2.0 \
-drive file=openwrt-x86_64-combined-ext4.vdi,id=d0,if=none \
-device ide-hd,drive=d0,bus=ide.0 \
-drive file=data.qcow2,id=d1,if=none \
-device ide-hd,drive=d1,bus=ide.1 \
-soundhw ac97 \
-netdev bridge,br=virbr0,id=hn0 \
-device e1000,netdev=hn0,id=nic1 \
-netdev user,id=hn1 \
-device e1000,netdev=hn1,id=nic2
 
qemu-system-x86_64 -M q35 \
-drive file=openwrt-x86_64-combined-ext4.img,id=d0,if=none,bus=0,unit=0 \
-device ide-hd,drive=d0,bus=ide.0
```

UEFI firmware requires ovmf package installed.

```
qemu-system-x86_64 \
-enable-kvm -m 1G -drive if=pflash,format=raw,readonly,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
-drive if=pflash,format=raw,file=my_uefi_vars.fd
```

### Network configuration

QEMU has several options to provide network connectivity to emulated images, see all `-net` options in qemu(1). Although this option is considered obsolete since QEMU 0.12, it continues to work although it is. The new syntax uses either `-nic` for emulating a particular embedded board, or it uses the two options `-netdev` and `-device`, see the [official documentation](https://wiki.qemu.org/Documentation/Networking "https://wiki.qemu.org/Documentation/Networking").

### Provide Internet access to OpenWrt

The default networking mode for QEMU is “user mode network stack”.

In this mode, `qemu` acts as a proxy for outbound TCP/UDP connections. It also provides DHCP and DNS service to the emulated system.

To provide Internet access to the emulated OpenWrt system, use (the example uses an armvirt system, adjust for your setup):

```
qemu-system-arm -net nic,vlan=0 -net nic,vlan=1 -net user,vlan=1 \
-nographic -M virt -m 64 -kernel lede-17.01.0-r3205-59508e3-armvirt-zImage-initramfs
```

Here, we set up two network cards inside the emulated OpenWrt system:

- `eth0`, used as LAN in OpenWrt (not connected to anything here)
- `eth1`, used as WAN in OpenWrt, and connected to qemu that will proxy all TCP/UDP connections towards the Internet

The OpenWrt system should get both an IPv4 and an IPv6 on `eth1` (via DHCP/DHCPv6). The ranges will be 10.0.2.0/24 and fec0::/64 (qemu defaults, see qemu(1) to configure other ranges).

### Provide access to LuCI inside OpenWrt

LuCI is the web UI used by OpenWrt. If you want to check how LuCI works or to poke around with LuCI-apps this setup is for you. (the example uses an armvirt system, adjust for your setup)

**Note**: This setup requires some privileges (`CAP_NET_ADMIN` and `CAP_MKNOD` under Linux) so it's easier to run it under `sudo`

Save the script and edit `IMAGE` variable to reflect your OpenWrt version, then run it under `sudo`

```
#!/bin/sh
IMAGE=lede-17.01.0-r3205-59508e3-armvirt-zImage-initramfs
LAN=ledetap0
# create tap interface which will be connected to OpenWrt LAN NIC
ip tuntap add mode tap $LAN
ip link set dev $LAN up
# configure interface with static ip to avoid overlapping routes
ip addr add 192.168.1.101/24 dev $LAN
qemu-system-arm \
-device virtio-net-pci,netdev=lan \
-netdev tap,id=lan,ifname=$LAN,script=no,downscript=no \
-device virtio-net-pci,netdev=wan \
-netdev user,id=wan \
-M virt -nographic -m 64 -kernel $IMAGE
# cleanup, delete tap interface created earlier
ip addr flush dev $LAN
ip link set dev $LAN down
ip tuntap del mode tap dev $LAN
```

How networking works:

- `eth0`, used as LAN in OpenWrt, and connected to `ledetap0` in host system(static address `192.168.1.101/24`), providing access to LuCI at `http://192.168.1.1`
- `eth1`, used as WAN in OpenWrt, and connected to qemu that will proxy all TCP/UDP connections towards the Internet

### Forward ports of the host

If you configure NICs on embedded systems, which cannot be used via `-device`, you can access them from the host by forwarding a (high) port in the `-nic` option using `hostfwd=hostip:hostport-guestip:guestport`.

For example, to [access SSH](https://wiki.qemu.org/Documentation/Networking#How_to_get_SSH_access_to_a_guest "https://wiki.qemu.org/Documentation/Networking#How_to_get_SSH_access_to_a_guest") by `ssh root@127.1 -p 1122` from the host on the guest system `malta-be`, you can use:

```
qemu-system-mips -M malta -nographic -hda openwrt-malta-be-rootfs-ext4.img \
-kernel openwrt-malta-be-vmlinux.elf -append 'root=/dev/sda console=ttyS0' \
-nic hostfwd=tcp::1122-:22
```

If the network adapter is a WAN interface, you have to add firewall rules in the guest to allow SSH:

```
uci -q delete firewall.ssh
uci set firewall.ssh="rule"
uci set firewall.ssh.name="Allow-SSH"
uci set firewall.ssh.src="wan"
uci set firewall.ssh.dest_port="22"
uci set firewall.ssh.proto="tcp"
uci set firewall.ssh.target="ACCEPT"
uci commit firewall
/etc/init.d/firewall restart
```

### Use KVM igb network interfaces

(taken from mailing list post by Philip Prindeville)

On my Centos 7.4 KVM host, I did:

To provision 10 VFs per NIC:

```
cat << EOF > /etc/modprobe.d/sr-iov.conf
# for SR-IOV support
options igb max_vfs=10
EOF
```

This will take effect after the next reboot. Alternatively by unloading and reloading the IGB module.

Create XML files for each NIC you want to support virtualization on:

```
# cat << EOF > /tmp/hostdev-net0.xml
<network>
<name>hostdev-net0</name>
<uuid>$(uuidgen)</uuid>
<forward mode='hostdev' managed='yes'>
<pf dev='eno1'/>
</forward>
</network>
EOF
 
cat << EOF > /tmp/hostdev-net1.xml
<network>
<name>hostdev-net1</name>
<uuid>$(uuidgen)</uuid>
<forward mode='hostdev' managed='yes'>
<pf dev='eno2'/>
</forward>
</network>
EOF
 
virsh net-destroy default
virsh net-define /tmp/hostdev-net0.xml
virsh net-autostart hostdev-net0
virsh net-define /tmp/hostdev-net1.xml
virsh net-autostart hostdev-net1
```

To create the pool of VF interfaces.

Then to add interfaces to VMs, I did:

```
# cat << EOF > /tmp/new-interface-0.1.xml
<interface type='network'>
<mac address='52:54:00:0d:84:f4'/>
<source network='hostdev-net0'/>
<address type='pci' domain='0x0000' bus='0x07' slot='0x10' function='0x0'/>
</interface>
EOF
 
# Where the ‘0d:84:f4’ is 3 unique bytes
dd status=none bs=1 count=3 if=/dev/urandom | hexdump -e '/1 "%x"\n'
 
virsh attach-device my-machine-1 /tmp/new-interface-0.1.xml
```

## Advanced boot methods

### Use KVM acceleration

This will be much faster, but will only work if the architecture of your CPU is the same as the target image (here, ARM cortex-a15).

```
qemu-system-arm -nographic -M virt,accel=kvm -cpu host -m 64 -kernel openwrt-armvirt-zImage-initramfs
```

### Boot with a separate rootfs

```
qemu-system-arm -nographic -M virt -m 64 \
-kernel openwrt-armvirt-zImage \
-drive file=openwrt-armvirt-root.ext4,format=raw,if=virtio \
-append 'root=/dev/vda rootwait'
```

### Boot with local directory as rootfs

```
qemu-system-arm -nographic -M virt -m 64 -kernel openwrt-armvirt-zImage \
-fsdev local,id=rootdev,path=root-armvirt/,security_model=none \
-device virtio-9p-pci,fsdev=rootdev,mount_tag=/dev/root \
-append 'rootflags=trans=virtio,version=9p2000.L,cache=loose rootfstype=9p'
```

### Run with kvmtool

```
# start a named machine
lkvm run -k openwrt-armvirt-zImage -i openwrt-armvirt-rootfs.cpio --name armvirt0
 
# start with virtio-9p rootfs
lkvm run -k openwrt-armvirt-zImage -d root-armvirt/
 
# stop "armvirt0"
lkvm stop --name armvirt0
 
# stop all
lkvm stop --all
```

## Examples

This example uses OpenWrt virtualized using Debian, QEMU with KVM and a Lex twitter system with Intel Atom D525 and ICH8M chipset. Normally OpenWrt works on most of the hardware mentioned in the table of hardware (search in this wiki), and also on most of the hardware that support **Intel x86 ISA** or `x86` in the address bar.

Anyway some embedded x86 board have particular hardware that is not always well supported by the OpenWrt platform, even if all the `kmod` packages are included in the basic image. One of this x86 compatible hardware family are systems based on Intel Atom and ICH8M chipset (maybe also others), like the Lex twitter system 3I525U.

OpenWrt is able to run on that system, but for example, is not able to manage the possibility of having two WAN connections with different metric. The request will be always routed to the interface with higher metric also using `ping -I <wan2_interface> 8.8.8.8`. Moreover software like `Nmap` will fail to be bind to certain interfaces. Someone with more knowledge could explain why this happens but as workaround one can use a more complete linux system (for example Debian) as base and then virtualize (`virtualization OR qemu OR kvm OR hypervisor` in the address bar) openwrt, that in the end requires really a little resources most of the time, or one can assign plenty of resources because at the end the base system is quite powerful.

### Prepare debian (7.1 in the test) for virtualization

Debian was installed on a 2 GB CF card through a USB stick and netinstaller, having only the basic system utilities and ssh utilities. 1.1 GB of space were used, 600 MB free and the rest swap.

Install the following packages: `apt-get install qemu-kvm bridge-utils libvirt-bin virtinst`

- Qemu-kvm for QEMU and KVM additional software components.
- bridge-utils for managing bridges in debian
- libvirt-bin for additional virtualization packages
- virtinst for handy virtualization management

If you don't want to use any user but just work with root (the objective is to let OpenWrt run on the twitter system, not having a well set up Debian system):

- Change /etc/libvirt/qemu.conf uncommenting user/group to work as root.
- restart /etc/init.d/libvirt* entries.

Then we have to prepare the network. Modify `/etc/network/interfaces` a follows (adapt according to your needs)

```
auto br0 br1 br2 br3
 
iface br0 inet dhcp
  bridge_ports eth0
 
iface br1 inet dhcp
  bridge_ports eth1
 
iface br2 inet dhcp
  bridge_ports eth2
 
iface br3 inet dhcp
  bridge_ports eth3
```

The bridges ( [https://wiki.debian.org/BridgeNetworkConnections](https://wiki.debian.org/BridgeNetworkConnections "https://wiki.debian.org/BridgeNetworkConnections") ) are helpful because they allows different network adapters, real or virtual ( [network.interfaces](/docs/guide-developer/networking/network.interfaces "docs:guide-developer:networking:network.interfaces") to exchange data (as the word 'bridge' suggests) and not only, because the bridge will have a certain mac address but also the virtual interfaces attached to it can have different mac addresses. Here the marvels of the linux networking system have to be explained by someone with more knowledge.

### Virtualization proper

Then we need to create our virtual machine. The additional packages, apart from QEMU, will help here. We can issue the following command, using the x86 generic image placed in the folder `/root/openwrt_kvm/`:

```
virt-install --name=openwrt --ram=256 --vcpus=1 --os-type=linux \
--disk path=/root/openwrt_kvm/openwrt-x86-generic-combined-ext4.img,bus=ide \
--network bridge=br0,model=e1000 --import
# be careful to the model, e1000 let's openwrt recognize the interface.
# http://manpages.ubuntu.com/manpages/lucid/man1/virt-install.1.html
```

If you want to interact with the system from command line, use `virsh`. For example to force the shutdown of a virtual machine `virsh destroy openwrt` or to delete the virtual machine (but not the disk file) `virsh undefine openwrt`.

For having multiple interfaces

```
virt-install --name=openwrt --ram=256 --vcpus=1 --os-type=linux \
--disk path=/root/openwrt_kvm/openwrt-x86-generic-combined-ext4.img,bus=ide \
--network bridge=br0,model=e1000 --network bridge=br3,model=e1000 --import
```

Remember that the console requires `ctrl+5` to exit.

To mark a virtual machine for the autostart, type: `virsh autostart openwrt`.

### Known issues

\* Virtual interfaces with macvtap: [problems with IPv6 because of multicast](https://bugzilla.redhat.com/show_bug.cgi?id=1035253#c15 "https://bugzilla.redhat.com/show_bug.cgi?id=1035253#c15") * USB-host devices in qemu might not work like on bare metal, might be related to USB3 or driver issues (mt7601u); consider virtualizing whole USB controller via PCIe VFIO.

### Notes

In qemu x86\_64 images you need to create a wan interface is not defined by default (you can forward port 80 if you want to use the web interface to do it) hostfwd=tcp:127.0.0.1:8080-192.168.1.1:80
