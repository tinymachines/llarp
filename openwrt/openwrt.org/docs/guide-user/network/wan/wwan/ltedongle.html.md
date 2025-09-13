# How to use LTE modem in QMI mode for WAN connection

Many of currently available 3G/4G/5G modems use **QMI** and/or **MBIM** protocol to interact with the *host system*, e.g. with a router. For your information, [QMI](https://blogs.gnome.org/dcbw/2010/04/15/mobile-broadband-and-qualcomm-proprietary-protocols/ "https://blogs.gnome.org/dcbw/2010/04/15/mobile-broadband-and-qualcomm-proprietary-protocols/") is a proprietary protocol by Qualcomm. In contrast to QMI, [MBIM](https://modemmanager.org/docs/libmbim/mbim-protocol/ "https://modemmanager.org/docs/libmbim/mbim-protocol/") is more standardized protocol for such modems.

This recipe explains how to setup and configure OpenWrt for using 3G/4G/5G USB modems for WAN connection, using QMI or MBIM protocol.

The same applies to external modems connected to USB ports and internal models installed into M.2(NGFF) or mPCIe slots.

You may want to checkout the [mwan3](/docs/guide-user/network/wan/multiwan/mwan3 "docs:guide-user:network:wan:multiwan:mwan3") (Multi WAN load balancing/failover) package to use this simultaneously with other connections to the Internet.

## About

Many modern USB modems may operate in different modes. If your modem provides only *serial* interface(s) like `/dev/ttyUSBx` - please refer to [How to use 3g/UMTS USB Dongle for WAN connection](/docs/guide-user/network/wan/wwan/3gdongle "docs:guide-user:network:wan:wwan:3gdongle"). For more information about other protocols commonly used:

- **MBIM**, see below on this page
- **NCM**, see [How To use LTE modem in NCM mode for WAN connection](/docs/guide-user/network/wan/wwan/ethernetoverusb_ncm "docs:guide-user:network:wan:wwan:ethernetoverusb_ncm")
- **ECM**, see [Use cdc\_ether driver based dongles for WAN connection](/docs/guide-user/network/wan/wwan/ethernetoverusb_cdc "docs:guide-user:network:wan:wwan:ethernetoverusb_cdc")
- **RNDIS**, see [How To use LTE modem in RNDIS mode for WAN connection](/docs/guide-user/network/wan/wwan/ethernetoverusb_rndis "docs:guide-user:network:wan:wwan:ethernetoverusb_rndis")

If it is possible to switch your modem to provide QMI or MBIM interface - then this article is for you.

### Legacy Modem Preparation

If QMI or MBIM interface is not exposed by the modem initially you may need to switch it to another mode or *composition* by using [USB mode switch](/docs/guide-user/network/wan/wwan/usb-modeswitching "docs:guide-user:network:wan:wwan:usb-modeswitching") tool or a vendor-specific AT command.

![:!:](/lib/images/smileys/exclaim.svg) Please read about [AT commands](/docs/guide-user/network/wan/wwan/at_commands "docs:guide-user:network:wan:wwan:at_commands") for your modem.

### LTE or 5G Modem Preparation

More recent modems are set by default to MBIM or QMI mode.

This is an example of switching modes for popular Quectel modems (don't expect these proprietary commands to work on devices from other manufacturers):

```
AT+QCFG="usbnet"	# check the current mode
AT+QCFG="usbnet",0	# set QMI or RMNET mode
AT+QCFG="usbnet",1	# set ECM mode
AT+QCFG="usbnet",2	# set MBIM mode
```

Reset the modem to apply changes - power toggle it or send `AT+CFUN=1,1` command.

It is worth checking the list of *PDP Contexts* and particularly the *APNs* configured on the modem. Use a *terminal* program to query the modem with `AT+CGDCONT?` and observe the output. Example:

```
AT+CGDCONT?
+CGDCONT: 1,"IPV4V6","internet",...
+CGDCONT: 2,"IPV4V6","ims",...
+CGDCONT: 3,"IPV4V6","sos",...
```

Typically, but not always, context #1 is used for Internet connection. If it is not configured with the correct information (IP type and APN), it is recommended to set the desired parameters. Example:

```
AT+CGDCONT=1,"IP","internet"
```

Replace `IP` with `IPV4V6` or `IPV6` if necessary and use your APN instead of `internet`.

For an alternative method, see [Manual validation](/docs/guide-user/network/wan/wwan/ltedongle#manual_validation "docs:guide-user:network:wan:wwan:ltedongle") section below.

While in the *terminal*, check the modem firmware version with `ATI` and see if there is an upgrade available.

### Router Preparation

1\. Install OpenWrt

2\. Complete Steps [OpenWrt Configuration](/docs/guide-quick-start/checks_and_troubleshooting "docs:guide-quick-start:checks_and_troubleshooting")

Router should be turned on and connected to the Internet to get the needed packages. Please refer to: [Internet Connection](/docs/guide-user/network/wan/internet.connection "docs:guide-user:network:wan:internet.connection").

### Required Packages

To make use of QMI protocol, packages `kmod-usb-net-qmi-wwan` (driver) and `uqmi` (control utility) are needed. For MBIM protocol the packages are `kmod-usb-net-cdc-mbim` and `umbim`.

### Optional Packages

1\. Add protocol support to LuCI - install `luci-proto-qmi` for QMI or `luci-proto-mbim` for MBIM.

2\. Add support for *serial* interfaces (ttyUSBx) - install `kmod-usb-serial-option` or `kmod-usb-serial-qualcomm` depending on the modem.

That is needed to interact with the modem using AT commands, for configuration purposes or to be able to send/receive SMS and USSD. A *terminal* program like `picocom` will be needed to actually send AT commands.

3\. Install [usb-modeswitch](/packages/pkgdata/usb-modeswitch "packages:pkgdata:usb-modeswitch") package *only if* that is needed for switching the modem into a “working” state. More about: [USB mode switch](/docs/guide-user/network/wan/wwan/usb-modeswitching "docs:guide-user:network:wan:wwan:usb-modeswitching")

4\. Add support for *storage* component of your modem - refer to: [USB Storage](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives")

## Sample installation

1\. Install all the needed packages either in LuCI → System → Software or via command line:

- if the modem is in QMI mode:

```
root@OpenWrt:~# opkg update
root@OpenWrt:~# opkg install kmod-usb-net-qmi-wwan uqmi luci-proto-qmi kmod-usb-serial-option picocom
```

- if the modem is in MBIM mode:

```
root@OpenWrt:~# opkg update
root@OpenWrt:~# opkg install kmod-usb-net-cdc-mbim umbim luci-proto-mbim kmod-usb-serial-option picocom
```

You can also add the necessary packages when building a new image with [Firmware Selector](https://firmware-selector.openwrt.org/ "https://firmware-selector.openwrt.org/").

![:!:](/lib/images/smileys/exclaim.svg) If your have not enough space on your device - think about upgrading your hardware or installing [Rootfs on External Storage (extroot)](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration"). Refer to your router wiki page or forum thread for possibility and instructions.

2\. Reboot the router by executing `reboot` on the console.

3\. Check if you got a new *device*:

```
root@OpenWrt:~# ls -l /dev/cdc*

crw-r--r--    1 root     root      180, 176 Oct  1 12:03 /dev/cdc-wdm0
```

If there is no such device found - try to get more details:

- Open System Log from LuCI web interface and see what it shows regarding newly discovered USB device(s)
- execute `dmesg` on the console and see if any relevant information is present in the kernel log
- check the details about USB devices detected by the system by running `cat /sys/kernel/debug/usb/devices` on the console:

```
[...]
T:  Bus=01 Lev=01 Prnt=01 Port=00 Cnt=01 Dev#=  2 Spd=480  MxCh= 0
D:  Ver= 2.00 Cls=ef(misc ) Sub=02 Prot=01 MxPS=64 #Cfgs=  1
P:  Vendor=2c7c ProdID=0306 Rev= 3.10
S:  Manufacturer=Quectel
S:  Product=EP06-E
S:  SerialNumber=0123456789ABCDEF
C:* #Ifs= 5 Cfg#= 1 Atr=a0 MxPwr=500mA
I:* If#= 0 Alt= 0 #EPs= 2 Cls=ff(vend.) Sub=ff Prot=ff Driver=option
E:  Ad=81(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
E:  Ad=01(O) Atr=02(Bulk) MxPS= 512 Ivl=0ms
I:* If#= 1 Alt= 0 #EPs= 3 Cls=ff(vend.) Sub=00 Prot=00 Driver=option
E:  Ad=83(I) Atr=03(Int.) MxPS=  10 Ivl=32ms
E:  Ad=82(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
E:  Ad=02(O) Atr=02(Bulk) MxPS= 512 Ivl=0ms
I:* If#= 2 Alt= 0 #EPs= 3 Cls=ff(vend.) Sub=00 Prot=00 Driver=option
E:  Ad=85(I) Atr=03(Int.) MxPS=  10 Ivl=32ms
E:  Ad=84(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
E:  Ad=03(O) Atr=02(Bulk) MxPS= 512 Ivl=0ms
I:* If#= 3 Alt= 0 #EPs= 3 Cls=ff(vend.) Sub=00 Prot=00 Driver=option
E:  Ad=87(I) Atr=03(Int.) MxPS=  10 Ivl=32ms
E:  Ad=86(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
E:  Ad=04(O) Atr=02(Bulk) MxPS= 512 Ivl=0ms
I:* If#= 4 Alt= 0 #EPs= 3 Cls=ff(vend.) Sub=ff Prot=ff Driver=qmi_wwan
E:  Ad=89(I) Atr=03(Int.) MxPS=   8 Ivl=32ms
E:  Ad=88(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
E:  Ad=05(O) Atr=02(Bulk) MxPS= 512 Ivl=0ms
```

See Troubleshooting Section of this page for more information.

## Configuration

### With LuCi web interface

\[QMI]: Assuming `luci-proto-qmi` package is installed, navigate to Network → Interfaces, then Add new interface… → Protocol: QMI Cellular

\[MBIM]: Assuming `luci-proto-mbim` package is installed, navigate to Network → Interfaces, then Add new interface… → Protocol: MBIM Cellular

\[Common]:

Select Interface “cdc-wdm0” in the drop-down. If it is not available there, check if the corresponding driver (`kmod-usb-net-*`) is loaded, reset the modem if its mode has recently been changed.

Enter your `APN` and select the `IP type` as instructed by the carrier, *don't set `IP type` to `IPV4V6` until you're 100% sure that provider supports IPv6*, that is critical in QMI mode.

Note: in IPv6-only mode it is recommended to enable `dhcpv6` option in order to automatically start the 464XLAT interface (that requires [464xlat](/packages/pkgdata/464xlat "packages:pkgdata:464xlat") package).

Assign the firewall zone (wan) on 'Firewall Settings' tab.

### Editing text configuration files

Add new interface to `/etc/config/network` using a *text editor* like `vi` or `nano`:

```
config interface 'wwan'
        option proto 'qmi'
        option device '/dev/cdc-wdm0'
        option apn 'internet'
        option pdptype 'ip'
```

Replace “qmi” with “mbim” if necessary to match the modem configuration. Make sure the APN name is one provided by your carrier.

Add the same interface name to the existing “wan” firewall zone in `/etc/config/firewall`:

```
config zone
    option name 'wan'
    [...]
    list network 'wwan'
```

### QMI Protocol Configuration Parameters

QMI (and MBIM) interfaces could be manually configured in [UCI](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") using [uci command line](/docs/techref/uci "docs:techref:uci") or [text editor](/docs/guide-user/base-system/user.beginner.cli#editingfiles "docs:guide-user:base-system:user.beginner.cli").

Name Type Required Default Description **device** file path yes (none) QMI device node, typically **/dev/cdc-wdm0** **apn** string yes (none) Used APN **v6apn** string no (none) APN for IPv6, if different from IPv4 APN **auth** string no (none) Authentication type: **pap**, **chap**, **both**, **none** **username** string no (none) Username for PAP/CHAP authentication **password** string no (none) Password for PAP/CHAP authentication **pincode** number no (none) PIN code to unlock SIM card **delay** number no 0 Seconds to wait before trying to interact with the modem (some ZTE modems require up to 30 s.) **modes** string no (modem default) Allowed network modes, comma separated list of: **all**, **lte**, **umts**, **gsm**, **cdma**, **td-scdma** **pdptype** string no IP PDP Context Type, IP (for IPv4), IPV6 (for IPv6) or IPV4V6 (for dual-stack). Connection will fail if selected type is unsupported by the carrier. **profile** number no 1 PDP Context Identifier **v6profile** number no (none) PDP Context Identifier for IPv6 if different from IPv4 profile **dhcp** boolean no 1 Whether to use DHCP (**default**) or uqmi (**0**) to get IPv4 interface configuration **dhcpv6** boolean no 0 Whether to use DHCP (**1**) or uqmi (**default**) to get IPv6 interface configuration **sourcefilter** boolean no 1 Used to disable source-based IPv6 routing **delegate** boolean no 1 Used to disable IPv6 Prefix Delegation **autoconnect** boolean no 1 **plmn** number no (none) Limit network registration to specific operator. First 3 digits is the **MCC** (Mobile Country Code) and last 3 digits is the **MNC** (Mobile Network Code); for example, if lock is required for a network with MCC 338 and MNC 20, then plmn should be set to 338020 **timeout** number no 10 Timeout (in seconds) to wait for SIM operations **mtu** number no (none) Interface MTU size

Here is a brief help about `uqmi` command line usage:

Click to display ⇲

Click to hide ⇱

```
Usage: uqmi <options|actions>
Options:
  --single, -s:                     Print output as a single line (for scripts)
  --device=NAME, -d NAME:           Set device name to NAME (required)
  --keep-client-id <name>:          Keep Client ID for service <name>
  --release-client-id <name>:       Release Client ID after exiting
  --mbim, -m                        NAME is an MBIM device with EXT_QMUX support
  --timeout, -t                     response timeout in msecs
 
Services:                           dms, nas, pds, wds, wms
 
Actions:
  --get-versions:                   Get service versions
  --set-client-id <name>,<id>:      Set Client ID for service <name> to <id>
                                    (implies --keep-client-id)
  --get-client-id <name>:           Connect and get Client ID for service <name>
                                    (implies --keep-client-id)
  --sync:                           Release all Client IDs
  --start-network:                  Start network connection (use with options below)
    --apn <apn>:                    Use APN
    --auth-type pap|chap|both|none: Use network authentication type
    --username <name>:              Use network username
    --password <password>:          Use network password
    --ip-family <family>:           Use ip-family for the connection (ipv4, ipv6, unspecified)
    --autoconnect:                  Enable automatic connect/reconnect
    --profile <index>:              Use connection profile
  --stop-network <pdh>:             Stop network connection (use with option below)
    --autoconnect:                  Disable automatic connect/reconnect
  --get-data-status:                Get current data access status
  --set-ip-family <val>:            Set ip-family (ipv4, ipv6, unspecified)
  --set-autoconnect <val>:          Set automatic connect/reconnect (disabled, enabled, paused)
  --get-profile-settings <val,#>:   Get APN profile settings (3gpp, 3gpp2),#
  --get-default-profile <val>:      Get default profile number (3gpp, 3gpp2)
  --create-profile <val>            Create profile (3gpp, 3gpp2)
    --apn <apn>:                    Use APN
    --pdp-type ipv4|ipv6|ipv4v6>:   Use pdp-type for the connection
    --username <name>:              Use network username
    --password <password>:          Use network password
    --auth-type pap|chap|both|none: Use network authentication type
    --no-roaming false|true         To allow roaming, set to false
  --modify-profile <val>,#          Modify profile number (3gpp, 3gpp2)
    --apn <apn>:                    Use APN
    --pdp-type ipv4|ipv6|ipv4v6>:   Use pdp-type for the connection
    --username <name>:              Use network username
    --password <password>:          Use network password
    --auth-type pap|chap|both|none: Use network authentication type
    --no-roaming false|true         To allow roaming, set to false
  --get-current-settings:           Get current connection settings
  --get-capabilities:               List device capabilities
  --get-pin-status:                 Get PIN verification status
  --verify-pin1 <pin>:              Verify PIN1
  --verify-pin2 <pin>:              Verify PIN2
  --set-pin1-protection <state>:    Set PIN1 protection state (disabled, enabled)
    --pin <pin>:                    PIN1 needed to change state
  --set-pin2-protection <state>:    Set PIN2 protection state (disabled, enabled)
    --pin <pin2>:                   PIN2 needed to change state
  --change-pin1:                    Change PIN1
    --pin <old pin>:                Current PIN1
    --new-pin <new pin>:            New pin
  --change-pin2:                    Change PIN2
    --pin <old pin>:                Current PIN2
    --new-pin <new pin>:            New pin
  --unblock-pin1:                   Unblock PIN1
    --puk <puk>:                    PUK needed to unblock
    --new-pin <new pin>:            New pin
  --unblock-pin2:                   Unblock PIN2
    --puk <puk>:                    PUK needed to unblock
    --new-pin <new pin>:            New pin
  --get-iccid:                      Get the ICCID
  --get-imsi:                       Get International Mobile Subscriber ID
  --get-imei:                       Get International Mobile Equipment ID
  --get-msisdn:                     Get the MSISDN (telephone number)
  --reset-dms:                      Reset the DMS service
  --get-device-operating-mode       Get the device operating mode
  --set-device-operating-mode <m>   Set the device operating mode
                                    (modes: online, low_power, factory_test, offline
                                     reset, shutting_down, persistent_low_power,
                                     mode_only_low_power)
  --fcc-auth:                       Set FCC authentication
  --uim-verify-pin1 <pin>:          Verify PIN1 (new devices)
  --uim-verify-pin2 <pin>:          Verify PIN2 (new devices)
  --uim-get-sim-state:              Get current SIM state
  --uim-power-off:                  Power off SIM card
    --uim-slot:                     SIM slot [1-2]
  --uim-power-on:                   Power on SIM card
    --uim-slot:                     SIM slot [1-2]
  --set-network-modes <modes>:      Set usable network modes (Syntax: <mode1>[,<mode2>,...])
                                    Available modes: all, lte, umts, gsm, cdma, td-scdma
  --set-network-preference <mode>:  Set preferred network mode to <mode>
                                    Available modes: auto, gsm, wcdma
  --set-network-roaming <mode>:     Set roaming preference:
                                    Available modes: any, off, only
  --network-scan:                   Initiate network scan
  --network-register:               Initiate network register
  --set-plmn:                       Register at specified network
    --mcc <mcc>:                    Mobile Country Code (0 - auto)
    --mnc <mnc>:                    Mobile Network Code
  --get-plmn:                       Get preferred network selection info
  --get-signal-info:                Get signal strength info
  --get-serving-system:             Get serving system info
  --get-system-info:                Get system info
  --get-lte-cphy-ca-info:           Get LTE Cphy CA Info
  --get-cell-location-info:         Get Cell Location Info
  --get-tx-rx-info <radio>:         Get TX/RX Info (gsm, umts, lte)
  --list-messages:                  List SMS messages
    --storage <mem>:                Messages storage (sim (default), me)
  --delete-message <id>:            Delete SMS message at index <id>
    --storage <mem>:                Messages storage (sim (default), me)
  --get-message <id>:               Get SMS message at index <id>
    --storage <mem>:                Messages storage (sim (default), me)
  --get-raw-message <id>:           Get SMS raw message contents at index <id>
    --storage <mem>:                Messages storage (sim (default), me)
  --send-message <data>:            Send SMS message (use options below)
    --send-message-smsc <nr>:       SMSC number
    --send-message-target <nr>:     Destination number (required)
    --send-message-flash:           Send as Flash SMS
  --wda-set-data-format <type>:     Set data format (type: 802.3|raw-ip)
  --wda-get-data-format:            Get data format
```

### MBIM Protocol support

MBIM configuration is very similar to QMI. Supported interface configuration options:

**Name** **Type** **Required** **Default** **Description** **device** file path yes (none) MBIM device node, typically **/dev/cdc-wdm0** **apn** string yes (none) Used APN **auth** string no (none) Authentication type: **pap**, **chap**, **both**, **none** **username** string no (none) Username for PAP/CHAP authentication **password** string no (none) Password for PAP/CHAP authentication **pincode** number no (none) PIN code to unlock SIM card **delay** number no 0 Seconds to wait before trying to interact with the modem **pdptype** string no IP PDP Context Type, IP (for IPv4), IPV6 (for IPv6) or IPV4V6 (for dual-stack) **ipv6** boolean no 1 Set it to 0 to disable IPv6 operation **dhcp** boolean no 0 Whether to use DHCP (**1**) or “umbim” tool (**default**) to get IPv4 interface configuration **dhcpv6** boolean no 0 Whether to use DHCPv6 (**1**) or “umbim” tool (**default**) to get IPv6 interface configuration **sourcefilter** boolean no 1 Used to disable source-based IPv6 routing **extendprefix** boolean no 0 Accept a /64 IPv6 prefix via SLAAC and extend it on one downstream interface **delegate** boolean no 1 Used to disable IPv6 Prefix Delegation **allow\_roaming** boolean no 0 Allow connection if the modem is registered to the network in roaming **allow\_partner** boolean no 0 Allow connection if the modem is registered to a partner network **mtu** number no (none) Interface MTU size

Here is a brief help about `umbim` command line:

```
root@OpenWrt:~# umbim help
Usage: umbim <caps|pinstate|unlock|home|registration|subscriber|attach|detach|connect|disconnect|config|radio> [options]
Options:
    -d <device>         the device (/dev/cdc-wdmX)
    -t <transaction>    the transaction id
    -n                  no close
    -v                  verbose
```

`uqmi` tool can talk to MBIM modems using `--mbim` or `-m` option on the command line.

### Manual validation

Check the currently configured APN:

```
root@OpenWrt:~# uqmi -d /dev/cdc-wdm0 --get-profile-settings 3gpp,1
{
        "apn": "internet",
        "pdp-type": "ipv4v6",
        "username": "",
        "password": "",
        "auth": "none",
        "no-roaming": false,
        "apn-disabled": false
}
```

Change the APN and/or IP type (an alternative method to using AT commands mentioned above):

```
root@OpenWrt:~# uqmi -d /dev/cdc-wdm0 --set-device-operating-mode low_power
root@OpenWrt:~# uqmi -d /dev/cdc-wdm0 --modify-profile 3gpp,1 --apn internet --pdp-type=ipv4 --username="" --password="" --auth=none
root@OpenWrt:~# uqmi -d /dev/cdc-wdm0 --set-device-operating-mode online
```

where “internet” is the APN of your provider

Check network registration and signal strength:

```
root@OpenWrt:~# uqmi -d /dev/cdc-wdm0 --get-serving-system
{
        "registration": "registered",
        "plmn_mcc": 123,
        "plmn_mnc": 45,
        "plmn_description": "OperatorName",
        "roaming": false
}
```

and

```
root@OpenWrt:~# uqmi -d /dev/cdc-wdm0 --get-signal-info
{
        "type": "lte",
        "rssi": -71,
        "rsrq": -9,
        "rsrp": -94,
        "snr": 70
}
```

Check the connection status:

```
root@OpenWrt:~# uqmi -d /dev/cdc-wdm0 --get-data-status
"disconnected"
```

To manually start the Internet connection issue a command:

```
root@OpenWrt:~# uqmi -d /dev/cdc-wdm0 --start-network internet --autoconnect
```

where “internet” is the APN of your provider

![:!:](/lib/images/smileys/exclaim.svg) Some providers will accept almost any APN, in this case using “internet” is fine.

Check the status:

```
root@OpenWrt:~# uqmi -d /dev/cdc-wdm0 --get-data-status
"connected"
```

`--autoconnect` key says that you want always be connected, once the modem is physically connected to the router and cellular network is in range. ![:!:](/lib/images/smileys/exclaim.svg) It will be kept after reboot.

In case you need additional authentication, please look at the possible arguments for `uqmi` utility:

```
  --start-network <apn>:            Start network connection (use with options below)
    --auth-type pap|chap|both|none: Use network authentication type
    --username <name>:              Use network username
    --password <password>:          Use network password
    --autoconnect:                  Enable automatic connect/reconnect
  --stop-network <pdh>:             Stop network connection (use with option below)
    --autoconnect:                  Disable automatic connect/reconnect
```

### Checking your balance

To check your balance or send any other AT commands, you need to have USB serial device like: /dev/ttyUSB0

If you have it (if not then install missing USB serial drivers), you can run in first terminal:

```
cat /dev/ttyUSB0
```

and in the second (\*101# is my USSD code):

```
echo -ne 'AT+CUSD=1,"*101#",15\r\n' > /dev/ttyUSB0
```

You should see in first terminal USSD response.

### Modem Status page in LuCI

This important feature is not yet officially available in OpenWrt, but you can try external package like [https://github.com/4IceG/luci-app-3ginfo-lite](https://github.com/4IceG/luci-app-3ginfo-lite "https://github.com/4IceG/luci-app-3ginfo-lite") for displaying modem status and [https://github.com/4IceG/luci-app-sms-tool-js](https://github.com/4IceG/luci-app-sms-tool-js "https://github.com/4IceG/luci-app-sms-tool-js") for SMS support.

### Troubleshooting

***Everything is okay but modem doesn't establish connection. What can I try?***

You may want to try adding the argument *--get-client-id wds* and *--set-client-id* when running *uqmi* like:

```
wds=`uqmi -s -d /dev/cdc-wdm0 --get-client-id wds`
uqmi -d /dev/cdc-wdm0 --set-client-id wds,"$wds" --start-network your_apn
```

Moreover based on this [article](http://tiebing.blogspot.com/2015/03/linux-running-4g-lte-modem.html "http://tiebing.blogspot.com/2015/03/linux-running-4g-lte-modem.html") I discovered that need to reset my modem (tested on Dell Wireless 5804 413c:819b) in boot process, so you can try add the following commands in your /etc/rc.local:

```
/sbin/uqmi -d /dev/cdc-wdm0 --set-device-operating-mode offline
/sbin/uqmi -d /dev/cdc-wdm0 --set-device-operating-mode reset
/bin/sleep 20
/sbin/uqmi -d /dev/cdc-wdm0 --set-device-operating-mode online
/sbin/uqmi -d /dev/cdc-wdm0 --set-autoconnect enabled
/sbin/uqmi -d /dev/cdc-wdm0 --network-register
```

***My router is not detecting the modem. What should I do?***

Try the following commands:

```
usbmode -l
```

It should respond with a message about your USB device is detected. If it does, issue the next command. If it doesn't, you might want to get help from the forum.

```
usbmode -s
```

Then wait for the modem to get issued an IP from your ISP.

***No serial or network device is present (/dev/ttyUSB, /dev/cdc-wdm)***

You may need to install the missing packages

```
opkg install kmod-usb-net-qmi-wwan kmod-usb-serial-option kmod-usb-serial-qualcomm
```
