# bind-server-filter-aaaa: forcing domains to resolve only to IPv4 addresses

This guide explains how to set up a local nameserver that prevents certain domain names from resolving to IPv6 addresses (`AAAA` records). This is useful if you are using an IPv6-over-IPv4 tunnel (such as [IPv6 with Hurricane Electric](/docs/guide-user/network/ipv6/ipv6_henet "docs:guide-user:network:ipv6:ipv6_henet")) and want to use network services that don't support IPv6 tunnels. This setup will strip `AAAA` records from your specified domains--forcing them to use IPv4 only--while allowing IPv6 for all other domains.

#### NOTE

Installing `bind-server` will temporarily interfere with/deactivate dnsmasq. After you install `bind-server`, you will stop it and edit its configuration file so that it can coexist with dnsmasq.

#### Installation

Log into the router through ssh.

Install at least the following packages:

- bind-rndc
- bind-server
- bind-server-filter-aaaa
- bind-dig

After installing bind-server, stop it with `/etc/init.d/named stop`.

#### Configuration

You will set up `named` to listen on port 2053 on loopback addresses, then configure dnsmasq to forward the domains that you want to filter to `named`.

##### Edit /etc/bind/named.conf

At the top level add:

```
plugin query "/usr/lib/bind/filter-aaaa.so" {
  filter-aaaa-on-v4 yes;
  filter-aaaa-on-v6 yes;
};
```

Add this inside the `options` section:

```
  	listen-on port 2053 { 127.0.0.1; };
  	listen-on-v6 port 2053 { ::1; };
        forward only;
        forwarders {
           // your ISP's DNS servers,
           // or your preferred replacements for them
           // examples:
           // 8.8.8.8;
           // 208.67.222.222;
        };
```

#### Enable and restart named

```
service named enable
service named start
```

#### Test named

Test that your filtered domain (`example.com`) has no `AAAA` records, according to your `named`:

```
dig @127.0.0.1 -p 2053 example.com AAAA
```

should provide you with a NOERROR response such as this:

```
; <<>> DiG 9.18.0 <<>> @127.0.0.1 -p 2053 example.com AAAA
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 34488
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 0bfa47e834f331f5010000006225150efca3ef92e372acd9 (good)
;; QUESTION SECTION:
;example.com.			IN	AAAA

;; Query time: 50 msec
;; SERVER: 127.0.0.1#2053(127.0.0.1) (UDP)
;; WHEN: Sun Mar 06 15:09:50 EST 2022
;; MSG SIZE  rcvd: 68
```

Whereas querying a public DNS server:

```
dig @8.8.8.8 -p 53 example.com AAAA
```

will return the IPv6 addresses for the filtered domain, such as:

```
; <<>> DiG 9.18.0 <<>> @8.8.8.8 -p 53 example.com AAAA
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 8182
;; flags: qr rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 512
;; QUESTION SECTION:
;example.com.			IN	AAAA

;; ANSWER SECTION:
example.com.		60	IN	AAAA	fe80::1
example.com.		60	IN	AAAA	fe80::2
example.com.		60	IN	AAAA	fe80::3

;; Query time: 30 msec
;; SERVER: 8.8.8.8#53(8.8.8.8) (UDP)
;; WHEN: Sun Mar 06 15:10:39 EST 2022
;; MSG SIZE  rcvd: 124
```

#### Configure dnsmasq

Now that named is filtering out `AAAA` records for all domains, you will add rules for dnsmasq to forward only the domains from which you want to strip `AAAA` records to your `named`:

```
uci add_list dhcp.@dnsmasq[0].server='/example.com/127.0.0.1#2053'
uci add_list dhcp.@dnsmasq[0].server='/example.net/127.0.0.1#2053'
uci commit
/etc/init.d/dnsmasq restart
```

#### Test dnsmasq forwarding of the domains

Test that your filtered domain (`example.com`) has no `AAAA` records, according to your dnsmasq:

```
dig @127.0.0.1 -p 53 example.com AAAA
```

With a result similar to the result direct from named:

```
; <<>> DiG 9.18.0 <<>> @127.0.0.1 -p 53 example.com AAAA
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 8399
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 9177638017b6a493010000006225159305ed84045f766c04 (good)
;; QUESTION SECTION:
;example.com.			IN	AAAA

;; Query time: 40 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Sun Mar 06 15:12:03 EST 2022
;; MSG SIZE  rcvd: 68
```
