# DDNS Client Hurricane Electric

This document describes the steps to configure the DDNS Client via LuCI to use Hurricane Electric's Free DNS Service. In this example I will show the steps to configure host.example.com domain to update with your router's public IP address.

## Requirements

- A domain name. (eg: example.com)
- A [https://dns.he.net/](https://dns.he.net/ "https://dns.he.net/") account
- Installed [DDNS LuCI packages](/docs/guide-user/services/ddns/client#installation "docs:guide-user:services:ddns:client"), the [ca-certificates package](/docs/guide-user/services/ddns/client#ssl_support "docs:guide-user:services:ddns:client")
- Download the CA authority certificate with which the portal for dynamic DNS updates is signed. As of 6.1.2017, dyn.dns.he.net is signed by CACert Level 3 CA.
- Import the 3rd party CA authority certs if you get dyndns errors. See [ca-certificates package](/docs/guide-user/services/ddns/client#ssl_support "docs:guide-user:services:ddns:client") how to import the CACert or any 3rd party certs to `/etc/ssl/certificates` which might be needed to overcome the problems for failing dns updates due to untrusted certificates.

## Domain Setup

Login to your registrar or edit your DNS Zone file to add the NS records for host.example.com to point to ns2.he.net, ns3.he.net, ns4.he.net, and ns5.he.net.

## DNS Host Setup

1. Login to [https://dns.he.net/](https://dns.he.net/ "https://dns.he.net/") and “Add a new domain” for host.example.com
2. Edit the host.example.com zone entry and add click “New A” and enter the Name of “@” and check the “Enable entry for dynamic dns” checkbox.
3. For the newly created A record, find the DDNS column and click the “Generate a DDNS key” circle arrow icon.
4. Generate a new password and copy that text for later before you save the form.

## LuCI Setup

On your OpenWrt router under Services &gt; Dynamic DNS enable the service with this configuration:

- Event interface: wan
- Service: he.net
- Hostname: host.example.com
- Username: host.example.com
- Password: \[the DDNS key you saved above]
- Source of IP address: URL
- URL to detect IP: [http://checkip.dyndns.com](http://checkip.dyndns.com "http://checkip.dyndns.com") (by default)

Save and Apply.

That should do it. If the above is useful and you use Hover to register a domain you can toss the author a buck credit with this referral link: [https://hover.com/hUyus9hH](https://hover.com/hUyus9hH "https://hover.com/hUyus9hH")

Remark: While this DDNS may work for IPv6 tunnel addresses, it does not work for auto-updating a dynamic he.net tunnel - at least on a NAT trunk / 3G with Austrian providers. See details for [https://forums.he.net/index.php?topic=1994.0](https://forums.he.net/index.php?topic=1994.0 "https://forums.he.net/index.php?topic=1994.0") It seems, that the custom url for auto detection of the ipv4 adress is:

```
https://<USERNAME>:<PASSWORD>@ipv4.tunnelbroker.net/nic/update?hostname=<TUNNEL_ID>
https://ipv4.tunnelbroker.net/nic/update?username=<USERNAME>&password=<PASSWORD>&hostname=<TUNNEL_ID>
```

These URLs work well with the correct parameters from the tunnelbroker.net website. When using these values or a custum setup Luci-DDNS will always complain about not being able to retrieve the local IP. That may be due to to format of the URL update script's output format. A workaround may be to call wget from within a cronjob.

## Troubleshooting

Check the /var/log/ddns/myddns\_ipvX.log and google for the error messages of transport agent. Trying to manually authenticate can help you understand better the error and the root cause.
