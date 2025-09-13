# Accessing LuCI web interface securely

If you are doing admin things via LuCI web interface, there is a risk that a user of your OpenWrt network is sniffing your traffic. You are at risk of giving away your LuCI web credentials to attacker. There are some ways to mitigate this risk.

Note that you need to choose wisely which of these methods suit your security needs. Don't be so attached about one method that you despise others in favor of your preferred methods. *Security is about doing things securely.*

## About HTTPS on OpenWrt

This is the standardized practice to secure HTTPS protocol.

\# Advantages Disadvantages 1 Simple access Bloated for devices with low storage 2 Standardized protocol Non-properly signed certificate triggers browser warning

The main advantage of HTTPS is a standardized protocol for securing HTTP connection. To access an HTTPS page is just typing [https://openwrt.lan/](https://openwrt.lan/ "https://openwrt.lan/") instead of [http://openwrt.lan/](http://openwrt.lan/ "http://openwrt.lan/"). It's simple. Just make sure that luci-ssl and its dependencies are [installed](/docs/guide-user/luci/luci.essentials#installation "docs:guide-user:luci:luci.essentials").

There are some disadvantages, though. Here are some of them.

1\. External libraries makes a bloated installation.

On systems with just 4 MB of flash, it's not possible to enable HTTPS for LuCI web interface. Why? Because with TLS libraries integrated, the resulting image doesn't fit 4 MB of flash. Unless you have done some workaround such as expanding overlayfs size, it's unpractical.

2\. Browser warning on non-properly signed certificate.

Well, this is a good browser feature. Unless the self signed root CA has been imported to the browser, this warning creeps you out! Why bother with commercial CA when your need is just securing your own router management interface for your own use?

Of course, you can just buy a properly signed certificate for your own openwrt.lan domain and ip address to get rid of the annoying browser warning. You can also just import the self-signed root CA used for certificate creation to your browser certificate store.

See also: [How to get rid of LuCI HTTPS certificate warnings](/docs/guide-user/luci/getting_rid_of_luci_https_certificate_warnings "docs:guide-user:luci:getting_rid_of_luci_https_certificate_warnings")

## Enable LuCI HTTPS redirect from HTTP

Since OpenWrt 21.02 is LuCI now available over HTTPS in addition to HTTP by default, without installing any additional packages. There is no automatic redirection to HTTPS on a fresh OpenWrt 21.02 installation, however, redirection *will* be enabled after upgrading from OpenWrt 19.07 to OpenWrt 21.02.

It is always possible to activate or deactivate the redirection to HTTPS like this:

```
uci set uhttpd.main.redirect_https=1     # 1 to enable redirect, 0 to disable redirect
uci commit uhttpd
service uhttpd reload
```

NOTE: Redirect needs to be off if you will be SSH tunneling

## Tunneling LuCI HTTP protocol through SSH

This little hack is convenient for devices with very limited storage.

\# Advantages Disadvantages 1 Secure encryption over SSH tunnel More complicated to setup 2 No additional TLS libraries needed

On standard OpenWrt installation, an SSH server daemon is always available. This is good news for limited-storage devices , since it's not necessary to install additional TLS libraries. Just use your favorite SSH client to setup port forwarding and all LuCI HTTP connection will be encapsulated within SSH packets.

This means that you get the same level protection of SSH, while getting rid of those TLS disadvantages for OpenWrt devices with low storage. Of course, there is disadvantages for this method. It requires more work to be done on SSH-client to setup the SSH-tunnel. I think the setup complexity is for the first time only. Later, it will be more simple to start the tunnel.

### Securing against brute-force attacks

[uHTTPd](/docs/guide-user/services/webserver/uhttpd "docs:guide-user:services:webserver:uhttpd") is the web server responsible of hosting the Luci web interface. By default uHTTPd listens to `0.0.0.0` which makes it accessible from the local network.

To prevent LuCI web interface from being brute-forced from attackers already in the local network, we are going to edit the uHTTPd config file and change its settings, so it only listens to `localhost`.

```
uci -q delete uhttpd.main.listen_http
uci add_list uhttpd.main.listen_http="127.0.0.1:80"
uci add_list uhttpd.main.listen_http="[::1]:80"
uci -q delete uhttpd.main.listen_https
uci add_list uhttpd.main.listen_https="127.0.0.1:443"
uci add_list uhttpd.main.listen_https="[::1]:443"
uci commit uhttpd
/etc/init.d/uhttpd restart
```

NOTE: You may have to add a uHTTPd restart in your local startup (`/etc/rc.local`) : `/etc/init.d/uhttpd restart` due to on boot uHTTPd throwing an error becuause `localhost` is not setup yet.

### Setting up the SSH-tunnel

If you are willing to spend a little effort to setup SSH-tunnel, here is a simple guide for some popular SSH clients. This guide is just about setting up a local port forwarding to LuCI web interface.

This setup will forward all traffic passing through port 8000 from 127.0.0.1 on your local machine (desktop or laptop) to port 80 of your OpenWrt device, which has a local address of 127.0.0.1. You may understand better by viewing this graph.

Local machine OpenWrt device 127.0.0.1:8000 127.0.0.1:80 sending packets → receiving packets receiving response ← sending response

All traffic bypassing through port 8000 on local machine will be forwarded to port 80 on the remote machine. That's why this SSH-tunnel setup is called local port forwarding.

#### OpenSSH client

This is the standard SSH client for GNU/Linux and BSD distributions. To establish an SSH tunnel for LuCI web interface access, just add a local port forwarding options to the command line. Make necessary adjustments if needed (hostname, port, identity file, etc).

```
ssh -L127.0.0.1:8000:127.0.0.1:80 root@openwrt.lan
```

The SSH-tunnel is active as long as the SSH session is active.

For convenient setup, you may create host profile for this setup. Edit `~/.ssh/config` file and add the following line. For more explanation about all available configuration, refer to [ssh\_config](http://man.cx/ssh_config "http://man.cx/ssh_config"). Be sure to make necessary adjustments if needed.

```
Host luci-tunnel
	Hostname openwrt.lan
	Port 22
	User root
	LocalForward 127.0.0.1:8000 127.0.0.1:80
```

After creating the above configuration, the SSH-tunnel can be started by issuing the following command.

```
ssh luci-tunnel
```

The command will read `luci-tunnel` host profile and set up the SSH-tunnel accordingly.

#### PuTTY

PuTTY is popular Windows SSH client. To establish SSH-tunnel, you need to perform more steps.

1. Navigate to *Connection* ⇒ *SSH* ⇒ *Tunnels*.
2. Fill **8000** on the *Source port* field.
3. Fill **127.0.0.1:80** on the *Destination* field.
4. Click *Add* until the port forwarding setup appears on *Forwarded ports* section. Typically, the shown forwarding setup is **L8000 127.0.0.1:80**.
5. Navigate to *Session*. Fill **root@openwrt.lan** on *Host Name* field and **22** on *Port* field. If you have modified your OpenWrt hostname and SSH listen port, you need to adjust the value accordingly.
6. On the *Saved Sessions* field, type a unique name, such as **OpenWrt LuCI Tunnel**. Click *Save*, so that you don't need to repeat this setup for future use.
7. To start the SSH-tunnel session, click *Open*. The tunnel will be active as long as the SSH session is active.
8. To start the SSH-tunnel in the future, just select **OpenWrt LuCI Tunnel** on the PuTTY new session dialog, click *Load* and then click *Open*.

### Accessing LuCI via SSH-tunnel

To access LuCI web interface securely, type [**http://127.0.0.1:8000/**](http://127.0.0.1:8000/ "http://127.0.0.1:8000/") instead of [http://openwrt.lan/](http://openwrt.lan/ "http://openwrt.lan/") or [http://192.168.1.1/](http://192.168.1.1/ "http://192.168.1.1/"). The traffic between your browser to uHTTPd webserver is encapsulated within SSH-tunnel, so that the http traffic gains the same level of SSH traffic encryption.

If you have finished accessing LuCI web interface, don't forget to end the SSH session.

### More secure configuration

For additional security, you may disable the uHTTPd webserver altogether and start it via SSH only when needed.

```
/etc/init.d/uhttpd disable
/etc/init.d/uhttpd stop
```

With this setup, you minimize the risk of the uHTTPd webserver being brute-forced and prevent unauthorized access to LuCI web interface, as long as your SSH setup is secure (disabling password and using only public key authentication).

As a bonus, your OpenWrt device performance may increase because of some system resources (memory, swap, and cpu usage) freed from uhttpd process.

See also: [Managing services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services")

### Allow access from Internet

If you have a public IP address then you can access your device's Luci or SSH shell remotely from the Internet. You can set up a [VPN server](/docs/guide-user/services/vpn/start "docs:guide-user:services:vpn:start") like [WireGuard](/docs/guide-user/services/vpn/wireguard/server "docs:guide-user:services:vpn:wireguard:server") or [OpenVPN](/docs/guide-user/services/vpn/openvpn/server "docs:guide-user:services:vpn:openvpn:server") then connect to a network and access the OpenWrt device as from a local network.

But if you really wish to access the device directly then you must make a few configuration steps. By default all traffic from the external WAN interface is blocked by a firewall. So if you wish to get an access you have to allow the specific port to be accessed by a firewall rule.

**But you better not to do this because the public internet access is not safe and you may attacked!** There are many scanning bots that are looking for open ports and tries to crack a password or sends exploits. The traffic should be encrypted so only HTTPS (based on TLS) or SSH may be used safely. Even if you have a good security with strong passwords and encryption you still may be attacked by DDoS but that will cost a lot for an attacker.

**You must be 100% sure what are you doing.**

For example, if you have a Transmission UI on a separate port, then it should be generally ok to allow the WAN access. But the WAN access to Luci is potentially more dangerous.

You may want to add some restrictions like:

1. IP allow list or [banip](/docs/guide-user/services/banip "docs:guide-user:services:banip")
2. Use upfront external WAF and DDoS prevention services [Cloudflare Proxy](https://www.cloudflare.com/ "https://www.cloudflare.com/")
3. Use tunnels or Zero Trust VPNs that at least adds an encryption. Most popular are:
   
   1. [SSH tunnel](/docs/guide-user/services/ssh/sshtunnel "docs:guide-user:services:ssh:sshtunnel")
   2. [Tor onion service](/docs/guide-user/services/tor/hs "docs:guide-user:services:tor:hs").
   3. [ZeroTier](/docs/guide-user/services/vpn/zerotier "docs:guide-user:services:vpn:zerotier")
   4. [Cloudflare Zero Trust](/docs/guide-user/services/vpn/cloudfare_tunnel "docs:guide-user:services:vpn:cloudfare_tunnel")
   5. [Tailscale](/docs/guide-user/services/vpn/tailscale/start "docs:guide-user:services:vpn:tailscale:start")

#### Allow HTTPS access from Internet

So you do want to open an external access to your Luci e.g. on web server (uhttpd). First of all you better to have a domain (at least a free [DDNS](/docs/guide-user/services/ddns/client "docs:guide-user:services:ddns:client")) and point it to your IP.

Now you need to add a firewall rule to open HTTP on 80 port and HTTPS (443):

```
config rule 'wan_https_allow'
	option name 'Allow external access from WAN to HTTP and HTTPS ports'
	option enabled '1'
	option target 'ACCEPT'
	option dest_port '80 443'
	option proto 'tcp'
	option src 'wan'
```

To create the rule and reload firewall use:

```
# create a new section of the rule in /etc/config/firewall
uci add firewall wan_https_allow
uci set firewall.wan_https_allow=rule
uci set firewall.wan_https_allow.name='Allow HTTP, HTTPS from WAN'
uci set firewall.wan_https_allow.src='wan'
uci set firewall.wan_https_allow.proto='tcp'
uci set firewall.wan_https_allow.dest_port='80 443'
uci set firewall.wan_https_allow.target='ACCEPT'
# save the new section to /etc/config/firewall
uci commit firewall
# reload the firewall to pick up the new rule
/etc/init.d/firewall reload
```

These commands use the OpenWrt [uci command](/docs/techref/uci "docs:techref:uci"), a brilliant way to parse, get, set, and edit values and sections from config files. It makes scripting OpenWrt a breeze.

Here you may see that we also allowed the raw unencrypted HTTP on 80 port. This is needed because some browsers may still use the HTTP by default when you type in address bar. The ACME webroot validation is also use the HTTP port but.

The plain HTTP should not be used and you should enable a web server (uhttpd) the redirect requests from HTTP to HTTPS. For the uhttpd this is made easily with one option:

```
uci set uhttpd.main.redirect_https=1
uci commit
/etc/init.d/uhttpd restart
```

Now enable uhttpd to respond to requests to your domain (e.g. example.com or example.duckdns.org) from devices on your private LAN. This is required because uhttpd by default rejects any requests from a private LAN host to the WAN address, which is what your domain resolves to.

```
uci set uhttpd.main.rfc1918_filter='0'
uci commit uhttpd
/etc/init.d/uhttpd restart
```

By default the OpenWrt device has a Luci with a configured “snake oil” self signed TLS certificate so you should be able to open it. Your browser will show a warning that it can't trust to the certificate. For a better security and convenience you should configure a [TLS cert issuing with ACME](/docs/guide-user/services/tls/acmesh "docs:guide-user:services:tls:acmesh").

#### Allow SSH access from Internet

Create a firewall rule to allow access to SSH (port 22):

```
uci add firewall wan_ssh_allow
uci set firewall.wan_ssh_allow=rule
uci set firewall.wan_ssh_allow.name='Allow SSH from WAN'
uci set firewall.wan_ssh_allow.src='wan'
uci set firewall.wan_ssh_allow.proto='tcp'
uci set firewall.wan_ssh_allow.dest_port='22'
uci set firewall.wan_ssh_allow.target='ACCEPT'
```

Please read [Security considerations](/docs/guide-user/base-system/dropbear#security_considerations "docs:guide-user:base-system:dropbear") for the SSH sever.
