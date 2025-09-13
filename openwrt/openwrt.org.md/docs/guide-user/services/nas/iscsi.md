# iSCSI

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

[iSCSI](https://en.wikipedia.org/wiki/ISCSI "https://en.wikipedia.org/wiki/ISCSI") allows to share a block device (i.e. a hard drive) at the block level, basically giving full control of partitions and filesystem to the client connected to it. Due to its design, only a single client can connect to it at a time. It's mostly used to provide network storage for commercial application and appliances that lack advanced storage options (RAID), usually VMWare ESXi (virtualization host) but there are others.

On OpenWrt 19.07 there is support only for **iSCSI targets** (i.e. the OpenWrt device can share its storage with iSCSI), support for **iSCSI initiators** (i.e. connecting to a iSCSI target to access its shared storage) is implemented from 21.02.

## Prerequisites

install package **tgt** and **kmod-scsi-core**

The documentation for the tools used is [here](http://stgt.sourceforge.net/ "http://stgt.sourceforge.net/") although it is not strictly necessary to read it for a basic setup.

## Configuration

Open the uci config file with a text editor to see the comments and edit it. Most options are self-explanatory or explained by the comments inside.

Let's see what is in this file:

```
config options 'tgt'
# iothreads limits number of worker threads per rdwr target, default is 16
# which seems to be too much for an avarage router
	option iothreads '2'
#	option nop_count '3'
#	option nop_interval '1'
#	option logging '0'
#	list portal '[::1]'
#	list portal '127.0.0.1:3261'
#	list portal '0.0.0.0:3262'
#	list portal '[::]:3263'

config target 1
	option name 'iqn.2012-06.org.openwrt:target1'
#	list allow_name 'iqn.1994-05.org.example:fedcba987654'
#	list allow_address '192.168.2.128/27'

#config target 2
#	option name 'iqn.2012-06.org.openwrt:t2'

# all options are set to default, except for the device
# lun "name" is constructed as TGTID_LUN
#config lun                        1_1
#	option 'device' '/dev/sda'
# type of scsi device. available options: disk, cd, pt (sg passthrough)
#	option 'type' 'disk'
# backing store access method: rdwr (read-write), aio (async IO), sg (for pt type only, device must be /dev/sgN)
#	option 'bstype' 'aio'
# set sync and/or direct flags when opening device, affect only rdwr
#	option 'sync' '0'
#	option 'direct' '0'
# block size for lun, default is 512
#	option 'blocksize' 4096
# override SCSI mode page, see tgtadm man page for details
#	option 'mode_page' 'string'
# vendor, product, revision, SCSI ID and SCSI Serial number
#	option 'vendor_id' 'string'
#	option 'product_id' 'string'
#	option 'product_rev' 'string'
#	option 'scsi_id' 'string'
#	option 'scsi_sn' 'string'
# refuse write attempts. applies only to disk type
#	option 'readonly' '0'
# Disk devices default to non-removable, cd - to removable
#	option 'removable' '0'
#  0 = Classic sense format, 1 = Support descriptor format.
#	option 'sense_format' '0'
# Rotaion rate: 0: not reported, 1: non-rotational medium (SSD), 2-1024: reserverd, 1025+: "Nominal rotation rate"
#	option 'rotation_rate' '0'

#config lun 2_1
#	option device /mnt/iscsi.img

#config lun 2_2
#	option device /dev/sdc

#config account
#	list target 1
#	list target 2
#	option user "username1"
#	option password "pass1"

#config account
#	option target 2
#	option user "user2"
#	option password "pwd2"
#	option outgoing 1
```

## Basic Setup

It's better to not delete all comments as they are useful information, but here I don't want to waste space in the wiki so I will provide a short and basic example setup where I am using **/dev/sda** as the iSCSI drive, **iqn.2012-06.org.openwrt:target1** as the name, and a user/password set up to have some limited security (it's better to set the “allow\_name” and “allow\_address” options too to limit access only to your iSCSI client if you want more security)

```
config options 'tgt'
	option iothreads '2'
config target 1
	option name 'iqn.2012-06.org.openwrt:target1'

config lun                        1_1
	option 'device' '/dev/sda'

config account
	list target 1
	option user "username"
	option password "pass"
```

After you changed the config, restart tgt with **service tgt restart**. Your iSCSI target is ready.

How to connect to this iSCSI target will be explained in the documentation of the appliance or application or device you want to connect. It will usually involve this iSCSI device name and it's IP address, and the **default iSCSI port 3260**.

## Performance

Testing this config on a Zyxel NSA310b (single core ARMv5 device with 256MB RAM) with a normal 3,5'' hard drive provides around 20-30MB/s of performance and loads the CPU to the max. More powerful devices will fare better.

As noted in the comments in the config file, if your device is more powerful you can increase the **option iothreads '2'**. You can check CPU utilization by installing and executing **htop** tool.
