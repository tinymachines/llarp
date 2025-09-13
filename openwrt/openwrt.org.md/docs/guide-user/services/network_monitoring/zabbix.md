# ZABBIX network monitoring

There are 3 'extra' packages for zabbix that add userparameters and detections rules for zabbix-agentd:

- zabbix-extra-network: a detection rule with the ifname (eth0.1) and the network name (wan)
- zabbix-extra-wifi: an universal detection rule for wifi (using libuci-lua) and many userparameters (using libiwinfo-lua)
- zabbix-extra-mac80211: a phy (phy0) detection rule and userparameters for mac80211 devices

Here follow Zabbix templates for Openwrt

“Template Openwrt Mac80211” (for zabbix-extra-mac80211): [http://pastebin.com/3iWQq2kc](http://pastebin.com/3iWQq2kc "http://pastebin.com/3iWQq2kc")

“Template Openwrt Network” (for zabbix-extra-network): [http://pastebin.com/5Jcg7w9j](http://pastebin.com/5Jcg7w9j "http://pastebin.com/5Jcg7w9j")

“Template Openwrt Wifi” (for zabbix-extra-wifi): [http://pastebin.com/uWtWT6C8](http://pastebin.com/uWtWT6C8 "http://pastebin.com/uWtWT6C8")

“All in one”: [http://pastebin.com/nQdZM89w](http://pastebin.com/nQdZM89w "http://pastebin.com/nQdZM89w")

Relevant commit: [https://dev.openwrt.org/changeset/36740](https://dev.openwrt.org/changeset/36740 "https://dev.openwrt.org/changeset/36740")
