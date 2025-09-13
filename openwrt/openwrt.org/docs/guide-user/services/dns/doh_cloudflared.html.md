# DoH with Dnsmasq and Cloudflared

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up [DNS over HTTPS](https://en.wikipedia.org/wiki/DNS_over_HTTPS "https://en.wikipedia.org/wiki/DNS_over_HTTPS") on OpenWrt.
- It relies on [Dnsmasq](/docs/guide-user/base-system/dhcp.dnsmasq "docs:guide-user:base-system:dhcp.dnsmasq") and [cloudflared](/packages/pkgdata/cloudflared "packages:pkgdata:cloudflared") for masking DNS traffic as HTTPS traffic. The Cloudflared agent natively supports DoH so, if you are already using it for its tunneling functionalities, you don't need additional packages (DoH proxies).

## Goals

- Encrypt your DNS traffic improving security and privacy.
  
  - Prevent DNS leaks and DNS hijacking.
- Bypass regional restrictions using public DNS providers.
  
  - Escape DNS-based content filters and internet censorship.

## Instructions

As first step, configure the tunnel part of [cloudflared](/packages/pkgdata/cloudflared "packages:pkgdata:cloudflared") normally.

In Cloudflare Zero Trust, create a *DNS Location*. Enable just the DNS over HTTPS (DoH) endpoint. An endpoint such as [https://xxxxxxxxxx.cloudflare-gateway.com/dns-query](https://xxxxxxxxxx.cloudflare-gateway.com/dns-query "https://xxxxxxxxxx.cloudflare-gateway.com/dns-query") will be generated; take note of it

(optional) in Cloudflare Zero Trust, create your desired DNS Policy, inside *Firewall policies*, in order to block web site categories (malware, phishing, etc.) based on their DNS names

Verify that the endpoint is actually reachable and allowing queries: this example sends a DoH query for the 'A' record for '[www.microsoft.com](http://www.microsoft.com "http://www.microsoft.com")':

```
curl -H 'accept: application/dns-json' 'https://xxxxxxxxxx.cloudflare-gateway.com/dns-query?name=www.microsoft.com&type=A'
```

We now need to tell the cloudflared agent to activate also the DoH feature. In `/etc/cloudflared/config.yml`, add the following:

```
    proxy-dns: true
    proxy-dns-port: 5053  # or any unused local port
    proxy-dns-upstream:
      - https://xxxxxxxxxx.cloudflare-gateway.com/dns-query    # the endpoint noted before
    bootstrap: 1.1.1.1
```

Restart cloudflared and check that cloudflared is now listening on port 5053 specified in the `config.yml` file:

```
	netstat -tulnp | grep 5053
	tcp        0      0 127.0.0.1:5053          0.0.0.0:*               LISTEN      12564/cloudflared
        udp        0      0 127.0.0.1:5053          0.0.0.0:*                           12564/cloudflared
```

Now we need to tell dnsmasq to use the endpoint on 5053 as forwarder, and the general Cloudflare DNS address (1.1.1.1) as fallback. Edit the `dnsmasq` section of `/etc/config/dhcp`, making sure to include the following:

```
...
option allservers '0'
...
# Primary DoH proxy (via cloudflared)
list server '127.0.0.1#5053'

# Fallback if DoH proxy is not available
list server '1.1.1.1'
```

Note the *allservers* line: we need to ensure that queries go first to 127.0.0.1#5053, and to 1.1.1.1 only as fallback; not in parallel to both upstreams. See the `allservers` option in [all\_options](/docs/guide-user/base-system/dhcp#all_options "docs:guide-user:base-system:dhcp") for details.

## Testing

Check that DoH is actually enforced, by using Cloudflare's test page ([https://1.1.1.1/help](https://1.1.1.1/help "https://1.1.1.1/help"))
