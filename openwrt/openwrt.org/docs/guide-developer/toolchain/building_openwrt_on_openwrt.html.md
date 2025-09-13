# Building OpenWrt ON OpenWrt

While the intention in the past hasn't been to make OpenWrt self hosting, with a few additions it can be. This is still experimental and requires workarounds for bugs in perl, llvm, and OpenWrt itself. This is a work in progress, but building OpenWrt *inside of* OpenWrt is possible.

## Purpose

Why Build OpenWrt on OpenWrt?

1. Becoming self-hosting is an important milestone for any OS.
2. It makes building OpenWrt more accessible for those with less resources.
3. Only building on a monoculture (x86-based full blown Linux systems) lets a lot of bugs slip under the radar. Building on a different system can (and did) expose issues that would inevitably crop up later.
4. For the educational value and bragging rights of knowing that your device's OS was built on your device.

## Device Requirements

So far this has been tested on armv7l and aarch64 devices, but will likely work on most if not all OpenWrt supported architectures. However the device's hardware does need to meet some minimum requirements:

- 1GHz or faster CPU, multi-core is an asset.
- 512MiB of physical RAM per core you intend to use in the build for 32-bit devices. For 64-bit devices you need double this.1
- 2GiB of swap space. This should be on a physical hard drive, or high quality external device (meaning not the device's internal eMMC).2
- 1GiB of storage space on your root device for all the packages you will need.
- ~26GiB of storage space for the build.

Note1: The initial toolchain build (especially of llvm-bpf) is quite RAM-hungry. The given memory requirements should be considered a minimum if you are building your own llvm-bpf. If you are able to use a pre-built llvm-bpf, then you can get away with less RAM-per-core. If you run this procedure on a QEMU virtual machine, dont use ballooning memory as it will result in oom-errors (during tools/cmake).

Note2: Your swap space (and to a lesser extent, the storage space for the build itself) should be on a hard drive or high quality solid state storage device. It should not under any circumstances be on the device's internal eMMC storage. This is to avoid NAND flash wear as this process is write heavy especially with swapping. Also, the larger your storage device is the more the wear will be spread.

## Setting Up The Development Environment

### User

Elements of the build system don't like to be built as root. OpenWrt is essentially single-user, so to get around this:

```
export FORCE_UNSAFE_CONFIGURE=1
```

You might want to add the above to your ~/.profile

### OpenWrt Packages

First of all you need a lot of OpenWrt packages:

- The development tools themselves:  
  `opkg install pkg-config make gcc diffutils autoconf automake check git git-http patch libtool-bin`
- Miscelaneous tools used in the build system:  
  `opkg install grep rsync tar python3 getopt procps-ng-ps gawk sed xz unzip gzip bzip2 flock wget-ssl`
- Perl3 and Python:  
  `opkg install perl perlbase-findbin perlbase-pod perlbase-storable perlbase-feature perlbase-b perlbase-ipc perlbase-module perlbase-extutils perlbase-time perlbase-json-pp python3`
- A bunch of coreutils, since busybox versions aren't good enough in some cases, or aren't there:  
  `opkg install coreutils-nohup coreutils-install coreutils-sort coreutils-ls coreutils-realpath coreutils-stat coreutils-nproc coreutils-od coreutils-mkdir coreutils-date coreutils-comm coreutils-printf coreutils-ln coreutils-cp coreutils-split coreutils-csplit coreutils-cksum coreutils-expr coreutils-tr coreutils-test coreutils-uniq coreutils-join`
- A few libraries:  
  `opkg install libncurses-dev zlib-dev musl-fts libzstd`  
  `ln -s libncursesw.a /usr/lib/libncurses.a`
- Some good-to-have packages to make life easier (instructions below will assume you have these):  
  `opkg install joe joe-extras bash htop whereis less file findutils findutils-locate chattr lsattr xxd`

Note3: The test systems this was performed on had quite a bit of perl pre-installed, so there may be more perl packages required.

Before we can go further, we have our first workaround:

**OpenWrt Bug**: OpenWrt doesn't put execute permissions on the scripts for the `automake`, `autoconf`, and `libtool` packages. This prevents a lot of build systems (including OpenWrt's own) from working correctly. To fix:  
`chmod +x /usr/share/automake-1.16;chmod -x /usr/share/automake-1.16/COPYING /usr/share/automake-1.16/INSTALL`  
`chmod +x /usr/share/autoconf/Autom4te/*`  
`chmod +x /usr/share/libtool/build-aux/*`

