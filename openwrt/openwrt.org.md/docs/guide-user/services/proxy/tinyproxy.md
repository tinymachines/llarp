# Tinyproxy

[Tinyproxy](https://en.wikipedia.org/wiki/Tinyproxy "https://en.wikipedia.org/wiki/Tinyproxy") is a light-weight HTTP/HTTPS proxy daemon for POSIX operating systems. Designed from the ground up to be fast and yet small, it is an ideal solution for use cases such as embedded deployments where a full featured HTTP proxy is required, but the system resources for a larger proxy are unavailable. In a typical scenario it consumes 5-10M RAM and when installed to an OpenWRT enabled router.

- [https://tinyproxy.github.io/](https://tinyproxy.github.io/ "https://tinyproxy.github.io/")

### Installing

To install tinyproxy follow these steps:

Install software packages:

```
opkg update
opkg install tinyproxy luci-app-tinyproxy
```

Configure Tinyproxy:

```
uci set tinyproxy.@tinyproxy[0].enabled=1
uci commit
service tinyproxy enable
service tinyproxy restart
```

#### Detailed configuration

If you like to finetune the other options you can also use an editor like VI or nano to edit `/etc/config/tinyproxy`. The following configuration example blocks per default, a whitelist-file `/etc/config/tinyproxy_whitelist.txt` can contain FQDN / Hostnames as regular expression:

```
config tinyproxy
	option User 'nobody'
	option Group 'nogroup'
	option Port '8888'
	option Timeout '600'
	option DefaultErrorFile '/usr/share/tinyproxy/default.html'
	option StatFile '/usr/share/tinyproxy/stats.html'
	option LogFile '/var/log/tinyproxy.log'
	option LogLevel 'Info'
	option MaxClients '100'
	option MinSpareServers '5'
	option MaxSpareServers '20'
	option StartServers '10'
	option MaxRequestsPerChild '0'
	option ViaProxyName 'tinyproxy'
	list ConnectPort '443'
	list ConnectPort '563'
	option enabled '1'
	list Allow '192.168.1.0/24'
	list Allow '127.0.0.1'
	option Filter '/etc/config/tinyproxy_whitelist.txt'
	option FilterDefaultDeny '1'
```

The whitelist file `/etc/config/tinyproxy_whitelist.txt` can whitelist OpenWRT website like this:

```
# filter exactly cnn.com
# ^cnn\.com$
 
# filter all subdomains of cnn.com, but not cnn.com itself
# .*\.cnn.com$
 
# filter any domain that has cnn.com in it, like xcnn.comfy.org
# cnn\.com
 
# filter any domain that ends in cnn.com
# cnn\.com$
 
# filter any domain that starts with adserver
# ^adserver
 
^openwrt\.org$
.*\.openwrt\.org$
 
^127\.0\.0\.1$
^localhost$
```

Please note that only the FQDN / hostname can be filtered for HTTPS and HTTP. URL filtering with tinyproxy only works for unencrypted HTTP traffic because HTTPS-traffic is opaque to the proxy. It controls if the `CONNECT` command to a HTTPS server is accepted or rejected. The content of the transmission between client and server remains opaque and encrypted.

#### Configure firewall

Configure the firewall to filter/block client traffic aimed directly to the WAN. Clients must still be able to reach the proxy from the LAN side, but not the WAN. If this step is omitted clients can reconfigure their proxy settings to not use a proxy and bypass the proxy without any effort.

#### Configure the clients

Configure the clients to use the proxy. Browsers like Firefox / Chromium / Brave need the IP or hostname of the device where `tinyproxy` is installed to and the port. The proxy is the same for HTTP and HTTPS traffic. Many commands line clients like `opkg`, `wget` or `curl` make use of the environment variable `https_proxy=http://IP:8888`.

#### Transparent HTTP proxy

This steps is optional and nowadays, that most websites use encryption, it is not as useful as it was anymore. Prefer configuring the proxy at the client side, most browsers allow configuring the proxy manually for HTTP and HTTPS. For unencrypted HTTP connections the firewall can redirect traffic to the proxy. Client devices do not need to be configured to make use of the proxy server, but it only works for HTTP traffic. Encrypted HTTPS traffic cannot be handled this way.

Configure transparent proxy redirection:

```
uci add firewall redirect
uci set firewall.@redirect[0].name='Transparent Proxy Redirect'
uci set firewall.@redirect[0].src=lan
uci set firewall.@redirect[0].proto=tcp
uci set firewall.@redirect[0].dest_port=8888
uci set firewall.@redirect[0].src_dport=80
uci set firewall.@redirect[0].src_dip='!192.168.1.1'
uci set firewall.@redirect[0].dest_ip=192.168.1.1
uci commit firewall
service firewall restart
```

![:!:](/lib/images/smileys/exclaim.svg) Note that the **`firewall.@redirect[0].src_dip=!192.168.1.1`** option is important, if you missed this option you may not connect to LuCI. I can't find this option in the **LuCI → Network → Firewall → Traffic Redirection** page, so be careful if you're using LuCI.

Note also that by default tinyproxy does not allow connections from other hosts so you will need to enable this. One way is to comment out the “Allow” line from the config.

### Notes on Attitude Adjustment 12.09 and maybe IPv6

If you're using Attitude Adjustment 12.09 and maybe setup IPv6 on your OpenWrt box then this may be helpful. These notes only have a few hours of testing; second opinions, better advice welcomed:

- The “Traffic Redirection” page can be found at **Network → Firewall → Port Forwards** on 12.09
- The **`firewall.@redirect[0].src_dip=!192.168.1.1`** LuCI option is called “External IP address” in 12.09 and you'll have to enter a --custom-- value to enter the leading !
- Add “[::ffff:0:0/96](http://en.wikipedia.org/wiki/IPv6_address#Transition_from_IPv4 "http://en.wikipedia.org/wiki/IPv6_address#Transition_from_IPv4")” so the “Allowed Clients” conaints both “127.0.0.1” and “::ffff:0:0/96” . Find at **Services → Tinyproxy → Configuration → Filtering and ACLs**.

Some help with tinyproxy logging and log analysis here: [http://www.farville.com/?p=314](http://www.farville.com/?p=314 "http://www.farville.com/?p=314")
