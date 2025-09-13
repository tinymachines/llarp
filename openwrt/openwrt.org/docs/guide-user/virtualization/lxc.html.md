# OpenWrt in LXC containers

OpenWrt can run inside an LXC container, using the same kernel as running on the host system. This can be useful for development as well as for VM hosting.

You may also benefit from better performance, bigger memory, and bigger storage, found in pfSense/OPNsense appliances and Mini PCs, commonly found for purchase, and replace their OS with a Linux distro plus an OpenWrt container.

## Installation

The following gives a rough idea on how to get things up and running. Before anything, install LXC on the host machine and make sure it supports running unprivileged containers. You will likely also need bridge functionality and/or additional underlying related subsystems (macvlan, etc.) if used.

### Via image

For some (*amd64*, *arm*...) architectures, the *download* template allows to retrieve an OpenWrt image from the [remote mirror](https://images.linuxcontainers.org/ "https://images.linuxcontainers.org/"). To create the OpenWrt container, just do:

```
lxc-create -n <container_name> -t download -- -d openwrt -a amd64
```

and spell the release you want to install when asked to. For any error related to fetching the GPG key, just specify a different keyserver (e.g. keyserver.ubuntu.com) by either setting `DOWNLOAD_KEYSERVER` or appending the `--keyserver` option.

The container will be created according to your default LXC config files (unless you use `--config` to specify a different config), so you may probably want to customize it further (e.g. add network interfaces or mount points) by modifying the final config in the container directory (see *lxc.container.conf(5)* man page). Depending on your setup, you may need to `attach` and temporarily give a fixed IP address to the relevant interface in order to establish the first connection.

### Via rootfs extraction

For all other architectures, some manual steps are required:

1. Create the VM folder manually at `.local/share/lxc/<vm-name>/`
2. Download a snapshot rootfs of OpenWrt and unpack it to `.local/share/lxc/<vm-name>/rootfs`
3. Create a `.local/share/lxc/<vm-name>/config` containing the following content:
   
   ```
   lxc.include = /etc/lxc/default.conf
   lxc.include = /usr/share/lxc/config/common.conf
   lxc.include = /usr/share/lxc/config/userns.conf
   lxc.arch = linux64
   
   # find your ids via
   # cat  /etc/s*id|grep $USER
   lxc.idmap = u 0 100000 65536
   lxc.idmap = g 0 100000 65536
   
   lxc.mount.auto = proc:mixed sys:ro cgroup:mixed
   
   # lan interface
   lxc.net.0.type = veth
   
   # wan interface
   lxc.net.1.type = veth
   lxc.net.1.link = lxcbr0
   
   # adapt <user> and <vm-name>
   lxc.rootfs.path = dir:/home/<user>/.local/share/lxc/<vm-name>/rootfs
   ```
4. run `chmod` on the rootfs folder with the id you obtained earlier
5. run `lxc-start -n <vm-name>`
6. run `lxc-attach -n <vm-name>`

## Upgrading

### Via OPKG

Just edit all repositories versions at `/etc/opkg/distfeeds.conf` (e.g. from `/releases/24.10.0` to `/releases/24.10.1`), then run:

```
opkg update
opkg list-upgradable | cut -d ' ' -f 1 | xargs opkg upgrade --force-depends
```

Kernel modules will fail to upgrade as the `kernel` package isn't available in the package list. You can ignore these failings as the host modules are used instead.

Alternatively, upgrade the `kernel` by downloading it directly from [https://downloads.openwrt.org/releases/24.10.2/targets/x86/64/packages](https://downloads.openwrt.org/releases/24.10.2/targets/x86/64/packages "https://downloads.openwrt.org/releases/24.10.2/targets/x86/64/packages") with `wget` and installing via `opkg install`, for example:

```
wget https://mirror-03.infra.openwrt.org/releases/24.10.2/targets/x86/64/packages/kernel_6.6.93~1745ebad77278f5cdc8330d17a3f43d6-r1_x86_64.ipk
opkg install kernel_6.6.93~1745ebad77278f5cdc8330d17a3f43d6-r1_x86_64.ipk
```

### Reinstall

Once a new release becomes available, as announced by the OpenWrt team, you can install and migrate to it:

1. install the new release image as above (it will typically be available within the next day)
2. replace the new container's config file with the old one (remember to edit relevant options if needed e.g. the rootfs path, the host name, the autostart flag...)
3. backup the settings of the currently running OpenWrt as you would usually do, and shut it down
4. start the new container and, if it's safe to do so (as it usually is for minor releases), restore OpenWrt settings from backup

Note: if you are still getting the previous image after more than 24h since the new release (images are currently built daily by lxc), chances are an old cached image is being used. In this case, you can delete the old image by appending the `--flush-cache` option to the command.

## Configuration

### Start on boot

To load the OpenWrt container with the host system boot, add to the LXC config:

```
lxc.start.auto = 1
```

### Physical port assignment

Giving the OpenWrt container full control over some physical ports is often useful. You can map the host interfaces to container named interfaces with the following config:

```
# Interface 1: Host en2s0 -> Container wan
lxc.net.1.hwaddr = AA:BB:CC:DD:EE:FF
lxc.net.1.type = phys
lxc.net.1.link = enp2s0
lxc.net.1.name = wan
lxc.net.1.flags = up
# Interface 2: Host eno1 -> Container lan1
lxc.net.2.type = phys
lxc.net.2.link = eno1
lxc.net.2.name = lan1
lxc.net.2.flags = up
```

### Host &lt;=&gt; OpenWrt connection

To connect OpenWrt with the host, and vice-versa, using a LAN IP, which is useful to offer OpenWrt visibility and redirection abilities to the host, you can use directly the LXC bridge, so you don't need another physical port, which might be a bottleneck.

1\. Configure the LXC network interface:

```
# host lan configuration
lxc.net.0.type = veth
lxc.net.0.link = lxcbr0
lxc.net.0.name = lan-host
lxc.net.0.flags = up
```

2\. Configure a static IP with LXC-NET bridge at `/etc/default/lxc-net`. Replace `LXC_ADDR` IP with a desired IP inside your LAN IP range.

```
USE_LXC_BRIDGE="true"
LXC_BRIDGE="lxcbr0"
LXC_ADDR="10.0.0.2"
LXC_NETMASK="255.255.255.0"
LXC_NETWORK="10.0.0.0/24"
```

Restart the `lxc` and the `lxc-net` services. (e.g. with `sudo systemctl restart lxc-net lxc`)

3\. In OpenWrt, add the device `lan-host` device to the `br-lan` bridge. There is no need to configure an interface for it.

Now the OpenWrt container should be able to ping the host IP (specified above at `LXC_ADDR`), and vice-versa.

### IPv6 RA conflict

LXC-NET advertises IPv6 RA and likely will conflict with OpenWrt IPv6 RA configuration.

Disabling LXC's IPv6 is an easy workaround, adding `LXC_IPV6_ENABLE=“false”` to `/etc/default/lxc-net`. This requires LXC 6.0.4 or greater.

### PPPoE use

PPPoE WAN interface requires the kernel device `/dev/ppp`. You need to mount the device in the LXC configuration file:

```
lxc.cgroup2.devices.allow = c 108:* rwm
lxc.mount.entry = /dev/ppp dev/ppp none bind,create=file
```

### Modules load

OpenWRT can't load modules through the container. Instead, you must load them manually on the host. To load them on boot automatically, create the file `/etc/modules-load.d/openwrt.conf` with a list of modules required, for example:

```
pppoe
pppox
wireguard
br-netfilter
8021q
```
