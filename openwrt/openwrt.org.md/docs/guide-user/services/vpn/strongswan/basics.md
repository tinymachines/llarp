# IPsec basics

A quick starters guide based on OpenWrt Barrier Breaker 14.07. Maybe it will save you and me time if one has to setup an IPsec VPN in the future. Hopefully it will encourage other people to use OpenWrt as an IPsec VPN router. We cannot provide a graphical user interface at the moment but at least it is a solid alternative to commercial IPsec appliances. strongSwan is a recommended IPsec implementation.

## Packages

If not already installed on your router you need the following packages.

### Required

- strongswan-default: everything needed for IPsec tunnels
- ip: Required to make scripting easier
- iptables-mod-nat-extra: For VPN networks with [overlapping IP addresses](/docs/guide-user/services/vpn/strongswan/overlappingsubnets "docs:guide-user:services:vpn:strongswan:overlappingsubnets")
- djbdns-tools: for simpler name resolving than nslookup

```
opkg install strongswan-default ip iptables-mod-nat-extra djbdns-tools
```

### Optional

- strongswan-utils: only if you are running Chaos Calmer or you experience “ipsec: not found” error.

```
opkg install strongswan-utils
```

- kmod-crypto-echainiv: only for Turris Omnia if you receive an “SAD entry with SPI” error.

```
opkg install kmod-crypto-echainiv
```

Altogether those packages will eat up about some MB of your router's flash memory. Maybe it is time for an [extroot\_configuration](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration") installation?

## Configuration concept

If you already worked with strongSwan you should know the different files you need to configure. They include:

- **/etc/strongswan.conf**: Central configuration file
- **/etc/ipsec.conf**: Tunnel definitions
- **/etc/ipsec.secrets**: List of preshared keys
- **/etc/ipsec.d**: Folder for certificates

![:!:](/lib/images/smileys/exclaim.svg) Remark! If youwant to stay with that configuration you have reached the wrong place.

The major challenge is handling all of those files automatically with a clean integration into the OpenWrt configuration concept. To solve this we will use a hierarchical configuration process. That involves:

- **/etc/config/ipsec**: The OpenWrt configuration file for strongSwan
- **/etc/init.d/ipsec**: The Strongswan start script. It will generate the required configuration files for strongSwan
- **/var/ipsec.conf**: The generated Strongswan config
- **/var/ipsec.secrets** : The generated file with preshared keys
- **/var/strongswan.conf** : The generated central configuration file

Here is a short example of the configuration methodology when having two VPN tunnels to ACME and Yabadoo networks

```
#/etc/config/ipsec
config 'remote' 'ACME'
  option 'enabled' '1'
  option 'gateway' '1.2.3.4'
  list   'tunnel' 'acme_lan'
  ...

config 'tunnel' 'acme_lan'
  option 'local_subnet' '192.168.213.64/26'
  option 'remote_subnet' '192.168.10.0/24'
  ...

config 'remote' 'Yabadoo'
  option 'enabled' '1'
  option 'gateway' '5.6.7.8'
```

Read more about the complete syntax for [/etc/config/ipsec](/docs/guide-user/services/vpn/strongswan/configuration "docs:guide-user:services:vpn:strongswan:configuration").

## IKE Daemon

To let Charon run as a background daemon we can place a hook in the init environment. Therefore create the file **/etc/init.d/ipsec** and set the executable bit. Remark: This script is in an early alpha state. It currently works for site to site tunnels with preshared keys. Feel free to enhance it.

