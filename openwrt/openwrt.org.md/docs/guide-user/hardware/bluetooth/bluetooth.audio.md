# Bluetooth Audio

This wiki entry should enable you to play audio from a bluetooth source to an OpenWrt router that has sound output capabilities. It is working with: Android mobile (Sony Xperia M) as bluetooth source (use “Throw” in Walkman App) to an TI omap BeagleBoard (onboard soundcard, noname Bluetooth 2.1+ USB 1.1 micro dongle) as bluetooth/audio sink.

Required OpenWrt packages:

1. kmod-input-uinput (new)
2. pulseaudio 6
3. sbc library (new)
4. bluez5
5. dbus (because bluez5)

Hardware:

1. Bluetooth dongle
2. Bluetooth sender (Android mobile)

![:!:](/lib/images/smileys/exclaim.svg) Some USB Hardware on Routers does not support USB 1.1 (such Bluetooth dongles) directly attached to USB ports (2.0 devices only). You have to use an USB hub in this case.

## Foreword

Getting bluetooth to run is difficult. Bluetooth development is fast, not documented and there are issues with the bluez userspace development in general. \[1] So there are a ton of outdated documentation using bluez3 or bluez4. Using Audio with bluez5 requires DBUS and pulseaudio. Pulseaudio 6 supports bluez4 and blue5.

Recommended/Not in this guide: Python because the test tools make use of python. Test tools can supply legacy methods via commandline for pairing.

## Device Pairing

Bluetooth radio is disabled by default (“DOWN”). Enable bluetooth from commandline to make OpenWrt device discoverable.

```
hciconfig -a hci0
hciconfig -a hci0 up
hciconfig -a hci0 piscan
hciconfig -a hci0 sspmode enable
```

hciconfig -a output after commands

```
hci0:   Type: BR/EDR  Bus: USB
        BD Address: XX:XX:XX:XX:XX:XX  ACL MTU: 310:10  SCO MTU: 64:8
        UP RUNNING PSCAN ISCAN 
        RX bytes:6513036 acl:21980 sco:0 events:597 errors:0
        TX bytes:10451 acl:316 sco:0 commands:128 errors:0
        Features: 0xff 0xff 0x8f 0xfe 0x9b 0xff 0x59 0x83
        Packet type: DM1 DM3 DM5 DH1 DH3 DH5 HV1 HV2 HV3 
        Link policy: RSWITCH HOLD SNIFF PARK 
        Link mode: SLAVE ACCEPT 
        Name: 'BlueZOmap'
        Class: 0x0c0000
        Service Classes: Rendering, Capturing
        Device Class: Miscellaneous, 
        HCI Version: 2.1 (0x4)  Revision: 0x12e7
        LMP Version: 2.1 (0x4)  Subversion: 0x12e7
        Manufacturer: Cambridge Silicon Radio (10)
```

\*Name can be set via /etc/bluetooth/main.conf*

### Adding bluetooth source to trusted devices

You will see an entry like this

```
bluetoothd[2285]: Authentication attempt without agent
bluetoothd[2285]: Access denied: org.bluez.Error.Rejected
```

run

```
bluetoothctl
```

with

```
trust AA:BB:CC:DD:EE:FF
[CHG] Device AA:BB:CC:DD:EE:FF Trusted: yes
Changing AA:BB:CC:DD:EE:FF trust succeeded
```

AA:BB:CC:DD:EE:FF ... Bluetooth device mac that is audio source (mobile)

## dbus access control

