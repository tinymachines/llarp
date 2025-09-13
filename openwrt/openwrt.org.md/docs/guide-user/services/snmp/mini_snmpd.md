# Minimal SNMP Daemon (mini\_snmpd) configuration

The *mini\_snmpd* configuration is located in `/etc/config/mini_snmpd`. This configuration is responsible for defining basic snmp attributes, such as *location*, *contact*, *community* and snmp tables for *disks* and *interfaces*. This daemon reports only 32bit counters (Counter32).

## Sections

Configuration consists of single section called *mini\_snmpd*.

The default configuration defines following settings:

```
config mini_snmpd
        option enabled          '0'
        option ipv6             '0'
        option community        'public'
        option location         ' '
        option contact          ' '
        list disks              '/tmp'
        list disks              '/jffs'
        list interfaces         'lo'
        list interfaces         'br-lan'
        list interfaces         'br-wan' # Max 4
```

- `enabled` defines if daemon should be started on by rc script
- `ipv6` enables daemon's support of ipv6 sockets - it will listen on :::161 instead of 0.0.0.0:161
- `community` sets SNMP community string
- `location` and `contact` set those base SNMP attributes
- `disks` and `interfaces` specifies which filesystems and interfaces should be referenced by corresponding management tables.
- `sysName` is set automatically from the Hostname on the main System page of the web GUI

Name Type Required Default Description `enabled` boolean yes `0` Switches daemon on or off in rc (init.d) script `ipv6` boolean no `0` Enables daemon's support of ipv6 sockets `community` string yes `public` Sets SNMP Community string to contact this agent `location` string no *(none)* If defined, sets *location* OID which *mini\_snmpd* reports `contact` string no *(none)* If defined, sets *contact* OID wchi *mini\_snmpd* reports `disks` list of filesystems' mountpoints no *(none)* If defined, *mini\_snmpd* includes this filesystem in output table `interfaces` list of network interfaces no *(none)* If defined, *mini\_snmpd* includes this interfaces in output table

## Examples

*Simple example:* enable daemon, excluding ipv6 support, defining other parameters.

```
config mini_snmpd
	option enabled 1
	option ipv6 0
	option community public
	option location ''
	option contact ''
	option disks '/tmp,/jffs'
	option interfaces 'wlan0,br-lan,eth0.1,eth0' # Max 4
```

Example of the `snmpwalk`:

```
$ snmpwalk -m ALL -v 2c -c public 192.168.1.1 
SNMPv2-MIB::sysDescr.0 = STRING: 
SNMPv2-MIB::sysObjectID.0 = OID: SNMPv2-SMI::enterprises
DISMAN-EVENT-MIB::sysUpTimeInstance = Timeticks: (17915) 0:02:59.15
SNMPv2-MIB::sysContact.0 = STRING: 
SNMPv2-MIB::sysName.0 = STRING: OpenWrt
SNMPv2-MIB::sysLocation.0 = STRING: 
RFC1213-MIB::ifNumber.0 = INTEGER: 4
RFC1213-MIB::ifIndex.1 = INTEGER: 1
RFC1213-MIB::ifIndex.2 = INTEGER: 2
RFC1213-MIB::ifIndex.3 = INTEGER: 3
RFC1213-MIB::ifIndex.4 = INTEGER: 4
RFC1213-MIB::ifDescr.1 = STRING: "wlan0"
RFC1213-MIB::ifDescr.2 = STRING: "br-lan"
RFC1213-MIB::ifDescr.3 = STRING: "eth0.1"
RFC1213-MIB::ifDescr.4 = STRING: "eth0"
RFC1213-MIB::ifOperStatus.1 = INTEGER: up(1)
RFC1213-MIB::ifOperStatus.2 = INTEGER: up(1)
RFC1213-MIB::ifOperStatus.3 = INTEGER: up(1)
RFC1213-MIB::ifOperStatus.4 = INTEGER: up(1)
RFC1213-MIB::ifInOctets.1 = Counter32: 19574486
RFC1213-MIB::ifInOctets.2 = Counter32: 18252147
RFC1213-MIB::ifInOctets.3 = Counter32: 124204634
RFC1213-MIB::ifInOctets.4 = Counter32: 126247040
RFC1213-MIB::ifInUcastPkts.1 = Counter32: 91002
RFC1213-MIB::ifInUcastPkts.2 = Counter32: 90354
RFC1213-MIB::ifInUcastPkts.3 = Counter32: 113467
RFC1213-MIB::ifInUcastPkts.4 = Counter32: 113467
RFC1213-MIB::ifInDiscards.1 = Counter32: 0
RFC1213-MIB::ifInDiscards.2 = Counter32: 0
RFC1213-MIB::ifInDiscards.3 = Counter32: 0
RFC1213-MIB::ifInDiscards.4 = Counter32: 0
RFC1213-MIB::ifInErrors.1 = Counter32: 0
RFC1213-MIB::ifInErrors.2 = Counter32: 0
RFC1213-MIB::ifInErrors.3 = Counter32: 0
RFC1213-MIB::ifInErrors.4 = Counter32: 0
RFC1213-MIB::ifOutOctets.1 = Counter32: 127834842
RFC1213-MIB::ifOutOctets.2 = Counter32: 125363371
RFC1213-MIB::ifOutOctets.3 = Counter32: 19332841
RFC1213-MIB::ifOutOctets.4 = Counter32: 20197296
RFC1213-MIB::ifOutUcastPkts.1 = Counter32: 112239
RFC1213-MIB::ifOutUcastPkts.2 = Counter32: 111021
RFC1213-MIB::ifOutUcastPkts.3 = Counter32: 85992
RFC1213-MIB::ifOutUcastPkts.4 = Counter32: 88600
RFC1213-MIB::ifOutDiscards.1 = Counter32: 0
RFC1213-MIB::ifOutDiscards.2 = Counter32: 0
RFC1213-MIB::ifOutDiscards.3 = Counter32: 0
RFC1213-MIB::ifOutDiscards.4 = Counter32: 0
RFC1213-MIB::ifOutErrors.1 = Counter32: 0
RFC1213-MIB::ifOutErrors.2 = Counter32: 0
RFC1213-MIB::ifOutErrors.3 = Counter32: 0
RFC1213-MIB::ifOutErrors.4 = Counter32: 0
HOST-RESOURCES-MIB::hrSystemUptime.0 = Timeticks: (1547471) 4:17:54.71"
```

As you see walk doesn't catch on disks for some reason.

**Under Construction!**  
This page is currently under construction. You can edit the article to help completing it.
