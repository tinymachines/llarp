# The OpenWrt source code

See also: [Adding a new device](/docs/guide-developer/adding_new_device "docs:guide-developer:adding_new_device")

The OpenWrt project source code is stored inside a git tree which contains all branches and releases ever made.

All repositories can be browsed online through:

1. [GitWeb](https://git.openwrt.org/ "https://git.openwrt.org/") - the master Git repository for OpenWrt
2. [GitHub](https://github.com/openwrt "https://github.com/openwrt") - a continually-updated mirror of GitWeb

## OpenWrt source code repositories

Any OpenWrt development happens in the main Git repository which is accessible via both HTTP and HTTPS:

```
git clone https://git.openwrt.org/openwrt/openwrt.git
```

You can find a mirror of the repository on GitHub:

```
git clone https://github.com/openwrt/openwrt.git
```

### General source structure

These are the folders you can find in the project’s git:

- **/config** : configuration files for menuconfig
- **/include** : makefile configuration files
- **/package** : packages makefile and configuration
- **/scripts** : miscellaneous scripts used throughout the build process
- **/target** : makefile and configuration for building imagebuilder, kernel, sdk and the toolchain built by buildroot.
- **/toolchain** : makefile and configuration for building the toolchain
- **/tools** : miscellaneous tools used throughout the build process

## Releases

Generating releases has already been vastly automated. The remaining parts of the process need to also be automated before the first LEDE release. We will introduce a TESTERS file that is formatted similarly to the MAINTAINERS file of the kernel. Community members can list themselves as testers for a target/profile/device. Once a release has been generated testers should receive an email informing them of the requirement for images to be tested. It needs to be decided if only tested images should be included in the binary release.

Releases should:

1. Happen at least once a year
2. Have at least one maintenance update
3. Provide CVE/critical/… fixes for at least one year after the release
4. Only include maintained targets
5. Only include targets that have seen on device testing
6. Be ready when they are ready

See the TODO page for more info.

## Staging trees

To create yourself a staging tree on git.openwrt.org (does not apply to regular users):

```
ssh git@git.openwrt.org "create openwrt/staging/yournick"
ssh git@git.openwrt.org "desc openwrt/staging/yournick Staging tree of Your Name"
```

To get your staging tree visible at [https://git.openwrt.org](https://git.openwrt.org "https://git.openwrt.org"):

```
ssh git@git.openwrt.org "perms openwrt/staging/yournick + READERS gitweb"
```

To get your staging tree read accessible to everyone:

```
ssh git@git.openwrt.org "perms openwrt/staging/yournick + READERS @all"
```

### Kernel updates

It has proven impractical and a waste of time to always be on the very latest kernel within 2 days of its release. It has caused the following:

1. diversification of kernel versions
2. pressure on maintainers to constantly upgrade rather than stabilize
3. huge effort invested to upgrade 3-4 times between releases
4. huge workload to maintain kmod-* packaging
5. Upgrade to kernels that might not be fully tested

Obviously, this doesn't excuse old, dusty kernels. A balanced path between the 2 should be taken that gives the community recent kernels without causing unnecessary workload and stability issues.

There should be a max of three concurrent kernel versions. Having only two concurrent versions is better than three.

In short, stability should be valued higher than bleeding edge. Bleeding edge is important, but not as a trade-off to stability.
