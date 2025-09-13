# Building a single package

Useful if you want to upgrade a package without reflashing the router.

Follow the [Build system usage](/docs/guide-developer/toolchain/use-buildsystem "docs:guide-developer:toolchain:use-buildsystem") up to the point when you `make menuconfig`. In here, select the target platform, then tick the package you want to build, and also its dependencies. If the package isn't ticked, the below commands will succeed without actually building the package. If you don't know the dependencies, you can ask the router. Let's assume we want to build `nano`:

```
# opkg info nano
Package: nano
Version: 2.2.5-1
Depends: libncurses
Provides:
Status: install user installed
Architecture: ar71xx
Installed-Time: 1300757537
```

The `Depends:` line is what we're interested into. The same information can also be found in the `Packages` file from the [package repository](/packages/start#package_lists_for_legacy_releases "packages:start").

Now issue the following commands:

```
make tools/install
make toolchain/install
```

The next step is building the dependencies. Back to our nano example:

```
make package/ncurses/compile
```

To build the host version of `ncurses` (that's used by `make menuconfig` below, for example):

```
make package/ncurses/host/compile
```

And finally, you get to build the package:

```
make package/nano/compile
make package/index
```

Done! You will find your coveted package in the `bin/` directory.

![:!:](/lib/images/smileys/exclaim.svg) If you get errors about not finding opkg in the staging directory, compile and install `package/base-files`.

![:!:](/lib/images/smileys/exclaim.svg) If you get errors that the package is not found, make sure you're typing the package directory name, not the package name listed in the Makefile (which may be different when a single Makefile builds multiple packages).

## Package maintenance on self-compiled kernel from latest snapshot

The problem we face when using the Latest snapshot, is that opkg quickly becomes incompatible with the snapshot as it moves forward in time. The idea is to use the feeds script with `-a` flag to prep all possible packages. Then when you want to install packages down the road, you go into `make menuconfig`, set the packages you want as modules `<M>`. Then do make package/compile to compile them as IPK files to the bin directory. Then you can scp them to the router `/tmp` for instance, and opkg install them. Sometimes opkg complains about MD5 mismatch with remote, or kernel version mismatch. Use opkg override flags if you must, E.G. `--force-depends` and/or `--force-checksum`.

## Kernel modules

One way or another, you'll need the [toolchain](/docs/guide-developer/toolchain/using_the_sdk "docs:guide-developer:toolchain:using_the_sdk") first. `make package/[kernel-module]` will not *build* modules, only package them. If they weren't built previously then you'll only get empty module packages. Instead:

```
make menuconfig
```

In the menuconfig, select your module such that an `<M>` appears, save and exit.

```
make target/linux/compile
make package/kernel/linux/compile
```

The resulting ipk will be in the `bin/targets/[target]/[subtarget]/packages` directory. You can `scp` it to the router and use `opkg install`.

## If the above does not work

You can always just rebuild everything.

```
make defconfig download clean world
```
