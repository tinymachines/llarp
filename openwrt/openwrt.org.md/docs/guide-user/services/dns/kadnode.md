# KadNode

KadNode is a lightweight peer-to-peer (p2p) DNS system. Usable for DynDNS purposes.

KadNode finds the IP address of other instances on the Internet or local network. It is used like DNS, but is based on the decentralized BitTorrent network.

KadNode intercepts `.p2p` domain queries on the systems level and resolves them using a decentralized [Kademlia](https://en.wikipedia.org/wiki/Kademlia "https://en.wikipedia.org/wiki/Kademlia") DHT network. Additionally, TLS authentication can be used to make sure the correct IP address was found. If successful, the IP address is passed to the application making the request.

### Features

- Support for two kinds of domains:
- public key domains as &lt;public-key&gt;.p2p
  
  - No need to exchange any further keys/certificates
  - Uses secp256r1 [ECC](https://en.wikipedia.org/wiki/Elliptic-curve_cryptography "https://en.wikipedia.org/wiki/Elliptic-curve_cryptography") key pairs
- named domains like yourdomain.com.p2p
  
  - Needs pre-shared certificates (self-signed root certificates or e.g. “Let's Encrypt”)
  - Uses TLS session handshake for authentication
- Support for mapping of clear text domains to pubkey e.g. myname.p2p ⇒ &lt;public-key&gt;.p2p
- IPv4/IPv6 support
- UPnP/NAT-PMP support
- Local peer discovery
- Small size / ~100KB depending on features / ~50KB compressed
- Command line control program
- NSS support through /etc/nsswitch.conf
- DNS server interface and DNS proxy
- Handles A, AAAA, and SRV requests
- Packages for ArchLinux, Debian, FreeBSD, MacOSX, OpenWrt, Windows
- Peer file import/export on startup/shutdown and every 24h
- Uses sha256 hash method

### How it works

- DHT (Distrbuted Hash Table)
  
  - DHT code from Transmission Bittorrent client
  - Maps 20 Bytes strings to addresses
- OS interface to resolve .p2p domain
  
  - DNS service on separate port
  - NSS (Name Service Switch)

### Documentation

- [Manual Page](https://github.com/mwarning/KadNode/blob/master/misc/manpage.md "https://github.com/mwarning/KadNode/blob/master/misc/manpage.md")
- [Implementation Details](https://github.com/mwarning/KadNode/blob/master/misc/implementation.md "https://github.com/mwarning/KadNode/blob/master/misc/implementation.md")
- [Usage examples](https://github.com/mwarning/KadNode/blob/master/misc/examples.md "https://github.com/mwarning/KadNode/blob/master/misc/examples.md")
- [FAQ](https://github.com/mwarning/KadNode/blob/master/misc/faq.md "https://github.com/mwarning/KadNode/blob/master/misc/faq.md")
- [Video: KadNode decentralized DNS system - 34. Chaos Communication Congress](https://www.youtube.com/watch?v=DFFNEoEYItE "https://www.youtube.com/watch?v=DFFNEoEYItE")

### Installation

```
opkg update
opkg install kadnode
```

### Configuration

Edit the following file:

```
/etc/config/kadnode
```

### LuCI App

luci-app-kadnode is in development here [https://github.com/stokito/luci/tree/luci-app-kadnode](https://github.com/stokito/luci/tree/luci-app-kadnode "https://github.com/stokito/luci/tree/luci-app-kadnode")
