# OpenWrt as Docker container host

[Docker](https://docs.docker.com/get-started/docker-overview/#docker-architecture "https://docs.docker.com/get-started/docker-overview/#docker-architecture") uses OS-level virtualization to deliver software in packages called containers. This is used to automate deployment of applications so that they work efficiently in different environments in isolation. To run containers, users may install Docker Community Edition, use native OpenWrt tools, or Podman. While Docker CE is perhaps the most typical method, this guide covers several options.

## Prerequisites

For devices with small flash partitions you may need to add [external storage](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives") for the containers and data.

Also in many cases you will be running the container as a specific user that will need access to some folder outside the container for its configuration and data. So you will probably need to [create new users and groups](/docs/guide-user/additional-software/create-new-users "docs:guide-user:additional-software:create-new-users") for applications, create folders, and then change the owner of these folders to the user who will run the container.

## Docker Community Edition

First install dockerd, `opkg install dockerd`. This daemon provides the [Docker Engine API](https://docs.docker.com/engine/api/ "https://docs.docker.com/engine/api/") and manages Docker objects such as images, containers, networks, and volumes.

Then you need a client, e.g. docker, `opkg install docker` to connect to the daemon and start containers. This client is command line based.

For a LuCI web client install luci-app-dockerman, `opkg install luci-app-dockerman`. This package will also install dockerd and docker-compose as dependencies. It can work with dockerd on local and remote hosts. The default folder for docker in dockerman is **/opt/docker/** so mount your storage at **/opt** or change the folder in **Docker** &gt; **Overview** &gt; **Docker Root Dir** then restart the dockerd service.

### Adding images

Search for an image on [Docker Hub](https://hub.docker.com/ "https://hub.docker.com/"), then copy the image name from the **Docker Pull Command** text box. For example, if the text is **docker pull linuxserver/transmission**, then copy **linuxserver/transmission**.

In Luci go to **Docker** &gt; **Images** and paste that text in the **Pull Image** box, then click **Pull**. The page will show the download progress.

Note for larger container pulls LuCI could timeout, so you will need to use the command line. For example, Unifi-network-application includes java runtime environment and approaches 500MB. For this use SSH and enter: `docker pull lscr.io/linuxserver/unifi-network-application:latest`.

Once you have your images, in Luci go to **Docker** &gt; **Containers** &gt; **Add**. In the new container page select the docker image from the **Docker Image** menu, then set all other parameters (usually the available/useful parameters are described in the description of the container on Docker Hub), then press Submit to create the container.

### Configure the Docker daemon

Config is located in `/etc/config/dockerd`.

- `data_root` a folder where to store images and containers. It's also mounted by a docker. You may want to change it to a USB disk. It's file system can't be fat or ntfs. By default `/opt/docker/`
- `log_level` Default `warn`.
- `hosts` an API listener. By default is used a UNIX socket `/var/run/docker.sock`.
- `iptables` Enable iptables rules. Default `1`
- `bip` network bridge IP. Default `172.18.0.1/24`
- `fixed_cidr` Allocate IPs from a range. Default `172.17.0.0/16`
- `fixed_cidr_v6` same as fixed\_cidr for IPv6. Default 'fc00:1::/80'
- `ipv6` Enable IPv6 networking. Default `1`
- `ip` Default `::ffff:0.0.0.0`
- `dns` DNS Servers. Default `172.17.0.1`
- `registry_mirrors` URL of a registries. Default `https://hub.docker.com`

The following settings require a restart of docker to take full effect, A reload will only have partial or no effect:

- bip
- blocked\_interfaces
- extra\_iptables\_args
- device

## Native OpenWrt tools

Instead of running Docker CE users may want to use the procd init system which supports Open Container Initiative Runtime Specification set by [Opencontainers.org](https://opencontainers.org/ "https://opencontainers.org/"). This extends its slim containers ('ujail') capability. The uxc command line tool handles the basic operations on containers as defined by the spec. This allows to use it as a drop-in replacement for Docker's 'runc' (or 'crun') on OpenWrt hosts with a reduced footprint.

Detailed but possibly outdated info available on [https://gitlab.com/prpl-foundation/prplos/prplos/-/wikis/uxc](https://gitlab.com/prpl-foundation/prplos/prplos/-/wikis/uxc "https://gitlab.com/prpl-foundation/prplos/prplos/-/wikis/uxc")

### Install packages

Install the following:

```
opkg install kmod-veth uxc procd-ujail procd-ujail-console
```

### Create veth pair for container

```
uci batch <<EOF
set network.veth0=device
set network.veth0.type='veth'
set network.veth0.name='vhost0'
set network.veth0.peer_name='virt0'
add_list network.lan.ifname='vhost0'
set network.virt0=interface
set network.virt0.ifname='virt0'
set network.virt0.proto='none'
# set proto='none' assuming DHCP client inside container
# use 'static' otherwise and also set ipaddr, gateway and dns
set network.virt0.jail='container1'
set network.virt0.jail_ifname='host0'
commit network
EOF
```

### Creating an OCI run-time bundle

To create an OCI run-time bundle, which is needed for uxc, follow these steps.

First build a container image.

```
docker build -t container1 .
```

Note the image ID that is printed at the end, and use it after the @ in the next command.

```
skopeo copy containers-storage:[overlay@$HOME/.local/share/containers/storage+/run/user/1000/containers]@b0897a4ee285938413663f4c7b2b06d21e45c4358cebb04093ac9de9de118bf2 oci:container1:latest
sudo umoci unpack --image container1 container1-bundle
sudo rsync -aH container1-bundle root@192.168.0.1:/mnt/sda3/debian
```

This is quite cumbersome. If someone knows a better way, please do update this page.

### Import a OCI runtime container

(assuming OCI run-time bundle with config.json in /mnt/sda3/debian)

```
uxc create container1 /mnt/sda3/debian true
uxc start container1

uxc list
uxc state container
```

If the container uses a stdio console, you can attach it using

```
ujail-console -c container1
```

(there is no buffer, so if you like to see the complete bootlog of a container, make sure to attach a console after the 'create' call but before starting it)

## Podman

[https://podman.io/](https://podman.io/ "https://podman.io/") is alternative to Docker and it is compatible with Docker client commands. Here is example setup using podman to create web server container with proxy.

Install necessary packages:

```
opkg install podman
```

If you want to use rootless containers, the package slirp4netns is installed as a dependency. There's also authoritative DNS server for netavark available as package aardvark-dns. This guide excludes their setup currently.

**Network**

Let's start by reviewing our container network's settings. /etc/containers/networks/podman.json:

```
{
     "name": "podman",
     "id": "5ef894788befd4d42498314b6e66282ca730aa2e1e82f9b9597bf4d1725ca074",
     "driver": "bridge",
     "network_interface": "podman0",
     "created": "2023-02-20T08:56:34.652030952Z",
     "subnets": [
          {
               "subnet": "10.129.0.0/24",
               "gateway": "10.129.0.1"
          }
     ],
     "ipv6_enabled": false,
     "internal": false,
     "dns_enabled": true,
     "ipam_options": {
          "driver": "host-local"
     }
}
```

I have a rather large network (10.0.0.0/9) so that's why the *odd* subnet - you can choose your own, but this is a example setup based on my settings. In this file you define your network named podman. You can have multiple networks.

**Firewall/Zone**

Next, we make sure internal port forwarding/firewalling of podman is disabled, check the network section of /etc/containers/containers.conf:

```
[network]
network_backend = "netavark"
firewall_driver = "none"
network_config_dir = "/etc/containers/networks/"
default_network = "podman"
default_subnet = "10.129.0.0/24"
default_rootless_network_cmd = "slirp4netns"
#dns_bind_port = 53
```

We do this to rather use openwrt's own firewall, as when using podman's/netavark's, rules are lost every time that firewall is re-loaded, including when you start your first container network, when podman0 interface comes up.

Be aware that this means you must manually configure a NAT rule on the firewall when you want to expose a port from a container, as podman will not do that for you!

Next is time to setup network and firewall on the openwrt's side, add this to /etc/config/network:

```
config device
	option type 'bridge'
	option name 'podman0'
	option bridge_empty '1'
	option ipv6 '0'

config interface 'podman0'
	option proto 'static'
	option device 'podman0'
	option ipaddr '10.129.0.1'
	option netmask '255.255.255.0'
```

And we also want to use firewall, in this setup we allow access from lan to podman, but not the other way around, we also grant access from wan, and to wan. /etc/config/firewall:

```
config zone
	option name 'Podman'
	option input 'DROP'
	option output 'ACCEPT'
	option forward 'REJECT'
	list network 'podman0'
```

Now that we have blocked access to LAN, our containers are missing access to DNS, unless we configure them to use something else, such as 8.8.8.8 - so we make a exception, containers can connect to lan, but only on port 53 (DNS):

```
config rule
	option name 'Allow-Podman-DNS'
	option src 'Podman'
	option dest_port '53'
	option target 'ACCEPT'
```

Now initial network setup is complete.

**Service**

Next we make sure that podman service is started on boot. This is optional, but if you want to follow this guide, it comes handy later. Podman service does not create/start/etc any containers, it only starts background service and creates unix socket used for communication. This socket is located at /var/run/podman/podman.sock - this socket accepts similar/compatible communication as docker. A so called podman-docker-compatibility package usually only contains a link to this socket to standard docker's socket path, and a docker wrapper script that forwards it's command-line to podman command. Service actually starts when you use podman, but we want to make sure it's listed as openwrt instance, and for further more advanced setup, this is helpful.

```
/etc/init.d/podman enable
```

After reboot, you can start using your podman setup. Guide continues, we make a web server and caddy proxy as example projects and handle forwarding of traffic to them. We will store our container data in /srv.

**Container storage (optional)**

I have a lot of disk space available, so I set my graphroot to hard drive, instead of storing container data in RAM, such as /tmp or /var which it defaults. First make a proper path:

```
mkdir -p /srv/.podman/storage
```

And edit your /etc/containers/storage.conf:

```
graphroot = "/srv/.podman/storage"
```

default was: “*/var/lib/containers/storage*”

Without setting graphroot, your setup works also, it's just that I happen to have a lot of disk space in my setups, I rather store them on hard drive instead of memory, such as /tmp or /var.

**Local image storage (optional)**

My setup builds my containers on every boot and I want to speed up that process, so I want images for Caddy proxy and nginx web server to be stored in permanent storage. But beware, every time you want to make changes to these images, you need to restart this process completely from beginning, first by resetting *additionalimagestores* setting to it's default value, remove physical image files and ofcourse before all this, you must remove containers using these images, along the images, from Podman's own system, and finally pull new images, and restore *additionalimagestores* setting to your image path. Also as Podman's service lacks stop functionality, some reboots are necessary as well. Complicated? Yes it is, but in the end it might pay off, as images don't need to be pulled after every reboot. To begin with, reboot your computer and make sure any containers are not created, started or even exist, this will help to avoid problems.

Create directory /srv/.podman/images:

```
mkdir -p /srv/.podman/images
```

Then check your /etc/containers/storage.conf:

```
additionalimagestores = []
```

If you have to change this line, you must reboot to podman service restart so this takes effect. Following line should be found, it is default setting. With this line, we do not have images locally stored in permanent store. Next issue following commands:

```
podman --root /srv/.podman/images images
podman --root /srv/.podman/images pull docker.io/me/my_caddy_image:latest
podman --root /srv/.podman/images pull docker.io/me/my_nginx_image:latest
```

replace image urls with your own, first command sets up path images as local image store, and next commands pull your images to local image store. You can also pull your pause image, for example: *k8s.gcr.io/pause:3.5*

After this, make changes to your /etc/containers/storage.conf:

```
additionalimagestores = [
        "/srv/.podman/images"
]
```

and reboot. Now when creating containers that use locally stored images, they do not need to be pulled from internet, they are instantly available. If you use not locally stored images, they work fine; they just are pulled from internet.

This is a one time operation; changes, removals, adds of locally stored images cannot be modified very easily. To restart process; remove containers using locally stored images, remove then these images from podman (podman image rm &lt;imageid&gt;), change your *additionalimagestores* back to \[], disable podman service, and make sure, podman service doesn't start by creation/start of containers during boot. Then you remove all files, from /srv/.podman/images:

```
rm -rf /srv/.podman/images
```

reboot again, and begin this again from start of this section of guide.

**Pod** We will start by creating a pod. Pod can hold multiple containers, they share some attributes, such as ip address. As we are trying to build a web server setup, we want IP address to be always same for this pod. I have created a script /srv/create.sh to construct this pod:

```
#!/bin/sh
 
podman pod create \
		--replace \
		--name servers \
		--hostname srv \
		--ip 10.129.0.2
 
podman pod start servers
```

This creates, or replaces if one exists, pod named servers, gives it a hostname srv (not important) and a static IP address 10.129.0.2.

**Containers** All configurations and statically exported data is also in /srv. In /srv/caddy I have all needed to build my caddy container, such as configurations and what ever caddy container of your choice needs. I also have a build script there, /srv/caddy/create.sh:

```
#!/bin/sh
 
podman create \
	--name caddy \
	--pod servers \
	--replace \
	--systemd false \
	--label app=caddy \
	--volume /srv/caddy/conf/:/etc/caddy/:Z,rw \
	--volume /srv/caddy/htdocs/:/var/htdocs/:z,rw \
	--volume /srv/caddy/logs/:/var/log/:z,rw \
	--volume /dev/log:/dev/log:Z,rw \
	--mount="type=bind,src=/etc/acme/domain.tld_ecc/domain.tld.cer,dst=/etc/caddy/ssl/server.pem,ro=true,idmap=uids=0-82-1;gids=0-82-1" \
	--mount="type=bind,src=/etc/acme/domain.tld_ecc/domain.tld.key,dst=/etc/caddy/ssl/server.key,ro=true,idmap=uids=0-82-1;gids=0-82-1" \
	docker.io/me/my_caddy_image:latest
 
podman start caddy
```

In this guide I do not review configuration of Caddy, look it up from caddy's docs. My caddy is set to run as user www:www-data which in that setup are uid 82 and gid 82, acme is used to fetch certificates, but user www(82) cannot read root owned files, so we use idmapping to map those 2 files for user www:www-data. There are multiple ways to do this, this is just one approach. You could also setup a system that chmod's those files to be available for reading to everyone, or at least for user and/or group 82. Or copy them locally and chown them in that location statically.

And I have a similar script for nginx:

```
#!/bin/sh
 
podman create \
	--name nginx \
	--pod servers \
	--replace \
	--systemd false \
	--label app=nginx \
	--volume /srv/nginx/conf/:/etc/nginx/:Z,rw \
	--volume /srv/nginx/logs/:/var/log/nginx/:Z,rw \
	--volume /srv/nginx/htdocs/:/var/htdocs/:z,rw \
	--volume /dev/log:/dev/log:Z,rw \
	docker.io/me/my_nginx_image:latest
 
podman start nginx
```

Now after you have configured properly your caddy and nginx, we should have a server properly running. We need to setup redirections from wan.

**Expose to wan**

Now that we have caddy serving at 10.129.0.2, ports 80 and 443, we edit /etc/config/firewall again:

```
config redirect
	option name 'Allow-HTTP'
	option src 'wan'
	option dest 'podman'
	option src_dport '80'
	option dest_ip '10.129.0.2'
	option dest_port '80'
	option proto 'tcp'
	option reflection '0'
	option target 'DNAT'
	option enabled '1'

config redirect
	option name 'Allow-HTTPS'
	option src 'wan'
	option dest 'podman'
	option src_dport '443'
	option dest_ip '10.129.0.2'
	option dest_port '443'
	option proto 'tcp'
	option reflection '0'
	option target 'DNAT'
	option enabled '1'
```

**Automation**

Finally, we want our pod and containers to build and start during boot, we also have acme handling our certificates, so we want to restart caddy when certificates are renewed.

I added /srv/scripts directory, and added there file restart\_caddy.sh:

```
#!/bin/sh
 
/etc/init.d/podman enabled || exit
logger -t acme -p daemon.info "SSL certificates renewed, restarting container servers:caddy"
 
podman stop caddy
sleep 1
podman start caddy
```

And then rest is handled by /etc/rc.local:

```
# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.
 
add_podman_trigger() {
 
	local counter=10
	local running=0
 
	[ -x "/etc/init.d/acme" ] || exit
	/etc/init.d/acme enabled || exit
 
	while [ "$counter" -gt 0 ]; do
		[ "$(service podman status)" = "running" ] && {
			running=1
			counter=0
		} || {
			sleep 1
			counter=$(($counter-1))
		}
	done
 
	[ "$running" -eq 1 ] && {
		ubus call service set '{ "name": "podman", "triggers": [[ "acme.renew", [[ "run_script", "/srv/scripts/restart_caddy.sh" ]], 2000 ]], "data": {}}'
		logger -t podman -p daemon.info "podman: added service trigger for acme.renew event to restart servers:caddy"
	}
}
 
start_podman_services() {
 
	/etc/init.d/podman enabled && {
		[ -f /tmp/.podman_created ] || {
 
			touch /tmp/.podman_created
 
			sleep 1
			/srv/create.sh
			sleep 2
			/srv/caddy/create.sh
			sleep 2
			/srv/nginx/create.sh
 
			add_podman_trigger &
		}
	}
}
```

This is why starting podman service with /etc/init.d/podman comes handy, we can ignore all container related during boot, by just simply disabling service as nothing podman related is started if service is disabled. This builds our pod and both containers and then adds a trigger for podman service to restart caddy when SSL certificates are renewed. There's a routine that checks if podman service has started, because trigger must be added AFTER podman service has started.
