# fw4 Filtering traffic with IP sets by DNS

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

This guide creates a **set** of IP addresses for traffic filtering and is an equivalent of [dns\_ipset](/docs/guide-user/firewall/fw3_configurations/dns_ipset "docs:guide-user:firewall:fw3_configurations:dns_ipset") based on **nftables/fw4** which is the default starting from *OpenWrt 22.03*.

## Goal

Avoid a direct connection to the IP address bypass of [DNS based filtering](/docs/guide-user/firewall/fw3_configurations/fw3_parent_controls#blocking_name_resolution_dns_by_adblockers "docs:guide-user:firewall:fw3_configurations:fw3_parent_controls") of a website or with DoH. The general use case is a traffic restriction to be applied for SmartTV, IoT and other devices for which you want to enforce limited Internet access.

To achieve this, a **set** of IP addresses is created from a list of allowed or denied domains. A firewall rule to allow or deny traffic to those IP address is then created. The below example refers to the allow case for a specific interface called *wildlan*.

## Prerequisites

1. You need a firewall zone without forwarding to **wan**, so that no traffic to the Internet is allowed by default. Below, this firewall zone is referenced as *wildlan*
2. **dig** and **grep** are installed (only for *Case 2*)
3. A standard fw4 configuration with *inet fw4* table

This wiki covers two cases, based on the *dnsmasq* running version. *Case 1* applies only to *dnsmasq* 2.87 or greater.

## \[CASE 1] Command-line instructions

Install *dnsmasq-full* as follows

```
opkg update; cd /tmp/ && opkg download dnsmasq-full; opkg install ipset libnettle8 libnetfilter-conntrack3;
opkg remove dnsmasq; opkg install dnsmasq-full --cache /tmp/; rm -f /tmp/dnsmasq-full*.ipk;
```

Confirm *dnsmasq* is running with

```
opkg list-installed dns*
```

A valid result looks like *dnsmasq-full - 2.88-1*

In */etc/hotplug.d/iface/20-firewall*, add the below code to create the **nft set** in which we will save the IP addresses, the proposed code is **ipv4** only but can be extended to cover **ipv6**.

```
# Filter wildlan by IP addresses
## Create a set for "inet fw4" table with name "allowlist" that can include "ipv4_addr"
nft add set inet fw4 allowlist { type ipv4_addr \;}
nft insert rule inet fw4 forward_wildlan ip daddr @allowlist accept
```

The *wildlan* zone has no access to Internet unless the target IP address is listed in *allowlist*. With *dnsmasq 2.87*, resolved IPs can be automatically added to a set.

Edit **/etc/dnsmasq.conf** with

```
# The IP address corresponding to allowed.url URLs will be saved in the nftset (/4# filters for ipv4)
nftset=/first.allowed.urls/4#inet#fw4#allowlist
nftset=/second.allowed.urls/4#inet#fw4#allowlist
...
```

Looking to the case in which you want to ensure that only IP addresses resolved via your DNS are allowed, then use # wildcard. This make sense if you want avoid access via direct IP without a filter for specific URLs.

```
nftset=/#/4#inet#fw4#allowlist
```

The relevant IP address of the allowed URLs can be listed with the below command, the set will anyhow remain empty till any of the allowed URLs is resolved via *dnsmasq*.

```
nft list set inet fw4 allowlist
```

## \[CASE 2] Command-line instructions

This applies only to *OpenWrt 22.03*, *OpenWrt 22.03.1* and *OpenWrt 22.03.2* that have an older release of *dnsmasq*. In this case we cannot use *dnsmasq* to automatically fill the IP addresses in the set, so this must be done via a script.

In */etc/hotplug.d/iface/20-firewall*, add the below code to create the **nft set** in which we will save the IP addresses, the proposed code is **ipv4** only but can be extended to cover **ipv6**.

```
# Filter wildlan by IP addresses
## Create a set for "inet fw4" table with name "allowlist" that can include "ipv4_addr"
nft add set inet fw4 allowlist { type ipv4_addr \;}
 
## Add element to "allowlist" from file urls.txt
for address in $(dig a -f /etc/sets-ipdns/wildlan-urls.list +short | grep -v '\.$'); do
	nft add element inet fw4 allowlist {$address timeout 24h}
done
 
nft insert rule inet fw4 forward_wildlan ip daddr @allowlist accept
```

The list of domains to which traffic will be allowed shall be included in a the custom file */etc/sets-ipdns/wildlan-urls.list*. To create the file:

```
cd /etc
mkdir sets-ipdns
cd sets-ipdns
vim wildlan-urls.list
```

List inside **vim** the domain names that shall be allowed.

Based on this forward chain, only the traffic with destination to the IP addresses included in @allowlist will be allowed.

The */etc/hotplug.d/iface/20-firewall* is executed at any change of any interface (so mostly at boot time), so that @allowlist will be filled with IP addresses only at that stage. That **set** shall be periodically updated for two reasons: 1. The IP addresses may change 2. In case of DNS Load Balancing, the same DNS query will result in different IP addresses (all valid) based on time of request.

In the Scheduled Task in Luci or in */etc/crontabs/root*, configure a script to update the **sets** every 15 minutes.

```
15 * * * * /etc/sets-ipdns/update-sets.sh
```

In the */etc/sets-ipdns/update-sets.sh*

```
## Add element to "allowlist" from file urls.txt
for address in $(dig a -f /etc/sets-ipdns/wildlan-urls.list +short | grep -v '\.$'); do
	nft add element inet fw4 allowlist {$address timeout 24h}
done
```

Enable the script and reboot

```
chmod +x /etc/sets-ipdns/update-sets.sh
reboot
```

After reboot, verify the content of the @allowlist and the result should be a list of **ipv4** addresses.

```
nft list set inet fw4 allowlist
```

The final crosscheck is to verify that addresses listed in */etc/sets-ipdns/wildlan-urls.list* can be accessed, no other domains should be accessible unless the same IP address is shared between multiple domains (that happen with CDNs).

## Limitations

In *CASE 1* any URL and sub-URL that is listed will be allowed, rather in *CASE 2* only the exact listed URL will be allowed. This make *CASE 2* functionally working only for services that doesn't use multiple sub-URLs.

In *CASE 2* the script will periodically query the DNS with all domains included in */etc/sets-ipdns/wildlan-urls.list* so that list should be reasonably small.

## Further Improvements

The command line instructions that are included in */etc/hotplug.d/iface/20-firewall* trigger a rebuild of the firewall configuration at each change of any interface. This is not triggered when a UCI/LUCI firewall change is applied. So at any change in the firewall configuration, the rebuild will not involve the custom rules included in */etc/hotplug.d/iface/20-firewall*. As a result, connectivity of devices that rely on this will be lost.

The rules will be reapplied at next change in status of any interface, that could also be triggered on purpose to rebuild the rules.

If in the next released is included a custom file for NFT commands that is triggered at any firewall rebuild, this problem will be solved.
