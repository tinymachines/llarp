# IPsec Performance

This page is optional and only documentation for the speed freak.

## Hardware performance

In the times of broadband internet connections encryption and decryption speed of SOME low-end routers can limit throughput of VPN tunnels. CPU utilization can max out at 100 percent and impacts other services of the device like a web server. FOR REFERENCE: Strongswan will run just FINE on a WNDR3700 (MIPS 680 Mhz, 64 Mb RAM). If your router is underpowered, here are some other options:

- Older firewall devices with hardware accelerated VPN are sold for a few bucks on Ebay. Juniper Netscreen 5GT for example can easily reach a VPN throughput of 20 MBit/sec. Downside is that firmware updates are only possible with a Juniper support contract. So check twice for a bargain.
- Firewall devices are built to support IPsec out of the box. A convenient web interface helps the administrator to build a tunnel in a few seconds. OpenWrt still lacks a standard LuCI config panel. If you only go with 1-5 VPN tunnels this should be no concern to you.

To find the right OpenWrt hardware for your VPN you should have a look at the following benchmark table. It is build on a simple test without any claim of perfection. Nevertheless the numbers are quite close to what you can expect from an AES 128/256 bit encrypted IPsec Tunnel connection with standard kernel modules. You may notice that those numbers differ from what is written on the [OpenSSL wiki page](/docs/guide-user/perf_and_log/benchmark.openssl "docs:guide-user:perf_and_log:benchmark.openssl"). But simply remember: **The tests over there do not include network traffic**. If you want to add a new device onto the list check the encrpytion throughput using the following prerequisites

- Logon to a fast Linux machine
- Use a direct LAN connection to the router
- Ensure the router is idle
- Transfer 100 MB of data using ssh
- Calculate the speed from the elapsed time. Throughput = 800 / SecondsElapsed

```
ssh -2 -c aes128-cbc root@<router> time dd if=/dev/zero bs=500000 count=200 > /dev/null
ssh -2 -c aes256-cbc root@<router> time dd if=/dev/zero bs=500000 count=200 > /dev/null
```

You can have a look at the realtime traffic graph in a dry run afterwards to verify the speed. But do not open it during your test because it invalidates the results.

CPU MHz tested device AES128 (s)AES128 (MBit/s)AES256 (s)AES256 (MBit/s) PPC 800 [TP-Link TL-WDR4900](/toh/tp-link/tl-wdr4900 "toh:tp-link:tl-wdr4900") 14.2 56.3 16.2 49.4 MIPS 24k 680 [D-Link DIR-825](/toh/d-link/dir-825 "toh:d-link:dir-825") [Netgear WNDR3700](/toh/netgear/wndr3700 "toh:netgear:wndr3700") 28.2 28.5 32.4 24.6 MIPS 24k 400 [TP-Link TL-WR703N](/toh/tp-link/tl-wr703n "toh:tp-link:tl-wr703n") 47.7 16.5 56.1 14.2 MIPS R3000 125 [Asus WL-500g](/toh/asus/wl500g "toh:asus:wl500g") 164.8 4.8 183.5 4.3

## IPsec security &amp; speed

If you use a default OpenWrt installation you will discover that working with the most secure AES256/SHA256 tunnel options will hit VPN performance. If you go for raw throughput going down the less secure AES128, SHA1 &amp; MD5 functions can be a helpful alternative. One may remark that MD5 is [not very secure](http://en.wikipedia.org/wiki/Md5#Security "http://en.wikipedia.org/wiki/Md5#Security") but for IPsec connections it should be enough as we are talking about hash values of encrypted data with a key that is changed [every hour](/docs/guide-user/services/vpn/ipsec/racoon/basic#p2_proposal "docs:guide-user:services:vpn:ipsec:racoon:basic") according to phase 2 proposals. A good tradeoff could be to choose AES256/SHA256 for phase 1 and AES128/MD5 for phase 2.

## Tuning crypto providers

Read on if you have some time and want to enhance your VPN speed. The kernel IPsec architecture relies on different crypto providers. E.g. if you build a tunnel with SHA1 checksums you must have a module that can calculate those values. A look at /proc/crypto will reveal what modules are loaded and which algorithms they provide. The standard Linux Kernel modules are far from being optimized. If you opted for a cheap router there won't be any hardware crpyto device.

## PPC tuning

Users of a TP-Link WDR4900 might enjoy the benefits of some recent module developments.

- Assembler optimized AES: Patch in the [linux crypto development git](https://git.kernel.org/cgit/linux/kernel/git/herbert/cryptodev-2.6.git/log/?qt=grep&q=powerpc%2Faes "https://git.kernel.org/cgit/linux/kernel/git/herbert/cryptodev-2.6.git/log/?qt=grep&q=powerpc%2Faes"). Waiting for inclusion into mainline.
- Assembler optimized MD5: Patch on the [linux crypto mailing list](http://marc.info/?l=linux-crypto-vger&m=142523463626661&w=2 "http://marc.info/?l=linux-crypto-vger&m=142523463626661&w=2"). Waiting for inclusion into development git.
- Assembler optimized SHA1: Patch on the [linux crypto mailing list](http://marc.info/?l=linux-crypto-vger&m=142480660217788&w=2 "http://marc.info/?l=linux-crypto-vger&m=142480660217788&w=2"). Waiting for inclusion into development git.
- Assembler optimized SHA256: Patch in the [linux crypto development git](https://git.kernel.org/cgit/linux/kernel/git/herbert/cryptodev-2.6.git/log/?qt=grep&q=ppc%2Fsha256 "https://git.kernel.org/cgit/linux/kernel/git/herbert/cryptodev-2.6.git/log/?qt=grep&q=ppc%2Fsha256"). Waiting for inclusion into mainline.

## MIPS tuning

Those of you that are on MIPS **big endian**![:!:](/lib/images/smileys/exclaim.svg) machines can replace the default aes\_generic.ko, sha\_generic.ko, cbc.ko and md5.ko modules with a single assembler optimized [mcespi.ko](https://sourceforge.net/projects/mcespi/files/ "https://sourceforge.net/projects/mcespi/files/"). The module is quite some years old and a first experience with crypto modules. Nevertheless it will work quite fine but needs manual compiling. The easyiest way to install it includes a few steps.

- create a buildroot environment
- compile an image for your router once
- put the mcespi.c into the the folder build\_dir/target-&lt;arch&gt;/linux-&lt;cpu-model&gt;/linux-X.Y.Z/crypto
- Include the line **obj-$(CONFIG\_CRYPTO\_MD5) += mcespi.o** into build\_dir/target-&lt;arch&gt;/linux-&lt;cpu-model&gt;/linux-X.Y.Z/crypto/Makefile
- compile the image once again.
- Afterwards you will find build\_dir/target-&lt;arch&gt;/linux-&lt;cpu-model&gt;/linux-X.Y.Z/crypto/mcespi.ko
- Put mcespi.ko to your router into /lib/modules/&lt;X.Y.Z&gt;
- Load the module with insmod
- For automatic loading create a new /etc/modules.d/09-crypto-mcespi with corresponding content.

## What's next

Basic setup and performance ok? So continue with the [firewall modifications](/docs/guide-user/services/vpn/strongswan/firewall "docs:guide-user:services:vpn:strongswan:firewall").
