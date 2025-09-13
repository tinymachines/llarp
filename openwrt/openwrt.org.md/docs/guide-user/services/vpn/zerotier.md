# Zerotier

Zerotier creates a virtual network between hosts. You may refer to [zerotier-openwrt's official Wiki](https://github.com/mwarning/zerotier-openwrt/wiki "https://github.com/mwarning/zerotier-openwrt/wiki") for the latest instructions.

## Installation

```
opkg update
opkg install zerotier
```

## Basic Configuration

- Create virtual network on [Zerotier Central](https://my.zerotier.com "https://my.zerotier.com"). Note the 16-digit *Network ID*.
- Add virtual network to the OpenWrt Zerotier config (the section name `mynet` is arbitrary, you can consistently replace it with whatever label you want)

For ZeroTier version 1.14.0 or older:

```
uci delete zerotier.sample_config
uci add zerotier mynet
uci add_list zerotier.mynet.join=<network_id>
uci set zerotier.mynet.enabled='1'
uci commit zerotier
service zerotier restart
```

For ZeroTier version 1.14.1 or newer:

```
uci set zerotier.global.enabled='1'
uci delete zerotier.earth
uci set zerotier.mynet=network
uci set zerotier.mynet.id=<network_id>
uci commit zerotier
service zerotier restart
```

The same defined in the configuration file (`/etc/config/zerotier`):

```
config zerotier 'global'
        option enabled '1'
        option secret ''

config network 'mynet'
        option id 'put your network id here'
        option allow_managed '1'
        option allow_global '0'
        option allow_default '0'
        option allow_dns '0'
```

- When a new virtual network is joined, a new *secret* will be generated, which may take a while. When it's finished, the *secret* will be saved in `/etc/config/zerotier`, and router will make an attempt to attach to the virtual network.
- To use the virtual network, the device must be first authorized on Zerotier Central portal by clicking “Auth?” box next to the device under Members.
- Communication with other Zerotier nodes is usually done through port 9993/udp (it can be changed), and no additional configuration is needed for an out-of-the-box router configuration.
- Device connectivity (or online status) can be seen by using the “info” command, it will also show your 10-digit node address:

```
root@OpenWrt# zerotier-cli info
200 info xxxxxxxxxx 1.14.1 ONLINE
```

- Some services (eg dropbear, Luci) may need to be reconfigured to allow access from the new Zerotier virtual interface. The easy way is to un-restrict them from specific networks/interfaces.
  
  - For dropbear (allow access from anywhere, potentially unsafe):

```
root@OpenWrt# cat /etc/config/dropbear

config dropbear
	option PasswordAuth 'on'
	option Port '22'
```

![:!:](/lib/images/smileys/exclaim.svg) You must reboot OpenWrt router at this point otherwise `ztXXXXXXXX` network device won't be created.

After reboot get the device name using your 16-digit Network ID:

```
root@OpenWrt# zerotier-cli get {network_id} portDeviceName
ztXXXXXXXX
```

Alternatively run `zerotier-cli listnetworks`, that will give you the same name plus more details.

```
# Create interface
uci -q delete network.ZeroTier
uci set network.ZeroTier=interface
uci set network.ZeroTier.proto='none'
uci set network.ZeroTier.device='ztXXXXXXXX' # Replace ztXXXXXXXX with your own ZeroTier device name
 
# Configure firewall zone
uci add firewall zone
uci set firewall.@zone[-1].name='vpn'
uci set firewall.@zone[-1].input='ACCEPT'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='ACCEPT'
uci set firewall.@zone[-1].masq='1'
uci add_list firewall.@zone[-1].network='ZeroTier'
uci add firewall forwarding
uci set firewall.@forwarding[-1].src='vpn'
uci set firewall.@forwarding[-1].dest='lan'
uci add firewall forwarding
uci set firewall.@forwarding[-1].src='vpn'
uci set firewall.@forwarding[-1].dest='wan'
uci add firewall forwarding
uci set firewall.@forwarding[-1].src='lan'
uci set firewall.@forwarding[-1].dest='vpn'
 
# Commit changes
uci commit
 
# Reboot
reboot
```

## Advanced Configuration

The [sample configuration](https://github.com/openwrt/packages/blob/master/net/zerotier/files/etc/config/zerotier "https://github.com/openwrt/packages/blob/master/net/zerotier/files/etc/config/zerotier") is helpful to see which uci options are available for configuring the ZeroTier client.

While basic uci configuration of ZeroTier as shown above is supported, almost no advanced configuration support via uci has yet been added. The ZeroTier documentation requires manipulation of the configuration files for many advanced features. However, ZeroTier configurations are stored by default under /var/lib in Linux-based systems, which is a temporary filesystem in OpenWrt, where changes are not persistent. Instead, ordinarily OpenWrt writes a new configuration folder in that location based on the uci configuration above each time the service is started. These configuration files are lost on reboot or service restart, and rewritten each time the service starts again. For a basic configuration which will suit most users, this is not an issue.

In order to configure advanced features, two uci directives may be used to configure OpenWrt to load a copy of a persistent configuration folder from another location when starting the service, such as /etc/zerotier, which the user must first create and populate based on the simple copy made upon first joining a network. Once this persistent location is configured, the user may make persistent changes according to the ZeroTier documentation, with support for all current features otherwise enabled.

- Complete the basic configuration steps above to joint a working network, which will create a temporary copy of the configuration folder with which to start.
- Create the persistent folder in any permanent location (/etc/zerotier will be used for this example), and copy the contents of the temporary folder to the permanent location:

```
mkdir /etc/zerotier
cp -r /var/lib/zerotier-one/* /etc/zerotier/
```

- Add the directives to use the new persistent folder. The network name *deadbeef00* will be used, similar to most ZeroTier documentation examples:

```
uci set zerotier.deadbeef00.config_path='/etc/zerotier'
uci set zerotier.deadbeef00.copy_config_path='1'
uci commit zerotier
service zerotier restart
```

The router will now refer to the configuration in /etc/zerotier for persistent advanced changes. Restarting the service after any configuration changes using the last line above will reset and apply any changes made. Do not attempt to edit the configuration in the /var/lib/zerotier-one location, as this temporary location will still be overwritten on restart by the configuration in the new persistent directory.

### Local Configuration Options

ZeroTier client in OpenWrt also supports the use of “Local Configuration Options” described in the official [ZeroTier Documentation](https://docs.zerotier.com/config/#local-configuration-options "https://docs.zerotier.com/config/#local-configuration-options"). What is called `local.conf` in the documentation can be used in OpenWrt by adding a line like this into “global” section of the main configuration file (`/etc/config/zerotier`):

```
option local_conf_path '/etc/zerotier.conf'
```

The configuration file referenced there should be in JSON format. The following example will instruct the local instance of ZeroTier to not use LAN and WireGuard interfaces to build the connections:

```
{
	"settings": {
		"interfacePrefixBlacklist": [ "br","wg" ]
	}
}
```
