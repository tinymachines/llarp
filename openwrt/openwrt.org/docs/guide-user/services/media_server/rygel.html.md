# Rygel DLNA Media Server

[Rygel](http://live.gnome.org/Rygel/ "http://live.gnome.org/Rygel/") implements several of the DLNA media server protocols. Given that several DLNA media servers are already packaged for OpenWrt, the most interesting functionality of rygel in this context is the implementation of the MediaRenderer protocol, which allows remote control of a media player using a standardized interface.

Rygel packaging in OpenWrt trunk is currently broken.

The latest packaging is available from [https://github.com/aandyl/openwrt-packages](https://github.com/aandyl/openwrt-packages "https://github.com/aandyl/openwrt-packages").

For trunk, you can add the rygel packages to feeds.conf with this entry (make sure to add it before the main packages repository):

```
src-git rygel https://github.com/aandyl/openwrt-packages.git;rygel
```

Building the rygel packages with openwrt trunk currently requires some patches to the openwrt build tree. The necessary patches are available in the openwrt patchwork and are linked from the [README](https://github.com/aandyl/openwrt-packages/blob/rygel/README "https://github.com/aandyl/openwrt-packages/blob/rygel/README") in the git repo.

For attitude adjustment, use the `rygel-aa` branch. feeds.conf entry (again, must be before the main packages repository):

```
src-git rygel https://github.com/aandyl/openwrt-packages.git;rygel-aa
```

## System requirements

My squashfs images for TL-WR1043ND containing rygel and dependencies are around 6 MB. That covers audio playback only. If you wanted to do video playback, the size would increase. Note that when installing packages to the JFFS with opkg, they are not compressed, so the space requirements will increase. (I don't expect an opkg install to fit in an 8 MB device.)

Running rygel uses most of the 32 MB of memory in the WR1043ND.

## Installing

There are several rygel plugins available, and packages are defined for all of them. Only the `rygel-playbin` plugin implementing the MediaRenderer protocol has been tested. When installing the playbin plugin, you likely want to install the `rygel-playbin-gst-suggested` package as well, which will pull in a set of useful gstreamer plugins for playing a variety of common audio formats. Using a smaller set of plugins is definitely possible if you only use a limited set of formats. Note, however, that identifying the needed plugins for a given format can be tricky.

Additional packages may be needed to support your audio output. For the case of USB audio adapters, information can be found in [usb.audio](/docs/guide-user/hardware/audio/usb.audio "docs:guide-user:hardware:audio:usb.audio").

## Configuring

The name of the media renderer is displayed when selecting a network destination in player applications. The default name is “Audio/Video playback on &lt;hostname&gt;”. You can set the name by doing:

```
uci set rygel.Playbin.title="MediaRendererName"
uci commit rygel
service rygel restart
```

## Using

Once the media renderer is set up, it should appear as an option in your player. The exact means of choosing the media renderer as the sink device will vary between players.

If you have trouble getting things to work, here are some things to check:

- Check the syslog for errors using `logread`
- Make sure the appropriate gstreamer plugins are installed
- See if you can play sound in other applications
- Try a different media player

## Link dump

- [https://wiki.archlinux.org/index.php/Rygel](https://wiki.archlinux.org/index.php/Rygel "https://wiki.archlinux.org/index.php/Rygel")
