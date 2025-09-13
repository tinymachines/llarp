# Clarifying the term "Interface"

See also: [DSA Mini-Tutorial &gt; Unfinished bits to be incorporated if still relevant](/docs/guide-user/network/dsa/dsa-mini-tutorial#unfinished_bits_to_be_incorporated_if_still_relevant "docs:guide-user:network:dsa:dsa-mini-tutorial")

If you come from some Linux distribution or a router like pfSense, the usage of the term “interface” may be a bit confusing.

An “Interface” in the OpenWrt configuration must not be mixed up with a physical interface. It is tempting. As Unix administrator you know about the `ifconfig` command, so the natural assumption is that e.g. `config interface lan` does what you'd do with `ifconfig`. Well, this is only partially true.

To clarify things (hopefully) let's avoid the term interface and replace it with something more neutral. What we actually configure in OpenWrt could be named a “Connector”. The configuration of a “Connector” combines all properties that are required to attach the device running OpenWrt to a network. This include a physical device (to avoid the term interface altogether, I'll call this a “controller”) and setup information that configures the controller in such a way that it allows the device to join the network.

```
# This is not valid configuration code
config connector 'lan'
	option controller 'eth0'
	option setup 'static'
	option ipaddr '192.168.1.1'
	option netmask '255.255.255.0'
```

If you already know the OpenWrt syntax a bit, you can see that I have replaced `interface` with `connector`, `device` with `controller` and `proto` with `setup` to avoid “interface” and anything related.

Of course, this configuration information has an influence on the controller, and you can see the effects with a command such as `ifconfig` or better `ip a s eth0`. But beware that this is not the complete configuration of `eth0`. There may be more connectors to other networks that involve the same controller. And, depending on the chosen setup, the connector configuration may have effects on other configurable items besides the controller.

As an example, consider IPv6 connectivity. IPv4 and IPv6 define distinct networks. Devices with an IPv4 address cannot talk to devices with an IPv6 address. Therefore, if we want our box to talk to other IPv6 devices, we need an additional connector.

```
# This is not valid configuration code
config connector 'lan6'
	option controller 'eth0'
	option setup 'dhcp6'
```

This configures another network connector that happens to use the same controller. [1)](#fn__1) as the previous connector, but uses a different setup strategy, an automatic strategy using dhcp (for IPv6). Therefore this configuration does not only influence the controller, but also helper processes (in this case `odhcpd`).

To summarize, when reading or writing an OpenWrt network configuration keep in mind that:

- `config interface` is not the configuration of a physical interface, but rather the specification of a connector to some network.
- `device` is usually not the name of something configured with `config interface`, but the name of a physical interface. [2)](#fn__2)
- `proto` is not the protocol used in the network, but the protocol used to setup the physical interface in such a way that it can participate in the network that it is supposed to connect to.

[1)](#fnt__1)

Luckily, using IPv6 does not require new physical devices.

[2)](#fnt__2)

I'm not really sure about this feature, but it seems that you can use `device @<devname>` as a shortcut to refer to the physical interfaces used in another interface configuration.
