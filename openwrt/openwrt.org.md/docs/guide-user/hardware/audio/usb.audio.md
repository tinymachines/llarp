# USB audio support

As long as you have the necessary hardware connected, OpenWrt can play audio, as can any other GNU/Linux distribution. Any USB Audio device supported by GNU/Linux should work with OpenWrt as well. But, because of it's lightbuild structure OpenWrt does not come with audio support. You have to install that afterwards.

Any USB sound card supported by Linux can work with OpenWrt. Many USB sound cards comply with the USB Audio Class standard and use the generic snd-usb-audio driver. Sometimes sound card manufacturers will explicitly say their devices are class compliant, but more commonly they do not. You can figure out whether a device is class compliant if it is marketed for use with iOS, as iOS only supports class compliant sound cards, or if it is marketed as working with Mac OS X but there is no driver to download for Mac OS X. (Windows partially supports the USB Audio Class standard, but often manufacturers provide a Windows driver for ASIO support.) If a device is not class compliant, you may be able to find whether it works with Linux by checking the [ALSA compatibility matrix](http://alsa-project.org/main/index.php/Matrix:Main "http://alsa-project.org/main/index.php/Matrix:Main"), but this is often very out of date.

You could get any cheap USB sound card for use with OpenWrt, but the quality of sound cards varies as widely as their price. You generally get what you pay for; expensive sound cards do sound much better than cheap ones.

For an overview of the different software systems for sound on Linux, see [How it works: Linux audio explained](http://tuxradar.com/content/how-it-works-linux-audio-explained "http://tuxradar.com/content/how-it-works-linux-audio-explained").

## Preparations

### Prerequisites

1. Utilize a **USB sound card** with GNU/Linux support, see the [Notes](/docs/guide-user/hardware/audio/usb.audio#notes "docs:guide-user:hardware:audio:usb.audio") on that.
2. ![:!:](/lib/images/smileys/exclaim.svg) You must have enabled the ALSA support in the kernel.
3. Follow [usb-installing](/docs/guide-user/storage/usb-installing "docs:guide-user:storage:usb-installing") and install the packages [kmod-usb-audio](/packages/pkgdata/kmod-usb-audio "packages:pkgdata:kmod-usb-audio") and [kmod-sound-core](/packages/pkgdata/kmod-sound-core "packages:pkgdata:kmod-sound-core") for Kernel audio support and ALSA drivers.
4. Plug the USB sound card of your choice into the USB port of your OpenWrt router.

### Required packages

#### Server (OpenWrt)

Name Size Description Required kmod-usb-audio 51909 Kernel support for USB audio devices kmod-sound-core 135315 Kernel modules for sound support alsa-utils ? To initialize your soundcard Optional kmod-sound-cs5535audio 56695 support for the integrated AC97 sound device on olpc kmod-sound-i8x0 66521 Support for the integrated AC97 sound device on motherboards with Intel/SiS/nVidia/AMD chipsets, or ALi chipsets using the M5455 Audio Controller. kmod-sound-soc-core 25290 SoC sound support usbutils 186470 package includes 'lsusb', if you want to check your usb-device is properly detected

## Configuration

In `/etc/rc.local` add the line

```
alsactl init            #to initialize your soundcard at boot up
```

There is nothing much to configure, but if you need to, you could use the package `alsa-utils` to do that.

## Alternative

A diploma thesis (in German) describes in detail: [http://neophob.com/serendipity/index.php?/archives/149-Diplomarbeit-Embedded-Linux-German.html](http://neophob.com/serendipity/index.php?%2Farchives%2F149-Diplomarbeit-Embedded-Linux-German.html "http://neophob.com/serendipity/index.php?/archives/149-Diplomarbeit-Embedded-Linux-German.html")

## Applications

Once your sound card is up and running, you need some programs to play the sound:

Name Version Dependencies Size Description madplay 0.15.2b-10 libid3tag libmad 28.36 KiB MAD is an MPEG audio decoder. It currently only supports the MPEG 1 standard, but fully implements all three audio layers (Layer I, Layer II, and Layer III, the latter often colloquially known as MP3.). There is also full support for ID3 tags. mpd-mini 0.23.9-2 alsa-lib, libaudiofile, libfaad2, libmad, glib2, libcurl, libflac, libmms, libpthread, libshout, libvorbis, libvorbisidec, libid3tag 447.44 KiB MPD is a music player supporting flac, mp3 and ogg files. It is typically controlled over a network using one of it's many clients including mpc(console), gmpc(gnome), phpmp(php), etc... sox 14.4.2-4 lame-lib, libmad, libid3tag, libvorbis, libvorbisidec, libgsm 267.53 KiB SoX is a command line utility that can convert various formats of computer audio files in to other formats. It can also apply various effects to these sound files during the conversion. As an added bonus, SoX can play and record audio files on several unix-style platforms. shairport-sync-mini 3.3.9-1 libc, librt, libpthread, alsa-lib, libconfig11, libdaemon, libpopt0, libmbedtls12 90.25 KiB Shairport Sync plays audio from iTunes and AirPlay sources, including iOS devices, Quicktime Player and third party sources such as forkedDaapd. There are different flavours: -mini, -mbedtls, -openssl. librespot 0.6.0 kmod-usb-core kmod-usb-audio kmod-sound-core alsa-utils ~ 10 MiB librespot is an open source client library for Spotify. It enables applications to use Spotify's service to control and play music via various backends, and to act as a Spotify Connect receiver. It is an alternative to the official and now deprecated closed-source libspotify. There is no official package for OpenWRT, but GitHub repositories with IPKs for different platforms exist.

### Madplay

In combination with wget it can act as an Internet radio. Find some MP3 stream and try something like:

```
wget -O - http://64.236.34.97:80/stream/1014 | madplay -
```

### MPD

MPD (Music Player Daemon) is a small music player with support for FLAC, MP3 and OGG files. It is a daemon process which is typically controlled by a client such as gmpc running on another desktop machine. For more information: [http://mpd.wikia.com](http://mpd.wikia.com "http://mpd.wikia.com")

MPD is configured in the file `/etc/mpd.conf`. The default config file probably won't work as-is, but it should have enough comments to be edited easily. ![FIXME](/lib/images/smileys/fixme.svg) The MPD package does not currently contain a script to start MPD at boot. Check other HowTos to easily write one.

- For MPD, read [https://forum.openwrt.org/viewtopic.php?pid=125196#p125196](https://forum.openwrt.org/viewtopic.php?pid=125196#p125196 "https://forum.openwrt.org/viewtopic.php?pid=125196#p125196")
- [Here](http://mpd.wikicities.com/wiki/OpenWRT_FullInstall "http://mpd.wikicities.com/wiki/OpenWRT_FullInstall") is some documentation about an old and very complicated installation of mpd. Most stuff isn't necessary any longer, and much is optional. But you could milk that article for help not provided here.

### Sox

```
sox -q $1 -t ossdsp /dev/sound/dsp
```

### librespot

There is no official package for OpenWRT, but GitHub repositories with IPKs for different platforms exist:

- [https://github.com/humaita-github/librespot-openwrt-ipk](https://github.com/humaita-github/librespot-openwrt-ipk "https://github.com/humaita-github/librespot-openwrt-ipk")
- [https://github.com/izer-xyz/librespot-openwrt](https://github.com/izer-xyz/librespot-openwrt "https://github.com/izer-xyz/librespot-openwrt")

### PulseAudio

- [PulseAudio Server](/docs/guide-user/hardware/audio/pulseaudio "docs:guide-user:hardware:audio:pulseaudio")

### LIRC

If your USB sound card has a **microphone input**, you can use it to connect an infrared receiver module, and use any remote to send commands to the router.

- [LIRC audio\_alsa](/docs/guide-user/hardware/lirc-audio_alsa "docs:guide-user:hardware:lirc-audio_alsa")

## Troubleshooting

Is the USB Soundcard detected?

```
root@OpenWrt:~# lsusb
Bus 001 Device 007: ID 041e:324d Creative Technology, Ltd
```

Generic Alsa init:

```
root@OpenWrt:~# alsactl init
Found hardware: "USB-Audio" "USB Mixer" "USB041e:324d" "" ""
Hardware is initialized using a generic method
```

**Required for AC97 Sound in Virtual Box.**

Unmute sound with:

```
amixer sset Master unmute
```

Test sounds with:

```
speaker-test -Dplug:front -c2 -tsine -f440
speaker-test -Dplug:front -c2 -twav -f440
```

## Internet radio

Use one of the existing buttons of your router to control the radio. Modify one of the scripts in `/etc/rc.buttons/...` [Attach functions to a push button](/docs/guide-user/hardware/hardware.button "docs:guide-user:hardware:hardware.button") . Below script uses `madplay`. The idea was to use the minimum of available resources: **One button control only**

- Start audio stream/radio station (ON)
- Stopp audio stream/radio station (OFF)
- Switch between streams/radio stations (SWITCH)

Below script implements this structure:

```
push the button the first time (t1)                -> start first stream (ON)
push the button a second time within (t1+10sec)    -> switch to second stream (SWITCH)
push the button a third  time within (t1+10sec)    -> switch to third stream (SWITCH)
...
The history is gone as soon as 10 seconds passed after the last button has been pushed
push the button again                              -> stop the stream (OFF) 
```

I copied most of the parts from other sources (see comments), as my bash programming skills are quite bad. There is quite some room for improvement.  
![:!:](/lib/images/smileys/exclaim.svg) There is no error handling in place. You need to know the functionality!

```
#!/bin/sh
 
#Control Time aka the time a sleep process is running -> to count how often the button is pressed
SLEEPTIME=10s   #in seconds
 
#Definition of radio stations
EGOFM="http://egofm-ais-edge-3002.fra-eco.cdn.addradio.net/egofm/live/mp3/high/stream.mp3?ar-distributor=ffa0"
FM4="http://185.85.28.144:8000"
ROCKANTENNE="http://stream.rockantenne.de/rockantenne"
RADIOBOB="http://bob.hoerradar.de/mp3-radiobob"
RADIOBOB_ALTERNATIVEROCK="http://bob.hoerradar.de/radiobob-alternativerock-mp3-hq"
RADIOBOB_PUNK="http://bob.hoerradar.de/radiobob-punk-mp3-mq"
DLFNOVA="http://st03.dlf.de/dlf/03/128/mp3/stream.mp3"
BRPULS="http://br-puls-live.cast.addradio.de/br/puls/live/mp3/128/stream.mp3"
 
#PID(s) of stream/audio processes
PIDWGET="$(ps | grep '[w]get' | awk '{print $1}')"      #https://stackoverflow.com/questions/3510673/find-and-kill-a-process-in-one-line-using-bash-and-regex
PIDMADPLAY="$(ps | grep '[m]adplay' |awk '{print $1}')"
#echo "wget PID $PIDWGET"       #debug
 
#PID(s) of sleep processes
PIDSLEEP="$(ps | grep '[s]leep' | awk '{print $1}')"
#echo "sleep PID $PIDSLEEP"     #debug
 
#number of sleep processes to count the number of buttons pressed
SPLITCHAR=" "
NOPIDWGET="$(echo ${PIDWGET} | awk -F"${SPLITCHAR}" '{print NF}')"
NOPIDSLEEP="$(echo ${PIDSLEEP} | awk -F"${SPLITCHAR}" '{print NF}')" #https://stackoverflow.com/questions/16679369/count-occurrences-of-a-char-in-a-string-using-bash/16
#echo "no. PID sleep $NOPIDSLEEP"       #debug
 
#function to kill stream and audio process
do_kill(){
if [ "$PIDWGET" -eq "$PIDWGET" ] 2>/dev/null    #https://stackoverflow.c
        then
                kill -SIGKILL $PIDWGET          #kill wget process (streaming)
                kill -SIGKILL $PIDMADPLAY       #kill madplay process (audio)
                #echo "kill -SIGKILL $PIDWGET"  #debug
fi
}
 
#function to start the internet stream and provide audio output (madplay)
do_stream(){
        #-A -10 -> volume -10dB
        #- -> ???
        #& process in background
        wget -O - $1 | madplay -A -10 - &
}
 
if [ "$ACTION" = "released" -a "$BUTTON" = "wps" ]; then
if [ $NOPIDSLEEP == 0 -a $NOPIDWGET == 0 ];then         #script never executed AND no stream running
        sleep $SLEEPTIME &     #increment count of script executions within 10sec
        #echo "0"              #debug
        do_stream $DLFNOVA
elif [ $NOPIDSLEEP == 0 -a  $NOPIDWGET == 1 ];then      #script not exectued AND stream running
        do_kill
elif [ $NOPIDSLEEP == 1 -a  $NOPIDWGET == 1 ];then      #script executed once AND stream running
        do_kill
        sleep $SLEEPTIME &     #increment count of script executions within 10sec
        #echo "1"              #debug
        do_stream $RADIOBOB
elif [ $NOPIDSLEEP == 2 -a  $NOPIDWGET == 1 ];then      #script executed twice AND stream running
        do_kill
        sleep $SLEEPTIME &     #increment count of script executions within 10sec
        #echo "2"              #debug
        do_stream $BRPULS
elif [ $NOPIDSLEEP == 3 -a  $NOPIDWGET == 1 ];then      #...
        do_kill
        sleep $SLEEPTIME &     #increment count of script executions within 10sec
        #echo "3"              #debug
        do_stream $EGOFM
fi
fi
return 0
```
