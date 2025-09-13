# Etherwake configuration

See also: [Wake on LAN configuration](/docs/guide-user/services/w_o_l/wol "docs:guide-user:services:w_o_l:wol"), [Scheduling tasks](/docs/guide-user/base-system/cron "docs:guide-user:base-system:cron")

The configuration file `/etc/config/etherwake` is provided by the *etherwake* package and defines hosts to wake when starting the `/etc/init.d/etherwake` init script. Install the package [luci-app-wol](/packages/pkgdata/luci-app-wol "packages:pkgdata:luci-app-wol") to provide the web interface.

## Sections

There are two sections `setup` and `target` defined for the configuration. Multiple *wake on lan targets* may exist in the file.

### Setup

```
config 'etherwake' 'setup'
	option 'pathes' '/usr/bin/etherwake /usr/bin/ether-wake'
	option 'sudo' 'off'
	option 'interface' ''
	option 'broadcast' 'off'
```

Below is a listing of the parameters defined for this section.

Name Type Required Default Description `pathes` path ??? *(none)* path to etherwake binary (typo is normal) `sudo` boolean no `off` Etherwake usually requires sudo `interface` string yes *(none)* On which interface to send the WOL packages `broadcast` boolean no `off` ???

### Target

```
config 'target'
	option 'name' 'example' 	 # name for the target
	option 'mac' '11:22:33:44:55:66' # mac address to wake up 	
	option 'password' 'AABBCCDDEEFF' # password in hex without any delimiters
	option 'wakeonboot' 'off'	 # wake up on system start, defaults to off
```

Below is a listing of the parameters defined for this section.

Name Type Required Default Description `name` string no *(none)* name of the target `mac` MAC address yes *(none)* Specifies the MAC address of the host to wake `password` string no *(none)* Send given *SecureON* password when waking the host `wakeonboot` boolean no `off` Don't send WOL packet when booting OpenWrt

## Example

```
config 'etherwake' 'setup'
	option 'pathes' '/usr/bin/etherwake'
	option 'sudo' 'on'
	option 'interface' 'eth0.2'
	option 'broadcast' 'on'

config 'target'
	option 'name' 'popeye'
	option 'mac' '00:22:33:44:55:66'
	option 'password' 'AABBCCDDEEFF'   # password in hex without any delimiters
	option 'wakeonboot' 'off'
```

## Wake target

```
# Syntax
/etc/init.d/etherwake start <target>
 
# Wake up "popeye"
/etc/init.d/etherwake start popeye
```
