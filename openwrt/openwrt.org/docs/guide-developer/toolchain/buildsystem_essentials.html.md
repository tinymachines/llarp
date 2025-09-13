# Build system essentials

## Introduction

The build system is used to build OpenWrt from the source code and requires significant hardware resources, time and knowledge. You can apply custom patches and build individual packages and OpenWrt images with specific compilation flags and options. As an alternative, you can use the [Image Builder](/docs/guide-user/additional-software/imagebuilder "docs:guide-user:additional-software:imagebuilder") to build OpenWrt images much faster and simpler at the cost of limited customization.

## Prerequisites

The build system is based on a [buildroot](https://en.wikipedia.org/wiki/Buildroot "https://en.wikipedia.org/wiki/Buildroot") and requires a GNU/Linux environment with a case-sensitive file system. This can be achieved by running a native or a virtualized [Linux](https://en.wikipedia.org/wiki/Linux "https://en.wikipedia.org/wiki/Linux") distribution using [VirtualBox](https://en.wikipedia.org/wiki/VirtualBox "https://en.wikipedia.org/wiki/VirtualBox"), [VMware](https://en.wikipedia.org/wiki/VMware "https://en.wikipedia.org/wiki/VMware"), [QEMU](https://en.wikipedia.org/wiki/QEMU "https://en.wikipedia.org/wiki/QEMU"), etc. Also some users have positive experience with [WSL](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux "https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux") and [macOS](https://en.wikipedia.org/wiki/MacOS "https://en.wikipedia.org/wiki/MacOS"), but those are not officially supported.

To generate a flashable firmware image file with default packages, you should have at least 10-15 GB of free disk space (better if more) and at least 2 GB of RAM for the compilation stage. 4 GB of RAM are required for compilation of x86 images. Doing additional optimization such as enabling LTO compile flag would also increase RAM consumption during build.

The more additional packages you add in the image, the more space is required, but the space requirements should increase slowly, most of the storage requirements are for the build infrastructure and core components of the firmware image.

Do note that these numbers are rough estimates only, you may very well be able to do it with less on some devices, but it's not guaranteed.

## Description

The **build system** is a set of [Makefiles](https://en.wikipedia.org/wiki/Make_%28software%29#Makefiles "https://en.wikipedia.org/wiki/Make_(software)#Makefiles") and [patches](https://en.wikipedia.org/wiki/Patch_%28computing%29 "https://en.wikipedia.org/wiki/Patch_(computing)") that automates the process of building a [cross-compilation](https://en.wikipedia.org/wiki/Cross_compiler "https://en.wikipedia.org/wiki/Cross_compiler") [toolchain](https://en.wikipedia.org/wiki/Toolchain "https://en.wikipedia.org/wiki/Toolchain") and then using it to build the Linux kernel, the [root filesystem](http://gnulinux.in/forum/what-root-file-system "http://gnulinux.in/forum/what-root-file-system") and possibly other pieces of software (such as [uboot](https://en.wikipedia.org/wiki/Das_U-Boot "https://en.wikipedia.org/wiki/Das_U-Boot")) required to run OpenWrt on a specific device. A typical toolchain consists of:

- A compiler, such as [gcc](https://en.wikipedia.org/wiki/GNU%20Compiler%20Collection "https://en.wikipedia.org/wiki/GNU Compiler Collection")
- Binary utilities such as an assembler and a linker; for example [binutils](https://en.wikipedia.org/wiki/GNU%20Binutils "https://en.wikipedia.org/wiki/GNU Binutils")
- A [C standard library](https://en.wikipedia.org/wiki/C%20standard%20library "https://en.wikipedia.org/wiki/C standard library"), such as glibc, musl, uClibc or dietlibc

Usually a toolchain generates code for the same instruction set architecture (ISA) that it runs on ([x86\_64](https://en.wikipedia.org/wiki/x86_64 "https://en.wikipedia.org/wiki/x86_64") in the case of most PCs and servers). However with OpenWrt this is not true. Most routers have processors that use a different architecture than the one we are using to run the build system. If we were to use our build system's toolchain to build OpenWrt for our router, it would generate code that would not work on our router. Nothing from the host system can be used. Everything, including the C standard library, the Linux kernel and all userspace programs, must be compiled with this cross-compilation toolchain.

Let's look at an example. We are building OpenWrt on an x86\_64 system for a router that uses a MIPS32 architecture, so we can't use the same toolchain we use to generate programs we run on our x86\_64 system. We need to first build a toolchain for the MIPS32 system, and then build all of the things that it needs to run OpenWrt using that toolchain.

The process of creating a cross compiler can be tricky. It's not something that's regularly attempted and so there's a certain amount of mystery and black magic associated with it. When you're dealing with embedded devices you'll often be provided with a binary copy of a compiler and basic libraries rather than instructions for creating your own - it's a time saving step but at the same time often means you'll be using a rather dated set of tools. It's also common to be provided with a patched copy of the Linux kernel from the board or chip vendor, but this is also dated and it can be difficult to spot exactly what has been changed to make the kernel run on the embedded platform.

While it is possible to manually create your toolchain, and then build OpenWrt with it, this is difficult and error-prone. The OpenWrt build system takes a different approach to building a firmware: it downloads, patches and compiles everything from scratch, including the cross compiler. Or to put it in simpler terms, OpenWrt's build system doesn't contain any executables or even sources. It is an automated system for downloading the sources, patching them to work with the given platform and compiling them correctly for the platform. What this means is that just by changing the template, you can change any step in the process. And of course the side benefit of this is that builds are automated, which saves time and guarantees the same result every time.

For example if a new kernel is released, a simple change to one of the Makefiles will download the latest kernel, patch it to run on the requested platform and produce a new firmware image. There's no work to be done trying to track down an unmodified copy of the existing kernel to see what changes had been made - the patches are already provided and the process ends up almost completely transparent. This doesn't just apply to the kernel, but to anything included with OpenWrt - it's this strategy that allows OpenWrt to stay on the bleeding edge with the latest compilers, kernels and applications.

## Directory structure

There are four key directories in the build system:

- `tools` - contains various utilities required for building toolchain and packages (e.g. autoconf automake), or for image generation (e.g. mkimage, squashfs). Some of these utilities could also be installed in the host system, but we include them in the OpenWrt source so that we don't have to worry about different versions used in various Linux distributions causing breakage, or to support building on macOS.
- `toolchain` - refers to the compiler, the c library, and common tools which will be used to build the firmware image. The result of this is two new directories, `toolchain_build_<arch>` which is a temporary directory used for building the toolchain for a specific architecture, and `staging_dir_<arch>` where the resulting toolchain is installed. You won't need to do anything with the `toolchain` directory unless you intend to add a new version of one of the components above.
- `target` - refers to the embedded platform, this contains items which are specific to a specific embedded platform. Of particular interest here is the `target/linux` directory which is broken down by platform and contains the kernel config and patches to the kernel for a particular platform. There's also the `target/image` directory which describes how to package a firmware for a specific platform.
- `package` - is for exactly that - packages. In an OpenWrt firmware, almost everything is an ipk, a software package which can be added to the firmware to provide new features or removed to save space.
- `dl` - anything downloaded by the toolchain, target or package steps will be placed in this directory.

Both the `target` and `package` steps will use the directory `build_<arch>` as a temporary directory for compiling.

## Difference between build\_dir and staging\_dir

The directory `build_dir` is used to unpack all the source archives and to compile them in.

The directory `staging_dir` is used to “install” all the compiled programs into, ready either for use in building further packages, or for preparing the firmware image.

There are three areas under `build_dir`:

- `build_dir/host`, for compiling all the tools that run on the host computer (OpenWrt builds its own version of `sed` and many other tools from source). This area will be used for compiling programs that run only on your host.
- `build_dir/toolchain...` for compiling the cross-C compiler and C standard library components that will be used to build the packages. This area will be used for compiling programs that run only on your host (the cross C compiler, for example) and also, libraries designed to run on the target that are linked to - e.g. uClibc, libm, pthreads, etc.
- `build_dir/target...` for compiling the actual packages, and the Linux kernel, for the target system

Under staging, there are also three areas:

- `staging_dir/host` is a mini Linux root with its own `bin/`, `lib/`, etc. that the host tools are installed into; the rest of the build system then prefixes its PATH with directories in this area
- `staging_dir/toolchain...` is a mini Linux root with its own `bin/`, `lib/`, etc that contains the cross C compiler used to build the rest of the firmware. You can actually use that to compile simple C programs outside of OpenWrt that can be loaded onto the firmware. The C compiler might be something like: `staging_dir/toolchain-mips_34kc_gcc-4.8-linaro_uClibc-0.9.33.2/bin/mips-openwrt-linux-uclibc-gcc`. You can see the version of the CPU, the C library and gcc encoded into it; this allows multiple targets to be built in the same area concurrently.
- `staging_dir/target.../root-...` contains “installed” versions of each target package again arranged with `bin/`, `lib/`, this will become the actual root directory that with some tweaking will get zipped up into the firmware image, something like `root-ar71xx`. There are some other files in `staging_dir/target...` primarily used for generating the packages and development packages, etc.

## Features

- Makes it easy to port software
- Uses kconfig (Linux Kernel menuconfig) for configuration of features
- Provides integrated cross-compiler toolchain (gcc, ld, ...)
- Provides abstraction for autotools (automake, autoconf), cmake, scons
- Handles standard download, patch, configure, compile and packaging workflow
- Provides a number of common fixups for badly behaving packages

## Make targets

- Offers a number of high level make targets for standard package workflows
- Targets always in the format `component/name/action`, e.g. `toolchain/gdb/compile` or `package/mtd/install`
- Prepare a package source tree: `package/foo/prepare`
- Compile a package: `package/foo/compile`
- Clean a package: `package/foo/clean`

## Build sequence

1. `tools` – automake, autoconf, sed, cmake
2. `toolchain/binutils` – as, ld, ...
3. `toolchain/gcc` – gcc, g++, cpp, ...
4. `target/linux` – kernel modules
5. `package` – core and feed packages
6. `target/linux` – kernel image
7. `target/linux/image` – firmware image file generation

## Patch management

- Many packages will not work as-is and need patches to work on the target or to even compile
- The build system integrates [quilt](https://en.wikipedia.org/wiki/Quilt%20%28software%29 "https://en.wikipedia.org/wiki/Quilt (software)") for easy patch management
- Turn package patches into quilt series: `make package/foo/prepare QUILT=1`
- Update patches from modified series: `make package/foo/update`
- Automatically rebase patches after an update: `make package/foo/refresh`

## Packaging considerations

- Main objective is small memory and size footprint
- Features that make no sense on embedded systems are disabled through configure or patched out
- Packages must be compatible regardless of the host system, they should be self contained
- Shipped “configure” scripts are often faulty or unusable in a cross-compile setting, autoreconf or patching is often needed
- Build variants and kconfig includes allow for configurable compile-time settings
- There is no standard way for porting software, in many cases it “just works” but often the package build process needs tweaks

## References

- [OpenWrt Forums: An introduction to OpenWrt Buildroot](https://forum.openwrt.org/viewtopic.php?pid=31794#p31794 "https://forum.openwrt.org/viewtopic.php?pid=31794#p31794")