### Libraries and Tools

A few dev libraries are needed. Two of them *are* are included in OpenWrt, but by default OpenWrt strips them (using `sstrip`) so that you can't actually compile against them. Switch to your ~/devel folder (or wherever you're going to use as your base build directory) and do the following:

#### Libraries

- [libargp](https://github.com/xhebox/libuargp "https://github.com/xhebox/libuargp"): A GNU GLIBC extension used by elflibs
  
  ```
  git clone https://github.com/xhebox/libuargp.git
  cd libuargp
  make
  make prefix=/usr install
  ln -s libargp.so /usr/lib/libargp.so.0
  cd ..
  ```
- [libfts](https://github.com/void-linux/musl-fts "https://github.com/void-linux/musl-fts"): Another GNU GLIBC extension needed for elflib.  
  We installed the non-dev version above already, so this will overwrite it with one that can be compiled against. We installed the non-dev version first so that it doesn't get installed later and overwrite your dev version with a lobotomized one:
  
  ```
  git clone https://github.com/void-linux/musl-fts.git
  cd musl-fts
  ./bootstrap.sh
  ./configure --prefix=/usr
  make
  make install
  cd ..
  ```
- [libobstack](https://github.com/void-linux/musl-obstack "https://github.com/void-linux/musl-obstack"): The final GNU GLIBC extension needed for elflib
  
  ```
  git clone https://github.com/void-linux/musl-obstack.git
  cd musl-obstack
  ./bootstrap.sh
  ./configure --prefix=/usr
  make
  make install
  cd ..
  ```
- libdl, librt, libresolv, and libpthread:  
  These are libraries for functions which are actually included in musl libc directly. However, since some tools try and link explicitly against these libs, you will run into “file not found” errors. To get around that, just make stub libraries for them:
  
  ```
  ar -rc /usr/lib/libdl.a
  ar -rc /usr/lib/librt.a
  ar -rc /usr/lib/libpthread.a
  ar -rc /usr/lib/libresolv.a
  ```
- [libzstd](https://github.com/facebook/zstd/ "https://github.com/facebook/zstd/"): A compression library now needed by llvm-bpf.  
  Like musl-fts above, OpenWrt does support this library, but by default ships a lobotomized version that can't be built against. We install the OpenWrt version above so it won't be later installed and overwrite the proper version we're making below:
  
  ```
  wget https://github.com/facebook/zstd/releases/download/v1.5.2/zstd-1.5.2.tar.gz
  tar -xvzf zstd-1.5.2.tar.gz
  cd zstd-1.5.2/lib
  make
  make prefix=/usr install
  cd ../..
  ```
- bzcat: Not a bug per se, though one might call it a bug by omission. The bzip2 binary also acts as bunzip2 and bzcat, but it can only do so if the proper softlinks are made when it's installed, which the OpenWrt package doesn't do. So:
  
  ```
  ln -s bzip2 /usr/bin/bunzip2
  ln -s bzip2 /usr/bin/bzcat
  ```
- swig: Needed for uboot
  
  ```
  git clone https://github.com/akimd/bison.git
  git clone https://github.com/swig/swig.git
  cd swig
  sh autogen.sh
  ./configure --prefix=/usr --without-pcre
  opkg install bison m4
  chmod +x ./swig/Tools/config/install-sh
  export BISON_PKGDATADIR=/home/buildbot/bison/data
  cp /usr/share/autoconf/m4sugar/* /home/buildbot/bison/data/m4sugar/
  export M4=m4
  make
  make install
  ```

#### Tools

The single tool needed in the build system that OpenWrt doesn't support is `rev`, a little-known and littler-used Unix tool. It's part of util-linux, which does provide a lot of packages for OpenWrt, but rev isn't one of them. It is, however, built as part of the process below, so it'll be be installed later.

## Getting and Building OpenWrt

This is based on the [build system instructions](/docs/guide-developer/toolchain/use-buildsystem "docs:guide-developer:toolchain:use-buildsystem"), with a bunch of deviations to fix various bugs along the way:

Make sure you're in your devel directory from before. The following assume you are building SNAPSHOT, but can be (with appropriate changes) be used for release versions as well.

01. Get OpenWrt master and associated packages:
    
    ```
    git clone https://git.openwrt.org/openwrt/openwrt.git
    cd openwrt
    git checkout master
    git pull
    ./scripts/feeds update -a
    ./scripts/feeds install -a
    ```
02. Get the config file for [your architecture](https://downloads.openwrt.org/snapshots/targets/ "https://downloads.openwrt.org/snapshots/targets/") and save it as .config. For example, for a device based on the mt7622 chipset (such as the BPI-R64) it is this:
    
    ```
    wget https://downloads.openwrt.org/snapshots/targets/mediatek/mt7622/config.buildinfo -O .config
    ```
03. Expand the configuration:
    
    ```
    make defconfig
    ```
04. **DECISION POINT**: llvm-bpf - build yourself or get pre-built  
    llvm-bpf is the the Berkeley Packet Filter bytecode compiler for Linux. It is a tool that is needed in order to build OpenWrt, but also can be built along with the rest of the OpenWrt toolchain below. Compiling llvm is easily the single most time and resource intensive step in building OpenWrt. If there is a pre-made one for your platform of the correct version for the version of OpenWrt you are building, then it is recommended to use it. Check the resources below. If you are using a pre-build one, then get it now and untar it into your openwrt working folder, so it will be there when you configure OpenWrt. For example:
    
    ```
    wget https://va1der.ca/~public/openwrt/llvm/llvm-bpf-15.0.7.Linux-armv7l.tar.xz
    tar -xvaf llvm-bpf-15.0.7.Linux-armv7l.tar.xz
    ```
05. Configure OpenWrt:  
    `make menuconfig`  
    Things to remember when you configure the build: Change “Target Profile” to build for only your platform (since by default it will want to build for all platforms using a given chipset). Also, if you obtained a pre-build llvm-bpf then change “Advanced Configuration Options → BPF Toolchain” to use the pre-built binary you obtained. Make any other tweaks you normally do, then save.
06. **If you are using pre-made llvm from step 4, then skip all of this step** (read the NOTE at the end though).  
    If you were unable or didn't want a pre-built llvm-bpf, then now is when you will build it. But first...  
    **llvm-bpf bugs:** There are two bugs in llvm's build system. One that [causes a built failure due to libatomic not being linked](https://discourse.llvm.org/t/build-of-14-06-fails-on-armv7-due-to-libatomic-not-being-linked/67091 "https://discourse.llvm.org/t/build-of-14-06-fails-on-armv7-due-to-libatomic-not-being-linked/67091"), and one that [causes a build failure when gcc is used instead of g++ at the linking stage](https://discourse.llvm.org/t/build-of-15-0-7-fails-due-to-libstdc-not-being-linked-against/68132 "https://discourse.llvm.org/t/build-of-15-0-7-fails-due-to-libstdc-not-being-linked-against/68132"). We will copy patches for both into the OpenWrt build system:
    
    ```
    mkdir tools/llvm-bpf/patches
    wget https://va1der.ca/~public/openwrt/patches/llvm-bpf/901-fix-fuzzer-linking.patch -O tools/llvm-bpf/patches/901-fix-fuzzer-linking.patch
    wget https://va1der.ca/~public/openwrt/patches/llvm-bpf/902-use-libatomic-as-required.patch -O tools/llvm-bpf/patches/902-use-libatomic-as-required.patch
    ```
    
    After musl-1.2.4 there were changes, such as lseek64 missing, and replaced with lseek, so llvm fails to build. To fix this, you need to make a minor change to llvm-bpf's Makefile, just under include $(INCLUDE\_DIR)/cmake.mk add following “HOST\_CFLAGS+= -D\_LARGEFILE64\_SOURCE”, so it will look a bit like this:
    
    ```
    ...
    CMAKE_SOURCE_SUBDIR := llvm
    
    include $(INCLUDE_DIR)/host-build.mk
    include $(INCLUDE_DIR)/cmake.mk
    
    HOST_CFLAGS+= -D_LARGEFILE64_SOURCE
    
    LLVM_BPF_PREFIX = llvm-bpf-$(PKG_VERSION).$(HOST_OS)-$(HOST_ARCH)
    ...
    ```
    
    Once those patches are copied and Makefile is fixed, you can build llvm. **Caution!** This is memory intensive, and a multi-core build on a system with marginal memory can push the system so far into memory-debt swapping that it can damage solid-state storage. A single-core build will take longer, but is safer. This is going to take a long time. Note that a drawback of OpenWrt's build system is that any time the build of any one package is interrupted, it starts that package from the beginning the next time. You don't want compilation to stop on a random net blip after ten hours, so use `nohup`. And start getting into the habit of using `V=sc` and logging everything, because this whole process is still experimental:
    
    ```
    nohup nice make -j 1 V=sc tools/llvm-bpf/compile > ~/llvmcomp01.out &
    ```
    
    Periodically check htop to make sure it is going well, and check the log when it stops. Hopefully there's no error, but if there is, welcome to the experiment. Debug, rinse and repeat and report it here for the rest of us.
    
    **NOTE:** Once llvm-bpf is out of the way, **if** you have multiple cores **and** enough RAM per core, then you should be ok to use multi-core compiling. Always keep a periodic eye on your build, though and htop is your friend. For all examples throughout these instructions, `-j 1` will be supplied to make for pasted commands for safety. But feel free to increase the core count at your discretion.
07. Now build the rest of the toolchain:
    
    ```
    nohup nice make -j 1 V=sc toolchain/install > ~/toolchain01.out &
    ```
    
    As with llvm, and all else, periodically check htop and the output log, debug, and repeat.
08. With the toolchain complete, you can do a make download. It had to wait until now because [a bug in qosify's makefile](https://github.com/openwrt/openwrt/issues/11193 "https://github.com/openwrt/openwrt/issues/11193") prevents make download from working before the toolchain is complete in some cases.
    
    ```
    make download
    ```
09. Build the the one missing tool noted above: `rev`. OpenWrt doesn't make a package out of it, even though it's built by default when OpenWrt builts packages out of its own util-linux. So we're going to build OpenWrt's util-linux then copy `rev` out. This is quick, probably no need to log it:
    
    ```
    make -j 1 package/util-linux/compile
    cp $(find . -wholename \*ipkg-install/usr/bin/rev) /usr/bin/rev
    ```
10. **perl bugs**: Here we fix three bugs in perl. One which [causes a problem with perl on musl](https://github.com/openwrt/openwrt/issues/11591 "https://github.com/openwrt/openwrt/issues/11591"), one where recent compilers cause a seg fault, and [one in Perl's Configure script](https://github.com/Perl/perl5/issues/20606 "https://github.com/Perl/perl5/issues/20606"). Fort these we need two patches. The first patch we will apply directly to OpenWrt's perl makefile:
    
    ```
    ( cd feeds/packages/lang/perl && wget https://va1der.ca/~public/openwrt/patches/perl/perl_fix_memmem_and_segfault.patch -O - 2> /dev/null | patch -p 1 )
    ```
    
    That fixes the first two bugs. This next fixes perl's configure bug, and we're just going to download and store it in the OpenWrt build system and let OpenWrt sic it on Perl when it builds it:
    
    ```
    wget https://va1der.ca/~public/openwrt/patches/perl/997-fix-Configure-gcc-parse.patch -O feeds/packages/lang/perl/patches/997-fix-Configure-gcc-parse.patch
    ```
11. **DECISION POINT**: perl bug - Test to see if your the OpenWrt device you are building on is affected by one of the above bugs. Some are, and if it is, you need to build perl right now with the above patch to fix your existing system. This is because the host system's perl is used when OpenWrt builds openssl. Download and run the script:
    
    ```
    wget https://va1der.ca/~public/openwrt/patches/perl/test_index.perl -O ~/test_index.pl
    chmod +x ~/test_index.pl
    ~/test_index.pl
    ```
    
    This will tell you if your perl is affected by the index() bug. If it is then build perl with the above bug patch above and copy libperl.so over top of of your system's buggy one:
    
    ```
    make -j 1 package/perl/compile
    cp $(find staging_dir -name libperl.so) /usr/lib/perl5/5.28/CORE/
    ~/test_index.pl
    ```
    
    The test should now show the index() bug is fixed
12. That was the last bug fix - you can now proceed with the rest of the build. This is likely to take a while (not as long as LLVM though). Continue to use `nohup`, tell make to give verbose output with `V=sc`, and continue to redirect that output to a log:
    
    ```
    nohup nice make -j 1 V=sc world > world01.out &
    ```

## Resources

### llvm-bpf

As noted above, it's beneficial to use a prebuilt llvm if possible. The following are available:

#### armv7l (ARM 32 little endian)

- [llvm-bpf-14.0.6.Linux-armv7l.tar.xz](https://va1der.ca/~public/openwrt/llvm/llvm-bpf-14.0.6.Linux-armv7l.tar.xz "https://va1der.ca/~public/openwrt/llvm/llvm-bpf-14.0.6.Linux-armv7l.tar.xz")
- [llvm-bpf-15.0.7.Linux-armv7l.tar.xz](https://va1der.ca/~public/openwrt/llvm/llvm-bpf-15.0.7.Linux-armv7l.tar.xz "https://va1der.ca/~public/openwrt/llvm/llvm-bpf-15.0.7.Linux-armv7l.tar.xz")

#### aarch64 (ARM 64)

- [llvm-bpf-14.0.6.Linux-aarch64.tar.xz](https://va1der.ca/~public/openwrt/llvm/llvm-bpf-14.0.6.Linux-aarch64.tar.xz "https://va1der.ca/~public/openwrt/llvm/llvm-bpf-14.0.6.Linux-aarch64.tar.xz")
- [llvm-bpf-15.0.7.Linux-aarch64.tar.xz](https://va1der.ca/~public/openwrt/llvm/llvm-bpf-15.0.7.Linux-aarch64.tar.xz "https://va1der.ca/~public/openwrt/llvm/llvm-bpf-15.0.7.Linux-aarch64.tar.xz")

#### AMD64 (aka x86\_64)

- [llvm-bpf-13.0.0.Linux-x86\_64.tar.xz](https://downloads.openwrt.org/releases/22.03.3/targets/mediatek/mt7622/llvm-bpf-13.0.0.Linux-x86_64.tar.xz "https://downloads.openwrt.org/releases/22.03.3/targets/mediatek/mt7622/llvm-bpf-13.0.0.Linux-x86_64.tar.xz")
- [llvm-bpf-15.0.7.Linux-x86\_64.tar.xz](https://downloads.openwrt.org/snapshots/targets/mediatek/filogic/llvm-bpf-15.0.7.Linux-x86_64.tar.xz "https://downloads.openwrt.org/snapshots/targets/mediatek/filogic/llvm-bpf-15.0.7.Linux-x86_64.tar.xz")

## On Errors

The above procedure has been tested, but this is still very much an experimental process and Your Mileage May Vary™. On the first successful attempt output was up to log file world13.out on two different platforms. The majority of errors were simple ones, caused by missing tools or inadequate ones where the basic busybox version wasn't good enough. There still may be missing packages in the above procedure, since it was tested on existing systems with preset installation packages that you may or may not have. There may be other subtle issues on other architectures. When htop tells you compilation has stopped, look at the log. Jump to the end, then (if you were doing multi-core builds) search backwards for “Error” (often with capital E) to find what exactly went wrong. Most of the time it's a missing tool. Sometimes the issue has been subtle problems with multi-core building. The timing of and staging of different parts of a build when doing a multi-core build changes on different architectures, and deficiencies in dependency settings may not show up in normal x86 builds that do on other archtectures. If you, for example, run into issues of symbols not being found on linking, sometimes simply redoing the build, or building that package in a single-thread build resolves the issue. Feel free to post your results in the [forum thread for this](https://forum.openwrt.org/t/building-openwrt-on-openwrt-a-howto/146213 "https://forum.openwrt.org/t/building-openwrt-on-openwrt-a-howto/146213").

## Summary

There were quite a number of bugs that were exposed while developing this procedure. Bugs in OpenWrt, Perl, LLVM, and other places. However, one shouldn't consider the presence of bugs the deciding factor on whether a system is, in general, self-hosting. OpenWrt needs one small utility (rev), and three bandaid libs to cover for GNU extensions to GLIBC. That makes OpenWrt about 99.9% self-hosting ready. This is a great achievement, especially for an embedded OS where self-hosting wasn't even the goal, and more especially considering the enormous amount of complex code and a build system that uses so many different build tools. The OpenWrt devs are to be greatly commended for an excellent embedded OS!
