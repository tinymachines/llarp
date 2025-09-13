# dnscrypt-proxy

dnscrypt-proxy is an application that acts as a local DNS stub resolver using [DNSCrypt](https://en.wikipedia.org/wiki/DNSCrypt "https://en.wikipedia.org/wiki/DNSCrypt"). It encrypts your DNS traffic improving security and privacy. dnscrypt-proxy is the client-side version of [dnscrypt-wrapper](https://github.com/Cofyc/dnscrypt-wrapper "https://github.com/Cofyc/dnscrypt-wrapper"). Follow [DNSCrypt with Dnsmasq and dnscrypt-proxy](/docs/guide-user/services/dns/dnscrypt_dnsmasq_dnscrypt-proxy "docs:guide-user:services:dns:dnscrypt_dnsmasq_dnscrypt-proxy") to properly setup DNSCrypt via dnscrypt-proxy on your router.

## Installation

```
opkg update
opkg install dnscrypt-proxy
```

LuCI integration:

```
opkg update
opkg install luci-app-dnscrypt-proxy
```

## Configuration

File: `/etc/config/dnscrypt-proxy`

Name Type Required Default Description `address` string yes `127.0.0.1` The IP address of the proxy server. `port` string yes `5353` Listening port for DNS queries. `providername` string no *none* Provider name for a custom resolver not present in the CSV file. `providerkey` string no *none* Provider public key for a custom resolver not present in the CSV file. `resolveraddress` string no *none* Resolver address for a custom resolver not present in the CSV file. `resolver` string no *none* DNS service for resolving queries. You can't add more than one resolver. `resolvers_list` string no `/usr/share/dnscrypt-proxy/dnscrypt-resolvers.csv` Location of CSV file containing list of resolvers. When you use a custom DNSCrypt server and you later get problems when executing DNSCrypt, have a look in the resolver list (`/usr/share/dnscrypt-proxy/dnscrypt-resolvers.csv`) and make sure the resolver you chose is listed there. If not you may need to manually add it or just update the resolver list with the [official one](https://github.com/dyne/dnscrypt-proxy/blob/master/dnscrypt-resolvers.csv "https://github.com/dyne/dnscrypt-proxy/blob/master/dnscrypt-resolvers.csv"). Be sure to verify the integrity of the file before overwriting the local list! `ephemeral_keys` boolean no `0` Improve privacy by using an ephemeral public key for each query. Note that you cannot yet use it with current (Chaos Calmer) version of OpenWrt as the dnscrypt-proxy package is outdated and uses a version of DNSCrypt, which does not support ephemeral keys. Ephemeral keys option requires extra CPU cycles (especially on non-x86 platforms) and can cause huge system load. Disable it in case of performance problems. Also this option is useless with most DNSCrypt servers (all the servers using short TTLs for the certificates, which is done by default in the Docker image). `client_key` string no *none* Use a client public key for identification. By default, the client uses a randomized key pair in order to make tracking more difficult. This option does the opposite and uses a static key pair, so that DNS providers can offer premium services to queries signed with a known set of public keys. A client cannot decrypt the received responses without also knowing the secret key. The value of this property is the path to a file containing the secret key. The corresponding public key is computed automatically `local_cache` boolean no `0` Cache DNS responses. Should be kept to false (`0`) if [Dnsmasq](/docs/guide-user/base-system/dhcp.dnsmasq "docs:guide-user:base-system:dhcp.dnsmasq") is in use, as it already does DNS caching. `block_ipv6` boolean no `0` Immediately reply to IPv6 requests with an empty value. Useful if your network doesn't support IPv6 as it avoids useless requests to upstream resolvers and having to wait for a response. `blacklist` string no *none* Block IP addresses or names matching a list of patterns. `syslog` boolean no `1` Send logs to the syslog daemon. `syslog_prefix` string no `dnscrypt-proxy` Log entries can optionally be prefixed with a string. `log_level` int no `6` Don't log events with priority above this log level. Valid values are between `0` (critical) to `7` (debug-level messages). `query_log_file` string no *none* File where to log DNS queries. The file name can be prefixed with `ltsv:` in order to store logs using the LTSV format (e.g. `ltsv:/tmp/dns-queries.log`).

### Examples

#### Using a resolver from the CSV file

##### IPv4

```
config dnscrypt-proxy 'dnscryptfrv4'
       option address '127.0.0.1'
       option port '5353'
       option resolver 'dnscrypt.org-fr'
```

##### IPv6

```
config dnscrypt-proxy 'dnscryptnlv6'
       option address '[::1]'
       option port '5354'
       option resolver 'dnscrypt.nl-ns0-ipv6'
```

#### Using a custom resolver

##### IPv4

```
config dnscrypt-proxy 'dnscryptcav4'
       option address '127.0.0.1'
       option port '5355'
       option providername '2.dnscrypt-cert.dnscrypt.ca-1'
       option providerkey '1A53:A3C9:5078:9CBD:D10B:1933:A468:9B6C:846A:40F1:B73D:1752:AECA:C982:9ECB:7CE2'
       option resolveraddress '192.99.183.132:443'
```

##### IPv6

```
config dnscrypt-proxy 'dnscryptdkv6'
       option address '[::1]'
       option port '5356'
       option providername '2.dnscrypt-cert.resolver2.dnscrypt.eu'
       option providerkey '3748:5585:E3B9:D088:FD25:AD36:B037:01F5:520C:D648:9E9A:DD52:1457:4955:9F0A:9955'
       option resolveraddress '[2001:1448:243::dc2]:443'
```
