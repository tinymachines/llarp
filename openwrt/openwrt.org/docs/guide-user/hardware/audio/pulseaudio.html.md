# PulseAudio

Read about [PulseAudio](https://en.wikipedia.org/wiki/PulseAudio "https://en.wikipedia.org/wiki/PulseAudio") and have a look at its operational flow chart: [File:Pulseaudio-diagram.svg](https://en.wikipedia.org/wiki/File:Pulseaudio-diagram.svg "https://en.wikipedia.org/wiki/File:Pulseaudio-diagram.svg").

## Preparations

### Routing

Routing describes the way which the Audio-Signal take when traversing your OS. Here a couple of routing configurations that make sense: (it is always a good idea to configure the soundsource (e.g. audio player) specifically to use the correct output interface)

The shortest path:

Device Soundsource → ALSA driver → Hardware

Many programs can communicate directly with PulseAudio:

Device Soundsource → PulseAudio → ALSA driver → Hardware

In case the sound source cannot communicate directly with PA, it takes a detour:

Device Soundsource → ALSA → PulseAudio → ALSA driver → Hardware

PulseAudio works over the network:

Device 1 ~ Device 2 Soundsource → PulseAudio → Network → PulseAudio → ALSA driver → Hardware

### Hardware

- Device 2 requires a [Sound card](https://en.wikipedia.org/wiki/Sound%20card "https://en.wikipedia.org/wiki/Sound card") (Hardware), Device 1 does not; [Loudspeaker](https://en.wikipedia.org/wiki/Loudspeaker "https://en.wikipedia.org/wiki/Loudspeaker")s are connected to the sound card

### Required Packages

- [pulseaudio-daemon](/packages/pkgdata/pulseaudio-daemon "packages:pkgdata:pulseaudio-daemon")
- [pulseaudio-profiles](/packages/pkgdata/pulseaudio-profiles "packages:pkgdata:pulseaudio-profiles")
- [pulseaudio-tools](/packages/pkgdata/pulseaudio-tools "packages:pkgdata:pulseaudio-tools")

### Official Documentation

- [manpage for PulseAudio](http://linux.die.net/man/1/pulseaudio "http://linux.die.net/man/1/pulseaudio")
- [pulseaudio](http://man.cx/pulseaudio "http://man.cx/pulseaudio")

## Configuration

With PulseAudio it's possible to send audio over the network. There are several ways to achieve that, here's the “tunnel”-approach described. For other solutions see the [PulseAudio wiki](http://pulseaudio.org/wiki/NetworkSetup "http://pulseaudio.org/wiki/NetworkSetup").

### Server configuration

For sound from the network, something like this is needed:

```
# /etc/pulse/system.pa
load-module module-alsa-sink
load-module module-native-protocol-tcp auth-anonymous=1
```

Most programs do not need the esound module because other ways to connect to pulseaudio server are available. (module-native,module-tunnel)

```
# /etc/pulse/system.pa
load-module module-esound-protocol-tcp auth-anonymous=1
```

**There is an issue ([#14175](https://dev.openwrt.org/ticket/14175 "https://dev.openwrt.org/ticket/14175")) with permissions in system mode with alsa. This is an workaround which does not support hotplug.** In system mode pulseaudio runs under user pulse but it does not have the permissions to access alsa.

```
cat << EOF >> /etc/init.d/pulseaudio
chown -R :51 /dev/snd
chmod -R g+rw /dev/snd
EOF
```

### Client configuration

You can enter network-sinks manually (which is described below).

![:!:](/lib/images/smileys/exclaim.svg) Automatic discovery with [Avahi/Zeroconf](/docs/guide-user/hardware/audio/pulseaudio#avahizeroconf "docs:guide-user:hardware:audio:pulseaudio") is disabled in the build system.

#### Linux

Load a new tunnel-sink:

```
pacmd load-module module-tunnel-sink server=<IP_OPENWRT>
```

Now it can be controlled with eg gnome-volume-control:

[![](/_media/doc/howto/gnome-volume-control.png)](/_detail/doc/howto/gnome-volume-control.png?id=docs%3Aguide-user%3Ahardware%3Aaudio%3Apulseaudio "doc:howto:gnome-volume-control.png")

To play one stream simultaneously to a local and a remote sink create a combined sink:

```
pacmd load-module module-combine sink_name=combined slaves="tunnel.<IP_OPENWRT>,alsa_output.usb-0ccd_0077-00-U0xccd0x77.analog-stereo"
pacmd set-default-sink combined
```

The local sink (in this case alsa\_output.usb-0ccd\_0077-00-U0xccd0x77.analog-stereo) can be obtained via pacmd:

```
# pacmd list-sinks | grep -e name:
        name: <alsa_output.pci-0000_00_1b.0.analog-stereo>
        name: <alsa_output.usb-0ccd_0077-00-U0xccd0x77.analog-stereo>
```

## Examples

## Notes

### MPD

#### Generalities

0.16.1 of MPD is needed. It needs to be build with support for PulseAudio:

```
Index: sound/mpd/Makefile
===================================================================
--- sound/mpd/Makefile  (Revision 25082)
+++ sound/mpd/Makefile  (Arbeitskopie)
@@ -63,7 +63,6 @@
        --disable-cue \
        --disable-jack \
        --disable-modplug \
-       --disable-pulse \
        --disable-sidplay \
        --disable-sqlite \
        --enable-shout \
```

#### Barrier Breaker and Chaos Calmer

More information on [building MPD-full with PulseAudio](/docs/guide-developer/build.mpd-full.pulse "docs:guide-developer:build.mpd-full.pulse")

### Avahi/ZeroConf

:![FIXME](/lib/images/smileys/fixme.svg): ![:!:](/lib/images/smileys/exclaim.svg) Not available in trunk

If you want to automatically discover new Pulseaudio devices on your network, you can install [pulseaudio-daemon-avahi](/packages/pkgdata/pulseaudio-daemon-avahi "packages:pkgdata:pulseaudio-daemon-avahi"). This will pull in dbus and avahi. You are then able to use padevchooser on the client to find and connect to Pulseaudio sinks in the local network.

```
opkg install pulseaudio-daemon-avahi
```

Add module-zeroconf-publish:

```
# /etc/pulse/system.pa
### Publish local soundcards on the network
load-module module-zeroconf-publish
```

Avahi-browse or avahi-discover on the client should list the sinks:

```
# avahi-browse -a
+  wlan0 IPv4 root@OpenWrt: Intel 82801DB-ICH4              PulseAudio Sound Sink local
+  wlan0 IPv4 root@OpenWrt                                  PulseAudio Sound Server local
+  wlan0 IPv4 Secure Shell on OpenWrt                       SSH-Fernzugriff      local
+  wlan0 IPv4 Music Player Daemon on OpenWrt                Music Player Daemon  local
```

Make sure module-zeroconf-discover is loaded on the client (pacmd load-module module-zeroconf-discover). The new sink should show up in gnome-control-center sound:

[![](/_media/doc/howto/gnome-control-center-sound.png)](/_detail/doc/howto/gnome-control-center-sound.png?id=docs%3Aguide-user%3Ahardware%3Aaudio%3Apulseaudio "doc:howto:gnome-control-center-sound.png")

### Issues

Some people experienced issues with fadvise (see [https://forum.openwrt.org/viewtopic.php?pid=118528#p118528](https://forum.openwrt.org/viewtopic.php?pid=118528#p118528 "https://forum.openwrt.org/viewtopic.php?pid=118528#p118528")). Building PulseAudio with ac\_cv\_func\_posix\_fadvise=no seems to help:

```
-       --without-caps 
+       --without-caps \ 
+       ac_cv_func_posix_fadvise=no
```

This seems to help on systems with low resources:

```
# /etc/pulse/daemon.conf
 
high-priority = yes
nice-level = -11
 
realtime-scheduling = yes
 
resample-method = trivial
 
default-sample-format = s16le
default-sample-rate = 48000
default-sample-channels = 2
default-channel-map = front-left,front-right
```

## Alternative configuration for forwarding sound

The approach taken above might not produce acceptable results depending on the hardware. It can lead to lagging, unpredictable, distorted sound. Here's a different method, that uses ssh to forward a tcp port from the client to the router and then uses socat to listen to this port on the router and connect it to pulseaudio's native Unix socket. The idea for this was found on [Joshua Tauberer’s Blog](http://razor.occams.info/blog/2009/02/11/pulseaudio-sound-forwarding-across-a-network/ "http://razor.occams.info/blog/2009/02/11/pulseaudio-sound-forwarding-across-a-network/").

### Required Packages

- [pulseaudio-daemon](/packages/pkgdata/pulseaudio-daemon "packages:pkgdata:pulseaudio-daemon")

### Server configuration

For sound from the network, something like this is needed:

```
# /etc/pulse/system.pa
load-module module-native-protocol-unix auth-anonymous=1
```

The module will already be in system.pa by default, just make sure that the auth-anonymous=1 option is given, to avoid an access denied error, when you later try to stream sound.

Sometimes it helps to start udevd before pulseaudio to avoid problems. Install the udev package, if you run into problems with pulseaudio.

```
udevd --daemon
```

If you still have problems, you can also try:

```
chmod 0777 /dev/snd/*
```

Pulseaudio also likes to complain that /var/lib/pulse is missing, so we create it:

```
mkdir -p /var/lib/pulse
```

Run pulseaudio as follows:

```
pulseaudio --system --disallow-module-loading --disallow-exit --no-cpu-limit &
```

It will complain that pulseaudio shouldn't be run in system mode, but on many routers this is the only mode that will actually work.

Now run socat to listen on the port that will be forwarded to the router and let it redirect to the native Unix socket that pulseaudio is using on the router:

```
socat TCP-LISTEN:4000,fork UNIX-CONNECT:/tmp/run/pulse/native &
```

You have to keep this running to keep the connection going.

You can put all of these commands in a script:

```
cat << "EOF" > /root/pulseaudioserver.sh
#!/bin/sh
udevd --daemon
chmod 0777 /dev/snd/*
mkdir -p /var/lib/pulse
pulseaudio --system --disallow-module-loading --disallow-exit --no-cpu-limit &
socat TCP-LISTEN:4000,fork UNIX-CONNECT:/tmp/run/pulse/native &
EOF
chmod +x /root/pulseaudioserver.sh
sed -i -e "
\$i /root/pulseaudioserver.sh
" /etc/rc.local
```

Pulseaudio should now be running after reboot.

### Client configuration

The first step is to forward a tcp port to the router using ssh. In this example we've decided to use port 4000.

```
ssh -f -N -L4000:localhost:4000 root@openwrt
```

Option `-f` puts the ssh session the background, because we don't need to actively work with the session anyways. Option `-N` let's ssh know that we don't want the shell to run any programs, since forwarding a port is all we want to do. Enter your root password and the port should be forwarded.

To actually stream sound over the network open a terminal and type

```
export PULSE_SERVER=localhost:4000
```

Any pulseaudio application started from that same terminal will automatically stream its sound over the network. Note that with this solution you won't see a second audio-output-device in pulseaudio-tools like padevchooser, so you can't move streams back and forth between devices.

If you don't want to type as much every time you are going to use the remote pulseaudio, you can add this to your ~/.bashrc:

```
function P {
	C=`netstat -ntap 2> /dev/null | grep -c ":4000"`
	if [ "$C" = "0" ]
	then
		ssh -f -N -L4000:localhost:4000 root@openwrt 2> /dev/null
	fi
	export PULSE_SERVER=localhost:4000
}
```

This will check wether the port is already forwarded and forward it if needed. Then it will set the PULSE\_SERVER environment variable, so that sound will be streamed over the network. All you have to type in a terminal is P.

Now you can do something like this to stream over the network:

```
P; mplayer *.ogg
```

Forwarding the port with ssh is not neccessary if your client can access the openWRT server directly (no firewall in between). For mpd you can use the following output configuration:

```
audio_output {
        type            "pulse"
        name            "openWRT Network Sink"
        server          "openWRT:4000"
        format          "48000:16:2"
}
```

For console applications you can simply set the PULSE\_SERVER environment variable:

```
export PULSE_SERVER='openWRT:4000'
```

## PulseAudio: Why software mixing?

“Many people wonder why have software mixing at all if you have hardware mixing? The thing is, hardware mixing is a thing of the past, modern soundcards don't do it anymore. Precisely for doing things like mixing in software SIMD CPU extensions like SSE have been invented. Modern sound cards these days are kind of “dumbed” down, high-quality [DACs](https://en.wikipedia.org/wiki/Digital-to-analog%20converter "https://en.wikipedia.org/wiki/Digital-to-analog converter"). They don't do mixing anymore, many modern chips don't even do volume control anymore. Remember the days where having a Wavetable chip was a killer feature of a sound card? Those days are gone, today wavetable synthesizing is done almost exclusively in software – and that's exactly what happened to hardware mixing too. And it is good that way. In software mixing is is much easier to do fancier stuff like DRC which will increase quality of mixing. And modern CPUs provide all the necessary SIMD command sets to implement this efficiently.” – [Lennart Poettering](http://0pointer.de/blog/projects/jeffrey-stedfast.html "http://0pointer.de/blog/projects/jeffrey-stedfast.html")
