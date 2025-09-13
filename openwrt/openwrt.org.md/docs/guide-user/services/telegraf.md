# Telegraf

Telegraf is a plugin-driven agent for collecting and sending metrics and events. It supports various inputs (including Prometheus endpoints) and can send data into InfluxDB. More inforamtion on telegraf's website: [https://www.influxdata.com/time-series-platform/telegraf/](https://www.influxdata.com/time-series-platform/telegraf/ "https://www.influxdata.com/time-series-platform/telegraf/")

## Installation

At the [20th of October](https://github.com/openwrt/packages/pull/16238#event-5493323261 "https://github.com/openwrt/packages/pull/16238#event-5493323261") the first telegraf was merged into the package repository. If you use the openwrt snapshot packages, you can install `telegraf` with the following commands.

To install the full version use the package `telegraf-full`.

```
opkg install telegraf-full
```

To use a smaller version (around 27M when installing with \`opkg\` and around 6M when including into squashfs) use the package \`telegraf\`

```
opkg install telegraf
```

The reduced version includes:

**Aggregators**:

- None

**Inputs**:

- cpu
- ethtool
- internal
- interrupts
- ipset
- iptables
- kernel
- mem
- net
- net\_response
- ping
- processes
- procstat
- prometheus
- sensors
- snmp
- socket\_listener
- swap
- syslog
- system
- tail
- tcp\_listener
- udp\_listener
- wireguard
- wireless

**Outputs**:

- exec
- file
- graphite
- http
- influxdb
- prometheus\_client
- syslog

**Processors**:

- None

## Configuration

Since version `1.20.3` the configuration file is stored at `/etc/telegraf.conf`. By default, the provided telegraf configuration file is deployed. You can find it [here](https://github.com/influxdata/telegraf/blob/master/etc/telegraf.conf "https://github.com/influxdata/telegraf/blob/master/etc/telegraf.conf") or in the package.

Changes in the configuration file will not be overwritten by updates of the package.

After changing the configuration the service needs to be restarted or you can reload the configuration.

To test the current configuration the following command can be used:

```
telegraf --test --config /etc/telegraf.conf
```

To limit the test to a specific plugin use:

```
telegraf --test --config /etc/telegraf.conf --input-filter <FILTER-NAME>  --output-filter <FILTER-NAME>
```

For the further configuration see the official telegraf [documentation](https://docs.influxdata.com/telegraf/v1.21/ "https://docs.influxdata.com/telegraf/v1.21/").

### Manage service

The telegraf service is managed via a `init.d` script.

The following command are available:

- start
- stop
- restart
- enable (autostart on bootup)
- disable (autostart on bootup)
- reload (configuration)

```
/etc/init.d/telegraf <COMMAND>
```
