# OpenWrt security hardening

Good news, OpenWrt is secure on the WAN/Internet side by default, such that no unsolicited traffic is allowed in by the [firewall](/docs/guide-user/firewall/overview "docs:guide-user:firewall:overview"). If you are inexperienced in Linux hardening, firewalls, and web security, there is little need to worry, inexperienced muggles may begin using it right away.

This page contains some best practices for security with OpenWrt and what you should do to keep your router in a properly secured state.

## Setting the root password

First thing you should do is set your root password. Using LuCI:

1. Navigate to LuCI → System → Administration page
2. Enter the new password in the Router Password section
3. Click **Save &amp; Apply**

You can also set the root password using SSH/command-line with `passwd`.

## A word about high-value weak points on OpenWrt

The OpenWrt firewall will drop packets on the WAN by default, however the LAN side has several common services running, which can mark high-value targets for malware. While uncommon, any harmless looking web site you visit could use cross site request forgery tricks, abusing an unpatched security flaw in one of these services. This could lead to malicious redirect attacks where a [website redirects to a malware site](https://attack.mitre.org/techniques/T1189/ "https://attack.mitre.org/techniques/T1189/") and so on. Below is a simple list of best practices for security.

Common high-value services in particular are:

- The webserver for LuCI web interface monitoring and configuration
- The Dropbear SSH server for command-line access
- WiFi access points that are unsecured can be used to gain access to your network
- Samba/Ksmbd share to provide user network file shares (only if manually activated, it's not there by default)
- The SFTP daemon for GUI file explorer admin access (only if manually activated, it's not there by default)

It is your responsibility to counter potential weak points on your OpenWrt device(s):

- Set a root password, `passwd` from command-line
- Keep your firmware up to date, read more about this in the section down below
- For WiFi enable the latest security features in LuCI: Network → Wireless → SSIDs, enable WPA2 and KRACK mitigation, or better yet WPA3 if your hardware supports it
- If you installed Samba/Ksmbd or SFTP packages: set a user password for access, and check regularly if there are package updates available and apply them

## Setting HTTPS for LuCI

It is good practice to [activate HTTPS](/docs/guide-user/luci/luci.essentials#providing_encryption "docs:guide-user:luci:luci.essentials") encryption for your LuCI web interface. Install the package `luci-ssl` and tell the web server to redirect to HTTPS with the command-line:

```
uci set uhttpd.main.redirect_https=1
uci commit uhttpd && service uhttpd reload
```

Now when connecting to the LuCI web UI it will use HTTPS.

If you don't wish to use LuCI web interface at all, you can [disable the webserver](/docs/guide-user/luci/luci.secure#more_secure_configuration "docs:guide-user:luci:luci.secure") entirely.

## Securing TTY and serial console

Enable password prompt for TTY and serial console.

```
uci set system.@system[0].ttylogin="1"
uci commit system
service system restart
```

Authentication for OpenWrt TTY and serial console is disabled by default. Using TTY and serial console requires physical access to the device. You can reduce the attack surface by enabling authentication.

Note that hardware attacks on serial console pins are also possible. However, it requires physical access, time and skill.

## My OpenWrt web interface page is always open in the background for ease of access...

...and that is a bad idea. Treat your root account with respect.

Do what every major company does with the root accounts of their Linux servers:

- Stay away from admin access (SSH and web interface) when you don't need it
- Log off your root admin sessions once your are done administrating
- Only connect as root when really in the need for administration
- Never share your root password with others

## Let's just open this one port for incoming traffic, what could possibly go wrong?...

Handle adding firewall rules with care:

- Do not expose services on the WAN port if you do not understand the security implications. Automatic scanners and script kids will find any open port on your WAN side and could then run extensive intrusion software suits on such open ports, probing a lot of attack vectors without any manual effort. The Internet is always being scanned for careless people.
- If you want to access home services while being on the road, consider using a WireGuard VPN instead of opening service-related ports publicly on the WAN side.
- A lot of online games have “recommended settings” to permanently open port ranges for the best gaming experience. Before blindly following these settings, check first, if any server connection problems are due to a [double NAT from cascaded routers](/docs/guide-user/network/switch_router_gateway_and_nat "docs:guide-user:network:switch_router_gateway_and_nat") at your home.
- Always use reasonable comments, when you add your own custom firewall rules (e.g. “...that's the rule that a random nice guy on the Internet asked me to add, promising me some really hot skateboarding penguin pictures in return...”)

If you have already performed various firewall rule changes and are now concerned about your custom rules, you can always reset all your OpenWrt settings back to the to the initial default with the `firstboot && reboot` command.

## So I've switched from insecure vendor firmware to OpenWrt. Finally, I am safe...

Initially yes, but not so fast... Did you notice that even OpenWrt firmware gets updated periodically?

As with your former vendor/OEM firmware, you should check regularly if OpenWrt has a new firmware release and apply this to your device. The good news with OpenWrt is that popular devices are often updated for many, many years. There is even a configuration backup and restore feature so you do not have to start from scratch after each update. Update your firmware via:

- For manually installing updates, download the latest sysupgrade builds from [Firmware Selector](https://firmware-selector.openwrt.org/ "https://firmware-selector.openwrt.org/")
- For an assisted process from SSH/command-line, install and use `owut`
- For an assisted process from LuCI webUI, install and use `luci-app-attendedsysupgrade`

## Dive into the deep end with SELinux

OpenWrt supports Security-Enhanced Linux (SELinux) [selinux\_policy\_development](/docs/guide-developer/selinux_policy_development "docs:guide-developer:selinux_policy_development"). This is a Linux security module that provides support for access control policies including mandatory access controls (MAC) and could be useful for advanced users with complex network setups.

## I have extra packages installed...

![:!:](/lib/images/smileys/exclaim.svg) This section is only recommended if you know there is a fix you need, otherwise do not use this as this could potentially break some functionality, wait for a firmware update to update packages.

As with the firmware you may also keep an eye on extra packages you installed.

If you are using custom packages, you can run a `opkg update; opkg list-upgradable` from time to time. This shows your installed packages that have available updates. You then install package upgrades manually by running `opkg upgrade <package>`. Not every listed package upgrade is due to security issues, it can also be a harmless bug fix or feature extension. Note that soon `opkg` packaging system will be replaced with `apk`.

An update will continue to use your existing configuration, but for critical OpenWrt environments, a manual config backup never hurts as precaution before upgrading packages. By default OpenWrt uses squashfs, a read-only root filesystem, plus a differential extension partition for all package installs and upgrades. When wanting to maximize usage of your precious flash space, it tends to be a better approach to applying firmware updates and then reinstalling your packages, instead of only upgrading packages.
