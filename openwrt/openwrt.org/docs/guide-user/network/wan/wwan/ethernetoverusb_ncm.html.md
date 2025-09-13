# Use NCM USB Dongle for WAN connection

[NCM](http://www.mcci.com/mcci-v5/hostside/ncm_drivers.html "http://www.mcci.com/mcci-v5/hostside/ncm_drivers.html") (Network Control Model) is [Ethernet over USB](https://en.wikipedia.org/wiki/Ethernet_over_USB "https://en.wikipedia.org/wiki/Ethernet_over_USB") protocol used by some USB modems.

The same applies to external modems connected to USB ports (“dongles”) and internal models installed into M.2(NGFF) or mPCIe slots.

For more information about other protocols commonly used:

- **PPP**, see [How to use 3g/UMTS USB Dongle for WAN connection](/docs/guide-user/network/wan/wwan/3gdongle "docs:guide-user:network:wan:wwan:3gdongle")
- **QMI** and **MBIM**, see [How to use LTE modem in QMI mode for WAN connection](/docs/guide-user/network/wan/wwan/ltedongle "docs:guide-user:network:wan:wwan:ltedongle")
- **ECM**, see [Use cdc\_ether driver based dongles for WAN connection](/docs/guide-user/network/wan/wwan/ethernetoverusb_cdc "docs:guide-user:network:wan:wwan:ethernetoverusb_cdc")
- **RNDIS**, see [How to use LTE modem in RNDIS mode for WAN connection](/docs/guide-user/network/wan/wwan/ethernetoverusb_rndis "docs:guide-user:network:wan:wwan:ethernetoverusb_rndis")

## Modem Preparation

You may need to switch your modem to provide a native **NCM** interface instead of *serial* **Modem** interface.

![:!:](/lib/images/smileys/exclaim.svg) Please read about [AT commands](/docs/guide-user/network/wan/wwan/at_commands "docs:guide-user:network:wan:wwan:at_commands") for your modem.

Once you've done - you can disconnect modem from the PC and connect it to the router.

## Router Preparation

1\. Install OpenWrt

2\. Complete steps [OpenWrt Configuration](/docs/guide-quick-start/checks_and_troubleshooting "docs:guide-quick-start:checks_and_troubleshooting")

Router should be turned on and connected to the Internet to get the needed packages. Please refer to: [Internet Connection](/docs/guide-user/network/wan/internet.connection "docs:guide-user:network:wan:internet.connection").

### Required Packages

To make use of NCM protocol, packages `kmod-usb-net-huawei-cdc-ncm` and `comgt-ncm` are needed (for Huawei modems). Other modems may require different `kmod-*` packages.

To access the PC UI Interface (AT Command port) package `kmod-usb-serial-option` is typically needed. Some modems may need `kmod-usb-acm` driver instead.

### Optional Packages

1\. Install `usb-modeswitch` *only if* that is needed for switching the modem into a “working” state. More about: [USB mode switch](/docs/guide-user/network/wan/wwan/usb-modeswitching "docs:guide-user:network:wan:wwan:usb-modeswitching")

2\. A terminal program like `picocom` will be needed to manually send AT commands.

3\. Add support for FlashCard of your dongle - refer to: [USB Storage](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives")

## Installation

1\. Install all the needed packages either in Luci → System → Software or via command line:

- For Huawei modems:

```
root@OpenWrt:~# opkg update
root@OpenWrt:~# opkg install kmod-usb-net-huawei-cdc-ncm luci-proto-ncm picocom
```

- other modems may require different packages, this is an example for Mikrotik modems:

```
root@OpenWrt:~# opkg update
root@OpenWrt:~# opkg install kmod-usb-net-rndis kmod-usb-acm luci-proto-ncm picocom
```

Additional packages will be automatically installed as *dependencies*.

You can also add the necessary packages when building a new image with [Firmware Selector](https://firmware-selector.openwrt.org/ "https://firmware-selector.openwrt.org/").

![:!:](/lib/images/smileys/exclaim.svg) If your have not enough space on your device - think about upgrading your hardware or installing [Rootfs on External Storage (extroot)](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration"). Refer to your router wiki page or forum thread for possibility and instructions.

2\. Reboot the router by executing `reboot` on the console.

3\. Check if you got a new *device*:

```
root@OpenWrt:~# ls -l /dev/cdc*

crw-r--r--    1 root     root      180, 176 Oct  1 12:03 /dev/cdc-wdm0
```

If there is no such device found, there is a possibility that completely different name is in use by the device driver, like `usb0` or `eth1`. Try to get more details:

- Open System Log from Luci web interface and see what it shows regarding newly discovered USB device(s)
- execute `dmesg` on the console and see if any relevant information is present in the kernel log
- check the details about USB devices detected by the system by running `cat /sys/kernel/debug/usb/devices` on the console:

```
[...]
T:  Bus=03 Lev=01 Prnt=01 Port=00 Cnt=01 Dev#=  2 Spd=480  MxCh= 0
D:  Ver= 2.10 Cls=00(>ifc ) Sub=00 Prot=00 MxPS=64 #Cfgs=  1
P:  Vendor=12d1 ProdID=1506 Rev= 1.02
S:  Manufacturer=HUAWEI_MOBILE
S:  Product=HUAWEI_MOBILE
C:* #Ifs= 5 Cfg#= 1 Atr=80 MxPwr=  2mA
I:* If#= 0 Alt= 0 #EPs= 3 Cls=ff(vend.) Sub=03 Prot=10 Driver=(none)
E:  Ad=82(I) Atr=03(Int.) MxPS=  10 Ivl=32ms
E:  Ad=81(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
E:  Ad=01(O) Atr=02(Bulk) MxPS= 512 Ivl=0ms
I:* If#= 1 Alt= 0 #EPs= 2 Cls=ff(vend.) Sub=03 Prot=12 Driver=option
E:  Ad=83(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
E:  Ad=02(O) Atr=02(Bulk) MxPS= 512 Ivl=0ms
I:  If#= 2 Alt= 0 #EPs= 1 Cls=ff(vend.) Sub=03 Prot=16 Driver=huawei_cdc_ncm
E:  Ad=85(I) Atr=03(Int.) MxPS=  16 Ivl=2ms
I:* If#= 2 Alt= 1 #EPs= 3 Cls=ff(vend.) Sub=03 Prot=16 Driver=huawei_cdc_ncm
E:  Ad=85(I) Atr=03(Int.) MxPS=  16 Ivl=2ms
E:  Ad=84(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
E:  Ad=03(O) Atr=02(Bulk) MxPS= 512 Ivl=0ms
I:* If#= 3 Alt= 0 #EPs= 2 Cls=08(stor.) Sub=06 Prot=50 Driver=usb-storage
E:  Ad=86(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
E:  Ad=04(O) Atr=02(Bulk) MxPS= 512 Ivl=125us
I:* If#= 4 Alt= 0 #EPs= 2 Cls=08(stor.) Sub=06 Prot=50 Driver=usb-storage
E:  Ad=87(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
E:  Ad=05(O) Atr=02(Bulk) MxPS= 512 Ivl=125us
```

See Troubleshooting Section of this page for more information.

## Configuration

### Protocol Configuration

[UCI](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") is supporting **NCM** network protocol configuration.

Name Type Required Default Description device file path yes (none) NCM device node, usually `/dev/ttyUSBx` or `/dev/ttyACMx`; acts as a control interface apn string yes (none) APN to use pincode number no (none) PIN code to unlock SIM card username string no (none) Username for PAP/CHAP authentication password string no (none) Password for PAP/CHAP authentication auth string no (none) Authentication type: **pap**, **chap**, **both**, **none** mode string no (modem default) Used network mode, not every device support every mode: **preferlte**, **preferumts**, **lte**, **umts**, **gsm**, **auto** pdptype string no IP PDP Context Type, **IP** (for IPv4), **IPV6** (for IPv6) or **IPV4V6** (for dual-stack) profile number no 1 PDP Context Identifier ifname string no (none) Data interface name delay number no 0 Seconds to wait before trying to interact with the modem (some modems require up to 30 s.)

You can configure the interface manually using [uci command line](/docs/techref/uci "docs:techref:uci") or [text editor](/docs/guide-user/base-system/user.beginner.cli#editingfiles "docs:guide-user:base-system:user.beginner.cli") or with [Luci](/docs/techref/luci "docs:techref:luci") package **luci-proto-ncm**.

![:!:](/lib/images/smileys/exclaim.svg) If option “mode” is set, the corresponding AT command is sent to the modem on every connection attempt. Most of modems (at least all Huawei models) store this setting in internal flash. So on each connection OpenWrt writes to modem flash. It is recommended to not use this option after the required mode is set once.

### Network configuration

Using Luci web interface: navigate to Network → Interfaces → Add new interface… → Protocol : NCM, Interface: “ttyUSB1”

The interface selected above is the “AT Command Port” or “PCUI” in Huawei terms, `ttyUSB1` is shown here as an example only, different modems have different port assignments like `/dev/ttyUSBx` or `/dev/ttyACMx`. The *data* interface like `wwan0` and corresponding device like `/dev/cdc-wdm0` will be discovered by the connection script automatically.

Enter your APN and select the 'IP Protocol' as instructed by the carrier.

Assign the firewall zone (wan) on 'Firewall Settings' tab.

Alternatively you can edit the configuration files with any text editor like `vi` or `nano`:

- add a new **Interface** in `/etc/config/network`:

```
config interface 'wwan'
        option proto 'ncm'
        option device '/dev/ttyUSB1'
        option pdptype 'IP'
        option apn 'internet'
```

- add the same interface name to the “wan” firewall zone in `/etc/config/firewall`:

```
config zone
    option name 'wan'
    [...]
    list network 'wwan'
```

### Additional Steps

Some providers of mobile Internet use Web redirection to their service pages for access activation, modem configuration, etc. If a *private* (rfc1918) IP address is used in redirection (example: YOTA in Russia), name resolution will be blocked by `dnsmasq` by default:

```
Jan 18 14:36:49 OpenWrt daemon.warn dnsmasq[1325]: possible DNS-rebind attack detected: my.yota.ru
```

To overcome this issue add the required domain to a *whitelist*: navigate in LuCI to “Network” → “DHCP and DNS” → “Filter” tab and type “yota.ru” without quotes in the “Domain whitelist” field then click on “+” next to it. Save &amp; apply.

## Troubleshooting

### My router is not detecting the modem. What should I do?

Get the information about USB devices with `cat /sys/kernel/debug/usb/devices`

Find a section for your device, look for “Manufacturer” and/or “Product” lines corresponding to your modem, for example:

```
S:  Manufacturer=HUAWEI_MOBILE
S:  Product=HUAWEI_MOBILE
```

See if necessary drivers are loaded for your device:

```
I:* If#= 1 Alt= 0 #EPs= 2 Cls=ff(vend.) Sub=03 Prot=12 Driver=option
[...]
I:  If#= 2 Alt= 0 #EPs= 1 Cls=ff(vend.) Sub=03 Prot=16 Driver=huawei_cdc_ncm
```

If the drivers are missing, install the missing packages and/or change the operating mode of the modem to expose the necessary interfaces.

Finally, ask in the forum.

### My modem doesn't reconnect after it loses the connection

This script [GitHub oilervoss](https://github.com/oilervoss/openvpnForNordvpn/tree/master/etc/init.d "https://github.com/oilervoss/openvpnForNordvpn/tree/master/etc/init.d") will check the connection pinging a public IP and, under failure, it will send AT commands to the serial interface of the modem restarting it.

To achieve continuous monitoring of the connection, it must be called recurrently through a cron job as:

```
#/etc/crontabs/root
#min    h   day  mon  week  command
*/20    *    *    *    *    /etc/init.d/ncm-fix start
```

### I am using 'huawei\_cdc\_ncm' module and the /dev/cdc-wdm0 does not respond. What do I do?

This is probably related to ticket #18673 ([https://dev.openwrt.org/ticket/18673](https://dev.openwrt.org/ticket/18673 "https://dev.openwrt.org/ticket/18673")). You should be able to use the modem by starting ndis manually by sending the following to */dev/ttyUSB1*

```
AT^NDISDUP=1,1,"your_apn_address"
```

It is possible to automate this task using [hotplug](/docs/techref/hotplug_legacy "docs:techref:hotplug_legacy"). Below are some scripts fetched from [http://forum.ixbt.com/post.cgi?id=print:14:59307&amp;page=4](http://forum.ixbt.com/post.cgi?id=print%3A14%3A59307&page=4 "http://forum.ixbt.com/post.cgi?id=print:14:59307&page=4"). Do not forget to modify them to your needs. The scripts are for Huawei modems obviously.

*/etc/init.d/ncm-network*:

```
#!/bin/sh /etc/rc.common

#
DEVICE='/dev/ttyUSB1'
# Interface name from /etc/config/network
IFNAME='WWAN'
# Your APN:
APN='your_apn_here'

START=70
STOP=90

start() {
        if [ -e ${DEVICE} ]; then
                echo -ne "AT^NDISDUP=1,0\r\n" > ${DEVICE}
                sleep 3
                echo -ne "AT^NDISDUP=1,1,\"${APN}\"\r\n" > ${DEVICE}
                sleep 3
                ifup $IFNAME
        else
                echo "No such device ${DEVICE}" | logger -t "ncm-network[$$]" -p info
        fi
}

stop() {
        if [ -e ${DEVICE} ]; then
                ifdown $IFNAME
                sleep 3
                echo -ne "AT^NDISDUP=1,0\r\n" > ${DEVICE}
        else
                echo "No such device ${DEVICE}" | logger -t "ncm-network[$$]" -p info
        fi
}
```

*/etc/hotplug.d/usb/70-ncm-network*

```
#!/bin/sh

# Uncomment set line below and check your modalias I from tmp file
MODEM_ID='usb:v12D1p1506d0102dc00dsc00dp00ic08isc06ip50in05'
PAUSE=10
PAUSE_FOR_HOTPLUG=5

#set >> /tmp/ncm-network.debug

if [ "${MODALIAS}" != "${MODEM_ID}" ]; then
        exit 0
fi

case "$ACTION" in
        add)
                SYSTEM_UPTIME=$(cat /proc/uptime | awk -F"\." '{ print $1 }')
                if [ "${SYSTEM_UPTIME}" -gt 60 ]; then
                        PAUSE=$PAUSE_FOR_HOTPLUG
                fi
                {
                sleep ${PAUSE} && \
                echo "Start modem ${MODEM_ID}" | logger -t "hotplug[$$]" -p info && \
                /etc/init.d/ncm-network start
                } &
                ;;
        remove)
                echo "Stop modem ${MODEM_ID}" | logger -t "hotplug[$$]" -p info
                /etc/init.d/ncm-network stop
                ;;
esac
```

Some modems does not reconnect after losing connection. Here is a connection check sh script which checks if it can ping remote servers with time intervals. If all pings fail, it tries to start the network by executing */etc/init.d/ncm-network start*

```
#!/bin/sh

# Enter the FQDNs you want to check with ping (space separated)
# Script does nothing if any tries to any FQDN succeeds
FQDN="www.google.com"
FQDN="$FQDN www.amd.com"
FQDN="$FQDN www.juniper.net"

# Sleep between ping checks of a FQDN (seconds between pings)
SLEEP=3                         # Sleep time between each retry
RETRY=3                         # Retry each FQDN $RETRY times
SLEEP_MAIN=60                   # Main loop sleep time

check_connection()
{
  for NAME in $FQDN; do
    for i in $(seq 1 $RETRY); do
      ping -c 1 $NAME > /dev/null 2>&1
      if [ $? -eq 0 ]; then
        return 0
      fi
      sleep $SLEEP
    done
  done
  # If we are here, it means all failed
  return 1
}

while true; do
  check_connection
  if [ $? -ne 0 ]; then
    /etc/init.d/ncm-network start
  fi
  sleep $SLEEP_MAIN
done
```

If your SIM receives a voice call. It will downgrade to CS network which means you will downgrade into 3G mode. To avoid this, set the stick to use only PS network by creating \`/etc/hotplug.d/iface/99-ifupwwan\` file with following code. Make sure to modify it to use correct serial interface and correct AT command for your device.

```
[ "$ACTION" = "ifup" -a "$INTERFACE" = "wwan" ] && {
    logger "iface wwan up detected..."
    # We need to set this to stop the card from receiving phone calls
    # This is for EC-25
    #echo -ne "\r\nAT+QCFG=\"servicedomain\",1,1\r\n" > /dev/ttyUSB2
    # This is for Huawei
    echo -ne "\r\nAT^SYSCFGEX=\"00\",3FFFFFFF,1,1,7FFFFFFFFFFFFFFF,,\r\n" > /dev/ttyUSB2
}
```
