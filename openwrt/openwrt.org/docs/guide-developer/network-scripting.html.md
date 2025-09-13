# Network scripts

netifd can (probably) bring up a wired, static ip configuration without shell scripts. For everything else (PPPoE or 3G) it needs *protocol handlers* implemented as sets of shell functions.

## Writing protocol handlers

Each protocol handler is a shell script in `/lib/netifd/proto/`. It is run (or maybe sourced) when netifd daemon starts. Changes made to the scripts do not take effect until netifd restarts. The name of the file usually matches `option proto` in `/etc/config/network`.

To be able to access the network functions, the script needs to include the necessary shell scripts at the beginning:

```
#!/bin/sh
 
[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. ../netifd-proto.sh
	init_proto "$@"
}
```

Current working directory is `/lib/netifd/proto/` when the handler is sourced.

At the end of the script a handler should register itself by calling `add_protocol protocolname`.

A handler should at least define 2 shell functions: `proto_protocolname_init_config` and `proto_protocolname_setup`.

### init\_config

The main purpose of this function is to let netifd know which parameters does this protocol have. These parameters then can be stored in `/etc/config/network`.

```
proto_protocolname_init_config() {
	proto_config_add_string "stringparam"
	proto_config_add_int "intparam"
	proto_config_add_boolean "boolparam"
	...
}
```

### Setup

The setup procedure implements the actual protocol specifc configuration logic and interface bringup.

When called, one or two parameters are passed:

1. Config, the UCI section name suitable for `config_get` calls
2. Interface name (only if `no_device=0`)

```
proto_protocolname_setup() {
	local config="$1"
	# set up the interface
}
```

This function must be implemented by any protocol backend.

There's usually no need to call `ifconfig iface up` at the end of this function. If `no_device=0`, netifd won't even try to start our profile until the device is already up. It waits for `operstate=up` and `carrier=1`, then starts the profile.

If `no_device=1`, netifd will bring it up, when it receives a notification from us:

```
proto_protocolname_setup () {
	...
	proto_init_update "$iface" 1
	proto_send_update "$config"
	...
}
```

However, this only works once. If someone called `ifconfig iface down`, netifd won't try to bring it up again (at least in BB), so just in case you may put the “up” command in the function.

### Teardown

Protocols that need special shutdown handling, for example to kill associated daemons, may implement a stop procedure. This procedure is called when an interface is brought down before the associated UCI state is cleared.

The function is called when we do `ifdown profile` or when `no_device=0` and netifd detects link connectivity loss.

When called, two parameters are passed:

1. Config, the UCI section name suitable for `config_get` calls
2. iface, the network device

```
proto_protocolname_teardown() {
	local config="$1"
	local iface="$2"
	# tear down the interface
}
```

This function is optional.

### Coldplug

By default, only interfaces present in `/proc/net/dev`, like *eth0*, are brought up on boot. Protocols which use virtual interfaces must set two variables at the beginning of init\_config.

```
proto_protocolname_init_config() {
	no_device=1
	available=1
	...
}
```

### Debugging

