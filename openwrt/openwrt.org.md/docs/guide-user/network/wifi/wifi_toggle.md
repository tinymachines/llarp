# Wi-Fi on/off buttons

Quite a bit of devices come with at least one button (apart from the omnipresent reset/recovery button, which isn't convenient to press), which in the stock firmware is used for WPS, toggling Wi-Fi, or whatever, and on OpenWrt is not usually connected to any function.

In this article we will install and configure a package called **wifitoggle**, which allows us to configure one of such buttons as a Wi-Fi on/off (toggle) button.

## Setup steps

- This package lacks a graphical interface so for the setup we will need to connect to the OpenWrt device using SSH (remote terminal).
- Install **wifitoggle** package with `opkg update && opkg install wifitoggle`
- see the new uci configuration for it `uci show wifitoggle`, you will see something like this

```
# uci show wifitoggle
wifitoggle.@wifitoggle[0]=wifitoggle
wifitoggle.@wifitoggle[0].button='wps'
wifitoggle.@wifitoggle[0].timer='600'
wifitoggle.@wifitoggle[0].persistent='0'
wifitoggle.@wifitoggle[0].led_enable_trigger='timer'
wifitoggle.@wifitoggle[0].led_enable_delayon='500'
wifitoggle.@wifitoggle[0].led_enable_delayoff='500'
wifitoggle.@wifitoggle[0].led_disable_default='0'
```

- Do any customizations to the configuration and then save the changes with `uci commit`

## wifitoggle uci section

The `wifitoggle` section contains these settings:

Name Type Required Default Description `button` String yes wps internal name of the button to use. Usually the internal name is similar to what the button did in stock firmware. See notes below this table. `persistent` Boolean yes 0 Commit changes to wireless config file, persistent after reset. Always 0 if Timer enabled `timer` Integer yes 600 Seconds for Wi-Fi to be turned off, 0 for no timer `led_sysfs` String no none Led to use, see [Led configuration](/docs/guide-user/base-system/led_configuration "docs:guide-user:base-system:led_configuration") for possible values `led_enable_trigger` String yes timer led trigger name, see [Led configuration](/docs/guide-user/base-system/led_configuration "docs:guide-user:base-system:led_configuration") for other possible led trigger names `led_enable_delayon` Integer yes 500 Milliseconds to turn led on after button pressed `led_enable_delayoff` Integer yes 500 Milliseconds to turn led off after button pressed `led_disable_default` Boolean yes 0 Led state for Wi-Fi disabled, 1 to turn it off if Wi-Fi is off

![:!:](/lib/images/smileys/exclaim.svg) Common internal names for button (by searching through the source code) are:

- **wps** = Wi-Fi protected service, most likely to be free in OpenWrt and also default in wifitoggle
- **wlan** = used for buttons that toggle Wi-Fi on/off in stock firmware
- **rfkill** = also used for buttons that toggle Wi-Fi on/off in stock firmware
- **wifi** = also used for buttons that toggle Wi-Fi on/off in stock firmware, yes there is a bit of creativity going on.
- **power** = used to power up some devices, may be bound already to system shutdown function
- **help** = unknown, but I see it in the source code of some devices
- **phone** = unknown, but I see it in the source code of some devices
- **BTN\_0** = unknown, but I see it in the source code of some devices
- **BTN\_1** = unknown, but I see it in the source code of some devices
- **ses** = cisco services button
- **reset** = the reset button, usually already bound to system restart function

![:!:](/lib/images/smileys/exclaim.svg) [Here's](/docs/guide-user/base-system/hotplug#finding_the_internal_name_of_hardware_buttons "docs:guide-user:base-system:hotplug") a way to identify the internal name of your button if just trying the above list blindly does not work.

## Troubleshooting

If the script isn't working on your Wi-Fi networks, or it works only on some but not all, try deleting and creating again the ones that don't work.

Default Wi-Fi networks look like this in the config, and it seems the script can't parse that.

```
wireless.default_radio0=wifi-iface
wireless.default_radio0.device='radio0'
wireless.default_radio0.network='lan'
wireless.default_radio0.mode='ap'
wireless.default_radio0.ssid='myWifi'
wireless.default_radio0.encryption='psk2+tkip+ccmp'
wireless.default_radio0.key='password'
wireless.default_radio0.disabled='1'
```

This is how it looks after I deleted and created it again (and is actually working)

```
wireless.@wifi-iface[0]=wifi-iface
wireless.@wifi-iface[0].device='radio0'
wireless.@wifi-iface[0].mode='ap'
wireless.@wifi-iface[0].ssid='myWifi'
wireless.@wifi-iface[0].encryption='psk2+tkip+ccmp'
wireless.@wifi-iface[0].key='password'
```

Anyone that can fix the script please send a PR from the link below.

## Wi-Fi disable after boot

If you like to have Wi-Fi disabled after power on, set it disabled by default and then set wifitoggle to NOT save Wi-Fi state changes to permanent memory (so that whatever the state was on reboot it would reset to disabled) with the following:

```
uci set wireless.@wifi-device[0].disabled=1
uci set wifitoggle.@wifitoggle[0].persistent=0
uci commit
```

Or add this to `/etc/rc.local` or in Startup (LuCI System - Startup):

```
uci set wireless.@wifi-device[0].disabled=1
wifi
```

## Behind-the-scenes info for additional tweaking

This package drops a script called **50-wifitoggle** into **/etc/hotplug.d/button** and this script relies on the OpenWrt [Hotplug](/docs/guide-user/base-system/hotplug "docs:guide-user:base-system:hotplug") infrastructure to be called when you press the button.  
The other component of its package is the uci configuration file to integrate it with the uci system. See the source [here](https://github.com/openwrt/packages/tree/master/utils/wifitoggle "https://github.com/openwrt/packages/tree/master/utils/wifitoggle")
