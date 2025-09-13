## Identify Wi-Fi connection as metered on Windows automatically

![:!:](/lib/images/smileys/exclaim.svg) *Due to End of Life of Windows 8.0 and Windows 2008 R2, this content only applies to current Windows versions: Windows 8.1\\10, Windows Server 2012\\2012 R2\\2016\\2019. All current Windows versions just named **Windows** in this document.*

![:!:](/lib/images/smileys/exclaim.svg) Provided method works mainly for Windows devices.

### Theory and Lyrics

#### Metered Connection Idea

Modern devices implement concept of metered connections.  
In simple, metered connection is an internet connection where you pay for amount data transmitted.  
In modern world, most common metered connections are mobile broadband connections - 3G, 4G LTE, 5G.

While connected over metered connection, device **may** reduce amount of data it transmits over this connection.  
For example, Windows 10 device will download only critical and security updates and postpone feature updates when device knows it is connected over metered connection.

#### Metered Connection Usefulness

Setting connection as metered can be userful for uplinks that can not satisfy daily client device operation to lower data consumption.  
For example, if you have Wireless router with LTE modem as uplink and your LTE connection is far from ideal, It's good for Wi-Fi clients to know that there is a bottleneck on the way to Internet somewhere to postpone non-critical high-bandwidth operations.

#### Second Hop problem

Windows detects connection as metered from 802.11 (Wi-Fi) beacons and probe responses.  
This means Windows will only see fast Wi-Fi connection and will not see that there is a slow 3G modem behind it.  
Solution is to tell Windows device that Wi-Fi connection should be treated as metered connection.

### Configuration

#### check status with windows

Check current connection status on your Windows PC: run `powershell.exe` and execute commands

```
  [void][Windows.Networking.Connectivity.NetworkInformation, Windows, ContentType = WindowsRuntime]
  [Windows.Networking.Connectivity.NetworkInformation]::GetInternetConnectionProfile().GetConnectionCost() | FL
```

As a result, you shall see output like this

```
  ApproachingDataLimit          : False
  NetworkCostType               : Unrestricted
  OverDataLimit                 : False
  Roaming                       : False
  BackgroundDataUsageRestricted : False
```

When `NetworkCostType` is `Unrestricted` or `Unknown` and everything else is `False`, connection treated as non-measured. If you see another values, probably you set connection as measured manually. In this case, you should better forget the network and connect again.

You can also check it is determined as `metered connection` by clicking `Wi-Fi icon` in system tray → `Properties` under connected network and see switch `metered connection` is off

#### check status with Network Manager (Linux)

```
# find your wireless device name
nmcli --get-values GENERAL.DEVICE,GENERAL.TYPE device show
# replace wlp2s0 with your wireless device name
nmcli -t -f GENERAL.METERED dev show wlp2s0
```

Open OpenWrt console and execute

```
# For radio0 interface
  # Print current value if it exists.
  uci show     wireless.radio0.hostapd_options
  # Delete current value if it exists.
  uci delete   wireless.radio0.hostapd_options
  # Write new value.
  uci add_list wireless.radio0.hostapd_options='vendor_elements=DD080050F21102000200'
 
# Same for radio1 interface if exists
  # Print current value if it exists.
  uci show     wireless.radio1.hostapd_options
  # Delete current value if it exists.
  uci delete   wireless.radio1.hostapd_options
  # Write new value.
  uci add_list wireless.radio1.hostapd_options='vendor_elements=DD080050F21102000200'
 
# Commit and reboot
  uci commit
  reboot
```

After reouter reboots, disconnect from Wi-Fi on Windows device and connect again. Check connection again using `powershell.exe`. Now it will show connection as `NetworkCostType: Fixed`. If not, try to *forget* wireless network and connect again.

```
# you can also activate vendor_elements for a single SSID only:
# see if the value already exists
uci show wireless.default_radio0.vendor_elements
# set vendor_elemts
uci set wireless.default_radio0.vendor_elements='DD080050F21102000200'
# commit config
uci commit
```

* * *

### Under the hood

Windows devices relies on Wi-Fi Beacon and Probe Response frames.  
IEEE802.11-2012 added ability to define custom information in Wi-Fi frames. They are called `Vendor-Specific Information Elements` or `IE`.  
Microsoft introduced special `Network Cost Information` element that gives ability for Windows to determine some connection information.  
It is documented in [MS-NCT](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-nct "https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-nct") document.  
It is implemented since Windows 8 and Server 2012.  
To enable Windows clients to detect Wi-Fi connection as metered, you need to implement this `Information Element` on your Wi-Fi Access Point.  
It can be done through `vendor_elements` configuration option for `hostapd`.  
And `hostapd` configuration files are generated on-the-fly from `uci` data.  
We use `uci` option to add field `vendor_elements` with value to `hostapd` configuration.

We use value `DD 08 00 50 F2 11 02 00 02 00`:

- `DD` This is IE type means `Vendor-Specific`
- `08` Length of IE data (8 bytes)
- `00 50 F2` OUI ID (Vendor ID). This match `Microsoft`
- `11` OUI Type. Type of data in this IE. `0x11` means `Network Cost Information`
- `02` Cost Level `Fixed`. This connection is fixed-cost connection. *Linux NetworkManager note: NM &gt; 1.31.5 treats connection as metered if this value is greater than `0x01`. NM 1.31.5 and before mistakenly ignores this value due to [bug](https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/issues/734 "https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/issues/734")*
- `00` Reserved byte, should be `00`
- `02` Cost Flag `Congested`. The network operator is experiencing or expecting heavy load. *Linux NetworkManager note: This byte is ignored by NM.*
- `00` Reserved byte, should be `00`. *Linux NetworkManager note: NM 1.31.5 and before due to a [bug](https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/issues/734 "https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/issues/734") mistakenly interprets this value as `Cost level`. It treats connection as metered when this value is greater than `0x01`*

* * *

### References

- [\[MS-NCT\]: Network Cost Transfer Protocol](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-nct/ "https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-nct/")
- [''hostapd\_options'' ''uci'' option precessing](https://github.com/openwrt/openwrt/blob/19bf1642912b120403d52bf685818b10e3736079/package/network/services/hostapd/files/hostapd.sh#L218 "https://github.com/openwrt/openwrt/blob/19bf1642912b120403d52bf685818b10e3736079/package/network/services/hostapd/files/hostapd.sh#L218") ([Implemented since v18.06.0-rc1](https://github.com/openwrt/openwrt/commit/9f5f5d250e7537f15fd668fa737ead719f910245 "https://github.com/openwrt/openwrt/commit/9f5f5d250e7537f15fd668fa737ead719f910245"))
- [Network cost information element description.](https://docs.microsoft.com/en-us/windows-hardware/drivers/mobilebroadband/network-cost-information-element "https://docs.microsoft.com/en-us/windows-hardware/drivers/mobilebroadband/network-cost-information-element") - ![:!:](/lib/images/smileys/exclaim.svg) Recommended for reading only after \[MS-NCT]. Not recommended as primary reference.
