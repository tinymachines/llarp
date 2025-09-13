# Bind

##### Before you start

This will deactivate dnsmasq which will also disable automatic creation of your internal hostnames (with a suffix of “lan” or “intra” or whatever you chose to use). You will need to manage the zone files yourself.

This allows you to manage your local DNS using bind and also provide a public DNS server at the same time. Your local lan can still use your router as a DNS server for public and local DNS queries.

This tutorial used “.intra” as the internal hostname suffix and 172.20.0.0/16 as the internal network. Also the tutorial assumes you have some experience with bind.

##### Installation

Install at least the following packages:

- bind-server
- bind-tools

Deactivate the DNS functionality of dnsmasq by setting “port” to “0”.

From this point on you will need “bind” for DNS forwarding and internal hostnames.

Copy the file “/etc/named.conf.example” to “/etc/named.conf” and perform the following steps:

- Add your ISPs name servers to the “forwarders section” if you want to use them. Bind can also work without these since it can perform lookups using the global DNS servers.
- Add two zone files (for “.intra” and “.172.in-addr.arpa”)

#### Local Zone Files

### /etc/bind/named.conf

add:

```
 zone "intra" {
        type master;
        file "/etc/bind/zone.intra";
 };                       

 zone "172.in-addr.arpa" {
        type master;
        file "/etc/bind/zone.172";
 }; 
```

### /etc/bind/zone.intra

```
;
$TTL	604800
@	IN	SOA	intra. root.intra. (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@		IN	NS	router.intra.
@		IN	A	172.20.1.1
router		IN	A	172.20.1.1
host2		IN	A	172.20.1.2
```

### /etc/bind/zone.172

```
;
$TTL	604800
@	IN	SOA	intra. root.intra. (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@		IN	NS	router.intra.
1.1.20		IN	PTR	router.intra.
2.1.20		IN	PTR	host2.intra.
```

Note that the IP addresses must be reversed when creating PTR records.

##### Test

```
dig @localhost intra ANY
```

should provide you with a valid response for your domain “intra”.

##### Finally

“enable” and “start” /etc/init.d/named.
