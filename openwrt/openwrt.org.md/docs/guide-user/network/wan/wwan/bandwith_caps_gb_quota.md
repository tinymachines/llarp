# Dealing with monthly GB quotas

Most mobile contracts have a monthly data quota, limiting the amount you can download over the connection without incurring additional charges.

OpenWrt has a bandwidth monitoring tool available in the standard repository called `nlbwmon`

## Installation instructions

`opkg update opkg install luci-app-nlbwmon`

You will then have access to an additional tab on the web interface with a detailed breakdown of bandwidth utilization: `Bandwidth Monitor`

## A custom script

The system keeps track of basic information already, if all you need is an overall consumption number, just point your script (or chronjob) to read these files. (change **br-lan** below with the name of your modem's interface if you want to look only at bandwith used for Internet, and not just for data exchange between your own devices in the LAN)

`/sys/devices/virtual/net/br-lan/statistics/rx_bytes /sys/devices/virtual/net/br-lan/statistics/tx_bytes`
