# OpenWrt as QEMU/KVM host server

## Introduction

It's possible to use OpenWrt as a QEMU host and run guests on it. If you want to run OpenWrt as a QEMU guest itself, see [OpenWrt in QEMU](/docs/guide-user/virtualization/qemu "docs:guide-user:virtualization:qemu").

OpenWrt provides QEMU packages for ARM and x86 platforms. This article focuses on the x86 target, the networking is done via [qemu-bridge-helper](https://wiki.qemu.org/Features/HelperNetworking "https://wiki.qemu.org/Features/HelperNetworking").

## Installing QEMU

You need the following packages on your device: [kmod-tun](/packages/pkgdata/kmod-tun "packages:pkgdata:kmod-tun"), [qemu-bridge-helper](/packages/pkgdata/qemu-bridge-helper "packages:pkgdata:qemu-bridge-helper"). Depending on the guest architecture, install [qemu-x86\_64-softmmu](/packages/pkgdata/qemu-x86_64-softmmu "packages:pkgdata:qemu-x86_64-softmmu") or [qemu-arm-softmmu](/packages/pkgdata/qemu-arm-softmmu "packages:pkgdata:qemu-arm-softmmu"). If your hardware supports it, also install [kmod-kvm-amd](/packages/pkgdata/kmod-kvm-amd "packages:pkgdata:kmod-kvm-amd") or [kmod-kvm-intel](/packages/pkgdata/kmod-kvm-intel "packages:pkgdata:kmod-kvm-intel") for better performance.

Example for an Intel system and a x86\_64 guest:

```
opkg install kmod-tun qemu-bridge-helper qemu-x86_64-softmmu kmod-kvm-intel
```

After the first installation, reboot your device.

## Running a guest

For the guest OS, use a distribution that comes with virtio drivers by default (Debian or Fedora for example).

The following QEMU command uses a physical disk, but you can use a disk image as well. Below are explanations of the networking options.

```
qemu-system-x86_64 -enable-kvm -cpu host -smp 2 -m 2G \
    -drive file=/dev/sda,cache=none,if=virtio,format=raw \
    -device virtio-net-pci,mac=E2:F2:6A:01:9D:C9,netdev=br0 \
    -netdev bridge,br=br-lan,id=br0
```

**Line 3** creates a virtio net device with a fixed MAC address that is told to use the network backend with `id=br0`, which gets created in **line 4**. The network backend is of type `bridge` and `br=br-lan` tells QEMU to connect to the bridge network `br-lan` of the OpenWrt host. For that `qemu-bridge-helper` will automatically create the needed TUN/TAP interfaces. If your guest uses DHCP it should now receive an address by the server running in `br-lan`.

You can choose any other bridge interface available on your OpenWrt host as well. See [Network basics](/docs/guide-user/base-system/basic-networking "docs:guide-user:base-system:basic-networking") on how to configure networking interfaces. If you want to change which networks QEMU is allowed to connect to, you can do so via `/etc/qemu/bridge.conf`.

## Installing Debian as guest OS

If you don't have a prepared disk image, you can install a guest OS directly on your OpenWrt device. There are several guides available on how to install a Linux distribution on a QEMU image: [Debian](https://wiki.debian.org/QEMU#Setting_up_a_stable_system "https://wiki.debian.org/QEMU#Setting_up_a_stable_system") for example. A quick way is to install Debian using the kernel and initrd of a Debian netboot installer.

### Create a disk image

```
qemu-img create -f qcow2 debian.img 4G
```

More details on disk images: [https://en.wikibooks.org/wiki/QEMU/Images](https://en.wikibooks.org/wiki/QEMU/Images "https://en.wikibooks.org/wiki/QEMU/Images")

### Download installer files

```
wget https://ftp.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/debian-installer/amd64/linux
wget https://ftp.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/debian-installer/amd64/initrd.gz
```

Both files can be savely removed after finishing the installation.

### Run the installer

The following command will launch the Debian installer inside QEMU, `debian.img` will appear as `/dev/vda`

```
qemu-system-x86_64 -enable-kvm -cpu host -smp 2 -m 2G \
	-initrd initrd.gz \
	-kernel linux \
	-append "root=/dev/ram console=ttyS0" \
	-drive file=debian.img,if=virtio \
	-device virtio-net-pci,mac=E2:F2:6A:01:9D:C9,netdev=br0 \
	-netdev bridge,br=br-lan,id=br0 \
	-nographic
```

Follow the installation instructions and install GRUB on `/dev/vda`. It's also useful to install sshd (enabled by default).

### Run the new guest

After finishing the installation, you can launch the new installation with QEMU:

```
qemu-system-x86_64 -enable-kvm -cpu host -smp 2 -m 2G \
	-drive file=debian.img,if=virtio \
	-device virtio-net-pci,mac=E2:F2:6A:01:9D:C9,netdev=br0 \
	-netdev bridge,br=br-lan,id=br0 \
	-nographic
```

You should now be able to reach the VM via SSH from within `br-lan`. If you want to control the VM using the command line, you have to enable a serial console. To do this, edit the GRUB entry during boot and add `console=ttyS0` to the kernel command line. After the VM finished booting, edit `/etc/default/grub` and add `console=ttyS0` to `GRUB_CMDLINE_LINUX_DEFAULT` as well. After that run `update-grub`.

## Init script

To automatically start the VM at boot and shut it down cleanly using [QMP](https://wiki.qemu.org/Documentation/QMP "https://wiki.qemu.org/Documentation/QMP"), create an [init script](/docs/techref/initscripts "docs:techref:initscripts") like the one below.

Be careful with copying the heredoc part. This code block is left unindented on purpose to avoid problems with whitespaces. If you want, you can indent the lines with tabs and use `<<-QMP` instead of `<<QMP`, but since tabs are printed as whitespaces in dokuwiki code blocks, this example is used without indentation. You can read more about here documents in the [advanced bash-scripting guide](http://tldp.org/LDP/abs/html/here-docs.html "http://tldp.org/LDP/abs/html/here-docs.html")

[/etc/init.d/qemu](/_export/code/docs/guide-user/virtualization/qemu_host?codeblock=6 "Download Snippet")

```
#!/bin/sh /etc/rc.common
 
START=99
STOP=1
 
qemu_pidfile="/var/run/qemu.pid"
 
start() {
qemu-system-x86_64 -enable-kvm -cpu host -smp 2 -m 2G \
	-drive file=/dev/sda,cache=none,if=virtio,format=raw \
	-device virtio-net-pci,mac=E2:F2:6A:01:9D:C9,netdev=br0 \
	-netdev bridge,br=br-lan,id=br0 \
	-qmp tcp:127.0.0.1:4444,server,nowait \
	-daemonize &> /var/log/qemu.log
 
/usr/bin/pgrep qemu-system-x86_64 > $qemu_pidfile
echo "QEMU: Started VM with PID $(cat $qemu_pidfile)."
}
 
stop() {
echo "QEMU: Sending 'system_powerdown' to VM with PID $(cat $qemu_pidfile)."
nc localhost 4444 <<QMP 
{ "execute": "qmp_capabilities" } 
{ "execute": "system_powerdown" } 
QMP
 
if [ -e $qemu_pidfile ]; then
	if [ -e /proc/$(cat $qemu_pidfile) ]; then
		echo "QEMU: Waiting for VM shutdown."
		while [ -e /proc/$(cat $qemu_pidfile) ]; do sleep 1s; done
		echo "QEMU: VM Process $(cat $qemu_pidfile) finished."
	else
		echo "QEMU: Error: No VM with PID $(cat $qemu_pidfile) running."
	fi
 
	rm -f $qemu_pidfile
else
	echo "QEMU: Error: $qemu_pidfile doesn't exist."
fi
}
```

Test the the script by running `/etc/init.d/qemu start` and look for errors in `/var/log/qemu.log`. If the script works as desired, enable it for every boot: `/etc/init.d/qemu enable`

![FIXME](/lib/images/smileys/fixme.svg) This script needs to be ported to [procd](/docs/guide-developer/procd-init-scripts "docs:guide-developer:procd-init-scripts"). Problem: [stop\_service() is called after procd killed the service](/docs/guide-developer/procd-init-scripts#stopping_services "docs:guide-developer:procd-init-scripts"), but we must run it beforehand to let the VM shut down.
