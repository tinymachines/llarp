# ubus system

**Package: procd**

Procedure Signature Description board {} returns board specific information like model and distribution code name, revision info {} returns real-time information about the system. `“uptime”: 20756, “localtime”: 1444142264, “load”: [ 7264, 3040, 3520 ], “memory”: { “total”: 29601792, “free”: 7344128, “shared”: 458752, “buffered”: 2166784 }, “swap”: { “total”: 0, “free”: 0 }` upgrade {} \*TODO* watchdog {“frequency”:“Integer”,“timeout”:“Integer”,“stop”:“Boolean”,“magicclose”:“Boolean”} controls the watchdog. \*ubus call system watchdog '{ “stop”: true“}'* only stops the thread triggering the watchdog. The watchdog is still counting down unless a second process is triggering the watchdog unless you enable 'magicclose', then you can manually tickle '/dev/watchdog'. signal {“pid”:“Integer”,”signum“:“Integer”} send a signal to a process. See man kill nandupgrade {“path”:“String”} \*TODO*

The values in load are the load averages over 1, 5, and 15 minutes. to get to the familiar values reported by uptime divide these numbers by 65536.0 and round to 2 decimals.

There is a detailed [blog post](http://kernelreloaded.com/manually-controlling-openwrt-hardware-watchdog/ "http://kernelreloaded.com/manually-controlling-openwrt-hardware-watchdog/") showing how to use, configure and manually take control over hardware watchdog with ubus commands.

## Examples

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
