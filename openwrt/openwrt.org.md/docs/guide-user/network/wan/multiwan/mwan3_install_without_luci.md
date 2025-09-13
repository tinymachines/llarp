# mwan3 install using filesystem (not luci)

Most guides on the wiki have moved to uci commands (good for scripting but not intuitive) or only cover the install for luci, so here will be a guide for mwan3 that is intended for users that administer openwrt via the filesystem.

This guide will be for a **failover** use case (arguably the most common). It's also possible to use mwan3 in a balanced type configuration, although in this author's experience that did not work as expected (tested in 17, though). Note that in this guide, we will be using only ipv4 (not ipv6).

### mwan3 on wiki

Mwan3 is covered on the wiki in two other documents (en). For example: [dual-wan](/docs/guide-user/routing/examples/dual-wan "docs:guide-user:routing:examples:dual-wan") and the main guide which is here: [mwan3](/docs/guide-user/network/wan/multiwan/mwan3 "docs:guide-user:network:wan:multiwan:mwan3")

This tutorial will simply be a walkthrough for installing mwan3 and some notes on usage. For more details, refer to the latter page above.

## Installation

For 21:

```
opkg install mwan3
```

For 22:

```
opkg install mwan3 iptables-nft
```

Due to the iptables to nft changeover in 22, iptables-nft is required. There is more discussion on this in the main mwan3 page and on the forum. You shouldn't have to make any further changes regarding iptables or nft. Simply install iptables-nft and it should work.

#### Configuration of /etc/config/network

Since we are using this as a failover, we will need a 2nd wan interface. That may look something like this:

[/etc/config/network](/_export/code/docs/guide-user/network/wan/multiwan/mwan3_install_without_luci?codeblock=2 "Download Snippet")

```
config interface 'wan'
    option ifname 'eth1'
    option proto 'static'
    option ipaddr 'myipaddress'
    option netmask '255.255.255.248'
    option gateway 'mygateway'
    option dns '8.8.8.8'
    option metric '10'
 
config interface 'wanb'
    option ifname 'eth2'
    option proto 'static'
    option ipaddr 'myipaddress'
    option netmask '255.255.255.248'
    option gateway 'mygateway'
    option dns '8.8.8.8'
    option metric '20'
```

There's two things you need to pay attention to here. 1) The metric is set for each interface. The metric has a weight, and the lower the weight, the higher the priority. So in the example above, wan has 10 (high priority) and wanb has 20 (low priority). 2) You must name the second wan interface appropriately. It can be anything, but you will need to know what it is to add it to the firewall zone next.

With the two interfaces configured, you should be able to ping out of each one. So now is a good time to test that each interface is working properly.

```
ping -I eth1 www.google.com
ping -I eth2 www.google.com
```

If either of these fail, then double check your interfaces are configured correct, the cables are plugged in, etc... Note that it is common in 21 and 22 for the 2nd interface to delay the first 3 packets w/mwan3 installed. This is a bug, but can be ignored for now. See [https://github.com/openwrt/openwrt/issues/12278](https://github.com/openwrt/openwrt/issues/12278 "https://github.com/openwrt/openwrt/issues/12278") for more details.

#### Configuration of /etc/config/firewall

The next step is to add your newly created wanb to the firewall

```
config zone
    option name    wan
    list network   'wan'
    list network   'wanb'
    list network   'wan6'
    option input   REJECT
    option output  ACCEPT
    option forward REJECT
    option masq    1
    option mtu_fix 1
```

If you fail to do this, you will get everything else in mwan3 working, but when you pull a cable to test the 2nd interface working as a backup, it will not properly change mwan3 over. The failover will not work. Perhaps some config checking would be in order for mwan3 so it detects if the user forgets to include the 2nd wan interface and notifies them appropriately. Note that the syntax utilizing **list network** is a newer syntax. Owrt from 17 and earlier used:

```
option network 'wan wanb wan6'
```

#### Configuration of /etc/config/mwan3

The final step is to choose wan\_wanb (failover) as the policy of /etc/config/mwan3 instead of the balanced, which is the default.

```
config rule 'https'
        option sticky '1'
        option dest_port '443'
        option proto 'tcp'
        option use_policy 'wan_wanb'
 
config rule 'default_rule_v4'
        option dest_ip '0.0.0.0/0'
        option use_policy 'wan_wanb'
        option family 'ipv4'
 
config rule 'default_rule_v6'
        option dest_ip '::/0'
        option use_policy 'wan_wanb'
        option family 'ipv6'
```

The default has wan6 and wanb6 disabled. If you are using ipv6, you may need to enable those in /etc/config/mwan3.

That should be all that is required. At this point you may need to run

```
mwan3 restart
```

Or you can alternatively reboot. Finally, test pulling each network cable, running **logread**, and testing w/ping to make sure the internet fails over appropriately.

## Troubleshooting

There is some discussion on the forum, and on the main mwan3 page. These commands may be valuable:

```
logread | grep mwan3
mwan3 status
```

#### Learning more about mwan3

See the source tree for mwan3: [https://github.com/openwrt/packages/tree/master/net/mwan3](https://github.com/openwrt/packages/tree/master/net/mwan3 "https://github.com/openwrt/packages/tree/master/net/mwan3")

```
mwan3 (without any arguments)
iptables -t mangle -L
less /etc/mwan3.user
```
