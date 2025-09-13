# LIRC audio\_alsa

[LIRC](http://www.lirc.org/ "http://www.lirc.org/") is a package that allows you to decode and send infra-red signals of many (but not all) commonly used remote controls.

Be aware you'll need a **sound card** with microphone input. A cheap usb sound card can do the job.

The audio\_alsa module lets you to use a soundcard input to receive infrarred signals. The basic idea is that the output of the IR module (somewhere in the range from 0 to ~3-4V) can be limited by using the attenuator built into every audio-card (also known as “mixer sliders”).

## Prepare your hardware

These are some schematics for connecting the IR module to our soundcard input

1. Using a diode, see [http://www.lirc.org/ir-audio.html](http://www.lirc.org/ir-audio.html "http://www.lirc.org/ir-audio.html")  
   [![](/_media/media/doc/howtos/lirc-alsa-diode.png?w=400&tok=da1cee)](/_media/media/doc/howtos/lirc-alsa-diode.png "media:doc:howtos:lirc-alsa-diode.png")  
   Tested with a small signal switching diode BAV20PH, but other diodes (not all) should also work.
2. Using a voltage divider  
   [![](/_media/media/doc/howtos/lirc-audio_alsa.jpg?w=500&tok=33e875)](/_detail/media/doc/howtos/lirc-audio_alsa.jpg?id=docs%3Aguide-user%3Ahardware%3Alirc-audio_alsa "media:doc:howtos:lirc-audio_alsa.jpg")  
   A TSOP1736 IR module also works. The +5V should be as stable as possible to avoid power supply disturbances.
3. Using a voltage divider, with some improvements: With a low band pass filter to minimize power supply disturbances. Also we put the 100 nF capacitor before the voltage divider, not after. And a 10kohm pullup resistor in the IR module out to boost the signal.  
   [![](/_media/media/doc/howtos/lirc-audio_alsa-v3.png?w=500&tok=85873d)](/_media/media/doc/howtos/lirc-audio_alsa-v3.png "media:doc:howtos:lirc-audio_alsa-v3.png")

One drawback for keeping it simple is the power supply. We can just modify our USB audiostick **isolating one minijack contact** and bridging it to the +5V usb power supply.  
[![](/_media/media/doc/howtos/lirc_alsa-audiostick.jpg?w=400&tok=1ab239)](/_detail/media/doc/howtos/lirc_alsa-audiostick.jpg?id=docs%3Aguide-user%3Ahardware%3Alirc-audio_alsa "media:doc:howtos:lirc_alsa-audiostick.jpg")  
The circuit then can be wired with a minijack cable. We need a little case for the circuit with the IR module receiver, an ADSL microfilter case is perfect for this purpose (you have for sure tons of them from ISPs).  
[![](/_media/media/doc/howtos/lirc_alsa-case1.jpg?w=400&tok=81446a)](/_detail/media/doc/howtos/lirc_alsa-case1.jpg?id=docs%3Aguide-user%3Ahardware%3Alirc-audio_alsa "media:doc:howtos:lirc_alsa-case1.jpg")

## Prepare your software

To use the audio\_alsa module you'll need to build Openwrt with the package lirc and alsamixer. Install both before building your own firmware.

```
./scripts/feeds update -a
./scripts/feeds install lirc alsa-utils
```

The lirc package is not built as default with *audio\_alsa*, and it seems partially broken. As a result of this you must modify the Makefile for lirc. Or just download this fixed one:  
Mirror: [lirc-audio\_alsa-for-openwrt](https://github.com/probonopd/lirc-audio_alsa-for-openwrt "https://github.com/probonopd/lirc-audio_alsa-for-openwrt")  
Tested with OpenWrt Attitude Adjustment, but it may also work with Backfire. Replace the lirc directory under feeds with this new one.

As usually build your custom firmware but select alsa-utils, lirc:

```
Location: 
    -> Utilities
```

```
┌─────────────────────────────────── Utilities ───────────────────────────────────┐
│ ┌─────────────────────────────────────────────────────────────────────────────┐ │  
│ │     Boot Loaders  --->                                                      │ │  
│ │     Editors  --->                                                           │ │  
│ │     Filesystem  --->                                                        │ │  
│ │     Terminal  --->                                                          │ │  
│ │     disc  --->                                                              │ │  
│ │ <*> alsa-utils............ ALSA (Advanced Linux Sound Architecture) utilitie│ │  
│ │ < > alsa-utils-seq.................................. ALSA sequencer utilitie│ │  
│ │ < > alsa-utils-tests.......... ALSA utilities test data (adds ~1.3M to image│ │  
│ │ < > bzip2.................................... bzip2 is a compression utility│ │  
│ │ < > cal................................................... display a calenda│ │  
│ │ < > comgt............................... Option/Vodafone 3G/GPRS control too│ │  
│ │ < > dmesg............................ print or control the kernel ring buffe│ │  
│ │ < > dropbearconvert.......................... Utility for converting SSH key│ │  
│ │ < > fconfig..................................... RedBoot configuration edito│ │  
│ │ < > flock.................................... manage locks from shell script│ │  
│ │ < > gdb......................................................... GNU Debugge│ │  
│ │ < > gdbserver................................. Remote server for GNU Debugge│ │  
│ │ < > getopt.................................. parse command options (enhanced│ │  
│ │ < > gpioctl................................... Tool for controlling gpio pin│ │  
│ │ < > hwclock.................................. query or set the hardware cloc│ │  
│ │ < > iconv................................... Character set conversion utilit│ │  
│ │ < > iwcap.................................... Simple radiotap capture utilit│ │  
│ │ < > iwinfo.......................... Generalized Wireless Information utilit│ │  
│ │ --- jshn................................................. JSON SHell Notatio│ │  
│ │ < > kexec-tools.......................................... Kernel boots kerne│ │  
│ │ < > ldconfig............................... Shared library path configuratio│ │  
│ │ < > ldd.................................................... LDD trace utilit│ │  
│ │ <*> lirc................................ LIRC - Linux Infrared Remote Contro│ │  
│ │ < > logger......... a shell command interface to the syslog system log modul│ │  
│ │ < > look......................... display lines beginning with a given strin│ │  
│ └─v(+)────────────────────────────────────────────────────────────────────────┘ │  
├─────────────────────────────────────────────────────────────────────────────────┤  
│                        <Select>    < Exit >    < Help >                         │  
└─────────────────────────────────────────────────────────────────────────────────┘ 
```

and lirc utitilities:

```
Location: 
    -> Utilities
      -> lirc
```

```
┌─────────── lirc............. LIRC - Linux Infrared Remote Control ────────────┐
│ ┌───────────────────────────────────────────────────────────────────────────┐ │
│ │ --- lirc.................. LIRC - Linux Infrared Remote Control           │ │
│ │ <*>   lircdaemonadd...................... Daemon Additional Files         │ │
│ │ <*>   lirctools....................................... LIRC tools         │ │
│ │                                                                           │ │
│ └───────────────────────────────────────────────────────────────────────────┘ │
├───────────────────────────────────────────────────────────────────────────────┤
│                   <Select>    < Exit >    < Help >                            │
└───────────────────────────────────────────────────────────────────────────────┘
```

Build openwrt, and flash your custom firmware. Now you have lirc prepared to work.

[![](/_media/meta/icons/tango/dialog-information.png)](/_detail/meta/icons/tango/dialog-information.png?id=docs%3Aguide-user%3Ahardware%3Alirc-audio_alsa "meta:icons:tango:dialog-information.png") Note the file **/etc/lircd.conf** is specific for your remote. You'll may need to use [irrecord](http://www.lirc.org/html/irrecord.html "http://www.lirc.org/html/irrecord.html") to get one for your own remote if you don't find any in the [lirc database](http://lirc.sourceforge.net/remotes/ "http://lirc.sourceforge.net/remotes/").

### Build with a transmitter

You may want to use the [LIRC GPIO blaster](/docs/guide-user/hardware/lirc-gpioblaster "docs:guide-user:hardware:lirc-gpioblaster") kernel module together with audio\_alsa receiver. We can use two lirc instances connected via TCP/IP or rather to patch lirc for having only one daemon running, this way it's more compact and saves some bytes. Link with the LIRC package and the patch, and also the lirc\_gpioblaster module

LIRC audio\_alsa patched to work with lirc\_gpioblaster kernel module  
[lirc\_0.9.0-audio\_alsa-plus\_gpioblaster.zip](https://drive.google.com/uc?export=download&id=0B-EMoBe-_OdBTTROQ3hpYUV3S0k "https://drive.google.com/uc?export=download&id=0B-EMoBe-_OdBTTROQ3hpYUV3S0k")

(Tested under Openwrt Attitude Adjustment)

## Make it work

Execute the lirc daemon

```
mkdir /var/run/lirc
lircd --driver=audio_alsa -d plughw@24000
```

LIRC sometimes is affected by an alsa bug, see → [alsa\_bug](#alsa_bug "docs:guide-user:hardware:lirc-audio_alsa ↵")

Now execute irw, to test your remote, the codes are shown when you press any button.

```
root@OpenWrt:/# irw
00000000000005e9 00 + rct3004
00000000000005ea 00 - rct3004
00000000000005ea 01 - rct3004
00000000000005dd 00 power rct3004
00000000000005d0 00 3 rct3004
00000000000005d0 01 3 rct3004
00000000000005c9 00 5 rct3004
00000000000005c9 01 5 rct3004
00000000000005c1 00 4 rct3004
00000000000005c1 01 4 rct3004
```

If nothing is shown you may need to calibrate the infrared receiver with alsamixer:

```
┌───────── AlsaMixer v1.0.24.2 ─────────┐
│ Card: Generic USB Audio Device        │
│ Chip: USB Mixer                       │
│ View: Playback                        │
│ Item: Speaker [dB gain: -0.06, -0.06] │
│     ┌──┐        ┌──┐                  │
│     │▒▒│        │  │                  │
│     │▒▒│        │  │                  │
│     │▒▒│        │  │                  │
│     │▒▒│        │  │                  │
│     │▒▒│        │  │                  │
│     │▒▒│        │▒▒│                  │
│     │▒▒│        │▒▒│                  │
│     │▒▒│        │▒▒│                  │
│     │▒▒│        │▒▒│                  │
│     │▒▒│        │▒▒│                  │
│     ├──┤        ├──┤        ┌──┐      │
│     │OO│        │MM│        │OO│      │
│     └──┘        └──┘        └──┘      │
│   100<>100       52                   │
│ <  Speaker  >    Mic     Auto Gain C  │
└───────────────────────────────────────┘
```

Sometimes is better to use Auto Gain other times not (**m** key to disable/enable). So play with it together with the next control:  
**Press F4** to enter the Capture control.

```
┌───────── AlsaMixer v1.0.24.2 ─────────┐
│ Card: Generic USB Audio Device        │
│ Chip: USB Mixer                       │
│ View: Capture                         │
│ Item: Mic [dB gain: 14.88]            │
│                                       │
│                 ┌──┐                  │
│                 │  │                  │
│                 │  │                  │
│                 │  │                  │
│                 │  │                  │
│                 │▒▒│                  │
│                 │▒▒│                  │
│                 │▒▒│                  │
│                 │▒▒│                  │
│                 │▒▒│                  │
│                 │▒▒│                  │
│                L└──┘R                 │
│               CAPTURE                 │
│                  62                   │
│              <  Mic   >               │
└───────────────────────────────────────┘
```

Now play with the gain (arrow up/down) until your remote shows its codes with irw. Once calibrated press Esc key to exit alsamixer.

### irexec

Ok nothing new here, just configure [lircrc](http://www.lirc.org/html/configure.html#lircrc_format "http://www.lirc.org/html/configure.html#lircrc_format") as described in the LIRC website. The file /etc/wifiradio/lircrc is an example. Run the [irexec](http://www.lirc.org/html/irexec.html "http://www.lirc.org/html/irexec.html") daemon with a command like this:

```
irexec --daemon /etc/wifiradio/lircrc
```

Now everytime you press a button in your remote, irexec will execute the associated commands in the lircrc file.

You can put the commands to calibrate alsamixer and execute commands in /etc/rc.local, to autostart lircd and irexec once you got it working.

```
mkdir /var/run/lirc
amixer -q set Mic capture 62%
lircd --driver=audio_alsa -d plughw@24000
irexec --daemon /etc/wifiradio/lircrc
```

## alsa bug

Sometimes lirc is unable to open correctly the recording device. The cause is still unknown. But fortunatelly when opening several times the alsa recording device we can see it fails with a defined pattern.

`arecord -q -d 1 -r44100 -f S16_LE -c1 -t wav test01.wav ← good arecord -q -d 1 -r44100 -f S16_LE -c1 -t wav test02.wav ← bad arecord -q -d 1 -r44100 -f S16_LE -c1 -t wav test03.wav ← bad arecord -q -d 1 -r44100 -f S16_LE -c1 -t wav test04.wav ← bad arecord -q -d 1 -r44100 -f S16_LE -c1 -t wav test05.wav ← good arecord -q -d 1 -r44100 -f S16_LE -c1 -t wav test06.wav ← bad arecord -q -d 1 -r44100 -f S16_LE -c1 -t wav test07.wav ← bad arecord -q -d 1 -r44100 -f S16_LE -c1 -t wav test08.wav ← bad arecord -q -d 1 -r44100 -f S16_LE -c1 -t wav test09.wav ← good arecord -q -d 1 -r44100 -f S16_LE -c1 -t wav test10.wav ← bad arecord -q -d 1 -r44100 -f S16_LE -c1 -t wav test11.wav ← bad ......`

[![](/_media/media/doc/howtos/lirc_alsa-arecord-bcm63xx.png?w=600&tok=4c301f)](/_media/media/doc/howtos/lirc_alsa-arecord-bcm63xx.png "media:doc:howtos:lirc_alsa-arecord-bcm63xx.png")

This happens in bcm63xx, the pattern is 3 good recordings, 1 bad. In bcm47xx the pattern is 1 good recording, 1 bad recording.

Considering this known predictable bug, we can solve the problem with an ugly workaround: **make dummy recordings before running lirc**.

Put this command before the line that executes the lirc daemon

```
/usr/bin/arecord -q -d 1 -r48000 -f S16_LE -c1 -t raw > /dev/null
```

You may need to put 1, 2 or 3 lines depending on the state of the recording device. Just test it adding more lines with a router reboot in every added recording line until lirc starts working ok.

## Notes

Successfully tested with a [Livebox 1](/toh/inventel/dv4210 "toh:inventel:dv4210") router under Backfire, using a CSOUNDU Conceptronic usb audio card, and TSOP1736 --- *danitool 2012/11/04 15:02*
