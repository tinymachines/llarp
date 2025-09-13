# SSH tunnel

The `ssh` command allows to create tunnels and forward a port which is useful to bypass NAT. E.g. when you don't have a public IP but have a server or router that have it. This is simplest and popular way of tunneling because not need for a dedicated client. As a downside an encrypted TLS (HTTPS) traffic will be additionally encrypted by SSH. But it's really not a big slowdown. Alternatively you can use [pppossh](/docs/guide-user/services/vpn/pppossh/start "docs:guide-user:services:vpn:pppossh:start") for a full VPN tunneling over SSH.

The simplest tunnel for port forward can be created with a command like `ssh -R *:80:127.0.0.1:80 jonh@myhome.jonh.me`.

In order to keep tunnel reconnecting after disconnect you need to install and configure the additional service [sshtunnel](https://openwrt.org/packages/pkgdata/sshtunnel "https://openwrt.org/packages/pkgdata/sshtunnel"). The service also provides an easy UCI configuration file and has LUCI app to configure from GUI.

## Install

To install from a command line use `opkg install sshtunnel`.

The SSH client included by default on OpenWrt is [DropBear dbclient](https://manpages.debian.org/testing/dropbear-bin/dbclient.1 "https://manpages.debian.org/testing/dropbear-bin/dbclient.1"). It's small and supports remote and local tunnels but has limited options. Previously, before the sshtunnel version 5.1 it's package installed as a dependency the full [openssh-client](https://openwrt.org/packages/pkgdata/openssh-client "https://openwrt.org/packages/pkgdata/openssh-client"). If you have enough of space it's generally recommended to install it with a command `opkg install openssh-client`.

There is a LUCI app [luci-app-sshtunnel](https://openwrt.org/packages/pkgdata/luci-app-sshtunnel "https://openwrt.org/packages/pkgdata/luci-app-sshtunnel") that provides a GUI for the `sshtunnel`. You may install it with `opkg install luci-app-sshtunnel`. It may be not yet available in the main packages feed.

## Configuration

The UCI configuration is located in `/etc/config/sshtunnel`. This file is responsible for defining *ssh servers* and *tunnels*.

A typical sshtunnel config file contains at least one `server` specifying the connection to an ssh server and one or more `tunnelL`, `tunnelR` or `tunnelD` defining Local, Remote or Dynamic tunnels.

### Server

In most cases there will be only one server defined, but possibly several tunnels to this server.

A minimal `server` declaration may look like the example below.

```
config server 'home'
	option user       'jonh'
	option hostname   'myhome.jonh.me'
	option port       '22'
```

\* `home` will identify this server on the tunnels sections * `jonh` specifies the username on the remote machine * `myhome.jonh.me` is the hostname of a remote machine running an SSH server.

The possible options for server sections are listed in the table below:

Name Type Required Default Description `user` string yes `root` remote host username. `hostname` string yes remote host hostname. `port` integer yes 22 Port to connect to on the remote host. `IdentityFile` string no Specifies a file from which the user's RSA, ed25519 or ECDSA authentication identity is read. The default is `/root/.ssh/id_rsa`, `/root/.ssh/id_ed25519`, `/root/.ssh/id_ecdsa` or `/root/.ssh/id_dropbear` `retrydelay` integer no 60 Delay after a connection failure before trying to reconnect. `StrictHostKeyChecking` string no `accept-new` If this flag is set to `yes`, ssh will never automatically add host keys to the `~/.ssh/known_hosts` file, and refuses to connect to hosts whose host key has changed. This provides maximum protection against trojan horse attacks, though it can be annoying when the `/root/.ssh/known_hosts` file is poorly maintained or when connections to new hosts are frequently made. This option forces the user to manually add all new hosts. If this flag is set to `no`, ssh will automatically add new host keys to the user known hosts files. If this flag is set to `accept-new`, new host keys will be added to the known host files and ssh will refuse to connect to hosts whose host key has changed.

If you have the `openssh-client` then you can specify advanced options:

Name Type Default Description `LogLevel` string `INFO` Gives the verbosity level that is used when logging messages from ssh. The possible values are: `QUIET`, `FATAL`, `ERROR`, `INFO`, `VERBOSE`, `DEBUG`, `DEBUG1`, `DEBUG2`, and `DEBUG3`. The DEBUG and DEBUG1 are equivalent, DEBUG2 and DEBUG3 each specify higher levels of verbose output. `CheckHostIP` string `yes` Enable check the host IP address in the `known_hosts` file. This allows ssh to detect if a host key changed due to DNS spoofing. `Compression` string `no` Enable gzip compression. It may be useful on slow connections but increases CPU usage and adds a small latency. `ServerAliveCountMax` string 3 Sets the number of server alive messages (see below) which may be sent without ssh receiving any messages back from the server. If this threshold is reached while server alive messages are being sent, ssh will disconnect from the server, terminating the session. It is important to note that the use of server alive messages is very different from TCPKeepAlive (below). The server alive messages are sent through the encrypted channel and therefore will not be spoofable. The TCP keepalive option enabled by TCPKeepAlive is spoofable. The server alive mechanism is valuable when the client or server depend on knowing when a connection has become inactive. If, for example, ServerAliveInterval (see below) is set to 15 and ServerAliveCountMax is left at the default, if the server becomes unresponsive, ssh will disconnect after approximately 45 seconds. `ServerAliveInterval` string 0 Sets a timeout interval in seconds after which if no data has been received from the server, ssh will send a message through the encrypted channel to request a response from the server. The default is 0, indicating that these messages will not be sent to the server. `TCPKeepAlive` string `yes` Specifies whether the system should send TCP keep-alive messages to the other side. If they are sent, death of the connection or crash of one of the machines will be properly noticed. However, this means that connections will die if the route is down temporarily, and some people find it annoying. The default is `yes` (to send TCP keepalive messages), and the client will notice if the network goes down or the remote host dies. `VerifyHostKeyDNS` string `no` Specifies whether to verify the remote key using DNS and SSHFP resource records. If this option is set to `yes`, the client will implicitly trust keys that match a secure fingerprint from DNS. `ProxyCommand` string Proxy tunnel command. The command to use to connect to the server. For example, the following command would connect via an HTTP proxy: `ncat --proxy-type http --proxy-auth alice:secret --proxy 192.168.1.2:8080 %h %p`

For the `openssh-client` you can also configure the server options in the `/root/.ssh/config` file:

```
Host home
    HostName myhome.jonh.me
    Port 22
    User jonh
    # Allow old DSA keys used by old OpenWrt router
    PubkeyAcceptedKeyTypes +ssh-dss
    HostkeyAlgorithms +ssh-rsa
```

But you still need to create a corresponding `server` section and use the `Host` as `hostname`'.

See OpenSSH [man ssh\_config](https://manpages.debian.org/testing/openssh-client/ssh_config.5 "https://manpages.debian.org/testing/openssh-client/ssh_config.5")

### Tunnels

A complete sshtunnel configuration contains at least one section:

- `tunnelR` a remote tunnel: Forward a port on the remote host to a service on the local host.
- `tunnelL` a local tunnel: Forward a port on the local host to a service on the remote host.
- `tunnelD` a Dynamic Tunnel e.g. SOCKS4/SOCKS5 proxy via remote host.
- `tunnelW` TUN/TAP VPN. Requires `openssh-client`.

If no any tunnel were specified for the server then the sshtunnel won't connect to it.

#### tunnelR

A example for a `tunnelR` declaration is given below:

```
config tunnelR local_ssh
        option server         'home'
        option remoteaddress  '*'
        option remoteport     '2222'
        option localaddress   '127.0.0.1'
        option localport      '22'
```

- **`*`** means to accept a connection from any interface on the **Server side**

`Specifying a remote bind_address will only succeed if the server's GatewayPorts option is enabled. See “SSH Server configuration” bellow`

- **`2222`** is the TCP port to bind on the **Server side**
- **`127.0.0.1`** is the **OpenWrt side** address to where the remote connection will be forwarded
- **`22`** is the **OpenWrt side** TCP port where to the remote connection will be forwarded

The equivalent `ssh` command would be `ssh -R *:2222:127.0.0.1:22 jonh@myhome.jonh.me`

The possible options for `tunnelR` sections are listed in the table below:

Name Type Required Default Description `enabled` boolean no `1` Enable or disable with `0` the auto establishment of the tunnel on service start `server` string yes *(none)* Specifies the used server, must refer to one of the defined server sections `remoteaddress` string no `*` Server side address `remoteport` integer yes *(none)* Server side TCP port `localaddress` string yes *(none)* OpenWrt side address `localport` integer yes *(none)* OpenWrt side TCP port

#### tunnelL

For a `tunnelL` the declaration is similar:

```
config tunnelL server_http
        option server         'home'
        option remoteaddress  '127.0.0.1'
        option remoteport     '8080'
        option localaddress   '*'
        option localport      '80'
```

- **`127.0.0.1`** is the **Server side** address to where the connection will be forwarded
- **`8080`** is the **Server side** TCP port to where the local connection will be forwarded
- **`*`** means to accept a connection from any interface on the **OpenWrt side**
- **`80`** is the local TCP port to bind on the **OpenWrt side**

The equivalent `ssh` command would be `ssh -L *:80:127.0.0.1:8080 jonh@myhome.jonh.me`

The possible options for `tunnelL` sections are listed in the table below:

Name Type Required Default Description `enabled` boolean no `1` Enable or disable with `0` the auto establishment of the tunnel on service start `server` string yes *(none)* Specifies the used server, must refer to one of the defined server sections `remoteaddress` string yes *(none)* Server side address `remoteport` integer yes *(none)* Server side TCP port `localaddress` string no `*` OpenWrt side address `localport` integer yes *(none)* OpenWrt side TCP port

#### tunnelD

A `tunnelD` declaration will create a SOCKS proxy accessible on the defined local port. This is supported only with the `openssh-client`.

```
config tunnelD proxy
        option server         'home'
        option localaddress   '*'
        option localport      '1080'
```

- **`*`** means to accept a connection from any interface on the **OpenWrt side**
- **`1080`** is the local TCP port to bind on the **OpenWrt side**

The equivalent `ssh` command would be `ssh -D *:1080 jonh@myhome.jonh.me`

The possible options for `tunnelD` sections are listed in the table below:

Name Type Required Default Description `enabled` boolean no `1` Enable or disable with `0` the auto establishment of the tunnel on service start `server` string yes *(none)* Specifies the used server, must refer to one of the defined server sections `localaddress` string no `*` OpenWrt side address `localport` integer yes *(none)* OpenWrt side TCP port

#### tunnelW

A `tunnelW` declaration will TUN/TAP devices on client and server to establish a VPN tunnel between them. This is supported only with the `openssh-client`. You better to use the [PPPoSSH](/docs/guide-user/services/vpn/pppossh/start "docs:guide-user:services:vpn:pppossh:start").

```
config tunnelW vpn
	option server           'home'
	option vpntype		'point-to-point'
	option localdev		'any'
	option remotedev	'any'
```

The equivalent `ssh` command would be `ssh -o Tunnel=point-to-point -w any:any jonh@myhome.jonh.me`

The possible options for `tunnelW` sections are listed in the table below:

Name Type Required Default Description `enabled` boolean no `1` Enable or disable with `0` the auto establishment of the tunnel on service start `server` string yes *(none)* Specifies the used server, must refer to one of the defined server sections `vpntype` string no `point-to-point` `point-to-point` or `ethernet` `remotedev` string yes `any` tun device numerical ID or the keyword `any`, which uses the next available tunnel device `localdev` string yes `any` remote device ID

See [Arch Wiki VPN over SSH](https://wiki.archlinux.org/title/VPN_over_SSH "https://wiki.archlinux.org/title/VPN_over_SSH")

### SSH tunnel providers

- [srv.us](https://docs.srv.us/ "https://docs.srv.us/") works with empty RemoteAddress or set to '\*'. You can also set a custom domain as a number 1, 2 etc.
- [localhost.run](https://localhost.run "https://localhost.run") works with empty RemoteAddress or set to '\*' but the generated domain will be rotated and changed on next restart. You need a custom domain (paid feature).
- [remote.moe](https://github.com/fasmide/remotemoe "https://github.com/fasmide/remotemoe") works only if a custom domain but this needs for some manual configuration.

See other options in the [Awesome tunneling: SSH services](https://github.com/yurt-page/awesome-tunneling#ssh-services "https://github.com/yurt-page/awesome-tunneling#ssh-services")

### SSH server configuration

To access an SSH server you need to add your public key to a list of authorized keys. So add your pub key (`id_ed25519.pub`, `id_rsa.pub`) to the `/root/.ssh/authorized_keys` or to the `/etc/dropbear/authorized_keys`. In LuCI you can do that with `System / Administration / SSH-Keys`.

For a remote tunnel you also should allow `GatewayPorts` on the server. For the Dropbear you can edit its config `vi /etc/config/dropbear`, add the `option GatewayPorts 1`, reload it with `service dropbear reload`.

Or by using UCI:

```
uci set dropbear.@dropbear[0].GatewayPorts=1
uci commit
```

For the OpenSSHd you need to edit the `/etc/ssh/sshd_config`, add the `GatewayPorts yes`, reload with `service sshd reload`.

mak

### See also

- [Video: Setup SSH tunnel on router](https://www.youtube.com/watch?v=xrtqq9fVq34 "https://www.youtube.com/watch?v=xrtqq9fVq34")
- [OpenWrt - Reverse SSH tunnel](https://eko.one.pl/?p=openwrt-sshtunnel "https://eko.one.pl/?p=openwrt-sshtunnel") in Polish
- [OpenWrt SSH tunnel](https://gist.github.com/ssalonen/9755dfd631a60951a369d563bb20cd71 "https://gist.github.com/ssalonen/9755dfd631a60951a369d563bb20cd71")
- [howto: SOCKS Proxy SSH Tunnels on OpenWRT](https://blog.thestateofme.com/2022/10/26/socks-proxy-ssh-tunnels-on-openwrt/ "https://blog.thestateofme.com/2022/10/26/socks-proxy-ssh-tunnels-on-openwrt/")
- [howto: OpenWrt SSH Tunneling](https://github.com/DerekGn/OpenWrt/wiki/OpenWrt-SSH-Tunneling "https://github.com/DerekGn/OpenWrt/wiki/OpenWrt-SSH-Tunneling")
- [sshtunnel SystemD](https://github.com/yurt-page/sshtunnel "https://github.com/yurt-page/sshtunnel") port of the sshtunnel to other SystemD based Linux distros (Ubuntu, Debian etc).
- [pppossh](/docs/guide-user/services/vpn/pppossh/start "docs:guide-user:services:vpn:pppossh:start") an L3 tunnel over SSH
- [sshuttle](https://gist.github.com/kylekyle/fcbb7b93ad9816915b31022a17f19cea "https://gist.github.com/kylekyle/fcbb7b93ad9816915b31022a17f19cea") - a Python based SSH VPN.
- [autossh](/docs/guide-user/services/ssh/autossh "docs:guide-user:services:ssh:autossh") - an older SSH re-connection tool
- [man ssh\_config — OpenSSH client configuration file. Manual](https://manpages.debian.org/testing/openssh-client/ssh_config.5.html "https://manpages.debian.org/testing/openssh-client/ssh_config.5.html")
- [man ssh — OpenSSH client. Manual](https://manpages.debian.org/testing/openssh-client/ssh.1.html "https://manpages.debian.org/testing/openssh-client/ssh.1.html")
- [sslh](https://github.com/yrutschle/sslh "https://github.com/yrutschle/sslh") - multiplexer proxy (e.g. share SSH and HTTPS)
