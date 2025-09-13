# WireGuard multi-client server automated

## Introduction

This guide details how to write an automated script that automatically creates a WireGuard Server and peers. There two methods to which peers can be made. The first script creates named peers with IDs and is especially useful for creating trusted users you want to be able to easily distinguish between. The second script just creates peers with unique IDs and can be set to create any number of peers.

Both scripts have been tested with the Ash Unix shell that is built into all vanilla firmware builds compiled by OpenWrt. This conforms with POSIX so will be guaranteed to work on any build of OpenWrt. Throughout the scripts there are many varibles used and have been put in place so that you can define your own variable values to suit your individual needs without having to touch the main script itself.

## 1. Prerequisites

1. Set up a Dynamic DNS client &gt;&gt; [DDNS client](/docs/guide-user/services/ddns/client "docs:guide-user:services:ddns:client")
2. Install Wireguard &gt;&gt; [Installing packages](/docs/guide-user/services/vpn/wireguard/basics#installing_packages "docs:guide-user:services:vpn:wireguard:basics")

## 2. Scripts

### a) Named Peers with IDs

This example creates 4 peers with usernames 'Alpha', 'Bravo', 'Charlie' and 'Delta' on a private LAN called 'lan'. The only changes you should need to make are in the 'Defining Variables' section below.

Copy the script below to the CLI and then call the script with

```
/root/auto_wg_username-id.sh
```

```
cat <<-"SCRIPT_EOF" > "/root/auto_wg_username-id.sh"
#!/bin/ash
clear
echo "======================================"
echo "|     Automated WireGuard Script     |"
echo "|        Named Peers with IDs        |"
echo "======================================"
# Define Variables
echo -n "Defining variables... "
export LAN="lan"
export interface="10.0.5"
export DDNS="my-ddns.no-ip.com"
export peer_ID="1" # The ID number to start from
export peer_IP="2" # The IP address to start from
export WG_${LAN}_server_port="51820"
export WG_${LAN}_server_IP="${interface}.1"
export WG_${LAN}_server_firewall_zone="${LAN}"
export quantity="4" # Change the number '4' to any number of peers you would like to create
export user_1="Alpha"
export user_2="Bravo"
export user_3="Charlie"
export user_4="Delta"
echo "Done"
 
# Create directories
echo -n "Creating directories and pre-defining permissions on those directories... "
mkdir -p /etc/wireguard/networks/${LAN}/peers
echo "Done"
 
# Remove pre-existing WireGuard interface
echo -n "Removing pre-existing WireGuard interface... "
uci del network.wg_${LAN} >/dev/null 2>&1
echo "Done"
 
# Generate WireGuard server keys
echo -n "Generating WireGuard server keys for '${LAN}' network... "
wg genkey | tee "/etc/wireguard/networks/${LAN}/${LAN}_server_private.key" | wg pubkey | tee "/etc/wireguard/networks/${LAN}/${LAN}_server_public.key" >/dev/null 2>&1
echo "Done"
 
echo -n "Rename firewall.@zone[0] to lan and firewall.@zone[1] to wan... "
uci rename firewall.@zone[0]="lan"
uci rename firewall.@zone[1]="wan"
echo "Done"
 
# Create WireGuard interface for 'LAN' network
echo -n "Creating WireGuard interface for '${LAN}' network... "
eval "server_port=\${WG_${LAN}_server_port}"
eval "server_IP=\${WG_${LAN}_server_IP}"
eval "firewall_zone=\${WG_${LAN}_server_firewall_zone}"
uci set network.wg_${LAN}=interface
uci set network.wg_${LAN}.proto='wireguard'
uci set network.wg_${LAN}.private_key="$(cat /etc/wireguard/networks/${LAN}/${LAN}_server_private.key)"
uci set network.wg_${LAN}.listen_port="${server_port}"
uci add_list network.wg_${LAN}.addresses="${server_IP}/24"
uci set firewall.${LAN}.network="${firewall_zone} wg_${firewall_zone}"
uci set network.wg_${LAN}.mtu='1420'
echo "Done"
 
# Add firewall rule
echo -n "Adding firewall rule for '${LAN}' network... "
uci set firewall.wg="rule"
uci set firewall.wg.name="Allow-WireGuard-${LAN}"
uci set firewall.wg.src="wan"
uci set firewall.wg.dest_port="${server_port}"
uci set firewall.wg.proto="udp"
uci set firewall.wg.target="ACCEPT"
echo "Done"
 
# Remove existing peers
echo -n "Removing pre-existing peers... "
while uci -q delete network.@wireguard_wg_${LAN}[0]; do :; done
rm -R /etc/wireguard/networks/${LAN}/peers/* >/dev/null 2>&1
echo "Done"
 
# Loop
n="0"
while [ "$n" -lt ${quantity} ] ; 
do
 
	for username in ${user_1} ${user_2} ${user_3} ${user_4}
	do
 
		# Configure variables
		eval "peer_ID_${username}=${peer_ID}"
		eval "peer_IP_${username}=${peer_IP}"
 
		eval "peer_ID=\${peer_ID_${username}}"
		eval "peer_IP=\${peer_IP_${username}}"
 
		eval "server_port=\${WG_${LAN}_server_port}"
		eval "server_IP=\${WG_${LAN}_server_IP}"
 
		echo ""
		# Create directory for storing peers
		echo -n "Creating directory for peer '${peer_ID}_${LAN}_${username}'... " 
		mkdir -p "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}"
		echo "Done"
 
		# Generate peer keys
		echo -n "Generating peer keys for '${peer_ID}_${LAN}_${username}'... " 
		wg genkey | tee "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}_private.key" | wg pubkey | tee "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}_public.key" >/dev/null 2>&1
		echo "Done"
 
		# Generate Pre-shared key
		echo -n "Generating peer PSK for '${peer_ID}_${LAN}_${username}'... " 
		wg genpsk | tee "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}.psk" >/dev/null 2>&1
		echo "Done"
 
		# Add peer to server 
		echo -n "Adding '${peer_ID}_${LAN}_${username}' to WireGuard server... " 
		uci add network wireguard_wg_${LAN} >/dev/null 2>&1
		uci set network.@wireguard_wg_${LAN}[-1].public_key="$(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}_public.key)"
		uci set network.@wireguard_wg_${LAN}[-1].preshared_key="$(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}.psk)"
		uci set network.@wireguard_wg_${LAN}[-1].description="${peer_ID}_${LAN}_${username}"
		uci add_list network.@wireguard_wg_${LAN}[-1].allowed_ips="${interface}.${peer_IP}/32"
		uci set network.@wireguard_wg_${LAN}[-1].route_allowed_ips='1'
		uci set network.@wireguard_wg_${LAN}[-1].persistent_keepalive='25'
		echo "Done"
 
		# Create peer configuration
		echo -n "Creating config for '${peer_ID}_${LAN}_${username}'... "
		cat <<-EOF > "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}.conf"
		[Interface]
		Address = ${interface}.${peer_IP}/32
		PrivateKey = $(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}_private.key) # Peer's private key
		DNS = ${server_IP}
 
		[Peer]
		PublicKey = $(cat /etc/wireguard/networks/${LAN}/${LAN}_server_public.key) # Server's public key
		PresharedKey = $(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}.psk) # Peer's pre-shared key
		PersistentKeepalive = 25
		AllowedIPs = 0.0.0.0/0, ::/0
		Endpoint = ${DDNS}:${server_port}
		EOF
		echo "Done"
 
		# Increment variables by '1'
		peer_ID=$((peer_ID+1))
		peer_IP=$((peer_IP+1))
		n=$((n+1))
	done
done
 
# Commit UCI changes
echo -en "\nCommiting changes... "
uci commit
echo "Done"
 
# Restart WireGuard interface
echo -en "\nRestarting WireGuard interface... "
ifup wg_${LAN}
echo "Done"
 
# Restart firewall
echo -en "\nRestarting firewall... "
service firewall restart >/dev/null 2>&1
echo "Done"
SCRIPT_EOF
chmod +x "/root/auto_wg_username-id.sh"
```

### b) Set Number of Peers with IDs

This example creates 4 peers on the guest LAN. The only changes you should need to make are in the 'Defining Variables' section below.

Copy the script below to the CLI and then call the script with

```
/root/auto_wg_id.sh
```

```
cat <<-"SCRIPT_EOF" > "/root/auto_wg_id.sh"
#!/bin/ash
clear
echo "======================================"
echo "|     Automated WireGuard Script     |"
echo "|    Set Number of Peers with IDs    |"
echo "======================================"
# Define Variables
echo -n "Defining variables... "
export LAN="guest"
export interface="10.0.6"
export DDNS="my-ddns.no-ip.com"
export peer_ID="1" # The ID number to start from
export peer_IP="2" # The IP address to start from
export WG_${LAN}_server_port="51821"
export WG_${LAN}_server_IP="${interface}.1"
export WG_${LAN}_server_firewall_zone="${LAN}"
export quantity="4" # Change the number '4' to any number of peers you would like to create
echo "Done"
 
# Create directories
echo -n "Creating directories and pre-defining permissions on those directories... "
mkdir -p /etc/wireguard/networks/${LAN}/peers
echo "Done"
 
# Remove pre-existing WireGuard interface
echo -n "Removing pre-existing WireGuard interface... "
uci del network.wg_${LAN} >/dev/null 2>&1
echo "Done"
 
# Generate WireGuard server keys
echo -n "Generating WireGuard server keys for '${LAN}' network... "
wg genkey | tee "/etc/wireguard/networks/${LAN}/${LAN}_server_private.key" | wg pubkey | tee "/etc/wireguard/networks/${LAN}/${LAN}_server_public.key" >/dev/null 2>&1
echo "Done"
 
echo -n "Rename firewall.@zone[0] to lan and firewall.@zone[1] to wan... "
uci rename firewall.@zone[0]="lan"
uci rename firewall.@zone[1]="wan"
echo "Done"
 
# Create WireGuard interface for 'LAN' network
echo -n "Creating WireGuard interface for '${LAN}' network... "
eval "server_port=\${WG_${LAN}_server_port}"
eval "server_IP=\${WG_${LAN}_server_IP}"
eval "firewall_zone=\${WG_${LAN}_server_firewall_zone}"
uci set network.wg_${LAN}=interface
uci set network.wg_${LAN}.proto='wireguard'
uci set network.wg_${LAN}.private_key="$(cat /etc/wireguard/networks/${LAN}/${LAN}_server_private.key)"
uci set network.wg_${LAN}.listen_port="${server_port}"
uci add_list network.wg_${LAN}.addresses="${server_IP}/24"
uci set firewall.${LAN}.network="${firewall_zone} wg_${firewall_zone}"
uci set network.wg_${LAN}.mtu='1420'
echo "Done"
 
# Add firewall rule
echo -n "Adding firewall rule for '${LAN}' network... "
uci set firewall.wg="rule"
uci set firewall.wg.name="Allow-WireGuard-${LAN}"
uci set firewall.wg.src="wan"
uci set firewall.wg.dest_port="${server_port}"
uci set firewall.wg.proto="udp"
uci set firewall.wg.target="ACCEPT"
echo "Done"
 
# Remove existing peers
echo -n "Removing pre-existing peers... "
while uci -q delete network.@wireguard_wg_${LAN}[0]; do :; done
rm -R /etc/wireguard/networks/${LAN}/peers/* >/dev/null 2>&1
echo "Done"
 
# Loop
n="0"
while [ "$n" -lt ${quantity} ] ;
do
 
	# Configure variables
	eval "server_port=\${WG_${LAN}_server_port}"
	eval "server_IP=\${WG_${LAN}_server_IP}"
 
	echo ""
	# Create directory for storing peers
	echo -n "Creating directory for peer '${peer_ID}_${LAN}'... " 
	mkdir -p "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}"
	echo "Done"
 
	# Generate peer keys
	echo -n "Generating peer keys for '${peer_ID}_${LAN}'... " 
	wg genkey | tee "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}/${peer_ID}_${LAN}_private.key" | wg pubkey | tee "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}/${peer_ID}_${LAN}_public.key" >/dev/null 2>&1
	echo "Done"
 
	# Generate Pre-shared key
	echo -n "Generating peer PSK for '${peer_ID}_${LAN}'... " 
	wg genpsk | tee "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}/${peer_ID}_${LAN}.psk" >/dev/null 2>&1
	echo "Done"
 
	# Add peer to server 
	echo -n "Adding '${peer_ID}_${LAN}' to WireGuard server... " 
	uci add network wireguard_wg_${LAN} >/dev/null 2>&1
	uci set network.@wireguard_wg_${LAN}[-1].public_key="$(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}/${peer_ID}_${LAN}_public.key)"
	uci set network.@wireguard_wg_${LAN}[-1].preshared_key="$(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}/${peer_ID}_${LAN}.psk)"
	uci set network.@wireguard_wg_${LAN}[-1].description="${peer_ID}_${LAN}"
	uci add_list network.@wireguard_wg_${LAN}[-1].allowed_ips="${interface}.${peer_IP}/32"
	uci set network.@wireguard_wg_${LAN}[-1].route_allowed_ips='1'
	uci set network.@wireguard_wg_${LAN}[-1].persistent_keepalive='25'
	echo "Done"
 
	# Create peer configuration
	echo -n "Creating config for '${peer_ID}_${LAN}'... "
	cat <<-EOF > "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}/${peer_ID}_${LAN}.conf"
	[Interface]
	Address = ${interface}.${peer_IP}/32
	PrivateKey = $(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}/${peer_ID}_${LAN}_private.key) # Peer's private key
	DNS = ${server_IP}
 
	[Peer]
	PublicKey = $(cat /etc/wireguard/networks/${LAN}/${LAN}_server_public.key) # Server's public key
	PresharedKey = $(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}/${peer_ID}_${LAN}.psk) # Peer's pre-shared key
	PersistentKeepalive = 25
	AllowedIPs = 0.0.0.0/0, ::/0
	Endpoint = ${DDNS}:${server_port}
	EOF
	echo "Done"
 
	# Increment variables by '1'
	peer_ID=$((peer_ID+1))
	peer_IP=$((peer_IP+1))
	n=$((n+1))
done
 
# Commit UCI changes
echo -en "\nCommiting changes... "
uci commit
echo "Done"
 
# Restart WireGuard interface
echo -en "\nRestarting WireGuard interface... "
ifup wg_${LAN}
echo "Done"
 
# Restart firewall
echo -en "\nRestarting firewall... "
service firewall restart >/dev/null 2>&1
echo "Done"
SCRIPT_EOF
chmod +x "/root/auto_wg_id.sh"
```

### c) Add Additional Set Number of Peers with Names and IDs

This script allows you to add a set number of extra peers with names and unique IDs alongside any pre-existing peers already on the system.

Copy the script below to the CLI and then call the script with

```
/etc/wireguard/scripts/add_named-id_peers.sh
```

```
mkdir "/etc/wireguard/scripts"
cat > "/etc/wireguard/scripts/add_named-id_peers.sh" <<-'SCRIPT_EOF'
#!/bin/ash
clear
echo "========================================================="
echo "|               Automated WireGuard Script              |"
echo "| Add Additional Set Number of Peers with Names and IDs |"
echo "========================================================="
# Define Variables
echo -n "Defining variables... " 
export LAN="lan"
export interface="10.0.5"
export DDNS="my-ddns.no-ip.com"
export WG_${LAN}_server_port="51820"
export WG_${LAN}_server_IP="${interface}.1"
export WG_${LAN}_server_firewall_zone="${LAN}"
export quantity="4" # Change the number '4' to any number of peers you would like to create
export user_1="Alpha"
export user_2="Bravo"
export user_3="Charlie"
export user_4="Delta"
function last_peer_ID () {
	cd "/etc/wireguard/networks/${LAN}/peers"
	ls | sort -V | tail -1 | cut -d '_' -f 1
}
export peer_ID=$(last_peer_ID) ; export peer_ID=$((peer_ID+1))
function last_peer_IP () {
	cd "/etc/wireguard/networks/${LAN}/peers"
	peer=$(ls | sort -V | tail -1)
	awk '/Address/' $peer/*.conf | cut -d '.' -f 3 | tr -d /24
	cd
}
export peer_IP=$(last_peer_IP) ; export peer_IP=$((peer_IP+1))
echo "Done"
 
n=0
while [ "$n" -lt ${quantity} ] ; 
do
	for username in ${user_1} ${user_2} ${user_3} ${user_4}
	do
		# Configure Variables
		echo "" 
		echo -n "Defining variables for '${peer_ID}_${LAN}_${username}'... " 
		eval "peer_ID_${username}=${peer_ID}"
		eval "peer_IP_${username}=${peer_IP}"
 
		eval "peer_ID=\${peer_ID_${username}}"
		eval "peer_IP=\${peer_IP_${username}}"
 
		eval "server_port=\${WG_${LAN}_server_port}"
		eval "server_IP=\${WG_${LAN}_server_IP}"
		echo "Done"
 
		# Create directory for storing peers
		echo -n "Creating directory for peer '${peer_ID}_${LAN}_${username}'... " 
		mkdir -p "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}"
		echo "Done"
 
		# Generate peer keys
		echo -n "Generating peer keys for '${peer_ID}_${LAN}_${username}'... " 
		wg genkey | tee "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}_private.key" | wg pubkey | tee "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}_public.key" >/dev/null 2>&1
		echo "Done"
 
		# Generate Pre-shared key
		echo -n "Generating peer PSK for '${peer_ID}_${LAN}_${username}'... " 
		wg genpsk | tee "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}.psk" >/dev/null 2>&1
		echo "Done"
 
		# Add peer to server 
		echo -n "Adding '${peer_ID}_${LAN}_${username}' to WireGuard server... " 
		uci add network wireguard_wg_${LAN} >/dev/null 2>&1
		uci set network.@wireguard_wg_${LAN}[-1].public_key="$(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}_public.key)"
		uci set network.@wireguard_wg_${LAN}[-1].preshared_key="$(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}.psk)"
		uci set network.@wireguard_wg_${LAN}[-1].description="${peer_ID}_${LAN}_${username}"
		uci add_list network.@wireguard_wg_${LAN}[-1].allowed_ips="${interface}.${peer_IP}/32"
		uci set network.@wireguard_wg_${LAN}[-1].route_allowed_ips='1'
		uci set network.@wireguard_wg_${LAN}[-1].persistent_keepalive='25'
		echo "Done"
 
		# Create peer configuration
		echo -n "Creating config for '${peer_ID}_${LAN}_${username}'... " 
		cat <<-EOF > "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}.conf"
		[Interface]
		Address = ${interface}.${peer_IP}/32
		PrivateKey = $(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}_private.key) # Peer's private key
		DNS = ${server_IP}
 
		[Peer]
		PublicKey = $(cat /etc/wireguard/networks/${LAN}/${LAN}_server_public.key) # Server's public key
		PresharedKey = $(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}.psk) # Peer's pre-shared key
		PersistentKeepalive = 25
		AllowedIPs = 0.0.0.0/0, ::/0
		Endpoint = ${DDNS}:${server_port}
		EOF
		echo "Done"
 
		# Increment variables by '1'	
		peer_ID=$((peer_ID+1))
		peer_IP=$((peer_IP+1))
		n=$((n+1))
	done
done
 
# Commit UCI changes
echo -en "\nCommiting changes... "
uci commit
echo "Done"
 
# Restart WireGuard interface
echo -en "\nRestarting WireGuard interface... "
ifup wg_${LAN}
echo "Done"
 
# Restart firewall
echo -en "\nRestarting firewall... "
service firewall restart >/dev/null 2>&1
echo "Done"
SCRIPT_EOF
chmod +x "/etc/wireguard/scripts/add_named-id_peers.sh"
```

### d) Add Additional Set Number of Peers with IDs

This script allows you to add a set number of extra peers with unique IDs alongside any pre-existing peers already on the system.

Copy the script below to the CLI and then call the script with

```
/etc/wireguard/scripts/add_id_peers.sh
```

```
mkdir "/etc/wireguard/scripts"
cat > "/etc/wireguard/scripts/add_id_peers.sh" <<-'SCRIPT_EOF'
#!/bin/ash
clear
echo "==============================================="
echo "|         Automated WireGuard Script          |"
echo "| Add Additional Set Number of Peers with IDs |"
echo "==============================================="
# Define Variables
echo -n "Defining variables... "
export LAN="guest"
export interface="10.0.6"
export DDNS="my-ddns.no-ip.com"
export WG_${LAN}_server_port="51821"
export WG_${LAN}_server_IP="${interface}.1"
export WG_${LAN}_server_firewall_zone="${LAN}"
export quantity="4" # Change the number '4' to any number of peers you would like to create
function last_peer_ID () {
	cd "/etc/wireguard/networks/${LAN}/peers"
	ls | sort -V | tail -1 | cut -d '_' -f 1
}
export peer_ID=$(last_peer_ID) ; export peer_ID=$((peer_ID+1))
function last_peer_IP () {
	cd "/etc/wireguard/networks/${LAN}/peers"
	peer=$(ls | sort -V | tail -1)
	awk '/Address/' $peer/*.conf | cut -d '.' -f 3 | tr -d /24
	cd
}
export peer_IP=$(last_peer_IP) ; export peer_IP=$((peer_IP+1))
echo "Done"
 
# Generate WireGuard server keys
echo -n "Generating WireGuard server keys for '${LAN}' network... "
wg genkey | tee "/etc/wireguard/networks/${LAN}/${LAN}_server_private.key" | wg pubkey | tee "/etc/wireguard/networks/${LAN}/${LAN}_server_public.key" >/dev/null 2>&1
echo "Done"
 
# Loop
n="0"
while [ "$n" -lt ${quantity} ] ;
do
 
	# Configure variables
	eval "server_port=\${WG_${LAN}_server_port}"
	eval "server_IP=\${WG_${LAN}_server_IP}"
 
	echo ""
	# Create directory for storing peers
	echo -n "Creating directory for peer '${peer_ID}_${LAN}'... " 
	mkdir -p "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}"
	echo "Done"
 
	# Generate peer keys
	echo -n "Generating peer keys for '${peer_ID}_${LAN}'... " 
	wg genkey | tee "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}/${peer_ID}_${LAN}_private.key" | wg pubkey | tee "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}/${peer_ID}_${LAN}_public.key" >/dev/null 2>&1
	echo "Done"
 
	# Generate Pre-shared key
	echo -n "Generating peer PSK for '${peer_ID}_${LAN}'... " 
	wg genpsk | tee "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}/${peer_ID}_${LAN}.psk" >/dev/null 2>&1
	echo "Done"
 
	# Add peer to server 
	echo -n "Adding '${peer_ID}_${LAN}' to WireGuard server... " 
	uci add network wireguard_wg_${LAN} >/dev/null 2>&1
	uci set network.@wireguard_wg_${LAN}[-1].public_key="$(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}/${peer_ID}_${LAN}_public.key)"
	uci set network.@wireguard_wg_${LAN}[-1].preshared_key="$(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}/${peer_ID}_${LAN}.psk)"
	uci set network.@wireguard_wg_${LAN}[-1].description="${peer_ID}_${LAN}"
	uci add_list network.@wireguard_wg_${LAN}[-1].allowed_ips="${interface}.${peer_IP}/32"
	uci set network.@wireguard_wg_${LAN}[-1].route_allowed_ips='1'
	uci set network.@wireguard_wg_${LAN}[-1].persistent_keepalive='25'
	echo "Done"
 
	# Create peer configuration
	echo -n "Creating config for '${peer_ID}_${LAN}'... "
	cat <<-EOF > "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}/${peer_ID}_${LAN}.conf"
	[Interface]
	Address = ${interface}.${peer_IP}/32
	PrivateKey = $(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}/${peer_ID}_${LAN}_private.key) # Peer's private key
	DNS = ${server_IP}
 
	[Peer]
	PublicKey = $(cat /etc/wireguard/networks/${LAN}/${LAN}_server_public.key) # Server's public key
	PresharedKey = $(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}/${peer_ID}_${LAN}.psk) # Peer's pre-shared key
	PersistentKeepalive = 25
	AllowedIPs = 0.0.0.0/0, ::/0
	Endpoint = ${DDNS}:${server_port}
	EOF
	echo "Done"
 
	# Increment variables by '1'
	peer_ID=$((peer_ID+1))
	peer_IP=$((peer_IP+1))
	n=$((n+1))
done
 
# Commit UCI changes
echo -en "\nCommiting changes... "
uci commit
echo "Done"
 
# Restart WireGuard interface
echo -en "\nRestarting WireGuard interface... "
ifup wg_${LAN}
echo "Done"
 
# Restart firewall
echo -en "\nRestarting firewall... "
service firewall restart >/dev/null 2>&1
echo "Done"
SCRIPT_EOF
chmod +x "/etc/wireguard/scripts/add_id_peers.sh"
```

## 3. Share Peer Config Files Over SAMBA 4 Network Share

Consider creating a Samba share on the OpenWrt router listening on a trusted network such as the private LAN so that the configuration files can be easily accessed over the network. From here they can be emailed as an attachment, uploaded to a private cloud storage and shared or sent via an IM (instant messaging) app such WhatsApp, Telegram, Discord etc. This makes it very easy to distribute the various config files whether they are for the private LAN, guest LAN or any others you may have setup.

Copy the script below to the CLI and then call the script with

```
/root/create_wg_smb_share.sh
```

```
cat <<-"SCRIPT_EOF" > "/root/create_wg_smb_share.sh"
# Define LAN network
export LAN="lan"
 
# Create SMB network share to access configuration files
echo -en "\nCreating SAMBA share for peer config files... "
uci batch <<EOF
set samba4.wireguard_${LAN}=sambashare
set samba4.wireguard_${LAN}.path="/etc/wireguard/networks/${LAN}/peers"
set samba4.wireguard_${LAN}.name='WG_${LAN}'
set samba4.wireguard_${LAN}.create_mask='0700'
set samba4.wireguard_${LAN}.dir_mask='0744'
set samba4.wireguard_${LAN}.read_only='yes'
set samba4.wireguard_${LAN}.guest_ok='yes'
EOF
echo "Done"
 
# Set permissions on peer directories
echo -en "\nSetting permissions on peer directories... "
chmod -R 755 /etc/wireguard/networks/${LAN}/peers/
echo "Done"
 
# Commit UCI changes
# Commit UCI changes
echo -en "\nCommiting changes... "
uci commit samba4
echo "Done"
 
# Restart SAMBA 4 services
echo -en "\nRestarting SAMBA 4... "
service samba4 restart
echo "Done"
SCRIPT_EOF
chmod +x "/root/create_wg_smb_share.sh"
```

## 4. Testing

Establish the VPN connection on the client device and verify the traffic is routed through the VPN.

```
traceroute openwrt.org
traceroute6 openwrt.org
```

Check your client public IP addresses.

[whatismyipaddress.com](https://whatismyipaddress.com/ "https://whatismyipaddress.com/")

Check there are no DNS leaks

[dnsleaktest.com](https://www.dnsleaktest.com/ "https://www.dnsleaktest.com/")
