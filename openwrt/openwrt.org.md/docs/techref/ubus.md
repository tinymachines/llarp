# ubus (OpenWrt micro bus architecture)

See also: [What is UBUS?](https://hackmd.io/@rYMqzC-9Rxy0Isn3zClURg/H1BY98bRw "https://hackmd.io/@rYMqzC-9Rxy0Isn3zClURg/H1BY98bRw")

To provide [Inter-process communication](https://en.wikipedia.org/wiki/Inter-process_communication "https://en.wikipedia.org/wiki/Inter-process_communication") between various daemons and applications in OpenWrt a project called `ubus` has been developed. It consists of several parts including daemon, library and some extra helpers.

The heart of this project is the `ubusd` daemon. It provides an interface for other daemons to register themselves as well as sending messages. For those curious, this interface is implemented using Unix sockets and it uses [TLV (type-length-value)](https://en.wikipedia.org/wiki/Type-length-value "https://en.wikipedia.org/wiki/Type-length-value") messages.

To simplify development of software using `ubus` (connecting to it) a library called `libubus` has been created.

Every daemon registers a set of paths under a specific namespace. Every path can provide multiple procedures with any number of arguments. Procedures can reply with a message.

The code is published under [LGPL 2.1 license](https://en.wikipedia.org/wiki/GNU_Lesser_General_Public_License "https://en.wikipedia.org/wiki/GNU_Lesser_General_Public_License") and can be found via git at [https://git.openwrt.org/project/ubus.git](https://git.openwrt.org/project/ubus.git "https://git.openwrt.org/project/ubus.git").

## Command-line ubus tool

The `ubus` command line tool allows to interact with the `ubusd` server (with all currently registered services). It's useful for investigating/debugging registered namespaces as well as writing shell scripts. For calling procedures with parameters and returning responses it uses the user-friendly JSON format. Below is an explanation of its commands.

### Help output

```
# ubus
Usage: ubus [<options>] <command> [arguments...]
Options:
 -s <socket>:		Set the unix domain socket to connect to
 -t <timeout>:		Set the timeout (in seconds) for a command to complete
 -S:			Use simplified output (for scripts)
 -v:			More verbose output
 -m <type>:		(for monitor): include a specific message type
			(can be used more than once)
 -M <r|t>		(for monitor): only capture received or transmitted traffic

Commands:
 - list [<path>]			List objects
 - call <path> <method> [<message>]	Call an object method
 - listen [<path>...]			Listen for events
 - send <type> [<message>]		Send an event
 - wait_for <object> [<object>...]	Wait for multiple objects to appear on ubus
 - monitor				Monitor ubus traffic
```

### list

To find out which services are currently running on the bus simply use the `ubus list` command. This will show a complete list of all namespaces registered with the RPC server:

```
# ubus list
dhcp
dnsmasq
file
iwinfo
log
luci
luci-rpc
network
network.device
network.interface
network.interface.lan
network.interface.loopback
network.interface.wan
network.interface.wan6
network.rrdns
network.wireless
service
session
system
uci
```

You can filter the list by specifying a service path:

```
# ubus list network.interface.*
network.interface.lan
network.interface.loopback
network.interface.wan
network.interface.wan6
```

To find out which procedures/methods and their argument signatures a specific service provides add `-v` in addition to the namespace path:

```
# ubus -v list network.interface.lan
'network.interface.lan' @099f0c8b
	"up": {  }
	"down": {  }
	"status": {  }
	"prepare": {  }
	"add_device": { "name": "String" }
	"remove_device": { "name": "String" }
	"notify_proto": {  }
	"remove": {  }
	"set_data": {  }
```

### call

Calls a given procedure within a given namespace and optionally pass arguments to it:

```
# ubus call network.interface.wan status
{
	"up": true,
	"pending": false,
	"available": true,
	"autostart": true,
	"uptime": 86017,
	"l3_device": "eth1",
	"device": "eth1",
	"address": [
		{
			"address": "178.25.65.236",
			"mask": 21
		}
	],
	"route": [
		{
			"target": "0.0.0.0",
			"mask": 0,
			"nexthop": "178.25.71.254"
		}
	],
	"data": {
 
	}
}
```

The arguments must be a valid JSON string, with keys and values set according to the function signature:

```
# ubus call network.device status '{ "name": "eth0" }'
{
	"type": "Network device",
	"up": true,
	"link": true,
	"mtu": 1500,
	"macaddr": "c6:3d:c7:90:aa:da",
	"txqueuelen": 1000,
	"statistics": {
		"collisions": 0,
		"rx_frame_errors": 0,
		"tx_compressed": 0,
		"multicast": 0,
		"rx_length_errors": 0,
		"tx_dropped": 0,
		"rx_bytes": 0,
		"rx_missed_errors": 0,
		"tx_errors": 0,
		"rx_compressed": 0,
		"rx_over_errors": 0,
		"tx_fifo_errors": 0,
		"rx_crc_errors": 0,
		"rx_packets": 0,
		"tx_heartbeat_errors": 0,
		"rx_dropped": 0,
		"tx_aborted_errors": 0,
		"tx_packets": 184546,
		"rx_errors": 0,
		"tx_bytes": 17409452,
		"tx_window_errors": 0,
		"rx_fifo_errors": 0,
		"tx_carrier_errors": 0
	}
}
```

### listen

Set up a listening socket and observe incoming events:

```
# ubus listen &
# ubus call network.interface.wan down
{ "network.interface": { "action": "ifdown", "interface": "wan" } }
# ubus call network.interface.wan up
{ "network.interface": { "action": "ifup", "interface": "wan" } }
{ "network.interface": { "action": "ifdown", "interface": "he" } }
{ "network.interface": { "action": "ifdown", "interface": "v6" } }
{ "network.interface": { "action": "ifup", "interface": "he" } }
{ "network.interface": { "action": "ifup", "interface": "v6" } }
```

### send

Send an event notification:

```
# ubus listen &
# ubus send foo '{ "bar": "baz" }'
{ "foo": { "bar": "baz" } }
```

## Access to ubus over HTTP

There is an `uhttpd` plugin called `uhttpd-mod-ubus` that allows `ubus` calls using HTTP protocol. For example this is used in [LuCI2](/docs/techref/luci2 "docs:techref:luci2"). Requests have to be sent to the `/ubus` URL (unless changed by `ubus_prefix` option) using the `POST` method. This interface uses [jsonrpc v2.0](https://www.jsonrpc.org/specification "https://www.jsonrpc.org/specification") There are a few steps that you will need to understand.

If uhttpd-mod-ubus is installed, uhttpd automatically configures it and enables it, by default at /ubus, but you can [configure this](/docs/guide-user/services/webserver/uhttpd "docs:guide-user:services:webserver:uhttpd") Also if you want to use the `/ubus` directly from a web client you need to specify `ubus_cors=1` option.

If you are using Nginx then you may try [nginx-ubus-module](https://github.com/Ansuel/nginx-ubus-module "https://github.com/Ansuel/nginx-ubus-module"). For other web servers like Lighttpd you may use the [ubus as CGI](https://github.com/yurt-page/cgi-ubus "https://github.com/yurt-page/cgi-ubus").

See the [Postman collection](https://documenter.getpostman.com/view/5972215/TVzNHeej#154b5d84-4065-4887-a5a8-c1f3b51fe9a6 "https://documenter.getpostman.com/view/5972215/TVzNHeej#154b5d84-4065-4887-a5a8-c1f3b51fe9a6") with some examples of calling UBUS over HTTP

### ACLs

While logged in via ssh, you have direct, full access to ubus. When you're accessing the `/ubus` url in uhttpd however, uhttpd first queries whether your call is allowed, and whoever is providing the ubus `session.*` namespace is in charge of implementing the access control:

```
ubus call session access '{ "ubus_rpc_session": "xxxxx", "object": "requested-object", "function": "requested-method" }'
```

This happens to be `rpcd` at the moment, with the `http-json` interface, for friendly operation with browser code, but this is just one possible implementation. Because we're using rpcd to implement the ACLs at this time, this allows/requires (depending on your point of view) ACLs to be configured in `/usr/share/rpcd/acl.d/*.json`. The *names* of the files in `/usr/share/rpcd/acl.d/*.json` don't matter, but the top level keys define roles. The default ACL, listed below, *only* defines the login methods, so you can log in, but you still wouldn't be able to do anything.

```
{
        "unauthenticated": {
                "description": "Access controls for unauthenticated requests",
                "read": {
                        "ubus": {
                                "session": [ "access", "login" ]
                        }
                }
        }
}
```

An example of a complicated ACL, allowing quite fine grained access to different ubus modules and methods is [available in the Luci2 project](https://git.openwrt.org/?p=project%2Fluci2%2Fui.git%3Ba%3Dblob%3Bf%3Dluci2%2Fshare%2Facl.d%2Fluci2.json "https://git.openwrt.org/?p=project/luci2/ui.git;a=blob;f=luci2/share/acl.d/luci2.json")

An example of a “security is for suckers” config, where a `superuser` ACL group is defined, allowing unrestricted access to everything, is shown below. This illustrates the usage of `*` definitions in the ACLs, but keep reading for better examples.

Placing this file in `/usr/share/rpcd/acl.d/superuser.json` will help you move forward to the next steps.

```
{
        "superuser": {
                "description": "Super user access role",
                "read": {
                        "ubus": {
                                "*": [ "*" ]
                        },
                        "uci": [ "*" ],
                        "file": {
                                "*": ["*"]
                        }
                },
                "write": {
                        "ubus": {
                                "*": [ "*" ]
                        },
                        "uci": [ "*" ],
                        "file": {
                                "*": ["*"]
                        },
                        "cgi-io": ["*"]
                }
        }
}
```

Below is an example of an ACL definition that only allows access to some specific ubus modules, rather than unrestricted access to everything.

```
{
        "lesssuperuser": {
                "description": "not quite as super user",
                "read": {
                        "ubus": {
                                "file": [ "*" ],
                                "log": [ "*" ],
                                "service": [ "*" ],
                        },
                },
                "write": {
                        "ubus": {
                                "file": [ "*" ],
                                "log": [ "*" ],
                                "service": [ "*" ],
                        },
                }
        }
}
```

**Note:** Before we leave this section, you may have noticed that there's both a `ubus` and a `uci` section, even though ubus has a uci method. The `uci` scope is used for the [uci api](/docs/techref/uci "docs:techref:uci") provided by rpcd to allow defining per-file permissions because using the ubus scope you can only say `uci set` is allowed or not, but not specify that it is allowed to e.g. modify `/etc/config/system` but not `/etc/config/network`. If your application/ACL doesn't need UCI access, you can just leave out the UCI section altogether.

### Authentication

Now that we have an ACL that allows operations beyond just logging in, we can actually try this out. As mentioned, `rpcd` is handling this, so you need an entry in `/etc/config/rpcd`

```
config login
	option username 'root'
	option password '$p$root'
	list read '*'
	list write '*'
 
config login
        option username 'blaer'
        option password '$p$blaer'
        list read lesssuperuser
        list write lesssuperuser
```

The `$p` magic means to look in `/etc/shadow` and the `$root` part means to use the password for the root user in that file. The list of read and write sections, those map ACL roles to user accounts. So `list read *` means the read credential of any group listed in the merged ACLs. Write implies read.

You can also use `$1$<hash>` which is a [crypt](https://en.wikipedia.org/wiki/Crypt_%28Unix%29 "https://en.wikipedia.org/wiki/Crypt_(Unix)") hash, using SHA1, exactly as used in `/etc/shadow`. You can generate these with `uhttpd -m secret`.

### Session management

To login and receive a session id:

```
$ curl -H 'Content-Type: application/json' -d '{ "jsonrpc": "2.0", "id": 1, "method": "call", "params": [ "00000000000000000000000000000000", "session", "login", { "username": "root", "password": "secret"  } ] }'  http://your.server.ip/ubus
 
{"jsonrpc":"2.0","id":1,"result":[0,{"ubus_rpc_session":"c1ed6c7b025d0caca723a816fa61b668","timeout":300,"expires":299,"acls":{"access-group":{"superuser":["read","write"],"unauthenticated":["read"]},"ubus":{"*":["*"],"session":["access","login"]},"uci":{"*":["read","write"]}},"data":{"username":"root"}}]}
```

The session id `00000000000000000000000000000000` (32 zeros) is a special null-session which only has the rights from the `unauthenticated` access group, only enabling the `session.login` ubus call. A session has a timeout that can be specified when you login, otherwise it defaults to 5 minutes.

If you ever receive a response like `{“jsonrpc”:“2.0”,“id”:1,“result”:[6]}`, that is a valid jsonrpc response, 6 is the ubus code for `UBUS_STATUS_PERMISSION_DENIED` (you'll get this if you try and login before setting up the `superuser` file, or any file that gives you more rights than just being allowed to attempt logins).

To list all active sessions, try `ubus call session list`

The session timeout is automatically reset on every use. There are plans to use these sessions even for luci1, but at present, if you use this interface in a luci1 environment, you'll need to manage sessions yourself.

### Actually making calls

Now that you have a `ubus_rpc_session` you can make calls, based on your ACLs and the available ubus services. `ubus -v list` is your primary documentation on what can be done, but see the rest of this page for more information. For example, `ubus -v list file` returns

```
'file' @ff0a2c92
	"read":{"path":"String","base64":"Boolean"}
	"write":{"path":"String","data":"String","append":"Boolean","mode":"Integer","base64":"Boolean"}
	"list":{"path":"String"}
	"stat":{"path":"String"}
	"md5":{"path":"String"}
	"exec":{"command":"String","params":"Array","env":"Table"}
```

The RPC-JSON container format is:

```
{ "jsonrpc": "2.0",
  "id": <unique-id-to-identify-request>, 
  "method": "call",
  "params": [
             <ubus_rpc_session>, <ubus_object>, <ubus_method>, 
             { <ubus_arguments> }
            ]
}
```

The “id” key is merely echo'ed by the server, so it needs not be strictly unique, it's mainly intended for client software to easily correlate responses to previously made requests. Its type is either a string or a number, so it can be an UUID, sha1 hash, md5 sum, sequence counter, unix timestamp, etc.

An example request to read a file `/etc/board.json` which contains device info would be:

```
$ curl -H 'Content-Type: application/json' -d '{ "jsonrpc": "2.0", "id": 1, "method": "call", "params": [ "c1ed6c7b025d0caca723a816fa61b668", "file", "read", { "path": "/etc/board.json" } ] }'  http://your.server.ip/ubus
{"jsonrpc":"2.0","id":1,"result":[0,{"data":"{\n\t\"model\": {\n\t\t\"id\": \"innotek-gmbh-virtualbox\",\n\t\t\"name\": \"innotek GmbH VirtualBox\"\n\t},\n\t\"network\": {\n\t\t\"lan\": {\n\t\t\t\"ifname\": \"eth0\",\n\t\t\t\"protocol\": \"static\"\n\t\t}\n\t}\n}\n"}]}
```

Here the first param `c1ed6c7b025d0caca723a816fa61b668` is the `ubus_rpc_session` received during the login call. If you received a response like `{“jsonrpc”:“2.0”,“id”:1,“error”:{“code”:-32002,“message”:“Access denied”}}` then probably your session token was expired and you need to request a new one.

To beautify output you can use [jq](https://stedolan.github.io/jq/ "https://stedolan.github.io/jq/") utility:

```
curl -s -H 'Content-Type: application/json' -d '{ "jsonrpc": "2.0", "id": 1, "method": "call", "params": [ "c1ed6c7b025d0caca723a816fa61b668", "file", "read", { "path": "/etc/board.json" } ] }'  http://your.server.ip/ubus | jq
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": [
    0,
    {
      "data": "{\n\t\"model\": {\n\t\t\"id\": \"innotek-gmbh-virtualbox\",\n\t\t\"name\": \"innotek GmbH VirtualBox\"\n\t},\n\t\"network\": {\n\t\t\"lan\": {\n\t\t\t\"ifname\": \"eth0\",\n\t\t\t\"protocol\": \"static\"\n\t\t}\n\t}\n}\n"
    }
  ]
}
```

In the response JSON document in the `result[1].data` field contains escaped JSON with the `model` and `network` objects. To fetch the concrete model name you can parse the response with the [jq](https://stedolan.github.io/jq/ "https://stedolan.github.io/jq/") program:

```
curl -s -H 'Content-Type: application/json' -d '{ "jsonrpc": "2.0", "id": 1, "method": "call", "params": [ "c1ed6c7b025d0caca723a816fa61b668", "file", "read", { "path": "/etc/board.json" } ] }'  http://your.server.ip/ubus | jq -r '.result[1].data' | jq .model.name
"innotek GmbH VirtualBox"
```

As you can see in the example the router model is in fact just a OpenWrt runned on [virtual machine in VirtualBox](/docs/guide-user/virtualization/virtualbox-vm "docs:guide-user:virtualization:virtualbox-vm").

## Lua module for ubus

This is even possible to use `ubus` in `lua` scripts. Of course it's not possible to use native libraries directly in `lua`, so an extra module has been created. It's simply called `ubus` and is a simple interface between `lua` scripts and the `ubus` (it uses `libubus` internally).

```
-- Load module
require "ubus"
-- Establish connection
local conn = ubus.connect()
if not conn then
    error("Failed to connect to ubusd")
end
 
-- Iterate all namespaces and procedures
local namespaces = conn:objects()
for i, n in ipairs(namespaces) do
    print("namespace=" .. n)
    local signatures = conn:signatures(n)
    for p, s in pairs(signatures) do
        print("\tprocedure=" .. p)
        for k, v in pairs(s) do
            print("\t\tattribute=" .. k .. " type=" .. v)
        end
    end
end
 
-- Call a procedure
local status = conn:call("network.device", "status", { name = "eth0" })
for k, v in pairs(status) do
    print("key=" .. k .. " value=" .. tostring(v))
end
 
-- Close connection
conn:close()
```

Optional arguments to `connect()` are a path to use for sockets (pass nil to use the default) and a per call timeout value (in milliseconds)

```
local conn = ubus.connect(nil, 500) -- default socket path, 500ms per call timeout
```

## Namespaces &amp; Procedures

As explained earlier, there can be many different daemons (services) registered in `ubus`. Below you will find a list of the most common projects with namespaces, paths and procedures they provide.

**Path only contains the first context, e.g. network for network.interface.wan**

path Description Package [dhcp](/docs/guide-developer/ubus/dhcp "docs:guide-developer:ubus:dhcp") dhcp server odhcpd [file](/docs/guide-developer/ubus/file "docs:guide-developer:ubus:file") file rpcd [hostapd](/docs/guide-developer/ubus/hostapd "docs:guide-developer:ubus:hostapd") acesspoints wpad/hostapd [iwinfo](/docs/guide-developer/ubus/iwinfo "docs:guide-developer:ubus:iwinfo") wireless informations rpcd iwinfo [log](/docs/guide-developer/ubus/log "docs:guide-developer:ubus:log") logging procd [mdns](/docs/guide-developer/ubus/mdns "docs:guide-developer:ubus:mdns") mdns avahi replacement mdnsd [network](/docs/guide-developer/ubus/network "docs:guide-developer:ubus:network") network netifd [service](/docs/guide-developer/ubus/service "docs:guide-developer:ubus:service") init/service procd [session](/docs/guide-developer/ubus/session "docs:guide-developer:ubus:session") Session management rpcd [system](/docs/guide-developer/ubus/system "docs:guide-developer:ubus:system") system misc procd [uci](/docs/guide-developer/ubus/uci "docs:guide-developer:ubus:uci") Unified Configuration Interface rpcd

### procd

Project [procd: Procd system init and daemon management](/docs/techref/procd "docs:techref:procd")

#### ubus system

**Package: procd**

Procedure Signature Description board {} returns board specific information like model and distribution code name, revision info {} returns real-time information about the system. `“uptime”: 20756, “localtime”: 1444142264, “load”: [ 7264, 3040, 3520 ], “memory”: { “total”: 29601792, “free”: 7344128, “shared”: 458752, “buffered”: 2166784 }, “swap”: { “total”: 0, “free”: 0 }` upgrade {} \*TODO* watchdog {“frequency”:“Integer”,“timeout”:“Integer”,“stop”:“Boolean”,“magicclose”:“Boolean”} controls the watchdog. \*ubus call system watchdog '{ “stop”: true“}'* only stops the thread triggering the watchdog. The watchdog is still counting down unless a second process is triggering the watchdog unless you enable 'magicclose', then you can manually tickle '/dev/watchdog'. signal {“pid”:“Integer”,”signum“:“Integer”} send a signal to a process. See man kill nandupgrade {“path”:“String”} \*TODO*

The values in load are the load averages over 1, 5, and 15 minutes. to get to the familiar values reported by uptime divide these numbers by 65536.0 and round to 2 decimals.

There is a detailed [blog post](http://kernelreloaded.com/manually-controlling-openwrt-hardware-watchdog/ "http://kernelreloaded.com/manually-controlling-openwrt-hardware-watchdog/") showing how to use, configure and manually take control over hardware watchdog with ubus commands.

##### Examples

See all methods of `system` (to see all methods of all services registered to ubusd: `ubus -v list`):

```
root@OpenWrt:/# ubus -v list system
'system' @651f206c
        "board":{}
        "info":{}
        "reboot":{}
        "watchdog":{"frequency":"Integer","timeout":"Integer","magicclose":"Boolean","stop":"Boolean"}
        "signal":{"pid":"Integer","signum":"Integer"}
        "validate_firmware_image":{"path":"String"}
        "sysupgrade":{"path":"String","force":"Boolean","backup":"String","prefix":"String","command":"String","options":"Table"}
```

You can now call a remote method and receive a reply. A reply may be a simple integer return code or a more complete reply. Internally the bus uses a blob format, the CLI conveniently converts this to JSON.

```
root@OpenWrt:/# ubus call system board
{
        "kernel": "4.9.198",
        "hostname": "OpenWrt",
        "system": "Qualcomm Atheros QCA956X ver 1 rev 0",
        "model": "TP-Link TL-WR1043N\/ND v4",
        "board_name": "tl-wr1043nd-v4",
        "release": {
                "distribution": "OpenWrt",
                "version": "18.06.5",
                "revision": "r7897-9d401013fc",
                "target": "ar71xx\/generic",
                "description": "OpenWrt 18.06.5 r7897-9d401013fc"
        }
}
```

You can call a method and pass it some parameters by simply appending a JSON structure to the CLI command.

```
root@OpenWrt:/# ubus call system signal '{ "pid": 123, "signum": 9 }'
root@OpenWrt:/# echo $?
0
```

#### ubus service

**Package: procd**

`service` used by init scripts as well to register new services

Path Procedure Signature Description `service` `set` `{“name”:“String”,“script”:“String”,“instances”:“Table”,“triggers”:“Array”,“validate”:“Array”,“autostart”:“Boolean”,“data”:“Table”}` \*TODO* `service` `add` `{“name”:“String”,“script”:“String”,“instances”:“Table”,“triggers”:“Array”,“validate”:“Array”,“autostart”:“Boolean”,“data”:“Table”}` \*TODO* `service` `list` `{“name”:“String”,“verbose”:“Boolean”}` Return a list of all services and their instances. Can be filtered by name `service` `delete` `{“name”:“String”,“instance”:“String”}` Delete instance of a service `service` `update_start` `{“name”:“String”}` \*TODO* `service` `event` `{“type”:“String”,“data”:“Table”}` \*TODO* `service` `validate` `{“package”:“String”,“type”:“String”,“service”:“String”}` \*TODO* `service` `get_data` `{“name”:“String”,“instance”:“String”,“type”:“String”}` \*TODO* `service` `state` `{“spawn”:“Boolean”,“name”:“String”}` \*TODO*

### netifd

Project [netifd: Network Interface Daemon](/docs/techref/netifd "docs:techref:netifd")

#### ubus network

**Package: netifd**

[DESIGN document at repo of netifd](https://git.openwrt.org/?p=project%2Fnetifd.git%3Ba%3Dblob%3Bf%3DDESIGN%3Bhb%3DHEAD "https://git.openwrt.org/?p=project/netifd.git;a=blob;f=DESIGN;hb=HEAD")

Path Procedure Signature Description `network` `restart` `{ }` Restart the network, reconfigures all interfaces `network` `reload` `{ }` Reload the network, reconfigure as needed `network.device` `status` `{ “name”: “ifname” }` Dump status of given network device `ifname` or all network devices if none given `network.device` `set_state` `{ “name”: “ifname”, “defer”: deferred }` Defer or ready the given network device `ifname`, depending on the boolean value *deferred* `network.interface.name` `up` `{ }` Bring interface `name` up `network.interface.name` `down` `{ }` Bring interface `name` down `network.interface.name` `status` `{ }` Dump status of interface `name` `network.interface.name` `prepare` `{ }` Prepare setup of interface `name` `network.interface.name` `add_device` `{ “name”: “ifname” }` Add network device `ifname` to interface `name` (e.g. for bridges: `brctl addif br-name ifname`) `network.interface.name` `remove_device` `{ “name”: “ifname” }` Remove network device `ifname` from interface `name` (e.g. for bridges: `brctl delif br-name ifname`) `network.interface.name` `remove` `{ }` Remove interface `name` (?) `network.wireless` `status` `{ }`

### rpcd

Project [rpcd: OpenWrt ubus RPC daemon for backend server](/docs/techref/rpcd "docs:techref:rpcd") is a set of small plugins providing sets of `ubus` procedures in separated namespaces. These plugins are not strictly related to any particular software (like `netifd` or `dhcp`) so it wasn't worth it to implement them as separated projects. rpcd and the desired plugins must be available or installed via opkg. After installing remember to enable and start the service via `service rpcd enable` and `service rpcd start` .

#### ubus file

**Package: rpcd**

With plugin `rpcd-mod-file` enabled:

Path Procedure Signature Description `file` `read` `{ “path”: “String”, “base64”: Boolean }` Read a file contents. The file path is encoded in Base64 if the `base64` param set to “true” `file` `write` `{ “path”: “String”, “data”: “String”, “append”: Boolean, “mode”: Integer, “base64”: Boolean }` Write a `data` to a file by `path`. The file path is encoded in Base64 if the `base64` param set to “true”. If the `append` param is “true” then file is not overwritten but the new content is added to the end of the file. The `mode` param if specified represent file permission mode. `file` `list` `{ “path”: “String” }` ? `file` `stat` `{ “path”: “String” }` ? `file` `md5` `{ “path”: “String” }` ? `file` `exec` `{ “command”: “String”, “params”: “Array”, “env”: “Table” }` ?

#### ubus iwinfo

With plugin `rpcd-mod-iwinfo` enabled:

Path Procedure Signature Description `iwinfo` `devices` `{ }` ? `iwinfo` `info` `{ “device”: “device” }` ? `iwinfo` `scan` `{ “device”: “device” }` ? `iwinfo` `assoclist` `{ “device”: “device”, “mac”: “mac” }` ? `iwinfo` `freqlist` `{ “device”: “device” }` ? `iwinfo` `txpowerlist` `{ “device”: “device” }` ? `iwinfo` `countrylist` `{ “device”: “device” }` ? `iwinfo` `phyname` `{ “section”: “device” }` ?

Always included in `rpcd`:

#### ubus session

Path Procedure Signature Description `session` `create` `{ “timeout”: timeout }` Create a new session and return its ID, set the session timeout to `timeout` in seconds (set `0` for no expire) `session` `list` `{ “ubus_rpc_session”: “sid” }` Dump session info specified by `sid`, if no ID is given, list all sessions `session` `grant` `{ “ubus_rpc_session”: “sid”, “scope”: “scope”, “objects”: [ [ “path”, “func” ], ... ] }` Within the session identified by `sid` grant access to all specified procedures `func` in the namespace `path` listed in the `objects` array `session` `revoke` `{ “ubus_rpc_session”: “sid”, “scope”: “scope”, “objects”: [ [ “path”, “func” ], ... ] }` Within the session identified by `sid` revoke access to all specified procedures `func` in the namespace `path` listed in the `objects` array. If `objects` is unset, revoke all access `session` `access` `{ “ubus_rpc_session”: “sid”, “scope”: “scope”, “object”: “path”, “function”: “function” }` Query whether access to the specified `function` in the namespace `path` is allowed `session` `set` `{ “ubus_rpc_session”: “sid”, “values”: { “key”: value, ... } }` Within the session identified by `sid` store the given arbitrary values under their corresponding keys specified in the `values` object `session` `get` `{ “ubus_rpc_session”: “sid”, “keys”: [ “key”, ... ] }` Within the session identified by `sid` retrieve all values associated with the given keys listed in the `keys` array. If the key array is unset, dump all key/value pairs `session` `unset` `{ “ubus_rpc_session”: “sid”, “keys”: [ “key”, ... ] }` Within the session identified by `sid` unset all keys listed in the `keys` array. If the key list is unset, clear all keys `session` `destroy` `{ “ubus_rpc_session”: “sid” }` Terminate the session identified by the given ID `sid` `session` `login` `{ “username”: “username”, “password”: “password”, “timeout”: timeout }` Authenticate with rpcd and create a new session with access rights as specified in the ACLs

**Note:** When using ubus over HTTP, setting `ubus_rpc_session` isn't allowed, it's automatically set to the calling session.

**Note:** Sessions are stored in memory so they will persist as long as `rpcd` is running

##### login call description

Use `session.login` to authorize and create a new session. The `timeout` argument is optional, it is set in seconds and by default is 5 minutes (300 seconds). The session timeout is automatically reset on every use.

Return example:

```
{
        "ubus_rpc_session": "948abf19b632c5460384315d69010e09",
        "timeout": 300,
        "expires": 299,
        "acls": {
                "access-group": {
                        "uci-access": [
                                "read",
                                "write"
                        ],
                        "unauthenticated": [
                                "read"
                        ]
                },
                "ubus": {
                        "file": [
                                "*"
                        ],
                        "session": [
                                "access",
                                "login"
                        ]
                },
                "uci": {
                        "*": [
                                "read",
                                "write"
                        ]
                }
        },
        "data": {
                "username": "root"
        }
}
```

To list all active sessions call `session list`.

##### Example of manual session creation

Create a session then grant access to all functions of `file` and to the `board` object function of `system` object. Also set a custom attribute `username` to `alice` then check if the sid have an access to `system.reboot` function (and there is npo such access)

```
root@OpenWrt:~# ubus call session create '{"timeout": 3600}'
{
        "ubus_rpc_session": "8c1af812b4b148fcbb92434c74cf61c1",
        "timeout": 3600,
        "expires": 3600,
        "acls": {

        },
        "data": {

        }
}
root@OpenWrt:~# ubus call session grant '{"ubus_rpc_session": "bf11e5cd01cd262ae692600a6a45ccfc", "scope": "write", "objects": [["file", "*"], ["system", "board"]]}'
root@OpenWrt:~# ubus call session set '{"ubus_rpc_session": "bf11e5cd01cd262ae692600a6a45ccfc", "values": { "username": "alice" } }'
root@OpenWrt:~# ubus call session list '{"ubus_rpc_session": "bf11e5cd01cd262ae692600a6a45ccfc"}'
{
        "ubus_rpc_session": "bf11e5cd01cd262ae692600a6a45ccfc",
        "timeout": 3600,
        "expires": 3600,
        "acls": {
                "ubus": {
                        "file": [
                                "*"
                        ],
                        "system": [
                                "board"
                        ]
                }
        },
        "data": {
                "username": "alice"
        }
}
root@OpenWrt:~# ubus call session access '{ "ubus_rpc_session": "bf11e5cd01cd262ae692600a6a45ccfc", "scope": "ubus", "object": "system", "function": "reboot" }'
{
        "access": false
}
```

#### ubus uci

**Package: rpcd**

```
# ubus -v list uci
'uci' @4eb774a8
	"configs":{}
	"get":{"config":"String","section":"String","option":"String","type":"String","match":"Table","ubus_rpc_session":"String"}
	"state":{"config":"String","section":"String","option":"String","type":"String","match":"Table","ubus_rpc_session":"String"}
	"add":{"config":"String","type":"String","name":"String","values":"Table","ubus_rpc_session":"String"}
	"set":{"config":"String","section":"String","type":"String","match":"Table","values":"Table","ubus_rpc_session":"String"}
	"delete":{"config":"String","section":"String","type":"String","match":"Table","option":"String","options":"Array","ubus_rpc_session":"String"}
	"rename":{"config":"String","section":"String","option":"String","name":"String","ubus_rpc_session":"String"}
	"order":{"config":"String","sections":"Array","ubus_rpc_session":"String"}
	"changes":{"config":"String","ubus_rpc_session":"String"}
	"revert":{"config":"String","ubus_rpc_session":"String"}
	"commit":{"config":"String","ubus_rpc_session":"String"}
	"apply":{"rollback":"Boolean","timeout":"Integer","ubus_rpc_session":"String"}
	"confirm":{"ubus_rpc_session":"String"}
	"rollback":{"ubus_rpc_session":"String"}
	"reload_config":{}
```

The “ubus uci” section of this documentation is severely outdated and incomplete. It is only useful nowadays as a starting point for someone to actually rewrite it to match reality.

Path Procedure Signature Description `uci` `configs` `{ }`

List all available configs

Example:

```
# ubus call uci configs '{"ubus_rpc_session":"2db687f321a60414e77677bbb5dd6d6f"}'
{
	"configs": [
		"dhcp",
		"dropbear",
		"firewall",
		"luci",
		"network",
		"radius",
		"rpcd",
		"system",
		"ubootenv",
		"ucitrack",
		"uhttpd",
		"wireless"
	]
}
```

`uci` `get` `{ “config”: “config”, “section”: “sname”, “type”: “type”, “option”: “oname” }`

Return the requested uci value(s), all arguments are optional.

1. When called without argument or with empty object: return an array of package names in the `configs` field
2. When called with `config` set: return an object containing all sections containing all options in a field named after the package
3. When called with `config` and `type` set: return an object containing all sections of type `type` containing all options in a field named after the package
4. When called with `config` and `sname` set: return an object containing all options of the section in a field named after the section
5. When called with `config` and `type` and `oname` set: return an object containing the value of each option named `oname` within a section of type `type` in a field named after the matched section
6. When called with `package` and `sname` and `oname` set: return the result string in a field named `oname` in case of options or an array of result strings in a field named `oname` in case of list options

Return messages:

1. `{ “config”: { “sname1”: { “.type”: “type1”, “option1”: “value1”, “option2”: [ “value2.1”, ... ], ... }, ... } }`
2. `{ “config”: { “sname1”: { “.type”: “type”, “option1”: “value1”, “option2”: [ “value2.1”, ... ], ... }, ... } }`
3. `{ “sname”: { “.type”: “type”, “option1”: “value1”, “option2”: [ “value2.1”, ... ], ... } }`
4. `{ “sectionname1”: “value1”, “sectionname2”: [ “value2.1”, ... ], ... }`
5. 1. `{ “oname”: “value1” }`
   2. `{ “oname”: [ “value1.1”, ... ] }`

Example:

```
# ubus call uci get '{"ubus_rpc_session":"2db687f321a60414e77677bbb5dd6d6f", "config":"wireless", "section":"wifinet2"}'
{
	"values": {
		".anonymous": false,
		".type": "wifi-iface",
		".name": "wifinet2",
		"device": "radio0",
		"mode": "ap",
		"ssid": "ilwf-guest",
		"encryption": "sae-mixed",
		"key": "XXXX",
		"network": "lan",
		"disabled": "0"
	}
```

`uci` `state` `{ “config”: “config”, “section”: “sname”, “type”: “tname”, “option”: “oname” }` `uci` `set` `{ “config”: “config”, “section”: “sname”, “type”: “tname”, “values”: “array_of_values” }`

Set the given value(s), the option argument is optional.

1. When called with `config` and `sname` and `array_of_values` set: add a new section `sname` in `config` and set it to the type given in `tname`
2. When called with `config` and `sname`, `oname` and `array_of_values` set `array_of_values` as values in `sname`

The call does not produce any data, instead it returns with the following status codes:

1. If there already is a section called `sname`: `UBUS_STATUS_INVALID_ARGUMENT` else: `UBUS_STATUS_OK`
2. If there is no section `sname` or if `value` is neither a string nor an array: `UBUS_STATUS_INVALID_ARGUMENT` else: `UBUS_STATUS_OK`

Example:

```
# ubus call uci set '{"ubus_rpc_session":"2db687f321a60414e77677bbb5dd6d6f", "config":"wireless", "section":"wifinet2", "values":{"disabled":"1"}}'
# ubus call uci get '{"ubus_rpc_session":"2db687f321a60414e77677bbb5dd6d6f", "config":"wireless", "section":"wifinet2"}'
{
	"values": {
		".anonymous": false,
		".type": "wifi-iface",
		".name": "wifinet2",
		"device": "radio0",
		"mode": "ap",
		"ssid": "ilwf-guest",
		"encryption": "sae-mixed",
		"key": "XXXXXXXX",
		"network": "lan",
		"disabled": "1"
	}
}
```

`uci` `add` `{ “config”: “config”, “type”: “type” }`

Add new anonymous section of given type.

1. When called with `config` and `type` set: Add a new anonymous section of type `type`.

Return message:

1. `{ “section”: “sectionname” }`

`uci` `delete` `{ “config”: “config”, “section”: “sname”, “type”: “type”, “option”: “oname” }`

Delete the given value(s) or section(s), the option and type arguments are optional.

1. When called with `config` and `type` set: delete all sections of type `type` in `config`
2. When called with `config` and `sname` set: delete the section named `sname` in `config`
3. When called with `config`, `type` and `oname` set: delete the option named `oname` within each section of type `type` in `package`
4. When called with `config`, `sname` and `oname` set: delete the option named `oname` in section `sname` of `package`

The call does not result in any data, instead it returns the following status codes:

1. If no section of type `type` was found: `UBUS_STATUS_NOT_FOUND` else: `UBUS_STATUS_OK`
2. If no section named `sname` was found: `UBUS_STATUS_NOT_FOUND` else: `UBUS_STATUS_OK`
3. If no options named `oname` within sections of type `type` where found: `UBUS_STATUS_NOT_FOUND` else: `UBUS_STATUS_OK`
4. If the option named `oname` within named section `sname` was not found: `UBUS_STATUS_NOT_FOUND` else: `UBUS_STATUS_OK`

`uci` `rename` `{“config”:“String”,“section”:“String”,“option”:“String”,“name”:“String” }` `uci` `order` `{“config”:“String”,“sections”:“Array” }` `uci` `changes` `{“config”:“String” }` `uci` `revert` `{“config”:“String” }` `uci` `commit` `{“config”:“String” }` `uci` `apply` `{“rollback”:“Boolean”,“timeout”:“Integer” }` `uci` `confirm` `{ }` `uci` `rollback` `{ }` `uci` `reload_config` `{ }`

## What's the difference between ubus vs dbus?

[D-Bus](https://en.wikipedia.org/wiki/D-Bus "https://en.wikipedia.org/wiki/D-Bus") is bloated, its C API is very annoying to use and requires writing large amounts of boilerplate code. In fact, the pure C API is so annoying that its own API documentation states: “If you use this low-level API directly, you're signing up for some pain.”

`ubus` is tiny and has the advantage of being easy to use from regular C code, as well as automatically making all exported API functionality also available to shell scripts with no extra effort.

## Examples

### FHEM

#### User mapping

In this example we map username `root` to `fhem_acl` for [FHEM](/docs/guide-user/services/automation/fhem "docs:guide-user:services:automation:fhem") server. Edit `/etc/config/rpcd`:

[/etc/config/rpcd](/_export/code/docs/techref/ubus?codeblock=30 "Download Snippet")

```
# /etc/config/rpcd
config login
	option username 'root'
	option password '$p$root'
	list read '*'
	list write '*'
 
config login
	option username 'fhem'
        #
        # '$p$<username> => reference to user passowrd on /etc/shadow
        # '$1$<hash>' => crypt() hash, using SHA1. generate via 'uhttpd -m fhem'
        #
        # password: fhem
        #
	option password '$1$$xEODf2fNSQ0ArfkJu4L2i1'
	#
        # map username to rpcd acl name "fhem_acl"
        #
        list read 'fhem_acl'
	list write ''
```

Then reload rpcd config:

```
uci commit rpcd
```

#### User ACL

All files under `/usr/share/rpcd/acl.d/` will be merge by `rpcd` to one config file!!

```
ubus call hostapd.wlan0 get_clients
ubus call hostapd.wlan1 get_clients
```

Example permissions to run ubus calls remote by fhem over http/json.

[/usr/share/rpcd/acl.d/fhem.json](/_export/code/docs/techref/ubus?codeblock=33 "Download Snippet")

```
{
        "fhem_acl": {
                "description": "FHEM PRESENCE Module User.. https://github.com/janLo/OpenWRT-Wifi-Clients-POC",
                "read": {
                        "ubus": {
                                "hostapd.wlan0": [ "get_clients" ],
                                "hostapd.wlan1": [ "get_clients" ]
                        }
                }
        }
}
```

FHEM Server - show all connected wireless clients:

```
$ python wifi_clients.py
Usage: wifi_clients.py.orig <OpenWrt_Host> <User> <Pass> <WiFi_1> [<WiFi2> ...]
$ python wifi_clients.py 192.168.1.71 fhem fhem wlan0 wlan1
c8:f6:50:e1:a9:10, 2c:f0:a2:e2:c0:15, 8c:a9:82:f1:9c:2a, 7c:c3:a1:b8:d2:1e, 64:9a:be:6a:6c:13, 00:1d:63:a3:8f:4a
```

### Getting firmware version

Get firmware version with [JSON RPC](https://github.com/openwrt/luci/wiki/JsonRpcHowTo "https://github.com/openwrt/luci/wiki/JsonRpcHowTo").

```
luci_rpc() {
local LIB="${1}"
local DATA="${2}"
local URL="https://${HOST}/\
cgi-bin/luci/rpc/${LIB}?auth=${TOKEN}"
curl -s -k -d "${DATA}" "${URL}" \
| jsonfilter -e "$['result']"
}
HOST="localhost"
USER="root"
PASS=""
DATA="{ \"id\": 1, \"method\": \"login\",
\"params\": [ \"${USER}\", \"${PASS}\" ] }"
TOKEN="$(luci_rpc auth "${DATA}")"
DATA="{ \"id\": 2, \"method\": \"exec\",
\"params\": [ \"ubus call system board\" ] }"
VERSION="$(luci_rpc sys "${DATA}" \
| jsonfilter -e "$['release']['version']")"
echo "${VERSION}"
```

Get firmware version with ubus RPC.

```
ubus_rpc() {
local DATA="${1}"
local URL="https://${HOST}/ubus"
curl -s -k -d "${DATA}" "${URL}" \
| jsonfilter -e "$['result']"
}
HOST="localhost"
USER="root"
PASS=""
DATA="{ 'jsonrpc': '2.0', 'id': 1, 'method': 'call',
'params': [ '00000000000000000000000000000000', 'session',
'login', { 'username': '${USER}', 'password': '${PASS}' } ] }"
SESSION="$(ubus_rpc "${DATA}" \
| jsonfilter -e "$[*]['ubus_rpc_session']")"
DATA="{ 'jsonrpc': '2.0', 'id': 2, 'method': 'call',
'params': [ '${SESSION}', 'system', 'board', {} ] }"
VERSION="$(ubus_rpc "${DATA}" \
| jsonfilter -e "$[*]['release']['version']")"
echo "${VERSION}"
```
