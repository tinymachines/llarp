# Wake on LAN configuration

The configuration file `/etc/config/wol` is provided by the *wol* package and defines hosts to wake when starting the `/etc/init.d/wol` init script. An alternative opkg-package is `etherwake`

Please see `/etc/crontabs/root` to configure `crond`.

## Sections

There is only one section type `wol-target` defined for the configuration. Multiple *wake on lan targets* may exist in the file.

### Wake on LAN targets

A `wol-target` section defines the parameters the *wol* utility is started with. The init script will start one instance of *wol* for each section of this type.

Below is a listing of the parameters defined for this section.

Name Type Required Default Description `mac` MAC address yes *(none)* Specifies the MAC address of the host to wake `broadcast` IPv4 address or hostname no `255.255.255.255` Specifies the target address magic packets are broadcasted to `port` integer no `40000` Specifies the UDP destination port for magic packets `password` string no *(none)* Send given *SecureON* password when waking the host `enabled` boolean no `1` Don't start *wol* for this section if set to `0`

## Example

Example entry to wake a host with the MAC address `00:06:29:4f:e4:b6` in the `192.168.0.0/24` subnet:

```
config wol-target
	option mac         '00:06:29:4f:e4:b6'
	option broadcast   '192.168.0.255'
	option enabled     '1'
```

## Notes

If *wol* does not work, the *etherwake* package can be used instead. To wake a host on boot, and put the following command into `/etc/rc.local`:

```
etherwake 00:0f:3d:ce:ef:ee
```

This would wake the host with the MAC address `00:0f:3d:ce:ef:ee`.
