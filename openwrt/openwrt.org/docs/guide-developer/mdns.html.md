# umdns for Local Device Discovery

The [umdns](/packages/pkgdata/umdns "packages:pkgdata:umdns") package creates a local DNS name for your router. When `umdns` is installed, the router and all its services are available using the name *hostname.local* instead of requiring the router's IP address.

`umdns` relies on mDNS (“multicast DNS”) also known as Bonjour, zero-configuration networking (ZeroConf) or DNS Service Discovery (DNS-SD). mDNS enables automatic discovery of computers, devices, and services on the local network. It is an internet standard documented in [RFC6762](https://tools.ietf.org/html/rfc6762 "https://tools.ietf.org/html/rfc6762").

## Installation

The [umdns](/packages/pkgdata/umdns "packages:pkgdata:umdns") package provides a compact implementation of this standard, well integrated with the OpenWrt system environment. It requires no configuration to work “right out of the box”. `umdns` is available using LuCI web interface, or with `opkg install umdns` (OpenWRT 17 and later).

### Configuration

**I NEED HELP NAILING DOWN THE DEFAULT, AND THE CORRECT DESCRIPTION OF ALL THE FOLLOWING LINES**

**Hostname:** `umdns` advertises the hostname that is present in `/etc/config/system`.

[/etc/config/system](/_export/code/docs/guide-developer/mdns?codeblock=0 "Download Snippet")

```
option hostname 'your_openwrt_device'      # sets the mDNS name to your_openwrt_device.local
```

**Local domain:** OpenWrt uses `.lan` by default. There is an [ongoing discussion](https://forum.openwrt.org/t/use-home-arpa-as-default-tld-for-local-network/165056/ "https://forum.openwrt.org/t/use-home-arpa-as-default-tld-for-local-network/165056/") about the proper suffix for the local domain - `.local`, `.lan`, or even `.home.arpa`. Choose one, and everything in your network will interoperate.

Configure the local domain in LuCI in the **Network → DNS and DHCP** in the **Local domain** field, or by editing `/etc/config/dhcp`.

[/etc/config/dhcp](/_export/code/docs/guide-developer/mdns?codeblock=1 "Download Snippet")

```
config dnsmasq
	...
	option local '/lan/'
	option domain 'lan'
	...
```

**umdns configuration:** `umdns` has its own configuration file.

[/etc/config/umdns](/_export/code/docs/guide-developer/mdns?codeblock=2 "Download Snippet")

```
config umdns
	option jail 1 # enables jail - see procd
	list network lan
	list network dmz # Provides visibility into both networks, but does not act as a repeater
```

**Notes:**

- The `option jail` **DOES WHAT?**

<!--THE END-->

- The `list network` lines indicate the interfaces where `umdns` advertises its names. The interface name is found from `/etc/config/network`, not the device name shown by `ifconfig`. So if the network configuration file contains `config interface 'vlan1'` in your `/etc/config/network`, use `vlan1`. To test for the correct name name use `ifstatus`.

<!--THE END-->

- It is considered unsafe to enable umdns on `wan` interface because it makes those hosts more visible to the external world.

### Firewall

mDNS requires UDP port 5353. If you choose to advertise on `wan` (see security warning above) or other networks, open that port in the firewall:

[/etc/config/firewall](/_export/code/docs/guide-developer/mdns?codeblock=3 "Download Snippet")

```
config rule
        option src_port '5353'
        option src '*'
        option name 'Allow-mDNS'
        option target 'ACCEPT'
        option dest_ip '224.0.0.251'
        option dest_port '5353'
        option proto 'udp'
```

To configure from GUI see “Firewall rules” section of [Resolving mDNS across VLANs with Avahi on OpenWRT](https://blog.christophersmart.com/2020/03/30/resolving-mdns-across-vlans-with-avahi-on-openwrt/ "https://blog.christophersmart.com/2020/03/30/resolving-mdns-across-vlans-with-avahi-on-openwrt/")

### mDNS Alternatives

As noted above, the [umdns](/packages/pkgdata/umdns "packages:pkgdata:umdns") package works well with the OpenWrt system environment, and is suitable for most straightforward environments.

If you know you need additional capabilities, there are several other packages that can provide mDNS services. They are described on the [Zero configuration networking in OpenWrt](/docs/guide-user/network/zeroconfig/zeroconf "docs:guide-user:network:zeroconfig:zeroconf") page.

## For Developers

The following information is useful if you are developing a service that uses mDNS.

### Browsing announced services

Almost all interaction with the daemon is via [ubus](/docs/guide-developer/ubus "docs:guide-developer:ubus").

```
$ ubus call umdns update
# wait a second or two
$ ubus call umdns browse
# big json dump example...
        ....
	"_printer._tcp": {
		"HP\\032Color\\032LaserJet\\032CP2025dn\\032(28A6CC)": {
			"port": 515,
			"txt": "txtvers=1",
			"txt": "qtotal=1",
			"txt": "rp=RAW",
			"txt": "ty=HP Color LaserJet CP2025dn",
			"txt": "product=(HP Color LaserJet CP2025dn)",
			"txt": "priority=50",
			"txt": "adminurl=http:\/\/NPI28A6CC.local.",
			"txt": "Transparent=T",
			"txt": "Binary=T",
			"txt": "TBCP=T"
		},
		"HP\\032LaserJet\\032P3010\\032Series\\032[46A14F]": {
			"port": 515,
			"txt": "txtvers=1",
			"txt": "qtotal=4",
			"txt": "rp=RAW",
			"txt": "pdl=application\/postscript,application\/vnd.hp-PCL,application\/vnd.hp-PCLXL",
			"txt": "ty=HP LaserJet P3010 Series",
			"txt": "product=(HP LaserJet P3010 Series)",
			"txt": "usb_MFG=Hewlett-Packard",
			"txt": "usb_MDL=HP LaserJet P3010 Series",
			"txt": "priority=52",
			"txt": "adminurl=http:\/\/NPI46A14F.local."
      },
   ....
$ ubus call umdns hosts 
#Show hosts discovered via mDns
        "SteakPrinter.local": {
                "ipv4": "192.168.1.159"
        },
        "Upstairs.local": {
                "ipv4": "192.168.1.151"
        },
```

### Issues/Bugs

- IP addresses are missing.
- TXT records aren't valid json in the dump, so jsonfilter can't be used.
- How long is data cached? What causes it to update? No idea.
- You may not see locally advertised services with `ubus call umdns browse`. See the [discussion](https://forum.openwrt.org/t/how-to-announce-service-with-umdns/5029/7 "https://forum.openwrt.org/t/how-to-announce-service-with-umdns/5029/7")

### Announcing local services

The umdns scans all the services listed in ubus (`ubus call service list`) and looks for `mdns` objects in their data object. You can view this more selectively for example with:

```
# ubus call service list | jsonfilter -e "$[*]['instances'][*]['data']['mdns']"
{ "ssh_22": { "service": "_ssh._tcp.local", "port": 22, "txt": [ "daemon=dropbear" ] } }
```

Here we can see that ssh is being advertised locally.

If you want to advertise your own service, your service needs to be a [procd](/docs/guide-developer/procd "docs:guide-developer:procd") managed service. You can use the `procd_add_mdns` call to provide a basic definition.

```
procd_open_instance
....
procd_add_mdns <service> <proto> <port> [<textkey=textvalue> ... ]
...
procd_close_instance
```

As an example, the following call

```
procd_add_mdns "webdav" "tcp" "80" "path=/nextcloud/remote.php/dav/files/YOUR_USER/" "u=YOUR_USER"
```

advertises `_webdav._tcp.local` with two text records. In the example we published a WebDAV folder from Nextcloud and now it can be seen in Network folder of a file manager in GNOME and KDE and can be [discovered from a Kodi media player](https://kodi.wiki/view/Avahi_Zeroconf "https://kodi.wiki/view/Avahi_Zeroconf"). The service names may be taken from the [IANA register](https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml "https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml") and the txt-records may be taken from the official DNS-SD keys (see [ServiceTypes](http://www.dns-sd.org/ServiceTypes.html "http://www.dns-sd.org/ServiceTypes.html") under “Defined TXT keys”.

If you wish to create a more complicated mdns information block, see `procd_add_mdns_service` in `/lib/functions/procd.sh` but be warned that umdns probably can't automatically support everything you can represent in json.

### Service description files in /etc/umdns

umdns advertises the services whose `*.json` files are found in `/etc/umdns`. This is similar to how Avahi advertises `*.service` files in `/etc/avahi/services/`.

**IMPORTANT!** Keep the json formating as in the following examples, i.e. the service definition needs to be a one-liner, otherwise it won't work!

For example the same WebDAV service description:

[/etc/umdns/nextcloud\_webdav.json](/_export/code/docs/guide-developer/mdns?codeblock=8 "Download Snippet")

```
{
  "nextcloud_webdav": { "service": "_webdav._tcp.local", "port": 80, "txt": [ "path=/nextcloud/remote.php/dav/files/YOUR_USER/", "u=YOUR_USER" ] }
}
```

Or you can advertise SFTP and SSH:

[/etc/umdns/ssh.json](/_export/code/docs/guide-developer/mdns?codeblock=9 "Download Snippet")

```
{
  "ssh_login": { "service": "_ssh._tcp.local", "port": 22, "txt": [ "u=root" ] },
  "sftp_share": { "service": "_sftp-ssh._tcp.local", "port": 22, "txt": [ "path=/", "u=root" ] }
}
```

See more examples in [umdns sources](https://git.openwrt.org/?p=project%2Fmdnsd.git%3Ba%3Dtree%3Bf%3Djson%3Bhb%3DHEAD "https://git.openwrt.org/?p=project/mdnsd.git;a=tree;f=json;hb=HEAD")

The reload the umdns service with: `ubus call umdns reload` or `service umdns reload`

### Testing

To see that service was advertised you may use `avahi-discover` GUI application. To see from a command line use `avahi-browse --all`. To find a specific service use: `avahi-browse -d local _webdav._tcp`.

### Links

- [Sources](https://git.openwrt.org/?p=project%2Fmdnsd.git%3Ba%3Dtree%3Bhb%3DHEAD "https://git.openwrt.org/?p=project/mdnsd.git;a=tree;hb=HEAD")
- [Sources on GitHub](https://github.com/openwrt/mdnsd/ "https://github.com/openwrt/mdnsd/")
