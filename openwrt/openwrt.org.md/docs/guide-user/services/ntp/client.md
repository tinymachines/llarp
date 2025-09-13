# Ntpclient configuration

The `ntpclient` configuration file defines parameters for the [ntpclient](http://doolittle.icarus.com/ntpclient/ "http://doolittle.icarus.com/ntpclient/") program, a small daemon that will keep the local clock in sync with time servers on the internet.

## Sections

The configuration file consists of a section defining general daemon options, a section defining clock drift information, and one or more sections defining time server hosts to use.

### Ntpclient

The `ntpclient` section defines general daemon options. This is the default configuration for this section:

```
config 'ntpclient'
        option 'interval' '600'
```

The `ntpclient` section contains these settings:

Name Type Required Default Description `count` integer no `0` Number of time measurements to perform before exiting. `0` means to never stop. `interval` integer no `600` Seconds to pause between measurements, i.e. 10 minutes. It is usually neither necessary not helpful to reduce this number. `interface` text no *(none)* Default value for setting `interface` in `host` section.

### Drift

The `ntpdrift` section defines parameters to adjust the drift of the local clock so that it can run more accurately. Please see the [ntpclient HOWTO](http://doolittle.icarus.com/ntpclient/HOWTO "http://doolittle.icarus.com/ntpclient/HOWTO") on how to compute these parameters.

This is the default configuration for this section:

```
config 'ntpdrift'
        option 'freq' '0'
```

The `ntpclient` section contains these settings:

Name Type Required Default Description `freq` integer no *(none)* Frequency adjustment for the local clock.

## Hosts

To receive time, at least one host must be configured through a `host` section. OpenWrt will try the specified hosts in order, and use the first one that is responding to time requests. OpenWrt uses the [NTP Pool](http://www.pool.ntp.org/ "http://www.pool.ntp.org/") to locate a close-by time server.

These are the default hosts:

```
config 'ntpserver'
        option 'hostname' '0.openwrt.pool.ntp.org'
        option 'port'     '123'
 
config 'ntpserver'
        option 'hostname' '1.openwrt.pool.ntp.org'
        option 'port'     '123'
 
config 'ntpserver'
        option 'hostname' '2.openwrt.pool.ntp.org'
        option 'port'     '123'
 
config 'ntpserver'
        option 'hostname' '3.openwrt.pool.ntp.org'
        option 'port'     '123'
```

A `host` section contains these settings:

Name Type Required Default Description `hostname` string yes *(none)* Hostname of the NTP server. `port` integer no `123` Port number the NTP server is listening on. `interface` text no *(none)* Only test this host if the specified interfaces comes up.

## Ntpclient startup details

The ntpclient is started via the hotplug subsystem upon any network interface startup, see `/etc/hotplug.d/iface/20-ntpclient`. The script starts the daemon in 4 phases:

1. **preliminary test** - the script checks if the ntpclient is already running.
2. **drift** - the scripts sets the specified `drift` in system clock.
3. **ntp server check phase** - the script tests the reachability of the ntp servers (`hosts`) from config file (uses the ntpclient for this). The script only checks `hosts` where the specified `interface` (or inherited `interface` from `ntpclient` section) matches the interface that triggered `hotplug.d` or where no `interface` is specified at all. If no ntp server is reachable the script quits.
4. **operational phase** - the ntpclient is started with the first reachable `host` and user configuration options (`interval` etc.) of polling and time adjustment

## Ntpclient shutdown details

All instances of the ntpclient are killed via the hotplug subsystem upon any network interface shutdown, see `/etc/hotplug.d/iface/20-ntpclient`.
