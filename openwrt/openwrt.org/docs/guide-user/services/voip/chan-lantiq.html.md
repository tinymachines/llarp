# chan-lantiq for Asterisk

**Note: This wiki entry is not finished and not complete yet.**

The Asterisk channel chan-lantiq provides support for FXS ports from routers using lantiq based SoCs. The channel should usable with most routers using DANUBE, VRX200 (VR9) SoC and probably ARX100 (AR9). VRX200 (VR9) devices need a special firmware using a reserved CPU core and reserved RAM (see section 2.)

## 1. Install chan-lantiq

To install chan-lantiq for usage with a SIP carrier like sipgate.de the following packages are recommended to install.

```
opkg install asterisk asterisk-chan-lantiq asterisk-chan-sip asterisk-codec-a-mu asterisk-codec-alaw asterisk-codec-resample asterisk-codec-ulaw asterisk-res-rtp-asterisk
```

Before release of openwrt-18.06 you could build OpenWrt manually and select the listed packages manually. Self building is supported since OpenWrt master commit 49acec5b5f4b2040c307aebb1a258cf8c1ade278 at 2017-03-24.

## 2. Compatible SoCs and routers

To use chan-lantiq with DANUBE SoC based routers only chan-lantiq needs to be installed. A special easy-to-use firmware should installed automatically by ltq-vmmc and ltq-tapi packages. For VRX200 (VR9) based routers a special lantiq firmware must be loaded to a reserved CPU core that is able to access a amount of 2MB reserved RAM. Reserved core and RAM is not needed with DANUBE based devices.

The channel was tested on the following DANUBE SoC based devices:

- ARV752DPW22 (EasyBox 803A)

The channel should run out of the box with the following VRX200 (VR9) SoC based devices:

- VGV7510KW22 (o2 Box 6431)
- VGV7519 (KPN Experia Box v8)

## 3. Add support for new devices

If chan-lantiq is not working with a specific DANUBE based SoC router, check if the routers DTS file have specified GPIOs within a vmmc section. Give a look to ARV752DPW22 DTS file. To support a new VRX200 (VR9) based router give a look to VGV7519 DTSI file ([https://github.com/openwrt/openwrt/commit/0ce929228a63cc23f0deb52a72cc99b21c1c9bf9#diff-6c090f56b029513115c56a335129a3e2](https://github.com/openwrt/openwrt/commit/0ce929228a63cc23f0deb52a72cc99b21c1c9bf9#diff-6c090f56b029513115c56a335129a3e2 "https://github.com/openwrt/openwrt/commit/0ce929228a63cc23f0deb52a72cc99b21c1c9bf9#diff-6c090f56b029513115c56a335129a3e2")).

Most important part is to add the following arguments to the kernel command line (bootargs). This line is valid for VGV7519 with 64 MB RAM.

```
mem=62M vpe1_load_addr=0x83e00000 vpe1_mem=2M maxvpes=1 maxtcs=1 nosmp
```

You may need to change the mem parameter and vpe1\_load\_addr. The reserved memory for firmware (vpe1\_mem) uses 2M, that means remaining memory is 64M-2M=62M. So the parameter mem=62M is valid. The vpe1\_load\_addr should point to begin of 62th MB of RAM. You should adopt parameters maxvpes and maxtcs unchanged. The parameter nosmp is needed to disable SMP. That means if you want using chan-lantiq you can only use one CPU core. The second CPU core is reserved for the special firmware for supporting FXS. The firmware might support DECT devices, too. But actually there is no utility/service that does maintain DECT telephones (e. g. register, key management).

To use FXS ports with e. g. Archer VR200v the kernel command line (bootargs) needs to be edited and a vmmc section must added to DTS file. Then FXS might probably work with chan-lantiq (not tested).

## 4. Example minimal configuration for Asterisk

The minimal configuration allows to take and receive calls via a SIP carrier like sipgate.de

**asterisk/lantiq.conf**

```
[interfaces]
channels = 2
per_channel_context = on
```

**asterisk/sip.conf**

```
nat=yes
directmedia=no
qualify=yes
```

```
register => SIPID:PASSWORD@sipgate.de/SIPID
```

```
[sipgate]
type=peer
host=sipgate.de
fromdomain=sipgate.de
dtmfmode=rfc2833
insecure=port,invite
directmedia=no
transport=udp,tcp
context=in_sipgate
disallow=all
allow=alaw,ulaw
username=SIPID
fromuser=SIPID
secret=PASSWORD
```

```
add to [sipgate] context
context=in_sipgate
```

**asterisk/extensions.conf**

```
[out_sipgate]
exten => _[+0-9].,1,Set(CALLERID(num)=NUMBER)
exten => _[+0-9].,2,Dial(SIP/sipgate/${EXTEN},30,Trg)
exten => _[+0-9].,3,Hangup

[in_sipgate]
exten => SIPID,1,Goto(tel1_in,s,1)

[tel1_out]
exten => _Z,1,Goto(out_internal,${EXTEN},1)
exten => _[+0-9].,1,Gosub(out_sipgate,${EXTEN})

[tel2_out]
exten => _Z,1,Goto(out_internal,${EXTEN},1)
exten => _[+0-9].,1,Gosub(out_sipgate,${EXTEN})

[ltq1_out]
;exten => _[+0-9]!,1,Goto(tel1_out,${EXTEN},1)
exten => _[+0-9]!,1,Dial(local/${EXTEN}@tel1_out/n)

[ltq2_out]
;exten => _[+0-9]!,1,Goto(tel2_out,${EXTEN},1)
exten => _[+0-9]!,1,Dial(local/${EXTEN}@tel2_out/n)

[ltq1_in]
exten => s,1,Dial(TAPI/1,30,t)

[ltq2_in]
exten => s,1,Dial(TAPI/2,30,t)

[tel1_in]
;exten => s,1,Goto(ltq1_in,s,1)
exten => s,1,Dial(local/s@ltq1_in/n)

[tel2_in]
;exten => s,1,Goto(ltq2_in,s,1)
exten => s,1,Dial(local/s@ltq2_in/n)

[lantiq1]
include => ltq1_out

[lantiq2]
include => ltq2_out
```

## 5. See also

[https://forum.openwrt.org/viewtopic.php?id=62696](https://forum.openwrt.org/viewtopic.php?id=62696 "https://forum.openwrt.org/viewtopic.php?id=62696")
