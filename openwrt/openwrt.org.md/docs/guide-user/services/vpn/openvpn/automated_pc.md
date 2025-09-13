# OpenVPN PC script automated

Creating private key on an embedded device requires a lot of time. You can speed up things creating certificates on your PC.

Install OpenVPN on your PC (it is required to create build the certificate) and then run this script. It will ask you a password to encrypt the private key of `client.ovpn`. Then you only have to transfer `server.conf` on your router in `/etc/openvpn` path and run `service openvpn restart`.

```
URL="https://openwrt.org/_export/code/docs/guide-user/services/vpn/openvpn/server"
cat << EOF > ovpn.sh
VPN_DIR="openvpn"
VPN_PKI="\${VPN_DIR}/pki"
VPN_PORT="1194"
VPN_PROTO="udp"
VPN_POOL="192.168.8.0 255.255.255.0"
VPN_DNS="\${VPN_POOL%.* *}.1"
VPN_DOMAIN="lan"
FETCHIP_URL="http://v4.ipv6-test.com/api/myip.php"
VPN_SERV="\$(wget -U "" -O - "\${FETCHIP_URL}")"
EASYRSA_URL="https://github.com/OpenVPN/easy-rsa/releases/download/v3.1.7/EasyRSA-3.1.7.tgz"
if [ ! -f "EasyRSA.tgz" ]
then
wget -U "" -O EasyRSA.tgz "\${EASYRSA_URL}"
tar -z -x -f EasyRSA.tgz
fi
alias easyrsa="EasyRSA-3.1.7/easyrsa"
$(wget -U "" -O - "${URL}?codeblock=1")
$(wget -U "" -O - "${URL}?codeblock=3" \
| sed -e "\|^/etc/init\.d/|d")
ls \${VPN_DIR}/*.conf
EOF
sh ovpn.sh
```
