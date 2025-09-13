# OpenNDS Captive Portal

## Overview

openNDS (open Network Demarcation Service) is a high performance, small footprint, Captive Portal.

It provides a border control gateway between a public local area network and the Internet.

It supports all ranges between small stand alone venues through to large mesh networks with multiple portal entry points.

Both the client driven Captive Portal Detection (CPD) method and gateway driven Captive Portal Identification method (CPI - RFC 8910 and RFC 8908) are supported.

In its default configuration, openNDS offers a dynamically generated and adaptive splash page sequence. Internet access is granted by a click to continue button, accepting Terms of Service. A simple option enables input forms for user login.

The package incorporates the FAS API allowing many flexible customisation options.

The creation of sophisticated third party authentication applications is fully supported.

Internet hosted https portals can be implemented with no security errors, to inspire maximum user confidence.

## Documentation

Full documentation can be found at:

[https://opennds.readthedocs.io](https://opennds.readthedocs.io "https://opennds.readthedocs.io")

## Official Repository

The official repository can be found here:

[https://github.com/openNDS/openNDS](https://github.com/openNDS/openNDS "https://github.com/openNDS/openNDS")

## How OpenNDS (NDS) works

OpenNDS is a Captive Portal Engine. Any Captive Portal, including NDS, will have two main components:

- Something that does the capturing, and
- Something to provide a Portal for client users to log in.

A wireless router will typically be running OpenWrt or some other Linux distribution.

A router, by definition, will have two or more interfaces, at least one to connect to the wide area network (WAN) or Internet feed, and at least one connecting to the local area network (LAN).

Each LAN interface must also act as the Default IP Gateway for its LAN, ideally with the interface serving IP addresses to client devices using DHCP.

Multiple LAN interfaces can be combined into a single bridge interface. For example, ethernet, 2.4Ghz and 5Ghz networks are typically combined into a single bridge interface. Logical interface names will be assigned such as eth0, wlan0, wlan1 etc. with the combined bridge interface named as br-lan.

NDS will manage one or more of them of them. This will typically be br-lan, the bridge to both the wireless and wired LAN, but could be, for example, wlan0 if you wanted NDS to work just on the wireless interface.

#### Summary of Operation

By default, NDS blocks everything.

A client will find out it is in a captured state by one of two basic methods:

##### 1. Captive Portal Detection (CPD)

CPD is a client driven process available on all modern mobile devices, most desktop operating systems and most browsers. The CPD process automatically issues a port 80 request on connection to a network as a means of probing for a captive state.

Sometimes known as a “canary test”, this process, driven by the client, has evolved over a number of years to be a reliable de-facto standard. openNDS detects this probing and serves a special “splash” web page sequence to the connecting client device.

##### 2. Captive Portal Identification (CPI)

CPI is a Gateway driven process as defined in standards RFC8910 (Captive-Portal Identification in DHCP and Router Advertisements) and RFC8908 (Captive Portal API). A gateway router informs a connecting client that it is in a captive state by providing a url at which a client can access for authentication. A client may access this url to be served the same portal “splash” page sequence as it would have in the traditional CPD method.

Alternatively, a client may use this url to access the RFC8908 Captive Portal API, ultimately being served a splash page sequence for authentication.

From openNDS v9.5.0, The CPI method is supported in both forms and enabled by default. It can be disabled in a config option.

Note: Very few client devices support CPI at the time of writing (November 2021)

Update: Most new devices now support CPI at least to some degree, indicating a probable “S” curve adoption. (January 2023)

#### The Portal

The client browser is redirected to the Portal component. This is a web service that is configured to know how to communicate with the core engine of NDS. This is commonly known as the “Splash Page”.

NDS has its own web server built in and is used in the basic modes of operation to serve the Portal “Splash” pages to the client browser. Alternatively, a separate web server can be used.

### NDS comes with multiple default Splash Page options

- A trivial Click to Continue splash page sequence (default configuration)
- A Client User form requiring Name and Email address to be entered.
- Admin definable themed page sequences, supporting optional remote content

A single uci config option is used to choose the default splash page sequence for client login.

For the simple “Click to Continue” pages:

```
 option login_option_enabled '1'
 
```

For the “username/email” pages:

```
 option login_option_enabled '2'
```

For admin defined Themespec pages:

```
 option login_option_enabled '3'
 
```

The default splash page options can be customised or a complete specialised Portal can be written by the installer (See ThemeSpec, FAS, PreAuth in the documentation).

### FAS, or Forward Authentication Service

FAS, or Forward Authentication Service may use the web server embedded in NDS, a separate web server installed on the NDS router, a web server residing on the local network or an Internet hosted web server.

The user of the client device will always be expected to complete some actions on the splash or captive portal page. Once the user on the client device has successfully completed the splash page actions, that page then links directly back to NDS.

For security, NDS expects to receive a token, hashed using a pre-shared key.

If this hashed token is valid, NDS then “authenticates” the client device, allowing access to the Internet.

Post authentication processing extensions may be added to NDS (See BinAuth in the documentation). Once NDS has received the valid token it will, if enabled, call a BinAuth script.

BinAuth Post Authentication processing is most often used to provide a mechanism for generating local client access logs.

Binauth can override the FAS and deny access or override quotas and data rate restrictions that may be set by the FAS or globally in the configuration.

If FAS Secure is enabled (Levels 1 (default), 2 and 3), the client authentication token is kept secret at all times. Instead, faskey is used to generate a hashed id value (hid) and this is sent by openNDS to the FAS. The FAS must then in turn generate a new return hash id (rhid) to return to openNDS in its authentication request.

**If set to “0” The FAS is enforced by NDS to use http protocol.** The client token is sent to the FAS in clear text in the query string of the redirect along with authaction and redir. This method is easy to bypass and useful only for the simplest systems where security does not matter.

**If set to “1” The FAS is enforced by NDS to use http protocol.** A base64 encoded query string containing the hid is sent to the FAS, along with the clientip, clientmac, gatewayname, client\_hid, gatewayaddress, authdir, originurl, clientif and custom parameters and variables.

Should the sha256sum utility not be available, openNDS will terminate with an error message on startup.

**If set to “2” The FAS is enforced by NDS to use http protocol.**

clientip, clientmac, gatewayname, client\_hid, gatewayaddress, authdir, originurl and clientif are encrypted using faskey and passed to FAS in the query string.

The query string will also contain a randomly generated initialization vector to be used by the FAS for decryption.

The cipher used is “AES-256-CBC”.

The “php-cli” package and the “php-openssl” module must both be installed for fas\_secure level 2.

openNDS does not depend on this package and module, but will exit gracefully if this package and module are not installed when this level is set.

The FAS must use the query string passed initialisation vector and the pre shared fas\_key to decrypt the query string. An example FAS level 2 php script (fas-aes.php) is stored in the /etc/opennds directory and also supplied in the source code. This should be copied the the web root of a suitable web server for use.

**If set to “3” The FAS is enforced by openNDS to use https protocol.** Level 3 is the same as level 2 except the use of https protocol is enforced for FAS. In addition, the “authmon” daemon is loaded. This allows the external FAS, after client verification, to effectively traverse inbound firewalls and address translation to achieve NDS authentication without generating browser security warnings or errors. An example FAS level 3 php script (fas-aes-https.php) is pre-installed in the /etc/opennds directory and also supplied in the source code. This should be copied the the web root of a suitable web server for use.

Option faskey has a default value. It is recommended that this is set to some secret value in the config file and the FAS script set to use a matching value, ie faskey must be pre-shared with FAS.

### A Note on Captive Portal Detection (CPD)

All modern mobile devices, most desktop operating systems and most browsers now have a CPD process that automatically issues a port 80 request on connection to a network. NDS detects this and serves a special “splash” web page to the connecting client device.

The port 80 html request made by the client CPD can be one of many vendor specific URLs.

Typical CPD URLs used are, for example:

- [http://captive.apple.com/hotspot-detect.html](http://captive.apple.com/hotspot-detect.html "http://captive.apple.com/hotspot-detect.html")
- [http://connectivitycheck.gstatic.com/generate\_204](http://connectivitycheck.gstatic.com/generate_204 "http://connectivitycheck.gstatic.com/generate_204")
- [http://connectivitycheck.platform.hicloud.com/generate\_204](http://connectivitycheck.platform.hicloud.com/generate_204 "http://connectivitycheck.platform.hicloud.com/generate_204")
- [http://www.samsung.com/](http://www.samsung.com/ "http://www.samsung.com/")
- [http://detectportal.firefox.com/success.txt](http://detectportal.firefox.com/success.txt "http://detectportal.firefox.com/success.txt")
- Plus many more

It is important to remember that CPD is designed primarily for mobile devices to automatically detect the presence of a portal and to trigger the login page, without having to resort to breaking SSL/TLS security by requiring the portal to redirect port 443 for example.

Just about all current CPD implementations work very well but some compromises are necessary depending on the application.

The vast majority of devices attaching to a typical Captive Portal are mobile devices. CPD works well giving the initial login page.

For a typical guest wifi, eg a coffee shop, bar, club, hotel etc., a device connects, the Internet is accessed for a while, then the user takes the device out of range.

When taken out of range, a typical mobile device begins periodically polling the wireless spectrum for SSIDs that it knows about to try to obtain a connection again, subject to timeouts to preserve battery life.

Most Captive Portals have a session duration limit (openNDS included).

If a previously logged in device returns to within the coverage of the portal, the previously used SSID is recognised and CPD is triggered and tests for an Internet connection in the normal way. Within the session duration limit of the portal, the Internet connection will be established, if the session has expired, the splash page will be displayed again.

Early mobile device implementations of CPD used to poll their detection URL at regular intervals, typically around 30 to 300 seconds. This would trigger the Portal splash page quite quickly if the device stayed in range and the session limit had been reached.

However it was very quickly realised that this polling kept the WiFi on the device enabled continuously having a very negative effect on battery life, so this polling whilst connected was either increased to a very long interval or removed all together (depending on vendor) to preserve battery charge. As most mobile devices come and go into and out of range, this is not an issue.

**A common issue raised is:**

*“My devices show the splash page when they first connect, but when the authorization expires, they just announce there is no internet connection. I have to make them “forget” the wireless network to see the splash page again. Is this how is it supposed to work?”*

This is normal, but you will find just manually disconnecting or turning WiFi off and on will simulate a “going out of range”, initialising an immediate trigger of the CPD. One or any combination of these solutions should work, again depending on the particular vendor's implementation of CPD.

In contrast, most laptop/desktop operating systems, and browser versions for these still implement CPD polling whilst online as battery considerations are not so important.

For example, Gnome desktop has its own built in CPD browser with a default interval of 300 seconds. Firefox also defaults to something like 300 seconds. Windows 10 is similar.

This IS how it is supposed to work, but does involve some compromises.

The best solution is to set the session timeout to a value greater than the expected length of time a client device is likely to be present. Experience shows a limit of 24 hours covers most situations eg bars, clubs, coffee shops, motels etc. If for example an hotel has guests regularly staying for a few days, then increase the session timeout as required.

Staff at the venue could have their devices added to the Trusted List if appropriate, but experience shows, it is better not to do this as they very soon learn what to do and can help guests who encounter the issue. (Anything that reduces support calls is good!)

Most such issues with CPD are potentially solved by the use of CPI instead but would require its adoption by all client device vendors. CPI is a new standard that is evolving as it is universally adopted. At the time of writing, most new devices support it to some degree.
