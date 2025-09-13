# Secure access to your router

See also: [Elevating privileges with sudo](/docs/guide-user/security/sudo#goals "docs:guide-user:security:sudo")

There are some possibilities to grant access to the router (or to any PC/Server):

1. ask for nothing: anybody who can establish a connection gets access
2. ask for username and password on an unsecured connection (e.g. telnet)
3. ask for username and password on an encrypted connection (e.g. SSH) (e.g. by following [walkthrough\_login](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login"))
4. ask for username and merely a **`signature`** instead of a **`password`** (e.g. SSH with [dropbear.public-key.auth](/docs/guide-user/security/dropbear.public-key.auth "docs:guide-user:security:dropbear.public-key.auth"))

If you ask for username/password, an attacker has to guess the combination. If you use an unencrypted connection, they could eavesdrop on you and obtain your credentials.

If you use an encrypted connection, any eavesdropper would have to decrypt the packets first. This is always possible. How long it takes to decrypt the content, depends on the algorithm and key length you used.

Also, as long as an attacker has network access to the console, they can always run a brute-force attack to find out your username and password. They does not have to do that themself: they can let their computer(s) do the guessing. To render this option improbable or even impossible you can:

1. not offer access from the Internet at all, or restrict it to certain IP addresses or IP address ranges
   
   1. by letting the SSH server [Dropbear](/docs/guide-user/base-system/dropbear "docs:guide-user:base-system:dropbear") and the web server [uHTTPd](/docs/guide-user/services/webserver/uhttpd "docs:guide-user:services:webserver:uhttpd") not listen on the external/WAN port
   2. by blocking incoming connections to those ports (TCP 22, 80 and 443 by default) in your firewall
2. make it more difficult to guess:
   
   1. don't use the username `root`
   2. don't use a weak password with 8 or less characters
   3. don't let the SSH server Dropbear listen on the default port (22)
3. use the combination of
   
   1. set up [Dropbear key-based authentication](/docs/guide-user/security/dropbear.public-key.auth "docs:guide-user:security:dropbear.public-key.auth")
   2. username different than `root`
   3. tell Dropbear to listen on a random port (should be &gt;1024): System → Administration → Dropbear Instance → Port[![SSH Port](/_media/media/doc/howtos/secure-access-02-ssh-port.png "SSH Port")](/_detail/media/doc/howtos/secure-access-02-ssh-port.png?id=docs%3Aguide-user%3Asecurity%3Asecure.access "media:doc:howtos:secure-access-02-ssh-port.png")

## System hardening

If you have an external disk you may want to [encrypt it](/docs/guide-user/storage/disk.encryption "docs:guide-user:storage:disk.encryption").

## Network hardening

1. [Fwknop](https://www.cipherdyne.org/fwknop/ "https://www.cipherdyne.org/fwknop/") (FireWall KNock OPerator) implements an authorization scheme called [Single Packet Authorization](https://en.wikipedia.org/wiki/Single%20Packet%20Authorization "https://en.wikipedia.org/wiki/Single Packet Authorization") (SPA) alongwith [setting up two factor authentication](https://secure.wphackedhelp.com/blog/wordpress-two-factor-authentication/ "https://secure.wphackedhelp.com/blog/wordpress-two-factor-authentication/"). This method of authorization is based around a default-drop packet filter and libpcap. SPA is essentially next generation port knocking. For example: it can open the port for SSH on WAN, but just for a short period of time, until you can establish a new connection through that port.
   
   - See detailed instructions at: [Fwknop](/docs/guide-user/services/fwknop "docs:guide-user:services:fwknop")
2. [Ostiary](http://ingles.homeunix.net/software/ost/index.html "http://ingles.homeunix.net/software/ost/index.html"), like port knocking, adds an additional layer of security. It can be used to simply initiate a script or task remotely (without needing SSH access). See detailed instructions for configuring Server or Client by going to the corresponding links below.
   
   - [Ostiary Server](/docs/guide-user/services/remote_control/ostiary.server "docs:guide-user:services:remote_control:ostiary.server")
   - [Ostiary Client](/docs/guide-user/services/remote_control/ostiary.client "docs:guide-user:services:remote_control:ostiary.client")
3. To protect open ports against brute force attack, the attacker ip address can be banned via iptables configuration:
   
   - [forum thread 7493](https://forum.openwrt.org/viewtopic.php?id=7493 "https://forum.openwrt.org/viewtopic.php?id=7493")
   - [forum thread 27103](https://forum.openwrt.org/viewtopic.php?id=27103 "https://forum.openwrt.org/viewtopic.php?id=27103")
4. Dependent on you situation you may want to employ an [Intrusion prevention system](https://en.wikipedia.org/wiki/Intrusion%20prevention%20system "https://en.wikipedia.org/wiki/Intrusion prevention system") like [fail2ban](https://en.wikipedia.org/wiki/fail2ban "https://en.wikipedia.org/wiki/fail2ban") or better yet implement your own one based on `logtrigger`.

## Protecting web interface

For secure web access, OpenWrt can be accessed via HTTPS (TLS) instead of the unencrypted HTTP protocol. If HTTP is not secure enough for you, you can disable the existing (unencrypted) web access and either

- [Tunnel your connection via SSH](/docs/guide-user/luci/luci.secure "docs:guide-user:luci:luci.secure")
- Follow [Providing encryption](/docs/guide-user/luci/luci.essentials#providing_encryption "docs:guide-user:luci:luci.essentials") to set up SSL protected access
  
  1. While luci-ssl automatically installs px5g that can be utilized, you can also use openssl to generate your own certificate authority and certs, then use that certificate authority to sign the certificate you use for uhttpd. Certificates can also be named or placed in whatever directory you wish by editing **/etc/config/uhttpd**
  2. Optionally instruct the server to not listen on plain HTTP anymore:
     
     ```
     uci -q delete uhttpd.main.listen_http
     uci commit uhttpd
     /etc/init.d/uhttpd restart
     ```
     
     **OR** Rebind to LAN only and redirect all http requests to https:
     
     ```
     uci set uhttpd.main.listen_http="192.168.1.1:80"
     uci set uhttpd.main.listen_https="192.168.1.1:443"
     uci set uhttpd.main.redirect_https="1"
     uci commit
     /etc/init.d/uhttpd restart
     ```

Can mandatory client certificate checking be set up with uhttpd? → [not possible with uhttpd](http://lists.infradead.org/pipermail/lede-dev/2017-August/008692.html "http://lists.infradead.org/pipermail/lede-dev/2017-August/008692.html")

If you require remote SSH access, follow the hardening instructions on SSH mentioned above.

## Protecting PPP credentials

When using PPP, protect its credentials from unprivileged users.

```
PPP_IF="wan"
PPP_USER="$(uci -q get network.${PPP_IF}.username)"
PPP_PASS="$(uci -q get network.${PPP_IF}.password)"
cat << EOF >> /etc/ppp/options
user ${PPP_USER}
EOF
cat << EOF >> /etc/ppp/chap-secrets
${PPP_USER} * ${PPP_PASS}
EOF
ln -f /etc/ppp/chap-secrets /etc/ppp/pap-secrets
chmod go= /etc/ppp/chap-secrets
uci -q delete network.${PPP_IF}.username
uci -q delete network.${PPP_IF}.password
uci commit network
/etc/init.d/network restart
```
