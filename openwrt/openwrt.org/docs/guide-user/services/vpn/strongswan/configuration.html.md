# strongSwan IPsec Configuration via UCI

Linux Charon IPsec daemon can be configured through `/etc/config/ipsec`.

**Note**: this has been updated to the `swanctl`-based configuration, and is current as of `5.9.5` packaging. For previous versions, use the Wiki's page history functionality.

## Sections

### ipsec

**Type** Name Type Required Default Description option zone string no vpn Firewall zone. Has to match the defined [firewall zone](/docs/guide-user/services/vpn/strongswan/firewall#zones "docs:guide-user:services:vpn:strongswan:firewall") list interface string yes (none) Interface that accept VPN traffic (empty for all interfaces, multiple lines for several interfaces) option debug number no 0 Trace level: 0 is least verbose, 4 is most - logs visible from output of logread -f

### remote

Contains tunnel definition.

NameTypeRequiredDefaultDescription enabledbooleanyes(none)Configuration is enabled or not gatewayipaddryes(none)IP address or FQDN name of the tunnel remote endpoint, or permitted subnets that peers can initiate this configuration from (analogue to local\_leftip) local\_gatewayipaddrno(none)IP address or FQDN of the tunnel local endpoint local\_sourceipipaddrno(none)Virtual IP(s) to request in IKEv2 configuration payloads requests, or in IKEv1 mode config (enables sending them/initiating it instead of quick mode) local\_ipipaddrno(none)Local address(es) to use in IKE negotiation when initiating; for responding, enumerates addresses we can negotiate from (and may by subnets or CIDRs) local\_identifierstringno(none)Local identifier for IKE (phase 1) remote\_identifierstringno(none)Remote identifier for IKE (phase 1) authentication\_methodstringyes(none)IKE authentication (phase 1). Only allowed value ath the moment is psk pre\_shared\_keystringno(none)The preshared key for the tunnel if authentication is psk crypto\_proposallistyes(none)List of IKE (phase 1) proposals to use for authentication (see below) tunnellistyes(none)Name of ESP/AH (phase 2) section (see below) keyingtriesintegerno3Number of retransmissions to attempt during initial negotiation dpddelayintervalno30sLiveness interval for IKE encapbooleannofalseForce UDP encapsulation of ESP packets to work around blocking of ESP packets. inactivityintervalno(none)Interval before closing an inactive CHILD\_SA fragmentationstringnoyesUse IKE fragmentation (maybe “yes”, “accept”, “force”, or “no”) mobikestringnoyesEnable MOBIKE on IKEv2 local\_certstringno(none)List of cert pathnames to use for authentication local\_keystringno(none)List of private key pathnames to use with above certificates ca\_certstringno(none)List of names of CA certificates that need to lie in remote peer's certificate's path of trust rekeytimeintervalno(none)IKEv2 interval to refresh keying material; also used to compute lifetime overtimeintervalno(none)Limit on time to complete rekeying/reauthentication (defaults to 10% of rekeytime) send\_certstringnoifaskedSend certificate payloads when using certificate authentication. (“always”, “ifasked”, “never”) send\_certreqbooleannonoSend certificate request payloads to offer trusted root CA certificates to the peer. keyexchangestringnoikev2Version of IKE to negotiation (“ikev1”, “ikev2”, or “ike” for both)

### crypto\_proposal

Definition of encryption proposals. Derived from [strongSwan cipher suites](https://wiki.strongswan.org/projects/strongswan/wiki/IKEv2CipherSuites "https://wiki.strongswan.org/projects/strongswan/wiki/IKEv2CipherSuites")

NameTypeRequiredDefaultDescription encryption\_algorithmstringyes(none)Encryption method (aes128, aes192, aes256, 3des) hash\_algorithmstringyes(none)Hash algorithm (md5, sha1, sha2, ...) not permitted when an AEAD algorithm is used dh\_groupstringyes(none)Diffie-Hellman exponentiation (modp768, modp1024, ...) prf\_algorithmstringno(none)Pseudo-Random Functions to use with IKE (prfmd5, prfsha1, prfsha256, ...); not applicable to ESP

### tunnel

Contains network defintion per tunnel.

NameTypeRequiredDefaultDescription local\_subnetlistyes(none)Local network(s) one per line remote\_subnetlistyes(none)Remote network(s) one per line local\_natsubnetno(none)NAT range for tunnels with [overlapping IP addresses](/docs/guide-user/services/vpn/strongswan/overlappingsubnets "docs:guide-user:services:vpn:strongswan:overlappingsubnets") crypto\_proposallistyes(none)List of ESP (phase two) proposals startactionstringnorouteAction on initial configuration load (none, start, route) updownstringno(none)Path to script to run on CHILD\_SA up/down events lifetimeintervalno(none)Maximum duration of the CHILD\_SA before closing (defaults to 110% of rekeytime) rekeytimeintervalno(none)Duration of the CHILD\_SA before rekeying dpdactionstringno(none)Action done when DPD timeout occurs (may be “none”, “clear”, “hold”, “restart”, “trap”, or “start”) closeactionstringnorouteAction done when CHILD\_SA is closed (may be “add”, “route”, “start”, “none”, or “trap”) if\_idstringno(none)XFRM interface ID set on input and output interfaces (should be coordinated with “ifid” values in route entries on “xfrm” interfaces) prioritystringno(none)Priority of the CHILD\_SA ipcompboolnofalseEnable ipcomp compression hw\_offloadboolnofalseEnable H/W offload

### mschapv2\_secrets

Contains [EAP secrets](https://docs.strongswan.org/docs/latest/interop/windowsEapServerConf.html#_eap_secrets "https://docs.strongswan.org/docs/latest/interop/windowsEapServerConf.html#_eap_secrets") for authentication.

NameTypeRequiredDefaultDescription idstringyes(none)EAP ID (i.e. Username) secretstringyes(none)EAP Secret (i.e. Password)

Local configuration for `/etc/config/ipsec`:

```
config 'ipsec'
  # useful so traffic isn't sourced from internal addresses,
  # which would then requiring NATting and port 4500, etc.
  list 'interface' 'wan'
  option 'zone' 'vpn'
 
config 'remote' 'acme'
  option 'enabled' '1'
  # address of wan device
  option 'local_ip' '6.6.6.6'
  # peer has routable DHCP'd address which changes
  option 'gateway' 'any'
  option 'authentication_method' 'pubkey'
  option 'local_identifier' 'C=US, O=Acme Corporation, CN=headquarters'
  option 'remote_identifier' 'C=US, O=Acme Corporation, CN=soho'
  option 'local_cert' 'headquarters.crt'
  option 'local_key' 'headquarters.key'
  option 'ca_cert' 'acme.crt'
  option 'rekeytime' '4h'
  option 'keyingtries' '0'
  option 'mobike' '0'
  option 'fragmentation' '1'
  list   'crypto_proposal' 'ike_proposal'
  list   'tunnel' 'tun_soho'
 
config 'crypto_proposal' 'ike_proposal'
  option 'encryption_algorithm' 'aes256gcm'
  # no hash_algorithm allowed with AEAD
  option 'dh_group' 'modp3072'
  option prf_algorithm 'prfsha512'
 
# we don't specify subnets because we're going to use XFRM-interfaced based routes instead
config 'tunnel' 'tun_soho'
  list   'local_subnet' '0.0.0.0/0'
  list   'remote_subnet' '0.0.0.0/0'
  option 'if_id' '357'
  option 'rekeytime' '1h'
  # other end is behind NAT or we'd use 'route' to initiate
  option 'startaction' 'none'
  option 'closeaction' 'none'
  list   'crypto_proposal' 'esp_proposal'
 
config 'crypto_proposal' 'esp_proposal'
  option 'encryption_algorithm' 'aes256gcm'
  # no hash_algorithm with allowed with AEAD
  option 'dh_group' 'modp3072'
```

and to support XFRM-based interfaces with associated routing, we put the following into `/etc/config/network`:

```
config 'interface' 'xfrm0'
  option 'ifid' '357'
  option 'tunlink' 'wan'
  option 'mtu' '1438'
  option 'zone' 'vpn'
  option 'proto' 'xfrm'
  # useful if you want to run Bonjour/mDNS across VPN tunnels
  option 'multicast' 'true'
 
config 'interface' 'xfrm0_s'
  option 'ifname' '@xfrm0'
  option 'proto' 'static'
  option 'ipaddr' '192.168.254.1/30'
 
config 'route'
  option 'interface' 'xfrm0'
  option 'target' '192.168.10.0/24'
  option 'source' '192.168.1.1'
```

Lastly, `/etc/config/firewall` requires:

```
config 'zone'
  option 'name' 'vpn'
  option 'network' 'xfrm0'
  option 'input' 'ACCEPT'
  option 'output' 'ACCEPT'
  option 'forward' 'ACCEPT'
  option 'mtu_fix' '1'
 
config 'forwarding'
  option 'src' 'lan'
  option 'dest' 'vpn'
 
config 'forwarding'
  option 'src' 'vpn'
  option 'dest' 'lan'
 
config 'rule'
  option 'name' 'Allow-IPSec-ESP'
  option 'src' 'wan'
  option 'proto' 'esp'
  option 'family' 'ipv4'
  option 'target' 'ACCEPT'
 
config 'rule'
  option 'name' 'Allow-ISP-ISAKMP'
  option 'src' 'wan'
  option 'src_port' '500'
  option 'dest_port' '500'
  option 'proto' 'udp'
  option 'family' 'ipv4'
  option 'target' 'ACCEPT'
```

Lastly generate the certificates for both ends on the hub:

```
root@HQ:~# gencerts -s US acme.com "Acme Corporation" headquarters soho
Generated as headquarters-certs.tar.gz
Generated as soho-certs.tar.gz
root@HQ:~# tar ztvf headquarters-certs.tar.gz 
-r--r--r-- 0/0      1870 2021-06-17 19:01:38 swanctl/x509ca/acme.crt
-r--r--r-- 0/0      1923 2021-06-17 19:01:53 swanctl/x509/headquarters.crt
-r-------- 0/0      3243 2021-06-17 19:01:53 swanctl/private/headquarters.key
root@HQ:~# tar ztvf soho-certs.tar.gz 
-r--r--r-- 0/0      1870 2021-06-17 19:01:38 swanctl/x509ca/acme.crt
-r--r--r-- 0/0      1903 2021-06-17 19:02:04 swanctl/x509/soho.crt
-r-------- 0/0      3243 2021-06-17 19:02:04 swanctl/private/soho.key
root@HQ:~# 
```

Note that the filenames in `headquarters.tar.gz` correspond to `local_cert`, `local_key`, and `ca_cert` above. Similarly, the certificate's subject corresponds to the `local_identifier`:

```
root@HQ:~# openssl x509 -in /etc/swanctl/x509/headquarters.crt -noout -subject
subject=C = US, O = Acme Corporation, CN = headquarters
root@OpenWrt2:~# 
```

As these files are present on the headquarters firewall already, you can remove `headquarters.tar.gz`. You can also remove:

```
/etc/swanctl/x509/soho.crt
/etc/swanctl/private/soho.key
```

as these are only needed on the remote end (SoHo).

Now copy the `soho-certs.tar.gz` file over to the SoHo router, and unpack it with:

```
root@SoHo:~# tar -zxf soho-certs.tar.gz -C /etc
```

Lastly, configure `/etc/config/ipsec` on the SoHo router:

```
config 'ipsec'
  option 'zone' 'vpn'
  listen 'interface' 'wan'
 
config 'remote' 'headquarters'
  option 'enabled' '1'
  option 'local_ip' '%any'
  option 'gateway' '6.6.6.6'
  option 'local_identifier' 'C=US, O=Acme Corporation, CN=soho'
  option 'remote_identifier' 'C=US, O=Acme Corporation, CN=headquarters'
  option 'authentication_method' 'pubkey'
  option 'fragmentation' '1'
  option 'local_cert' 'soho.crt'
  option 'local_key' 'soho.key'
  option 'ca_cert' 'acme.crt'
  option 'rekeytime' '4h'
  option 'keyingtries' '0'
  option 'mobike' 0
  list 'crypto_proposal' 'ike_proposal'
  list 'tunnel' 'tun_headquarters'
 
config 'crypto_proposal' 'ike_proposal'
  option 'encryption_algorithm' 'aes256gcm128'
  # no hash_algorithm allowed with AEAD
  option 'dh_group' 'modp3072'
  option 'prf_algorithm' 'prfsha512'
 
config tunnel 'tun_headquarters'
  list   'local_subnet' '0.0.0.0/0'
  list   'remote_subnet' '0.0.0.0/0'
  option 'if_id' '308'
  option 'rekeytime' '1h'
  option 'startaction' 'trap'
  option 'closeaction' 'none'
  option 'dpdaction' 'restart'
  list 'crypto_proposal' 'esp_proposal'
 
config 'crypto_proposal' 'esp_proposal'
  option 'encryption_algorithm' 'aes256gcm128'
  # no hash_algorithm allowed with AEAD
  option 'dh_group' 'modp3072'
```

Now modify `/etc/config/firewall` as above, and `/etc/config/network` as:

```
config 'interface' 'xfrm0'
  option 'ifid' '308'
  option 'tunlink' 'wan'
  option 'mtu' '1438'
  option 'zone' 'vpn'
  option 'proto' 'xfrm'
  # useful if you want to run Bonjour/mDNS across VPN tunnels
  option 'multicast' 'true'
 
config 'interface' 'xfrm0_s'
  option 'ifname' '@xfrm0'
  option 'proto' 'static'
  option 'ipaddr' '192.168.254.2/30'
 
config 'route'
  option 'interface' 'xfrm0'
  option 'target' '192.168.1.0/24'
  # assuming lan has the address 192.168.10.1/24
  option 'source' '192.168.10.1'
```

And when this is all done, on both ends do:

```
root@HQ:~# /etc/init.d/swanctl enable
root@HQ:~# /etc/init.d/swanctl restart
```
