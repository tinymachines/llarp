# Smartphone USB reverse tethering with OpenWrt

![:!:](/lib/images/smileys/exclaim.svg) The opposite direction is described in [smartphone.usb.tethering](/docs/guide-user/network/wan/smartphone.usb.tethering "docs:guide-user:network:wan:smartphone.usb.tethering")

USB reverse tethering is used to connect your Smartphone over your OpenWrt-Router with the Internet. Follow:

1. install usbnet:
   
   ```
   opkg install kmod-usb-net
   ```
2. now connect your smartphone to the USB port of your OpenWrt device
3. put your smartphone into *USB reverse thethering mode*
4. when your smartphone is connected to the USB bus in *USB reverse thethering mode*, a USB hotplug event *should* be triggered on the OpenWrt device and a new network interface **`usbN`** (where N is a number starting from 0) should appear. You can then configure it like any other ethernet interface, e.g.
   
   ```
   ip a a 192.168.6.254 dev usb0
   ```
   
   or
   
   ```
   ifconfig usb0 inet 192.168.6.254 up
   ```
5. make dropbear serve on usb0, see [dhcp](/docs/guide-user/base-system/dhcp "docs:guide-user:base-system:dhcp")

**Please note:** Some smartphone, like e.g. the “HTC Desire” product family do not support Linux and atm it is not possible to use the above procedure, which is very simple and strait forward to connect your HTC Desire via USB via Linux to the Internet. For other OSes there is a special software called HTC sync. Me thinks the simplest solution is to not buy these products.
