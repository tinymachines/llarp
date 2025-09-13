# µMurmur

µMurmur or uMurmur is a minimalistic [Mumble (software)](https://en.wikipedia.org/wiki/Mumble%20%28software%29 "https://en.wikipedia.org/wiki/Mumble (software)") server primarily targeted to run on embedded devices with an open OS like OpenWrt.

Project page for more info and most up-to-date documentation at [https://github.com/umurmur/umurmur](https://github.com/umurmur/umurmur "https://github.com/umurmur/umurmur")

## Preparation

### Prerequisites

So far there are two uMurmur packages available in the repos, one compiled against the Mbed-TLS library and one against the OpenSSL library.

```
opkg info umurmur-mbedtls
opkg info umurmur-openssl
```

***Note*** that currently, the Mbed-TLS version does not auto-generate a certificate, causing it to not startup correctly. It is therefor suggested to use the OpenSSL version for the time being.

See this GitHub issue: [https://github.com/openwrt/packages/issues/22188](https://github.com/openwrt/packages/issues/22188 "https://github.com/openwrt/packages/issues/22188")

*Firewall:* The default ports are 64738 tcp and 64738 udp. [open](/docs/guide-user/firewall/fw3_configurations/fw3_config_examples#opening_ports_on_the_openwrt_router "docs:guide-user:firewall:fw3_configurations:fw3_config_examples") them up in `/etc/config/firewall`.

### Required Packages

The following list specifies package versions for latest stable release of OpenWrt. At time of writing, 23.05.

#### Server (OpenWrt)

Name Version Size Description umurmur-openssl 0.2.20-2 36762 Minimalistic Mumble server daemon. Uses OpenSSL library for SSL and crypto. libopenssl3 3.0.12-1 1394609 The OpenSSL Project is a collaborative effort to develop a robust, commercial-grade, full-featured, and Open Source toolkit implementing the Secure Sockets Layer (SSL v2/v3) and Transport Layer Security (TLS v1) protocols as well as a full-strength general purpose cryptography library. This package contains the OpenSSL shared libraries, needed by other programs. libconfig11 1.7.3-1 15719 Libconfig is a simple library for manipulating structured configuration files. This file format is more compact and more readable than XML. And unlike XML, it is type-aware, so it is not necessary to do string parsing in application code. Libconfig is very compact -- just 38K for the stripped C shared library (less than one-fourth the size of the expat XML parser library) and 66K for the stripped C++ shared library. This makes it well-suited for memory-constrained systems like handheld devices. libprotobuf-c 1.4.1-1 9922 Runtime library to use Google Protocol Buffers from C applications. Protocol Buffers are a way of encoding structured data in an efficient yet extensible format. Google uses Protocol Buffers for almost all of its internal RPC protocols and file formats.

#### Client (your PC)

On Linux you need to install the `mumble` package, like [this one](http://packages.debian.org/squeeze/mumble "http://packages.debian.org/squeeze/mumble"). On Windows or MacOSX you have to download it: [http://mumble.sourceforge.net/](http://mumble.sourceforge.net/ "http://mumble.sourceforge.net/").

***Note*** that uMurmur version 0.2.x is compatible with Mumble version 1.2.x series. Mumble version 1.1.x series is **not** compatible.

## Installation

Example using shell access:

```
opkg install umurmur-openssl
vi /etc/umurmur.conf
/etc/init.d/umurmur enable
/etc/init.d/umurmur start
logread
```

Check log output that the `uMurmurd` started up OK.

[open](/docs/guide-user/firewall/fw3_configurations/fw3_config_examples#opening_ports_on_the_openwrt_router "docs:guide-user:firewall:fw3_configurations:fw3_config_examples") port 64738 for TCP and UDP in `/etc/config/firewall`.

```
vi /etc/config/firewall
/etc/init.d/firewall reload 
```

You should now be able to connect via the mumble protocol.

## Configuration

`cat /etc/umurmur.conf`

`max_bandwidth = 48000; welcometext = “Welcome to uMurmur!”; certificate = “/etc/umurmur/cert.crt”; private_key = “/etc/umurmur/key.key”; password = “”; max_users = 10; # Root channel must always be defined first. # If a channel has a parent, the parent must be defined before the child channel(s). channels = ( { name = “Root”; parent = “”; description = “The Root of all channels”; }, { name = “Lobby”; parent = “Root”; description = “Lobby channel”; }, { name = “Red team”; parent = “Lobby”; description = “The Red team channel”; }, { name = “Blue team”; parent = “Lobby”; description = “The Blue team channel”; } ); # Channel links configuration. channel_links = ( { source = “Lobby”; destination = “Red team”; }, { source = “Lobby”; destination = “Blue team”; } ); default_channel = “Lobby”;`

## Start on boot

To enable/disable start on boot: `/etc/init.d/umurmur enable` this simply creates a symlink to umurmur in “`/etc/rc.d/`” `/etc/init.d/umurmur disable` this removes the symlink again

## Administration

There is no privilege system implemented in uMurmur version &lt; 0.2.10 meaning that users cannot be kicked, banned or muted by other users. If you have a need for this kind of functionality the options are:

- Set a server password
- Add the IP of misbehaving users to your firewall.

Since uMurmur 0.2.10 there is a password based administration scheme. A package is available in OpenWRT trunk. For this to work you'd need to install the dependencies from trunk as well if you are running Backfire.

## Troubleshooting

The most common error is the firewall. Double check connection problems with

```
iptables -n -v
```

and check those counters.

If users cannot connect and you get this error in the log

```
WARN: SSL handshake failed: -28672
```

you're probably running Backfire 10.03.1-rc4 with Polarssl 0.14. Upgrade to Backfire 10.03.1-RC5 or later.

## Notes

1. Read about certificates in general. Do it! [Public key certificate](https://en.wikipedia.org/wiki/Public%20key%20certificate "https://en.wikipedia.org/wiki/Public key certificate")
2. enlighten your friends, there is no point in security if not all users understand the principle of operation

<!--THE END-->

- Project Homepage: [https://github.com/umurmur/umurmur](https://github.com/umurmur/umurmur "https://github.com/umurmur/umurmur")
