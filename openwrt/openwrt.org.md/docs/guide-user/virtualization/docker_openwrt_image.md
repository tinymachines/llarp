# OpenWrt as a Docker Image

See also [Docker OpenWrt Image Generation](/docs/guide-user/virtualization/obtain.firmware.docker "docs:guide-user:virtualization:obtain.firmware.docker").

The goal of this document is to run OpenWrt images on [docker](http://www.docker.io "http://www.docker.io"), a container system based on LXC.

[![](/_media/media/homepage-docker-logo.png)](/_detail/media/homepage-docker-logo.png?id=docs%3Aguide-user%3Avirtualization%3Adocker_openwrt_image "media:homepage-docker-logo.png")

## OpenWrt as a Native Docker Image

**Outdated Information!**  
This article contains information that is outdated or no longer valid. You can edit this page to update it.

This documentation is highly outdated, please consider using [https://github.com/openwrt/docker](https://github.com/openwrt/docker "https://github.com/openwrt/docker")

Import the base image:

```
$ docker import http://downloads.openwrt.org/attitude_adjustment/12.09/x86/generic/openwrt-x86-generic-rootfs.tar.gz openwrt-x86-generic-rootfs
$ docker images
REPOSITORY                           TAG                   IMAGE ID            CREATED             VIRTUAL SIZE
openwrt-x86-generic-rootfs           latest                2cebd16f086c        6 minutes ago       5.283 MB
```

Run a simple cat inside the docker image:

```
root@turmes /home/zoobab/docker [14]# docker run -i openwrt-x86-generic-rootfs cat /etc/banner
  _______                     ________        __
 |       |.-----.-----.-----.|  |  |  |.----.|  |_
 |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
 |_______||   __|_____|__|__||________||__|  |____|
          |__| W I R E L E S S   F R E E D O M
 -----------------------------------------------------
 ATTITUDE ADJUSTMENT (12.09, r36088)
 -----------------------------------------------------
  * 1/4 oz Vodka      Pour all ingredients into mixing
  * 1/4 oz Gin        tin with ice, strain into glass.
  * 1/4 oz Amaretto
  * 1/4 oz Triple sec
  * 1/4 oz Peach schnapps
  * 1/4 oz Sour mix
  * 1 splash Cranberry juice
 -----------------------------------------------------
root@turmes /home/zoobab/docker [15]# 
```

Let's run a basic command:

```
root@turmes /home/zoobab [17]# docker run -i openwrt-x86-generic-rootfs ifconfig
eth0      Link encap:Ethernet  HWaddr F2:06:70:1D:D0:65  
          inet addr:172.17.0.30  Bcast:172.17.255.255  Mask:255.255.0.0
          inet6 addr: fe80::f006:70ff:fe1d:d065/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

root@turmes /home/zoobab [18]# docker run -i openwrt-x86-generic-rootfs /sbin/init
init started: BusyBox v1.19.4 (2013-03-06 20:07:44 UTC)
sysinit: date: can't set kernel time zone: Operation not permitted

sysinit: Loading defaults

sysinit: Loading synflood protection

sysinit: Adding custom chains

sysinit: Loading zones

sysinit: Loading forwardings

sysinit: Loading rules

sysinit: Loading redirects

sysinit: Loading includes

sysinit: Optimizing conntrack

sysinit: Loading interfaces

```

You can also run an interactive shell:

```
root@turmes /home/zoobab [20]# docker run -i -t openwrt-x86-generic-rootfs /bin/ash


BusyBox v1.19.4 (2013-03-06 20:07:44 UTC) built-in shell (ash)
Enter 'help' for a list of built-in commands.

/ # ps
  PID USER       VSZ STAT COMMAND
    1 root      1248 S    /bin/ash
    6 root      1248 R    ps
/ # 
```

There seems to be an issue with /var subdirs not created:

```
/ # ifconfig
eth0      Link encap:Ethernet  HWaddr 02:51:6F:E7:12:0A  
          inet addr:172.17.0.44  Bcast:172.17.255.255  Mask:255.255.0.0
          inet6 addr: fe80::51:6fff:fee7:120a/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:25 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:15551 (15.1 KiB)  TX bytes:648 (648.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

/ # opkg update
Collected errors:
 * opkg_conf_load: Could not create lock file /var/lock/opkg.lock: No such file or directory.
/ # mkdir -p /var/lock
/ # ls
bin      dev      etc      lib      mnt      overlay  proc     rom      root     sbin     sys      tmp      usr      var      www
/ # opkg update
Downloading http://downloads.openwrt.org/attitude_adjustment/12.09/x86/generic/packages/Packages.gz.
Updated list of available packages in /var/opkg-lists/attitude_adjustment.
/ # 
```

Let's change the root password and try to setup dropbear to connect over ssh:

```
/ # passwd
Changing password for root
New password: 
Bad password: too weak
Retype password: 
Password for root changed by root
/ # ps
  PID USER       VSZ STAT COMMAND
    1 root      1252 S    /bin/ash
   21 root      1248 R    ps
/ # /etc/init.d/dropbear restart
/ # ps
  PID USER       VSZ STAT COMMAND
    1 root      1260 S    /bin/ash
   44 root       960 S    /usr/sbin/dropbear -P /var/run/dropbear.1.pid -p 22
   45 root      1248 R    ps
/ #
```

Leave the console OPENED, and in another terminal, try to SSH to the IP address:

```
zoobab@turmes /home/zoobab [2]$ ssh root@172.17.0.45
root@172.17.0.45's password: 


BusyBox v1.19.4 (2013-03-06 20:07:44 UTC) built-in shell (ash)
Enter 'help' for a list of built-in commands.

  _______                     ________        __
 |       |.-----.-----.-----.|  |  |  |.----.|  |_
 |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
 |_______||   __|_____|__|__||________||__|  |____|
          |__| W I R E L E S S   F R E E D O M
 -----------------------------------------------------
 ATTITUDE ADJUSTMENT (12.09, r36088)
 -----------------------------------------------------
  * 1/4 oz Vodka      Pour all ingredients into mixing
  * 1/4 oz Gin        tin with ice, strain into glass.
  * 1/4 oz Amaretto
  * 1/4 oz Triple sec
  * 1/4 oz Peach schnapps
  * 1/4 oz Sour mix
  * 1 splash Cranberry juice
 -----------------------------------------------------
root@17691dbb9d9a:~# 
```

Now let's install one package:

```
root@17691dbb9d9a:~# opkg update
Collected errors:
 * opkg_conf_load: Could not create lock file /var/lock/opkg.lock: No such file or directory.
root@17691dbb9d9a:~# mkdir /var/lock
root@17691dbb9d9a:~# opkg update
Downloading http://downloads.openwrt.org/attitude_adjustment/12.09/x86/generic/packages/Packages.gz.
Updated list of available packages in /var/opkg-lists/attitude_adjustment.
root@17691dbb9d9a:~# opkg install 
root@17691dbb9d9a:~# ps
  PID USER       VSZ STAT COMMAND
    1 root      1260 S    /bin/ash
   30 root       960 S    /usr/sbin/dropbear -P /var/run/dropbear.1.pid -p 22
   38 root      1032 S    /usr/sbin/dropbear -P /var/run/dropbear.1.pid -p 22
   39 root      1256 S    -ash
   48 root      1248 R    ps
root@17691dbb9d9a:~# opkg install lighttpd
Installing lighttpd (1.4.30-2) to root...
Downloading http://downloads.openwrt.org/attitude_adjustment/12.09/x86/generic/packages/lighttpd_1.4.30-2_x86.ipk.
Installing libopenssl (1.0.1e-1) to root...
Downloading http://downloads.openwrt.org/attitude_adjustment/12.09/x86/generic/packages/libopenssl_1.0.1e-1_x86.ipk.
Installing zlib (1.2.7-1) to root...
Downloading http://downloads.openwrt.org/attitude_adjustment/12.09/x86/generic/packages/zlib_1.2.7-1_x86.ipk.
Installing libpcre (8.11-2) to root...
Downloading http://downloads.openwrt.org/attitude_adjustment/12.09/x86/generic/packages/libpcre_8.11-2_x86.ipk.
Installing libpthread (0.9.33.2-1) to root...
Downloading http://downloads.openwrt.org/attitude_adjustment/12.09/x86/generic/packages/libpthread_0.9.33.2-1_x86.ipk.
Configuring libpthread.
Configuring libpcre.
Configuring zlib.
Configuring libopenssl.
Configuring lighttpd.
root@17691dbb9d9a:~#
```

I published a docker image:

```
docker pull  zoobab/openwrt-x86-attitude
```

Example to get a shell:

```
root@turmes /home/zoobab [4]# docker run -i -t zoobab/openwrt-x86-attitude /bin/ash


BusyBox v1.19.4 (2013-03-06 20:07:44 UTC) built-in shell (ash)
Enter 'help' for a list of built-in commands.

/ # ls
bin      dev      etc      lib      mnt      overlay  proc     rom      root     sbin     sys      tmp      usr      var      www
/ # ifconfig
eth0      Link encap:Ethernet  HWaddr E6:7A:80:85:59:68  
          inet addr:172.17.0.46  Bcast:172.17.255.255  Mask:255.255.0.0
          inet6 addr: fe80::e47a:80ff:fe85:5968/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:12 errors:0 dropped:0 overruns:0 frame:0
          TX packets:4 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:7069 (6.9 KiB)  TX bytes:328 (328.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

/ # 
```

### Todolist

- Fix /sbin/init to get the openwrt banner and shell at the end?
- Fix the /var entries: mkdir /var/run &amp;&amp; mkdir /var/lock
- Change the build to generate some images with dev entries
- Get the LUCI web interface to work
- publish more images with x64 and/or x32 arch
- publish images with a different arch via qemu ([http://dktrkranz.wordpress.com/2013/11/19/cross-architecture-linux-containers-in-debian/](http://dktrkranz.wordpress.com/2013/11/19/cross-architecture-linux-containers-in-debian/ "http://dktrkranz.wordpress.com/2013/11/19/cross-architecture-linux-containers-in-debian/"))
- publish images with interesting profiles (lighttpd dirlist server, ftpd server, ircd server, tor server, etc...)

### Links

- [https://hub.docker.com/r/zoobab/openwrt-15.05.1-x86-64-rootfs/](https://hub.docker.com/r/zoobab/openwrt-15.05.1-x86-64-rootfs/ "https://hub.docker.com/r/zoobab/openwrt-15.05.1-x86-64-rootfs/")

### Example Dockerfile

Note the use of “exec format” for the CMD which properly makes /sbin/init proc 1 and boots all services (fixing many issues).

```
FROM scratch
ADD https://downloads.openwrt.org/chaos_calmer/15.05/x86/generic/openwrt-15.05-x86-generic-Generic-rootfs.tar.gz /

EXPOSE 80

RUN mkdir /var/lock && \
    opkg update && \
    opkg install uhttpd-mod-lua && \
    uci set uhttpd.main.interpreter='.lua=/usr/bin/lua' && \
    uci commit uhttpd

USER root

# using exec format so that /sbin/init is proc 1 (see procd docs)
CMD ["/sbin/init"]
```

## OpenWrt in QEMU in Docker

This section provides example Docker files to run OpenWrt inside QEMU inside a Docker container.

This provides all the power and configurability of regular OpenWrt (firewall, kernel modules etc), with the only drawback being the slower emulation speed (unless KVM is enabled). This method allows OpenWrt to easily run in standard container clusters (e.g. Kubernetes) without any additional permissions and can provide various services through exposed ports (e.g. VoIP, VPN, etc).

Example build and usage:

```
docker build . -t openwrt_in_qemu
docker run --name my_openwrt -p 30022:30022 -p 30080:30080 openwrt_in_qemu
```

```
docker exec -ti my_openwrt /bin/sh
socat -,raw,echo=0,icanon=0 unix-connect:/tmp/qemu-console.sock
```

### OpenWrt in QEMU in Docker: Simple Example

```
# syntax=docker/dockerfile:1
#
# This Dockerfile creates a container image running OpenWrt in a QEMU VM.
# https://openwrt.org/docs/guide-user/virtualization/docker_openwrt_image
#
# To connect to the VM serial console, connect to the running container
# and execute this command:
#
#     socat -,raw,echo=0,icanon=0 unix-connect:/tmp/qemu-console.sock
#     socat -,echo=0,icanon=0 unix-connect:/tmp/qemu-monitor.sock
#
# To enable remote admin, set a password on the root account:
#
#     passwd
#
# and enable HTTP and SSH on the WAN interface exposed by QEMU to the
# container:
#
#     uci add firewall rule
#     uci set firewall.@rule[-1].name='Allow-Admin'
#     uci set firewall.@rule[-1].enabled='true'
#     uci set firewall.@rule[-1].src='wan'
#     uci set firewall.@rule[-1].proto='tcp'
#     uci set firewall.@rule[-1].dest_port='22 80'
#     uci set firewall.@rule[-1].target='ACCEPT'
#     service firewall restart

FROM docker.io/library/alpine:3.15

RUN apk add --no-cache \
        curl \
        qemu-system-x86_64 \
        qemu-img \
        socat \
        && \
    rm -f /usr/share/qemu/edk2-*

ENV IMAGE_URL="https://downloads.openwrt.org/releases/21.02.3/targets/x86/64/openwrt-21.02.3-x86-64-generic-ext4-combined.img.gz"
ENV IMAGE_FILE="openwrt-21.02.3-x86-64-generic-ext4-combined.img.gz"
ENV IMAGE_SHA256="f5a0401048d6fb3f707581c4914086093fecea642c86507714caea967a4a6a32"

WORKDIR /var/lib/qemu-image
RUN curl -L "${IMAGE_URL}" -o "${IMAGE_FILE}" && \
    sh -x -c '[ "$(sha256sum "${IMAGE_FILE}")" = "${IMAGE_SHA256}  ${IMAGE_FILE}" ]'

RUN echo -e '#!/bin/sh\n\
set -ex \n\
if [ ! -f /var/lib/qemu/image.qcow2 ]; then \n\
    gunzip --stdout "/var/lib/qemu-image/${IMAGE_FILE}" > /var/lib/qemu/image.raw || true \n\
    qemu-img convert -f raw -O qcow2 /var/lib/qemu/image.raw /var/lib/qemu/image.qcow2 \n\
    rm /var/lib/qemu/image.raw \n\
    qemu-img resize /var/lib/qemu/image.qcow2 1G \n\
fi \n\
exec /usr/bin/qemu-system-x86_64 \\\n\
    -nodefaults \\\n\
    -display none \\\n\
    -m 256M \\\n\
    -smp 2 \\\n\
    -nic "user,model=virtio,restrict=on,ipv6=off,net=192.168.1.0/24,host=192.168.1.2" \\\n\
    -nic "user,model=virtio,net=172.16.0.0/24,hostfwd=tcp::30022-:22,hostfwd=tcp::30080-:80,hostfwd=tcp::30443-:443" \\\n\
    -chardev socket,id=chr0,path=/tmp/qemu-console.sock,mux=on,logfile=/dev/stdout,signal=off,server=on,wait=off \\\n\
    -serial chardev:chr0 \\\n\
    -monitor unix:/tmp/qemu-monitor.sock,server,nowait \\\n\
    -drive file=/var/lib/qemu/image.qcow2,if=virtio \\\n\
\n' > /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 30022
EXPOSE 30080
EXPOSE 30443
VOLUME /var/lib/qemu
WORKDIR /tmp
USER 1001
CMD ["/usr/local/bin/entrypoint.sh"]
```

### OpenWrt in QEMU in Docker: Advanced Example

This Docker image is similar to the above, with a few more features:

- Support arbitrary container user IDs
- Tunable QEMU configuration
- A SPICE console + USB redirection
- KVM acceleration support
- Custom VM initialization scripts (e.g. from a Kubernetes ConfigMap)
- Default admin firewall rules and disk resizing
- Healthchecks

```
# syntax=docker/dockerfile:1
#
# This Dockerfile creates a container image running OpenWRT in a QEMU VM.
# https://openwrt.org/docs/guide-user/virtualization/docker_openwrt_image
# This can be run on regular container clusters (e.g. Kubernetes,OpenShift)
# without any special permissions.
#
#   docker build . -t openwrt_in_qemu
#   docker run --name my_openwrt -p 30022:30022 -p 30080:30080 openwrt_in_qemu
#
# For VGA console access and USB redirection, connect with a SPICE client 
# (e.g. "remote-viewer") on port 5900.
#
# To connect to the VM serial console, connect to the running container
# and execute one of these commands:
#
#   socat -,raw,echo=0,icanon=0 unix-connect:/tmp/qemu-console.sock
#   socat -,echo=0,icanon=0 unix-connect:/tmp/qemu-monitor.sock
#
# To use KVM acceleration, add these to your docker/podman arguments:
#
#   docker --env QEMU_ARGS="-enable-kvm" --device=/dev/kvm --group-add "$(getent group kvm | cut -d: -f3)"
#
# Volumes:
#
#   /var/lib/qemu:
#     The VM disk image.
#     
#   /var/lib/vmconfig:
#     You can use a shared volume/ConfigMap/etc to provide custom initial
#     configuration. The $CWD of these files is the parent vmconfig dir,
#     which you can use to provide other files. For testing, start docker 
#     with "--volume /tmp/my_config:/var/lib/vmconfig:z"
#
#     container.d: Scripts run on the container before config is sent to the VM
#     vm.d: Scripts run on the VM

FROM docker.io/library/alpine:3.16

# Install QEMU, remove large unnecessary files
RUN apk add --no-cache \
        curl \
        make \
        qemu-chardev-spice \
        qemu-hw-display-virtio-vga \
        qemu-hw-usb-redirect \
        qemu-img \
        qemu-system-x86_64 \
        qemu-ui-spice-core \
        socat \
        && \
    rm -f /usr/share/qemu/edk2-*

# Download OpenWRT image
ENV IMAGE_URL="https://downloads.openwrt.org/releases/21.02.3/targets/x86/64/openwrt-21.02.3-x86-64-generic-ext4-combined.img.gz"
ENV IMAGE_FILE="openwrt-21.02.3-x86-64-generic-ext4-combined.img.gz"
ENV IMAGE_SHA256="f5a0401048d6fb3f707581c4914086093fecea642c86507714caea967a4a6a32"

WORKDIR /var/lib/qemu-image

RUN curl -L "${IMAGE_URL}" -o "${IMAGE_FILE}" && \
    sh -x -c '[ "$(sha256sum "${IMAGE_FILE}")" = "${IMAGE_SHA256}  ${IMAGE_FILE}" ]'

# Support Arbitrary User IDs in container
RUN echo -e '#!/bin/sh\n\
set -ex \n\
if ! whoami &> /dev/null; then \n\
  if [ -w /etc/passwd ]; then \n\
    echo "container:x:$(id -u):0:Container User:/tmp:/sbin/nologin" >> /etc/passwd \n\
    echo "container:x:$(id -u):$(id -u)" >> /etc/group \n\
  fi \n\
fi \n\
\n' > /usr/local/bin/create-container-user.sh && \
    chmod +x /usr/local/bin/create-container-user.sh && \
    chmod g=u /etc/passwd && \
    chmod g=u /etc/group

# Provision VM disk image
RUN echo -e '#!/bin/sh\n\
set -ex \n\
if [ ! -f /var/lib/qemu/image.qcow2 ]; then \n\
    gunzip --stdout "/var/lib/qemu-image/${IMAGE_FILE}" > /var/lib/qemu/image.raw || true \n\
    qemu-img convert -f raw -O qcow2 /var/lib/qemu/image.raw /var/lib/qemu/image.qcow2 \n\
    rm /var/lib/qemu/image.raw \n\
fi \n\
if [ -n "${QEMU_STORAGE}" ]; then \n\
    qemu-img resize /var/lib/qemu/image.qcow2 "${QEMU_STORAGE}" \n\
fi \n\
\n' > /usr/local/bin/provision-image.sh && \
    chmod +x /usr/local/bin/provision-image.sh

# Create default VM configuration scripts
RUN mkdir -p /usr/local/share/vmconfig/container.d /usr/local/share/vmconfig/vm.d

RUN echo -e '#!/bin/sh\n\
set -e \n\
cat > vm.d/20-hostname.sh <<EOF\n\
#!/bin/sh \n\
set -e \n\
uci set system.@system[0].hostname="$QEMU_HOSTNAME" \n\
uci commit system \n\
EOF\n\
chmod +x vm.d/20-hostname.sh \n\
\n\' > /usr/local/share/vmconfig/container.d/20-hostname.sh && \
    chmod +x /usr/local/share/vmconfig/container.d/20-hostname.sh

RUN echo -e '#!/bin/sh\n\
set -e \n\
cat > vm.d/20-password.sh <<EOF\n\
#!/bin/sh \n\
set -e \n\
echo -e "$QEMU_PASSWORD\\n$QEMU_PASSWORD" | passwd \n\
EOF\n\
chmod +x vm.d/20-password.sh \n\
\n\' > /usr/local/share/vmconfig/container.d/20-password.sh && \
    chmod +x /usr/local/share/vmconfig/container.d/20-password.sh

RUN echo -e '#!/bin/sh\n\
set -ex \n\
uci add firewall rule \n\
uci set firewall.@rule[-1].name="Allow-Admin" \n\
uci set firewall.@rule[-1].enabled="true" \n\
uci set firewall.@rule[-1].src="wan" \n\
uci set firewall.@rule[-1].proto="tcp" \n\
uci set firewall.@rule[-1].dest_port="22 80 443" \n\
uci set firewall.@rule[-1].target="ACCEPT" \n\
uci commit firewall \n\
\n\' > /usr/local/share/vmconfig/vm.d/20-firewall.sh && \
    chmod +x /usr/local/share/vmconfig/vm.d/20-firewall.sh

RUN echo -e '#!/bin/sh\n\
set -ex \n\
ubus wait_for network.interface.wan \n\
sleep 3 \n\
opkg update \n\
\n\' > /usr/local/share/vmconfig/vm.d/30-wait-for-network.sh && \
chmod +x /usr/local/share/vmconfig/vm.d/30-wait-for-network.sh

RUN echo -e '#!/bin/sh\n\
set -ex \n\
opkg install partx-utils resize2fs sfdisk tune2fs \n\
echo "- +" | sfdisk --force -N 2 /dev/vda \n\
partx -u /dev/vda \n\
mount -o remount,ro / \n\
tune2fs -O^resize_inode /dev/vda2 \n\
e2fsck -y -f /dev/vda2 || true \n\
mount -o remount,rw / \n\
resize2fs /dev/vda2 \n\
\n\' > /usr/local/share/vmconfig/vm.d/40-resize-disk.sh && \
chmod +x /usr/local/share/vmconfig/vm.d/40-resize-disk.sh

# Write VM configuration archive as serial console commands to STDOUT
RUN echo -e '#!/bin/sh\n\
set -e \n\
cat <<EOF\n\
\n\
echo "require \\"nixio\\"; io.stdin:setvbuf \\"no\\"; io.write(nixio.bin.b64decode(io.read()));" > /tmp/base64_decode.lua \n\
lua /tmp/base64_decode.lua > /tmp/vmconfig.tgz \n\
EOF\n\
tar -zcv -C "$1" . | base64 -w0 \n\
cat <<EOF\n\
\n\
mkdir /tmp/vmconfig \n\
tar -zxvf /tmp/vmconfig.tgz -C /tmp/vmconfig \n\
sleep 5 \n\
(cd /tmp/vmconfig && (for f in \$(ls vm.d); do echo "Executing ./vm.d/\$f"; "./vm.d/\$f" || exit 1; done)) && echo -e "\\nVM configuration result: successful." || echo -e "\\nVM configuration result: failed." \n\
poweroff \n\
EOF\n\
\n' > /usr/local/bin/serialize-vm-config.sh && \
    chmod +x /usr/local/bin/serialize-vm-config.sh

# Send configuration archive to VM using serial console
RUN echo -e '#!/bin/sh\n\
set -ex \n\
echo "Discovered vmconfig:" \n\
find /var/lib/vmconfig \n\
sleep 5 \n\
rm -rf /tmp/vmconfig \n\
cp -rv /var/lib/vmconfig /tmp/vmconfig \n\
mkdir -p /tmp/vmconfig/container.d /tmp/vmconfig/vm.d \n\
if [ -z "$QEMU_CONFIG_NO_DEFAULTS" ]; then \n\
    cp /usr/local/share/vmconfig/container.d/* /tmp/vmconfig/container.d \n\
    cp /usr/local/share/vmconfig/vm.d/* /tmp/vmconfig/vm.d \n\
fi \n\
(cd /tmp/vmconfig && (for f in $(ls container.d); do "./container.d/$f"; done)) \n\
run-vm.sh & \n\
QEMU_PID="$!" \n\
sleep 5 \n\
socat STDOUT unix-connect:/tmp/qemu-console.sock | grep -q "Please press Enter to activate this console." \n\
serialize-vm-config.sh /tmp/vmconfig | socat STDIN unix-connect:/tmp/qemu-console.sock \n\
VM_CONFIG_RESULT="$(socat STDOUT unix-connect:/tmp/qemu-console.sock | grep -m1 "^VM configuration result:")" \n\
if test "${VM_CONFIG_RESULT#*failed}" != "$VM_CONFIG_RESULT"; then \n\
    exit 1 \n\
fi \n\
wait "$QEMU_PID" \n\
\n' > /usr/local/bin/send-config-to-vm.sh && \
    chmod +x /usr/local/bin/send-config-to-vm.sh

# Start VM in QEMU
RUN echo -e '#!/bin/sh\n\
set -e \n\
printf "$QEMU_PASSWORD" > /tmp/qemu-password.txt \n\
set -x \n\
exec /usr/bin/qemu-system-x86_64 \\\n\
    -nodefaults \\\n\
    -smp ""${QEMU_SMP}"" \\\n\
    -m "${QEMU_MEMORY}" \\\n\
    -drive file=/var/lib/qemu/image.qcow2,if=virtio \\\n\
    -chardev socket,id=chr0,path=/tmp/qemu-console.sock,mux=on,logfile=/dev/stdout,signal=off,server=on,wait=off \\\n\
    -serial chardev:chr0 \\\n\
    -monitor unix:/tmp/qemu-monitor.sock,server,nowait \\\n\
    -nic "user,model=virtio,restrict=on,ipv6=off,net=192.168.1.0/24,host=192.168.1.2,${QEMU_LAN_OPTIONS}" \\\n\
    -nic "user,model=virtio,net=${QEMU_WAN_NETWORK},${QEMU_WAN_OPTIONS}" \\\n\
    -object secret,id=secvnc0,format=raw,file=/tmp/qemu-password.txt \\\n\
    -display none \\\n\
    -device virtio-vga \\\n\
    -spice port=5900,password-secret=secvnc0 \\\n\
    -device intel-hda \\\n\
    -device hda-duplex \\\n\
    -device ich9-usb-ehci1,id=usb \\\n\
    -device ich9-usb-uhci1,masterbus=usb.0,firstport=0,multifunction=on \\\n\
    -device ich9-usb-uhci2,masterbus=usb.0,firstport=2 \\\n\
    -chardev spicevmc,name=usbredir,id=usbredirchardev1 \\\n\
    -device usb-redir,chardev=usbredirchardev1,id=usbredirdev1 \\\n\
    -chardev spicevmc,name=usbredir,id=usbredirchardev2 \\\n\
    -device usb-redir,chardev=usbredirchardev2,id=usbredirdev2 \\\n\
    $QEMU_ARGS \\\n\
\n' > /usr/local/bin/run-vm.sh && \
    chmod +x /usr/local/bin/run-vm.sh

# Healthcheck
RUN echo -e '#!/bin/sh\n\
set -ex \n\
[ -e /tmp/qemu-console.sock -a -f /var/lib/qemu/initialized ] \n\
curl -sSf -m 5 http://127.0.0.1:30080 > /dev/null \n\
\n' > /usr/local/bin/healthcheck-vm.sh && \
    chmod +x /usr/local/bin/healthcheck-vm.sh

# Entrypoint
RUN echo -e '#!/bin/sh\n\
set -ex \n\
create-container-user.sh \n\
provision-image.sh \n\
if [ ! -f /var/lib/qemu/initialized ]; then \n\
    timeout -s SIGINT "$QEMU_CONFIG_TIMEOUT" send-config-to-vm.sh || (echo "VM config error or time out."; exit 1) \n\
    touch /var/lib/qemu/initialized \n\
    chmod g+rw /var/lib/qemu/* \n\
fi \n\
exec run-vm.sh \n\
\n' > /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

# Runtime configuration
ENV QEMU_MEMORY="256M"
ENV QEMU_STORAGE="1G"
ENV QEMU_SMP="2"
ENV QEMU_LAN_OPTIONS=""
ENV QEMU_WAN_NETWORK="172.16.0.0/24"
ENV QEMU_WAN_OPTIONS="hostfwd=tcp::30022-:22,hostfwd=tcp::30080-:80,hostfwd=tcp::30443-:443,hostfwd=udp::51820-:51820"
ENV QEMU_PASSWORD="pass1234"
ENV QEMU_CONFIG_TIMEOUT="300"
ENV QEMU_CONFIG_NO_DEFAULTS=""
ENV QEMU_HOSTNAME="OpenWrtVM"
ENV QEMU_ARGS=""

EXPOSE 5900/tcp
EXPOSE 30022/tcp
EXPOSE 30080/tcp
EXPOSE 30443/tcp
EXPOSE 51820/udp

HEALTHCHECK --interval=30s --timeout=30s --start-period=120s --retries=3 CMD [ "/usr/local/bin/healthcheck-vm.sh" ]
VOLUME /var/lib/vmconfig
VOLUME /var/lib/qemu
WORKDIR /tmp
USER 1001
CMD ["/usr/local/bin/entrypoint.sh"]
```
