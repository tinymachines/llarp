# PBR app

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

[PBR app](https://docs.openwrt.melmac.net/pbr/ "https://docs.openwrt.melmac.net/pbr/") provides an advanced policy-based routing solution.

## Command-line instructions

Install and enable PBR app.

```
# Install packages
opkg update
opkg install pbr
 
# Enable PBR
uci set pbr.config.enabled="1"
uci commit pbr
service pbr restart
```

## Extras

### Web interface

If you want to manage PBR settings using web interface. Install the necessary packages.

```
# Install packages
opkg update
opkg install luci-app-pbr
service rpcd restart
```

### Support OpenVPN

Support unmanaged protocols like OpenVPN.

```
# Support OpenVPN
uci add_list pbr.config.supported_interface="tun*"
uci commit pbr
service pbr restart
```

### Support Tailscale

Create rules with a lower numeric priority value when using [Tailscale](/docs/guide-user/services/vpn/tailscale/start "docs:guide-user:services:vpn:tailscale:start"). Note that Tailscale (with exit node configured) sets itself up as the default and this may not be reflected in PBR Luci (which might, e.g., still show WAN as default route).

```
# Support Tailscale
uci set pbr.config.wan_ip_rules_priority="1000"
uci commit pbr
service pbr restart
```

### Route LAN to VPN

[Disable gateway redirection](https://docs.openwrt.melmac.net/pbr/#a-word-about-default-routing "https://docs.openwrt.melmac.net/pbr/#a-word-about-default-routing") in the VPN client configuration. Route LAN `192.168.1.0/24` to VPN.

```
# Route LAN to VPN
uci add pbr policy
uci set pbr.@policy[-1].src_addr="192.168.1.0/24"
uci set pbr.@policy[-1].interface="vpn"
uci commit pbr
service pbr restart
```

### Forward WAN port

Forward WAN port to a webserver running on `192.168.1.2`. Arrange this policy above more generic ones.

```
# Forward WAN port
uci add pbr policy
uci set pbr.@policy[-1].src_addr="192.168.1.2"
uci set pbr.@policy[-1].src_port="443"
uci set pbr.@policy[-1].proto="tcp"
uci set pbr.@policy[-1].interface="wan"
uci reorder pbr.@policy[-1]="1"
uci commit pbr
service pbr restart
```

### Prioritize local subnets

Prioritize routing between local subnets `192.168.1.0/24` and `192.168.3.0/24`. Arrange this policy above all others.

```
# Prioritize local subnets
uci set pbr.config.webui_show_ignore_target="1"
uci add pbr policy
uci set pbr.@policy[-1].dest_addr="192.168.1.0/24 192.168.3.0/24"
uci set pbr.@policy[-1].interface="ignore"
uci reorder pbr.@policy[-1]="1"
uci commit pbr
service pbr restart
```
