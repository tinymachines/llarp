# Asterisk

## Introduction

[Asterisk](https://www.asterisk.org/ "https://www.asterisk.org/") is an open-source software PBX that can be extended by various modules. OpenWrt provides packages for Asterisk and most of its official modules via the telephony [feed](/docs/guide-developer/feeds "docs:guide-developer:feeds"). On routers with Lantiq SoCs it's possible to use built in analogue FXS ports with Asterisk, turning these devices into [VoIP gateways](https://en.wikipedia.org/wiki/VoIP_gateway "https://en.wikipedia.org/wiki/VoIP_gateway") (see [chan-lantiq for Asterisk](/docs/guide-user/services/voip/chan-lantiq "docs:guide-user:services:voip:chan-lantiq")).

This article focuses on Asterisk installation and basic SIP configuration on OpenWrt.

## Installation

### Choosing an Asterisk version

Asterisk has standard and long term support (LTS) releases. Have a look at [Asterisk versions](https://docs.asterisk.org/About-the-Project/Asterisk-Versions/ "https://docs.asterisk.org/About-the-Project/Asterisk-Versions/") on the Asterisk wiki for the current upstream support status. OpenWrt releases usually include the latest LTS release of Asterisk.

You can query the package table to get information about the Asterisk versions in OpenWrt, module names and their descriptions: [Asterisk packages](/packages/table/start?dataofs=50&dataflt%5BName_pkg-dependencies%2A~%5D=asterisk "packages:table:start")

### SIP stack

Until Asterisk 20 it was possible to choose between two SIP stacks in Asterisk: `chan_sip` and `chan_pjsip`.

`chan_sip` was marked as [deprecated](https://www.asterisk.org/deprecating-chan_sip-asterisk-17-0-0-rc2-release/ "https://www.asterisk.org/deprecating-chan_sip-asterisk-17-0-0-rc2-release/") with the release of Asterisk 17 and was [removed in Asterisk 21](https://docs.asterisk.org/Development/Asterisk-Module-Deprecations/ "https://docs.asterisk.org/Development/Asterisk-Module-Deprecations/").

You can find help on how to migrate your configuration [here](https://docs.asterisk.org/Configuration/Channel-Drivers/SIP/Configuring-res_pjsip/Migrating-from-chan_sip-to-res_pjsip/ "https://docs.asterisk.org/Configuration/Channel-Drivers/SIP/Configuring-res_pjsip/Migrating-from-chan_sip-to-res_pjsip/").

### Opkg

While it's perfectly possible to install Asterisk via [opkg](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg"), keep in mind that space on the [OverlayFS](/docs/techref/filesystems "docs:techref:filesystems") ist limited on most devices.

```
opkg install asterisk asterisk-pjsip asterisk-bridge-simple asterisk-codec-alaw asterisk-codec-ulaw asterisk-res-rtp-asterisk
```

An Asterisk installation can be quite big. If you plan to use several modules, you may easily run out of space. In this case, you can try to build a custom image using the image builder.

### Image builder

The [image builder](/docs/guide-user/additional-software/imagebuilder "docs:guide-user:additional-software:imagebuilder") can be used to build Asterisk packages directly into the SquashFS partition. Optionally you can exclude packages you don't need to save space.

Example command for an [o2 Box 6431](/toh/arcadyan/vgv7510kw22 "toh:arcadyan:vgv7510kw22"):

```
make image PROFILE=arcadyan_vgv7510kw22-nor PACKAGES="kmod-ltq-tapi kmod-ltq-vmmc kmod-ltq-ifxos asterisk asterisk-pjsip asterisk-bridge-simple asterisk-codec-alaw asterisk-codec-ulaw asterisk-res-rtp-asterisk asterisk-chan-lantiq"
```

## Security considerations

VoIP services are a common attack target and it's important to implement at least some basic security measures before putting an Asterisk server online.

Asterisk security advisories are announced here: [https://www.asterisk.org/downloads/security-advisories](https://www.asterisk.org/downloads/security-advisories "https://www.asterisk.org/downloads/security-advisories")

### Modules

Only install modules you really need. For basic SIP operation it's enough to install a RTP stack (`*-res-rtp-asterisk`), a channel bridging module (`asterisk*-bridge-simple`) and needed audio codecs (normally `*-codec-alaw` or `*-codec-ulaw`) in addition to the SIP stack.

### Firewall

Don't expose SIP related ports on your WAN Interface. For in- and outgoing calls the registration process takes care to establish a connection to your SIP provider and to keep it alive.

If you have problems receiving incoming calls, you can try to install `kmod-nf-nathelper-extra`, see [here](https://forum.openwrt.org/t/solved-incoming-calls-not-reaching-hosts-on-the-network/77568/2 "https://forum.openwrt.org/t/solved-incoming-calls-not-reaching-hosts-on-the-network/77568/2") or [here](https://forum.openwrt.org/t/voip-behind-a-openwrt-nat-router/40534/12 "https://forum.openwrt.org/t/voip-behind-a-openwrt-nat-router/40534/12").

### Blocking of unneeded numbers

Most SIP providers offer to block foreign or special numbers. It's highly recommended to make use of that if you don't need them. That way an attacker can't make calls to these numbers, even if your installation should get compromised.

## Configuration

Asterisk configurations can differ to a great extend depending on provider/hardware/country, so it's difficult to provide generic configurations. On OpenWrt, Asterisk configuration files can be found under `/etc/asterisk/`. The most important files are the dialplan (`extensions.conf`) and the SIP channel configuration (`pjsip.conf` or `sip.conf`). Location specific tone indications are set in `indications.conf`. Links to the corresponding Asterisk-wiki-pages with details on configuration options are given below, together with working examples, taken from [this forum thread](https://forum.openwrt.org/t/voip-configuration-for-asterisk13-pjsip-chan-lantiq-and-vodafone-germany/9470 "https://forum.openwrt.org/t/voip-configuration-for-asterisk13-pjsip-chan-lantiq-and-vodafone-germany/9470").

After changing your Asterisk configuration, restart the server: `/etc/init.d/asterisk reload`

Before the asterisk service can be used it must be 'enabled'. Edit the config file /etc/config/asterisk and check the option enabled (0→1).

If asterisk is not started as a service and you see something like this in dmesg:

do\_page\_fault(): sending SIGSEGV to asterisk for invalid read access from 00000008

epc = 77d76e90 in libc.so\[77d46000+ab000]

ra = 77d77394 in libc.so\[77d46000+ab000]

you should let asterisk run as root. There seems to be a bug if the service is run as the user asterisk. To prevent this edit:

`nano /etc/init.d/asterisk` and comment the line “-U “$NAME” \\” → “#-U “$NAME” \\” also adjust the position if the “-f \\” parameter.

### pjsip.conf

[https://docs.asterisk.org/Asterisk\_16\_Documentation/API\_Documentation/Module\_Configuration/res\_pjsip/](https://docs.asterisk.org/Asterisk_16_Documentation/API_Documentation/Module_Configuration/res_pjsip/ "https://docs.asterisk.org/Asterisk_16_Documentation/API_Documentation/Module_Configuration/res_pjsip/")

***Example for Vodafone Germany:***

[pjsip.conf](/_export/code/docs/guide-user/services/voip/asterisk?codeblock=2 "Download Snippet")

```
[global]
type = global
endpoint_identifier_order = ip,username
 
[acl]
type = acl
deny = 0.0.0.0/0.0.0.0
permit = 127.0.0.1
;permit = 192.168.1.0/24 ;uncomment if you want to connect clients from LAN
permit = 88.79.152.xxx ;nslookup <area_code>.sip.arcor.de
 
[transport-udp]
type = transport
protocol = udp
bind = 0.0.0.0:5060
local_net = 127.0.0.1
local_net = 192.168.1.0/24
 
[reg_arcor]
type = registration
transport = transport-udp
contact_user = <area_code><your_number>
client_uri = sip:<area_code><your_number>@<area_code>.sip.arcor.de
server_uri = sip:<area_code>.sip.arcor.de
outbound_auth = auth_arcor
retry_interval = 30
forbidden_retry_interval = 300
max_retries = 10
auth_rejection_permanent = false
 
[auth_arcor]
type = auth
auth_type = userpass
realm = arcor.de
username = <area_code><your_number>
password = <password>
 
[aor_arcor]
type = aor
contact = sip:<area_code>.sip.arcor.de
 
[id_arcor]
type = identify
match = <area_code>.sip.arcor.de
endpoint = in_arcor
 
[in_arcor]
type = endpoint
transport = transport-udp
context = lantiq1_inbound
disallow = all
allow = alaw,g722,ulaw
disable_direct_media_on_nat = yes
rewrite_contact = yes
 
[out_arcor]
type = endpoint
transport = transport-udp
disallow = all
allow = alaw,g722,ulaw
disable_direct_media_on_nat = yes
callerid = <area_code><your_number>
from_user = <area_code><your_number>
from_domain = <area_code>.sip.arcor.de
outbound_auth = auth_arcor
aors = aor_arcor
```

Vodafone also supports the [line option](https://www.asterisk.org/the-pjsip-outbound-registration-line-option/ "https://www.asterisk.org/the-pjsip-outbound-registration-line-option/"), which can simplify the configuration by omitting the `[id_arcor]` section. The above configuration is shown to present a more generic example.

***Example for Telekom Germany:***

In order to get trusted input ip-addresses which can be used in the \[acl] section you can use: nslookup -q=SRV \_sip.\_udp.tel.t-online.de 1.1.1.1 .

[pjsip.conf](/_export/code/docs/guide-user/services/voip/asterisk?codeblock=3 "Download Snippet")

```
[global]
type = global
endpoint_identifier_order = ip,username
 
[acl]
type = acl
deny = 0.0.0.0/0.0.0.0
permit = 127.0.0.1
permit = 217.0.147.5
permit = 217.0.146.5
permit = 217.0.147.197
 
[transport-udp]
type = transport
protocol = udp
bind = 0.0.0.0
 
[transport-tcp]
type = transport
protocol = tcp
bind = 0.0.0.0
 
[reg_telekom]
type = registration
contact_user = <area_code><your_number> ;(e.g. 0228...)
client_uri = sip:<intern_code><area_code><your_number>@tel.t-online.de ;(e.g.+49228...)
server_uri = sip:tel.t-online.de
outbound_auth = auth_telekom
retry_interval = 30
forbidden_retry_interval = 300
max_retries = 10
auth_rejection_permanent = false
 
[auth_telekom]
type = auth
auth_type = userpass
username = <accessnumber> ;(former T-Online Number)
realm = tel.t-online.de
 
[aor_telekom]
type = aor
contact = sip:<intern_code><area_code><your_number>@tel.t-online.de
 
[id_telekom]
type = identify
match = tel.t-online.de
endpoint = in_telekom
 
[in_telekom]
type = endpoint
context = lantiq1_inbound
disallow = all
allow = alaw,g722,ulaw
disable_direct_media_on_nat = yes
rewrite_contact = yes
 
[out_telekom]
type = endpoint
disallow = all
allow = alaw,g722,ulaw
disable_direct_media_on_nat = yes
callerid = <area_code><your_number>
from_user = <area_code><your_number>
from_domain = tel.t-online.de
outbound_auth = auth_telekom
aors = aor_telekom
```

***Important!** Enable Telekom DNS server for \*t-online.de:*

`uci add_list dhcp.@dnsmasq[0].server=“/t-online.de/1.1.1.1”`

`uci commit dhcp`

`service dnsmasq restart`

### extensions.conf

[https://docs.asterisk.org/Configuration/Dialplan/](https://docs.asterisk.org/Configuration/Dialplan/ "https://docs.asterisk.org/Configuration/Dialplan/")

Example for Vodafone Germany:

[extensions.conf](/_export/code/docs/guide-user/services/voip/asterisk?codeblock=4 "Download Snippet")

```
[general]
static=yes
writeprotect=yes
autofallthrough=yes
 
[default]
exten => _X.,1,Answer()
same => n,Verbose(1,${CALLERID(num)} reached context DEFAULT by calling ${EXTEN})
same => n,Hangup()
 
[out_arcor]
; national numbers with country code
exten => _+49ZXX!.,1,Dial(PJSIP/${EXTEN}@out_arcor,60,Trg)
same => n,Hangup()

; national numbers called with leading 0
exten => _0Z.,1,Dial(PJSIP/${EXTEN}@out_arcor,60,Trg)
same => n,Hangup()

; local area numbers
exten => _Z.,1,Dial(PJSIP/${EXTEN}@out_arcor,60,Trg)
same => n,Hangup()

; emergency calls
exten => 110,1,Dial(PJSIP/${EXTEN}@out_arcor,60,Trg)
exten => 110,n,Hangup()
exten => 112,1,Dial(PJSIP/${EXTEN}@out_arcor,60,Trg)
exten => 112,n,Hangup()

; add rules for expensive special numbers. Get German examples from:
; https://www.linuxmaker.com//asterisk-pbx/dialplan-extensionsconf.html
exten => _0137Z.,1,Verbose(1,Blocked: ${EXTEN})
;same => n,Playback(forbidden)
same => n,Hangup()
 
[lantiq1_inbound]
exten => <area_code><your_number>,1,Dial(TAPI/1,60,t)
same => n,Hangup()
 
[lantiq1]
include => out_arcor

;[lantiq2]
;include => ltq2_out
```

Just change arcor to telekom if you want to use it. Check on your router both ports for telephony in order to get the right one.

### indications.conf

[https://docs.asterisk.org/Configuration/Core-Configuration/Configuring-Localized-Tone-Indications/](https://docs.asterisk.org/Configuration/Core-Configuration/Configuring-Localized-Tone-Indications/ "https://docs.asterisk.org/Configuration/Core-Configuration/Configuring-Localized-Tone-Indications/")

Example for Vodafone Germany:

[indications.conf](/_export/code/docs/guide-user/services/voip/asterisk?codeblock=5 "Download Snippet")

```
[general]
country=de
```

### lantiq.conf

If you plan to use Asterisk on a Lantiq device, see [chan-lantiq](/docs/guide-user/services/voip/chan-lantiq "docs:guide-user:services:voip:chan-lantiq") for detailed configuration examples.

[lantiq.conf](/_export/code/docs/guide-user/services/voip/asterisk?codeblock=6 "Download Snippet")

```
[interfaces]
channels = 2
per_channel_context = on
```

`per_channel_context = on` is important, as it will place calls from the Lantiq FXS ports in contexts `lantiq1` and `lantiq2` instead of `default`, which should be avoided.

### SQM/QoS

For VoIP you will need some form of traffic shaping to reduce latency. On OpenWrt the best choice is using [SQM with cake](/docs/guide-user/network/traffic-shaping/sqm "docs:guide-user:network:traffic-shaping:sqm"). To prioritize VoIP traffic choose `layer_cake.qos` as the queue setup script. For more details read [this forum thread](https://forum.openwrt.org/t/simple-qos-for-voip/10382 "https://forum.openwrt.org/t/simple-qos-for-voip/10382").

More information on TOS/CoS values can be found in the [IP QoS article](https://docs.asterisk.org/Configuration/Channel-Drivers/IP-Quality-of-Service/ "https://docs.asterisk.org/Configuration/Channel-Drivers/IP-Quality-of-Service/") on the Asterisk documentation.

## Asterisk GUI

A GUI in LuCI is provided through [luci-app-asterisk](/packages/pkgdata/luci-app-asterisk "packages:pkgdata:luci-app-asterisk") package, however it's been deprecated since Asterisk 17.

## Asterisk CLI

[Asterisk provides its own CLI](https://docs.asterisk.org/Operation/Asterisk-Command-Line-Interface/ "https://docs.asterisk.org/Operation/Asterisk-Command-Line-Interface/"), which is especially useful for debugging. Execute `asterisk -r`, to connect to a already running Asterisk server.

Commands follow a general syntax of `<module name> <action type> <parameters>`. The CLI supports command-line completion using the `<Tab>` key.

You can stop the service `/etc/init.d/asterisk stop` and run the verbose CLI `asterisk -cvvvvv` while setting up the system.

### Increasing the log level

To see what's going on during a call run the following command inside the Asterisk CLI:

```
core set verbose 3
```

After that run `module reload logger` and make a call. To get even more verbose information, you can execute the following commands (![:!:](/lib/images/smileys/exclaim.svg) enabling all of them will produce a lot of output!):

```
core set verbose 5
core set debug 5
pjsip set logger on
rtp set debug on
```

### Other useful commands

```
dialplan show <context>

pjsip show endpoints
pjsip show endpoint <endpoint>
pjsip show registration <registration>
```

During a call:

```
core show channels
core show channel <channel>
```

### Executing commands from outside the CLI

You can execute Asterisk commands from outside the CLI, for example to control the Asterisk server via a shell script:

```
asterisk -rx "pjsip show endpoints"
```

## Finding further information about Asterisk

- The first place to look for information is [the Asterisk documentation](https://docs.asterisk.org/ "https://docs.asterisk.org/")
- Another great resource is *The Asterisk Book*. It's about an older Asterisk version, but explains the core principles in a very profound way: [English version](http://the-asterisk-book.com/ "http://the-asterisk-book.com/"), [German version](http://das-asterisk-buch.de/ "http://das-asterisk-buch.de/")
- [Official Asterisk forum](https://community.asterisk.org/ "https://community.asterisk.org/")