- STDERR in protos is redirected to the syslog. `echo “message” > 2>&1` can be used to print.
- As `set -x` also prints to STDERR, it can be used to trace which commands are called inside the proto. However this is very spammy.
- There is a pending patch: [https://patchwork.ozlabs.org/project/openwrt/patch/20201229233319.164640-1-me@irrelefant.net/](https://patchwork.ozlabs.org/project/openwrt/patch/20201229233319.164640-1-me@irrelefant.net/ "https://patchwork.ozlabs.org/project/openwrt/patch/20201229233319.164640-1-me@irrelefant.net/").

### Available proto flags

Flags can be added to a proto handler in `proto_protoname_init_config`, by setting their value to `1`. The information about all loaded protocols can be obtained by calling *ubus call network get\_proto\_handlers*.

Name Name in *ubus call network get\_proto\_handlers* Meaning no\_device no\_device The interface does not have a lower device. TBD: Explain implications. immediate TBD: I only saw this for the proto static. Maybe this is impossible to set from shell protos? available init\_available Initialize the device directly as available, without the device specified by ifname being present TBD: Is that correct? renew\_handler renew\_available Has a renew handler, which can be called. TBD: How can it be called? Is it called automatically by sth.? teardown\_on\_l3\_link\_down teardown\_on\_l3\_link\_down TBD force\_link\_default TBD: I only saw this for the proto static. Maybe this is impossible to set from shell protos? no\_proto\_task no\_task TBD

### Error codes

If errors for interfaces occur, the json object in *ifstatus interfacename* or in *ubus call network.interface dump* have an attribute *“error”*. If there are no errors, this attribute is not existing.

CODE Meaning NO\_DEVICE The configured device in ifname is not found. DEVICE\_CLAIM\_FAILED One of the reasons for this is, that the device configured by ifname does not exist. Usually this would result in NO\_DEVICE as the device is only claimed when it is available. However when the proto flags *available=1* and *no\_device=0* are set, the device specified by ifname is tried to be claimed directly. TBD: Is this the only case? Is this correct? SETUP\_FAILED TBD

Custom error codes can be thrown from the proto scripts aswell. This is done via `proto_notify_error “$config” MY_CUSTOM_ERROR_ID`.

### How does it work internally?

```
init_proto $proto $cmd $interface $data $ifname
```

This function takes all all arguments from the *proto.sh* file, interprets them and then defines the implementation of *add\_protocol()*.

If `$cmd = “dump”` then *add\_protocol()* will do the following:

- A json output dump of the results of `proto_protocolname_init_config` will be printed.
- Other parameters than `$cmd` will be ignored.

If `$cmd ∈ {“setup”, “teardown”, “renew”}` *add\_protocol()* will do the following:

- If `$proto ≠ protoname` nothing will be done.
- `$data` is loaded via *json\_load*
- `proto_protoname_... $interface $ifname` will be called.

Otherwise the script will fail with something like:

- `add_protocol: not found`

## API

The following functions are defined in `/lib/netifd/netifd-proto.sh`.

### netifd functions

#### initialization functions

- `add_protocol`
- `init_proto`
- `proto_config_add_boolean`
- `proto_config_add_int`
- `proto_config_add_string`

#### notification functions

Note: some of these function exit immediately. These functions are dispatched to ubus and arrive [here](https://git.openwrt.org/?p=project%2Fnetifd.git%3Ba%3Dblob%3Bf%3Dproto-shell.c%3Bhb%3Dc00c8335d6188daa326ecfe5a62da15a9b9987e1#l792 "https://git.openwrt.org/?p=project/netifd.git;a=blob;f=proto-shell.c;hb=c00c8335d6188daa326ecfe5a62da15a9b9987e1#l792")

- `proto_block_restart $interface`
- `proto_init_update $ifname $up [$external]`
- `proto_kill_command $interface [$signal]`
- `proto_notify_error $interface $str1 [$str2] [$str3] ...`
- `proto_run_command`

We can start a daemon that maintains the connection asynchronously by calling `proto_run_command “$config” custom_script`. Netifd remembers its pid. It can be killed manually by calling `proto_kill_command “$config”`. Netifd can automatically kill it, when the profile stopped.

\* `proto_add_host_dependency`

It seems to avoid race conditions in protos. We can register the following type of dependencies by calling:

- `proto_add_host_dependency “$config” “$host” “$ifname”`
- `proto_add_host_dependency “$config” \'\' “$ifname”` (only wait for an iface)
- (maybe more?)

Only if `$iface` is up, the corresponding `$config` will be loaded. So we need another proto to be completed, we can use this here.

From some observations I think it looks like technically the `$config` is initially loaded, then the `proto_add_host_dependency` is called inside the proto handler and then the `$config` is removed again until `$iface` is available, up, ... or so. However, currently I do not know where to find the source code, so this is only a vague idea of what happens.

- `proto_send_update $interface`
- `proto_set_available $interface $state`

### common functions

- `json_add_string`
- `json_dump`
- `json_init`
- `json_get_var`
- `json_get_vars`

## Examples

[Network functions](https://github.com/openwrt/openwrt/blob/master/package/base-files/files/lib/functions/network.sh "https://github.com/openwrt/openwrt/blob/master/package/base-files/files/lib/functions/network.sh") rely on runtime configuration and can return unexpected result if you are using MWAN or VPN. Replace automatic WAN detection with explicit interface definition if necessary.

### Get LAN address

```
# Runtime configuration
NET_IF="lan"
. /lib/functions/network.sh
network_flush_cache
network_get_ipaddr NET_ADDR "${NET_IF}"
network_get_ipaddr6 NET_ADDR6 "${NET_IF}"
echo "${NET_ADDR}"
echo "${NET_ADDR6}"
```

### Get WAN interface

```
# Runtime configuration
. /lib/functions/network.sh
network_flush_cache
network_find_wan NET_IF
network_find_wan6 NET_IF6
echo "${NET_IF}"
echo "${NET_IF6}"
```

### Get WAN L2 device

```
# Runtime configuration
. /lib/functions/network.sh
network_flush_cache
network_find_wan NET_IF
network_find_wan6 NET_IF6
network_get_physdev NET_L2D "${NET_IF}"
network_get_physdev NET_L2D6 "${NET_IF6}"
echo "${NET_L2D}"
echo "${NET_L2D6}"
```

### Get WAN L3 device

```
# Runtime configuration
. /lib/functions/network.sh
network_flush_cache
network_find_wan NET_IF
network_find_wan6 NET_IF6
network_get_device NET_L3D "${NET_IF}"
network_get_device NET_L3D6 "${NET_IF6}"
echo "${NET_L3D}"
echo "${NET_L3D6}"
 
# Persistent configuration
uci get network.wan.device
uci get network.wan6.device
```

### Get WAN address

```
# Runtime configuration
. /lib/functions/network.sh
network_flush_cache
network_find_wan NET_IF
network_find_wan6 NET_IF6
network_get_ipaddr NET_ADDR "${NET_IF}"
network_get_ipaddr6 NET_ADDR6 "${NET_IF6}"
echo "${NET_ADDR}"
echo "${NET_ADDR6}"
 
# Persistent static configuration
uci get network.wan.ipaddr
uci get network.wan6.ip6addr
```

### Get WAN gateway

```
# Runtime configuration
. /lib/functions/network.sh
network_flush_cache
network_find_wan NET_IF
network_find_wan6 NET_IF6
network_get_gateway NET_GW "${NET_IF}"
network_get_gateway6 NET_GW6 "${NET_IF6}"
echo "${NET_GW}"
echo "${NET_GW6}"
 
# Persistent static configuration
uci get network.wan.gateway
uci get network.wan6.ip6gw
```

### Get WAN prefix

```
# Runtime configuration
. /lib/functions/network.sh
network_flush_cache
network_find_wan6 NET_IF6
network_get_prefix6 NET_PFX6 "${NET_IF6}"
echo "${NET_PFX6}"
 
# Persistent static configuration
uci get network.wan6.ip6prefix
```

### Get WAN gateway for unmanaged default route

```
# Runtime configuration
ubus call network.interface dump \
| jsonfilter -e "$['interface'][*]['inactive']
['route'][*]['target'='0.0.0.0','mask'='0','nexthop']"
```
