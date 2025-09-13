# ModemManager

ModemManager is a service that automatically sets up and connects 2G/3G/4G/5G modems and provides a high level of abstraction when interacting with modems.

A few examples of functionality offered by ModemManager are:

- initialisation of the modem
- connecting to the Internet
- sending/receiving SMS
- firmware upgrades for select QMI-based modems.

## Installing

In `menuconfig`, ModemManager is located under the Network section.

## Kernel modules

You probably need to include the kernel module for your modem in your firmware image, or on running firmware via [opkg](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg").

Common ones which should get most modems working to some extent are:

```
opkg update && opkg install kmod-usb-serial kmod-usb-net kmod-usb-serial-wwan kmod-usb-serial-option kmod-usb-net-qmi-wwan kmod-usb-net-cdc-mbim
```

## MBIM Support

ModemManager supports MBIM modems. You can include MBIM support by selecting it under the Configuration section in ModemManager's `menuconfig` entry.

## QMI Support

ModemManager supports QMI modems. You can include QMI support by selecting it under the Configuration section in ModemManager's `menuconfig` entry.

## Use

ModemManager abstracts the configuration of your modems into standard Linux network interfaces. The example below illustrates a typical configuration:

**/etc/config/network**

```
config interface 'broadband'
    option device   '/sys/devices/platform/soc/20980000.usb/usb1/1-1/1-1.2/1-1.2.1'
    option proto    'modemmanager'
    option apn      'ac.vodafone.es'
    option username 'vodafone'
    option password 'vodafone'
    option pincode  '7423'
    option lowpower '1' 
```

The available options are

optiontyperequireddescription devicestringXFull sysfs path of the device, for example `/sys/devices/platform/soc/20980000.usb/usb1/1-1/1-1.2/1-1.2.1`. Do not use `/dev/cdc-wdm0`. apnstringXThe GPRS Access Point Name specifying the APN used when establishing a data session with the GSM-based network allowedauthlist(string) Authentication method to use. A list of `none, pap, chap, mschap, mschapv2, eap` usernamestring The username used to authenticate with the network, if required passwordstring The password used to authenticate with the network, if required pincodestring If the SIM is locked with a PIN it must be unlocked before any other operations are requested iptypestringX`ipv4v6` or `ipv4` or `ipv6` signalrateint Signal refresh rate to `signalrate` second (see mmcli --signal-setup) lowpowerboolean See mmcli --set-power-state-low

## Luci support

It is possible to install `luci-proto-modemmanager` to configure an interface with `ModemManager` protocol via Luci.

[![](/_media/media/luci_proto_modemmanager.png)](/_detail/media/luci_proto_modemmanager.png?id=docs%3Aguide-user%3Anetwork%3Awan%3Awwan%3Amodemmanager "media:luci_proto_modemmanager.png")
