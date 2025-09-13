# Podman Containers

I recently went through the process of getting **Podman** running properly on **OpenWrt 24.10.2** and configuring it to behave well with OpenWrt’s native networking, firewall setup and daemon startup and configuration logic. Since some of the information at [https://openwrt.org/docs/guide-user/virtualization/docker\_host](https://openwrt.org/docs/guide-user/virtualization/docker_host "https://openwrt.org/docs/guide-user/virtualization/docker_host") was outdated, I’ve updated parts of it there, and I'm sharing this more complete guide here as well, for those who want a more practical walkthrough.

* * *

## Installing Podman

First, install Podman using

```
opkg install podman
```

It will pull in a number of dependencies, including networking tools and container runtimes.

* * *

## Basic Configuration

### Storage Setup

Update Podman’s storage path to point to a disk with enough space, this folder, depending how careful you'll select containers, will tend to take quite some space:

/etc/containers/storage.conf

```
graphroot = "/home/podman/storage"
```

Then create the directory:

```
mkdir -p /home/podman/storage
```

* * *

### Regular Cleanup

Add cleanup tasks to cron:

```
crontab -e
```

Add:

```
# Podman cleanup
10 0 * * 0 /usr/bin/podman system prune --volumes -f > /dev/null 2>&1
20 0 * * 0 /usr/bin/podman image prune -a -f > /dev/null 2>&1
```

* * *

### Networking Setup

We want Podman to use a static bridge and be fully manageable by OpenWrt’s network config and firewall. Here’s how to set it up:

/etc/containers/networks/podman.json

```
{
     "name": "podman",
     "driver": "bridge",
     "network_interface": "podman0",
     "subnets": [
          {
               "subnet": "192.168.11.0/24",
               "gateway": "192.168.11.1"
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

/etc/containers/containers.conf

```
[network]
network_backend = "netavark"
firewall_driver = "none"
network_config_dir = "/etc/containers/networks/"
default_network = "podman"
default_subnet = "192.168.11.0/24"
default_rootless_network_cmd = "slirp4netns"
```

/etc/config/network

```
config device
        option type 'bridge'
        option name 'podman0'
        option bridge_empty '1'
        option ipv6 '0'
config interface 'podman0'
        option proto 'static'
        option device 'podman0'
        option ipaddr '192.168.11.1'
        option netmask '255.255.255.0'
```

/etc/config/firewall

Be careful that zone names for other zones must match your configuration

```
config zone
        option name 'Podman'
        option input 'DROP'
        option output 'ACCEPT'
        option forward 'REJECT'
        list network 'podman0'
config forwarding
        option src 'Podman'
        option dest 'Internet'
config forwarding
        option src 'lan'
        option dest 'Podman'
config rule
        option name 'DNS to Podman'
        option src 'Podman'
        option dest_port '53'
        option target 'ACCEPT'
```

* * *

### Giving Access to Container Ports

Since we're using 'firewall\_driver = “none”' Podman won't open ports automatically. If a container needs to be reachable, you'll need to manually create rules. For this reason I am explicitly adding an IP to each container, more of this later.

Example:

```
config rule
        option src 'VPN'
        option name 'NRPE to Nagios'
        option dest_port '5666'
        option target 'ACCEPT'
        list proto 'tcp'
        list src_ip '192.168.0.5'
        option dest 'Podman'
config redirect
        option dest 'Podman'
        option target 'DNAT'
        option name 'Serve NRPE from container'
        option family 'ipv4'
        list proto 'tcp'
        option src 'VPN'
        option src_dport '5666'
        option dest_ip '192.168.11.2'
        option dest_port '5666'
        option src_ip '192.168.0.5'
```

* * *

## Podman Init Script

Here’s how I run containers at boot using an init script. The set of parameters it understands is basic, and it's not smart when it comes to enforce containers to have name and images, but it's good enough for me and easy to mod in case needed. It is configurable via ^ /etc/config/containers ^ and is pretty flexible.

### /etc/init.d/containers

```
#!/bin/sh /etc/rc.common
 
START=90
STOP=20
USE_PROCD=1
 
NAME=containers
PROG=/usr/bin/podman
 
. /lib/functions.sh
 
start_service() {
    # At boot time, wait longer for dependencies
    local max_wait=60
    local count=0
 
    logger -t "$NAME" "Waiting for system readiness"
 
    # Wait for basic system services
    while [ $count -lt $max_wait ]; do
        # Check if essential services are ready
        if [ -S /var/run/ubus/ubus.sock ] && pgrep -f "ubusd" >/dev/null && \
           [ -d /sys/class/net ] && $PROG system info >/dev/null 2>&1; then
            break
        fi
        sleep 1
        count=$((count + 1))
    done
 
    if [ $count -ge $max_wait ]; then
        logger -t "$NAME" "Timeout waiting for system services and podman to be ready"
        return 1
    fi
 
    logger -t "$NAME" "Starting containers service"
 
    config_load containers
    config_foreach start_container container
}
 
start_container() {
    local cfg="$1" enabled name
 
    config_get enabled "$cfg" enabled 0
    config_get privileged "$cfg" privileged 0
    config_get name "$cfg" name "$cfg"
    config_get image "$cfg" image "$cfg"
 
    config_get dns "$cfg" dns ""
    config_get hostname "$cfg" hostname ""
    config_get image "$cfg" image ""
    config_get ip "$cfg" ip ""
    config_get memory "$cfg" memory ""
    config_get pid "$cfg" pid ""
    config_get pull "$cfg" pull "missing"
    config_get restart "$cfg" restart ""
 
    caps=""
    append_cap() {
        caps="$caps --cap-add=$1"
    }
    config_list_foreach "$cfg" cap append_cap
 
    envs=""
    append_env() {
        envs="$envs -e $1"
    }
    config_list_foreach "$cfg" env append_env
 
    vols=""
    append_vol() {
        vols="$vols -v $1"
    }
    config_list_foreach "$cfg" volume append_vol
 
    [ "$enabled" -eq 0 ] && return 0
 
    logger -t "$NAME" "Starting container $name"
    logger -t "$NAME" "Pulling latest version for $name - $image"
 
    $PROG pull $image  >/dev/null 2>&1 || logger -t "$NAME" "Pulling failed for $image"
 
    # Build the Podman command
    podman_cmd="$PROG run -d"
    [ -n "$dns" ] && podman_cmd="$podman_cmd --dns $dns"
    [ -n "$hostname" ] && podman_cmd="$podman_cmd --hostname $hostname"
    [ -n "$ip" ] && podman_cmd="$podman_cmd --ip $ip"
    [ -n "$memory" ] && podman_cmd="$podman_cmd --memory $memory"
    [ -n "$pid" ] && podman_cmd="$podman_cmd --pid $pid"
    [ -n "$restart" ] && podman_cmd="$podman_cmd --restart $restart"
    [ "$privileged" -eq 1 ] && podman_cmd="$podman_cmd --privileged"
    podman_cmd="$podman_cmd $envs $vols $caps --name $name $image"
 
    logger -t "$NAME" "Running '$podman_cmd'"
 
    procd_open_instance "$name"
    procd_set_param command sh -c "
        $podman_cmd || exit 1
        exec $PROG wait '$name'
    "
    procd_set_param respawn
    procd_close_instance
}
 
stop_service() {
    config_load containers
    config_foreach stop_container container
}
 
stop_container() {
    local cfg="$1" name
    config_get name "$cfg" name "$cfg"
    $PROG stop "$name" 2>/dev/null
    $PROG rm "$name" 2>/dev/null
}
 
# Standard init handlers
start() { start_service; }
stop() { stop_service; }
restart() { stop; start; }
reload() { stop; start; }
```

Make it executable:

```
chmod +x /etc/init.d/containers
```

And enable it for next boot

```
/etc/init.d/containers enable
```

* * *

## Example Container Config

/etc/config/containers

```
config container 'test'
    option enabled '1'
    option privileged '0'
    option name 'test'
    option dns '9.9.9.9'
    option image 'quay.io/podman/hello'
    option memory '64m'
    option hostname 'hello'
    option ip '192.168.11.2'
    option pid 'host'
    option restart 'unless-stopped'
    list env 'TZ=Europe/Amsterdam'
    list volume '/etc/openwrt_release:/etc/openwrt_release:ro'
    list volume '/home/test_container/etc/:/etc/test'
    list cmd 'ping'
    list cmd '-c'
    list cmd '4'
    list cmd '192.168.11.1'
```

* * *

## Preserving Configs During Sysupgrade

Add this to

/etc/sysupgrade.conf

```
/etc/containers
/etc/config/containers
/etc/init.d/containers
/home/
```

* * *
