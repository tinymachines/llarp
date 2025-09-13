# Security

This page contains the old content from [security](/docs/guide-developer/security "docs:guide-developer:security"), please move content to the new page and do not edit this one any more.

## Security Advisories &amp; Vulnerability Reporting

Security bugs seem to not be treated differently than other kinds of bugs, so one should probably follow the normal bug reporting procedures documented in the [bugs](/bugs "bugs") wiki page. On the other hand, the mailing list thread [\[OpenWrt-Devel\] Security Vulnerability Reporting and Database](https://lists.openwrt.org/pipermail/openwrt-devel/2015-March/032169.html "https://lists.openwrt.org/pipermail/openwrt-devel/2015-March/032169.html") indicated that security vulnerabilities be reported by sending an email to the public [openwrt-devel](https://lists.openwrt.org/cgi-bin/mailman/listinfo/openwrt-devel "https://lists.openwrt.org/cgi-bin/mailman/listinfo/openwrt-devel") mailing list. Whichever way it is done, it is better to report a vulnerability than not report it.

Vulnerabilities in third-party components of OpenWrt, like the Linux kernel, OpenSSL, etc. should be reported directly to the third-party project first unless the vulnerability is somehow OpenWrt-specific (e.g. the vulnerability is in a OpenWrt patch to the third-party component).

- ![FIXME](/lib/images/smileys/fixme.svg): Much of this information is useful for users as well as developers, so the non-developer-specific information should be moved to a more general page, with a link to that page here.

## Threat Model

- ![FIXME](/lib/images/smileys/fixme.svg): Adapt [OpenWireless's threat model documentation](https://github.com/EFForg/OpenWireless/blob/master/security.txt "https://github.com/EFForg/OpenWireless/blob/master/security.txt") to OpenWrt.

## Security Updates

Most people set up their device once and then don't touch it, as long as it appears to be working. In particular, very few people make a habit of checking for updates.

- ![FIXME](/lib/images/smileys/fixme.svg): How can updates be made automatic and enabled by default?
- ![FIXME](/lib/images/smileys/fixme.svg): How can automatic updates be done in a non-disruptive way, as Google claims for OnHub?
- ![FIXME](/lib/images/smileys/fixme.svg): OpenWrt supports many routers that come with stock firmware that supports automatic updates. Are any of them based on OpenWrt? Could OpenWrt base an automatic update mechanism on one?
- ![FIXME](/lib/images/smileys/fixme.svg): How can we ensure that updates are failsafe and can be easily rolled back or aborted?
- ![FIXME](/lib/images/smileys/fixme.svg): Does the squashfs+JFFS2 overlay system and the opkg package manager make sense with respect to automatic updates? In particular, if updates are done by writing to the JFFS2 filesystem then the system could easily run out of space over time as the JFFS2 diffs from the squashfs filesystem accumulate. Also, usually OpenWrt firmware is quite small, so it may not be worth trying to do partial system updates when full updates are probably good enough. But then, can we afford to store both the old and new versions of the firmware at the same time? Regardless of all of that, it still may be useful to separate updates of the bootloader and kernel from other updates, because the latter are likely to be more disruptive than the former.
- ![FIXME](/lib/images/smileys/fixme.svg): Automatic updates rely on cryptographic signatures of the updates to ensure that the updates are from a trusted source; i.e. are not malicious. But, in a decentralized project like OpenWrt, there's no one person that can be trusted with the signing keys. And, also, there are so many different configurations of OpenWrt for various kinds of hardware and user preferences that it would be impossible for one person or organization to properly QA all the updates. Perhaps some kind of voting system for trustworthiness of updates; such a system would almost definitely depend on reproducible builds.

Background:

- [generic.sysupgrade](/docs/guide-user/installation/generic.sysupgrade "docs:guide-user:installation:generic.sysupgrade") discusses how updates work.
- Turris OS is based on top of OpenWrt and has automatic updates. See [https://www.turris.cz/en/software](https://www.turris.cz/en/software "https://www.turris.cz/en/software") for the claim and see [https://gitlab.labs.nic.cz/turris/updater](https://gitlab.labs.nic.cz/turris/updater "https://gitlab.labs.nic.cz/turris/updater") for the code.
- Google's “OnHub automatically updates with new features and the latest security upgrades, without interrupting your connection.” (OnHub is [based on Chromium OS](https://blog.exploitee.rs/2015/gaining-root-on-the-google-onhub/ "https://blog.exploitee.rs/2015/gaining-root-on-the-google-onhub/"), which in turn is [based on Gentoo Linux's Portage System](https://www.zdnet.com/article/the-secret-origins-of-googles-chrome-os/ "https://www.zdnet.com/article/the-secret-origins-of-googles-chrome-os/")). See [https://www.chromium.org/chromium-os/chromiumos-design-docs/filesystem-autoupdate](https://www.chromium.org/chromium-os/chromiumos-design-docs/filesystem-autoupdate "https://www.chromium.org/chromium-os/chromiumos-design-docs/filesystem-autoupdate") and [https://www.chromium.org/chromium-os/chromiumos-design-docs/filesystem-autoupdate-supplements](https://www.chromium.org/chromium-os/chromiumos-design-docs/filesystem-autoupdate-supplements "https://www.chromium.org/chromium-os/chromiumos-design-docs/filesystem-autoupdate-supplements").
- FirefoxOS was based on Android and reuses Android's update mechanisms for the Linux stuff. However, it also had some features for less disruptive automatic updates of userspace parts that may be worth looking at.
- Android itself has a well-studied update mechanism, though it isn't automatic.
- Freifunk's remote-update tool is in the [LuCI repo](https://github.com/openwrt/luci/blob/for-15.05/contrib/package/remote-update/files/usr/sbin/remote-update "https://github.com/openwrt/luci/blob/for-15.05/contrib/package/remote-update/files/usr/sbin/remote-update").

## Reproducible Builds

![FIXME](/lib/images/smileys/fixme.svg): Write this section.

Background info:

- Motivation (not specific to OpenWrt): [https://reproducible-builds.org/](https://reproducible-builds.org/ "https://reproducible-builds.org/") and [https://wiki.debian.org/ReproducibleBuilds/About](https://wiki.debian.org/ReproducibleBuilds/About "https://wiki.debian.org/ReproducibleBuilds/About")
- [https://lists.openwrt.org/pipermail/openwrt-devel/2015-March/032140.html](https://lists.openwrt.org/pipermail/openwrt-devel/2015-March/032140.html "https://lists.openwrt.org/pipermail/openwrt-devel/2015-March/032140.html")
- HOWTO (not OpenWrt-specific): [https://reproducible-builds.org/docs/](https://reproducible-builds.org/docs/ "https://reproducible-builds.org/docs/")
- OpenWrt specifics: [https://reproducible.debian.net/openwrt/openwrt.html](https://reproducible.debian.net/openwrt/openwrt.html "https://reproducible.debian.net/openwrt/openwrt.html")

## Binary-Blob-free Builds

Many people are interested in OpenWrt because they believe that it being open source improves security because the code has been (in theory) been carefully reviewed. Further, one of the goals of having reproducible builds is to ensure that the binaries downloaded and installed onto a device derived from the carefully-reviewed OpenWrt source code. Obviously, the OpenWrt doesn't have access to the source code for binary blobs and so it can't review them, and so binary blobs are counterproductive to security. Yet some hardware doesn't work as well, or at all, without the binary blobs, and some users don't care about this issue.

- ![FIXME](/lib/images/smileys/fixme.svg): What can be done to help developers configure a 100%-binary-blob-free build?
- ![FIXME](/lib/images/smileys/fixme.svg): What can be done to document which binary blobs, if any, are used by a particular build?
- ![FIXME](/lib/images/smileys/fixme.svg): What can be done to facilitate better sharing between LibreCMC and OpenWrt? The OpenWrt trunk has more hardening options, has better defaults for security-related build options, and has support for more devices, but it isn't clear if/when/what closed-source components are included in the build. LibreCMC has already done a lot of great work to get good results without closed-source components, but it has limited device support; in particular, there seem to be devices that aren't “supported” by LibreCMC but which do--or can be easily made to--work without binary blobs.

Background:

- [https://lists.openwrt.org/pipermail/openwrt-devel/2010-July/007556.html](https://lists.openwrt.org/pipermail/openwrt-devel/2010-July/007556.html "https://lists.openwrt.org/pipermail/openwrt-devel/2010-July/007556.html") - Reading the whole thread is recommended, as options for creating “blob free” builds in OpenWrt without a fork are discussed.
- [https://librecmc.org/](https://librecmc.org/ "https://librecmc.org/") - A binary-blob-free OpenWrt fork. LibreWRT and CeroWrt merged into LibreCMC.

## General Concerns to Address

- ![FIXME](/lib/images/smileys/fixme.svg): See [https://lwn.net/Articles/649870/](https://lwn.net/Articles/649870/ "https://lwn.net/Articles/649870/"). OpenWrt has many private patches to the kernel and other packages that are applied using the quilt tool. These patches have likely not been as well-reviewed as patches that have been accepted in upstream patches. How can we get all of OpenWrt's packages reviewed &amp; accepted upstream? How can one get a list of all of OpenWrt's patches?
- ![FIXME](/lib/images/smileys/fixme.svg): Besides private patches, OpenWrt does many things differently than other Linux distros. Many of these things are done to make OpenWrt fit on the very small devices that it typically runs on. What, exactly, are these differences? How can we audit
- ![FIXME](/lib/images/smileys/fixme.svg): “Everything runs as root.” See [https://forum.openwrt.org/viewtopic.php?pid=287257#p287257](https://forum.openwrt.org/viewtopic.php?pid=287257#p287257 "https://forum.openwrt.org/viewtopic.php?pid=287257#p287257") and [https://lists.openwrt.org/pipermail/openwrt-devel/2015-March/032197.html](https://lists.openwrt.org/pipermail/openwrt-devel/2015-March/032197.html "https://lists.openwrt.org/pipermail/openwrt-devel/2015-March/032197.html"). Right now it is difficult to tell what even needs to be done.
- ![FIXME](/lib/images/smileys/fixme.svg): ["OpenWrt is using a 2 year old release of uClibc \[...\]"](http://blog.oldcomputerjunk.net/tag/openwrt/ "http://blog.oldcomputerjunk.net/tag/openwrt/"). Now OpenWrt is using musl libc instead of uClibc to address this. but it is using uClibc++; does uClibc++ have the same maintenance issues as uClibc?
- ![FIXME](/lib/images/smileys/fixme.svg): ["\[...\] and 1 year old release of binutils, etc."](http://blog.oldcomputerjunk.net/tag/openwrt/ "http://blog.oldcomputerjunk.net/tag/openwrt/"). How is OpenWrt doing in keeping up-to-date with packages and toolchains?
- [https://github.com/EFForg/OpenWireless/issues](https://github.com/EFForg/OpenWireless/issues "https://github.com/EFForg/OpenWireless/issues") has some good ideas that haven't been implemented yet.

## OS and Package Hardening

See the configuration files under [config/](https://github.com/openwrt/openwrt/tree/master/config "https://github.com/openwrt/openwrt/tree/master/config") in the source tree for more detailed information about each option, such as the label used in “make menuconfig”, the current default value, and prerequisites and conditions for enabling the feature. In particular, “Yes” in the “Enabled by Default” column is often an oversimplification. Options are listed in the order they are listed in their config/Config-\*.in file.

### Using ''checksec'' to Check Your Build

`checksec` can be used to verify that some executables and/or libraries have been correctly built with many of these options. To use it:

1. `git clone https://github.com/slimm609/checksec.sh`, somewhere outside your OpenWrt tree.
2. Build OpenWrt with `CONFIG_TARGET_ROOTFS_TARGZ=y` so that it generates a tar.gz archive.
3. Extract the .tar.gz archive to a temporary directory.
4. Run the `checksec` script from inside your copy of the repo you cloned in the first step.

Note that a lot of documentation for this tool--including the README.md in its GitHub repo--suggests running it as `checksec.sh` but the script was renamed to `checksec`. See [Evaluating the security of OpenWrt (part 2)](http://blog.oldcomputerjunk.net/2014/evaluating-the-security-of-openwrt-part-2/ "http://blog.oldcomputerjunk.net/2014/evaluating-the-security-of-openwrt-part-2/") for help on analyzing the output; OpenWrt has improved since that blog post was written so your results should be better.

### "Hardening build options" in config/Config-build.in

Source: [config/Config-build.in](https://github.com/openwrt/openwrt/blob/master/config/Config-build.in "https://github.com/openwrt/openwrt/blob/master/config/Config-build.in"). Note that individual packages and/or targets may ignore or otherwise not respect the setting.

.config line Enabled by Default? Notes `CONFIG_PKG_CHECK_FORMAT_SECURITY=y` Yes `-Wformat -Werror=format-security` `CONFIG_PKG_CC_STACKPROTECTOR_STRONG=y` “Regular” is the default. “Strong” requires GCC 5. `CONFIG_KERNEL_CC_STACKPROTECTOR_STRONG=y` “Regular” is the default. “Strong” requires GCC 5. `CONFIG_PKG_FORTIFY_SOURCE_2=y` `CONFIG_PKG_FORTIFY_SOURCE_1=y` is the default. `CONFIG_PKG_RELRO_FULL=y` Yes

### More Security-related Kernel Build Options in config/Config-kernel.in

Source: [config/Config-kernel.in](https://github.com/openwrt/openwrt/blob/master/config/Config-kernel.in "https://github.com/openwrt/openwrt/blob/master/config/Config-kernel.in")

.config line Enabled by Default? Notes `CONFIG_KERNEL_SECCOMP_FILTER=y`  
`CONFIG_KERNEL_SECCOMP=y` No ![FIXME](/lib/images/smileys/fixme.svg): Which services are done? Which services need to be done? How does the JSON-based configuration for procd work? How can the Seccomp BPF configurations be shared upstream? `CONFIG_KERNEL_NAMESPACES=y`  
`CONFIG_KERNEL_UTS_NS=y`  
`CONFIG_KERNEL_IPC_NS=y`  
`CONFIG_KERNEL_USER_NS=y`  
`CONFIG_KERNEL_PID_NS=y`  
`CONFIG_KERNEL_NET_NS=y` No OpenWrt's procd jail feature uses namespaces. See [LWN's series of articles on namespaces](https://lwn.net/Articles/531114/ "https://lwn.net/Articles/531114/") for more information.

### TODOs

- Non-executable stack (NX)? MIPS support?
- ![FIXME](/lib/images/smileys/fixme.svg): Jails. What configuration options are needed to gets jails to be enabled? Which services are done? Which services need to be done?
  
  - procd reference for jail configuration options: [http://wiki.prplfoundation.org/wiki/Procd\_reference#procd\_add\_jail.28name.2C.5Bjail\_options.5D.29](http://wiki.prplfoundation.org/wiki/Procd_reference#procd_add_jail.28name.2C.5Bjail_options.5D.29 "http://wiki.prplfoundation.org/wiki/Procd_reference#procd_add_jail.28name.2C.5Bjail_options.5D.29").
  - Bug report stating (unverified) that jails are not working with musl on DD (x86 only?): [https://lists.openwrt.org/pipermail/openwrt-devel/2015-November/037156.html](https://lists.openwrt.org/pipermail/openwrt-devel/2015-November/037156.html "https://lists.openwrt.org/pipermail/openwrt-devel/2015-November/037156.html") and [https://dev.openwrt.org/ticket/20785](https://dev.openwrt.org/ticket/20785 "https://dev.openwrt.org/ticket/20785").
  - Recent jail work: [https://lists.openwrt.org/pipermail/openwrt-devel/2015-November/037154.html](https://lists.openwrt.org/pipermail/openwrt-devel/2015-November/037154.html "https://lists.openwrt.org/pipermail/openwrt-devel/2015-November/037154.html") and [https://lists.openwrt.org/pipermail/openwrt-devel/2015-November/037511.html](https://lists.openwrt.org/pipermail/openwrt-devel/2015-November/037511.html "https://lists.openwrt.org/pipermail/openwrt-devel/2015-November/037511.html") (note that there are many patches in that thread) and [https://lists.openwrt.org/pipermail/openwrt-devel/2015-December/037597.html](https://lists.openwrt.org/pipermail/openwrt-devel/2015-December/037597.html "https://lists.openwrt.org/pipermail/openwrt-devel/2015-December/037597.html") (many patches) and [https://www.mail-archive.com/openwrt-devel@lists.openwrt.org/msg35978.html](https://www.mail-archive.com/openwrt-devel@lists.openwrt.org/msg35978.html "https://www.mail-archive.com/openwrt-devel@lists.openwrt.org/msg35978.html") (about improving documentation).
- ![FIXME](/lib/images/smileys/fixme.svg): ASLR. “Assigned” to Steven Barth, according to him. “Probably going to take some hacking into GCC...”, but hacking GCC doesn't seem realistic. Source: [https://youtu.be/arDdCMYNXQA?t=471](https://youtu.be/arDdCMYNXQA?t=471 "https://youtu.be/arDdCMYNXQA?t=471").
- ![FIXME](/lib/images/smileys/fixme.svg): What do packages need to do to be compatible with OpenWrt's hardening configuration? Create a security checklist for contributing a package or reviewing a contributed package.
- According to various discussions, passing hardening options in CPPFLAGS is the “right” thing to do, but more packages actually work correctly if the flags are passed in CFLAGS. It would be nice if the packages could be fixed upstream could be fixed to accept hardening flags in CPPFLAGS so that OpenWrt can switch to using CPPFLAGS for this purpose.
- [https://lists.openwrt.org/pipermail/openwrt-devel/2015-March/032197.html](https://lists.openwrt.org/pipermail/openwrt-devel/2015-March/032197.html "https://lists.openwrt.org/pipermail/openwrt-devel/2015-March/032197.html") - Discusses procd jails and procd seccomp-bpf support, but also has a large wishlist at the end with a lot of good ideas.
- ![FIXME](/lib/images/smileys/fixme.svg): What other projects' guidelines can/should be adopted by OpenWrt? Examples: [https://wiki.archlinux.org/index.php/Security](https://wiki.archlinux.org/index.php/Security "https://wiki.archlinux.org/index.php/Security") and [https://wiki.gentoo.org/wiki/Hardened/Toolchain](https://wiki.gentoo.org/wiki/Hardened/Toolchain "https://wiki.gentoo.org/wiki/Hardened/Toolchain").

## Web Interface (LuCI, etc.) Hardening

- ![FIXME](/lib/images/smileys/fixme.svg): How are XSS, CSRF, and other “solved” web security vulnerability classes systematically prevented? (The OpenWireless documentation mentions some measures that they have taken, such as insisting on the use of only “safe” HTML templating patterns.)

## Cryptography

- ![FIXME](/lib/images/smileys/fixme.svg): How well does the secure random number generator work in practice? Most OpenWrt devices lack a hardware RNG and seem to have few sources of entropy.

<!--THE END-->

- The Jitter RNG is available in Kernel 4.2 and later. DD will be based on Kernel 4.4 according to [this message from John Crispin](https://lists.openwrt.org/pipermail/openwrt-devel/2016-January/038726.html "https://lists.openwrt.org/pipermail/openwrt-devel/2016-January/038726.html").

<!--THE END-->

- How well does the Jitter RNG work? What else can be done to improve secure random generation? Background: [Crypto Update for 4.2](https://lkml.org/lkml/2015/6/22/112 "https://lkml.org/lkml/2015/6/22/112") and the [LWN article on the Jitter RNG](https://lwn.net/Articles/642166/ "https://lwn.net/Articles/642166/").

<!--THE END-->

- ![FIXME](/lib/images/smileys/fixme.svg): Adding and preferring new algorithms &amp; protocol versions. Should OpenWrt make a concerted effort to make a certain set of algorithms (e.g. x25519 + Ed25519 + ChaCha20 + Poly1305, NIST P-{256,384} ECDH &amp; ECDSA + AES-{128,256}GCM) enabled and preferred by default?

<!--THE END-->

- ![FIXME](/lib/images/smileys/fixme.svg): Some algorithms and protocols are obsolete and/or dangerous. Are there any that should be outright disabled in the default configuration? How should security vs. compatibility in the default configuration be balanced?

<!--THE END-->

- ![FIXME](/lib/images/smileys/fixme.svg): Document the new Ed25519 package signing mechanism. What, exactly, is signed? Who signs packages? How are the keys managed? How are keys revoked?

<!--THE END-->

- ![FIXME](/lib/images/smileys/fixme.svg): The build process uses MD5 digests to ensure packages haven't been tampered with. This protects against most kinds of tampering, but it wouldn't protect against someone intentionally developing a public “good” and a private “bad” version of a package, where the “bad” version would have the same MD5 as the “good” version. It would be good to migrate to something stronger like SHA-256 (sha256sum).

## Potential Future Improvements

- ![FIXME](/lib/images/smileys/fixme.svg): What security technologies, with what priority, are worth adding to OpenWrt? Full ASLR? SELinux (perhaps based on Android's policy)? LXC containers?

## LXC Containers

See the [LXC in OpenWrt/Turris](https://smallhacks.wordpress.com/2015/07/15/lxc-on-openwrtturris-presentation/ "https://smallhacks.wordpress.com/2015/07/15/lxc-on-openwrtturris-presentation/") presentation (Video and slides) by Alex Samorukov on LXC containers. Important unanswered questions:

- ![FIXME](/lib/images/smileys/fixme.svg): How are LXC containers complementary to other security mechanisms?
- ![FIXME](/lib/images/smileys/fixme.svg): How are LXC containers a better alternative for other security mechanisms?
