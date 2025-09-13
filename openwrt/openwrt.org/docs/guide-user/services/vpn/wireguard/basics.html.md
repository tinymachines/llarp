# WireGuard basics

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Protocol

WireGuard is an [OSS](https://en.wikipedia.org/wiki/Open-source_software "https://en.wikipedia.org/wiki/Open-source_software") and protocol that implements [VPN](https://en.wikipedia.org/wiki/Virtual_private_network "https://en.wikipedia.org/wiki/Virtual_private_network") by creating secure point-to-point connections over UDP in routed configurations. It runs as a module inside the Linux kernel and aims for better performance than the IPsec and OpenVPN tunneling protocols. The protocol is designed to provide a general purpose VPN solution and can support [different configuration types](/docs/guide-user/services/vpn/wireguard/serverclient "docs:guide-user:services:vpn:wireguard:serverclient") including point-to-point, client-server, and site-to-site connections.

## Key management

WireGuard generally relies on [public-key cryptography](https://en.wikipedia.org/wiki/Public-key_cryptography "https://en.wikipedia.org/wiki/Public-key_cryptography"). It requires to generate a private and public key for each peer and exchange only the public keys. The private key is best never disclosed outside the peer where it was generated. For better security, you can also generate and exchange a pre-shared key. Each pair of peers should use one pre-shared key.

## Time synchronization

WireGuard is time sensitive and can refuse to pass traffic if the peer's clock is out of sync. It's recommended to rely on NTP for all peers. The issue could be caused by incorrect NTP configuration, or race conditions between netifd and sysntpd services, specifically when RTC is missing. Setting [time forward](/docs/guide-user/services/vpn/wireguard/extras#race_conditions "docs:guide-user:services:vpn:wireguard:extras") on the client side can work around the problem.

## Web interface instructions

### 1. Installing packages

Navigate to **LuCI → System → Software** and install the package [luci-proto-wireguard](/packages/pkgdata/luci-proto-wireguard "packages:pkgdata:luci-proto-wireguard").

Optionally install the package [qrencode](/packages/pkgdata/qrencode "packages:pkgdata:qrencode") to allow creation of a QR code when creating a peer configuration for simple import onto a phone wireguard client.

### 2. Generating keys

Generate a key pair of private and public keys.

```
wg genkey | tee wg.key | wg pubkey > wg.pub
```

- Use the **wg.key** file to configure the WireGuard interface on this router.
- Use the **wg.pub** file to configure peers that will connect to *this* router through the WireGuard VPN.

Alternatively a key pair can be generated later when creating the network interface at step 4 via the Luci web interface.

### 3. Restarting services

Navigate to **LuCI → System → Startup → Initscripts** and click to **network → Restart**.

### 4. Setting up network

To create a new WireGuard interface go to **LuCI → Network → Interfaces → Add new interface...** and select **WireGuard VPN** from the **Protocol** dropdown menu.

### 5. Monitoring status

The menu **LuCI → Status → WireGuard** shows information about the WireGuard VPN.

## Enabling debug support

To have wireguard send debug messages to the kernel message buffer, one must compile the kernel with the following option enabled:

- Global build settings &gt;&gt; Kernel build options &gt;&gt; Compile the kernel with dynamic printk

The resulting option will create **/sys/kernel/debug/dynamic\_debug/control** which can be used to enable debug logging of wireguard with the following command:

```
echo module wireguard +p > /sys/kernel/debug/dynamic_debug/control
```

Now wireguard transactions should be echoed to the kernel message buffer, viewable by a call to dmesg.
