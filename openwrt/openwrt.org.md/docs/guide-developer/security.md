# Security

See [Security old](/docs/guide-developer/security/old "docs:guide-developer:security:old") for the old page.

This page lists the processes, tools, and mechanisms the OpenWrt project uses for the security of OpenWrt. This policy covers the OpenWrt distribution with the official package feeds hosted at [https://github.com/openwrt/](https://github.com/openwrt/ "https://github.com/openwrt/") and also the OpenWrt specific tools hosted at [https://git.openwrt.org/](https://git.openwrt.org/ "https://git.openwrt.org/") such as procd, ubus, and libubox.

## Vulnerability reporting

Security bugs should be reported in confidentiality to [contact@openwrt.org](mailto:contact@openwrt.org "contact@openwrt.org"), please see [Reporting security bugs](/bugs#reporting_security_bugs "bugs") and [High-level security incident response handling process](/docs/guide-developer/security_incidents_response "docs:guide-developer:security_incidents_response") for additional details. The [contact@openwrt.org](mailto:contact@openwrt.org "contact@openwrt.org") mail box is not well monitored, probably we will not notice when you send a mail to this mail address. In case you do not get an answer or it is important please use our public mailing list [openwrt-adm@lists.openwrt.org](mailto:openwrt-adm@lists.openwrt.org "openwrt-adm@lists.openwrt.org").

## Security advisories

### [OpenWrt Security Advisories](/advisory/start "OpenWrt Security Advisories")

01. [OpenWrt Security Advisories](/advisory/start "advisory:start")
02. [Security Advisory 2024-12-06-1 - OpenWrt Attended SysUpgrade server: Build artifact poisoning via truncated SHA-256 hash and command injection (CVE-2024-54143)](/advisory/2024-12-06 "advisory:2024-12-06")
03. [Security Advisory 2022-10-17-1 - Multiple issues in mac80211 and cfg80211 (CVE-2022-41674, CVE-2022-42719, CVE-2022-42720, CVE-2022-42721 and CVE-2022-42722)](/advisory/2022-10-17-1 "advisory:2022-10-17-1")
04. [Security Advisory 2022-10-04-1 - wolfSSL buffer overflow during a TLS 1.3 handshake (CVE-2022-39173)](/advisory/2022-10-04-1 "advisory:2022-10-04-1")
05. [Security Advisory 2021-08-01-3 - luci-app-ddns: Multiple authenticated RCEs (CVE-2021-28961)](/advisory/2021-08-01-3 "advisory:2021-08-01-3")
06. [Security Advisory 2021-08-01-2 - Stored XSS in hostname UCI variable (CVE-2021-33425)](/advisory/2021-08-01-2 "advisory:2021-08-01-2")
07. [Security Advisory 2021-08-01-1 - XSS via missing input validation of host names displayed (CVE-2021-32019)](/advisory/2021-08-01-1 "advisory:2021-08-01-1")
08. [Security Advisory 2021-02-02-2 - wolfSSL heap buffer overflow in RsaPad\_PSS (CVE-2020-36177)](/advisory/2021-02-02-2 "advisory:2021-02-02-2")
09. [Security Advisory 2021-02-02-1 - netifd and odhcp6c routing loop on IPv6 point to point links (CVE-2021-22161)](/advisory/2021-02-02-1 "advisory:2021-02-02-1")
10. [Security Advisory 2021-01-19-1 - dnsmasq multiple vulnerabilities (CVE-2020-25681, CVE-2020-25682, CVE-2020-25683, CVE-2020-25684, CVE-2020-25685, CVE-2020-25686, CVE-2020-25687)](/advisory/2021-01-19-1 "advisory:2021-01-19-1")
11. [Security Advisory 2021-01-17-1 - OpenWrt forum break-in on 16-Jan-2021](/advisory/2021-01-17-1 "advisory:2021-01-17-1")
12. [Security Advisory 2020-12-09-2 - libuci import heap use after free (CVE-2020-28951)](/advisory/2020-12-09-2 "advisory:2020-12-09-2")
13. [Security Advisory 2020-12-09-1 - Linux kernel - ICMP rate limiting can be used to facilitate DNS poisoning attack (CVE-2020-25705)](/advisory/2020-12-09-1 "advisory:2020-12-09-1")
14. [Security Advisory 2020-05-06-2 - relayd out-of-bounds reads of heap data and possible buffer overflow (CVE-2020-11752)](/advisory/2020-05-06-2 "advisory:2020-05-06-2")
15. [Security Advisory 2020-05-06-1 - umdns out-of-bounds reads of heap data and possible buffer overflow (CVE-2020-11750)](/advisory/2020-05-06-1 "advisory:2020-05-06-1")
16. [Security Advisory 2020-02-21-1 - ppp buffer overflow vulnerability (CVE-2020-8597)](/advisory/2020-02-21-1 "advisory:2020-02-21-1")
17. [Security Advisory 2020-01-31-2 - libubox tagged binary data JSON serialization vulnerability (CVE-2020-7248)](/advisory/2020-01-31-2 "advisory:2020-01-31-2")
18. [Security Advisory 2020-01-31-1 - Opkg susceptible to MITM (CVE-2020-7982)](/advisory/2020-01-31-1 "advisory:2020-01-31-1")
19. [Security Advisory 2020-01-13-1 - uhttpd invalid data access via HTTP POST request (CVE-2019-19945)](/advisory/2020-01-13-1 "advisory:2020-01-13-1")
20. [Security Advisory 2019-11-05-3 - ustream-ssl information disclosure (CVE-2019-5101, CVE-2019-5102)](/advisory/2019-11-05-3 "advisory:2019-11-05-3")
21. [Security Advisory 2019-11-05-2 - LuCI CSRF vulnerability (CVE-2019-17367)](/advisory/2019-11-05-2 "advisory:2019-11-05-2")
22. [Security Advisory 2019-11-05-1 - LuCI stored XSS](/advisory/2019-11-05-1 "advisory:2019-11-05-1")

This only lists security advisories for components directly maintained by the OpenWrt project. This does not list fixed security problems in third-party components used by OpenWrt which may also affect the security of OpenWrt. We do not list known security problems in the Linux kernel, openssl, and other third-party components even when they affect use cases relevant to OpenWrt. The OpenWrt project monitors the upstream projects and backports security fixes for components used in the OpenWrt core repository to supported OpenWrt versions. For example [159 CVEs](https://www.cvedetails.com/product/47/Linux-Linux-Kernel.html?vendor_id=33 "https://www.cvedetails.com/product/47/Linux-Linux-Kernel.html?vendor_id=33") were assigned for the Linux kernel in 2021 alone, OpenWrt regularly updates the minor Linux kernel version to get these recent fixes.

## Support Status

This table lists the support status of various OpenWrt releases:

Version Current status Initial Release (Projected) EoL Latest Release Release Date 24.10 Supported 2025, February 06 2026, February 24.10.2 2025, June 25 23.05 End of Life 2023, October 13 2025, July 23.05.6 2025, August 20 22.03 End of Life 2022, September 06 2024, July 22.03.7 2024, July 25 21.02 End of Life 2021, September 04 2023, May 21.02.7 2023, May 01 19.07 End of Life 2020, January 06 2022, April 19.07.10 2022, April 20 18.06 End of Life 2018, July 31 2020, December 18.06.9 2020, December 09 17.01 End of Life 2017, February 22 2018, September 17.01.7 2019, June 20 15.05 End of Life 2015, September 11 2016, March 15.05.1 2016, March 16

The listed **Version** numbers reference the code base and the support status applies to the the latest minor release of that branch:

- **Supported**: The OpenWrt project will provide updates for the core packages fixing security and other problems we are aware of.
- **Security Maintenance**: The OpenWrt project will fix only security problems in this release, existing bugs will remain.
- **End of Life**: The OpenWrt project will **NOT** provide any updates, even for severe security vulnerabilities, please update to a more recent version.

A major release will be **Supported** after its initial release.

When the next major release is published, the previous version will move into **Security Maintenance** status.

A major release will move into **End of Life** status one year after the initial release, or 6 months after the next major release, whichever date is later. The project aims to do a final minor release at the end of the support cycle.

#### Notes

![:!:](/lib/images/smileys/exclaim.svg) This timeline only covers core OpenWrt packages and not the external package feeds hosted on GitHub.

![:!:](/lib/images/smileys/exclaim.svg) Some package feed maintainers do not support all OpenWrt versions that are still supported by the OpenWrt project.

![:!:](/lib/images/smileys/exclaim.svg) For the best security support we strongly suggest that every device is upgraded to the most recent stable version.

![:!:](/lib/images/smileys/exclaim.svg) The **Projected EoL** date may be subject to change depending on circumstances, such as the timing of the next release.

## Identifying problems

The OpenWrt project uses multiple tools to identify potential security problems. This information is normally available to everyone and we appreciate fixes for problems reported by these tools from everyone.

### uscan

The [uscan report](https://sdwalker.github.io/uscan/index.html "https://sdwalker.github.io/uscan/index.html") shows the version number of all packages from the base and the package repository and compares it against the recent upstream released versions. In addition the tool which generates this page also checks for existing CVEs assigned to the packages based on the Common Platform Enumeration (CPE) which is listed in the PKG\_CPE\_ID variable of many packages. That page is updated weekly for master and the active release branches.

### Coverity Scan

OpenWrt uses the commercial [Coverity Scan](https://scan.coverity.com/projects/openwrt "https://scan.coverity.com/projects/openwrt") tool which is available for free to open source projects to do static code analyses on the OpenWrt components. This scans one OpenWrt build per week and reports the problems found in the components developed in the OpenWrt project like procd and ubus, but not on (patched) third party components.

## Reproducible builds

The [reproducible builds project](https://reproducible.debian.net/openwrt/openwrt.html "https://reproducible.debian.net/openwrt/openwrt.html") checks that OpenWrt master is still reproducible. This proves that the produced releases really match the delivered source code and no backdoors were introduced in the build process.

## Deliver to users

OpenWrt operates multiple [build bot instances](/infrastructure#buildbot "infrastructure") which are building snapshots of the `master` and the supported release branches.

When a change to a package is committed to the OpenWrt base repository of package feed, the build bots are automatically detecting this change and will rebuild this package. The newly built package can then be installed with opkg or be integrated with the image builder by users of OpenWrt. This allows us to ship updates in about 2 days to the end users.

The kernel is normally located in its own partition and upgrades are not so easily possible. Therefore this mechanism currently does not work for the kernel itself and kernel modules and a new minor release is needed to ship fixes to end users.

## Hardening build options

OpenWrt activates some build hardening options in the [build configuration](https://git.openwrt.org/?p=openwrt%2Fopenwrt.git%3Ba%3Dblob%3Bf%3Dconfig%2FConfig-build.in "https://git.openwrt.org/?p=openwrt/openwrt.git;a=blob;f=config/Config-build.in") at compile time for all package builds. Note that individual packages and/or targets may ignore or otherwise not respect these settings.

.config line Enabled by default Notes `CONFIG_PKG_CHECK_FORMAT_SECURITY=y` Yes `-Wformat -Werror=format-security` `CONFIG_PKG_CC_STACKPROTECTOR_REGULAR=y` Yes `-fstack-protector` `CONFIG_PKG_CC_STACKPROTECTOR_STRONG=y` No `-fstack-protector-strong` `CONFIG_KERNEL_CC_STACKPROTECTOR_REGULAR=y` Yes Kernel config CONFIG\_STACKPROTECTOR `CONFIG_KERNEL_CC_STACKPROTECTOR_STRONG=y` No Kernel config CONFIG\_STACKPROTECTOR\_STRONG `CONFIG_PKG_FORTIFY_SOURCE_1=y` Yes `-D_FORTIFY_SOURCE=1` (Using [fortify-headers](https://git.2f30.org/fortify-headers/ "https://git.2f30.org/fortify-headers/") for musl libc) `CONFIG_PKG_FORTIFY_SOURCE_2=y` No `-D_FORTIFY_SOURCE=2` (Using [fortify-headers](https://git.2f30.org/fortify-headers/ "https://git.2f30.org/fortify-headers/") for musl libc) `CONFIG_PKG_RELRO_FULL=y` Yes `-Wl,-z,now -Wl,-z,relro` `CONFIG_PKG_ASLR_PIE_REGULAR=y` Yes `-fPIC` CFLAGS and `-specs=hardened-build-ld` LDFLAGS  
PIE is activated for some binaries, mostly network exposed applications `CONFIG_PKG_ASLR_PIE_ALL=y` No PIE is activated for all applications `CONFIG_KERNEL_SECCOMP` Yes Kernel config CONFIG\_SECCOMP `CONFIG_SELINUX` No Kernel config SECURITY\_SELINUX
