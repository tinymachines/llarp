# IPsec Modern IKEv2 Road-Warrior Configuration

IPsec Road-Warrior Configuration: Android (app), Windows 7+ (native), iOS9+ (native) BB10 (native), PlayBook, Dtek mobile devices.

The basic context of the so-called “road warrior” configuration:

1. Your OpenWrt router is the firewalled IPsec host or gateway that receives requests to connect from mobile IPsec users
2. IPsec users have a dynamically assigned (private) IP outside your private net which changes frequently.
3. IPsec users frequently move around roaming across different networks.
4. IPsec users require access to both internal and external resources (full tunnel support) through a “gateway”.

[![](/_media/media/doc/howtos/ipsecnet.gif)](/_detail/media/doc/howtos/ipsecnet.gif?id=docs%3Aguide-user%3Aservices%3Avpn%3Astrongswan%3Aroadwarrior "media:doc:howtos:ipsecnet.gif")

This is an IPsec IKEv2 setup that recreates the usual client-server VPN setup. Everything else (PPTP, IPsec IKEv1+xauth, L2TP/IPsec IKEv1, TUN/TAP-based TLS VPN)in my opinion is obsolete and should not be used for new deployments. IKEv2 is built-in to any modern OS. It is supported in Android as well using the Strongswan app.

A note about terminology. IPsec is not a client-server protocol, and it is not a VPN protocol either. Hence, it is incorrect to talk about IPsec servers or IPsec clients. However, on this page, we talk about IPsec-based VPN servers and clients indicating the IPsec gateway or IPsec users respectively.

This configuration makes use of various authentication mechanisms: a certificate-based one and two EAP-based methods using either a username/password challenge (EAP-MSCHAPv2) or certificates (EAP-TLS). They can also be used in parallel by implementing a double round authentication for an added layer of security if your client supports that configuration.

Examples would be a phone or laptop that wants to VPN into a private home network. Note that Strongswan's IKEv2 with MOBIKE lets you leave VPN up ALL the time on a phone with near-zero battery drain or perceptible performance hit. The benefits of this cannot be overstated for the road warrior.

## Prerequisites

