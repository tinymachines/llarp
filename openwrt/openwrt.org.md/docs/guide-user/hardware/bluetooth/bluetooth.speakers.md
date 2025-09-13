# Bluetooth Speakers/Headphones

OpenWrt is a Linux distribution which is geared towards networking on routers. However, some of the travel routers which can run OpenWrt, are ideal portable music servers which can be connected to Bluetooth headphones and speakers which can play and control music from an OpenWrt Router. The [HooToo TM03](/toh/hwdata/hootoo/hootoo_ht-tm03_tripmate_mini "toh:hwdata:hootoo:hootoo_ht-tm03_tripmate_mini") is one of the travel routers which is an ideal portable music player.

- It fits is the palm of your hand
- It has a USB A port which you can use to connect a USB Bluetooth dongle
- It has a MicroSD slot which allows for continuous operation with an [overlay](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration") file system.
- It contains a 3000mAh battery for easy portable operation.

This has been tested with OpenWrt 18.06.4 running on a [HooToo TM03](/toh/hwdata/hootoo/hootoo_ht-tm03_tripmate_mini "toh:hwdata:hootoo:hootoo_ht-tm03_tripmate_mini") and [RAVPower RP-WD02](/toh/ravpower/rp-wd02 "toh:ravpower:rp-wd02") with a MicroSD card [overlay](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration") file systems with a [Plugable](https://www.newegg.com/p/1B4-00M5-00031?Description=USB%20Bluetooth%20dongle&cm_re=USB_Bluetooth%20dongle-_-9SIA2XB39D1325-_-Product "https://www.newegg.com/p/1B4-00M5-00031?Description=USB%20Bluetooth%20dongle&cm_re=USB_Bluetooth%20dongle-_-9SIA2XB39D1325-_-Product") USB Bluetooth dongle. The microSD card also contains a 128MB [swap](/docs/guide-user/storage/fstab#the_swap_sections "docs:guide-user:storage:fstab") partition.

#### Notes

- OpenWrt 18.06.1 Bluetooth does not work correctly
- Do not use OpenWrt 19.xx.xx with the [HooToo TM03](/toh/hwdata/hootoo/hootoo_ht-tm03_tripmate_mini "toh:hwdata:hootoo:hootoo_ht-tm03_tripmate_mini") or [RAVPower RP-WD02](/toh/ravpower/rp-wd02 "toh:ravpower:rp-wd02") since the kernel has been compiled to no longer support [overlay](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration") file systems with these devices.
- Although you can connect multiple Bluetooth devices simultaneously, the [HooToo TM03](/toh/hwdata/hootoo/hootoo_ht-tm03_tripmate_mini "toh:hwdata:hootoo:hootoo_ht-tm03_tripmate_mini") or [RAVPower RP-WD02](/toh/ravpower/rp-wd02 "toh:ravpower:rp-wd02") do not have enough horsepower to drive Bluetooth speakers/headphones and [tethering](/docs/guide-user/hardware/bluetooth/bluetooth.tether "docs:guide-user:hardware:bluetooth:bluetooth.tether") simultaneously.

### Required OpenWrt packages:

Your OpenWrt router configured with an [overlay](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration") file system.

01. kmod-input-uinput
02. bluez-daemon
03. bluez-utils
04. dbus
05. dbus-utils
06. pulseaudio-daemon-avahi
07. pulseaudio-profiles
08. pulseaudio-tools
09. mpd-full
10. mpc
11. madplay
12. inotifywait
13. gawk
14. grep
15. kmod-6lowpan
16. kmod-bluetooth\_6lowpan
17. wget

This should result in the installation of other dependencies including the USB packages.

#### Notes

- Since there is no OpenWrt bluezalsa package, we will use pulseaudio.
- Since the `mpd-mini` package does not support `pipe` or pulseaudio, we are forced to install the `mpd-full` package which does not support pulseaudio either, but does support `pipe` which we can use with the pulsaudio `pacat` utility.

### Modify Default Configuration files

#### /etc/bluetooth/main.conf

In `/etc/bluetooth/main.conf`, change the last line to `AutoEnable=true`

#### /etc/pulse/system.pa

Modify `/etc/pulse/system.pa` to look as below.

```
#!/usr/bin/pulseaudio -nF
#
# This file is part of PulseAudio.

load-module module-stream-restore
load-module module-device-restore
load-module module-card-restore

load-module module-bluez5-discover
load-module module-bluetooth-policy

load-module module-switch-on-port-available

load-module module-rescue-streams

load-module module-always-sink

load-module module-suspend-on-idle

load-module module-native-protocol-unix auth-group=pulse-access
```

#### /etc/dbus-1/system.d/bluetooth.conf

In `/etc/dbus-1/system.d/bluetooth.conf`, add

```
    <allow send_type="method_call"/>
    <allow send_type="method_return"/>
```

to the `root` policy block. The `root` policy block should now look like

```
  <policy user="root">
    <allow own="org.bluez"/>
    <allow send_destination="org.bluez"/>
    <allow send_interface="org.bluez.Agent1"/>
    <allow send_interface="org.bluez.MediaEndpoint1"/>
    <allow send_interface="org.bluez.MediaPlayer1"/>
    <allow send_interface="org.bluez.Profile1"/>
    <allow send_interface="org.bluez.GattCharacteristic1"/>
    <allow send_interface="org.bluez.GattDescriptor1"/>
    <allow send_interface="org.bluez.LEAdvertisement1"/>
    <allow send_interface="org.freedesktop.DBus.ObjectManager"/>
    <allow send_interface="org.freedesktop.DBus.Properties"/>
    <allow send_type="method_call"/>
    <allow send_type="method_return"/>
  </policy>
```

#### /etc/dbus-1/system.d/pulseaudio-system.conf

Modify `/etc/dbus-1/system.d/pulseaudio-system.conf` to look as below

```
<?xml version="1.0"?><!--*-nxml-*-->
<!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">

<!--
This file is part of PulseAudio.

PulseAudio is free software; you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation; either version 2.1 of the
License, or (at your option) any later version.

PulseAudio is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General
Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with PulseAudio; if not, see <http://www.gnu.org/licenses/>.
-->

<busconfig>

  <!-- System-wide PulseAudio runs as 'pulse' user. This fragment is
       not necessary for user PulseAudio instances. -->

  <policy user="pulse">
    <allow own="org.pulseaudio.Server"/>
    <allow send_type="method_call"/>
    <allow send_type="method_return"/>
  </policy>

</busconfig>
```

#### /etc/passwd

Make sure that `/etc/passwd` has the following entry.

```
pulse:x:51:51:pulse:/var/run/pulse:/bin/false
```

#### /etc/group

Make sure that `/etc/group` has the following entries.

```
pulse:x:51:pulse:root
pulse-rt:x:53:
pulse-access:x:54:root
```

#### /etc/init.d/pulseaudio

Modify `/etc/init.d/pulseaudio` to look as below.

```
#!/bin/sh /etc/rc.common
# Copyright (C) 2011 OpenWrt.org

START=99
STOP=65

USE_PROCD=1
PROG=/usr/bin/pulseaudio

start_service() {
	[ -d /var/run/pulse ] || {
		mkdir -m 0755 -p /var/run/pulse
		chmod 0750 /var/run/pulse
		chown pulse:pulse /var/run/pulse
	}
	[ -d /var/lib/pulse ] || {
		mkdir -m 0755 -p /var/lib/pulse
		chmod 0750 /var/lib/pulse
		chown pulse:pulse /var/lib/pulse
	}

	
	procd_open_instance
	procd_set_param command $PROG --system --disallow-exit --disable-shm --exit-idle-time=-1 --realtime=false
	procd_close_instance
}
```

### Pair, Trust and Connect Bluetooth Speaker/Headphones

While logged into your OpenWrt device, type in the command `bluetoothctl`.

Make sure that your Bluetooth speaker/headphones is in pairing mode and then issue the command `scan on`.

Wait for your speaker/headphones Bluetooth MAC address to appear and then type `pair XX:XX:XX:XX:XX:XX` where XX represents the Bluetooth MAC address of your speaker/headphones. For example, for my VERSE headphones, I type `pair 1C:A0:D3:D2:AE:75` and accept any pins.

When your speaker/headphones has paired successfully, type `connect XX:XX:XX:XX:XX:XX` where XX represents the Bluetooth MAC address of your speaker/headphones. For example, for my VERSE Headphones, I type `connect 1C:A0:D3:D2:AE:75`

If you have connected to your speaker/headphones successfully, you should see the `bluetoothctl` prompt change from `[bluetooth]#` to the name of your connected device. For example, for my VERSE headphones, the `bluetoothctl` prompt changes to `[VERSE]#`.

If your speaker/headphones has connected successfully, type `trust XX:XX:XX:XX:XX:XX` where XX represents the Bluetooth MAC address of your speaker/headphones. For example, for my VERSE Headphones, I type `trust 1C:A0:D3:D2:AE:75`. Trusting your Bluetooth speaker/headphones will allow them to auto connect in the future.

### Testing and Debugging the Bluetooth Connection

If your OpenWrt router has Internet access and you live in a country that does not block Google, issue the following command while logged into your OpenWrt router.

```
wget --quiet -O - -U "stream-mp3/mpg123/0.59r" 'http://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=Joy%20to%20the%20world&tl=en' | madplay -Q -o wave:- - | paplay
```

If you do not hear *Joy to the world* on your connected Bluetooth speaker/headphones, try rebooting your OpenWrt router and running `bluetoothd` and `pulseaudio` manually in debug mode and look for any error messages.

If you are still having problems, connect your Bluetooth dongle to a Debian machine and follow the steps in the previous section to pair. connect and trust your Bluetooth speaker/headphones. If you can connect successfully, copy everything in your Debian `/var/lib/bluetooth` directory to your OpenWrt `/etc/bluetooth/keys` directory. Reconnect your Bluetooth dongle to your OpenWrt router and reboot. Your Bluetooth speaker/headphones should now connect automatically to your OpenWrt router.

If your have your Bluetooth speaker/headphone paired with multiple devices, auto-connection may not always occur. Log into your OpenWrt router and issue the command

```
bluetoothctl connect XX:XX:XX:XX:XX:XX
```

where XX:XX:XX:XX:XX:XX is the MAC address of your Bluetooth speaker/headphones.

### MPD Configuration

We will be using [mpd](https://www.musicpd.org/ "https://www.musicpd.org/") to play our music through our Bluetooth headphones/speakers.

- Place all your music in your OpenWrt router `/data/share/mp3` directory
- Place your playlists in your `/data/share/mp3/playlists` directory

Sample playlist file which contains music files.

`Moby.m3u`

```
/data/share/mp3/moby/everything_is_wrong/Moby - Everything Is Wrong - 13 - When It's Cold I'd Like To Die.flac
/data/share/mp3/moby/i_like_to_score/01_novio.mp3
/data/share/mp3/moby/play/03 Radio 4.mp3
/data/share/mp3/moby/play/04 Toss The Feathers.mp3
```

Sample playlist file which contains Radio streams.

`Radio.m3u`

```
https://kexp-mp3-128.streamguys1.com/kexp128.mp3
https://onair.wfuv.org/onair-hi
http://listen.noagendastream.com/noagenda
http://icecast-ruvr.cdnvideo.ru/rian.voiceusa
http://stream.wqxr.org/wqxr
```

- Modify your `/etc/mpd.conf` file to look like the below.

```
music_directory		"/data/share/mp3"
playlist_directory	"/data/share/mp3/playlists"
db_file			"/data/mpd/tag_cache"
pid_file		"/data/mpd/pid"
state_file		"/data/mpd/state"
sticker_file		"/data/mpd/sticker.sql"

audio_output {
	type		"pipe"
	name		"mypipe"
	command		"/usr/bin/pacat --rate=44100 --format=s16le --channels=2 2>/dev/null"
	format		"44100:16:2"
}
```

![:!:](/lib/images/smileys/exclaim.svg) Note that you must manually create any directories that do not exist.

- Reboot your OpenWrt router and then issue the command `mpc update`

Once the update has completed, you can now create and load playlists and play music using [mpc](https://www.musicpd.org/clients/mpc/ "https://www.musicpd.org/clients/mpc/")

### Controlling Music Playback with your Headphones/Speaker

If your headphones/speaker supports the Bluetooth [AVRCP](https://en.wikipedia.org/wiki/List_of_Bluetooth_profiles#Audio%2FVideo_Remote_Control_Profile_%28AVRCP%29 "https://en.wikipedia.org/wiki/List_of_Bluetooth_profiles#Audio%2FVideo_Remote_Control_Profile_%28AVRCP%29") profile, you can use the Play/Pause/Next/Previous buttons on your speaker/headphones to control music playback. In Linux, these buttons can be read just like any other keyboard event.

#### Set up cross-compiling environment

Follow the instructions [here](https://electrosome.com/cross-compile-openwrt-c-program/ "https://electrosome.com/cross-compile-openwrt-c-program/") to set up a cross-compiling environment. Be sure to pull the environment that matches the OpenWrt version on your router.

My cross-compile environmental variables which need to be set before I cross-compile are as follows

```
export STAGING_DIR=/home/user/openwrt/staging_dir
export TOOLCHAIN_DIR=$STAGING_DIR/toolchain-mipsel_24kc_gcc-7.3.0_musl
export LDCFLAGS=$TOOLCHAIN_DIR/usr/lib
export LD_LIBRARY_PATH=$TOOLCHAIN_DIR/usr/lib
export PATH=$TOOLCHAIN_DIR/bin:$PATH
```

#### Compile buttonlogger.c

Anywhere on your cross-compile computer, create a file `buttonlogger.c` with the following contents.

```
#include <fcntl.h>
#include <linux/input.h>
#include <unistd.h>
#include <signal.h>
#include <stdlib.h>
#include <stdio.h>



int main(int argc, char *argv[])
{

        if (argc < 2) {
                fprintf(stderr, "Need /dev/input/eventx arguement\n");
                return 1;
        }


        int device = open(argv[1], O_RDONLY);
        struct input_event ev;


        read(device,&ev, sizeof(ev));
        if(ev.type == 1 && ev.value == 1)buttonlogger /dev/input/event0{
              /* printf("Key: %i State: %i\n",ev.code,ev.value); */
	      switch(ev.code) {
		case KEY_PLAYCD :
			printf("PLAY\n");
			break;
		case KEY_PAUSECD :
			printf("PAUSE\n");
			break;
		case KEY_NEXTSONG :
			printf("NEXT\n");
			break;
		case KEY_PREVIOUSSONG :
			printf("PREVIOUS\n");
			break;
	      }
			
        }
	else if(ev.value == 300 && ev.code == 0) printf("START\n");
}
```

Now compile `buttonlogger.c` with your cross C compiler. For my system, the command is

```
mipsel-openwrt-linux-gcc -o buttonlogger buttonlogger.c
```

This will create an executable called `buttonlogger` which you can copy to your OpenWrt router `$PATH`.

#### Test buttonlogger

Press your Bluetooth speaker/headphones **Play** button while connected to your OpenWrt router. Then issue the following command.

```
buttonlogger /dev/input/event0
```

while logged into your OpenWrt router.

Press your Bluetooth speaker/headphones **Play** button again. `butoonlogger` should return **PLAY**.

Your can re-issue the command

```
buttonlogger /dev/input/event0
```

and test all your other Bluetooth speaker/headphone buttons

Notes

- `/dev/input/event0` is dynamically created when your Bluetooth [AVRCP](https://en.wikipedia.org/wiki/List_of_Bluetooth_profiles#Audio%2FVideo_Remote_Control_Profile_%28AVRCP%29 "https://en.wikipedia.org/wiki/List_of_Bluetooth_profiles#Audio%2FVideo_Remote_Control_Profile_%28AVRCP%29") profile speaker/headphones are connected to your OpenWrt router. For some speaker/headphones, you need to press the **Play** button before `/dev/input/event0` is created.
- The **NEXT** and **PREVIOUS** buttons will only work while audio is playing through your Bluetooth speaker/headphones.
- Similarly, the **PAUSE** button may only work while music is playing.
- Some Bluetooth speakers/headphones only output **PLAY** and never **PAUSE**. For these Bluetooth headphones/speakers, your controlling script will need to determine if music is currently playing so it knows whether to issue an `mpc play` or `mpc pause` command.

#### Music Playback Controlling Script

I execute the following script on my OpenWrt router which allows me to use my Bluetooth speaker/headphones playback buttons to control music track playback.

`button-monitor.sh`

```
#!/bin/bash

# Bluetooth speaker/headphone button monitor


urlencode() {
    # urlencode <string>

    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:$i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done

    LC_COLLATE=$old_lc_collate
}

google_tts() {

    # google_tts <string>
    
    wget --quiet -O - -U "stream-mp3/mpg123/0.59r" \
        'http://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q='$(urlencode "$@")'&tl=en' |  madplay -Q -o wave:- -
 

}

# Select Text To Speech Engine
TTS_ENGINE="google_tts"


while true
do

# If result is empty, bluetooth device is not connected. Wait for new
# input device and try again
	while [ ! -e /dev/input/event0 ]
	do	
		if [ ! -d /dev/input ]
		then
			inotifywait -qqe create /dev
		else
			inotifywait -qqe create /dev/input
		fi	
	done

# Parse the output of the Bluetooth speaker/headphone buttonlogger 
# program and output voice and control mpd accordingly.
	BUTTON=$(/usr/local/bin/buttonlogger /dev/input/event0)
	case $BUTTON in
		PLAY)
                  paplay /usr/local/share/voices/play-track.wav
		  mpc -q play
		  ;;
		START)
                  paplay /usr/local/share/voices/play-track.wav
		  mpc -q play
		  ;;
		PAUSE)
	 	  CURRENT_SONG="$(mpc current | sed -e 's|["'\'']||g')"
		  mpc -q pause
                  paplay /usr/local/share/voices/pause-track.wav
		  if [ $(grep -c wlan0-1 /proc/net/wireless) -eq 1 ]
		  then
    		       $TTS_ENGINE  "$CURRENT_SONG" | paplay
		  fi
		  ;;
		NEXT)
		  mpc -q pause
                  paplay /usr/local/share/voices/next-track.wav
		  mpc -q next
		  ;;
		PREVIOUS)
		  mpc -q pause
                  paplay /usr/local/share/voices/previous-track.wav
		  mpc -q prev
		  ;;
	esac


done
```

Notes

- The above script requires the `bash` shell.
- Pre-recorded `.wav` files are in my OpenWrt router `/usr/local/share/voices/` directory. The script plays the appropriate voice file when a Bluetooth speaker/headphone button is pressed.
- When my OpenWrt has Internet access (is in [AP+STA](/docs/guide-user/network/wifi/ap_sta "docs:guide-user:network:wifi:ap_sta") mode) and the speaker/headphones **Pause** button is pressed, the script uses the `mpc current` command to retrieve the current track artist and song title, urlencode this information, send the text to Google for text to speech conversion and then play the result on my Bluetooth speaker/headphones.

### Controlling MPD via a Web Browser

Rather than ssh into your OpenWrt router and control [mpd](https://www.musicpd.org/ "https://www.musicpd.org/") via [mpc](https://www.musicpd.org/clients/mpc/ "https://www.musicpd.org/clients/mpc/"), we will control the OpenWrt [mpd](https://www.musicpd.org/ "https://www.musicpd.org/") daemon via an HTML 5 compliant Web browser. Note that the latest versions of Firefox and Safari are HTML 5 compliant. [ympd](https://www.ympd.org/ "https://www.ympd.org/") is extremely lightweight and fast since it is written in C, uses web-sockets and HTML 5 putting all the CPU load on the client Web browser. [ympd](https://www.ympd.org/ "https://www.ympd.org/") even includes an extremely lightweight web server in its executable. With [ympd](https://www.ympd.org/ "https://www.ympd.org/"), you will be able to use your Smart Phone, Tablet or PC web browser to search for music, create playlists, start/stop/next/previous track and seek to different times within a track while your Smart Phone is connected to your OpenWrt [AP](/docs/guide-quick-start/basic_wifi "docs:guide-quick-start:basic_wifi"). Neither your Smart Phone/Tablet/PC or your OpenWrt router needs to have Internet Access for this to work. I assume your already set up a successful cross-compiler environment as is described in the previous section.

#### Build libmpdclient

Download and extract the source code for libmpdclient which can be found [here](https://github.com/MusicPlayerDaemon/libmpdclient "https://github.com/MusicPlayerDaemon/libmpdclient"). Install both [ninja](https://en.wikipedia.org/wiki/Ninja_%28build_system%29 "https://en.wikipedia.org/wiki/Ninja_(build_system)") and [meson](https://mesonbuild.com/ "https://mesonbuild.com/") on your Linux cross-compiler computer. For Debian based Linux, the commands are

```
sudo apt install ninja-build
sudo apt install meson
```

In the `build/cross` sub-directory create a file called `openwrt.txt`. My `openwrt.txt` file is as follows

```
[binaries]
c = '/home/user/openwrt/staging_dir/toolchain-mipsel_24kc_gcc-7.3.0_musl/bin/mipsel-openwrt-linux-gcc'
cpp = '/home/user/openwrt/staging_dir/toolchain-mipsel_24kc_gcc-7.3.0_musl/bin/mipsel-openwrt-linux-g++'
ar = '/home/user/openwrt/staging_dir/toolchain-mipsel_24kc_gcc-7.3.0_musl/bin/mipsel-openwrt-linux-ar'
strip = '/home/user/openwrt/staging_dir/toolchain-mipsel_24kc_gcc-7.3.0_musl/bin/mipsel-openwrt-linux-musl-strip'
pkgconfig = '/home/user/openwrt/Programs/libmpdclient-2.19/build/openwrt/pkg-config.sh'

[properties]
root = '/home/user/openwrt/staging_dir/toolchain-mipsel_24kc_gcc-7.3.0_musl'

[host_machine]
system = 'linux'
cpu_family = 'mips'
cpu = 'mips'
endian = 'big'
```

Modify the above for your environment as per [here](https://mesonbuild.com/Cross-compilation.html "https://mesonbuild.com/Cross-compilation.html"). Then issue the following commands.

```
meson . output --cross-file build/cross/openwrt.txt
ninja -C output
ninja -C output install
```

Verify that the following files were installed correctly into the cross compiling environment.

```
ls /home/user/openwrt/staging_dir/toolchain-mipsel_24kc_gcc-7.3.0_musl/usr/include/mpd

async.h         entity.h       neighbor.h   protocol.h     socket.h
audio_format.h  error.h        output.h     queue.h        song.h
capabilities.h  fingerprint.h  pair.h       recv.h         stats.h
client.h        idle.h         parser.h     replay_gain.h  status.h
compiler.h      list.h         partition.h  response.h     sticker.h
connection.h    message.h      password.h   search.h       tag.h
database.h      mixer.h        player.h     send.h         version.h
directory.h     mount.h        playlist.h   settings.h     version.h.in
```

```
ls -l /home/openwrt/staging_dir/toolchain-mipsel_24kc_gcc-7.3.0_musl/usr/lib

lrwxrwxrwx 1 user user     20 Oct 16 20:28 libmpdclient.so -> libmpdclient.so.2.19
lrwxrwxrwx 1 user user     20 Oct 16 20:28 libmpdclient.so.2 -> libmpdclient.so.2.19
-rwxrwxr-x 1 user user 391700 Oct 16 20:27 libmpdclient.so.2.19
```

![:!:](/lib/images/smileys/exclaim.svg) Note that your build environment cross-compiling paths may differ.

#### Build ympd

Download and extract the source code for [ympd](https://www.ympd.org/ "https://www.ympd.org/") which can be found [here](https://github.com/notandy/ympd "https://github.com/notandy/ympd"). Install [cmake](https://en.wikipedia.org/wiki/CMake "https://en.wikipedia.org/wiki/CMake") on your Linux cross-compiler computer. For Debian based Linux, the command is

```
sudo apt install cmake
```

Create a `cmake` cross-compiling definition file as per the instructions [here](https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html#cross-compiling-for-linux "https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html#cross-compiling-for-linux"). My `cmake` cross-compiling definition file, which I named `ympd.cross` is below.

```
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR mips)
set(CMAKE_SYSROOT /home/user/openwrt/staging_dir/toolchain-mipsel_24kc_gcc-7.3.0_musl)
set(tools /home/user/openwrt/staging_dir/toolchain-mipsel_24kc_gcc-7.3.0_musl)
set(CMAKE_C_COMPILER ${tools}/bin/mipsel-openwrt-linux-gcc)
set(CMAKE_CXX_COMPILER ${tools}/bin/mipsel-openwrt-linux-g++)
set(include_directories ${tools}/usr/include)
```

![:!:](/lib/images/smileys/exclaim.svg) Note that your build environment cross-compiling paths may differ.

Execute the following commands in the `ympd` diectory.

```
cmake -DCMAKE_TOOLCHAIN_FILE=/home/user/openwrt/ympd/ympd.cross -DWITH_SSL=no
make
```

Copy `ympd` to somewhere in your OpenWrt router `$PATH`.

### Automatic Start

Start up everything automatically at power up by adding `button-monitor.sh` and `ympd` to your OpenWrt router `/etc/rc.local` file. My `/etc/rc.local` file contents are as follows.

```
# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.

/usr/local/bin/ympd -w 80 &

/usr/local/bin/button-monitor.sh &

exit 0
```

When I power up my OpenWrt router, my Bluetooth speaker/headphones automatically connects and I can start playing music my simply pressing my Bluetooth speaker's/headphones' play button. If I want to change the playlist, I simply connect my Smart Phone or tablet to my OpenWrt [AP](/docs/guide-quick-start/basic_wifi "docs:guide-quick-start:basic_wifi") and browse to [LuCI](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login").

![:!:](/lib/images/smileys/exclaim.svg) Since I don't use [LUCI](/docs/guide-user/luci/start "docs:guide-user:luci:start") and want to free up port 80 for `ympd`, I have disabled `uhttpd` by issuing the following command.

```
/etc/init.d/uhttpd disable
```

### TODO

Since OpenWrt does not include the [ofono](https://packages.debian.org/sid/ofono "https://packages.debian.org/sid/ofono") package, we cannot get audio from the Bluetooth speaker/headphones microphone. If OpenWrt did include the [ofono](https://packages.debian.org/sid/ofono "https://packages.debian.org/sid/ofono") and the [Darkice](https://packages.debian.org/sid/darkice "https://packages.debian.org/sid/darkice") package, we could take audio from the the Bluetooth speaker/headphones microphone, send it to an [Icecast](https://icecast.org/ "https://icecast.org/") server and listen or capture it as an audio stream.
