# Opportunistic Wireless Encryption (OWE) and OWE Transition Mode

## Overview

Opportunistic Wireless Encryption (OWE) is a Wi-Fi security mechanism standardized under IEEE 802.11 and certified by the Wi-Fi Alliance as part of WPA3.  
It provides encryption for open Wi-Fi networks without requiring user authentication, enhancing security for public or guest networks.  
OWE Transition Mode enables backward compatibility, allowing OWE-capable and legacy devices to coexist on the same network.

This page provides a technical summary of OWE and OWE Transition Mode, including their features, operation, use cases, and limitations.

### OpenWrt Support

Support for OWE in OpenWrt has been available since Jun 16, 2022

***NOTE: The FULL version of wpad is required. ie one of the following:***

- wpad-mbedtls
- wpad-wolfssl
- wpad-openssl

## Definition - Opportunistic Wireless Encryption (OWE)

OWE encrypts wireless traffic on open Wi-Fi networks without requiring passwords or authentication.  
It protects against passive eavesdropping in environments where traditional authentication (e.g., WPA2/WPA3) is impractical.

### Key Features

- Unauthenticated Encryption: Encrypts traffic between clients and access points (APs) without credentials.
- Diffie-Hellman Key Exchange: Uses Elliptic Curve Diffie-Hellman (ECDH) to establish a Pairwise Master Key (PMK) for each client-AP session.
- WPA3-Based: Leverages WPA3’s cryptographic protocols, including AES-based ciphers.
- Seamless Connection: Requires no user interaction, as no password is needed.
- Traffic Protection: Secures unicast and broadcast/multicast traffic.

### Operation

- The AP advertises OWE support in beacon frames, indicating an open network with encryption.
- The client and AP perform an ECDH key exchange during the 4-way handshake to derive encryption keys.
- The session is encrypted using AES-based ciphers (e.g., CCMP).

### Use Cases

- Public Wi-Fi hotspots (e.g., cafes, airports).
- Guest networks in enterprises.
- IoT devices requiring secure connectivity without complex authentication.

### Benefits

- Mitigates risks of unencrypted open networks.
- Simplifies user experience by eliminating password entry.
- Enhances privacy in public Wi-Fi environments.

### Limitations

- Lacks authentication, making it vulnerable to rogue APs or man-in-the-middle attacks.
- Not suitable for high-security environments requiring authenticated access.

## Definition - OWE Transition Mode

OWE Transition Mode enables coexistence of OWE-capable and legacy devices on the same Wi-Fi network, supporting a gradual migration to OWE-enabled networks.

### Key Features

- Dual SSID Behavior: Advertises two logical networks under one SSID:
  
  - An open (unencrypted) network for legacy devices.
  - An OWE-encrypted network for OWE-capable devices.
- Single SSID: Users see one SSID, with clients selecting the appropriate mode (OWE or open) based on capability.
- Robust Security Association (RSA) Query: OWE-capable clients query the AP to confirm OWE support.
- Backward Compatibility: Legacy devices connect to the unencrypted network.

### Operation

- The AP broadcasts a single SSID with beacon frames indicating both open and OWE capabilities.
- OWE-capable clients detect OWE support and initiate an encrypted connection.
- Legacy clients connect to the unencrypted open network.
- The AP maintains separate security contexts for OWE and non-OWE clients.

### Use Cases

- Mixed-device environments with modern and legacy clients.
- Public hotspots transitioning to OWE without disrupting legacy device connectivity.
- Enterprise guest networks supporting diverse devices.

### Benefits

- Simplifies network management with a single SSID.
- Encourages OWE adoption while supporting older devices.
- Transparent to users, as clients handle mode selection.

### Limitations

- Legacy devices remain unencrypted, reducing overall security.
- Requires careful AP configuration to segregate OWE and non-OWE traffic.
- Risk of misconfiguration, where clients may connect to the open network.

## Technical Details

### Cryptographic Protocols

- Key Exchange: ECDH with NIST P-256 curve (or higher) for PMK derivation.
- Encryption: AES-CCMP (128-bit) for data confidentiality and integrity.
- Hashing: SHA-256 or stronger for key derivation.

### Frame Modifications

- OWE support is signaled in the Robust Security Network (RSN) element of beacon and probe response frames.
- OWE Transition Mode includes additional RSN information to advertise both open and OWE networks.

### Standards

- Defined in IEEE 802.11-2016 and later amendments.
- Part of Wi-Fi Alliance’s WPA3 certification.

### Deployment Considerations

- APs must support OWE and Transition Mode in firmware.
- Client devices require OWE support (available in modern OSes like Windows 11, macOS, iOS, and Android 10+).
- Administrators should monitor for rogue APs and prioritize OWE for capable devices.

### Comparison of OWE and OWE Transition Mode

Feature OWE OWE Transition Mode Encryption Always encrypted Encrypted for OWE devices; open for legacy Authentication None None SSID Management Single SSID (OWE only) Single SSID (dual modes) Legacy Support Not supported Supported (unencrypted) Security for Legacy N/A No encryption for legacy devices Use Case Modern devices only Mixed environments

### Example UCI Config Entries for OpenWrt

```
config wifi-iface 'default_radio0'
	option device 'radio0'
	option network 'lan'
	option mode 'ap'
	option ssid 'OpenWrt'
	option encryption 'none'
	option ifname 'open0-0'
	option owe_transition_ifname 'owe0-0'
	option macaddr '96:83:c4:a3:8e:cb'
	option disabled '0'


config wifi-iface 'owe00'
	option device 'radio0'
	option network 'lan'
	option mode 'ap'
	option ssid 'OpenWrt-2g-8ecb'
	option encryption 'owe'
	option ifname 'owe0-0'
	option hidden '1'
	option macaddr '96:83:c4:a7:8e:cb'
	option disabled '0'

```

***Note: Unique mac addresses for the open/transition interface and owe interface are required.***  
***Some firmwares may not ensure unique mac addresses, so it is advised to specify the macaddr option to mitigate potential issues.***

## Conclusion

***OWE*** enhances the security of open Wi-Fi networks by providing encryption without authentication, making it ideal for public and guest networks.  
***OWE Transition Mode*** facilitates adoption by supporting both OWE-capable and legacy devices under a single SSID.  
However, the lack of authentication in both mechanisms necessitates additional security measures (e.g., VPNs) in high-risk environments.  
Proper AP configuration and client support are essential for successful deployment.

## References

- [Commit Adding Support to OpenWrt (on Jun 16, 2022)](https://github.com/openwrt/openwrt/commit/574539ee2cdbb3dd54086423c6dfdd19bb1c06a6 "https://github.com/openwrt/openwrt/commit/574539ee2cdbb3dd54086423c6dfdd19bb1c06a6")
