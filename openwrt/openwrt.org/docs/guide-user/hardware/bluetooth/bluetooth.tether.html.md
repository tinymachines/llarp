# Smartphone Bluetooth Tethering

Bluetooth tethering is used to connect your OpenWrt Router to the Internet by using your smartphone. It's more convenient and has better performance (lower latency, more stable) than turning your smartphone into an access point and using that. It also is less of a CPU load on your phone, and allows you the flexibility of doing things with your OpenWrt router that you cannot do with your phone like connecting multiple devices with ease, both wireless and wired, to each other and to the internet. Unlike USB tethering, Bluetooth tethering allows you the freedom to use your smartphone without the limits of being connected to a USB cable. In short, you get the stability of USB Tethering without the need to have your smartphone physically connected to your OpenWrt Router. In order to maximize performance, you should turn your tethered phone Wi-Fi off.

This has been tested with an IPhone 8 running IOS 14.2, OpenWrt 18.06.4 running on a [HooToo TM03](/toh/hwdata/hootoo/hootoo_ht-tm03_tripmate_mini "toh:hwdata:hootoo:hootoo_ht-tm03_tripmate_mini") and [RAVPower RP-WD02](/toh/ravpower/rp-wd02 "toh:ravpower:rp-wd02") with a MicroSD card [overlay](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration") file systems and a [MT-300A](/toh/gl.inet/gl-mt300a "toh:gl.inet:gl-mt300a") with both [Sabrent](https://www.bhphotovideo.com/c/product/1427141-REG/sabrent_bt_ub40_micro_bluetooth_4_0_adapter.html "https://www.bhphotovideo.com/c/product/1427141-REG/sabrent_bt_ub40_micro_bluetooth_4_0_adapter.html") and [Plugable](https://www.newegg.com/p/1B4-00M5-00031?Description=USB%20Bluetooth%20dongle&cm_re=USB_Bluetooth%20dongle-_-9SIA2XB39D1325-_-Product "https://www.newegg.com/p/1B4-00M5-00031?Description=USB%20Bluetooth%20dongle&cm_re=USB_Bluetooth%20dongle-_-9SIA2XB39D1325-_-Product") USB Bluetooth dongles.

#### Notes

- OpenWrt 18.06.1 Bluetooth does not work correctly
- Do not use OpenWrt 19.xx.xx with the [HooToo TM03](/toh/hwdata/hootoo/hootoo_ht-tm03_tripmate_mini "toh:hwdata:hootoo:hootoo_ht-tm03_tripmate_mini") or [RAVPower RP-WD02](/toh/ravpower/rp-wd02 "toh:ravpower:rp-wd02") since the kernel has been compiled to no longer support [overlay](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration") file systems with these devices.
- In order to position the Bluetooth dongle in an optimum location with my stationary OpenWrt router, I purchased a [USB A Extender Cable](https://www.bhphotovideo.com/c/product/836878-REG/Pearstone_usb3_aa3_USB_3_0_Type_A.html "https://www.bhphotovideo.com/c/product/836878-REG/Pearstone_usb3_aa3_USB_3_0_Type_A.html") which I connected to my [MT-300A](/toh/gl.inet/gl-mt300a "toh:gl.inet:gl-mt300a") OpenWrt router and Bluetooth dongle.

#### Required OpenWrt packages:

1. kmod-input-uinput
2. bluez-daemon
3. bluez-utils
4. dbus
5. dbus-utils

This should result in the installation of other dependencies including the USB packages.

## Modify Default Configuration files

In `/etc/bluetooth/main.conf`, change the last line to `AutoEnable=true`

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

## Pair and Trust Smartphone

While logged into your OpenWrt device, type in the command `bluetoothctl`.

Make sure that your smartphone Bluetooth is enabled and then issue the command `scan on`.

Wait for your smartphone Bluetooth MAC address to appear and then type `pair XX:XX:XX:XX:XX:XX` where XX represents the Bluetooth MAC address of your smartphone. For example, for my IPhone, I type `pair 50:BC:96:9D:DD:21` and accept any pins.

When your smartphone has paired successfully, type `trust XX:XX:XX:XX:XX:XX` where XX represents the Bluetooth MAC address of your smartphone. For example, for my IPhone, I type `trust 50:BC:96:9D:DD:21`

## Connect To Your Smartphone

While logged into your OpenWrt device with the default Access Point configuration, issue the following command

```
dbus-send --system --type=method_call --dest=org.bluez /org/bluez/hci0/dev_XX_XX_XX_XX_XX_XX org.bluez.Network1.Connect string:'nap'
```

where XX represents the Bluetooth MAC address of your smartphone. For example, for my IPhone, I would type the command

```
dbus-send --system --type=method_call --dest=org.bluez /org/bluez/hci0/dev_50_BC_96_9D_DD_21 org.bluez.Network1.Connect string:'nap'
```

You should now get an indication on your smartphone that your OpenWrt router is connected. Get an IP address and route your Internet traffic though your smartphone by issuing the following commands.

```
uci set network.wan=interface
uci set network.wan.proto='dhcp'
uci set network.wan.ifname='bnep0'
uci commit
ifup wan
```

The output of the `ifconfig` command should now contain a block which looks something like the below

```
bnep0     Link encap:Ethernet  HWaddr 5C:F3:70:9B:95:CD  
          inet addr:172.20.10.14  Bcast:172.20.10.15  Mask:255.255.255.240
          inet6 addr: fe80::5ef3:70ff:fe9b:90cb/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:11071 errors:0 dropped:0 overruns:0 frame:0
          TX packets:11379 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:4383378 (4.1 MiB)  TX bytes:1936379 (1.8 MiB)
```

Note that `HWaddr` is the Bluetooth MAC address of the USB Bluetooth dongle connected to your OpenWrt device.

If your smartphone becomes separated from your OpenWrt router, simply re-issue the command

```
dbus-send --system --type=method_call --dest=org.bluez /org/bluez/hci0/dev_XX_XX_XX_XX_XX_XX org.bluez.Network1.Connect string:'nap'
```

This process can be easily automated by writing a script using the `l2ping` command. The script I use with my IPhone is below

```
#!/bin/sh
while [ 1 ]
do
   if [ ! -e /proc/sys/net/ipv4/conf/bnep0 ]
   then
     if [ $(l2ping -c 1 50:BC:96:9D:DD:21 2>/dev/null | grep -c "1 received") = 1 ]
     then
        dbus-send --system --type=method_call --dest=org.bluez /org/bluez/hci0/dev_50_BC_96_9D_DD_21 org.bluez.Network1.Connect string:'nap'
     fi
   fi
   sleep 30
done
```

When I take my IPhone away from my stationary OpenWrt router and then return, my OpenWrt router will re-tether to my IPhone for Internet access within 30 seconds.
