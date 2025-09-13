# Nodogsplash (Outdated document)

**!!!Warning!!!** This document is VERY outdated and in some instances misleading due to its outdated nature. Please go to:

[OpenNDS](/docs/guide-user/services/captive-portal/opennds "docs:guide-user:services:captive-portal:opennds")

`Nodogsplash` offers a simple way to open a free [Hotspot (Wi-Fi)](https://en.wikipedia.org/wiki/Hotspot%20%28Wi-Fi%29 "https://en.wikipedia.org/wiki/Hotspot (Wi-Fi)") providing restricted access to an Internet connection.  
The goal was to use a single wireless router to both provide local secure wifi, and share a portion of our bandwidth as a free hotspot, with a splash page to advertise who is providing the hotspot, and the fact that secure, faster access is available for a small contribution towards costs.

This page describes setting up a simple wireless hotspot with the following features:

- Open access to the hotspot
- Capture (splash) page
- Port restrictions
- Bandwidth Limit
- Separate, secure wireless access for local use

The secure wireless is bridged to the hard-wired ports, the hotspot is separate and isolated from the local network.

Official documentation: [https://nodogsplashdocs.readthedocs.io/en/stable/](https://nodogsplashdocs.readthedocs.io/en/stable/ "https://nodogsplashdocs.readthedocs.io/en/stable/")

## Overview

The nodogsplash captive portal runs as a service that manages client traffic over a router by adjusting firewall rules based on client tracking tools that interact with a users browser and client network requests.

In order to fully setup user and password authentication or more complex configuration. You will need to read the linked documentation to gain better understanding of the layers that are involved.

Usually this will require some basic script/web source editing and web server setup and modification. On Openwrt if user credentials are to be local to the router this will also need to be considered.

## Installation

[opkg](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg")

```
opkg update
opkg install nodogsplash
```

In **/etc/config/nodogsplash** ensure option enabled is 1

```
  option enabled 1
```

Enable and start the nodogsplash ( NDS ) service.

```
/etc/init.d/nodogsplash enable
/etc/init.d/nodogsplash start
```

Some useful commands are listed below.

```
/usr/bin/ndsctl status                 ( check if nodogsplash is up )
/usr/bin/ndsctl clients                ( list connected clients and status )
/usr/bin/ndsctl deauth 192.168.1.10    ( useful for testing )
```

See [https://github.com/nodogsplash/nodogsplash#7-debugging-nodogsplash](https://github.com/nodogsplash/nodogsplash#7-debugging-nodogsplash "https://github.com/nodogsplash/nodogsplash#7-debugging-nodogsplash") about how to debug start-up issues.

Documentation can be found online [here](https://nodogsplash.readthedocs.io/en/latest/ "https://nodogsplash.readthedocs.io/en/latest/").

## Configuration

### Nodogsplash Configuration File

Older versions use `/etc/nodogsplash/nodogsplash.conf`, while versions starting at 0.9\_beta9.9.9-5 in Chaos Calmer 15.05 use UCI with `/etc/config/nodogsplash`.

The “/etc/config/nodogsplash” config file can be seen [here](https://github.com/openwrt-routing/packages/blob/master/nodogsplash/files/nodogsplash.config "https://github.com/openwrt-routing/packages/blob/master/nodogsplash/files/nodogsplash.config") or [here](https://raw.githubusercontent.com/nodogsplash/nodogsplash/master/openwrt/nodogsplash/files/etc/config/nodogsplash "https://raw.githubusercontent.com/nodogsplash/nodogsplash/master/openwrt/nodogsplash/files/etc/config/nodogsplash"), and is documented below.

Below is a documented version of the “/etc/config/nodogsplash” file. This UCI file is automatically turned into a temporary config file with the old format when nodogsplash starts. That file can be viewed in /tmp/etc/.

```
config nodogsplash
  # Set to 1 to enable nodogsplash
  option enabled 0

  # Use plain configuration file
  #option config '/etc/nodogsplash/nodogsplash.conf'

  # The network the users are connected to - if you connect to 'br-lan', enter 'lan' here.
  option network 'lan'
  
  # Set GatewayName to the name of your gateway. This value
  # will be available as variable $gatewayname in the splash page source
  # and in status output from ndsctl, but otherwise doesn't matter.
  # If none is supplied, the value "NoDogSplash" is used.
  option gatewayname 'OpenWrt Nodogsplash'
  
  # Set MaxClients to the maximum number of users allowed to
  # connect at any time. (Does not include users on the TrustedMACList,
  # who do not authenticate.)
  option maxclients '250'
  
  # Set ClientIdleTimeout to the desired of number of minutes
  # of inactivity before a user is automatically 'deauthenticated'.
  option clientidletimeout '1200'
  
  # Set ClientForceTimeout to the desired number of minutes before
  # a user is automatically 'deauthenticated', whether active or not
  # option clientforcetimeout '1200'

  ###########################
  # ## authenticated_users ##
  ###########################
  # Control access for users after authentication.
  # These rules are inserted at the beginning of the
  # FORWARD chain of the router's filter table, and
  # apply to packets that have come in to the router
  # over the GatewayInterface from MAC addresses that
  # have authenticated with Nodogsplash, and that are
  # destined to be routed through the router. The rules are
  # considered in order, and the first rule that matches
  # a packet applies to it.
  # If there are any rules in this ruleset, an authenticated
  # packet that does not match any rule is rejected.
  # N.B.: This ruleset is completely independent of
  # the preauthenticated-users ruleset.
  
  # You may want to open access to a machine on a local
  # subnet that is otherwise blocked (for example, to
  # serve a redirect page; see RedirectURL). If so,
  # allow that explicitly, e.g:
  # list authenticated_users 'allow tcp port 80 to 192.168.254.254'

  # Your router may have several interfaces, and you
  # probably want to keep them private from the network/gatewayinterface.
  # If so, you should block the entire subnets on those interfaces, e.g.:
  list authenticated_users 'block to 192.168.0.0/16'
  list authenticated_users 'block to 10.0.0.0/8'

  # Typical ports you will probably want to open up.
  list authenticated_users 'allow tcp port 22'
  list authenticated_users 'allow tcp port 53'
  list authenticated_users 'allow udp port 53'
  list authenticated_users 'allow tcp port 80'
  list authenticated_users 'allow tcp port 443'

  ##############################
  # ## preauthenticated_users ##
  ##############################
  # Control access for users before authentication.
  # These rules are inserted in the PREROUTING chain
  # of the router's nat table, and in the
  # FORWARD chain of the router's filter table.
  # These rules apply to packets that have come in to the
  # router over the GatewayInterface from MAC addresses that
  # are not on the BlockedMACList or TrustedMACList,
  # are *not* authenticated with Nodogsplash. The rules are
  # considered in order, and the first rule that matches
  # a packet applies to it. A packet that does not match
  # any rule here is rejected.
  # N.B.: This ruleset is completely independent of
  # the authenticated-users and users-to-router rulesets.
 
  # For splash page content not hosted on the router, you
  # will want to allow port 80 tcp to the remote host here.
  # Doing so circumvents the usual capture and redirect of
  # any port 80 request to this remote host.
  # Note that the remote host's numerical IP address must be known
  # and used here.
  # list preauthenticated_users 'allow tcp port 80 to 123.321.123.321'
 
  # For preauthenticated users to resolve IP addresses in their
  # initial request not using the router itself as a DNS server,
  list preauthenticated_users 'allow tcp port 53'
  list preauthenticated_users 'allow udp port 53'


  #######################
  # ## users_to_router ##
  #######################
  # Control access to the router itself from the GatewayInterface.
  # These rules are inserted at the beginning of the
  # INPUT chain of the router's filter table, and
  # apply to packets that have come in to the router
  # over the GatewayInterface from MAC addresses that
  # are not on the TrustedMACList, and are destined for
  # the router itself. The rules are considered
  # in order, and the first rule that matches a packet applies
  # to it.
  # If there are any rules in this ruleset, a
  # packet that does not match any rule is rejected.
  
  # Allow ports for SSH/Telnet/DNS/DHCP/HTTP/HTTPS
  list users_to_router 'allow tcp port 22'
  list users_to_router 'allow tcp port 23'
  list users_to_router 'allow tcp port 53'
  list users_to_router 'allow udp port 53'
  list users_to_router 'allow udp port 67'
  list users_to_router 'allow tcp port 80'
  list users_to_router 'allow tcp port 443'

  # MAC addresses that are / are not allowed to access the splash page
  # Value is either 'allow' or 'block'. The allowedmac or blockedmac list is used.
  #option macmechanism 'allow'
  #list allowedmac '00:00:C0:01:D0:0D'
  #list allowedmac '00:00:C0:01:D0:1D'
  #list blockedmac '00:00:C0:01:D0:2D'

  #MAC addresses that do not need to authenticate
  #list trustedmac '00:00:C0:01:D0:1D'

  # EmptyRuleSetPolicy directives
  # The FirewallRuleSets that NoDogSplash permits are:
  #
  # authenticated-users
  # preauthenticated-users
  # users-to-router
  # trusted-users
  # trusted-users-to-router
  #
  # For each of these, an EmptyRuleSetPolicy can be specified.
  # An EmptyRuleSet policy applies to a FirewallRuleSet if the
  # FirewallRuleSet is missing from this configuration file,
  # or if it exists but contains no FirewallRules.
  #
  # The possible values of an EmptyRuleSetPolicy are:
  # allow -- packets are accepted
  # block -- packets are rejected
  # passthrough -- packets are passed through to pre-existing firewall rules
  #
  # Default EmptyRuleSetPolicies are set as follows:
  # EmptyRuleSetPolicy authenticated-users passthrough
  # EmptyRuleSetPolicy preauthenticated-users block
  # EmptyRuleSetPolicy users-to-router block
  # EmptyRuleSetPolicy trusted-users allow
  # EmptyRuleSetPolicy trusted-users-to-router allow

  # This should be autodetected on an OpenWRT system, but if not:
  # Set GatewayAddress to the IP address of the router on
  # the GatewayInterface. This is the address that the Nodogsplash
  # server listens on.
  # option gatewayaddress '192.168.1.1'

  # This should be autodetected from /proc/net/route on a OpenWRT system, but if
  # not: set ExtrnalInterface to the 'external' interface on your router,
  # i.e. the one which provides the default route to the internet.
  # Typically vlan1 for OpenWRT.
  # option externalinterface 'vlan1'


  # After authentication, normally a user is redirected
  # to their initially requested page.
  # If RedirectURL is set, the user is redirected to this URL instead.
  # option redirecturl 'http://www.ilesansfil.org/'

  # Nodogsplash's own http server uses GatewayAddress as its IP address.
  # The port it listens to at that IP can be set here; default is 2050.
  # option gatewayport '2050'


  # Set to yes (or true or 1), to immediately authenticate users
  # who make a http port 80 request on the GatewayInterface (that is,
  # do not serve a splash page, just redirect to the user's request,
  # or to RedirectURL if set).
  # option authenticateimmediately 'no'

  # Either block or allow.
  # If 'block', MAC addresses on BlockedMACList are blocked from
  # authenticating, and all others are allowed.
  # If 'allow', MAC addresses on AllowedMACList are allowed to
  # authenticate, and all other (non-trusted) MAC's are blocked.
  # option macmechanism 'block'

  # Set to yes (or true or 1), to require a password matching
  # the Password parameter to be supplied when authenticating.
  # option passwordauthentication 'no'

  # Whitespace delimited string that is compared to user-supplied
  # password when authenticating.
  # option password 'nodog'

  # Set to yes (or true or 1), to require a username matching
  # the Username parameter to be supplied when authenticating.
  # option usernameauthentication 'no'

  # Whitespace delimited string that is compared to user-supplied
  # username when authenticating.
  # option username 'guest'

  # Integer number of failed password/username entries before
  # a user is forced to reauthenticate.
  # option passwordattempts '5'

  # By setting this parameter, you can specify a range of IP addresses
  # on the GatewayInterface that will be responded to and managed by
  # Nodogsplash. Addresses outside this range do not have their packets
  # touched by Nodogsplash at all.
  # Defaults to 0.0.0.0/0, that is, all addresses.
  # option gatewayiprange '0.0.0.0/0'
```

Allow access to email:

```
  list authenticated_users 'allow tcp port 995'
  list authenticated_users 'allow tcp port 993'
  list authenticated_users 'allow tcp port 465'
  list authenticated_users 'allow tcp port 110'
  list authenticated_users 'allow tcp port 143'
```

Restrict access to the gateway from the hotspot side:

```
  list users_to_router 'allow tcp port 22'
  list users_to_router 'allow tcp port 80'
  list users_to_router 'allow tcp port 443'
```

### mwan3 Compatibility

NDS and mwan3 both mess with iptables. As such they need a little extra configuration sometimes to work together.

**NDS 0.9**

Add the following lines to /etc/nodogsplash/nodogsplash.conf:

```
FW_MARK_AUTHENTICATED 262144
FW_MARK_TRUSTED 131072
FW_MARK_BLOCKED 65536
```

**NDS 1.0**

Make the following changes per [this](https://github.com/nodogsplash/nodogsplash/issues/218 "https://github.com/nodogsplash/nodogsplash/issues/218") issue.

In /etc/config/nodogsplash:

```
list fw_mark_authenticated '30000'
list fw_mark_trusted '20000'
list fw_mark_blocked '10000'
```

In /etc/config/mwan3:

```
config globals 'globals'
```

**NDS 2.0** *(compatible by default)*

### Check status

Nodogsplash package provides the `ndsctl` binary to manage it. Run ndsctl without arguments to see the help.

```
root@openWrt:~# ndsctl       
Usage: ndsctl [options] command [arguments]

options:
  -s <path>           Path to the socket
  -h                  Print usage

commands:
  status              View the status of nodogsplash
  clients             Display machine-readable client list
  json             	  Display machine-readable client list in json format
  stop                Stop the running nodogsplash
  auth mac|ip|token   Authenticate user with specified mac, ip or token
  deauth mac|ip|token Deauthenticate user with specified mac, ip or token
  block mac           Block the given MAC address
  unblock mac         Unblock the given MAC address
  allow mac           Allow the given MAC address
  unallow mac         Unallow the given MAC address
  trust mac           Trust the given MAC address
  untrust mac         Untrust the given MAC address
  loglevel n          Set logging level to n
  password pass       Set gateway password
  username name       Set gateway username
```

## Customise splash page

Edit these files to customize the “splash page” / “error page”:

- `/etc/nodogsplash/htdocs/splash.html`
- `/etc/nodogsplash/htdocs/infoskel.html`

Note, to include an external `*.css` file, put it in the images directory, and include as so:

```
@import url("$imagesdir/stylesheet.css");
```

Somewhere in `splash.html` you should include a link for the authentication, e.g:

```
<h3> Click <a href="$authtarget"> HERE</a> to start browsing </h3>
```

## Restrict access to domains

If you would want to restrict the access to the IP address 20.20.20.20 you can use this [netfilter](/docs/guide-user/firewall/netfilter-iptables/netfilter "docs:guide-user:firewall:netfilter-iptables:netfilter") command (supposing 10.20.30.0/24 is your hotspot network and you redirect clients to your nodogsplash webserver)

```
  iptables -t nat -I ndsOUT -p tcp -s 10.20.30.0/24 -d 20.20.20.20 --dport 80 -j DNAT --to 10.20.30.1:2050
```

### Restrict access to multiple domains

Some domains resolve to multiple different ip addresses so you need to ban all of them.

1. Create `/root/banned.txt` with the domains to ban (do not add domains with www):
   
   ```
   root@openWrt:~# head /root/banned.txt 
   alice.cc
   malware.ru
   sersnkis.com
   superdupertorrent.com
   ultraload.com
   downloadmuch.com
   ```
2. Create following script `/root/ban-domains.sh`:
   
   ```
   #!/bin/sh
    
   for domain in `cat /root/banned.txt`; do
   	dig @8.8.8.8 $domain | egrep [0-9] | grep IN| awk {'print $5'} >> /tmp/ips.txt
   	done
    
   for ip in `cat /tmp/ips.txt`; do
   	iptables -t nat -I ndsOUT -p tcp -s 10.20.30.0/24 -d $ip --dport 80 -j DNAT --to 10.20.30.1:80
   	done
    
   rm -fr /tmp/ips.txt
   ```
3. run
   
   ```
   chmod +x /root/ban-domains.sh"
   ```
4. install dig package:
   
   ```
   opkg install bind-dig
   ```
5. add `/root/ban-domains.sh` to your `/etc/rc.local` file.

after executing the script you can check if it works ok running “iptables -t nat -L -n” and you should get something like this:

```
Chain ndsOUT (1 references)
target     prot opt source               destination         
DNAT       tcp  --  10.20.30.0/24        199.58.211.41       tcp dpt:80 to:10.20.30.1:80 
DNAT       tcp  --  10.20.30.0/24        69.163.39.214       tcp dpt:80 to:10.20.30.1:80 
DNAT       tcp  --  10.20.30.0/24        78.140.135.6        tcp dpt:80 to:10.20.30.1:80 
DNAT       tcp  --  10.20.30.0/24        74.117.114.96       tcp dpt:80 to:10.20.30.1:80 
DNAT       tcp  --  10.20.30.0/24        88.85.73.158        tcp dpt:80 to:10.20.30.1:80 
DNAT       tcp  --  10.20.30.0/24        216.69.227.108      tcp dpt:80 to:10.20.30.1:80 
DNAT       tcp  --  10.20.30.0/24        72.8.129.153        tcp dpt:80 to:10.20.30.1:80 
```

### Restrict access to DNS VPNs

The default config opens TCP and UDP port 53 without redirecting it to a DNS server, and this could be exploited with iodine or any VPN software by using those ports. Limit it by changing:

```
  #list preauthenticated_users 'allow tcp port 53'
  list preauthenticated_users 'allow udp port 53 to 208.67.222.222'
  list preauthenticated_users 'allow udp port 53 to 208.67.220.220'
```

In your /etc/config/nodogsplash file, and change the DNS for ones you use.

## External links

- [Original Nodogsplash project homepage](http://kokoro.ucsd.edu/nodogsplash/ "http://kokoro.ucsd.edu/nodogsplash/")
- [Current Nodogsplash source repository](https://github.com/nodogsplash/nodogsplash "https://github.com/nodogsplash/nodogsplash")
- [Nodogsplash OpenWrt package](https://github.com/openwrt-routing/packages "https://github.com/openwrt-routing/packages")

# Misc.

If your configuration does NOT use NAT, you need to check “force connection tracking” in the firewall configuration of the zone nodogsplash is handling. Without connection tracking, the NAT tables of will not run and redirecting to the splash page does not work.

## NoDogSplash on OpenWRT 12.09+ Access Point

The following instructions are touching NoDogSplash configuration on the OpenWRT 12.09 and later firmwares with “router” configured as a **switch** or **Access Point** (AP). OpenWrt is not configured as a router here! This is a common setup where users want to add additional AP to extend their home WiFi coverage and do not want to mess with router from their Internet providers. Example setup:

- Non OpenWRT router for intranet with address 192.168.1.1
- OpenWRT AP with static address 192.168.1.3
- Clients get DHCP subnet range 192.168.1.200-250 by router
- Clients can connect to AP WiFi within secure SSID
- Guest hotspot SSID are getting their own 192.168.15.0/24 subnet and DHCP on isolated segment

Configuration of the AP is as usual except that AP needs to have NAT for the hotspot segment only. To achieve this one needs to add custom iptables rule

```
iptables -A POSTROUTING -t nat -j SNAT --to-source 192.168.1.3
```

and delete all provided firewall rules fy using OpenWRT web interface.

Detailed configuration for AP only OpenWRT is:

1. Install package *nodogsplash*
2. With web interface *Network→WiFi* create: additional ESSID named hotstpot and create additional network hotstpot along with existing lan and unused wan.
3. Edit *Network→Interfaces→HOTSPOT* and select Protocol: Static address with IPv4 address 192.168.5.1 and Netmask: 255.255.255.0. Leave gateway, broadcast and DNS servers empty. Add DHCP server for this interface with default settings. This HOTSPOT interface is internally named as wlan0-1 and will be used as NoDogSplash gateway address.
4. Edit *Network→DHCP and DNS*-Forwarder by unchecking Authoritative and add DNS forwardings: 192.168.1.1 to router DNS masquerading and/or external DNS servers from your internet provider.
5. Remove all *Network→Firewall Zones* and add *Network→Firewall→Custom Rules* by adding iptables rule described above.
6. Change `/etc/nodogsplash/nodogsplash.conf` affected lines to

```
        GatewayInterface wlan0-1
        ExternalInterface br-lan
```

FirewallRuleSet authenticated-users can remain unchanged. You can also start iptables SNAT command manually if not rebooted meanwhile. Check the presence of this rule by `iptables -t nat -v -n -L`. Enable and start NoDogSplash. After above setup everything should work. Trafic shapping due to the lack of IMQ currently does not work on OpenWrt 12.09 (Attitude Adjustment). One possibility is to install qos-scripts and luci-app-qos. Adding additional interface HOTSPOT to QOS configuration cannot separate between WAN and HOTSPOT bandwidth limit. One can choose to limit NoDogSplash and secure WiFi together to certain Upload and Download rate, but not separate!

**Added by NetoMX (2016/03/30): In my case, I needed to add in the default firewall rules, FORWARD→ACCEPT to make this work. I didn't make point 4 and it still works. For bandwitdh limit, use WShaper. ==== Legacy NDS - Bandwidth Control ==== In backfire 10.03.1rc5, you need to edit /etc/init.d/nodogsplash and uncomment last lines to make bandwidth control to work**

```
    # if not using traffic control,
    # you can comment out the following 3 lines:
    do_module_tests "imq" "numdevs=2"
    do_module_tests "ipt_IMQ"
    do_module_tests "sch_htb"
```

Note: *ipt\_IMQ = xt\_IMQ*

**You also need to install some extra kernel modules:**

```
    opkg install iptables-mod-imq
    opkg install kmod-ipt-imq
    opkg install kmod-sched
```

And some utilities

```
    opkg install ip
    opkg install tc
```

NOTE: In Attitude Adjustment 12.09 there is no `iptables-mod-imq` package and so traffic control no longer works.

For bandwidth control in **Attitude Adjustment 12.09** you can install [WonderShaper](http://lartc.org/wondershaper/ "http://lartc.org/wondershaper/") (which also uses [tc](/docs/guide-user/network/traffic-shaping/packet.scheduler "docs:guide-user:network:traffic-shaping:packet.scheduler") as its back-end):

```
    opkg install wshaper
```

WonderShaper's UCI config file is stored in `/etc/config/wshaper`. A simple configuration for a guest network might look like this:

```
config wshaper 'settings'
	option network 'public'
	option downlink '64'
	option uplink '512'
```

**Note:** The `downlink` and `uplink` maximum values will usually need to be reversed from what one might, at first glance, expect. Also note that due to overhead, actual speeds will be slightly lower.
