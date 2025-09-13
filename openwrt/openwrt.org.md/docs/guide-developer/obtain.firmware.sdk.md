# Using the SDK

THIS IS THE *OLD* DOCUMENT ![:!:](/lib/images/smileys/exclaim.svg)  
**See [Using the SDK](/docs/guide-developer/toolchain/using_the_sdk "docs:guide-developer:toolchain:using_the_sdk") for the latest version** ![:!:](/lib/images/smileys/exclaim.svg)

The [SDK](https://en.wikipedia.org/wiki/Software_development_kit "https://en.wikipedia.org/wiki/Software_development_kit") is a relocatable, precompiled OpenWrt [toolchain](https://en.wikipedia.org/wiki/Toolchain "https://en.wikipedia.org/wiki/Toolchain") suitable to [cross compile](https://en.wikipedia.org/wiki/Cross_compile "https://en.wikipedia.org/wiki/Cross_compile") single [userspace](https://en.wikipedia.org/wiki/User_space "https://en.wikipedia.org/wiki/User_space") packages for a specific target without compiling the whole system from scratch.

Reasons for using the SDK are:

- Compile custom software for a specific release while ensuring binary and feature compatibility
- Compile newer versions of certain packages
- Recompile existing packages with custom patches or different features

## Obtain SDK

You can either download an already compiled SDK, or compile it yourself by using the “make menuconfig” command.

#### Prerequisites

Please see [Build system – Installation](/docs/guide-developer/toolchain/install-buildsystem "docs:guide-developer:toolchain:install-buildsystem") page how to install the needed software to build the packages on the SDK.

* * *

Note: On some hosts it is needed to install the **ccache** package

### Download

You should find bz2-archives ready for download in the corresponding download directory:

- [Trunk SDK](https://downloads.openwrt.org/snapshots/trunk/ "https://downloads.openwrt.org/snapshots/trunk/") → [Platform](https://dev.openwrt.org/wiki/platforms "https://dev.openwrt.org/wiki/platforms") → OpenWrt-SDK-&lt;Platform&gt;-for-linux-x86\_64-gcc-&lt;version&gt;-linaro-uClibc-&lt;version&gt;.tar.bz2
- [Stable SDK "Chaos Calmer (15.05.1)"](https://downloads.openwrt.org/chaos_calmer/15.05.1/ "https://downloads.openwrt.org/chaos_calmer/15.05.1/") → [Platform](https://dev.openwrt.org/wiki/platforms "https://dev.openwrt.org/wiki/platforms") → OpenWrt-SDK-&lt;Platform&gt;-for-linux-x86\_64-gcc-&lt;version&gt;-linaro-uClibc-&lt;version&gt;.tar.bz2
- [Legacy SDKs (Historic Releases)](https://downloads.openwrt.org/ "https://downloads.openwrt.org/"), → [Platform](https://dev.openwrt.org/wiki/platforms "https://dev.openwrt.org/wiki/platforms") → OpenWrt-SDK-&lt;Platform&gt;-for-linux-x86\_64-gcc-&lt;version&gt;-linaro-uClibc-&lt;version&gt;.tar.bz2

### Package Feeds

After decompressing the SDK archive, edit the `feeds.conf.default` file to download the needed package definitions

## Usage

By default the SDK ships with no package definitions. Makefiles for packages to compile must be checked out from the OpenWrt repository and placed into the `package/` directory first.

### Obtain Definitions

- Use the `./scripts/feeds update -a` command to obtain package definitions.
- After the definitions have been updates, execute `./scripts/feeds install <packagename>` to prepare the package and its dependencies.

### Compile Packages

After the Makefile is in place, the usual buildroot commands apply:

- `make package/example/download` - download the soures of *example*
- `make package/example/prepare` - extract the sources, apply patches and download if necessary
- `make package/example/compile` - compile *example*, prepare and download if necessary
- `make package/example/clean` - clean the sourcecode
- `make package/index` - build a repository index to make the output directory usable as local *opkg* source

Some packages are built on host:

`$ make package/example/host/{clean,compile} V=99`

The common command to recompile a package *example* and enable verbose output is:

`$ make package/example/{clean,compile} V=99`

After the compilation is finished, the generated .ipk files are placed in the bin directory.

The output of make might contain `WARNING: your configuration is out of sync. Please run make menuconfig, oldconfig or defconfig!`. That warning is misleading and wrong in the SDK case. Since everything is precompiled you cannot run oldconfig (see [Why is the SDK configuration out of sync?](https://forum.openwrt.org/viewtopic.php?id=43055 "https://forum.openwrt.org/viewtopic.php?id=43055")).

### Example: existing package

The example below rebuilds *tmux*.

```
$ ./scripts/feeds install tmux
Installing package 'tmux'
Installing package 'toolchain'
Installing package 'ncurses'
Installing package 'libevent2'
Installing package 'openssl'
Installing package 'zlib'
Installing package 'ocf-crypto-headers'
$ make package/tmux/download
Collecting package info: done
tmp/.config-package.in:36:warning: ignoring type redefinition of 'PACKAGE_libc' from 'boolean' to 'tristate'
tmp/.config-package.in:64:warning: ignoring type redefinition of 'PACKAGE_libgcc' from 'boolean' to 'tristate'
#
# configuration written to .config
#
 make[1] package/tmux/download
 make[2] -C feeds/packages/utils/tmux download
$ make package/tmux/prepare
tmp/.config-package.in:36:warning: ignoring type redefinition of 'PACKAGE_libc' from 'boolean' to 'tristate'
tmp/.config-package.in:64:warning: ignoring type redefinition of 'PACKAGE_libgcc' from 'boolean' to 'tristate'
#
# configuration written to .config
#
 make[1] package/tmux/prepare
 make[2] -C feeds/packages/utils/tmux prepare
$ make package/tmux/compile
tmp/.config-package.in:36:warning: ignoring type redefinition of 'PACKAGE_libc' from 'boolean' to 'tristate'
tmp/.config-package.in:64:warning: ignoring type redefinition of 'PACKAGE_libgcc' from 'boolean' to 'tristate'
#
# configuration written to .config
#
 make[1] package/tmux/compile
 make[2] -C feeds/base/package/libs/toolchain compile
 make[2] -C feeds/base/package/libs/ocf-crypto-headers compile
 make[2] -C feeds/base/package/libs/zlib compile
 make[2] -C feeds/base/package/libs/openssl compile
 make[2] -C feeds/base/package/libs/libevent2 compile
 make[2] -C feeds/base/package/libs/ncurses host-compile
 make[2] -C feeds/base/package/libs/ncurses compile
 make[2] -C feeds/base/package/libs/ncurses compile
 make[2] -C feeds/base/package/libs/ncurses compile
 make[2] -C feeds/packages/utils/tmux compile

 make[1] package/index

 make[1] package/index
$ ls bin/ar71xx/packages/packages
tmux_1.9a-1_ar71xx.ipk
```

### Build your own packages

See [Creating packages](/docs/guide-developer/packages "docs:guide-developer:packages")

## Troubleshooting

![:!:](/lib/images/smileys/exclaim.svg) Some SDK versions have bugs.

Bug: BB SDK for BRCM2708: wants to compile with “ccache\_cc” see [https://dev.openwrt.org/ticket/13949](https://dev.openwrt.org/ticket/13949 "https://dev.openwrt.org/ticket/13949")

Bug: BB SDK for BRCM2708: static compilation broken