add entry to a policy section in /etc/dbus-1/system.d/**bluetooth**.conf:

```
...
<policy user="root">
...
    <allow send_type="method_call"/>
    <allow send_type="method_return"/>
</policy>
...
```

add entry to a policy section in /etc/dbus-1/system.d/**pulseaudio**.conf:

```
	<allow send_type="method_call"/>
	<allow send_type="method_return"/>
```

## Problems

1. Reloading daemons might be necessary
2. Check logread or run daemons in foreground with multiple SSH connections

### bluetooth debugging

Bluetoothd can run in foreground with very verbose debugging.

```
bluetoothd -n -d
```

```
Note multiple arguments to -d can be specified, colon, comma or space
separated. The arguments are relative source code filenames for which
debugging output should be enabled; output shell-style globs are
accepted (e.g.: 'plugins/*:src/main.c').
```

### sound debugging

Pulseaudio can run in foreground. See /etc/init.d/pulseaudio for commandline arguments

Pulseaudio runs in system mode. This is unsupported and you should check access rights (group &amp; module parameters) ![:!:](/lib/images/smileys/exclaim.svg) The main problem is that bluetooth devices appear &amp; disappear from playback. This might require to allow runtime module loading permanently.

Check if you have pulseaudio output with

```
paplay <filename>
```

Check access rights via /etc/group

```
pulse-rt:x:53:
pulse-access:x:54:root
```

![:!:](/lib/images/smileys/exclaim.svg) and see pulse-access group added as module parameter below

Check if you have error when loading modules. For this guide allow module loading by removing

```
 --disallow-module-loading
```

from /etc/init.d/pulseaudio ![:!:](/lib/images/smileys/exclaim.svg) Security risk

Check if you load the right modules in /etc/pulse/system.pa

```
#!/usr/bin/pulseaudio -nF
#
# This file is part of PulseAudio.

### Automatically load driver modules depending on the hardware available
.ifexists module-detect.so

### Use the static hardware detection module (for systems that lack udev/hal support)
load-module module-detect
.endif

### Automatically restore the volume of streams and devices
load-module module-stream-restore
load-module module-device-restore
load-module module-card-restore


### Automatically restore the default sink/source when changed by the user
### during runtime
### NOTE: This should be loaded as early as possible so that subsequent modules
### that look up the default sink/source get the right value
# load-module module-default-device-restore

### Bluetooth
load-module module-bluetooth-discover
load-module module-bluetooth-policy

load-module module-zeroconf-publish

### Should be after module-*-restore but before module-*-detect
load-module module-switch-on-port-available

### Automatically move streams to the default sink if the sink they are
### connected to dies, similar for sources
load-module module-rescue-streams

### Make sure we always have a sink around, even if it is a null sink.
load-module module-always-sink

### Honour intended role device property
load-module module-intended-roles

### Automatically suspend sinks/sources that become idle for too long
load-module module-suspend-on-idle

### Enable positioned event sounds
load-module module-position-event-sounds

### Load several protocols
.ifexists module-esound-protocol-unix.so
load-module module-esound-protocol-unix
.endif
load-module module-native-protocol-unix auth-group=pulse-access

### Load the RTP receiver module (also configured via paprefs, see above)
load-module module-rtp-recv

### Load the RTP sender module (also configured via paprefs, see above)
load-module module-null-sink sink_name=rtp format=s16be channels=2 rate=44100 sink_properties="device.description='RTP Multicast Sink'"
load-module module-rtp-send source=rtp.monitor

### Modules to allow autoloading of filters (such as echo cancellation)
### on demand. module-filter-heuristics tries to determine what filters
### make sense, and module-filter-apply does the heavy-lifting of
### loading modules and rerouting streams.
load-module module-filter-heuristics
load-module module-filter-apply

#load-module module-loopback source=bluez_source.AA_BB_CC_DD_EE_FF sink=_name=alsa_output.0.analog-stereo rate=44100 adjust_time=0
```

You can load modules with **pactl**

### uinput missing

If you dont have kmod-input-uinput installed you will see errors like

```
Wed Apr  1 14:53:21 2015 daemon.err bluetoothd[2285]: AVRCP: failed to init uinput for AA:BB:CC:DD:EE:FF
```

Successful kmod-input-uinput message

```
kern.info kernel: [  681.020385] input: AA:BB:CC:DD:EE:FF as /devices/virtual/input/input2
bluetoothd[2530]: profiles/audio/avctp.c:init_uinput() AVRCP: uinput initialized for AA:BB:CC:DD:EE:FF
```

![:!:](/lib/images/smileys/exclaim.svg) You should see start/stop messages in the log whe you start/stop playback.

![:!:](/lib/images/smileys/exclaim.svg) If you have no sound at this point check pulseaudio settings (modules!), reload pulseaudio, enable the audio sink

## TODO

1. commandline / uci foo
2. role of /var/lib/bluetooth/nn:nn:nn:nn:nn:nn/ with devices
3. Headset buttons/ uinput: /etc/modules-load.d/uinput.conf

## Links and Documentation

- [pulseaudio modules](http://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/Modules "http://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/Modules")