- Supported version of OpenWrt (opkg will complain about kernel version if not).
- You probably want to have 16MB flash for strongswan to fit in. And 64MB ram to run it properly.
- [package: strongswan-full](/packages/pkgdata/strongswan-full "packages:pkgdata:strongswan-full") (use `opkg install strongswan-full` to install)
- [package: kmod-crypto-ccm](/packages/pkgdata/kmod-crypto-ccm "packages:pkgdata:kmod-crypto-ccm") &amp; [package: kmod-crypto-sha256](/packages/pkgdata/kmod-crypto-sha256 "packages:pkgdata:kmod-crypto-sha256") (use `opkg install kmod-crypto-ccm kmod-crypto-sha256` to install them if you can't connect and logread complained about something like “netlink error: Function not implemented”)
- OpenSSL ([package: libopenssl](/packages/pkgdata_owrt18_6/libopenssl "packages:pkgdata_owrt18_6:libopenssl")) (to make the .p12 or PKCS#12 package you distribute to clients)
- Depending on the build, you may also need [package: kmod-crypto-gcm](/packages/pkgdata/kmod-crypto-gcm "packages:pkgdata:kmod-crypto-gcm") ([more info](https://github.com/openwrt/packages/issues/16595 "https://github.com/openwrt/packages/issues/16595"))
- [package: openssl-util](/packages/pkgdata/openssl-util "packages:pkgdata:openssl-util") (to make the .p12 or PKCS#12 package you distribute to clients)
- If OpenWRT-LEDE version is less than 17.0.5 then patch the `\lib\functions.sh` file line 161 to:

```
			modprobe $m || :
```

* * *

- Tested on OpenWrt Barrier Breaker r37092-r39879 through to the current (July 2017) Openwrt Designated Driver 50107 on WNDR3700v2.
- Tested on **LEDE Reboot 17.01.4 r3560-79f57e422d / LuCI lede-17.01 branch (git-18.147.69097-36945b5)** on **D-Link DIR-885L**
- Tested on **CHAOS CALMER (15.05.1, r48532)** on **Generic Broadcom BCM47xx board**
- Tested on **OpenWrt 19.07 branch (git-20.057.55219-13dd17f) / OpenWrt 19.07.2 r10947-65030d81f3** on **HiWiFi HC5962**
- \[newly updated swanctl configuration] Tested on **OpenWrt 22.03 branch (git-22.245.77528-487e58a) / OpenWrt 22.03.0 r19685-512e76967f** on **Phicomm K3** (ARMv7 v7I, bcm53xx/generic)

* * *

To make sure Strongswan runs, you can type For ipsec config: `/etc/init.d/ipsec start` For swanctl config, normally you'll see connections successfully loaded (no failed ones): `/etc/init.d/swanctl start` and/or `swanctl --load-all` Note for **swanctl**: you probably don't what `ipsec.*` files in `/etc` and you may want to run `/etc/init.d/ipsec disable` if you are migrating from ipsec config. Ipsec.conf still works on 22.03, but not as stable. You may need to manually restart as it often failed to start when the system starts.

For testing, you will want to run logread in a scrolling window as follows:

`logread && logread -f`

We're going to edit the following:

- **/etc/strongswan.conf**: Strongswan configuration file
- **/etc/config/firewall**: Firewall changes to allow VPN traffic

for ipsec config (openwrt ~21.xx)

- **/etc/ipsec.conf**: Tunnel definitions
- **/etc/ipsec.secrets**: List of secrets and keys
- **/etc/ipsec.d**: Folder for certificates

for swanctl config (openwrt 22.xx+)

- **/etc/swanctl**: Folder for swanctl config

**Note after openssl-util packages are installed:** You may want to disable LUCI's (actually uhttp's) https redirection by commenting out the two `list listen_https` lines in `/etc/config/uhttpd` file.

## strongswan.conf

```
charon {
        load_modular=yes
        dns1 = 10.0.0.1
        nbns1 = 10.0.0.1
        plugins {
                include strongswan.d/charon/*.conf
        }
}
include strongswan.d/*.conf

include /var/ipsec/strongswan.conf
```

In this setup, the IKEv2 daemon will assign the router IP as DNS and WINS server to be used by remote clients. For example, here we use servers available on the private LAN, but you can use public ones as well if you like, even for debug-only purposes. If the server runs on the same device you are configuring this strongswan instance, make sure that DNS server is configured to serve local DNS queries, as requests from virtual clients will appear as originating from inside the router. The default DNS server in OpenWrt, dnsmasq, has such an option: make sure it's enabled. The `load_modular` option allows `charon` to dynamically load required plugins. Note that in earlier versions of StrongSwan (5.1.1 or earlier), you may find that charon plugins are not loading dynamically. You can spot it by changing `charondebug` in `ipsec.conf` to check. If you must use an older version, try explicitly telling charon which plugins you want by adding `load = ...` to charon like this:

```
charon {
load = aes des sha1 sha2 md5 pem pkcs1 gmp random nonce x509 revocation hmac stroke kernel-netlink socket-default updown attr farp dhcp
.....
```

The above issue seems to have been resolved in 5.1.2 according to the [Wiki here.](https://wiki.strongswan.org/projects/strongswan/wiki/PluginLoad "https://wiki.strongswan.org/projects/strongswan/wiki/PluginLoad") Replace the IP addresses with the appropriate values for your INTERNAL network. In this and other examples, I expect your private internal network to be 10.0.1.0/24. This means that your LAN network will still be 10.0.0.0/24 and your VPN clients will connect to your LAN zone using 1.0.1.0/24, so directions do not overlap.

- `dns1` entry tells `charon` (the IKEv2 service) where to go for DNS - typically the OpenWrt host.
- `nbns1` entry tells `charon` where to go for NetBIOS name services if you want to use windows file sharing.

## ipsec.conf

**Please note**: you don't want this part if you are going to use swanctl (recommended for OpenWRT 22.03+). Check the swanctl config part below.

Note that the server is always authenticated via public key, both for certificate-based (pubkey and eap-tls) and username/password-based (eap-mschapv2) client authentication configurations. This REQUIRES you to install certificates on the server and clients. You can choose one or more from the below example configurations, although certificate-based ones are recommended. For certificate-based configurations, if ALL your clients support this feature, you could optionally require an additional username/password-based challenge round.

```
config setup

conn %default
        keyexchange=ikev2
        ike=aes256-aes128-sha1-sha256-modp2048-modp3072
        esp=aes128-aes256-sha256-modp3072-modp2048,aes128-aes256-sha256
        left=%any
        leftauth=pubkey
        leftcert=serverCert_myvpnserver.dyndns.org.pem
        leftid=myvpnserver.dyndns.org
        leftsubnet=0.0.0.0/0;::/0
        right=%any
        rightsourceip=10.0.1.0/24
        #rightdns=8.8.8.8
        eap_identity=%identity
        auto=add

conn rwPUBKEY
        rightauth=pubkey
        rightcert=clientCert_myvpnclient.pem
        #rightauth2=eap-mschapv2

conn rwPUBKEYIOS
        leftsendcert=always
        rightid=myVpnClients
        rightauth=pubkey
        rightcert=clientCert_myvpnclient.pem

conn rwEAPTLS
        rightauth=eap-tls
        rightcert=clientCert_myvpnclient.pem
        #rightauth2=eap-mschapv2

conn rwEAPTLSIOS
        leftsendcert=always
        rightid=myVpnClients
        rightauth=eap-tls
        rightcert=clientCert_myvpnclient.pem

conn rwEAPMSCHAPV2
        leftsendcert=always
        rightauth=eap-mschapv2
        rightsendcert=never
```

Explanation: The notion of “left” and “right” is explained in the strongswan documentation, but briefly, “left” here is the “Local” (Left = Local) or private net you want access to, and “right” is the “Remote” (Right = Remote) or client side.

- The `config setup` block is needed but can be empty
- The `conn %default` block provides default settings if you plan on adding more profiles.
- The `ike =` specify the preferred ciphersuite for the main IKE\_SA. Other ciphersuites your strongswan version accepts by default will remain available unless this option ends with an exclamation mark `!`, the **aes256-aes128-sha1-sha256-modp2048-modp3072** value is the bare minimum for a secure IKE proposal, make sure your clients are at least matching this. Use a stronger preference if you like.
- The `esp =` specify the preferred ciphersuite for the ESP CHILD\_SA. Other ciphersuites your strongswan version accepts by default will remain available unless this option ends with an exclamation mark `!`, the **aes128-aes256-sha256-modp3072-modp2048,aes128-aes256-sha256** value is the bare minimum for a secure ESP proposal, make sure your clients are at least matching this. Use a stronger preference if you like. Here we prefer aes128 for better performances as it's still on par with SHA256 cryptographic strength. Differently from IKE, we have no HMAC-SHA1 because it is not considered safe for a large amounts of ESP traffic. We specify Diffie-Hellman groups in the first preferred proposal to enable Perfect Forward Secrecy (PFS) as each ESP rekey will also imply reauthentication like initially done for IKE. Clients not using PFS are also allowed by the second preferred proposal where no DH groups are specified.
- `conn roadwarriorPUBKRY` is our roadwarrior configuration for pure “IKEv2 Certificate” authenticated clients.
- `conn roadwarriorPUBKRYIOS` is our roadwarrior configuration for pure “IKEv2 Certificate” authenticated clients (select Certificate in iOS VPN settings)
- `conn roadwarriorEAPTLS` is our roadwarrior configuration for “IKEv2 EAP” via EAP-TLS, aka “EAP Certificate”
- `conn roadwarriorEAPTLSIOS` is our roadwarrior configuration for “IKEv2 EAP” via EAP-TLS, aka “EAP Certificate” (select None then Certificate for iOS VPN settings)
- `conn roadwarriorEAPMSCHAPV2` is our roadwarrior configuration for “IKEv2 EAP” via EAP-MSCHAPv2, aka “EAP Password”
- `leftauth = pubkey` tells the host to use certificates.
- `leftid =` the FQDN you put in the cert as subjectAltName (see “--san” option when you make your certs below). Note that it could be anything as long as it matches what you set on the client. Use of dyndns (in the example) is advised if your gateway is also assigned a dynamic address.
- `leftsubnet =` the scope of VPN. 0.0.0.0/0 is a full tunnel, meaning ALL traffic will go through the VPN. You can put 10.0.0.0/24 if you want your clients on 10.0.1.0/24 to use the VPN to reach ONLY those addresses and your private net is 10.0.0.0/24. The full tunnel option is more secure because it prevents a client from acting as a bridge.
- `leftsendcert = always` required by iOS native IKEv2 client
- `right = %any` lets any peer IP connect. (remote user)
- `rightid = myVpnClients` lets iOS client match its Local ID with a SAN in its client certificate.
- `rightdns = 8.8.8.8` Feel free to enable this to push DNS to clients.
- `rightsourceip` = the pool of internal addresses to use for the VPN clients. You may want to assign multiple clients IPs from a subnet that doesn't overlap any of your private LANs (on 10.0.0.0/24), like in this example, setting to something like 10.0.1.0/24. Note that if you have only ONE client connecting, you could use 10.0.1.100**/32** instead, which means that only 1 single host can connect and it will be given that address 10.0.1.100. Otherwise, if you like the clients to be part of the same private subnet you can set this to a single address or a subnet portion that is free and not overlapping with DHCP ranges. Finally, you may alternatively set this to `%dhcp` and configure `/etc/strongswan.d/charon/dhcp.conf` accordingly if you want the client's addresses to be released by DHCP.
- `rightcert =` the cert the client needs
- `rightauth = pubkey` as in roadwarriorPUBKEY section, requires the client to authenticate via pure IKEv2 certificates.
- `rightauth = eap-tls` as in roadwarriorEAPTLS section, requires the client to authenticate via EAP using EAP-TLS method, which is another way of doing certificate-based auth not directly within IKEv2.
- `#rightauth2 = eap-mschapv2` uncomment to enable, requires the client to authenticate via “IKEv2 ... **+ EAP**” which means to perform a second auth round via EAP using the EAP-MSCHAPv2 method (aka “EAP username and password”), but this is not supported on iOS and Windows native IKEv2 clients. Because of strongswan limitations, you can't simultaneously support both single round and double round auth for pubkey authenticated roadwarrior clients (=clients connecting from unknown network locations)
- `eap_identity = %identity` tells strongswan to ask the client for its specific identity to be used in EAP auth, instead of using its IKEv2 identity (ip address).

If you want to issue personal certificates to your clients then you should verify the signing CA's identity instead of the client certificates themselves. To achieve this, use the `rightca=“C=US, O=yyy, CN=xxxx”` directive instead of `rightcert`, where `yyy` and `xxxx` are what you choose in the next steps at Making Keys. More information on this: [strongSwan documentation](http://wiki.strongswan.org/projects/strongswan/wiki/ConnSection "http://wiki.strongswan.org/projects/strongswan/wiki/ConnSection") With the above configuration, you will need to also install caCert.pem on your clients in addition to the client cert - see the 'Making Keys' section below.

## /etc/swanctl/* for swanctl-style config

If you are running Openwrt 22.03+, you probably want this instead of ipsec. We are going to demonstrate setting up a `swanctl.conf` and corresponding files to a similar configuration as the above ipsec configuration. Please note: we are using “default” proposals provided by strongswan here as the test shows they work well with present clients (apps/oses' default settings).

0\. Certificates (including (.pem) key files). Make them and put them in corresponding directories according to the “making of certificate/key files” section above. If you are migrating from ipsec config, move the files in swanctl directory: `/etc/ipsec.d/cacerts/*` → `/etc/swanctl/x509ca/*` ; `/etc/ipsec.d/private/*` → `/etc/swanctl/private/*` ; `/etc/ipsec.d/certs/*` → `/etc/swanctl/x509/*`

1\. Create a `/etc/swanctl/common.conf` file as a counterpart of `conn %default` settings in `ipsec.conf` as `swanctl.conf` does not have such `%default` part but needs to use `include` to do so.

```
      local_addrs  = 0.0.0.0/0,::/0
      remote_addrs = 0.0.0.0/0,::/0
      local {
         auth = pubkey
         certs = serverCert_myvpnserver.dyndns.org.pem
         id = myvpnserver.dyndns.org
      }
      children {
         ikev2clients {
            local_ts  = 0.0.0.0/0;::/0
            esp_proposals = default
         }
      }
      pools = strongswanippool 
      unique = never
      version = 2
      proposals = default
```

**for some reason, you do want to replace `proposals = default` with the following if you are using a later release of openwrt 22.03**

```
      proposals = aes256-aes128-sha256-modp3072-modp2048-modp1024
```

2\. Create main settings in Create a `/etc/swanctl/swanctl.conf`

```
connections {
   rw-eapmschapv2 {
      include ./common.conf
      remote-eapmschapv2 {
         auth = eap-mschapv2
         eap_id = %any
      }
      send_certreq = no
      send_cert = always
   }
   rw-eapmschapv2ios {
      include ./common.conf
      remote-eapmschapv2ios {
         auth = eap-mschapv2
         eap_id = %any
      }
      send_certreq = no
      send_cert = always
   }
   rw-eaptls {
      include ./common.conf
      remote-eaptls {
         auth = eap-tls
         certs = clientCert_myvpnclient.pem
      }
      send_certreq = no
   }
   rw-eaptlsios {
      include ./common.conf
      remote-eaptlsios {
         auth = eap-tls
         certs = clientCert_myvpnclient.pem
         id = myVpnClients
      }
      send_certreq = no
      send_cert = always
   }
   rw-pubkey {
      include ./common.conf
      remote-pubkey {
         auth = pubkey
         certs = clientCert_myvpnclient.pem
      }
      send_certreq = no
   }
   rw-pubkeyios {
      include ./common.conf
      remote-pubkeyios {
         auth = pubkey
         certs = clientCert_myvpnclient.pem
         id = myVpnClients
      }
      send_certreq = no
      send_cert = always
   }
}

secrets {
   rsa- {
      filename="serverKey_myvpnserver.dyndns.org.pem"
   }
   eap-remoteuser {
      id = remoteusername 
      secret = secretpassword
   }
}

pools {
    strongswanippool {
        addrs = 10.0.1.0/24
	# dns = 8.8.8.8
    }
}

# Include config snippets
include conf.d/*.conf

include /var/swanctl/swanctl.conf
```

3\. If you are upgrading from an old router setting (installed strongswan in older OpenWrt versions and did a system upgrade keeping the settings, reinstalled `strongswan-full`), you may want to make sure you have the newly added (as you may find in `.conf-opkg` files) second `include` part in `/etc/swanctl/swanctl.conf`

```
include /var/swanctl/swanctl.conf
```

and `/etc/strongswan.conf`

```
include /var/ipsec/strongswan.conf
```

Also, you may want to rename/remove all `/etc/ipsec.*` files to keep strongswan from using them. You may want to run `/etc/init.d/ipsec disable` (as well as `/etc/init.d/ipsec stop`)

4\. Check the config

```
swanctl --load-all
```

You'll see 6 connections loaded successfully if everything goes well. Otherwise, check the prompts to see what went wrong.

## ipsec.secrets

**Please note**: you don't want this part if you are going to use swanctl (recommended for OpenWRT 22.03+). Check the swanctl config part below.

This configures the key used by the server to authenticate itself against the client, and valid client credentials for any EAP authentication round did via eap-mschapv2 with user/password. Change name according to your certificate name in `/etc/ipsec.d/certs/`.

```
: RSA serverKey_myvpnserver.dyndns.org.pem
remoteusername : EAP "secretpassword"
```

You can skip/ignore this last line if you don't use eap-mschapv2 authentication. Replace `remoteusername` and `secretpassword` with the values you want.

## Making Keys

You will need the certs/keys no matter what kind of config (ipsec/swanctl) you are using.

To make keys, run this script and follow on-screen instructions. It is intended to be run on the OpenWrt router, but you can also manually run the first half on Linux/WSL and move the needed key and certs into the router thereafter.

Existing CACert would be retained for new server/client certs. Remove/rename client* if you want to regenerate clientCert for another user.

```
#!/bin/sh
cd ~
COUNTRYNAME="US"
CANAME="xxxxca"
ORGNAME="yyy"
SERVERDOMAINNAME="myvpnserver.dyndns.org"
CLIENTNAMES="myvpnclient" # or more " … myvpnclient2 muvpnclient3"
SHAREDSAN="myVpnClients" # iOS clients need to match a common SAN
 
echo "Building certificates for [ $SERVERDOMAINNAME ] and client [ $CLIENTNAME (aka $SHAREDSAN) ] "
 
if [ -f "caKey.pem" ] ; then
  echo "caKey exists, using existing caKey for signing serverCert and clientCert...."
elif [ -f "ca.p12" ] ; then
  echo "CA keys bundle exists, accessing existing protected caKey for signing serverCert and clientCert...."
  openssl pkcs12 -in ca.p12 -nocerts -out caKey.pem
else
  echo "generating a new cakey for [ $CANAME ]"
  ipsec pki --gen --outform pem > caKey.pem
fi
echo "generating caCert for [ $CANAME ]..."
ipsec pki --self --lifetime 3652 --in caKey.pem --dn "C=$COUNTRYNAME, O=$ORGNAME, CN=$CANAME" --ca --outform pem > caCert.pem
openssl x509 -inform PEM -outform DER -in caCert.pem -out caCert.crt
echo "Now building CA keys bundle, choose a secure password known by IPsec Administrator ONLY"
openssl pkcs12 -export -inkey caKey.pem -in caCert.pem -name "$CANAME" -certfile caCert.pem -caname "$CANAME" -out ca.p12
 
echo "generating server certificates for [ $SERVERDOMAINNAME ]... "
ipsec pki --gen --outform pem > serverKey_$SERVERDOMAINNAME.pem
ipsec pki --pub --in serverKey_$SERVERDOMAINNAME.pem | ipsec pki --issue --lifetime 3652 --cacert caCert.pem --cakey caKey.pem --dn "C=$COUNTRYNAME, O=$ORGNAME, CN=$SERVERDOMAINNAME" --san="$SERVERDOMAINNAME" --flag serverAuth --flag ikeIntermediate --outform pem > serverCert_$SERVERDOMAINNAME.pem
#openssl x509 -inform PEM -outform DER -in serverCert_$SERVERDOMAINNAME.pem -out serverCert_$SERVERDOMAINNAME.crt
 
for CLIENTNAME in $CLIENTNAMES; do
  if [ -f "clientCert_$CLIENTNAME.pem" ] ; then
    echo "clientCert for [ $CLIENTNAME ] exists, not generating new clientCert."
    continue
  fi
  echo "generating clientCert for [ $CLIENTNAME (aka $SHAREDSAN) ]..."
  ipsec pki --gen --outform pem > clientKey_$CLIENTNAME.pem
  ipsec pki --pub --in clientKey_$CLIENTNAME.pem | ipsec pki --issue --lifetime 3652 --cacert caCert.pem --cakey caKey.pem --dn "C=$COUNTRYNAME, O=$ORGNAME, CN=$CLIENTNAME" --san="$CLIENTNAME" --san="$SHAREDSAN" --outform pem > clientCert_$CLIENTNAME.pem
  openssl x509 -inform PEM -outform DER -in clientCert_$CLIENTNAME.pem -out clientCert_$CLIENTNAME.crt
  echo "Now building Client keys bundle for [ $CLIENTNAME ], choose a secure password known by that Client ONLY (this password will only be required to install certificate and key, not for IPsec authentication)"
  openssl pkcs12 -export -inkey clientKey_$CLIENTNAME.pem -in clientCert_$CLIENTNAME.pem -name "$CLIENTNAME" -certfile caCert.pem -caname "$CANAME" -out client_$CLIENTNAME.p12
  rm clientKey_$CLIENTNAME.pem
  openssl x509 -inform PEM -outform DER -in clientCert_$CLIENTNAME.pem -out clientCert_$CLIENTNAME.crt
done
rm caKey.pem
```

\# where to put them For ipsec config:

```
cp caCert.pem /etc/ipsec.d/cacerts/
echo "copy ca.p12 /somewhere/safe/on/your/pc (includes caCert and caKey, needed to generate more certs for more clients)"
cp serverCert*.pem /etc/ipsec.d/certs/
cp serverKey*.pem /etc/ipsec.d/private/ # keep on your router only, delete and regenerate a fresh one if router gets compromised
rm serverKey*.pem
cp clientCert*.pem /etc/ipsec.d/certs/ # not needed if you authenticate via righca instead of rightcert
echo "copy client_*.p12 /somewhere/safe/on/your/clients"
echo "copy caCert.crt and clientCert_*.crt to /somewhere/safe/on/your/clients for Android clients"
```

For swanctl config: if you are going to use swanctl (recommended for OpenWRT 22.03+), you need to put them in /etc/swanctl/\[corresponding\_sub\_dir] . Check the swanctl config part below for details.

```
cp caCert.pem /etc/swanctl/x509ca/
echo "copy ca.p12 /somewhere/safe/on/your/pc (includes caCert and caKey, needed to generate more certs for more clients)"
cp serverCert*.pem /etc/swanctl/x509/
cp serverKey*.pem /etc/swanctl/private/ # keep on your router only, delete and regenerate a fresh one if router gets compromised
rm serverKey*.pem
cp clientCert*.pem /etc/swanctl/x509/
echo "copy client_*.p12 /somewhere/safe/on/your/clients"
echo "copy caCert.crt and clientCert_*.crt to /somewhere/safe/on/your/clients for Android clients"
```

Now install client.p12 on the clients. Note that caCert has been included already in the client.p12 if you used the above commands. If the client platform requires you to install the CA certificate separately, extract that cert from client.p12 or use the `caCert.crt` file, then install it.

## /etc/config/firewall

Add the following to your firewall configuration. You can use Luci for this.

```
config rule 'ipsec_esp'
	option src 'wan'
	option name 'IPSec ESP'
	option proto 'esp'
	option target 'ACCEPT'
 
config rule 'ipsec_ike'
	option src 'wan'
	option name 'IPSec IKE'
	option proto 'udp'
	option dest_port '500'
	option target 'ACCEPT'
 
config rule 'ipsec_nat_traversal'
	option src 'wan'
	option name 'IPSec NAT-T'
	option proto 'udp'
	option dest_port '4500'
	option target 'ACCEPT'
 
config rule 'ipsec_auth_header'
	option src 'wan'
	option name 'Auth Header'
	option proto 'ah'
	option target 'ACCEPT'
```

for swanctl config, you probably want to add this too:

```
config rule
        option name 'AllowIPsec2WAN'
        list proto 'all'
        option src 'wan'
        option dest 'wan'
        option target 'ACCEPT'
```

Explanation: Basically, you're opening up the ports/protocols on the WAN zone that strongswan needs to accept traffic from a client. You can also create a custom zone called “VPN” if you want to get fancy. Please see [this forum post](https://forum.openwrt.org/t/traffic-is-dropped-for-ipsec-with-firewall4 "https://forum.openwrt.org/t/traffic-is-dropped-for-ipsec-with-firewall4") for more details on how to do that with *fw4* and *nftables*.

For swanctl part, as we used a policy-based VPN, your virtual IPs would be installed on the “outbound” interface on the server, which is usually your wan interface, such as pppoe-wan or something. And your version of OpenWRT probably uses nftables instead of iptables for the firewall, it would block WAN interface to forward by default which makes sense if it only accepts packets to its own IP. But as virtual IPs are considered originated from this interface, they would be dropped by the rule banning all forwarding happening to the packets sent by your virtual IP (and arrived on WAN interface first). They will never make their way to srcnat or something to NAT ““back”” (from WAN) to WANZONE. By adding this AllowIPsec2WAN, you can allow your VPN clients to access the internet (wan) while accessing your lan.

You will also need additional rules in `/etc/firewall.user`. Note that strongswan mentions the `leftfirewall=yes` setting in `ipsec.conf` which was used to add the iptables entries using the `_updown` script in `/usr/libexec/ipsec/_updown` but this has been deprecated and doesn't do anything.

`firewall.user:`

```
iptables -I INPUT  -m policy --dir in --pol ipsec --proto esp -j ACCEPT
iptables -I FORWARD  -m policy --dir in --pol ipsec --proto esp -j ACCEPT
iptables -I FORWARD  -m policy --dir out --pol ipsec --proto esp -j ACCEPT
iptables -I OUTPUT   -m policy --dir out --pol ipsec --proto esp -j ACCEPT
iptables -t nat -I POSTROUTING -m policy --pol ipsec --dir out -j ACCEPT
```

Explanation: You're accepting INPUT, FORWARD(in/out) and OUTPUT traffic originated from and directed to clients matching an IPsec policy. The last rule exempts traffic that matches an IPsec policy from being NAT-ed before tunneling. You wouldn't be able to reach or ping roadwarrior clients without this last rule.

In order for your VPN clients to be able to reach the Internet through this OpenWrt router, you'll need to NAT (or SNAT) them. In case you assigned a `rightsourceip` which belongs to the same subnet of your `lan` interface this NATing is done already by default. Otherwise, if you use `rightsourceip` from a separate subnet you need to explicitly do so by also adding the line below replacing `<YOURWANIF>` accordingly (NOTE: this should be done from `/etc/config/firewall` directly.

```
iptables -t nat -I POSTROUTING -s 10.0.1.0/24 -o <YOURWANIF> -j MASQUERADE
```

### Fix Port Forwards

Note: this shouldn't be needed if you set VPN client's NAT from appropriate /etc/config/firewall locations instead of doing this from firewall.user as explained above.

If you have Port Forwards configured, especially if they are on port 80 and/or 443, you will notice that all of the internet-bound traffic will be redirected to the port forward target. To work around this, using LuCI navigate to the Port Forward, then Edit, then on the Advanced Settings tab under “Extra arguments” add

```
-m policy --dir in --pol none
```

Explication: `-m policy` uses the iptables policy module, and matching on the `--pol none` means no policy. To match on traffic that came from IPSEC, it would have been `--pol ipsec`. The reason this is needed is IPSEC in the kernel shows as coming from the WAN interface even after it's decrypted (rather than from, say, a special virtual IPSEC interface).

### For BlackBerry Clients

BlackBerry allows you to specify Perfect Forward Secrecy. You will want/need this. This should be standard. If you have problems with preferred ciphersuites being too strong, try relaxing them in ipsec.conf file this way:

```
 ike=aes256-aes128-sha1-modp1024
 esp=aes128-aes256-sha1-modp1024,es128-aes256-sha1
```

What this does is specify what cipher suites is preferred, including the **unsecure** MODP1024 for Diffie-Hellman Group which is no more part of default strongswan acceptable proposals. Avoid using the above weak and broken ciphersuite preference whenever possible. You can read about these settings in the [strongswan IKEv2 cipher suite documentation](https://wiki.strongswan.org/projects/strongswan/wiki/IKEv2CipherSuites "https://wiki.strongswan.org/projects/strongswan/wiki/IKEv2CipherSuites").

#### as PUBKEY roadwarriors

Import your certificates into the Berry first, then add a VPN profile with the following settings:

- Your gateway type will be “Generic IKEv2 VPN Server”,
- Authentication Type = PKI,
- Authentication ID Type= Identity Certificate Distinguished Name
- Client Certificate = The name of your client cert (“myvpnclient” in the above example)
- Gateway Auth Type = PKI
- Gateway Auth ID Type = Identify Certificate Distinguished Name
- Gateway CA Certificate = your server Certificate name (“xxxx” in the above example)
- Perfect Forward Secrecy = On (VERY IMPORTANT)
- Automatically determine IP = ON
- Automatically determine DNS = ON
- Automatically determine algorithm = ON

The rest can be left to defaults.

If you receive an Authentication Error you can try to use distinguished name (DN) of your server's certificate instead of the FQDN for the `leftid` property. It is `C=US, O=yyy, CN=myvpnserver.dyndns.org` in the example above, but you can find out yours using the command below and looking for the `Subject` field

```
openssl x509 -in /etc/ipsec.d/certs/serverCert.pem -text -noout
```

## Road-Warriors configuration

For testing, the original author of this page used a Blackberry Z10 with NATIVE Ikev2 support (LOVE your Blackberry), an Android phone with the strongSwan app, Windows 7 and 10+ machines using native IKEv2, and a Blackberry DTek running Android with DTek. We have also tested newer (12+) Android versions (for now, tested on 12 and 13) with the system's native IPSec VPN capability which works as expected.

Hint: you can easily email client certs .p12 bundles (and caCert.crt, if needed) to the mobile device users.

### For Windows Clients

Windows natively supports IKEv2 since Windows 7.

By default, Windows uses an old ciphersuite which is not secure and is no more allowed by strongswan defaults. Read [here](https://web.archive.org/web/20190908105454/https://www.stevenjordan.net/2016/09/secure-ikev2-win-10.html "https://web.archive.org/web/20190908105454/https://www.stevenjordan.net/2016/09/secure-ikev2-win-10.html") to learn how to edit the Windows registry in order to enable **aes256-sha1-modp2048** for IKE. Other ciphers, including more robust ESP proposals and PFS, are available via [Set-VpnConnectionIPsecConfiguration](https://docs.microsoft.com/en-us/powershell/module/vpnclient/set-vpnconnectionipsecconfiguration?view=win10-ps "https://docs.microsoft.com/en-us/powershell/module/vpnclient/set-vpnconnectionipsecconfiguration?view=win10-ps") PowerShell cmdlet.

It is **not recommended** to add back the legacy ciphersuite in ipsec.conf to allow Windows clients to connect with default settings. Use the above registry or PowerShell tweaks to match the bare minimum proposals in the provided above ipsec.conf example.

#### as PUBKEY roadwarriors

You will need administrative rights to set up this kind of VPN connection. Only traditional desktop editions are supported.

In windows, import your client and CA certificates into **Local Machine** storage, not Current User. If you followed this tutorial the CA certificate is already in a bundle with the client cert into the client.p12 package, just take care of importing, again, into **Local Machine** and keep selecting the option to automatically choose the appropriate certificate store. At the end of the import, you should have the CA in “Trusted Root Certification Authorities\\Certificates” store and the client cert in “My\\Certificates” store.

Follow these instructions to set up the Windows VPN connection for using Machine Certificates: [https://supportforums.cisco.com/docs/DOC-24022](https://supportforums.cisco.com/docs/DOC-24022 "https://supportforums.cisco.com/docs/DOC-24022")

Please note: this Machine Certificates setup uses Device certificate/key installed in **Local Machine** keystore and it is not based on EAP. Windows **does not** support EAP with Device certificate/key from **Local Machine** keystore for native VPN client.

#### as EAPTLS roadwarriors

You don't need administrative rights to set up this kind of VPN connection, but you still need to be an admin in order to import the CA cert only. Modern WinRT-based editions are also supported (including WP8+ mobile editions).

In Windows, import your client and CA certificate into **Current User**, not Local Machine. If you followed this tutorial the CA certificate is already in a bundle with the client cert into the client.p12 package, just take care of importing, again, into **Current User** and keep selecting the option to automatically choose the appropriate certificate store. At the end of the import, you should have the CA in “Trusted Root Certification Authorities\\Certificates” store and the client cert in “My\\Certificates” store. Now you need to import this CA as **Local Machine**, you can do it by using the standalone CA cert from the bove steps or export it from the **Current User** CA store after p12 import is done.

Create a new VPN connection from the wizard, choose IKEv2 as the type, and select “Certificate” for the authentication method. Connect, and pick your “myvpnclient” cert when prompted. Please note, split-tunneling is enabled by default in Windows 10+ (just google for “disable Split Tunneling Windows” or read here: [https://docs.microsoft.com/en-us/powershell/module/vpnclient/set-vpnconnection?view=win10-ps#examples](https://docs.microsoft.com/en-us/powershell/module/vpnclient/set-vpnconnection?view=win10-ps#examples "https://docs.microsoft.com/en-us/powershell/module/vpnclient/set-vpnconnection?view=win10-ps#examples").

Please note: this EAP-TLS setup uses User certificate/key installed in **Current User** keystore. Windows **does not** support EAP (including EAP-TLS) with Device certificate/key from **Local Machine** keystore for native VPN client.

### For Android Clients

A CA certificated has to be installed prior for a VPN set up. Download you caCert.crt file to your phone (via email, net-drive, IM or something) and goto your phone's “settings” app. Search for “credential storage” / “install certificate” and select “CA certificate”. Choose the file (caCert.crt) you just downloaded to your phone and install it.

Starting with Android 11 a native IKEv2 implementation is available. For some reason, it didn't work until Android 12.

Android 12 IKEv2 works just fine but it doesn't allow using HMAC-SHA1 for the CHILD\_SA. This wouldn't be an issue unless you explicitly excluded - for whatever reasons - greater integrity algorithms.

For authentication, Android 12 only supports “IKEv2/IPsec RSA” (which is pure “IKEv2 Certificate” PUBKEY authentication), “IKEv2/IPsec PSK” (which is not supported on this page because it's hard to keep secure), and “IKEv2/IPsec MSCHAPv2” (which is EAP-MSCHAPv2). It does not support EAP-TLS, nor any second authentication round.

#### as PUBKEY roadwarriors

You need to install the p12 private cert package from the import certificate wizard (Settings → Security → Cryptography and credentials → Install certificate &gt; User certificate for apps and VPN. Give that credentials bundle a name you can easily distinguish from any other installed certs. You don't need to install the CA cert separately as it is included in the p12 bundle. After install, you can check into Settings → Security → Cryptography and credentials → User credentials → *myvpnclient*, you will see it includes an user certificate, an user private key and the CA certificate.

Then you can go into Settings → Network → VPN → + and choose:

1. Name: give a name to your VPN
2. Type: IKEv2/IPsec RSA
3. Server address: myvpnserver.dyndns.org
4. IPsec identifier: myvpnclient
5. IPsec user certificate: pick the one you previously imported, it contains both a private key and a user certificate with a matching public key
6. IPsec CA certificate: pick the one you previously imported, it also contains the CA certificate with the public key
7. IPsec server certificate: leave as default “(received from server)”

#### as EAPMSCHAPV2 roadwarriors

You'll need your CA certificate installed as mentioned before, but you don't need your user certificate.

Then you can go into Settings → Network → VPN → + and choose:

1. Name: give a name to your VPN
2. Type: IKEv2/IPsec MSCHAPv2
3. Server address: myvpnserver.dyndns.org
4. IPsec identifier: remoteusername ←-your\_user\_name
5. IPsec CA certificate: pick the one you previously imported, it also contains the CA certificate with the public key
6. IPsec server certificate: leave as default “(received from server)”
7. Proxy: None
8. Username: remoteusername ←-your\_user\_name
9. Password: secretpassword ←-your\_pass\_word

### For strongSwan Android's App Clients

If you get a ciphersuite proposal error in your log (eg. “… unacceptable, requesting …”, “NO\_PROPOSAL\_CHOSEN”, “no acceptable proposal found”), you need to override the default ciphersuites proposal in your StrongSwan VPN Profile with something your router supports.

To do that, click Edit on the Profile, and scroll to the bottom to **Advanced settings**. At the bottom, you will find a section called **Algorithms**.

If the error relates to IKE\_SA, edit *IKEv2 Algorithms*, downgrade to **aes256-aes128-sha256-sha1-modp3072-modp2048** or whatever crypto algorithms your router and strongswan version supports for IKE.  
If the error relates to CHILD\_SA, edit *IPsec/ESP Algorithms*, downgrade to **aes128-aes256-sha256-modp3072-modp2048,aes128-aes256-sha256** or **aes128-aes256-sha256-sha1-modp3072-modp2048-modp1024,aes128-aes256-sha256-sha1** or whatever crypto algorithms your router supports for ESP.  
Save, and then try to connect again. Please, avoid using weak or **broken** algorithms, and also avoid using too strong ESP algorithms your router doesn't handle with good performance.

#### as PUBKEY roadwarriors

In Android, go to “Settings &gt; Security” to import certificates.

If you can see both client certificate and CA certificate in the Trusted Credentials - User, you can use “IKEv2 Certificate” or “IKEv2 Certificate + EAP”

In the Strongswan client, specify “IKEv2 Certificate” (“+ EAP” if you enabled second round auth) as the type of VPN, pick “myvpnclient” for the certificate you just imported, and eventually specify the username/password combo you added to `/etc/ipsec.secrets` (or the secrets section of /etc/swanctl/swanctl.conf if you are using swanctl config) for second round auth. Keep an eye on the log file (see above) during the initial login to spot any issues.

If you can only see CA certificate in Android certificate storage, strongswan client app would probably be unable to pick up your client certificate too. But you can still use IKEv2 + MSCHAPv2 aka “IKEv2 EAP (Username/Password)”, simply input username/password as you've set in ipsec.secrets (or the secrets section of /etc/swanctl/swanctl.conf if you are using swanctl config) and server hostname, then you should be up and running.

### For iOS Clients

Beginning with iOS 9, IKEv2 connections are natively supported.

Versions of iOS prior to iOS 9 only support IKEv1. This setup is not recommended. For versions of iOS prior to iOS 9, or to enable a double authentication round you will need to use a third-party app. Cisco's Anyconnect may work but has not been tested.

iOS 12 client requires an additional directive `leftsendcert=always` in the ipsec.conf connection profile example or `send_cert = always` in swanctl.conf file mentioned above. If you encounter the “no matching peer config found” error (in the strongswan machine's log), please check “Local ID” on the iOS client side is set correctly as the rightid in ipsec.conf and matches one of the SANs of the client certificate (e.g. the SHAREDSAN).

#### as PUBKEYIOS roadwarriors

You must install the CA certificate (`caCert.crt`) and the personal certificate (`client.p12`) onto the device, such as by accessing through iCloud drive or an email attachment. You do not need to set the CA certificate to be trusted for websites. You'll need to do it one at a time. And make sure they are marked green as “Verified”. Install the CA certificate again if one is still “unverified” although you've done both.

It follows some sample iOS configurations, from Settings→VPN→Add Configuration.

```
Type: IKEv2
Description: <your choice>
Server: <domain name of VPN server: myvpnserver.dyndns.org>
Remote ID: <same as Server>
Local ID: <SHAREDSAN as in client certificate SAN as well as the rightid in ipsec.conf in IOS-related connection settings: myVpnClients>
User Authentication: **None**
Use Cerificiate: enabled
Certificate: select the certificate imported from client.p12
```

#### as EAPTLSIOS roadwarriors

You must install the CA certificate (`caCert.crt`) and the personal certificate (`client.p12`) onto the device, such as by accessing through iCloud drive or an email attachment. You do not need to set the CA certificate to be trusted for websites. You'll need to do it one at a time. And make sure they are marked green as “Verified”. Install the CA certificate again if one is still “unverified” although you've done both.

It follows some sample iOS configurations, from Settings→VPN→Add Configuration.

```
Type: IKEv2
Description: <your choice>
Server: <domain name of VPN server: myvpnserver.dyndns.org>
Remote ID: <same as Server>
Local ID: <SHAREDSAN as in client certificate SAN as well as the rightid in ipsec.conf in IOS-related connection settings: myVpnClients>
User Authentication: **Certificate**
Certificate: select the certificate imported from client.p12
```

#### as EAPMSCHAPV2 roadwarriors

You must install the CA certificate (`caCert.crt`) onto the device, such as by accessing through iCloud drive or an email attachment. You do not need to set the CA certificate to be trusted for websites.

```
Type: IKEv2
Description: <your choice>
Server: <domain name of VPN server: myvpnserver.dyndns.org>
Remote ID: <same as Server>
Local ID: <can be left blank>
User Authentication: Username
Username: <the one you set in ipsec.secrets>
Password: <the one you set in ipsec.secrets>
```
