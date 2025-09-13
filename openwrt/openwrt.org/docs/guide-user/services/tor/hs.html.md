# Tor onion services

You can enable a remote access tunnel to your device over the Tor network and use it for SSH or to serve a web site. This is often used not only for privacy but also just a method of NAT traversal to a device that doesn't have a static IP. You can create your own `.onion` domain for free but it will be accessible only with the Tor Browser or via Tor SOCKS proxy.

## Introduction

- [How do Onion Services work](https://community.torproject.org/onion-services/overview/ "https://community.torproject.org/onion-services/overview/")
- [How to set up an onion service](https://community.torproject.org/onion-services/setup/ "https://community.torproject.org/onion-services/setup/") to share your local services with the Tor world.
- [Tor Support Portal](https://forum.torproject.net/c/support/onion-services/16 "https://forum.torproject.net/c/support/onion-services/16")

## Tor HS configurator

The [tor-hs](/packages/pkgdata/tor-hs "packages:pkgdata:tor-hs") package provides the Tor hidden service configurator that tries to simplify creation of hidden services on OpenWrt routers.

### Installation

To install the package with LUCI: in main menu select `System` / `Software`. Press `Update lists..` and then type into Filter field `tor-hs`.

Or run in terminal:

```
opkg update
opkg install tor-hs
```

There is a LUCI app luci-app-tor that provides a GUI for the `tor-hs`. You may install it with `opkg install luci-app-tor`. It may be not yet available in the main packages feed.

### Hidden service configuration

UCI configuration is located in `/etc/config/tor-hs`. You have to edit and adjust from terminal with `vi /etc/config/tor-hs`. If you want to create a new hidden service, you have to add a hidden-service section. For every hidden service, there should be a new `hidden-service` section.

Example of hidden service section for SSH server:

```
config hidden-service
	option Name 'sshd'
	option Description 'Hidden service for SSH'
	option Enabled 'false'
	option IPv4 '127.0.0.1'
	list PublicLocalPort '2222;22'
```

Name Example value Description `Name` `sshd` Name of hidden service. It is used as directory name in `HSDir` `Description` `Hidden service for ssh` Description used in `rpcd` service `Enabled` `false` Enable hidden service after running `tor-hs` init script `IPv4` `127.0.0.1` Local IPv4 address of service. Service could run on another device, in that case OpenWrt will redirect communication. `PublicLocalPort` `2222;22` List of public ports accessible via Tor network. Local port is normal port of service. `HookScript` `/etc/tor/nextcloud-update.php` Path to script which is executed after starting tor-hs. Script is executed with parameters `--update-onion hostname`. The hostname is replaced with Onion v3 address for given hidden service.

### Required section of configuration

There is one required section common. Example:

```
config tor-hs common
	option GenConf "/etc/tor/torrc_hs"
	option HSDir "/etc/tor/hidden_service"
	option RestartTor "true"
	option UpdateTorConf "true"
```

### Options description

Name Default Description `GenConf` `/etc/tor/torrc_generated` Generated config by tor-hs. `HSDir` `/etc/tor/hidden_service` Directory with meta-data for hidden services (hostname, keys, etc). `RestartTor` `true` It will restart tor after running starting the `tor-hs` service. `UpdateTorConf` `true` Update `/etc/config/tor` with config from `GenConf` option.

### Setup from command line

Allow remote access to the router with onion services. It's recommended to enable [client authorization](/docs/guide-user/services/tor/extras#client_authorization "docs:guide-user:services:tor:extras").

```
# Configure Tor onion service
uci -q delete tor-hs.ssh
uci set tor-hs.ssh="hidden-service"
uci set tor-hs.ssh.Name="ssh"
uci set tor-hs.ssh.Enabled="1"
uci set tor-hs.ssh.IPv4="127.0.0.1"
uci add_list tor-hs.ssh.PublicLocalPort="22;22"
uci commit tor-hs
service tor-hs restart
 
# Fetch onion service hostname
cat /etc/tor/hidden_service/ssh/hostname
```

Access the onion service from Tor client.

```
# Install packages
opkg update
opkg install torsocks
 
# Access onion service
torsocks ssh ${TOR_HOST}
```

### Client authorization

You can secure access to onion services with [client authorization](https://community.torproject.org/onion-services/advanced/client-auth/ "https://community.torproject.org/onion-services/advanced/client-auth/").

```
# Install packages
opkg update
opkg install openssl-util coreutils-base32
 
# Enable client authorization
openssl genpkey -algorithm x25519 -out /etc/tor/hidden_service.pem
TOR_KEY="$(openssl pkey -in /etc/tor/hidden_service.pem -outform der \
| tail -c 32 \
| base32 \
| sed -e "s/=//g")"
TOR_PUB="$(openssl pkey -in /etc/tor/hidden_service.pem -outform der -pubout \
| tail -c 32 \
| base32 \
| sed -e "s/=//g")"
TOR_HOST="$(cat /etc/tor/hidden_service/ssh/hostname)"
cat << EOF > client.auth_private
${TOR_HOST%.onion}:descriptor:x25519:${TOR_KEY}
EOF
cat << EOF > /etc/tor/hidden_service/ssh/authorized_clients/client.auth
descriptor:x25519:${TOR_PUB}
EOF
chown -R tor:tor /etc/tor/hidden_service
service tor restart
```

Configure authorization on the client using the private key.

```
# Configure client authorization
cat << EOF >> /etc/tor/custom
ClientOnionAuthDir /etc/tor/onion_auth
EOF
umask go=
TOR_AUTH="$(cat client.auth_private)"
TOR_HOST="${TOR_AUTH%%:*}.onion"
mkdir -p /etc/tor/onion_auth
cat << EOF > /etc/tor/onion_auth/client.auth_private
${TOR_AUTH}
EOF
chown -R tor:tor /etc/tor/onion_auth
service tor restart
```

### Running service

To enable tor-hs service run:

```
service tor-hs enable
service tor-hs start
```

In case you enabled option `RestartTor` and `UpdateTorConf` hidden service should be running. Otherwise, you should also restart tor daemon.

```
service tor restart
```

After that you should also restart rpcd daemon, so you can use tor-hs RPCD service.

```
service rpcd restart
```

### RPCD

The RPCD service helps users to access basic information about hidden services on the router. After running HS, it contains an onion URL for a given hidden service in hostname value.

```
$ ubus call tor-hs-rpc list-hs
{
    "hs-list": [
        {
            "name": "sshd",
            "description": "Hidden service for SSH",
            "enabled": "1",
            "ipv4": "127.0.0.1",
            "hostname": "<hidden-service-hostname>.onion",
            "ports": [
                "22;22"
            ]
        }
    ]
}
```

## Client authorization

Secure access with [client authorization](https://community.torproject.org/onion-services/advanced/client-auth/ "https://community.torproject.org/onion-services/advanced/client-auth/").

1. Generate public-private key pair using instructions from [Tor client authorization](https://community.torproject.org/onion-services/advanced/client-auth/ "https://community.torproject.org/onion-services/advanced/client-auth/").
2. Place the generated public key in `<HSDir>/<hidden-service.Name>/authorized_clients/<client-name>.auth`.
   
   - For the example above (ssh server), and a client named `someone`, that will be `/etc/tor/hidden_service/sshd/authorized_clients/someone.auth`.
3. Use the private key in your browser when visiting the hidden service.
