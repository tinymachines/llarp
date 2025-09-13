# Wi-Fi /etc/config/wireless

The UCI wireless configuration is located in `/etc/config/wireless`. Note that if the device has Ethernet ports, wireless is turned **off** by default and using LuCI → Network → Wireless will also write to this file.

See also: [How do I enable Wi-Fi?](/faq/how_do_i_enable_wifi "faq:how_do_i_enable_wifi")

## Sections

A typical wireless config file contains at least a pair of:

- *wifi-device* - specifies general radio properties like channel, driver type, and txpower
- *wifi-iface* - defines a wireless network on top of the *wifi-device*

## Wi-Fi devices

The *wifi-device* refer to physical radio devices present on the system. The options present in this section describe properties common across all wireless interfaces on this radio device, such as channel or antenna selection.

A minimal *wifi-device* declaration may look like the example below. Note that identifiers and options may vary for different chipset types or drivers.

```
config	wifi-device	'wl0'
	option	type	'broadcom'
	option	channel	'6'
```

- *wl0* is the *internal identifier* for the wireless adapter
- *broadcom* specifies the *chipset/driver type*
- *6* is the [wireless channel](https://en.wikipedia.org/wiki/List_of_WLAN_channels "https://en.wikipedia.org/wiki/List_of_WLAN_channels") the device operates on

The possible options for device sections are listed in the table below. Note that not all options are used for all chipset/driver types, refer to the comments for further details.

### Common options

Name Type Required Default Description *type* string yes *(autodetected)* The *type* is determined on firstboot during the initial radio device detection - it is usually not required to change it. Used values are *broadcom* on brcm47xx, or *mac80211* for all other platforms *phy* string no/yes *(autodetected)* Specifies the radio phy associated to this section. If present, it is usually autodetected and should not be changed. *macaddr* MAC address yes/no *(autodetected)* Specifies the radio adapter associated to this section, it is *not* used to change the device mac but to identify the underlying interface. *disabled* boolean no *0* Disables the radio adapter if set to *1*. Removing this option or setting it to *0* will enable the adapter *channel* integer or “auto” yes *auto* Specifies the wireless channel. “auto” defaults to the lowest available channel, or [utilizes the ACS algorithm](https://forum.openwrt.org/t/wi-fi-channel-auto-selection/47776/8 "https://forum.openwrt.org/t/wi-fi-channel-auto-selection/47776/8") depending on hardware/driver support. *channels* list no *(regulatory domain specific)* Use specific channels, when channel is in “auto” mode. This option allows hostapd to select one of the provided channels when a channel should be automatically selected. Channels can be provided as range using hyphen ('-') or individual channels can be specified by space (' ') separated values. *hwmode* string no *(driver default)* Specifies the hardware mode, possible values are *11b* for 2.4 GHz (used for legacy 802.11b only), *11g* for 2.4 GHz (used for 802.11b, 802.11g and 802.11n) and *11a* for 5 GHz (used for 802.11a, 802.11n and 802.11ac). Note that 11ng, 11na, 11n and 11ac are invalid options, this setting should largely be seen as controlling the frequency band. (**DEPRECATED** since 21.02.2, replaced with *band*) *band* string no *(driver default)* Specifies the band, possible values are *2g* for 2.4 GHz, *5g* for 5 GHz, *6g* for 6 GHz and *60g* for 60 GHz. (**NEW** since 21.02.2, replaces *hwmode*) *htmode* string no *(driver default)* Specifies the high throughput mode, used to control 802.11n (HT), 802.11ac (VHT) and 802.11ax (HE). The channel width used for these depends on this configuration. See [this section](/docs/guide-user/network/wifi/basic#htmodewi-fi_channel_width "docs:guide-user:network:wifi:basic") for details. Possible values are: *HT20*, *HT40-*, *HT40+*, *HT40*, or *VHT20*, *VHT40*, *VHT80*, *VHT160*, *NOHT* disables 11n and 11ac, HE20, HE40, HE80, HE160 *chanbw* integer no 20 Specifies a narrow channel width in MHz, possible values are: *5*, *10*, *20* *ht\_capab* string no *(driver default)* Specifies the available capabilities of the radio. The values are autodetected. See [here](http://w1.fi/cgit/hostap/tree/hostapd/hostapd.conf "http://w1.fi/cgit/hostap/tree/hostapd/hostapd.conf") for options (check vs. the version of hostapd installed on your router using the “refs” link) *txpower* integer no *(driver default)* Specifies the maximum desired *transmission power in dBm*. The actual txpower used depends on regulatory requirements. *diversity* boolean no *1* Enables or disables the automatic antenna selection by the driver *rxantenna* integer no *(driver default)* Specifies the *antenna for receiving*, the value may be driver specific, usually it is *1* for the first and *2* for the second antenna. Specifying *0* enables automatic selection by the driver if supported. This option has no effect if diversity is enabled *txantenna* integer no *(driver default)* Specifies the *antenna for transmitting*, values are identical to *rxantenna* *country* varies no *(driver default)* Specifies the country code, affects the available channels and transmission powers. For types *mac80211* and *broadcom* a two letter country code is used (*EN* or *DE*). The *madwifi* driver expects a numeric code. *country\_ie* boolean no 1 if *country* is set, otherwise 0 Enables IEEE 802.11d country IE (information element) advertisement in beacon and probe response frames. This IE contains the country code and channel/power map. Requires *country*. *distance* string no *(driver default)* Distance between the ap and the furthest client in meters. *beacon\_int* integer no *100 (hostapd default)* Set the beacon interval. This is the time interval between beacon frames, measured in units of 1.024 ms. hostapd permits this to be set between 15 and 65535. This option has no effect on *sta* type wifi-ifaces *legacy\_rates* boolean no *1 in 19.07, 0 in 21.02* 0 = Disallow legacy 802.11b data rates, 1 = Allow legacy 802.11b data rates. Legacy or badly behaving devices may require legacy 802.11b rates to interoperate. Airtime efficiency may be significantly reduced where these are used. It is recommended to not allow 802.11b rates where possible. The basic\_rate and supported\_rates options overrides this option. *require\_mode* string no *none* Sets the minimum client capability level mode that connecting clients must support to be allowed to connect. Overrides and sets legacy\_rates to 0 to disable legacy 802.11b data rates. Supported values: n = 802.11n, ac = 802.11ac  
![:!:](/lib/images/smileys/exclaim.svg) Warning: setting this value to “ac” causes reliability problems from Apple devices, even if they actually support 802.11ac or better. *cell\_density* integer no *0, supported in 21.02* Configures data rates based on the coverage cell density. Normal configures basic rates to 6, 12, 24 Mbps if legacy\_rates is 0, else to 5.5, 11 Mbps. High configures basic rates to 12, 24 Mbps if legacy\_rates is 0, else to the 11 Mbps rate. Very High configures 24 Mbps as the basic rate. Supported rates lower than the minimum basic rate are not offered. The basic\_rate and supported\_rates options overrides this option. 0 = Disabled, 1 = Normal, 2 = High, 3 = Very High *basic\_rate* list no *(hostapd/driver default)* Set the basic data rates. Each basic\_rate is measured in kb/s. This option only has an effect on *ap* and *adhoc* wifi-ifaces. It is recommended to use the cell\_density option instead. *supported\_rates* list no *(hostapd/driver default)* Set the supported data rates. Each supported rate is measured in kb/s. This option only has an effect on *ap* and *adhoc* wifi-ifaces. This must be a superset of the rates set in basic\_rate. The minimum basic rate should also be the minimum supported rate. It is recommended to use the cell\_density option instead. *log\_level* integer no 2 Set the log\_level. Supported levels are: 0 = Verbose Debugging, 1 = Debugging, 2 = Informational Messages, 3 = Notification, 4 = Warning *hostapd\_options* list no *none* Pass any custom options to `hostapd-*.conf`. Values passed *as-is*. For example, used when setting vendor-specific informational element to [make Windows clients detect Wi-Fi as metered connection](/docs/guide-user/network/wifi/ms-meteredconnection "docs:guide-user:network:wifi:ms-meteredconnection")

### MAC80211 options

Name Type Required Default Description *path* string no *(none)* Alternative to phy used to identify the device based paths in /sys/devices *htmode* string no *(driver default)* Specifies the channel width in 802.11n and 802.11ac mode, possible values are:  
HT20 (single 20MHz channel),  
HT40- (2x 20MHz channels, primary/control channel is upper, secondary channel is below),  
HT40+ (2x 20MHz channels, primary/control channel is lower, secondary channel is above),  
HT40 (2x 20Mz channels, auto selection of upper or lower secondary channel on versions 14.07 and above),  
NONE (disables 802.11n rates and enforce the usage of legacy 802.11 b/g/a rates)  
VHT20 / VHT40 / VHT80 / VHT160 (channel width in 802.11ac, extra channels are picked according to the specification)  
HE20 / HE40 / HE80 / HE160 (channel width in 802.11ax)  
See also: [Why can't I use HT40+ with channel 11?](https://forum.archive.openwrt.org/viewtopic.php?id=22742&p=48#p156165 "https://forum.archive.openwrt.org/viewtopic.php?id=22742&p=48#p156165")  
![:!:](/lib/images/smileys/exclaim.svg) See HT (high throughput) capabilities below for options to customize high-throughput modes *chanbw* integer no 20 Specifies a narrow channel width, possible values are: 5 (5MHz channel), 10 (10MHz channel) or 20 (20MHz channel).  
![:!:](/lib/images/smileys/exclaim.svg) Only supported by the ath9k/ath5k driver *noscan* boolean no 0 Do not scan for overlapping BSSs in HT40+/- mode.  
![:!:](/lib/images/smileys/exclaim.svg) Turning this on will violate regulatory requirements! *beacon\_int* integer no 100 *(hostapd default)* Set the beacon interval. This is the time interval between beacon frames, measured in units of 1.024 ms. hostapd permits this to be set between 15 and 65535. This option has no effect on *sta* type wifi-ifaces. *basic\_rate* list no *(hostapd/driver default)* Set the supported basic rates. Each basic\_rate is measured in kb/s. This option only has an effect on ap and adhoc wifi-ifaces. *supported\_rates* list no *(hostapd/driver default)* Set the supported rates. Each supported\_rates is measured in kb/s. This option only has an effect on ap wifi-ifaces. *ht\_coex* integer no 0 Disable honoring 40 MHz intolerance in coexistence flags of stations. When enabled, the radio will *not* stop using the 40 MHz channels if the 40 MHz intolerance indication is received from another AP or station. *frag* integer no *(none)* Fragmentation threshold *rts* integer no *(driver default)* Override the RTS/CTS threshold *antenna\_gain* integer no 0 Reduction in antenna gain from regulatory maximum in dBi

### Broadcom options

![:!:](/lib/images/smileys/exclaim.svg) The options below are only used by the proprietary Broadcom driver (type *broadcom*).

Name Type Required Default Description *frameburst* boolean no *0* Enables Broadcom frame bursting (Xpress Technology) if supported *maxassoc* integer no *(driver default)* Limits the maximum allowed number of associated clients *slottime* integer no *(driver default)* Slot time in milliseconds

### Ubiquiti Nanostation options

![:!:](/lib/images/smileys/exclaim.svg) The options below are only used by the Ubiquiti Nanostation family of devices.

Name Type Required Default Description *antenna* string no *(driver default)* Specifies the antenna, possible values are *vertical* for internal vertical polarization, *horizontal* for internal horizontal polarization or *external* to use the external antenna connector

## Wi-Fi interfaces

A complete wireless configuration contains at least one *wifi-iface* section per adapter to define a wireless network on top of the hardware. Some drivers support multiple wireless networks per device:

- *broadcom* if the core revision is greater or equal *9* (see *dmesg | grep corerev*)
- *mac80211*

A minimal example for a *wifi-iface* declaration is given below.

```
config	wifi-iface
	option	device		'wl0'
	option	network		'lan'
	option	mode		'ap'
	option	ssid		'MyWifiAP'
	option	encryption	'psk2'
	option	key		'secret passphrase'
```

- *wl0* is the identifier for the underlying radio hardware
- *lan* specifies the network interface that the Wi-Fi is attached to.
- *ap* is the operation mode, *Access Point* in this example
- *MyWifiAP* is the broadcasted SSID
- *psk2* specifies the wireless encryption method, WPA2 PSK here
- *secret passphrase* is the secret WPA passphrase, at least 8 characters long

### Common Options

The common configuration options for *wifi-iface* sections are listed below.

Name Type Required Default Description *ifname* string no *(driver default)* Specifies a custom name for the Wi-Fi interface, which is otherwise automatically named. Maximum length: 15 characters. Note that [DSA support](/docs/guide-user/network/dsa/start "docs:guide-user:network:dsa:start") does not affect wireless configuration, so this option is still valid. *device* string yes *(first device id)* Specifies the used wireless adapter, must refer to one of the defined *wifi-device* sections. *network* string array yes *lan* Specifies one or multiple logical network interfaces declared in the network configuration, each one should be a L3 bridge to be able to attach this L2 wireless interface. *mode* string yes *ap* Specifies the operation mode of the wireless network interface controller. Possible values are *ap*, *sta*, *adhoc*, *monitor*, *mesh*. NB: for wds mode, use `option wds 1` with either `option mode 'ap`' or `option mode 'sta`'. *disabled* boolean no *0* When set to 1, wireless network is disabled. *ssid* string yes OpenWrt The broadcasted SSID of the wireless network and for for managed mode the SSID of the network you’re connecting to. *bssid* BSSID address no *(driver default)* Override the BSSID of the network, only applicable in *adhoc* or *sta* mode. In *wds* mode specifies the BSSID of another AP to create WDS with. *mesh\_id* Mesh ID no none The Mesh ID as defined in IEEE 802.11s. If set, the wireless interface will join this mesh network when brought up. If not, it is necessary to invoke *iw &lt;iface&gt; mesh join &lt;mesh\_id&gt;* to join a mesh after the interface is brought up. *hidden* boolean no *0* Disables the broadcasting of beacon frames if set to *1* and, in doing so, hides the ESSID. Where the ESSID is hidden, clients may fail to roam and airtime efficiency may be significantly reduced. *isolate* boolean no *0* Isolates wireless clients from each other, only applicable in *ap* mode. See [this](https://forum.openwrt.org/t/clients-in-same-wlan-cant-reach-each-other/2501/22 "https://forum.openwrt.org/t/clients-in-same-wlan-cant-reach-each-other/2501/22") post for details. *bridge\_isolate* boolean no *0* Isolates wireless clients from each other on the AP's bridge. (i.e. 2.4ghz and 5ghz radios on the same AP.) *doth* boolean no *0* Enables 802.11h support. *wmm* boolean no *1* Enables WMM. Where Wi-Fi Multimedia (WMM) Mode QoS is disabled, clients may be limited to 802.11a/802.11g rates. Required for 802.11n/802.11ac/802.11ax. *encryption* string no *none* Wireless encryption method. Possible values are listed in the [encryption values](/docs/guide-user/network/wifi/basic#encryption_modes "docs:guide-user:network:wifi:basic") table, right after this table. *key* integer or string no *(none)* In any **WPA-PSK** mode, this is a string that specifies the pre-shared passphrase from which the pre-shared key will be derived. The clear text key has to be 8-63 characters long. If a 64-character hexadecimal string is supplied, it will be used directly as the pre-shared key instead. In **WEP** mode, this can be an integer specifying which key index to use (*key1*, *key2*, *key3*, or *key4*.) Alternatively, it can be a string specifying a passphrase or key directly, as in *key1*. In any **WPA-Enterprise AP** mode, this option has a different interpretation. *key1* string no *(none)* WEP passphrase or key #1 (selected by the index in *key*). This string is treated as a passphrase from which the WEP key will be derived. If a 10- or 26-character hexadecimal string is supplied, it will be used directly as the WEP key instead. *key2* string no *(none)* WEP passphrase or key #2 (selected by the index in *key*), as in *key1*. *key3* string no *(none)* WEP passphrase or key #3 (selected by the index in *key*), as in *key1*. *key4* string no *(none)* WEP passphrase or key #4 (selected by the index in *key*), as in *key1*. *macfilter* string no *disable* Specifies the *mac filter policy*, *disable* to disable the filter, *allow* to treat it as whitelist or *deny* to treat it as blacklist. *maclist* list of MAC addresses no *(none)* List of MAC addresses (divided by spaces) to put into the mac filter. *iapp\_interface* string no *(none)* Specifies a network interface to be used for 802.11f (IAPP) - only enabled when defined. *rsn\_preauth* boolean no *0* Allow preauthentication for WPA2-EAP networks (and advertise it in WLAN beacons). Only works if the specified network interface is a bridge. *ieee80211w* integer no *0* Enables MFP (802.11w) support (0 = disabled, 1 = optional, 2 = required). **Requires the 'full' version of wpad/hostapd and support from the Wi-Fi driver** *ieee80211w\_max\_timeout* integer no *(hostapd default)* Specifies the 802.11w Association SA Query maximum timeout. *ieee80211w\_retry\_timeout* integer no *(hostapd default)* Specifies the 802.11w Association SA Query retry timeout. *sae\_require\_mfp* boolean no 1 Require MFP for all associations using SAE. Useful for when 802.11w is set to optional for WPA2/WPA3 mixed mode. *maxassoc* integer no *(hostapd/driver default)* Specifies the maximum number of clients to connect. *macaddr* MAC address or string no *(hostapd/driver default)* Overrides the MAC address used for the Wi-Fi interface. Warning: if the MAC address specified is a multicast address, this override will fail silently. To avoid this problem, ensure that the MAC address specified is a valid unicast MAC address.  
When set to `random`, a new locally administered unicast MAC address is generated and assigned to the iface everytime it is (re-)configured. *dtim\_period* integer no *2 (hostapd default)* Set the DTIM (delivery traffic information message) period. There will be one DTIM per this many beacon frames. This may be set between 1 and 255. This option has no effect on *sta* type wifi-ifaces. *short\_preamble* boolean no *1* Set optional use of short preamble *max\_listen\_int* integer no *65535 (hostapd default)* Set the maximum allowed STA (client) listen interval. Association will be refused if a STA attempts to associate with a listen interval greater than this value. This option only has an effect on *ap* wifi-ifaces. *mcast\_rate* integer no *(driver default)* Sets the fixed multicast rate, measured in kb/s. **Only supported in adhoc and mesh modes** *wds* boolean no *0* This sets [4-address mode](https://wireless.wiki.kernel.org/en/users/documentation/iw#using_4-address_for_ap_and_client_mode "https://wireless.wiki.kernel.org/en/users/documentation/iw#using_4-address_for_ap_and_client_mode") *owe\_transition\_ssid* string no *none* Opportunistic Wireless Encryption (OWE) Transition SSID (only for OPEN and OWE networks) *owe\_transition\_bssid* BSSID address no *none* Opportunistic Wireless Encryption (OWE) Transition BSSID (only for OPEN and OWE networks) *sae\_pwe* integer no *0 (hostapd default)* Sets the SAE mechanism for PWE derivation (0 = hunting-and-pecking only, 1 = hash-to-element only, 2 = both hunting-and-pecking and hash-to-element) *ocv* integer no *0 (hostapd/wpa\_supplicant default)* Configuration option for Operating Channel Validation. When operating as an access point the following options are available: 0 = disabled, 1 = enabled, 2 = enabled in workaround mode - Allow STA that claims OCV capability to connect even if the STA doesn't send OCI or negotiate PMF.

When operating in client mode the following options are available: 0 = disabled, 1 = enabled if wpa\_supplicant's SME in use. Otherwise enabled only when the driver indicates support for operating channel validation. *start\_disabled* boolean no *0* For an AP, start with beaconing disabled by default (see *start\_disabled* in hostapd.conf). Note that if an interface with mode *sta* is also defined on the same radio, *start\_disabled* will be added in the hostapd configuration, regardless of the value set for the AP. *default\_disabled* boolean no *0* For an STA, add *disabled* to the default wpa\_supplicant network block (to prevent it from scanning by default). The network block can still be enabled, for example by using *wpa\_cli* (see *disabled* in wpa\_supplicant.conf). *hostapd\_bss\_options* list no *none* Pass any custom options to `hostapd-*.conf`. Values passed *as-is*.

### Encryption Modes

Besides the encryption mode, the *encryption* option also specifies the group and peer ciphers to use. To override the cipher, the value of *encryption* must be given in the form *mode+cipher*. See the listing below for possible combinations.

WPA3 modes are supported by default starting with the [OpenWrt 21.02](/releases/21.02/notes-21.02.0#wpa3_support_included_by_default "releases:21.02:notes-21.02.0") release.

Value Type Ciphers Supported since *none* no authentication none *sae* WPA3 Personal (SAE) CCMP 19.07 *sae-mixed* WPA2/WPA3 Personal (PSK/SAE) mixed mode CCMP 19.07 *psk2+tkip+ccmp* WPA2 Personal (PSK) TKIP, CCMP *psk2+tkip+aes* WPA2 Personal (PSK) TKIP, CCMP *psk2+tkip* WPA2 Personal (PSK) TKIP *psk2+ccmp* WPA2 Personal (PSK) CCMP *psk2+aes* WPA2 Personal (PSK) CCMP *psk2* WPA2 Personal (PSK) CCMP *psk+tkip+ccmp* WPA Personal (PSK) TKIP, CCMP *psk+tkip+aes* WPA Personal (PSK) TKIP, CCMP *psk+tkip* WPA Personal (PSK) TKIP *psk+ccmp* WPA Personal (PSK) CCMP *psk+aes* WPA Personal (PSK) CCMP *psk* WPA Personal (PSK) CCMP *psk-mixed+tkip+ccmp* WPA/WPA2 Personal (PSK) mixed mode TKIP, CCMP *psk-mixed+tkip+aes* WPA/WPA2 Personal (PSK) mixed mode TKIP, CCMP *psk-mixed+tkip* WPA/WPA2 Personal (PSK) mixed mode TKIP *psk-mixed+ccmp* WPA/WPA2 Personal (PSK) mixed mode CCMP *psk-mixed+aes* WPA/WPA2 Personal (PSK) mixed mode CCMP *psk-mixed* WPA/WPA2 Personal (PSK) mixed mode CCMP *wep* defaults to “open system” authentication aka **wep+open** RC4 *wep+open* “open system” authentication RC4 *wep+shared* “shared key” authentication RC4 *wpa3* WPA3 Enterprise CCMP 19.07 *wpa3-mixed* WPA3/WPA2 Enterprise CCMP 19.07 *wpa2+tkip+ccmp* WPA2 Enterprise TKIP, CCMP *wpa2+tkip+aes* WPA2 Enterprise TKIP, CCMP *wpa2+ccmp* WPA2 Enterprise CCMP *wpa2+aes*' WPA2 Enterprise CCMP *wpa2* WPA2 Enterprise CCMP *wpa2+tkip* WPA2 Enterprise TKIP *wpa+tkip+ccmp* WPA Enterprise TKIP, CCMP *wpa+tkip+aes* WPA Enterprise TKIP, AES *wpa+ccmp* WPA Enterprise CCMP *wpa+aes* WPA Enterprise CCMP *wpa+tkip* WPA Enterprise TKIP *wpa* WPA Enterprise CCMP *wpa-mixed+tkip+ccmp* WPA/WPA2 Enterprise mixed mode TKIP, CCMP *wpa-mixed+tkip+aes* WPA/WPA2 Enterprise mixed mode TKIP, CCMP *wpa-mixed+tkip* WPA/WPA2 Enterprise mixed mode TKIP *wpa-mixed+ccmp* WPA/WPA2 Enterprise mixed mode CCMP *wpa-mixed+aes* WPA/WPA2 Enterprise mixed mode CCMP *wpa-mixed* WPA/WPA2 Enterprise mixed mode CCMP *owe* Opportunistic Wireless Encryption (OWE) CCMP 19.07

### WPA Enterprise (Access Point)

Listing of Access Point options for WPA Enterprise.

Name Default Description *server* *(none)* RADIUS server to handle client authentication *port* *1812* RADIUS port *key* *(none)* Shared RADIUS secret *wpa\_group\_rekey* *600* WPA Group Cipher rekeying interval in seconds *auth\_server* *(none)* RADIUS authentication server to handle client authentication *auth\_port* *1812* RADIUS authentication port *auth\_secret* *(none)* Shared authentication RADIUS secret *auth\_cache* *0* Disable or enable PMKSA and Opportunistic Key Caching *acct\_server* *(none)* RADIUS accounting server to handle client authentication *acct\_port* *1813* RADIUS accounting port *acct\_secret* *(none)* Shared accounting RADIUS secret *nasid* *(none)* NAS ID for RADIUS authentication requests *ownip* *(none)* NAS IP Address for RADIUS authentication requests *dae\_client* *(none)* Dynamic Authorization Extension client. This client can send “Disconnect-Request” or “CoA-Request” packets to forcibly disconnect a client or change connection parameters. *dae\_port* *3799* Port the Dynamic Authorization Extension server listens on. *dae\_secret* *(none)* Shared DAE secret. *dynamic\_vlan* *0* Dynamic VLAN assignment *vlan\_naming* *1* VLAN Naming *vlan\_tagged\_interface* *(none)* VLAN Tagged Interface *vlan\_bridge* *(none)* VLAN Bridge Naming Scheme - added in [hostapd: improve 802.1x dynamic vlan support with bridge names](https://git.openwrt.org/?p=openwrt%2Fopenwrt.git%3Ba%3Dcommitdiff%3Bh%3Dd40842d1801e65156d27d727d4fba4735728a844 "https://git.openwrt.org/?p=openwrt/openwrt.git;a=commitdiff;h=d40842d1801e65156d27d727d4fba4735728a844") *radius\_client\_addr* *(none)* Source-IP for RADIUS requests.

### WPA Enterprise (Client)

Listing of Client related options for WPA Enterprise.

Name Default Description *eap\_type* *(none)* Defines the EAP protocol, possible values are *tls* for EAP-TLS and *peap* or *ttls* for EAP-PEAP *auth* *MSCHAPV2* “auth=PAP”/PAP/MSCHAPV2 - Defines the phase 2 (inner) authentication method, only applicable if *eap\_type* is *peap* or *ttls* *identity* *(none)* EAP identity to send during authentication *password* *(none)* Password to send during EAP authentication *ca\_cert* *(none)* Specifies the path the CA certificate used for authentication *client\_cert* *(none)* Specifies the client certificate used for the authentication *priv\_key* *(none)* Specifies the path to the private key file used for authentication, only applicable if *eap\_type* is set to *tls* *priv\_key\_pwd* *(none)* Password to unlock the private key file, only works in conjunction with *priv\_key*

![:!:](/lib/images/smileys/exclaim.svg) When using WPA Enterprise type PEAP with Active Directory Servers, the “auth” option must be set to “auth=MSCHAPV2” or “auth=PAP”.

```
option auth 'auth=MSCHAPV2'
```

or

```
option auth 'auth=PAP'
```

### wpa\_psk\_file

The wpa\_psk\_file option specifies an external file containing a list of MAC address and PSK/passphrase pairs, allowing for multiple PSK/passphrases.

Name Default Description *wpa\_psk\_file* (none) Location of the wpa\_psk file (a common location is /etc/hostapd.wpa\_psk)

Example for a wpa\_psk file:

```
00:00:00:00:00:00 secret_passphrase
00:00:00:00:00:00 another_passphrase
00:11:22:33:44:55 passphrase_for_a_specific_mac_only
00:22:33:44:55:66 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
vlanid=3 00:00:00:00:00:00 passphrase_for_vlan_id_3
```

In the example above, the last line uses the “vlanid=&lt;id&gt;” parameter: Clients can be assigned to VLAN-tagged interfaces depending on the PSK/passphrase. Additional configuration is required, re-using several parameters originally intended for RADIUS-based VLAN mappings:

Name Default Description *dynamic\_vlan* *0* Dynamic VLAN mode: 0 = disabled, 1 = optional (use default interface when no VLAN ID is used), 2 = required *vlan\_file* (none) Absolute path to the file containing VLAN ID - network interface mappings (a common location is /etc/hostapd.vlan) *vlan\_tagged\_interface* *(none)* prefix for the vlan tagged interface (see vlan\_naming option) *vlan\_naming* *1* VLAN naming scheme prefix for the newly created interface: 0 = “vlan&lt;id&gt;”, 1 = “&lt;vlan\_tagged\_interface&gt;.&lt;id&gt;” (see vlan\_tagged\_interface option) *vlan\_bridge* *(none)* bridge prefix for the bridge to which the wifi and the tagged interface will be added; defaults to “brvlan&lt;id&gt;” if no tagged interface is given and “br&lt;vlan\_tagged\_interface&gt;.&lt;id&gt;” if a tagged interface is given (see vlan\_tagged\_interface option)

Note: The vlan-related options above will be ignored or rejected by the default stripped down wpad-basic/hostapd-basic binaries. Like a RADIUS-based setup, these require the fully featured wpad/hostapd.

Example for a vlan file:

```
# VLAN ID to network interface mapping
1	vlan1
2	vlan2
3	vlan3
100	guest
# Optional wildcard entry matching all VLAN IDs. The first "#" in the interface name will be replaced with the VLAN ID.
# The network interfaces are created and removed dynamically when necessary.
*	vlan#
# Optional third parameter to override the bridge name
101	vlan100	bridge_name
```

### WPA key reinstallation attack workaround

Name Default Description *wpa\_disable\_eapol\_key\_retries* *0* Workaround for key reinstallation attacks (requires LEDE 17.01.4 or higher)

Complete description copied from upstream hostapd.conf example:

```
# Workaround for key reinstallation attacks
#
# This parameter can be used to disable retransmission of EAPOL-Key frames that
# are used to install keys (EAPOL-Key message 3/4 and group message 1/2). This
# is similar to setting wpa_group_update_count=1 and
# wpa_pairwise_update_count=1, but with no impact to message 1/4 and with
# extended timeout on the response to avoid causing issues with stations that
# may use aggressive power saving have very long time in replying to the
# EAPOL-Key messages.
#
# This option can be used to work around key reinstallation attacks on the
# station (supplicant) side in cases those station devices cannot be updated
# for some reason. By removing the retransmissions the attacker cannot cause
# key reinstallation with a delayed frame transmission. This is related to the
# station side vulnerabilities CVE-2017-13077, CVE-2017-13078, CVE-2017-13079,
# CVE-2017-13080, and CVE-2017-13081.
#
# This workaround might cause interoperability issues and reduced robustness of
# key negotiation especially in environments with heavy traffic load due to the
# number of attempts to perform the key exchange is reduced significantly. As
# such, this workaround is disabled by default (unless overridden in build
# configuration). To enable this, set the parameter to 1.
#wpa_disable_eapol_key_retries=1
```

**Note** that this workaround can't prevent attacks against Tunneled Direct-Link Setup (TDLS). You may also want to add the option *tdls\_prohibit=1* in order to make such an attack more complicated:

Name Default Description *tdls\_prohibit* *0* Prohibit the use of TDLS on the network (complicates key reinstallation attacks against TDLS) (requires hostapd/wpad 2016-12-19-ad02e79d-7 or higher)

### WPS options

Listing of [Wi-Fi Protected Setup](http://en.wikipedia.org/wiki/Wi-Fi_Protected_Setup "http://en.wikipedia.org/wiki/Wi-Fi_Protected_Setup") related options.

![:!:](/lib/images/smileys/exclaim.svg) Support for WPS is provided by packages *wpad* and *hostapd-utils*. Default package *wpad-mini* is not enough.

![:!:](/lib/images/smileys/exclaim.svg) WPS is possible only when encryption PSK/PSK2 is selected.

Name Type Required Default Description *wps\_config* list no *(none)* List of configuration methods. Currentlly supported methods are: *push\_button*. *wps\_device\_name* string no *LEDE AP* User-friendly description of device; up to 32 octets encoded in UTF-8. *wps\_device\_type* string no *6-0050F204-1* Primary device type. Examples: *1-0050F204-1* (Computer / PC), *1-0050F204-2* (Computer / Server), *5-0050F204-1* (Storage / NAS), *6-0050F204-1* (Network Infrastructure / AP) *wps\_label* boolean no *0* Enable *label* configuration method. *wps\_manufacturer* string no *lede-project.org* The manufacturer of the device (up to 64 ASCII characters). *wps\_pushbutton* boolean no *0* Enable *push-button* configuration method. *wps\_pin* string no none The PIN to use with WPS-PIN (only in external registrar mode?)

Minimal steps needed to get WPS running:

- Add *option wps\_pushbutton '1* ' to a *config wifi-iface* section that is configured for WPA2-PSK in /etc/config/wireless
- opkg update
- opkg remove wpad-mini
- opkg install wpad hostapd-utils
- reboot

After rebooting, instead of pushing the WPS button, you can manually initiate the WPS process (which is safer than using the button if it doubles as a reset button):

```
hostapd_cli wps_pbc
```

When using WPS-PIN:

- Add *option wps\_label '1* ' to a *config wifi-iface* section that is configured for WPA2-PSK in /etc/config/wireless
- opkg update
- opkg remove wpad-mini
- opkg install wpad hostapd-utils
- reboot

After rebooting, the WPS PIN needs to be given to hostapd each time a station tries to connect. The PIN may **not** be used multiple times, as an active attacker can recover half of it during each try. The “any” keyword can be replaced by the specific stations EUUID, as printed in hostapd log.

```
hostapd_cli wps_pin any $PIN
```

Example:

```
# /etc/config/wireless
...
config wifi-iface
	option device 'radio0'
	option mode 'ap'
	option ssid 'My-WiFi-Home'
	option network 'lan'
	option encryption 'psk2'
	option key 'WiFipassword'
	option ieee80211w '0'
	option wps_pushbutton '1'
```

### Neighbor reports options (802.11k)

This function needs the full version of hostapd or wpad. See also [Wifi Roaming](/docs/guide-user/network/wifi/roaming "docs:guide-user:network:wifi:roaming").

Name Type Required Default Description *ieee80211k* boolean no *0* Enables Radio Resource Measurement (802.11k) support. *rrm\_neighbor\_report* boolean no Value of *ieee80211k* Enable neighbor report via radio measurements. *rrm\_beacon\_report* boolean no Value of *ieee80211k* Enable beacon report via radio measurements.

### BSS transition management frames options (802.11v)

This function needs the full version of hostapd or wpad. See also [Wifi Roaming](/docs/guide-user/network/wifi/roaming "docs:guide-user:network:wifi:roaming").

Name Type Required Default Description *ieee80211v (Removed)* boolean no *0* Enables BSS transition (802.11v) support. This option was removed in [this](https://github.com/openwrt/openwrt/commit/b518f07d4b8ae144453c606c9ec4ecef7d39f968 "https://github.com/openwrt/openwrt/commit/b518f07d4b8ae144453c606c9ec4ecef7d39f968") commit. *time\_advertisement* integer no *0* Time advertisement. 0 is disabled and 2 is enabled (see hostapd's [time\_advertisement](https://w1.fi/cgit/hostap/plain/hostapd/hostapd.conf "https://w1.fi/cgit/hostap/plain/hostapd/hostapd.conf") setting). *time\_zone* string no (none) Local time zone as specified in 8.3 of IEEE Std 1003.1-2004. *wnm\_sleep\_mode* boolean no *0* WNM-Sleep Mode (extended sleep mode for stations). *bss\_transition* boolean no *0* BSS Transition Management.

### Fast BSS transition options (802.11r)

First note that 802.11r is not necessarily needed for [roaming](/docs/guide-user/network/wifi/roaming "docs:guide-user:network:wifi:roaming") since most WiFi clients (e.g. phones, tablets, laptops) will roam regardless of access point features. The difference is that roaming without 802.11r will take longer. Without 802.11r roaming for PSK might take 150ms and with EAP 500ms+. With 802.11r roaming is reduced to 15-75ms, see the [forum discussion](https://forum.openwrt.org/t/fast-seamless-roaming-through-ethernet-with-openwrt/182458/7 "https://forum.openwrt.org/t/fast-seamless-roaming-through-ethernet-with-openwrt/182458/7"). So you will likely only see a difference if you are roaming whilst time-sensitive network traffic is being exchanged (e.g. VoIP, video conference, online game, etc.).

To check if 802.11r is working properly, set log\_level to 1 (cf. [Common Options](/docs/guide-user/network/wifi/basic#common_options1 "docs:guide-user:network:wifi:basic")) and look for message “*FT authentication already completed - do not start 4-way handshake*” in your system log after roaming.

Name Type Required Default Description *ieee80211r* boolean no *0* Enables fast BSS transition (802.11r) support. *nasid* string no *(BSSID without colon)* PMK-R0 Key Holder identifier (dot11FTR0KeyHolderID). A 1 to 48 octet identifier. *mobility\_domain* string no *(first 4 bytes of `md5sum` of the SSID)* Mobility Domain identifier (dot11FTMobilityDomainID, MDID). MDID is used to indicate a group of APs (within an ESS, i.e., sharing the same SSID) between which a STA can use Fast BSS Transition. 2-octet identifier as a hex string. *r0\_key\_lifetime* integer no *10000* Default lifetime of the PMK-RO in minutes \[1-65535]. *r1\_key\_holder* string no *(BSSID) (hostapd default)* PMK-R1 Key Holder identifier (dot11FTR1KeyHolderID). A 6-octet identifier as a hex string. *reassociation\_deadline* integer no *1000* Reassociation deadline in time units (TUs / 1.024 ms, 1000-65535).  
![:!:](/lib/images/smileys/exclaim.svg) Warning: Some devices do not function properly with the default value of *1000*. Using *20000* which is the default used on Cisco gear appears to resolve these issues. *r0kh* string no ff:ff:ff:ff:ff:ff,\*,$key List of R0KHs in the same Mobility Domain. Valid format: &lt;MAC address&gt;,&lt;NAS Identifier&gt;,&lt;256-bit key as hex string&gt; This list is used to map R0KH-ID (NAS Identifier) to a destination MAC address when requesting PMK-R1 key from the R0KH that the STA used during the Initial Mobility Domain Association. Key is generated with thep of auth\_secret, so this should be the same for all APs. *r1kh* string no 00:00:00:00:00:00,00:00:00:00:00:00,$key List of R1KHs in the same Mobility Domain. Valid format: &lt;MAC address&gt;,&lt;R1KH-ID&gt;,&lt;256-bit key as hex string&gt; This list is used to map R1KH-ID to a destination MAC address when sending PMK-R1 key from the R0KH. This is also the list of authorized R1KHs in the MD that can request PMK-R1 keys. *pmk\_r1\_push* boolean no *0* Whether PMK-R1 push is enabled at R0KH.  
![:!:](/lib/images/smileys/exclaim.svg) Warning: If WPA3 (SAE) is enabled, setting this will break fast BSS transition (802.11r). *ft\_over\_ds* boolean no *0* Whether to enable FT-over-DS.  
![:!:](/lib/images/smileys/exclaim.svg) Warning: The previous default value of 0 for “FT over the DS” is known to cause issues especially with Apple devices. Setting this to 0 which instead uses “FT over the Air” is known to fix these issues and is the default as of openwrt [23.05.0](https://github.com/openwrt/openwrt/commit/2984a0420649733662ff95b0aff720b8c2c19f8a "https://github.com/openwrt/openwrt/commit/2984a0420649733662ff95b0aff720b8c2c19f8a"). *ft\_psk\_generate\_local* boolean no *1* Whether to generate FT response locally for PSK networks. This avoids use of PMK-R1 push/pull from other APs with FT-PSK networks as the required information (PSK and other session data) is already locally available.  
![:!:](/lib/images/smileys/exclaim.svg) Warning: For WPA3-only (SAE), setting this will break fast BSS transition (802.11r). For WPA2/3 mixed mode, you also need to disable this. Note that Fast Transition should continue working as r0kh and r1kh are automatically generated by default or you may elect to set r0kh &amp; r1kh manually.

### Inactivity timeout options

Name Type Required Default Description *disassoc\_low\_ack* boolean no *1* Disassociate stations based on excessive transmission failures or other indications of connection loss. This depends on the driver capabilities and may not be available with all drivers. *max\_inactivity* integer no *300* Station inactivity limit in seconds: If a station does not send anything in ap\_max\_inactivity seconds, an empty data frame is sent to it in order to verify whether it is still in range. If this frame is not ACKed, the station will be disassociated and then deauthenticated. *skip\_inactivity\_poll* boolean no *0* The inactivity polling can be disabled to disconnect stations based on inactivity timeout so that idle stations are more likely to be disconnected even if they are still in range of the AP. *max\_listen\_interval* integer no *65535* Maximum allowed Listen Interval (how many Beacon periods STAs are allowed to remain asleep).

## Wi-Fi Stations

The *wifi-station* section allows matching a client (station) based on it's PSK or MAC Address and tagging it with a VLAN ID. It can be used to replicate the behaviour of *wpa\_psk\_file* in native UCI.

![:!:](/lib/images/smileys/exclaim.svg) WPA3 SAE is supported since 24.10.

Name Type Required Description *iface* string no Wireless interface this station will be matched for (empty would match all interfaces) *vid* integer no VLAN ID to assign station to (defaults to no VLAN) *mac* string no MAC address to match authenticating stations against *key* string yes PSK to match authenticating stations against

Example:

```
config	wifi-station
	option	iface		'iface_radio0'
	option	vid		'10'
	option	mac		'12:34:56:78:90:00'
	option	key		'hunter12'
```

## Wi-Fi VLANs

The *wifi-vlan* section allows you to map between VLAN tagging on hostapd interfaces and their corresponding networks.

![:!:](/lib/images/smileys/exclaim.svg) If the underlying interface is a DSA interface (Hardware Switch) make sure to configure the VLANs appropiately to guarantee the packets flow further.

Name Type Required Description *iface* string no Wireless interface this VLAN will be matched for (empty would match all interfaces) *vid* integer yes VLAN ID to match against *network* string yes Network interface that this VLAN ID will be assigned *name* string yes Name for the VLAN entry. Maximum length: 14 - Wi-Fi interface name length

Example:

```
config	wifi-vlan
	option	iface		'iface_radio0'
	option	network		'dmz'
	option	vid		'10'
	option	name		'10'
```

## Start/Stop wireless

Wireless interfaces are brought up and down with the *wifi* command. To (re)start the wireless after a configuration change, use *wifi*, to disable the wireless, run *wifi down*. In case your platform carries multiple wireless devices it is possible to start or run down each of them individually by making the *wifi* command be followed by the device name as a second parameter. Note: The *wifi* command has an optional first parameter that defaults to *up* , i.e. start the device. To make the second parameter indeed a second parameter it is mandatory to give a first parameter which can be anything except *down*. E.g. to start the interface *wlan2* issue: *wifi up wlan2*; to stop that interface: *wifi down wlan2*. If the platform has also e.g. wlan0 and wlan1 these will not be touched by stopping or starting wlan2 selectively.

## Regenerate configuration

To rebuild the configuration file, e.g. after installing a new wireless driver, remove the existing wireless configuration (if any) and use the *wifi config* command:

```
rm -f /etc/config/wireless
wifi config
```

## htmode: Wi-Fi channel width

The Wi-Fi channel width is the range of frequencies i.e. how broad the signal is for transferring data. Generally speaking, the bigger the channel width, the more data can be transmitted over the signal. But as with everything there are drawbacks. With larger channel widths, interference with others Wi-Fi networks or Bluetooth becomes a much larger issue, and making solid connections becomes much harder as well. Think of it like a highway. The wider the road, the more traffic (data) can pass through. On the other hand, the more cars (routers) you have on the road, the more congested the traffic becomes.

Wi-Fi standard allows 10, 20, 22, 40, 80 and 160 MHz but 10MHz is not used anymore, the 80 and 160 can be used only with 5 GHz frequency, and certain devices not being able to connect to APs with channel widths more than 40Mhz.

By default, the 2.4 GHz frequency uses a 20 MHz channel width. A 20MHz channel width is wide enough to span one channel. A 40 MHz channel width bonds two neighbouring 20 MHz channels together, forming a 40 MHz channel width; therefore, it allows for greater speed and faster transfer rates. One “control” channel functions as the main channel, and the other “extension” as the auxiliary channel. The main channel sends Beacon packets and data packets, and the auxiliary channel sends other packets. The extension channel can either be “above” or “below” the control channel, as long as it doesn't go outside the band. For example, if your control channel is 1, your extension channel has to “above”, because anything below channel 1 would be below the lowest frequency allowed in the 2.4GHz ISM band. The extension channel has to be contiguous with the edge of the control channel, without overlapping.

`HT40+` means that centre frequency of the main 20 MHz channel is higher than that of the auxiliary channel, and `HT40-` otherwise. For example, if the centre frequency 149 and the centre frequency 153 reside on two 20 MHz channels, 149plus indicates that the two 20 MHz channels are bundled to form a 40 MHz channel.

When the HT40 mode is used in the 2.4 GHz frequency band, there is only one non-overlapping channel. Therefore, you are not advised to use the HT40 mode in the 2.4 GHz frequency band.

- `HT20` High Throughput 20MHz, 802.11n
- `HT40` High Throughput 40MHz, 802.11n
- `HT40-` High Throughput 40MHz, 802.11n, control channel is below extension channel.
- `HT40+` High Throughput 40MHz, 802.11n, control channel is above extension channel.
- `VHT20` Very High Throughput 20MHz, Supported by 802.11ac
- `VHT40` Very High Throughput 40MHz, Supported by 802.11ac
- `VHT80` Very High Throughput 80MHz, Supported by 802.11ac
- `VHT160` Very High Throughput 160MHz, Supported by 802.11ac
- `NOHT` disables 11n

### 40 MHz channel width (up to 300 Mbps) for 802.11n devices ONLY

The default max channel width `VT20` i.e. 20MHz supports a max speed of 150Mbps. Increasing this to 40MHz will increase the maximum theoretical speed to 300Mbps. The catch is that in areas with a lot of Wi-Fi traffic (and Bluetooth etc. which share the same radio frequencies), 40MHz may decrease your overall speed. Devices **should** detect interference when using 40MHz, and drop back to 20MHz. Edit `htmode` options in the file `/etc/config/wireless` and restart the Wi-Fi AP to test various channel widths. Note that option *htmode* should be set to either `HT40+` (for channels 1-7) or `HT40-` (for channels 5-11) or simply `HT40`.

## HT (high throughput) capabilities

When using the mac80211 device, you can choose to enable/disable a number of high-throughput capabilities by setting any of the following options in the wifi-device section. Most capabilities are detected and enabled by default (in Barrier Breaker or later).

### 802.11n capabilities

The following capabilities relate to 802.11n operation, and are enabled when the htmode option is set to any of HT20 HT40 HT40- HT40+ VHT20 VHT40 VHT80 or VHT160. Capabilities supported by a device can be queried with the `iw list` command, and are listed in the “Capabilities” section, refer to [https://w1.fi/cgit/hostap/tree/hostapd/hostapd.conf](https://w1.fi/cgit/hostap/tree/hostapd/hostapd.conf "https://w1.fi/cgit/hostap/tree/hostapd/hostapd.conf") for a description of the options (search for ht\_capab on that web page).

Name Type Default Capability Description ldpc boolean 1 LDPC LDPC (Low-Density Parity-Check code) capability greenfield boolean 0 GF Receive Greenfield - treats pre-80211n traffic as noise.  
![:!:](/lib/images/smileys/exclaim.svg) Warning: this can cause significant packet collisions and reduction in performance if older pre-n (a/b/g) traffic is present in the local area (including other networks which you don't control); it is disabled by default for a reason. short\_gi\_20 boolean 1 SHORT-GI-20 Short GI (guard interval) for 20 MHz short\_gi\_40 boolean 1 SHORT-GI-40 Short GI for 40 MHz tx\_stbc integer 1 TX-STBC Transmit STBC (Space-Time Block Coding) rx\_stbc integer 3 RX-STBC1  
RX-STBC12  
RX-STBC123 Receive STBC:  
1 - one spatial stream,  
2 - one or two spatial streams,  
3 - one, two, or three spatial streams,  
0 - disables capability max\_amsdu boolean 1 MAX-AMSDU-7935 Maximum A-MSDU length of 7935 octets (3839 octets if option set to 0) dsss\_cck\_40 boolean 1 DSSS\_CCK-40 DSSS/CCK Mode in 40 MHz allowed in Beacon, Measurement Pilot and Probe Response frames

### 802.11ac capabilities

The following capabilities relate to 802.11ac operation, and are enabled when the htmode option is set to any of VHT20, VHT40, VHT80, or VHT160. Capabilities supported by the device can be queried with the `iw list` command and are listed in the “VHT Capabilities” section.

Name Type Default Capability Description rxldpc boolean 1 RXLDPC Supports receiving LDPC coded pkts short\_gi\_80 boolean 1 SHORT-GI-80 Supports reception of packets transmitted with TXVECTOR  
params format equal to VHT and CBW = 80Mhz short\_gi\_160 boolean 1 SHORT-GI-160 Supports reception of packets transmitted with TXVECTOR  
params format equal to VHT and CBW = 160Mhz tx\_stbc\_2by1 boolean 1 TX-STBC-2BY1 Supports transmission of at least 2×1 STBC  
![:!:](/lib/images/smileys/exclaim.svg) currently ignored in trunk su\_beamformer boolean 1 SU-BEAMFORMER Single user beamformer su\_beamformee boolean 1 SU-BEAMFORMEE Single user beamformee mu\_beamformer boolean 1 MU-BEAMFORMER Supports operation as an MU beamformer mu\_beamformee boolean 1 MU-BEAMFORMEE Supports operation as an MU beamformee vht\_txop\_ps boolean 1 VHT-TXOP-PS 0 = VHT AP doesn't support VHT TXOP PS (Power Save) mode (OR) VHT STA not in VHT TXOP PS mode,  
1 = VHT AP supports VHT TXOP PS mode (OR) VHT STA is in VHT TXOP power save mode htc\_vht boolean 1 HTC-VHT STA supports receiving a VHT variant HT Control field. rx\_antenna\_pattern boolean 1 RX-ANTENNA-PATTERN Rx antenna pattern does not change during the lifetime of an association tx\_antenna\_pattern boolean 1 TX-ANTENNA-PATTERN Tx antenna pattern does not change during the lifetime of an association vht\_max\_a\_mpdu\_len\_exp integer 7 MAX-A-MPDU-LEN-EXP&lt;0-7&gt; Indicates the maximum length of A-MPDU pre-EOF padding that the STA can recv vht\_max\_mpdu integer 11454 MAX-MPDU-7991  
MAX-MPDU-11454 Maximum MPDU length rx\_stbc integer 4 0 - not supported,  
1 - RX-STBC-1,  
2 - RX-STBC-12,  
3 - RX-STBC-123,  
4 - RX-STBC-1234 Supports reception of PPDUs using STBC:  
1 - one spatial stream,  
2 - one or two spatial streams,  
etc.  
![:!:](/lib/images/smileys/exclaim.svg) currently used incorrectly in trunk vht\_link\_adapt integer 3 VHT-LINK-ADAPT&lt;0-3&gt; TA supports link adaptation using VHT variant HT Control field vht160 integer 2 VHT160  
VHT160-80PLUS80 Supported channel widths:  
0 - 160MHz and 80+80 MHz not supported, 1 - 160 MHz supported,  
2 - 160MHz and 80+80 MHz supported

## DFS / radar detection

In many countries, operating Wi-Fi devices on some or all channels in the 5GHz band requires radar detection and [DFS](/docs/techref/dfs "docs:techref:dfs") [(explanation)](http://wifi-insider.com/wlan/dfs.htm "http://wifi-insider.com/wlan/dfs.htm"). If you define a channel in your wireless config that requires DFS according to your country regulations, the 5GHz radio device won’t start up unless the firmware image is able to provide DFS support (i.e. it is both included and enabled). More technical details of the Linux implementation can be found [here](https://wireless.wiki.kernel.org/en/developers/DFS "https://wireless.wiki.kernel.org/en/developers/DFS"). DFS works as follows in Linux: The driver detects radar pulses and reports this to nl80211 where the information is processed. If a series of pulses matches one of the defined radar patterns, this will be reported to the user space application (e.g. hostapd) which in turn reacts by switching to another channel.

The following configuration specifies channel 104 which needs DFS support as implicitly stated with country code DE:

```
config	wifi-device		'radio0'
	option	type		'mac80211'
	option	channel		'104'
	option	hwmode		'11a'
	option	path		'pci0000:00/0000:00:00.0'
	option	htmode		'HT20'
	option	country		'DE'
 
config	wifi-iface
	option	device		'radio0'
	option	network		'lan'
	option	mode		'ap'
	option	ssid		'OpenWrt'
	option	encryption	'none'
```

You can check the country (regulatory domain) your Wi-Fi card thinks it must conform to with

```
iw reg get
```

If in doubt, double check your hostapd-phy.conf to make sure it contains the following values, and that your country code is set:

```
country_code=DE
ieee80211n=1
ieee80211d=1
ieee80211h=1
hw_mode=a
```

If radar detection is working, DFS channels will show up like this (here for Belgium, *iw phy1 info* output trimmed):

```
Frequencies:
* 5220 MHz [44] (17.0 dBm)
* 5240 MHz [48] (17.0 dBm)
* 5260 MHz [52] (20.0 dBm) (radar detection)
DFS state: usable (for 2155257 sec)
DFS CAC time: 60000 ms
* 5280 MHz [56] (20.0 dBm) (radar detection)
DFS state: usable (for 2155257 sec)
DFS CAC time: 60000 ms
```

![:!:](/lib/images/smileys/exclaim.svg) When DFS is on, there will be a delay before the interface is enabled (e.g. after reboot). During this time period (often 60 seconds, and determined by local reglations) luci will report the interface is disabled. This time period is used to detect the presence of other signals on the channel (Channel Availability Check Time). This process can be monitored with:

```
logread -f
```

If you select a channel that requires DFS in your country and enable HT40, this may result in the **DFS start\_dfs\_cac() failed** error (visible with logread):

```
Configuration file: /var/run/hostapd-phy1.conf
wlan1: interface state UNINITIALIZED->COUNTRY_UPDATE
wlan1: interface state COUNTRY_UPDATE->HT_SCAN
wlan1: interface state HT_SCAN->DFS
wlan1: DFS-CAC-START freq=5680 chan=136 sec_chan=-1, width=0, seg0=0, seg1=0, cac_time=60s
DFS start_dfs_cac() failed, -1
Interface initialization failed
wlan1: interface state DFS->DISABLED
wlan1: AP-DISABLED
hostapd_free_hapd_data: Interface wlan1 wasn't started
```

Changing your configuration to HT20 should resolve this.
