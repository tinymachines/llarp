# The UCI system

See also: [UCI defaults](/docs/guide-developer/uci-defaults "docs:guide-developer:uci-defaults"), [Network scripting](/docs/guide-developer/network-scripting#examples "docs:guide-developer:network-scripting")

The abbreviation [UCI](/docs/techref/uci "docs:techref:uci") stands for ***U**nified **C**onfiguration **I**nterface*, and is a system to centralize the configuration of OpenWrt services.

UCI is the successor to the NVRAM-based configuration found in the White Russian series of OpenWrt. It is the main configuration user interface for the most important system settings including the main network interface configuration, wireless settings, logging functionality and remote access configuration.

Many packages in the OpenWrt repository have been made compatible with the UCI system. Applications are made UCI-compatible by simply writing the original configuration file (which is read by the program) according to the chosen settings in the corresponding UCI file. This is done upon running the initialization scripts in `/etc/init.d/`. See [Init scripts](/docs/techref/initscripts "docs:techref:initscripts") for more information. Thus, when starting a daemon with such a UCI-compatible initialization script, you should be aware that the program's original configuration file gets overwritten. For example, in the case of [Samba/CIFS](/docs/guide-user/services/nas/cifs.server "docs:guide-user:services:nas:cifs.server"), the file `/etc/samba/smb.conf` is overwritten with UCI settings from the UCI configuration file `/etc/config/samba` when running `/etc/init.d/samba start`. In addition, the application's configuration file is often stored in RAM instead of in flash, because it does not need to be stored in non-volatile memory and it is rewritten after every change, based on the UCI file. There are ways to disable UCI in case you want to adjust settings in the original configuration file not available through UCI, in [cifs.server](/docs/guide-user/services/nas/cifs.server "docs:guide-user:services:nas:cifs.server") you can see how to disable UCI for samba, for example.

For those non-UCI compatible programs, there is a convenient [list of some non-UCI configuration files](/docs/guide-user/base-system/notuci.config "docs:guide-user:base-system:notuci.config") you may want to tend to. Note that, for most third party programs, you should consult the program's own documentation.

## Common principles

OpenWrt's central configuration is split into several files located in the `/etc/config/` directory. Each file relates roughly to the part of the system it configures. You can edit the configuration files with a text editor or modify them with the command line utility program `uci`. UCI configuration files are also modifiable through various programming APIs (like Shell, Lua and C), which is also how web interfaces like [LuCI](/docs/guide-user/luci/luci.essentials "docs:guide-user:luci:luci.essentials") make changes to the UCI files.

Upon changing a UCI configuration file, whether through a text editor or the command line, the services or executables that are affected must be (re)started (or, in some cases, simply reloaded) by an [init.d call](/docs/techref/initscripts "docs:techref:initscripts"), such that the updated UCI configuration is applied to them. Many programs are made compatible with UCI by simply making their init.d script first update their standard program-specific configuration files, based on the updated UCI configuration in `/etc/config`, and then restarting the executable. This implies that solely (re)starting the executable directly, without calling the appropriate init.d script, would not behave as expected as it would not yet result in the incorporation of configuration updates into the program's standard [configuration file(s)](http://en.wikipedia.org/wiki/Configuration_file "http://en.wikipedia.org/wiki/Configuration_file").

As an example of modifying the UCI configuration, suppose you want to change the device's IP address from the default `192.168.1.1` to `192.168.2.1`. To do this, using any text editor, such as vi, change the line

```
option ipaddr	192.168.1.1
```

in the file `/etc/config/network` to:

```
option ipaddr	192.168.2.1
```

Next, commit the settings by running

```
/etc/init.d/network restart
```

In this case, remember that you have to login again using SSH as the device is now accessible at its new IP address!

## Configuration files

File Description Basic [/etc/config/dhcp](/docs/guide-user/base-system/dhcp "docs:guide-user:base-system:dhcp") [Dnsmasq](/docs/guide-user/base-system/dhcp.dnsmasq "docs:guide-user:base-system:dhcp.dnsmasq") and [odhcpd](/docs/techref/odhcpd "docs:techref:odhcpd") settings: DNS, DHCP, DHCPv6 [/etc/config/dropbear](/docs/guide-user/base-system/dropbear "docs:guide-user:base-system:dropbear") SSH server options [/etc/config/firewall](/docs/guide-user/firewall/firewall_configuration "docs:guide-user:firewall:firewall_configuration") NAT, packet filter, port forwarding, etc. [/etc/config/network](/docs/guide-user/network/ucicheatsheet "docs:guide-user:network:ucicheatsheet") Switch, interface and route configuration:  
[General](/docs/guide-user/network/network_configuration "docs:guide-user:network:network_configuration"), [IPv4](/docs/guide-user/network/ipv4/configuration "docs:guide-user:network:ipv4:configuration"), [IPv6](/docs/guide-user/network/ipv6/configuration "docs:guide-user:network:ipv6:configuration"), [Routes](/docs/guide-user/network/routing/routes_configuration "docs:guide-user:network:routing:routes_configuration"), [Rules](/docs/guide-user/network/routing/ip_rules "docs:guide-user:network:routing:ip_rules"), [WAN](/docs/guide-user/network/wan/wan_interface_protocols "docs:guide-user:network:wan:wan_interface_protocols"), [Aliases](/docs/guide-user/network/network_interface_alias "docs:guide-user:network:network_interface_alias"), [Switches](/docs/guide-user/network/network_configuration "docs:guide-user:network:network_configuration"), [VLAN](/docs/guide-user/network/vlan/switch_configuration "docs:guide-user:network:vlan:switch_configuration"), [IPv4/IPv6 transitioning](/docs/guide-user/network/ipv6_ipv4_transitioning "docs:guide-user:network:ipv6_ipv4_transitioning"), [Tunneling](/docs/guide-user/network/tunneling_interface_protocols "docs:guide-user:network:tunneling_interface_protocols") [/etc/config/system](/docs/guide-user/base-system/system_configuration "docs:guide-user:base-system:system_configuration") Misc. system settings, [NTP](/docs/guide-user/advanced/ntp_configuration "docs:guide-user:advanced:ntp_configuration"), [RNG](/docs/guide-user/services/rng "docs:guide-user:services:rng"), [Watchcat](/docs/guide-user/advanced/watchcat "docs:guide-user:advanced:watchcat") [/etc/config/wireless](/docs/guide-user/network/wifi/basic "docs:guide-user:network:wifi:basic") Wireless settings and wifi network definition IPv6 [/etc/config/ahcpd](/doc/uci/ahcpd "doc:uci:ahcpd") Ad-Hoc Configuration Protocol (AHCP) server and forwarder configuration [/etc/config/dhcp6c](/docs/guide-user/network/ipv6/dhcp6c "docs:guide-user:network:ipv6:dhcp6c") WIDE-DHCPv6 client [/etc/config/dhcp6s](/doc/uci/dhcp6s "doc:uci:dhcp6s") WIDE-DHCPv6 server [/etc/config/gw6c](/doc/uci/gw6c "doc:uci:gw6c") GW6c client configuration Other [/etc/config/acme](/docs/guide-user/services/tls/acmesh "docs:guide-user:services:tls:acmesh") Configure issuing of TLS certificates via ACME [/etc/config/babeld](/docs/guide-user/services/babeld "docs:guide-user:services:babeld") babeld configuration [/etc/config/bbstored](/docs/guide-user/services/bbstored "docs:guide-user:services:bbstored") BoxBackup server configuration [/etc/config/cloudflared](/docs/guide-user/services/vpn/cloudfare_tunnel "docs:guide-user:services:vpn:cloudfare_tunnel") Cloudflare tunnel [/etc/config/ddns](/docs/guide-user/base-system/ddns "docs:guide-user:base-system:ddns") Dynamic DNS configuration (ddns-scripts) [/etc/config/dnscrypt-proxy](/docs/guide-user/services/dns/dnscrypt-proxy "docs:guide-user:services:dns:dnscrypt-proxy") DNSCrypt proxy [/etc/config/dockerd](/docs/guide-user/virtualization/docker_host "docs:guide-user:virtualization:docker_host") The Docker CE Engine Daemon [/etc/config/emailrelay](/docs/guide-user/services/email/emailrelay "docs:guide-user:services:email:emailrelay") E-MailRelay: simple SMTP server and proxy with POP support. Package [emailrelay](/packages/pkgdata/emailrelay "packages:pkgdata:emailrelay") [/etc/config/etherwake](/docs/guide-user/services/w_o_l/etherwake "docs:guide-user:services:w_o_l:etherwake") Wake-on-Lan: etherwake [/etc/config/freifunk\_p2pblock](/docs/guide-user/firewall/freifunk_p2pblock "docs:guide-user:firewall:freifunk_p2pblock") Uses iptables layer7-, ipp2p- and recent-modules to block p2p/filesharing traffic [/etc/config/fstab](/docs/guide-user/storage/fstab "docs:guide-user:storage:fstab") Mount points and swap [/etc/config/hd-idle](/docs/guide-user/storage/hd-idle "docs:guide-user:storage:hd-idle") Another idle-daemon for attached hard drives [/etc/config/httpd](/docs/guide-user/base-system/httpd "docs:guide-user:base-system:httpd") Web server options (Busybox httpd, deprecated) [/etc/config/ipset-dns](/docs/guide-user/services/dns/ipset-dns "docs:guide-user:services:dns:ipset-dns") Configure [ipset-dns](https://git.zx2c4.com/ipset-dns/about/ "https://git.zx2c4.com/ipset-dns/about/") [/etc/config/kadnode](/docs/guide-user/services/dns/kadnode "docs:guide-user:services:dns:kadnode") KadNode p2p DNS [/etc/config/luci](/doc/uci/luci "doc:uci:luci") Base LuCI config [/etc/config/luci\_statistics](/doc/uci/luci_statistics "doc:uci:luci_statistics") Configuration of Statistics packet [/etc/config/mini\_snmpd](/docs/guide-user/services/snmp/mini_snmpd "docs:guide-user:services:snmp:mini_snmpd") mini\_snmpd settings [/etc/config/minidlna](/docs/guide-user/services/media_server/minidlna "docs:guide-user:services:media_server:minidlna") MiniDLNA settings [/etc/config/mjpg-streamer](/doc/uci/mjpg-streamer "doc:uci:mjpg-streamer") Streaming application for Linux-UVC compatible webcams [/etc/config/mountd](/docs/guide-user/storage/mountd "docs:guide-user:storage:mountd") OpenWrt automount daemon [/etc/config/mroute](/doc/uci/mroute "doc:uci:mroute") Configuration files for multiple WAN routes [/etc/config/multiwan](/docs/guide-user/network/wan/multiwan/multiwan_package "docs:guide-user:network:wan:multiwan:multiwan_package") Simple multi WAN configuration [/etc/config/mwan3](/docs/guide-user/network/wan/multiwan/mwan3 "docs:guide-user:network:wan:multiwan:mwan3") Multi-WAN config with load balancing and failover [/etc/config/nodogsplash](/docs/guide-user/services/captive-portal/nodogsplash "docs:guide-user:services:captive-portal:nodogsplash") nodogsplash configuration [/etc/config/ntpclient](/docs/guide-user/services/ntp/client "docs:guide-user:services:ntp:client") Getting the correct time [/etc/config/nut\_server](/docs/guide-user/services/ups/software.nut "docs:guide-user:services:ups:software.nut") Controlling a UPS (Uninterruptible Power Supply) and/or sharing with other hosts [/etc/config/nut\_monitor](/docs/guide-user/services/ups/software.nut "docs:guide-user:services:ups:software.nut") Monitoring a UPS (Uninterruptible Power Supply) from a remote host or local nut-server [/etc/config/nut\_cgi](/docs/guide-user/services/ups/software.nut "docs:guide-user:services:ups:software.nut") Web UI for NUT (viewing only in UCI) [/etc/config/p910nd](/docs/guide-user/services/print_server/p910nd "docs:guide-user:services:print_server:p910nd") config for non-spooling Printer daemon [p910nd.server](/docs/guide-user/services/print_server/p910nd.server "docs:guide-user:services:print_server:p910nd.server") [/etc/config/pure-ftpd](/docs/guide-user/services/nas/pure-ftpd "docs:guide-user:services:nas:pure-ftpd") Pure-FTPd server config [/etc/config/qos](/docs/guide-user/network/traffic-shaping/traffic_shaping "docs:guide-user:network:traffic-shaping:traffic_shaping") Implementing Quality of Service for the *upload* [/etc/config/racoon](/docs/guide-user/services/vpn/ipsec/racoon/basic "docs:guide-user:services:vpn:ipsec:racoon:basic") racoon IPsec daemon [/etc/config/samba](/docs/guide-user/services/nas/samba "docs:guide-user:services:nas:samba") settings for the Microsoft file and print services daemon [/etc/config/snmpd](/docs/guide-user/services/snmp/snmpd "docs:guide-user:services:snmp:snmpd") SNMPd settings [/etc/config/sqm](/docs/guide-user/network/traffic-shaping/sqm_configuration "docs:guide-user:network:traffic-shaping:sqm_configuration") SQM settings [/etc/config/sshtunnel](/docs/guide-user/services/ssh/sshtunnel "docs:guide-user:services:ssh:sshtunnel") Settings for the package `sshtunnel` [/etc/config/stund](/docs/guide-user/services/voip/stund "docs:guide-user:services:voip:stund") STUN server configuration [/etc/config/tinc](/doc/uci/tinc "doc:uci:tinc") [tinc](/docs/guide-user/services/vpn/tinc "docs:guide-user:services:vpn:tinc") package configuration [/etc/config/tor](/docs/guide-user/services/tor/client "docs:guide-user:services:tor:client") Tor configuration [/etc/config/tor-hs](/docs/guide-user/services/tor/hs "docs:guide-user:services:tor:hs") Tor hidden services configuration [/etc/config/transmission](/docs/guide-user/services/downloading_and_filesharing/transmission "docs:guide-user:services:downloading_and_filesharing:transmission") BitTorrent configuration [/etc/config/uhttpd](/docs/guide-user/services/webserver/uhttpd "docs:guide-user:services:webserver:uhttpd") Web server options (uHTTPd) [/etc/config/upnpd](/docs/guide-user/firewall/upnp/miniupnpd "docs:guide-user:firewall:upnp:miniupnpd") miniupnpd UPnP server settings [/etc/config/users](/docs/guide-user/base-system/users "docs:guide-user:base-system:users") user database for different services [/etc/config/ushare](/docs/guide-user/services/media_server/ushare "docs:guide-user:services:media_server:ushare") uShare UPnP server settings [/etc/config/vblade](/docs/guide-user/services/vblade "docs:guide-user:services:vblade") vblade userspace AOE target [/etc/config/vnstat](/docs/guide-user/services/network_monitoring/vnstat "docs:guide-user:services:network_monitoring:vnstat") vnstat downloader settings [/etc/config/wifitoggle](/docs/guide-user/network/wifi/wifi_toggle "docs:guide-user:network:wifi:wifi_toggle") Toggle WiFi with a button [/etc/config/wol](/docs/guide-user/services/w_o_l/wol "docs:guide-user:services:w_o_l:wol") Wake-on-Lan: wol [/etc/config/znc](/docs/guide-user/services/proxy/znc "docs:guide-user:services:proxy:znc") ZNC bouncer configuration

## File syntax

The UCI configuration files usually consist of one or more `config` statements, so called sections with one or more option statements defining the actual values.

A `#` begins comments in the usual way. Specifically, if a line contains a `#` outside of a string literal, it and all characters after it in the line are considered a comment and ignored.

Below is an example of a simple configuration file (see also [uci\_dataobject\_model](#uci_dataobject_model "docs:guide-user:base-system:uci ↵")):

```
package 'example'
 
config 'example' 'test'
        option   'string'      'some value'
        option   'boolean'     '1'
        list     'collection'  'first item'
        list     'collection'  'second item'
```

- The `config 'example' 'test`' statement defines the start of a section with the type `example` and the name `test`. There can also be so called anonymous sections with only a type, but no name identifier. The type is important for the processing programs to decide how to treat the enclosed options.

<!--THE END-->

- The `option 'string' 'some value`' and `option 'boolean' '1`' lines define simple values within the section. Note that there are no syntactical differences between text and boolean options. Per convention, boolean options may have one of the values '0', 'no', 'off', 'false' or 'disabled' to specify a false value or '1' , 'yes', 'on', 'true' or 'enabled' to specify a true value.

<!--THE END-->

- In the lines starting with a `list` keyword an option with multiple values is defined. All `list` statements that share the same name, `collection` in our example, will be combined into a single list of values with the same order as in the configuration file.

<!--THE END-->

- The indentation of the `option` and `list` statements is a convention to improve the readability of the configuration file but it's not syntactically required.

<!--THE END-->

- If an option is absent and not required, the default value is assumed. If it is absent and required, it may trigger an error in the application or other unwanted behaviour.

<!--THE END-->

- A way to disable a config section, that does not have a `enabled` option to be disabled, is renaming the config section identifier (or type, in this case `example`) to a value not recognized by the processes that uses those values. Normally a `disabled_identifier` as config section type/identifier is sufficient.

Usually you do not need to enclose identifiers or values in quotes. Quotes are only required if the enclosed value contains spaces or tabs. Also it's legal to use double- instead of single-quotes when typing configuration options.

All of the examples below are valid UCI syntax:

```
option  example   value
option  example  "value"
option 'example'  value
option 'example' "value"
option "example" 'value'
```

In contrast, the following examples are not valid UCI syntax:

```
# missing quotes around the value
option  example   v_a l u-e
# unbalanced quotes
option 'example" "value'
```

It is important to know that UCI identifiers and config file names may contain only the characters `a-z`, `0-9` and `_`. E.g. no hyphens (`-`) are allowed. Option values may contain any character (as long they are properly quoted).

## Editor plugins

Syntax highlighting and (slightly) more in vim: [vim-uci](https://github.com/cmcaine/vim-uci "https://github.com/cmcaine/vim-uci") - works well with sshfs (need openssh-sftp-server).

## Command-line utility

For adjusting settings, one normally changes the UCI config files directly. However, for scripting purposes, all of UCI configuration can also be read and changed using the `uci` command line utility. For developers requiring automatic parsing of the UCI configuration, it is therefore redundant, unwise, and inefficient to use `awk` and `grep` to parse OpenWrt's config files. The `uci` utility offers all functionality with respect to modifying and parsing UCI.

Below is the usage, as well as some useful examples of how to use this powerful utility.

When using `uci` to write configuration files, the files are always rewritten in whole and non-recognised commands are omitted. This means that any extraneous lines in the file are deleted, such as comments. If you have UCI configuration files that you have edited yourself and you want to preserve your own comments and blank lines, you should not use the command line utility but edit the files normally. Note that some files, such as the uHTTPd configuration file, already contain many comments when the application is first installed. Also, note that some applications such as [LuCI](/docs/techref/luci "docs:techref:luci") also use the `uci` utility and thus may rewrite UCI configuration files.

When there are multiple sections of the same type in a config, UCI supports array-like references for them. If there are 8 NTP servers defined in `/etc/config/system`, UCI will let you reference their sections as `system.@timeserver[0]` for the first or `system.@timeserver[7]` for the last one. You can also use negative indexes, such as `system.@timeserver[-1]`. “-1” means the last one, “-2” means the second-to-last one, and so on. This comes in very handy when appending new rules to the end of a list. See the examples below.

### Usage

```
# uci
Usage: uci [<options>] <command> [<arguments>]

Commands:
	batch
	export     [<config>]
	import     [<config>]
	changes    [<config>]
	commit     [<config>]
	add        <config> <section-type>
	add_list   <config>.<section>.<option>=<string>
	del_list   <config>.<section>.<option>=<string>
	show       [<config>[.<section>[.<option>]]]
	get        <config>.<section>[.<option>]
	set        <config>.<section>[.<option>]=<value>
	delete     <config>.<section>[.<option>]
	rename     <config>.<section>[.<option>]=<name>
	revert     <config>[.<section>[.<option>]]
	reorder    <config>.<section>=<position>

Options:
	-c <path>  set the search path for config files (default: /etc/config)
	-d <str>   set the delimiter for list values in uci show
	-f <file>  use <file> as input instead of stdin
	-m         when importing, merge data into an existing package
	-n         name unnamed sections on export (default)
	-N         don't name unnamed sections
	-p <path>  add a search path for config change files
	-P <path>  add a search path for config change files and use as default
	-q         quiet mode (don't print error messages)
	-s         force strict mode (stop on parser errors, default)
	-S         disable strict mode
	-X         do not use extended syntax on 'show'
```

`Command` Target Description `commit` `[<config>]` Writes changes of the given configuration file, or if none is given, all configuration files, to the filesystem. All “uci set”, “uci add”, “uci rename” and “uci delete” commands are staged into a temporary location and written to flash at once with “uci commit”. This is not needed after editing configuration files with a text editor, but for scripts, GUIs and other programs working directly with UCI files. `batch` - Executes a multi-line UCI script which is typically wrapped into a *here* document syntax. `export` `[<config>]` Exports the configuration in a machine readable format. It is used internally to evaluate configuration files as shell scripts. `import` `[<config>]` Imports configuration files in UCI syntax. `changes` `[<config>]` List staged changes to the given configuration file or if none given, all configuration files. `add` `<config> <section-type>` Add an anonymous section of type `section-type` to the given configuration. `add_list` `<config>.<section>.<option>=<string>` Add the given string to an existing list option. `del_list` `<config>.<section>.<option>=<string>` Remove the given string from an existing list option. `show` `[<config>[.<section>[.<option>]]]` Show the given option, section or configuration in compressed notation. `get` `<config>.<section>[.<option>]` Get the value of the given option or the type of the given section. `set` `<config>.<section>[.<option>]=<value>` Set the value of the given option, or add a new section with the type set to the given value. `delete` `<config>.<section>[.<option>]` Delete the given section or option. `rename` `<config>.<section>[.<option>]=<name>` Rename the given option or section to the given name. `revert` `<config>[.<section>[.<option>]]` Revert the given option, section or configuration file. `reorder` `<config>.<section>=<position>` Move a section to another position.

Note that you cannot delete an entire config using `uci delete` eg. `uci delete umdns` will not work. If you are really, truly sure you want to wipe an entire config, this shell code snippet will do it by looping and deleting the first entry in the config until it is empty:

```
while uci -q delete umdns.@umdns[0]; do :; done
```

## UCI data/object model

### Elements

The elements in UCI model are:

- **config**: main configuration groups like **network**, **system**, **firewall**. Each configuration group has it's own file in **/etc/config**
- **sections**: config is divided into sections. A section can either be **named** or **unnamed**.
- **types**: a section can have a type. E.g in the network config we typically have 4 sections of the type “interface”. The sections are “lan”, “wan”, “loopback” and “wan6”
- **options**: each section have some options where you set your configuration values
- **values**: value of option

#### Sections naming

Sections deserve some extra explanation in regards to naming. A section can be *named* or *unnamed*. Unnamed sections will get an **autogenerated ID/CFGID** (like “cfg073777”) and be presented with an **anonymous-name** (like “@switch\[0]”)

Section names may only contain alphanum and “\_” (for shell compatibility). Hyphen '-' is not allowed.

Example of **anonymous-name**:

```
# uci show network
...
network.@switch[0]=switch
network.@switch[0].name='switch0'
network.@switch[0].reset='1'
network.@switch[0].enable_vlan='1'
...
```

Example of **autogenerated ID/CFGID**:

```
# uci show network.@switch[0]
network.cfg073777=switch
network.cfg073777.name='switch0'
network.cfg073777.reset='1'
network.cfg073777.enable_vlan='1'
```

#### Different presentation

The same config section can be presented in different ways:

- Human-friendly: as presented in the config files or with the command “uci export &lt;config&gt;”
- Programmable: as presented with the command “uci show &lt;config&gt;”

Different model presentations **Human-friendly**, named section (“uci export network”) **Human-friendly**, unnamed section (“uci export network”) ![](/_media/media/doc/howtos/uci_hr_named.png) ![](/_media/media/doc/howtos/uci_hr_unmaned.png) **Programmable**, named section (“uci show network.wan”) **Programmable**, unnamed section, anonymous name (“uci show network”) **Programmable**, unnamed section, CFGID (“uci show network.@switch\[0]”) ![](/_media/media/doc/howtos/uci_prg_named.png) ![](/_media/media/doc/howtos/uci_prg_unmaned_an.png) ![](/_media/media/doc/howtos/uci_prg_unmaned_cfgid.png)

### Examples

#### Setting a value

If we want to change the listening port of the [uHTTPd Web Server](/docs/guide-user/services/webserver/http.uhttpd "docs:guide-user:services:webserver:http.uhttpd") from 80 to 8080 we change the configuration in `/etc/config/uhttpd` :

```
uci set uhttpd.main.listen_http='8080'
uci commit uhttpd
/etc/init.d/uhttpd restart
```

Done, now the configuration file is updated and uHTTPd listens on port 8080.

#### Export an entire configuration

```
uci export configuration_name
```

Commonly available configurations are: **defaults**, **dnsmasq**, **dropbear**, **firewall**, **fstab**, **net**, **qos**, **samba**, **system**, **wireless**.

#### Show a configuration

```
uci show configuration_name
```

Here an example:

```
# uci show system 
system.@system[0]=system 
system.@system[0].hostname='OpenWrt' 
system.@system[0].timezone='UTC' 
system.ntp=timeserver 
system.ntp.server='0.openwrt.pool.ntp.org' '1.openwrt.pool.ntp.org' '2.openwrt.pool.ntp.org' '3.openwrt.pool.ntp.org' 
system.ntp.enabled='1' 
system.ntp.enable_server='0'
```

#### Display just the value of an option

```
uci get httpd.@httpd[0].port
```

#### Append an entry to a list

```
uci add_list system.ntp.server='0.de.pool.ntp.org'
```

#### Replace a list completely

```
uci delete system.ntp.server
uci add_list system.ntp.server='0.de.pool.ntp.org'
uci add_list system.ntp.server='1.de.pool.ntp.org'
uci add_list system.ntp.server='2.de.pool.ntp.org'
```

#### Adding a new anonymous section to configuration

```
uci add configuration_name section_type
```

It will generate a new unnamed section of type `section_type` inside the configuration called `configuration_name`. Afterwards you can add keys to this section as normal. The add command will print an auto generated alphanumeric section name that you can use for further adding keys to the newly added section.

Add a new firewall config section of type `rule` and refer to it by index:

```
uci add firewall rule
uci set firewall.@rule[-1].src='wan'
```

Add a new firewall config section of type `rule` and refer to it by its auto generated name:

```
sid=$(uci add firewall rule)
uci set firewall.$sid.src='wan'
```

#### Adding a named section to configuration

In order to add a named section of a given type, the option-less form of the `uci set` command must be used.

```
touch /etc/config/example
uci set example.this_name=blah
uci set example.this_name.xxx=yyy
uci set example.other_name=blah
uci set example.other_name.yyy=zzz
uci commit example
```

```
uci show example
```

```
example.this_name=blah
example.this_name.xxx=yyy
example.other_name=blah
example.other_name.yyy=zzz
```

```
cat /etc/config/example
```

```
config blah 'this_name'
    option xxx 'yyy'
    
config blah 'other_name'
    option xxx 'zzz'
```

#### Showing the not-yet-saved modified values

```
uci changes
```

#### Saving modified values of a single configuration

```
uci commit configuration_name 
reload_config
```

#### Saving all modified values

```
uci commit
reload_config
```

#### Generating a full UCI section with a simple copy-paste

This block of code catches the code printed by uci when you add a new section (see above) and reuses it in all the new keys you want to add after it. This automates what would be a very fun typing or copy-paste job. You can also do this in your scripts.

Generic version:

```
rule_name=$(uci add <config> <section-type>) 
uci batch << EOI
set <config>.$rule_name.<option1>='value'
set <config>.$rule_name.<option2>='value'
set <config>.$rule_name.<option3>='value'
...
EOI
uci commit
```

A working example:

```
rule_name=$(uci add firewall rule) 
uci batch << EOI
set firewall.$rule_name.enabled='1'
set firewall.$rule_name.target='ACCEPT'
set firewall.$rule_name.src='wan'
set firewall.$rule_name.proto='tcp udp'
set firewall.$rule_name.dest_port='111'
set firewall.$rule_name.name='NFS_share'
EOI
uci commit
```

#### UCI paths

Consider this example config file:

```
config bar 'first'
	option name	'Mr. First'
config bar
	option name	'Mr. Second'
config bar 'third'
	option name	'Mr. Third'
```

Then the paths below are equal in every group:

```
# Mr. First
uci get foo.@bar[0].name
uci get foo.@bar[-0].name
uci get foo.@bar[-3].name
uci get foo.first.name
 
# Mr. Second
uci get foo.@bar[1].name
uci get foo.@bar[-2].name
# uci get foo.second.name won't work; label 'second' undefined
 
# Mr. Third
uci get foo.@bar[2].name
uci get foo.@bar[-1].name
uci get foo.third.name
```

If you show it, you get :

```
# uci show foo
foo.first=bar
foo.first.name='Mr. First'
foo.@bar[0]=bar
foo.@bar[0].name='Mr. Second'
foo.third=bar
foo.third.name='Mr. Third'
```

But if you used `uci show foo.@bar[0]`, you will see:

```
# uci show foo.@bar[0]
foo.first=bar
foo.first.name='Mr. First'
```

#### Add a firewall rule

This is a good example of both adding a firewall rule to forward the TCP SSH port, and of the negative (-1) syntax used with uci.

```
uci add firewall rule
uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].target='ACCEPT'
uci set firewall.@rule[-1].proto='tcp'
uci set firewall.@rule[-1].dest_port='22'
uci commit firewall
/etc/init.d/firewall restart
```

#### Get SSID

```
uci get wireless.@wifi-iface[0].ssid
```

## Porting UCI to a different Linux distribution

See [UCI (Unified Configuration Interface) – Technical Reference](/docs/techref/uci#usage_outside_of_openwrt "docs:techref:uci")

## Corrupted configs

See also: [UCI extras](/docs/guide-user/advanced/uci_extras "docs:guide-user:advanced:uci_extras")

If you manually edited the configs in `/etc/config`, it is possible that some of them are corrupted due to typos.

```
# uci show fstab
uci: Parse error (invalid command) at line 20, byte 0
```
