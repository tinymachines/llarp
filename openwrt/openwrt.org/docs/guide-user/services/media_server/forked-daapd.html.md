# iTunes server (forked-daapd)

Please note that forked-daapd cannot currently play aac files on low-power devices - see below

This page is intented for people who want to run an itunes server on their OpenWrt device, controlling it via Apple Remote on iPod Touch/iPhone/iPad or Retune/TunesRemote+ on Android. This can be achieved with [forked-daapd](https://github.com/ejurgensen/forked-daapd "https://github.com/ejurgensen/forked-daapd"), which is a rewritten and updated version of the old mt-daapd/FireFly.

You’ll need a device with good cpu/memory. The device will probably also need attached USB storage. Your USB storage must have your music library, and it must also be set up so that custom packages will be installed on it. See [extroot\_configuration](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration") for more information about that.

##### Building yourself

This package is available in opkg repositories provided by packages feed. It should be possible to run the following commands to install forked-daapd on your device.

```
opkg update
opkg install forked-daapd
```

##### Building yourself

Have a look at the Makefiles etc. [in the OpenWrt packages repository.](https://github.com/openwrt/packages/tree/master/sound/forked-daapd "https://github.com/openwrt/packages/tree/master/sound/forked-daapd")

### Running forked-daapd

Edit /etc/forked-daapd.conf. Set the path to your music library and set the path to the forked-daapd database. Start the server by running “/etc/init.d/forked-daapd start”. The server should now start scanning your library. You can check /var/log/forked-daapd.log if you want to see what is going on. To stop forked-daapd run “/etc/init.d/forked-daapd stop”. If the server is not starting make sure avahi-daemon and dbus are running.

More instructions, like how to get Remote working, are available in [this readme](https://github.com/ejurgensen/forked-daapd/blob/master/README.md "https://github.com/ejurgensen/forked-daapd/blob/master/README.md").

### Bugs (or: please help fix these!)

1. when you start playback of an aac file CPU will spike and playback will stop - this may only be a problem on some devices (like my WNDR3700)

### Notes

This is third-party software, use at own risk. If you have trouble with these packages, or if you can contribute, please discuss in this thread: [https://forum.openwrt.org/viewtopic.php?id=30302](https://forum.openwrt.org/viewtopic.php?id=30302 "https://forum.openwrt.org/viewtopic.php?id=30302")