```
#!/bin/sh /etc/rc.common
#/etc/init.d/ipsec - version 6 - 2016/09/13
 
NAME=ipsec
START=60
STOP=60
 
. $IPKG_INSTROOT/lib/functions.sh
. $IPKG_INSTROOT/lib/functions/service.sh
 
FileSecrets=/var/ipsec/ipsec.secrets
FileConn=/var/ipsec/ipsec.conf
FileCommon=/var/ipsec/strongswan.conf
 
FolderCerts=/var/ipsec/ipsec.d
 
Connections=""
 
ConfigUser()
{
  local enabled
  local xauth
  local name
  local password
  local crt_subject
 
  config_get_bool enabled $1 enabled 0
  [[ "$enabled" == "0" ]] && return
 
  config_get_bool xauth       $1 xauth       0
  config_get      name        $1 name        ""
  config_get      password    $1 password    ""
 
  if [ $xauth -eq 1 -a "$name" != "" -a "$password" != "" ]; then
    echo "$name : XAUTH \"$password\"" >> $FileSecrets
  fi
}
 
ConfigPhase1() {
  local encryption_algorithm
  local hash_algorithm
  local dh_group
 
  config_get encryption_algorithm  "$1" encryption_algorithm
  config_get hash_algorithm        "$1" hash_algorithm
  config_get dh_group              "$1" dh_group
 
  Phase1Proposal=${Phase1Proposal}","${encryption_algorithm}-${hash_algorithm}-${dh_group}
}
 
WriteOption() {
  echo "  $1" >> $FileConn
}
 
ConfigTunnel() {
  local local_subnet
  local local_nat
  local remote_subnet
  local p2_proposal
  local pfs_group
  local encryption_algorithm
  local authentication_algorithm
  local remote_name="$2"
 
  config_get local_subnet             "$1"           local_subnet
  config_get local_nat                "$1"           local_nat ""
  config_get remote_subnet            "$1"           remote_subnet
  config_get p2_proposal              "$1"           p2_proposal
  config_get pfs_group                "$p2_proposal" pfs_group
  config_get encryption_algorithm     "$p2_proposal" encryption_algorithm
  config_get authentication_algorithm "$p2_proposal" authentication_algorithm
 
  [[ "$local_nat" != "" ]] && local_subnet=$local_nat
 
  p2_proposal="${encryption_algorithm}-${authentication_algorithm}-${pfs_group}"
 
  Connections="$Connections $ConfigName-$1"
 
  echo "conn $ConfigName-$1" >> $FileConn
  echo "  keyexchange=ikev1" >> $FileConn
  echo "  left=$LocalGateway" >> $FileConn
  echo "  right=$RemoteGateway" >> $FileConn
  echo "  leftsubnet=$local_subnet" >> $FileConn
  if [ "$AuthenticationMethod" = "psk" ]; then
    echo "  leftauth=psk" >> $FileConn
    echo "  rightauth=psk" >> $FileConn
    echo "  rightsubnet=$remote_subnet" >> $FileConn
    echo "  auto=route" >> $FileConn
  elif [ "$AuthenticationMethod" = "xauth_psk_server" ]; then
    echo "  authby=xauthpsk" >> $FileConn
    echo "  xauth=server" >> $FileConn
    echo "  modeconfig=pull" >> $FileConn
    echo "  rightsourceip=$remote_subnet" >> $FileConn
    echo "  auto=add" >> $FileConn
  fi
  if [ "$LocalIdentifier" != "" ]; then
    echo "  leftid=$LocalIdentifier" >> $FileConn
  fi
  if [ "$RemoteIdentifier" != "" ]; then
    echo "  rightid=$RemoteIdentifier" >> $FileConn
  fi
 
  echo "  esp=$p2_proposal" >> $FileConn
  echo "  ike=$Phase1Proposal" >> $FileConn
  echo "  type=tunnel" >> $FileConn
  config_list_foreach "$2" extra_option WriteOption 
}
 
ConfigRemote() {
  local enabled
  local gateway
  local pre_shared_key
  local authentication_method
  local local_identifier
  local remote_identifier
  local local_gateway
 
  ConfigName=$1
 
  config_get_bool enabled "$1" enabled 0
  [[ "$enabled" == "0" ]] && return
 
  config_get gateway               "$1" gateway
  config_get pre_shared_key        "$1" pre_shared_key
  config_get authentication_method "$1" authentication_method
  config_get local_identifier      "$1" local_identifier
  config_get remote_identifier     "$1" remote_identifier
  config_get local_gateway         "$1" local_gateway
 
  AuthenticationMethod=$authentication_method
  LocalIdentifier=$local_identifier
  RemoteIdentifier=$remote_identifier
 
  RemoteGateway=$gateway
  if [ "$RemoteGateway" = "any" ]; then
    RemoteGateway="%any"
    LocalGateway=`ip route get 1.1.1.1 | awk -F"src" '/src/{gsub(/ /,"");print $2}'`
  else
    LocalGateway=`ip route get $RemoteGateway | awk -F"src" '/src/{gsub(/ /,"");print $2}'`
  fi
  [ -z "$local_gateway" ] || LocalGateway="$local_gateway"
 
  echo "$LocalGateway $RemoteGateway : PSK \"$pre_shared_key\"" >> $FileSecrets
 
  Phase1Proposal=""
  config_list_foreach "$1" p1_proposal ConfigPhase1
  Phase1Proposal=`echo $Phase1Proposal | cut -b 2-`
 
  config_list_foreach "$1" tunnel ConfigTunnel "$1"
}
 
PrepareEnvironment() {
  local debug
 
  for d in cacerts aacerts ocspcerts crls acerts; do
    mkdir -p $FolderCerts/$d 2>/dev/null
  done
 
  if [ ! -L /etc/ipsec.d ]; then
    rm -rf /etc/ipsec.d 2>/dev/null
    ln -s $FolderCerts /etc/ipsec.d
  fi
 
  if [ ! -L /etc/ipsec.secrets ]; then
    rm /etc/ipsec.secrets 2>/dev/null
    ln -s $FileSecrets /etc/ipsec.secrets
  fi
 
  if [ ! -L /etc/strongswan.conf ]; then
    rm /etc/strongswan.conf 2>/dev/null
    ln -s $FileCommon /etc/strongswan.conf
  fi
 
  if [ ! -L /etc/ipsec.conf ]; then
    rm /etc/ipsec.conf 2>/dev/null
    ln -s $FileConn /etc/ipsec.conf
  fi
 
  echo "# generated by /etc/init.d/ipsec" > $FileConn
  echo "version 2" >> $FileConn
  echo 'config setup' >> $FileConn
  config_list_foreach "$1" setup_option WriteOption 
 
  echo "# generated by /etc/init.d/ipsec" > $FileSecrets
 
  config_get debug "$1" debug 0
 
  echo "# generated by /etc/init.d/ipsec" > $FileCommon
  echo "charon {" >> $FileCommon
  echo "  load = aes des sha1 sha2 md5 gmp random nonce hmac stroke kernel-netlink socket-default updown" >> $FileCommon
  echo "  filelog {" >> $FileCommon
  echo "    /var/log/charon.log {" >> $FileCommon
  echo "      time_format = %b %e %T" >> $FileCommon
  echo "      ike_name = yes" >> $FileCommon
  echo "      append = no" >> $FileCommon
  echo "      default = " $debug >> $FileCommon
  echo "      flush_line = yes" >> $FileCommon
  echo "    }" >> $FileCommon
  echo "  }" >> $FileCommon
  echo "}" >> $FileCommon
 
}
 
CheckInstallation() {
  if [ ! -x $(which ip) ]; then
    echo ip is missing
    echo install with \"opkg install ip\" or \"opkg install ip-tiny\"
    exit
  fi
 
  for f in aes authenc cbc hmac md5 sha1 sha256; do
    if [ `opkg list kmod-crypto-$f | wc -l` -eq 0 ]; then
      echo kmod-crypto-$f missing
      echo install with  \"opkg install kmod-crypto-$f --nodeps\"
      exit
    fi
  done
 
  for f in aes gmp hmac kernel-netlink md5 random sha1 sha2 updown attr resolve; do
    if [ ! -f /usr/lib/ipsec/plugins/libstrongswan-${f}.so ]; then
      echo /usr/lib/ipsec/plugins/$f missing
      echo install with \"opkg install strongswan-mod-$f --nodeps\"
      exit
    fi
  done
}
 
start() {
  CheckInstallation
 
  config_load ipsec
  config_foreach PrepareEnvironment ipsec
  config_foreach ConfigRemote remote
 
  config_load users
  config_foreach ConfigUser user
 
  /usr/sbin/ipsec start
  sleep 2
  for conn in $Connections; do
    ipsec up "$conn"
  done
}
 
stop() {
  /usr/sbin/ipsec stop
}
```

Before you start Charon with the web interface you should make a dry run from command line. This will show you if there are any errors in your generated configuration file **/etc/ipsec.conf**. Afterwards you can control startup behaviour with LuCI.

[![](/_media/doc/howto/ipsec_daemon.png)](/_detail/doc/howto/ipsec_daemon.png?id=docs%3Aguide-user%3Aservices%3Avpn%3Astrongswan%3Abasics "doc:howto:ipsec_daemon.png")

## What's next

After the basic setup you should make sure you understand the [expected performance](/docs/guide-user/services/vpn/strongswan/performance "docs:guide-user:services:vpn:strongswan:performance") of low budget routers.
