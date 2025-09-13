# Dropbear configuration

- Follow [SFTP server](/docs/guide-user/services/nas/sftp.server "docs:guide-user:services:nas:sftp.server") to provide SFTP support.
- Follow [Dropbear key-based authentication](/docs/guide-user/security/dropbear.public-key.auth "docs:guide-user:security:dropbear.public-key.auth") to set up key-based authentication.
- Follow [Secure your router's access](/docs/guide-user/security/secure.access "docs:guide-user:security:secure.access") for additional security hardening.

The SSH configuration is handled by the [Dropbear](https://en.wikipedia.org/wiki/Dropbear%20%28software%29 "https://en.wikipedia.org/wiki/Dropbear (software)") subsystem of uci and the configuration file is located in `/etc/config/dropbear`.

Each dropbear SSH server instance uses a single section of the configuration file, and you can have multiple instances.

## Sections

The `dropbear` configuration contains settings for the dropbear SSH server in a single section.

### Dropbear

The `dropbear` section contains these settings. Names are case-sensitive.

Name Type Required Default Description `enable` boolean no 1 Set to `0` to disable starting dropbear at system boot. `verbose` boolean no 0 Set to `1` to enable verbose output by the start script. `BannerFile` string no *(none)* Name of a file to be printed before the user has authenticated successfully. `PasswordAuth` boolean no 1 Set to `0` to disable authenticating with passwords. `Port` integer no 22 Port number to listen on. `RootPasswordAuth` boolean no 1 Set to `0` to disable authenticating as root with passwords. `RootLogin` boolean no 1 Set to `0` to disable SSH logins as root. `GatewayPorts` boolean no 0 Set to `1` to allow remote hosts to connect to forwarded ports. `Interface` string no *(none)* Write an interface name, for example `lan`. With this setting you can limit connections to clients that can reach the IP of this interface. So for example the LAN IP of the interface can only be seen from clients in the LAN network, but not from the WAN in the default firewall configuration. It's used in dropbear's -p option that does the following: “Listen on specified address and TCP port. If just a port is given listen on all addresses. up to 10 can be specified (default 22 if none specified). ” `keyfile` list of files no *(none)* Path to host key file. `rsakeyfile` file no *(none)* Path to RSA host key file. *Deprecated.* See `keyfile`. `SSHKeepAlive` integer no 300 Ensure that traffic is transmitted at a certain interval in seconds. This is useful for working around firewalls or routers that drop connections after a certain period of inactivity. The trade-off is that a session may be closed if there is a temporary lapse of network connectivity. A setting of 0 disables keepalives. If no response is received for 3 consecutive keepalives the connection will be closed. Equivalent of OpenSSH `ClientAliveInterval` `IdleTimeout` integer no 0 Disconnect the session if no traffic is transmitted or received for `IdleTimeout` seconds even after the `SSHKeepAlive` keep alive pings. Equivalent of OpenSSH `ClientAliveInterval` multiplied on `ClientAliveCountMax` `mdns` integer no 1 Whether to announce the service via [mDNS](/docs/guide-developer/mdns "docs:guide-developer:mdns") `MaxAuthTries` integer no 3 Amount of times you can retry writing the password when logging in before the SSH server closes the connection. `RecvWindowSize` integer no 24576 Specify the per-channel receive window buffer size. Increasing this may improve network performance at the expense of memory use.

### Default configuration

This is the default configuration:

```
# uci show dropbear
dropbear.@dropbear[0]=dropbear
dropbear.@dropbear[0].RootPasswordAuth='1'
dropbear.@dropbear[0].PasswordAuth='1'
dropbear.@dropbear[0].Port='22'
```

## Extras

### Multiple instances

Add a second instance of dropbear listening on port 2022.

```
uci add dropbear dropbear
uci set dropbear.@dropbear[-1].RootPasswordAuth='1'
uci set dropbear.@dropbear[-1].PasswordAuth='0'
uci set dropbear.@dropbear[-1].Port="2022"
uci commit dropbear
service dropbear restart
```

If you want to connect from internet you need to allow the 2022 port on WAN interface.

### OpenSSH compatibility

Dropbear does not support SFTP by itself. Meanwhile OpenSSH client uses SFTP [by default](https://www.openssh.com/releasenotes.html#9.0 "https://www.openssh.com/releasenotes.html#9.0"). Use `scp -O` for the [legacy SCP protocol](https://man.openbsd.org/scp#O "https://man.openbsd.org/scp#O") if necessary.

If you do have enough space you can install the SFTP server:

```
opkg update
opkg install openssh-sftp-server
```

### Security considerations

- Set up [public key authentication](/docs/guide-user/security/dropbear.public-key.auth "docs:guide-user:security:dropbear.public-key.auth") and disable password authentication if possible.
- Set up a [VPN](/docs/guide-user/services/vpn/start "docs:guide-user:services:vpn:start") to avoid exposing SSH to the internet as a single critical vulnerability may be enough for a remote attacker to gain root access.

Problems facing with a public SSH:

- No normal group for users and no normal user.
- No facility to ban IPs with many failed login attempts.
- File system permissions are very lax on default OpenWrt.
- Preventing normal users from exploiting BusyBox to gain access to root only commands due to missing permissions for symlinks.

### References

- [Dropbear homepage](https://matt.ucc.asn.au/dropbear/dropbear.html "https://matt.ucc.asn.au/dropbear/dropbear.html")
- [Dropbear man page](https://www.mankier.com/8/dropbear "https://www.mankier.com/8/dropbear")

### See also

- [Replace Dropbear to OpenSSH](/docs/guide-user/services/ssh/openssh_instead_dropbear "docs:guide-user:services:ssh:openssh_instead_dropbear")
- [SSH articles](/docs/guide-user/services/ssh/start "docs:guide-user:services:ssh:start") - tunneling, SSHFS mounting etc.
- [Dropbear key-based authentication](/docs/guide-user/security/dropbear.public-key.auth "docs:guide-user:security:dropbear.public-key.auth")
- [Port knocking](/docs/guide-user/services/remote_control/portknock.server "docs:guide-user:services:remote_control:portknock.server")
