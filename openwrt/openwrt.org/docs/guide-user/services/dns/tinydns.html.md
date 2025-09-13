# Tinydns

`Tinydns is a DNS server. It accepts iterative DNS queries from hosts around the Internet, and responds with locally configured information. D. J. Bernstein : http://cr.yp.to/djbdns/tinydns.html`

* * *

That a very good choice for makeing a dns server, the openwrt package is amazing, and have really integrate tinydns on openwrt. Tinydns is very nice for make small domain, and have capability to grow without major change. Compare to Bind design deployment that the day and the night. You should consider djbdns tools and the amazing work done by the packager of Djbdns

[https://dev.openwrt.org/browser/packages/net/djbdns/README](https://dev.openwrt.org/browser/packages/net/djbdns/README "https://dev.openwrt.org/browser/packages/net/djbdns/README")

## Install tinydns

Tinydns is all ready aviable on OpenWrt, you can use opkg tool for install it:

```
opkg update
opkg install djbdns-base djbdns-tinydns
```

## Configuration file

**/etc/tinydns/data**

It file contain informations about you Domain Name store in **tinydns-data** format, it format is describ by the author here [http://cr.yp.to/djbdns/tinydns-data.html](http://cr.yp.to/djbdns/tinydns-data.html "http://cr.yp.to/djbdns/tinydns-data.html")

The logic is simple the each line define a thing, and the frist letter of each line is a Flag it define the Type.

- The djbdns-tinydns package provide it file as exemple for make you first tests. You have to edit it file for put you own setting as describ on it document.

<!--THE END-->

- On tipical djbdns deploiement it file is convert to binary cdb format and store in memory, all that work is done via /etc/init.d/tinydns script on OpenWrt.

<!--THE END-->

- Take care about you SOA serial number, each time you change something you have to increase it number. It is not done by the /etc/init.d/tinydns script.

### SOA Serial notes:

`Few admins system like put Epoch (reference date) as SOA serial number, and that a good practice. An other practice can be add +1 each to the SOA Serial number, that work too. That a arbitral value the DNS standard require to add +1 as minimum, that because lot of dns servers will ignore and nor relay you new data file. You can choose to never update it serial if you have only one DNS server at home, but that a bad pratice name “poor design” That the frist cause of mistake increase you SOA manually at all`

## UCI integration

The entire djbdns tools have true UCI integration, here what uci store for tinydns

```
root@openwrt:/# uci show djbdns | grep 'tinydns\|global'
djbdns.@global[0]=global
djbdns.@global[0].runasuser=djbdns
djbdns.@global[0].runasgroup=djbdns
djbdns.@tinydns[0]=tinydns
djbdns.@tinydns[0].logging=0
djbdns.@tinydns[0].interface=lan
```

**djbdns.@global\[0].runasuser** define with which user the /etc/init.d/tinydns script will execute all djbdns tools.

**djbdns.@global\[0].runasgroup** define with which group the /etc/init.d/tinydns script will execute all djbdns tools.

**djbdns.@tinydns\[0].logging** it's the same as export the environement Variable DEBUG before start /etc/init.d/tinydns script. It enable a a mode where init tinydns write it activity.

**djbdns.@tinydns\[0].interface** init script will determine the ip of the interface set here.

For the entire list of what djbdns uci store:

```
root@openwrt:/# uci show djbdns
```

## Script provide by djbdns

tinydns come with several script it can help you to configure your /etc/tinydns/data file.

Usage of they script will be describe later on it document, for the complet howto follow it link: [http://cr.yp.to/djbdns/run-server.html](http://cr.yp.to/djbdns/run-server.html "http://cr.yp.to/djbdns/run-server.html")

/etc/tinydns/add-alias

/etc/tinydns/add-childns

/etc/tinydns/add-host

/etc/tinydns/add-mx

/etc/tinydns/add-ns

## What a tipical conf can be

All IP use for they exemples should be change for you own IP

They docs declare each time the last MX to a antispam black list, that a good practice, same for spf txt entry.

The Reverse address xxx.xxx.xxx.xxx.in-addr.arpa is declare like that for a Local Area Network, in case you use IP public to a Wide Area Network the reverse entry should be done via an ISP (Internet Provider) tool, general a web interface, or a Incident Ticket.

*Minimal setting for a personal usage*:

```
#SOA
Zexemple.net:ns1.exemple.net:hostmaster.exemple.net:1330551249:16384:2048:1048576:2560:::
#NS
.exemple.net:192.168.31.215:ns1.exemple.net:259200:
.215.31.168.192.in-addr.arpa::ns1.exemple.net:259200:
#Domain
+exemple.net:192.168.31.215:86400
#MX
@exemple.net:192.168.31.215:mx1.exemple.net:10:86400
@exemple.net:tarbaby.junkemailfilter.com:tarbaby.junkemailfilter.com:30:86400
:exemple.net:16:\016v=spf1\040mx\040-all:86400
#Exemple Web servers
=www.exemple.net:192.168.31.215:86400
#Mail Server
=mail.exemple.net:192.168.31.215:86400
```

*Multi NS , Multi MX exemple*:

```
#SOA
Zexemple.net:ns1.exemple.net:hostmaster.exemple.net:1330551249:16384:2048:1048576:2560:::
#NS1
.exemple.net:192.168.31.215:ns1.exemple.net:259200:
.215.31.168.192.in-addr.arpa::ns1.exemple.net:259200:
#NS2
.exemple.net:192.168.185.63:ns2.exemple.net:259200:
.63.185.168.192.in-addr.arpa::ns2.exemple.net:259200:
#NS3
.exemple.net:192.168.114.57:ns3.exemple.net:259200:
.57.114.168.192.in-addr.arpa::ns3.exemple.net:259200
#Domain
+exemple.net:192.168.31.215:86400
#MX
@exemple.net:192.168.31.215:mx1.exemple.net:10:86400
@exemple.net:192.168.114.57:mx2.exemple.net:20:86400
@exemple.net:tarbaby.junkemailfilter.com:tarbaby.junkemailfilter.com:30:86400
:exemple.net:16:\016v=spf1\040mx\040-all:86400
#Web servers
=www.exemple.net:192.168.31.215:86400
=www1.exemple.net:192.168.31.215:86400
=www2.exemple.net:192.168.114.57:86400
#Ntp servers
=ntp1.exemple.net:192.168.31.215:86400
=ntp2.exemple.net:192.168.114.57:86400
#Mail Server
=mail.exemple.net:192.168.31.215:86400
#Other
+friends.exemple.net:192.168.72.94:86400
```

## Test you installation

Open a terminal session on you machine, export a env variable name DEBUG, then start/restart the tinydns init script.

```
export DEBUG="1"; /etc/init.d/tinydns restart
```

```
Restarting Authoritative nameserver: tinydns... 
Stopping Authoritative nameserver: tinydns .
Starting Authoritative nameserver: tinydns
starting tinydns
```

The tinydns server restart, but keep the hand, now you can test from an other machine or a other terminal session.

The exemple for make the test is done with djbdns “dnsq” tool but it work with “dig”,“nslookup”, or all other resolver you like.

```
dnsq a mail.exemple.net $YOU_TINYDNS_IP_ADDRESS
```

```
1 mail.exemple.net:
155 bytes, 1+1+3+3 records, response, authoritative, noerror
query: 1 mail.exemple.net
answer: mail.exemple.net 86400 A $IP_ADRESS_MAIL
authority: exemple.net 259200 NS ns1.exemple.net
authority: exemple.net 259200 NS ns2.exemple.net
authority: exemple.net 259200 NS ns3.exemple.net
additional: ns1.exemple.net 259200 A $IP_ADRESS_NS1
additional: ns2.exemple.net 259200 A $IP_ADRESS_NS2
additional: ns3.exemple.net 259200 A $IP_ADRESS_NS3
```

From you frist terminal, you should see tinydns recive and reply to the request

```
c0a8010f:bc4b:3a0c + 0001 mail.exemple.net
stats 1 1 0 0 0 0 0
```

That mean it work, but remenber to back to the normal, because when you'll leave you terminal session tinydns will die with it.

On you first terminal session use the combinaison key “Control + C” for close tinydns then:

```
^C
root@openwrt:/root# unset DEBUG; /etc/init.d/tinydns restart
Restarting Authoritative nameserver: tinydns... 
Stopping Authoritative nameserver: tinydns .
Starting Authoritative nameserver: tinydns
root@openwrt:/root#
```

The tinydns restart and give back the hand, if you have enable the service at startup you'll be a enjoy guy :)

### Have you own domain name :

It's possible to have you own domain for free by exemple with : [http://www.eu.org](http://www.eu.org "http://www.eu.org") , but generally you have to pay to a registar a lease for you domain.
