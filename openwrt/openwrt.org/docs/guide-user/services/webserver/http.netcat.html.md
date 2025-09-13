# Netcat as Webserver

[Netcat](https://en.wikipedia.org/wiki/Netcat "https://en.wikipedia.org/wiki/Netcat") is ...; manpage: [netcat](http://man.cx/netcat "http://man.cx/netcat")

As default OpenWrt installs

- `busybox-ash` (that is the Busybox-fork of the Debian implementation of the [Almquist shell](https://en.wikipedia.org/wiki/Almquist%20shell "https://en.wikipedia.org/wiki/Almquist shell") (see → [http://www.in-ulm.de/~mascheck/various/ash/#busybox](http://www.in-ulm.de/~mascheck/various/ash/#busybox "http://www.in-ulm.de/~mascheck/various/ash/#busybox")). In case you want to read about it.)
- `busybox-nc` (= the busybox implementation of netcat) does not support server mode.

You can anytime replace those packages by they original counterparts:

```
opkg install bash netcat
```

Examples:

- [https://forum.openwrt.org/viewtopic.php?pid=210001#p210001](https://forum.openwrt.org/viewtopic.php?pid=210001#p210001 "https://forum.openwrt.org/viewtopic.php?pid=210001#p210001")
- [http://www.razvantudorica.com/08/web-server-in-one-line-of-bash/](http://www.razvantudorica.com/08/web-server-in-one-line-of-bash/ "http://www.razvantudorica.com/08/web-server-in-one-line-of-bash/")

```
while true; do { echo -e 'HTTP/1.1 200 OK\r\n'; cat /tmp/index.html; } | netcat -l -p 8080; done
```

- [https://github.com/TooTallNate/bashttpd](https://github.com/TooTallNate/bashttpd "https://github.com/TooTallNate/bashttpd") - A web server written in bash , implementation that “Simplify things by using pipes”
