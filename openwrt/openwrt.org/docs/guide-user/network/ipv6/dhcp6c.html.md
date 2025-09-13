# WIDE-DHCPv6 client configuration

The `/etc/config/dhcp6c` file controls the WIDE-DHCPv6 client package *wide-dhcpv6-client* configuration. It defines *basic properties* and *interface settings*.

## Sections

A typical default configuration consists of one `dhcp6c` section with common settings and one or more `interface` sections, usually covering the *lan* and *loopback* networks.

### Basic Properties

The section of type `dhcp6c` named `basic` defines common client settings.

Example:

```
config 'dhcp6c' 'basic'
        option 'enabled'              '1'
        option 'interface'            'wan'
        option 'pd'                   '1'
        option 'domain_name_servers'  '1'
        option 'script'               '/usr/bin/dhcp6c-state'
```

All defined options of this section are listed below.

Name Type Required Default Description `enabled` boolean no `0` Specifies whether the DHCPv6 client should be started on boot `interface` string yes `wan` Specifies the *logical interface name* the client is running on `dns` string no `dnsmasq` Specifies the type of DNS server in use to propagate received DNS information. At the time of writing, only *dnsmasq* is supported `debug` boolean no `0` Enables additional debug information in the system log `pd` boolean no `1` Requests prefix delegation at the DHCPv6 server `na` boolean no `0` Requests a permanent, non temporary address at the DHCPv6 server `rapid_commit` boolean no `1` Signalize a rapid commit two message exchange ([RFC3315](http://tools.ietf.org/html/rfc3315#section-22.14 "http://tools.ietf.org/html/rfc3315#section-22.14")) `domain_name_servers` boolean no `1` Request a DNS server addresses `domain_name` boolean no `0` Request the domain name `ntp_servers` boolean no `0` Request NTP server addresses ([RFC5908](http://tools.ietf.org/html/rfc5908#section-4.1 "http://tools.ietf.org/html/rfc5908#section-4.1")) `sip_server_address` boolean no `0` Request SIP server address ([RFC3319](http://tools.ietf.org/html/rfc3319#section-3 "http://tools.ietf.org/html/rfc3319#section-3")) `sip_server_domain_name` boolean no `0` Request SIP domain names ([RFC3319](http://tools.ietf.org/html/rfc3319#section-3.1 "http://tools.ietf.org/html/rfc3319#section-3.1")) `nis_server_address` boolean no `0` Request Network Information Service (NIS) server address ([RFC3898](http://tools.ietf.org/html/rfc3898#section-3 "http://tools.ietf.org/html/rfc3898#section-3")) `nis_domain_name` boolean no `0` Request Network Information Service (NIS) domain name ([RFC3898](http://tools.ietf.org/html/rfc3898#section-5 "http://tools.ietf.org/html/rfc3898#section-5")) `nisp_server_address` boolean no `0` Request Network Information Service V2 (NIS+) server address ([RFC3898](http://tools.ietf.org/html/rfc3898#section-4 "http://tools.ietf.org/html/rfc3898#section-4")) `nisp_domain_name` boolean no `0` Request Network Information Service V2 (NIS+) domain name ([RFC3898](http://tools.ietf.org/html/rfc3898#section-6 "http://tools.ietf.org/html/rfc3898#section-6")) `bcmcs_server_address` boolean no `0` Request Broadcast and Multicast Control Service (BCMCS) address ([RFC4280](http://tools.ietf.org/html/rfc4280#section-4.4 "http://tools.ietf.org/html/rfc4280#section-4.4")) `bcmcs_server_domain_name` boolean no `0` Request Broadcast and Multicast Control Service (BCMCS) domain name ([RFC4280](http://tools.ietf.org/html/rfc4280#section-4.2 "http://tools.ietf.org/html/rfc4280#section-4.2")) `duid` string no *(derived from MAC address)* Override the DUID used for DHCPv6 requests. The DUID must be specified as a set of at least 7 colon separated heximal digits, e.g. `00:03:00:06:D8:5D:4C:A5:03:F2` `script` file path no `/usr/bin/dhcp6c-state` Path of script which is executed when a reply is received

### Interface Settings

Sections of type `interface` define on which interfaces delegated prefixes are added and how they're aggregated. This sections are *named*, the section name corresponds to the covered *logical interface*.

Example:

```
config 'interface' 'lan'
        option 'enabled' '1'
        option 'sla_id'  '0'
        option 'sla_len' '8'
```

- `lan` specifies that this section belongs to the LAN interface
- `sla_id 0` selects the 1st subnet out of the delegated prefix
- `sla_len 8` defines that the received prefix is expected to be 56 bits in size (`64` - `8` = `56`)

The valid options of this section are listed blow.

Name Type Required Default Description `enabled` boolean no `0` Specifies whether a prefix should be added on this interface `sla_id` integer yes *(none)* Specifies the *site level aggregator identifier* (selects the subnet out of the delegated prefix) `sla_len` integer yes *(none)* Specifies the *site level aggregator length* which is the difference of 64 and the delegated prefix size, e.g. `/64` minus `/56` from ISP = `8`

## Example

This example requests a `/56` sized prefix and DNS servers on `wan` and configures two `/64` subnets out of the prefix on `lan` and `loopback`. The `loopback` interface gets the first subnet assigned, `lan` the second.

```
config 'dhcp6c' 'basic'
        option 'enabled'              '1'
        option 'interface'            'wan'
        option 'pd'                   '1'
        option 'domain_name_servers'  '1'
        option 'script'               '/usr/bin/dhcp6c-state'
 
config 'interface' 'loopback'
        option 'enabled' '1'
        option 'sla_id'  '0'
        option 'sla_len' '8'
 
config 'interface' 'lan'
        option 'enabled' '1'
        option 'sla_id'  '1'
        option 'sla_len' '8'
```
