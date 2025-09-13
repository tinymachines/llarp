# multiwan: Connection to spare internet provider

![FIXME](/lib/images/smileys/fixme.svg): It is only skeleton of the article. It is need to full translate from [russian](/ru/doc/howto/multiwan.failower "ru:doc:howto:multiwan.failower").

## Conditions and definitions

- **Main uplink** -- connection to main internet provider.
- **Spare link** -- connection to router of the friendly organisation.
- **Main condition** -- subnets of the local network, Main uplink and Spare link do not overlap each other.

## Configuring a router

### Install OpenWRT

Download OpenWRT for [your device](/toh/start "toh:start"). Follow instructions in [generic.flashing](/docs/guide-user/installation/generic.flashing "docs:guide-user:installation:generic.flashing") and [walkthrough\_login](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login").

### Packages installation

If you are installing a [trunk version](http://downloads.openwrt.org/snapshots/trunk/ "http://downloads.openwrt.org/snapshots/trunk/"), it's recommended to install also the web user interface [LuCI](/docs/guide-user/luci/luci.essentials "docs:guide-user:luci:luci.essentials") for ease of operations. [Current version](http://downloads.openwrt.org/attitude_adjustment/12.09/ "http://downloads.openwrt.org/attitude_adjustment/12.09/") should have the web user interface already installed and enabled by default.

Next to be installed is the **luci-app-miltiwan** package that in turn will pull also the dependencies like the required [multiwan\_package](/docs/guide-user/network/wan/multiwan/multiwan_package "docs:guide-user:network:wan:multiwan:multiwan_package").

### Set up

#### Setup connection to Main uplink

LuCI: fill all required fields on *Network* → *Interfaces* → *WAN* and click `Save & Apply` UCI: edit a file `/etc/config/network`:

```
config interface 'wan'
        option ifname 'eth1'
        option proto 'static'
        option ipaddr '198.51.100.195'
        option netmask '255.255.255.128'
        option gateway '198.51.100.129'
        option dns '192.0.2.160 8.8.8.8 192.0.2.190'
```

And apply changes:

```
/etc/init.d/network reload
```

It is recommends specify some public DNS in addition to DNS of provider “Main aplink”. It is need to avoid failures of resolving when Main uplink will down.

#### Create a VLAN

First, it is need exlude one port from existing “LAN” VLAN. This VLAN has number “1”. Second, need create new VLAN (with number “2” or another less or equal 4096) and include into new VLAN freed port with untagged mode and Port 5 (“CPU port”) in the tagged mode.

In UCI: change file `/etc/config/network`: replace

```
config switch_vlan
        option device 'rtl8366s'
        option vlan '1'
        option ports '0 1 2 3 5t'
```

with

```
config switch_vlan
        option device 'rtl8366s'
        option vlan '1'
        option ports '0 1 2 5t'
config switch_vlan
        option device 'rtl8366s'
        option vlan '2'
        option ports '3 5t'
```

After `/etc/config/network` is changes it is need to run:

```
/etc/init.d/network restart
```

for apply changes.

#### Setup multiwan

##### Interfaces assignation

It is need assign virtual interface to phisical. LuCI: *Network* → *Interfaces*:

- Click *Add New Interface*
- Write name *WWAN*
- Select phisical interface “*VLAN interface: eth0.2*”
- In a line *Protocol of the new interface* select *DHCP Client* (or required by Spare link)
- Click *Submit*

UCI: Add following lines into `/etc/config/network`:

```
config interface 'wwan'
        option ifname 'eth0.2'
        option proto 'dhcp'
```

##### Setup firewall

Set up firewall parameters for new interface:

- LuCI: *Network* → *Interfaces* → *WWAN* → *Firewall settings* select a zone “`wan`”.

##### Set up parameters of multiwan

**In LuCI**: *Network* → *Multi-WAN*

- Remove `WAN2`
- Create `WWAN`
- Set *Failover Traffic Destination* to another interface: `WAN` in `wwan` interface section and `WWAN` in `wan` section
- Best solution for DNS: insert DNS server of provider of link and one of public save DNS server (for example, Google's public DNS servers)
- A parameter *Health Monitor ICMP Host(s)* should be set with different save servers but not servers of provider of links (because link may be up but internet are down)

Next assign policy for multiwan:

- *Default Route*: `wan`

(Main uplink should use for all traffic if it up, and Spare link only in case when Main uplink are down.

Last remove unneeded rules from *Multi-WAN Traffic Rules* and enable multiwan.

Don't forget click *Save &amp; Apply*.

**In UCI** need change `/etc/config/multiwan`:

```
config multiwan 'config'               
        option enabled '1'
        option default_route 'wan'
                                          
config interface 'wan'                    
        option weight '10'                
        option health_interval '10'       
        option timeout '3'                
        option health_fail_retries '3'    
        option health_recovery_retries '5'
        option dns 'auto'           
        option icmp_hosts '8.8.8.8'   
        option failover_to 'wwan'         
                                          
config interface 'wwan'                   
        option weight '10'                
        option health_interval '10'       
        option timeout '3'                
        option health_fail_retries '3'    
        option health_recovery_retries '5'
        option dns 'auto'                 
        option icmp_hosts '8.8.4.4'
        option failover_to 'wan'          
```

Next apply changes:

```
/etc/init.d/multiwan restart
```

##### Set up dnsmask

**LuCI**: *Network* → *DHCP and DNS* → *General settings*. In section *DNS forwardings* enumerate DNS servers of both links and, for better work, one or two public DNS servers.

**UCI:** enumerate DNS servers in lines `list server …` in section `config dnsmasq` of file `/etc/config/dhcp`, for example:

```
config dnsmasq
	list server '8.8.8.8'
	list server '8.8.4.4'
	list server '192.0.2.160'
	list server '192.0.2.190'
…
```

And apply changes:

```
/etc/init.d/dnsmasq reload
```

Just work!
