# CoovaChilli captive portal

Originally the common opensource captive hotspot was [ChilliSpot](http://www.chillispot.org/ "http://www.chillispot.org/"), but it has long since fallen into disrepair. So much that the [CoovaChilli](https://coova.github.io/ "https://coova.github.io/") fork has completely taken over its role. So much in fact that if you see any reference to 'chilli' on the internet, as in 'we support or require chilli' you can safely assume they mean 'coovachilli'. And in fact, CoovaChilli's main executable binary is 'chilli' and its configuration is in '/etc/chilli'. So it is pretty much a drop-in replacement of ChilliSpot.

CoovaChilli has been available as package on OpenWrt for several years now and if you manually created a `init.d` startup script and edited the defaults configuration file it worked quite well since at least Backfire 10.03

But since 15.05 Chaos Calmer it has been better integrated. Not only is there now a startup script, said startup script parses OpenWrt style configuration in the `/etc/config/chilli` file. So it is integrated much tighter into OpenWrt. Many thanks to the anonymous (to me) developer. But without documentation it took me quite a while to figure out the new configuration options, so I am writing this document to help others.

You see, the new style script &amp; configuration is not compatible with the old one. The old 'manual' method uses `chilli_opt` to parse `/etc/chilli/default` file into options, the new method parses `/etc/config/chilli` file into options. And the options in those are quite different. Also the new method *seems* to map 1:1 to actual binary options, but there are a two tricky differences.

If you want to use coova using the old style, simply delete and replace the Chaos Calmer delivered `/etc/init.d/chilli` script, and edit `/etc/chilli/default` like before.

If you want to use coova using the new integrated style, ignore `/etc/chilli/default`, do not modify or replace Chaos Calmer delivered `/etc/init.d/chilli` script, and only edit `/etc/config/chilli`

## CoovaChilli is \*not* a full Hotspot solution

Chilli is only the working network portion of a full HotSpot. It is the captive portal portion of it. It deals with intercepting new clients, provisioning IP addresses (DHCP), providing WISPr, enforcing bandwidth and usage limits. But it does not deal with authentication or payments.

For the latter, you typically also need a Radius server and some database, as well as some commercial application and presentation layer to offer vouchers and pricing and payment, or just free access with a 'accept conditions' button.

When you opt for a OpenWrt based solution, we assume you will run this authentication backend on a different server, and the OpenWrt device is only handling the network portion. If so, Chilli needs to be configured to connect to the backend server, a self-build one, or a professional 3rd party service provider.

There may be a 'mac-address-only' authentication with CoovaChilli, so it may be possible to forgo Radius and have a splash page only solution, but this wikipage does not discuss that option, if the option is indeed possible.

I use [HotSpotSystem](http://www.hotspotsystem.com/ "http://www.hotspotsystem.com/") myself, so some of below examples hold their server names and the examples may be biased toward their needs. Another such provider is [Sputnik](http://www.sputnik.com/ "http://www.sputnik.com/"); [WifiDog](http://dev.wifidog.org/ "http://dev.wifidog.org/"); [WorldSpot](http://worldspot.net/ "http://worldspot.net/") but there may be many more.

For a simple, non-commercial, single device solution with a welcome splash page, consider [Nodogsplash](/docs/guide-user/services/captive-portal/wireless.hotspot.nodogsplash "docs:guide-user:services:captive-portal:wireless.hotspot.nodogsplash") or [OpenNDS](/docs/guide-user/services/captive-portal/opennds "docs:guide-user:services:captive-portal:opennds") instead.  
[WifiDog](http://dev.wifidog.org/ "http://dev.wifidog.org/") also seems to have a direct [OpenWrt package](/docs/guide-user/services/captive-portal/wireless.hotspot.wifidog "docs:guide-user:services:captive-portal:wireless.hotspot.wifidog"), but I am not sure if that needs a backend server.

## Configurable options

As a rule, all options usable on chilli binary ([man chilli.conf(5)](http://coova.github.io/CoovaChilli/chilli.conf%285%29.html "http://coova.github.io/CoovaChilli/chilli.conf(5).html")) can be used in the **`/etc/config/chilli`** file. Any option will have to be preceded by the 'option' keyword. So for example:

command line chilli -c &lt;file&gt; /etc/config/chilli old-style /etc/chilli/defaults `-radiusnasid <value>` `radiusnasid=<value>` `option radiusnasid “value”` `HS_NASID=“value”` `-radiussecret <value>` `radiussecret=<value>` `option radiussecret “value”` `HS_RADSECRET=“value”` `-uamsecret <value>` `uamsecret=<value>` `option uamsecret “value”` `HS_UAMSECRET=“value”`

The exception is when there are no-value or boolean options. For example swapoctets. Merely putting in this option without value means OpenWrt does not process it. So for these options you need to assign 1.

command line chilli -c &lt;file&gt; /etc/config/chilli `-swapoctets` `swapoctets` `option swapoctets 1` `-uamanydns` `uamanydns` `option uamanydns 1`

Another exception is the -uamallowed option (and possibly the uamdomain one). The chilli binary accepts multiple occurrences of this keyword, so you can add many host addresses gracefully. However the OpenWrt config file only accepts the keyword once. So you have to cram all hosts onto a single line, possibly extended with the “\\” line continuation symbol.

chilli -c multiline becomes 'single' line `uamallowed=“hosta,hostb”` `option uamallowed “hosta,hostb,\` `uamallowed=“hostc,hostd”` `hostc,hostd”`

I will not repeat the full list of options here. Please refer to the Coova documentation man page instead: [http://coova.github.io/CoovaChilli/chilli.conf](http://coova.github.io/CoovaChilli/chilli.conf "http://coova.github.io/CoovaChilli/chilli.conf")(5).html

## Configuration

### Get OpenWrt

Use at least version 15.05 Chaos Calmer or newer, as this is where the new elements init.d script was introduced. The web resources of OpenWrt will help you figuring out what firmware you will need for your device and how to flash it. Ensure your device is properly working as a router before you continue setting op CoovaChilli

### Install CoovaChilli

```
opkg update
opkg install coova-chilli
```

### Configure CoovaChilli

For safety, we first stop and disable chilli. This so that if you lock yourself out by a faulty config, you can always stop the captive portal by rebooting:

```
/etc/init.d/chilli stop
/etc/init.d/chilli disable
```

Next, using your favorite editor (vi, joe, nano), edit `/etc/config/chilli` file:

```
config chilli
    # option disabled 1
    
    # Your HotSpotSystem account details
    option radiusnasid 		"xxxxxxxxx"
    option radiussecret		"xxxxxxxxx"
    option uamsecret		"xxxxxxxxx"
    
    # WISPr settings
    # It is possible your provider has specific demands on these values. But for WISPr the values are
    # as shown below. (cc=2-digit ISO country; idd=phone-country;ac=phone-area-code)
    # example:			"isocc=se,cc=46,ac=584,network=CampingTiveden"
    # the <SSID> does not actually need to be the SSID, but WISPr RFC calls it SSID
    # the <sub-id> is just so you know which device on your network gave the problem. Can be Alfanumeric.
    
    option locationname 		"<human readible location name>"
    option radiuslocationname 	"<SSID>,<sub-ID>"
    option radiuslocationid 	"isocc=<cc>,cc=<idd>,ac=<ac>,network=<SSID>"
    
    # Radius parameters (change to the one for your provider)
    option radiusserver1		radius.hotspotsystem.com
    option radiusserver2		radius2.hotspotsystem.com
    
    # Your device's LAN interface on which to put the hotspot
    option dhcpif 			br-lan		# Subscriber Interface for client devices
    
    # set DNS to whatever is fastest. On slow saturated lines, best use your local router for caching.
    # on fast & wide lines, use or Google or your ISP's dns, whichever is fastest 
    option dns1			8.8.8.8
    option dns2			8.8.4.4
        
    # Tunnel and Subnet 
    option tundev 			'tun0'
    option net			192.168.180.0/22	# For 1000 addresses. Default is 182/24 subnet
    option uamlisten		192.168.182.1	# keep it at 182.1 despite the 180/22 subnet
    option lease			86400		# 1 day
    option leaseplus		600		# plus 10 minutes
    
    # Universal access method (UAM) parameters
    option uamserver		"https://customer.hotspotsystem.com/customer/hotspotlogin.php"
    option uamuiport 		4990		# HotSpot UAM "UI" Port (on subscriber network)
    option uamanydns		1
    #option	uamaliasip 		1.0.0.1		# default: http://1.0.0.1 will goto login page
    option uamaliasname 		login		#          http://login will goto login page
    #option	uamlogoutip 		1.0.0.0		# default: http://1.0.0.0 will logout
    #						# default: http://logout will logout
    option nouamsuccess		1		# no success page, to original requested URL
    
    # Hosts; services; network segments the client can access without first authenticating (walled garden)
    # Hosts are evaluated every 'interval', but this does not work well on multi-homed (multi-IP'ed) hosts, use IP instead.
    option uamallowed	"customer.hotspotsystem.com,www.directebanking.com,betalen.rabobank.nl,ideal.ing.nl,ideal.abnamro.nl,www.ing.nl"
    
    # Domain suffixes the client can access without first authenticating (walled garden)
    # Host on the domain are checked by spying on DNS requests, so this does work for multi-homed hosts too.
    option uamdomain	".paypal.com,.paypalobjects.com,.worldpay.com,.rbsworldpay.com,.adyen.com,.hotspotsystem.com"
    
    # Various debug and optimization values
    option swapoctets		1		# swap input and output octets
    option interval 		3600		# config file and host lookup refresh
    
    # Add the chilli firewall rules
    option ipup '/etc/chilli/up.sh'
    option ipdown '/etc/chilli/down.sh'
```

Start chilli

```
/etc/init.d/chilli start
```

Check if the chilli process is running

```
ps | grep chilli
```

Check if the `tun0` device is up with `ifconfig`.

Check if the options were correctly processed;

```
cat /var/run/chilli_<config>.conf
```

If all is well, you should be able to connect to your hotspot. If WISPr works correctly, your PC should automatically start browser and go to login page, without actually intercepting a customer request.

Once it all works, set chilli to autostart

```
/etc/init.d/chilli enable
```

### Security Warning

If you hang your hotspot off your private LAN, please be aware that your private LAN is on the WAN side of the hotspot router and thus open to any authenticated hotspot user. That user may not know about your internal addresses, but security through obscurity is never a good idea.

This is no bug, it all works as it was designed. After all chilli does not know which portions of the WAN should be off limits.

Still, if you want to prevent this, first ensure chilli does not need or use some of your private servers (like DNS or RADIUS), and then add this firewall rule in OpenWrt's custom firewall file **`/etc/config/firewall.user`** :

|`iptables -A FORWARD -s 192.168.180.0/22 -d 192.168.1.0/24 -j DROP`|

TODO: a better/cleaner command. ideally, we should use environment variables for this rather than hardcode anything

```
iptables -I INPUT -p all -i tun+ -j REJECT
iptables -I FORWARD -p all -i tun+ -o $(ifconfig $(uci get network.wan.ifname) 2>/dev/null | \
	awk '/inet addr/ {printf "%s\n", substr($2,6)}') -j REJECT
```

## Known issues / bugs

### WISPr goes to MSN

When WISPr autostarts the browser, it may actually try to go to “go.microsoft.com/fwlink/?LinkID=219472&amp;clcid=0x409” at first. This is due to Windows EnableActiveProbing. This is where windows tries to reach a page to determine if internet works, otherwise you get that little yellow bang over the WiFi/network icon. The page will be intercepted by chilli, so you still get the login page anyway, but it is not as smooth and fast as it could be.

You need to disable EnableActiveProbing if you want to prevent this, but you would have to change that on your all of customers PC's, so it is not really an option. For now we will just have to accept the situation.

(*PS: I did consider blocking DNS resolution for “go.microsoft.com” for unauthenticated clients, but am not sure how to do that*)

### init restart does not work

The OpenWrt integration does seem to have the issue that `/etc/init.d/chilli restart` does not work. It probably tries to restart too soon. If you manually stop and start again it also does not work. If you wait a second or 2, and start again it works.

EDIT: I also came across this bug so I've opened a bug report for this and posted the fix there too. [Link](https://dev.openwrt.org/ticket/22880 "https://dev.openwrt.org/ticket/22880") You just need to replace the stop function in `/etc/init.d/chilli` with

```
  stop() {
    for pID in $( pgrep chilli )
     do
       kill  $pID
     done
    rm -f /var/run/chilli*
  }
```

## Written by

Page was initiated by cybermaus, comments and additions welcome.

- Mail: cybermaus\_at\_gmail.com

## Resources

- \[0] [http://downloads.openwrt.org/snapshots/trunk/](http://downloads.openwrt.org/snapshots/trunk/ "http://downloads.openwrt.org/snapshots/trunk/")
- \[1] [https://coova.github.io/](https://coova.github.io/ "https://coova.github.io/")
- \[2] [http://coova.github.io/CoovaChilli/chilli.conf(5).html](http://coova.github.io/CoovaChilli/chilli.conf%285%29.html "http://coova.github.io/CoovaChilli/chilli.conf(5).html")
- \[3] [https://gremaudpi.emf-informatique.ch/how-to-build-a-captive-portal-with-radiusdesk-and-coova-chilli-on-raspberry-pi-running-openwrt/](https://gremaudpi.emf-informatique.ch/how-to-build-a-captive-portal-with-radiusdesk-and-coova-chilli-on-raspberry-pi-running-openwrt/ "https://gremaudpi.emf-informatique.ch/how-to-build-a-captive-portal-with-radiusdesk-and-coova-chilli-on-raspberry-pi-running-openwrt/")
