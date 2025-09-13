← [Helloworld overview](/docs/guide-developer/helloworld/start "docs:guide-developer:helloworld:start")  

 [Next Chapter](/docs/guide-developer/helloworld/chapter2 "docs:guide-developer:helloworld:chapter2") →

# Preparing your OpenWrt build system for use

This is the first chapter in the “Hello, world!” for OpenWrt article series. Before starting this chapter, you should read through [Build system – Installation](/docs/guide-developer/toolchain/install-buildsystem "docs:guide-developer:toolchain:install-buildsystem"), procure a suitable computing platform (virtualized or otherwise) of your choice, and clone the source code to a new directory. Instructions for performing these steps can be found on the Wiki page linked above.

Although this guide will not provide detailed instructions for this approach, you can also use the [OpenWrt SDK](/docs/guide-developer/toolchain/using_the_sdk "docs:guide-developer:toolchain:using_the_sdk") for your target platform instead of cloning the source code and creating the build system from scratch. If you opt for this route, you can skip the source cloning steps listed in the “Build system - Installation” guide, and instead download &amp; extract the SDK into a new folder on your otherwise-prepared development environment.

## Preparing, configuring and building the necessary tools

These steps are necessary only if you chose to clone the source code. If you chose to use the SDK, you can skip this section.

We first select a stable source code revision (v23.05.3), and ensure our source code directory is clean. The author of this article chose to clone the source code into a folder called 'source' under the home directory of the build user, called 'buildbot'.

`/home/buildbot/` is a representative path, you might choose, for example, `~/devel/`

It is also suggested to use the most-current “stable” git branch. In April, 2024, that is `openwrt-23.05.3`

As of April, 2024, the OpenWrt git repository can be cloned using

```
git clone https://git.openwrt.org/openwrt/openwrt.git source
```

to place it into the `./source/` subdirectory of the current directory. As with the leading path, there is nothing special about the name `source`. Some users may choose to omit the final argument and have it cloned into `./openwrt/` or supply a different directory on the clone command. `source` is shown above to be consistent with the remainder of this guide.

To perform these steps, issue the following commands to change into the source code directory, checkout a stable code revision and clean any possible build artifacts:

```
cd /home/buildbot/source
git checkout v23.05.3
make distclean
```

It is recommended that you update and install your 'feeds' packages to avoid future problems. You can do that using:

```
./scripts/feeds update -a
./scripts/feeds install -a
```

Now, we can configure the cross-compilation toolchain by invoking the graphical configuration menu:

```
make menuconfig
```

From the menu, choose the suitable 'Target System', 'Subtarget' and 'Target Profile'. The author of this article targets the P2812HNU-F1 router model, manufactured by Zyxel, and as such, chooses 'Lantiq', 'XRX200' and 'P2812HNU-F1' as the corresponding values.

After making these choices, select 'Exit' from the configuration menu, and **save your changes** on the way out. You can now build the target-independent tools and the cross-compilation toolchain:

```
make toolchain/install
```

Go grab a cup of coffee while the target-independent tools and the toolchain are built, as it is going to take a while.

## Adjusting the PATH variable

The target-independent tools and the toolchain are deployed to the `staging_dir/host/` and `staging_dir/toolchain/` directories. This applies to the executables built in the above section as well the pre-built executables available in the SDK.

Note that the toolchain directory has a set of identifying variables on the directory name that relate to your target system. These variables specify the computer architecture, sub-architecture, used C compiler, its version, the name of the C standard library, and the version of this library. It is possible to change the used compiler, its version, the C standard library or its version, but these modifications are out of scope of this article series. We accept the defaults specified by the OpenWrt build system based on your selections in the configuration menu.

While some of the target-independent tools found from `staging_dir/host/bin` are simply links to the existing executables elsewhere in your development environment, many are not. In order to use these tools effectively in the later chapters of this article series, it is preferable to be able to refer to them without prefixing the full path. We accomplish this by adding the target-independent tools into our PATH variable:

```
export PATH=/home/buildbot/source/staging_dir/host/bin:$PATH
```

## Conclusion

In this chapter, we prepared, configured and built the target-independent tools and the cross-compilation, and appended the location of the target-independent tools into our PATH variable.

← [Helloworld overview](/docs/guide-developer/helloworld/start "docs:guide-developer:helloworld:start")  

[Helloworld overview](/docs/guide-developer/helloworld/start "docs:guide-developer:helloworld:start")  

 [Next Chapter](/docs/guide-developer/helloworld/chapter2 "docs:guide-developer:helloworld:chapter2") →
