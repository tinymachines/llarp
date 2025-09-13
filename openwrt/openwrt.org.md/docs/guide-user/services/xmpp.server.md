# Prosody XMPP Server (open messaging protocol)

**Prosody** writen in Lua and small enough for routers and easy to configure.

- [Homepage](https://prosody.im/ "https://prosody.im/")
- [Documentation](https://prosody.im/doc/configure "https://prosody.im/doc/configure")
- [Wiki from Arch Linux](https://wiki.archlinux.org/title/Prosody "https://wiki.archlinux.org/title/Prosody")

## Install

```
opkg update
opkg install prosody
```

## Show me it working ASAP

Faster way is allowing auto-registration to @localhost.

### allow\_registration

```
sed -i -e 's/\(allow_registration = \)false;/\1true;/' /etc/prosody/prosody.cfg.lua
/etc/init.d/prosody restart
```

### XMPP client

Use a XMPP client to add an account to 192.168.1.1 server like:

- [Pidgin](https://pidgin.im/install/ "https://pidgin.im/install/") for Windows, Linux &amp; Mac OS X
- [Conversations](https://conversations.im/ "https://conversations.im/") for Android
- [List of all clients](https://xmpp.org/software/ "https://xmpp.org/software/")

### The right way?

Batch add users with the same password:

```
for f in almursi jow maddes nilfred orca thelexi
do prosodyctl register $f localhost pasword123
done
```

### Not so easy

All users see all others registered users by default.

```
# A roster for everyone
mkdir -p -m 775 /tmp/roster
cd /tmp/roster
# Make a list
echo "acoul
almursi
glp
hauke
jow
juhosg
maddes
nbd
nilfred
orca
thelexi" > lista.txt
for f in $(awk '{print $1}' lista.txt)
# Register
do prosodyctl register $f localhost 123
# Add to group "Familiares" all others, but not self.
sed -e "/$f/ d" lista.txt | awk 'BEGIN {print "return {\n\t[false] = {\n\t\t[\"version\"] = 5;\n\t};\n\t[\"pending\"] = {};"} {print "\t[\"" $1 "@localhost\"] = {\n\t\t[\"groups\"] = {\n\t\t\t[\"Familiares\"] = true;\n\t\t};\n\t\t[\"subscription\"] = \"both\";\n\t\t[\"name\"] = \"" toupper(substr($1, 1, 1)) substr($1, 2) "\";\n\t};"} END {print "}"}' > $f.dat
done
chmod 666 *.dat
# Move to flash at once
mkdir -p -m 775 /etc/prosody/data/localhost/roster
chown prosody:prosody *.dat . /etc/prosody/data/localhost/roster
mv *.dat /etc/prosody/data/localhost/roster/
```

The sausage do:

- Remove the self name from the list
- Print a head
- Print a paragraph to each other with
  
  - name@localhost
  - groups: Familiares
  - Nickname with first letter capitalized
- Print a tail to a file

## Using your DDNS domain

This example requires you to get a example.no-ip.biz domain and install luci-app-ddns. Then is exactly the same as @localhost:

```
# Allow registration?
sed -i -e 's/\(allow_registration = \)false;/\1true;/' /etc/prosody/prosody.cfg.lua
chmod +r /etc/prosody/prosody.cfg.lua
# Start once to create the prosody:prosody account
/etc/init.d/prosody start
/etc/init.d/prosody stop
chown -R prosody:prosody /etc/prosody/data
sed -i -e 's/example.com/example.no-ip.biz/;/enabled = false/ d' /etc/prosody/prosody.cfg.lua
# A roster for everyone
mkdir -p -m 775 /tmp/roster
cd /tmp/roster
# Make a list
echo "acoul
almursi
glp
hauke
jow
juhosg
maddes
nbd
nilfred
orca
thelexi" > lista.txt
mkdir -p -m 775 /etc/prosody/data/example.no-ip.biz/roster
chown -R prosody:prosody /etc/prosody/data
for f in $(awk '{print $1}' lista.txt)
do prosodyctl register $f example.no-ip.biz 123
sed -e "/$f/ d" lista.txt | awk 'BEGIN {print "return {\n\t[false] = {\n\t\t[\"version\"] = 1;\n\t};\n\t[\"pending\"] = {};"} {print "\t[\"" $1 "@example.no-ip.biz\"] = {\n\t\t[\"groups\"] = {\n\t\t\t[\"Familiares\"] = true;\n\t\t};\n\t\t[\"subscription\"] = \"both\";\n\t\t[\"name\"] = \"" toupper(substr($1, 1, 1)) substr($1, 2) "\";\n\t};"} END {print "}"}' > $f.dat
done
chmod 666 *.dat
chown prosody:prosody *.dat .
mv *.dat /etc/prosody/data/example.no-ip.biz/roster/
/etc/init.d/prosody start
# All OK?
cat /var/log/prosody/prosody.err
cat /var/log/prosody/prosody.log
```

### Set your router a DDNS name

After reading how to setup [DDNS client](/docs/guide-user/services/ddns/client "docs:guide-user:services:ddns:client"), you should end with something like this working configuration:

```
uci batch <<'EOF'
set ddns.myddns.domain=example.no-ip.biz
set ddns.myddns.enabled=0
set ddns.myddns.force_interval=22
set ddns.myddns.ip_interface=pppoe-wan
set ddns.myddns.ip_source=interface
delete ddns.myddns.ip_url
set ddns.myddns.password=password
set ddns.myddns.service_name=no-ip.com
set ddns.myddns.username=username
commit ddns
EOF
```

### Set your router the same LAN name as WAN

It would be wise if your router has the same name for LAN clients, so has to not go out and redirected back.

```
uci batch <<'EOF'
add dhcp domain
set dhcp.@domain[-1].ip=192.168.1.1
set dhcp.@domain[-1].name=tplinklogin.net
add dhcp domain
set dhcp.@domain[-1].ip=192.168.1.1
set dhcp.@domain[-1].name=routerlogin.net
add dhcp domain
set dhcp.@domain[-1].ip=192.168.1.1
set dhcp.@domain[-1].name=example.no-ip.biz
commit dhcp
EOF
```

Now these commands have the same effect in your LAN:

```
ssh root@192.168.1.1
ssh root@routerlogin.net
ssh root@tplinklogin.net
ssh root@example.no-ip.biz
```

Your router now has a name!

### Set your own domain name SRV records

Very well! So, for your own domain name may need to setup SRV records if the xmpp server run in another subdomain like this:

```
_xmpp-client._tcp.example.com. 18000 IN SRV 0 5 5222 xmpp.example.com.
_xmpp-server._tcp.example.com. 18000 IN SRV 0 5 5269 xmpp.example.com. 
```

Translated to uci will look like this:

```
uci batch <<'EOF'
add dhcp srvhost
set dhcp.@srvhost[-1].srv=_xmpp-client._tcp.example.com
set dhcp.@srvhost[-1].target=xmpp.example.com
set dhcp.@srvhost[-1].port=5222
set dhcp.@srvhost[-1].class=0
set dhcp.@srvhost[-1].weight=5
add dhcp srvhost
set dhcp.@srvhost[-1].srv=_xmpp-server._tcp.example.com
set dhcp.@srvhost[-1].target=xmpp.example.com
set dhcp.@srvhost[-1].port=5269
set dhcp.@srvhost[-1].class=0
set dhcp.@srvhost[-1].weight=5
commit dhcp
EOF
```

This DNS trick is for someone@xmpp.example.com looks like someone@example.com, but also for fancy names like this full picture:

```
# A record
your-server.EXAMPLE.COM                     IN A            1.2.3.4        # this *must* be an A record and not a CNAME
 
# CNAME records
anon.EXAMPLE.COM                          IN CNAME        your-server.EXAMPLE.COM. # this is what the anonymous binding (non-logged in web users) will connect to
topics.EXAMPLE.COM                        IN CNAME        your-server.EXAMPLE.COM. # to enable channels like food@topics.EXAMPLE.COM
 
# SRV records
_xmpp-client._tcp.EXAMPLE.COM.            IN SRV 5 0 5222 your-server.EXAMPLE.COM.
_xmpp-server._tcp.EXAMPLE.COM.            IN SRV 5 0 5269 your-server.EXAMPLE.COM.
_xmpp-server._tcp.anon.EXAMPLE.COM        IN SRV 5 0 5269 your-server.EXAMPLE.COM.
_xmpp-server._tcp.topics.EXAMPLE.COM      IN SRV 5 0 5269 your-server.EXAMPLE.COM. 
```
