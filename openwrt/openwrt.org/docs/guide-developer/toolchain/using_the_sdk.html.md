# Using the SDK

The [SDK](https://en.wikipedia.org/wiki/Software_development_kit "https://en.wikipedia.org/wiki/Software_development_kit") is a [stripped-down buildroot](/docs/guide-developer/toolchain/use-buildsystem "docs:guide-developer:toolchain:use-buildsystem") and a pre-compiled [toolchain](https://en.wikipedia.org/wiki/Toolchain "https://en.wikipedia.org/wiki/Toolchain") designed to [cross compile](https://en.wikipedia.org/wiki/Cross_compile "https://en.wikipedia.org/wiki/Cross_compile") packages for a specific target without compiling the whole system from scratch.

Tasks you can do with the SDK:

- Compile custom software for a specific release while ensuring binary and feature compatibility
- Compile newer versions of certain packages for a specific release
- Recompile existing packages with custom patches or different features

Tasks you cannot do with the SDK:

- Use it as a drop-in for a cross-compiling toolchain to compile the whole firmware.

#### Prerequisites

The SDK has the same prerequisites as the buildroot system, so please see [Build system – Installation](/docs/guide-developer/toolchain/install-buildsystem "docs:guide-developer:toolchain:install-buildsystem") page to install the needed software to build the packages on the SDK.

Note: On some hosts it is needed to install the `ccache` package.

- Do everything as an unprivileged user, not root, without sudo.
- Make sure there are no spaces in the full path to the build directory.

## Obtain the SDK

You can either download a precompiled SDK or compile it yourself from sources. Compilation from source is done by simply enabling the menuconfig option `Build the OpenWrt SDK` (CONFIG\_SDK). The precompiled SDK is found in the same download folder where you find the firmware images for your device.

### Downloads

- [development snapshot SDK](https://downloads.openwrt.org/snapshots/targets/ "https://downloads.openwrt.org/snapshots/targets/") → [Platforms](/docs/platforms/start "docs:platforms:start") → Supplementary Files → openwrt-sdk-&lt;Platform&gt;\_gcc-&lt;version&gt;\_musl.Linux-x86\_64.tar.zst
- [21.02.3](https://downloads.openwrt.org/releases/21.02.3/targets/ "https://downloads.openwrt.org/releases/21.02.3/targets/") → [Platforms](/docs/platforms/start "docs:platforms:start") → Supplementary Files → openwrt-sdk-&lt;Platform&gt;\_gcc-&lt;version&gt;\_musl.Linux-x86\_64.tar.xz
- [19.07.10](https://downloads.openwrt.org/releases/19.07.10/targets/ "https://downloads.openwrt.org/releases/19.07.10/targets/") → [Platforms](/docs/platforms/start "docs:platforms:start") → Supplementary Files → openwrt-sdk-&lt;Platform&gt;\_gcc-&lt;version&gt;\_musl.Linux-x86\_64.tar.xz

### Package feeds

After decompressing the SDK archive, optionally edit the `feeds.conf.default` file to add your package feeds. By default, this will contain the feeds used when the SDK was built. You can add your own feeds, local or remote, just like using the buildroot. If you are simply rebuilding extra packages, you don't need to do this at all.

NOTE: if you want to override packages coming from an existing feed, you must write your custom feed ABOVE the line of the package feed containing the packages you want to override.  
For example, you want to make a custom version of a package that is already shipped in Packages feed, this is how your **feeds.conf.default** will look like (the first line is your own custom package feed)

```
src-link local /path/to/local/custom/feed
src-git packages https://git.openwrt.org/feed/packages.git
src-git luci https://git.openwrt.org/project/luci.git
src-git routing https://git.openwrt.org/feed/routing.git
src-git telephony https://git.openwrt.org/feed/telephony.git
#src-git video https://github.com/openwrt/video.git
#src-git targets https://github.com/openwrt/targets.git
#src-git oldpackages http://git.openwrt.org/packages.git
#src-link custom /usr/src/openwrt/custom-feed
```

### Load package lists

- Use `./scripts/feeds update -a` command to obtain and update package definitions.
- After the definitions have been updated, `./scripts/feeds install <packagename>` to prepare the package and its dependencies.

`./scripts/feeds install -a` will make all packages available, again, just like in the buildroot.

## Usage

### Select packages

Open a terminal in the SDK's folder and then open the SDK's menu by writing `make menuconfig`. The SDK menuconfig system is the same as the buildroot. Instructions are at the top and help is available via the `?` key.

You *probably* want to disable some default settings, which build every available package. Enter `Global Build Settings` and in the submenu, deselect/exclude the following options:

- `Select all target specific packages by default`
- `Select all kernel module packages by default`
- `Select all userspace packages by default`

Still in the menu, find the package you want to build and select it by pressing “m”, this will also select all the dependencies, and you will see that they are all tagged with “&lt;M&gt;” in the menu. You can select multiple packages too.

Save the configuration and exit the menu.

### Compile packages

After the Makefile is in place, the usual buildroot commands apply:

- `make package/example/download` - download the soures of *example*
- `make package/example/prepare` - extract the sources, apply patches and download if necessary
- `make package/example/compile` - compile *example*, prepare and download if necessary
- `make package/example/clean` - clean the sourcecode
- `make package/index` - build a repository index to make the output directory usable as local *opkg* source

Or, just run `make` to build everything selected. You can compile faster by writing `make -j5` or similar as appropriate for your build host.

After the compilation is finished, the generated .ipk files are placed in the bin/packages and bin/targets directories inside the directory you extracted the SDK into.
