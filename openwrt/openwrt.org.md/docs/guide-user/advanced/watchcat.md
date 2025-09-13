# Watchcat - network watchdog utility

Install the packages [watchcat](/packages/pkgdata/watchcat "packages:pkgdata:watchcat") and [luci-app-watchcat](/packages/pkgdata/luci-app-watchcat "packages:pkgdata:luci-app-watchcat").

Watchcat is a ping-watchdog utility that allows you to set up rules for when a ping to a particular host fails.

The following modes of operation are available

- **Ping Reboot**: reboot the OpenWrt device if a ping to a specific host fails
- **Restart Interface**: restart a network interface if a ping to a host over that interface fails
- **Periodic Reboot**: reboot at a set period of time, such as every 24h.

## Parameters

`mode` - the mode this watchcat instance is in.

- `ping_reboot`
- `restart_iface`
- `periodic_reboot`

`period` - the way this parameter is used depends on the mode watchcat is in:

- Periodic Reboot: the interval of time at which to perform the reboot, such as every 24h
- Ping Reboot: the longest interval of time without a successful ping before the rule is activated
- Restart Interface: the longest interval of time without a successful ping before the rule is activated

**Period examples**

- 10 seconds would be: `10` or `10s`
- 5 minutes would be: `5m`
- 1 hour would be: `1h`
- 1 week would be: `7d`

`pinghosts` - In Ping Reboot and Restart Interface modes, the host(s) to ping/monitor

`pingperiod` - how often to ping

**Ping Period examples**

- every 10 seconds would be: `10` or `10s`
- every 5 minutes would be: `5m`
- every 1 hour would be: `1h`
- every week would be: `7d`

`pingsize` - the size of packet to use for pings.

**Supported ping size values**

- `small` - 1 byte
- `windows` - 32 bytes
- `standard` - 56 bytes
- `big` - 248 bytes
- `huge` - 1492 bytes
- `jumbo` - 9000 bytes

`interface` - the interface to ping via, and also, in Restart Interface mode the one to restart. If unset, it will use the default route's interface.

**Interface examples**

- `eth1`
- `wwan0`

`forcedelay` - in Ping Reboot and Periodic Reboot modes, the amount of time to try a graceful reboot before a sysreq reboot is activated as a fail safe.

`mmifacename` - name of a ModemManager interface to restart - if set it will restart the ModemManager service when that interface goes down.

**Modem Manager Interface Name example**

- `mobiledata`

`unlockbands` - if set to 1 it will issue `mmcli -m any --set-current-bands=any` when the rule is activated

**Possible unlockbands values**

- `0` - disabled (default)
- `1` - enabled

Note `restart_iface` mode, `interface`, `pingsize`, `mmifacename` `unlockbands` parameters are available after commit: [https://github.com/openwrt/packages/commit/d5047303d6ad052f0249350a205015d149882e0e](https://github.com/openwrt/packages/commit/d5047303d6ad052f0249350a205015d149882e0e "https://github.com/openwrt/packages/commit/d5047303d6ad052f0249350a205015d149882e0e")

## Configuration Examples

The following are examples of a `config watchcat` stanza for a rule in the `/etc/config/watchcat` configuration file:

\- Ping host `192.168.1.1` (gateway) every `30s` (30 seconds) via the interface `eth1.1` and reboot if it fails for `5m` (5 minutes) or longer and wait up to `1m` (1 minute) for a soft reboot before requesting a hard reboot:

```
config watchcat
  option interface 'eth1.1'
  option period '5m'
  option mode 'ping_reboot'
  option pinghosts '192.168.1.1'
  option pingperiod '30s'
  option forcedelay '1m'
```

\- Reboot the device every `3d` (3 days) and wait up to `2m` (2 minutes) for a soft reboot before requesting a hard reboot:

```
config watchcat
  option mode 'periodic_reboot'
  option period '3d'
  option forcedelay '2m'
```
