# brnboot

- Signed “Broad Net Technology, INC.”.
- Sometimes called AMAZON Loader.
- Uses the file transfer protocol [XMODEM](https://en.wikipedia.org/wiki/XMODEM "https://en.wikipedia.org/wiki/XMODEM") for file transfers.
- Has a hidden menu with more options unlocked by entering the character '!'.

## Recovery web interface

The brn-boot bootloader features a “secret” recovery web interface on `http://192.168.1.1/` or `http://192.168.2.1` which can be activated by switching on the device whilst holding the reset button depressed. This recovery mode includes a DHCP server, so you do not have to set a static IP on your computer.

Firmware images seem to be checked for a valid [signature](https://dev.openwrt.org/browser/trunk/tools/firmware-utils/src/mkbrnimg.c "https://dev.openwrt.org/browser/trunk/tools/firmware-utils/src/mkbrnimg.c") before actually flashing them. The signature key depends on the model of the router.

***WARNING: Only use this if you know exactly what you are doing or you may brick your device and/or the wifi card!***

This web interface is also loaded if the bootloader does not find a valid code image in the code image partition(s) when loading.

[![screenshot of the brn-boot recovery web interface](/_media/media/arcadyan/recovering_tool.png "screenshot of the brn-boot recovery web interface")](/_detail/media/arcadyan/recovering_tool.png?id=docs%3Atechref%3Abootloader%3Abrnboot "media:arcadyan:recovering_tool.png")

This “secret” recovery interface comes with an even more secret page `http://192.168.1.1/undoc_upgrade.stm` that does **not** check the firmware images before flashing them, and which even allows to flash the entire flash (including the bootloader). When the flashing is finished, the page may reload and show some garbled crap. Be sure to wait unil the flashing is finished before powercycling the device. On my [IAD 4421](/toh/arcadyan/arv7506pw11 "toh:arcadyan:arv7506pw11") with 8MiB of NOR flash, a “master” flash (reflashing the entire flash, including the bootloader and the ART partition) took about 5 minutes.

More information on [the difference between NOR and BRN](https://forum.openwrt.org/t/difference-between-nor-and-brn/7880/3 "https://forum.openwrt.org/t/difference-between-nor-and-brn/7880/3").

***WARNING: Only use this if you know exactly what you are doing or you may brick your device and/or the wifi card!***

### Use cases

- [Installing LEDE/u-boot via brnboot web interface (without rs232)](https://forum.openwrt.org/t/installing-lede-u-boot-via-brnboot-web-interface-without-rs232/9857/6 "https://forum.openwrt.org/t/installing-lede-u-boot-via-brnboot-web-interface-without-rs232/9857/6")

## Related tools

- [https://code.google.com/p/brndumper/](https://code.google.com/p/brndumper/ "https://code.google.com/p/brndumper/")
- [https://github.com/rvalles/brntool](https://github.com/rvalles/brntool "https://github.com/rvalles/brntool")
