# Flashing OpenWrt with Wi-Fi enabled on first boot

OpenWrt is configured to have Wi-Fi disabled on first boot. Some upgrade scenarios require that wireless connection is enabled by default, though. There are two sections in this guide: one for upgrading an OpenWrt image, the other is suited for flashing OpenWrt from stock (vendor) firmware.

## Upgrading OpenWrt with Wi-Fi enabled on first boot

We use `sysupgrade` cli tool with a specially prepared restore configuration file. The method can be used for any OpenWrt image. You need to have an OpenWrt already running on the router. It will not work with a vendor ROM.

To flash an OpenWrt image with Wi-Fi enabled:

1. upload the upgrade image to the `/tmp` directory
2. paste the code to the command line:
   
   ```
   cat << "EOF" > /etc/uci-defaults/xxx_config
   uci set wireless.@wifi-device[0].disabled="0"
   uci set wireless.@wifi-iface[0].disabled="0"
   uci set wireless.@wifi-iface[0].ssid="OpenWrt"
   uci set wireless.@wifi-iface[0].key="changemeplox"
   uci set wireless.@wifi-iface[0].encryption="psk2"
   uci commit wireless
   EOF
   ```
3. This sets the initial name to `OpenWrt` and password to `changemeplox` for default interface on the first radio. You are strongly encouraged to change this password in the above file or at the very least after the first boot.
4. change directory to `/tmp`
5. run `tar -czvf config.tar.gz /etc/uci-defaults/` to create a config file for `sysupgrade`
6. run `rm /etc/uci-defaults/xxx_config` to remove this configuration file from the current image in case it is a dual boot device or sysupgrade fails
7. run `sysupgrade -n -f config.tar.gz image.bin` to flash. Note that it will not save the current configuration.

## Flashing OpenWrt with Wi-Fi enabled on first boot from vendor ROM

For this you need to build your own image. Follow the [beginners guide to building your own firmware](/docs/guide-developer/toolchain/beginners-build-guide "docs:guide-developer:toolchain:beginners-build-guide"). Before `make` put the `xxx_config` from the above section in `files/etc/uci-defaults` directory.

1. Create `files/etc/uci-defaults` relative to the main build dir.
   
   ```
   mkdir -p files/etc/uci-defaults
   ```
2. use your favourite editor to create `xxx_config`
   
   ```
   vi files/etc/uci-defaults/xxx_config
   ```
3. Build - also make sure you read guidelines how to speed up the build process (download all before build and build with `-jx`)
   
   ```
   make
   ```
4. use `factory.img` to flash your router

## Additional Information

- [Sysupgrade – Technical Reference](/docs/techref/sysupgrade "docs:techref:sysupgrade")
- [UCI defaults](/docs/guide-developer/uci-defaults "docs:guide-developer:uci-defaults")
- [Using the Image Builder](/docs/guide-user/additional-software/imagebuilder "docs:guide-user:additional-software:imagebuilder")
- [Build system – Usage](/docs/guide-developer/toolchain/use-buildsystem "docs:guide-developer:toolchain:use-buildsystem")

The same method can be used for any other configuration you need on the first boot. For example MAC address override on Wan interface.
