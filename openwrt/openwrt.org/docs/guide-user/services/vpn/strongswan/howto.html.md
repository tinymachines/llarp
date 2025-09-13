# IPsec Legacy IKEv1 Configuration

mostly taken from [https://forum.openwrt.org/viewtopic.php?id=39560](https://forum.openwrt.org/viewtopic.php?id=39560 "https://forum.openwrt.org/viewtopic.php?id=39560")

This IPsec IKEv1 (+xauth) howto was written for old Apple iOS “IPsec” clients. The same kind of setup could be found on some commercial gateways (Netgear, AVM FritzBox, etc.) and third-party IPsec VPN softwares like TheGreenBow or ShrewSoft. For modern deployments, look for IPsec IKEv2 instead.

# install necessary packages

```
      opkg update
```

```
      opkg install strongswan-default strongswan-mod-dhcp strongswan-mod-af-alg strongswan-mod-gcrypt \ 
      strongswan-mod-blowfish strongswan-mod-md4 strongswan-mod-openssl strongswan-mod-pkcs11 \
      strongswan-mod-pkcs8 strongswan-mod-test-vectors strongswan-mod-farp
```

# ipsec config

## /etc/ipsec.conf

```
      # ipsec.conf - strongSwan IPsec configuration file
      
      conn ios
              keyexchange=ikev1
              authby=xauthrsasig
              xauth=server
              left=%any
              leftsubnet=0.0.0.0/0
              leftfirewall=yes
              leftcert=serverCert.pem
              right=%any
              rightsubnet=192.168.1.0/24
              rightsourceip=%dhcp
              rightcert=clientCert.pem
              forceencaps=yes
              auto=add
```

## /etc/ipsec.secrets

```
      # /etc/ipsec.secrets - strongSwan IPsec secrets file
      
      : RSA serverKey.pem
      anyuser : XAUTH "anypassword"
```

## /etc/init.d/ipsec

```
      #!/bin/sh /etc/rc.common
      # ipsec init script
      
      START=46
      STOP=01
      
      start() {
      ipsec start
      }
      
      stop() {
      ipsec stop
      }
      
      restart() {
      ipsec restart
      }
      
      reload() {
      ipsec update
      }
```

remember to run /etc/init.d/ipsec enable when done to enable startup on boot

# strongswan config

## /etc/strongswan.conf

```
      # strongswan.conf - strongSwan configuration file
      
      charon {
      
              dns1 = 192.168.1.1
      
              threads = 16
      
              plugins {
      
                      dhcp {
                              server = 192.168.1.1
                      }
              }
      
      }
      
      pluto {
      
      }
      
      libstrongswan {
      
              #  set to no, the DH exponent size is optimized
              #  dh_exponent_ansi_x9_42 = no
      }
```

# firewall config

## /etc/firewall.user

```
      iptables -I INPUT  -m policy --dir in --pol ipsec --proto esp -j ACCEPT
      iptables -I FORWARD  -m policy --dir in --pol ipsec --proto esp -j ACCEPT
      iptables -I FORWARD  -m policy --dir out --pol ipsec --proto esp -j ACCEPT
      iptables -I OUTPUT   -m policy --dir out --pol ipsec --proto esp -j ACCEPT
```

## /etc/config/firewall

```
      config rule
              option 'src' 'wan'
              option 'proto' 'esp'
              option 'target' 'ACCEPT'
      
      config rule
              option 'src' 'wan'
              option 'proto' 'udp'
              option 'dest_port' '500'
              option 'target' 'ACCEPT'
      
      config rule
              option 'src' 'wan'
              option 'proto' 'udp'
              option 'dest_port' '4500'
              option 'target' 'ACCEPT'
      
      config rule
              option 'src' 'wan'
              option 'proto' 'ah'
              option 'target' 'ACCEPT'
```

next (certificates) is taken from [http://wiki.strongswan.org/projects/strongswan/wiki/IOS\_(Apple)](http://wiki.strongswan.org/projects/strongswan/wiki/IOS_%28Apple%29 "http://wiki.strongswan.org/projects/strongswan/wiki/IOS_(Apple)")

# certificates generation

```
      ipsec pki --gen --outform pem > caKey.pem
      ipsec pki --self --in caKey.pem --dn "C=DE, O=xxx, CN=xxxx" --ca --outform pem > caCert.pem
```

```
      ipsec pki --gen --outform pem > serverKey.pem
      ipsec pki --pub --in serverKey.pem | ipsec pki --issue --cacert caCert.pem --cakey caKey.pem --dn "C=DE, O=xxx, CN=xxx.dyndns.org" \
      --san="xxx.dyndns.org" --flag serverAuth --flag ikeIntermediate --outform pem > serverCert.pem
```

```
      ipsec pki --gen --outform pem > clientKey.pem
      ipsec pki --pub --in clientKey.pem | ipsec pki --issue --cacert caCert.pem --cakey caKey.pem --dn "C=DE, O=xxx, CN=client" --outform pem > clientCert.pem
```

```
      openssl pkcs12 -export -inkey clientKey.pem -in clientCert.pem -name "client" -certfile caCert.pem -caname "xxxx" -out clientCert.p12
```

Replace xxx.dyndns.org with the hostname or IP adress which is used to contact the VPN server.

# copy certificates

```
      cp caCert.pem /etc/ipsec.d/cacerts/
      cp serverCert.pem /etc/ipsec.d/certs/
      cp serverKey.pem /etc/ipsec.d/private/
```

```
      cp clientCert.pem /etc/ipsec.d/certs/
      cp clientKey.pem /etc/ipsec.d/private/
```

Email caCert.pem and clientCert.p12 to Your IPhone/IPad and import them. Create an IPSec VPN Connection from the settings app and use the client certificated and the credentials added to /etc/ipsec.secrets ... and you're done.

# Troubleshooting

If you experience errors, like:

```
      07[KNL] received netlink error: Function not implemented (89)
      07[KNL] unable to add SAD entry with SPI ccc321fa
      07[KNL] received netlink error: Function not implemented (89)
      07[KNL] unable to add SAD entry with SPI 07d0af31
      07[IKE] unable to install inbound and outbound IPsec SA (SAD) in kernel
```

You are most likely missing following packages:

```
      strongswan-mod-kernel-libipsec
      kmod-tun
```

After these are installed, problem should be fixed.

If you have problems with reaching of DHCP.. You probably should install also following modules:

```
      ipset
      iptables-mod-filter
      iptables-mod-nat-extra
      ppp-mod-pppoe
```
