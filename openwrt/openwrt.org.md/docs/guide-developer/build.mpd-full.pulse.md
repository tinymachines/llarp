# Building MPD-full with PulseAudio

More information about building from source: [OpenWrt Buildroot - Usage](/docs/guide-developer/toolchain/start "docs:guide-developer:toolchain:start")

First you need to follow the HowtoBuild [MPD-full building from source](/docs/guide-developer/build.mpd-full "docs:guide-developer:build.mpd-full")

Based on the following reference: [BB + MPD-full + PulseAudio, unable to build](https://forum.openwrt.org/viewtopic.php?pid=287809#p287809 "https://forum.openwrt.org/viewtopic.php?pid=287809#p287809")

### 18.06.02

#### The MPD Makefile

In your git clone directory edit the makefile `/openwrt/feeds/packages/sound/mpd/Makefile`.

Detect the area in the Makefile involved with the full MPD installation. Add `+pulseaudio-daemon` to DEPENDS.

```
 
  TITLE+= (full)
  DEPENDS+= +libffmpeg +libid3tag +libmms +libupnp +libshout +pulseaudio-daemon
  PROVIDES:=mpd
  VARIANT:=full
```

Edit the --disable-pulse to **--enable-pulse**

```
     --disable-nfs \
     --disable-openal \
     --disable-opus \
     --enable-pulse \
     --disable-sidplay \
     --disable-smbclient \
     --disable-sndfile \
```

Edit the EXTRA\_LDFLAGS and add

```
-Wl,-rpath-link=$(STAGING_DIR)/usr/lib/pulseaudio 
```

The complete line looks like that:

```
  EXTRA_LDFLAGS += $(if $(ICONV_FULL),-liconv,-Wl,--whole-archive -liconv -Wl,--no-whole-archive) -Wl,-rpath-link=$(STAGING_DIR)/usr/lib/pulseaudio
```

Maybe the path has to be adapted to $(STAGING\_DIR)/opt/lib/pulseaudio.
