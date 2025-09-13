# Build System Usage

- Do everything as an unprivileged user, not root, without sudo.
- Make sure there are no spaces in the full path to the build directory.

There is an issue affecting the current OpenWrt source tree (from at least 21.02 onwards): OpenWrt images built in certain setups will succeed, but they will hang on boot if installed on a device. To work around this issue, please follow the instructions posted [here](https://github.com/openwrt/openwrt/issues/9545 "https://github.com/openwrt/openwrt/issues/9545") in the section titled “workaround” **before checking out the source tree**.

## Overview

These are the basic steps to build your own OpenWrt images/packages:

1. [Install the build prerequisites](/docs/guide-developer/toolchain/install-buildsystem "docs:guide-developer:toolchain:install-buildsystem")
2. Download the sources. Note that the canonical git repo url is [https://git.openwrt.org/openwrt/openwrt.git](https://git.openwrt.org/openwrt/openwrt.git "https://git.openwrt.org/openwrt/openwrt.git") but it is suggested to clone from [https://github.com/openwrt/openwrt.git](https://github.com/openwrt/openwrt.git "https://github.com/openwrt/openwrt.git") instead due to [longstanding](https://forum.openwrt.org/t/very-slow-git-clone/232552 "https://forum.openwrt.org/t/very-slow-git-clone/232552") [problems](https://forum.openwrt.org/t/clone-git-openwrt-org-slow/42054 "https://forum.openwrt.org/t/clone-git-openwrt-org-slow/42054") with git.openwrt.org.
   
   ```
   git clone https://github.com/openwrt/openwrt.git
   cd openwrt
   git pull 
   ```
3. View the available releases:
   
   ```
   git branch -a
   git tag
   ```
4. Then `git checkout <branch/tag>`, e.g.:
   
   ```
   git checkout openwrt-24.10
   ```
5. Update the feeds:
   
   ```
   ./scripts/feeds update -a
   ./scripts/feeds install -a
   ```
6. [Configure the firmware image](/docs/guide-developer/toolchain/use-buildsystem#menuconfig "docs:guide-developer:toolchain:use-buildsystem"):
   
   ```
   make menuconfig
   ```
7. *Optional*: [configure the kernel](/docs/guide-developer/toolchain/use-buildsystem#kernel_configuration_optional "docs:guide-developer:toolchain:use-buildsystem") (![:!:](/lib/images/smileys/exclaim.svg) usually not required, in case of doubt: don't)
8. Build the firmware image and packages:
   
   ```
   make defconfig download clean world
   ```
9. After a successful build, the freshly built image(s) and packages can be found below the newly created `<buildroot>/bin/targets` and `<buildroot>/bin/packages` directories, respectively. The exact location depends on the target/subtarget (for images) or architecture (for packages):
   
   ```
   # Assuming a build for a Netgear WNDR3800, an "ath79" target with a "generic" subtarget
   # and a "mips_24kc" package architecture
   
   find bin/targets/ -iname "*-sysupgrade.img*"
   bin/targets/ath79/generic/openwrt-24.10.2-ath79-generic-netgear_wndr3800-squashfs-sysupgrade.bin
   
   find bin/packages/ -iname "*.ipk"
   bin/packages/mips_24kc/packages/mips_24kc/packages/acme_4.0.0_all.ipk
   ...
   ```
   
   See also: [Directory structure](/docs/guide-developer/toolchain/buildsystem_essentials#directory_structure "docs:guide-developer:toolchain:buildsystem_essentials").

## Configuration

### Menuconfig

The **build system configuration interface** handles the selection of the target platform, packages to be compiled, packages to be included in the firmware file, some kernel options, etc.

Start the build system configuration interface by writing the following command:

```
make menuconfig
```

This will update the dependencies of your existing configuration automatically, and you can now proceed to build your updated images.

You will see a list of options. This list is really the top of a tree. You can select a list item, and descend into its tree.

To search for the package or feature in the tree, you can type the “/” key, and search for a string. This will give you its locations within the tree.

For most packages and features, you have three options: `y`, `m`, `n` which are represented as follows:

- pressing `y` sets the `<*>` built-in label  
  This package will be compiled and included in the firmware image file.
- pressing `m` sets the `<M>` package label  
  This package will be compiled, but **not** included in the firmware image file, e.g. to be installed with opkg after flashing the firmware image file to the device.
- pressing `n` sets the `< >` excluded label  
  The source code will not be processed.

When you save your configuration, the file **`<buildroot>/.config`** will be created / updated.

When you open `menuconfig` you will need to set the build settings in this order (also shown in this order in `menuconfig`'s interface):

1. Target system (general category of similar devices)
2. Subtarget (subcategory of Target system, grouping similar devices)
3. Target profile (each specific device)
4. Package selection
5. Build system settings
6. Kernel modules

Select your device's **Target system** first, then select the right **Subtarget**, then you can find your device in the **Target profile**'s list of supported platforms.

E.g. to select and save the target for [TL-WR841N v11](/toh/tp-link/tl-wr841n "toh:tp-link:tl-wr841n") Wi-Fi router:

1. Target System → Select → Atheros AR7xxx/AR9xxx → Select
2. Subtarget → Select → Devices with small flash → Select
3. Target Profile → Select → TP-LINK TL-WR841N/ND v11 → Select
4. Exit → Yes

### Diff File

Beside `make menuconfig` another way to configure is using a configuration diff file. This file includes only the changes compared to the default configuration. A benefit is that this file can be version-controlled in your downstream project. It's also less affected by upstream updates, because it only contains the changes.

#### Creating a Diff File

Save the build config changes.

```
# Write the changes to diffconfig
./scripts/diffconfig.sh > diffconfig
```

The firmware make process [automatically creates](https://git.openwrt.org/?p=openwrt%2Fopenwrt.git%3Ba%3Dcommit%3Bh%3D454021581f630d5d04afeb8ff6581c1bda295c87 "https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=454021581f630d5d04afeb8ff6581c1bda295c87") the configuration diff file `config.buildinfo`, previously named as `config.seed` in 18.06 and before.

#### Using a Diff File

These changes can form the basis of a config file `<buildroot>/.config`. By running `make defconfig` these changes will be expanded into a full config.

```
# Write changes to .config
cp diffconfig .config
 
# Expand to full config
make defconfig
```

These changes can also be added to the bottom of the config file (`<buildroot>/.config`), by running `make defconfig` these changes will override the existing configuration.

```
# Append changes to bottom of .config
cat diffconfig >> .config
 
# Apply changes
make defconfig
```

### Official Config

If you want to compile OpenWrt in a way that it gets [the same packages as the default official image](https://forum.openwrt.org/t/compiling-openwrt-exactly-like-the-official-one/23214 "https://forum.openwrt.org/t/compiling-openwrt-exactly-like-the-official-one/23214"), you can start from the configuration used to build the official images.

Let's assume that you are building for the [archer\_c7](/toh/tp-link/archer_c7 "toh:tp-link:archer_c7"), using this specific release:

[https://downloads.openwrt.org/releases/24.10.2/targets/ath79/generic/openwrt-24.10.2-ath79-generic-tplink\_archer-c7-v2-squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.2/targets/ath79/generic/openwrt-24.10.2-ath79-generic-tplink_archer-c7-v2-squashfs-factory.bin "https://downloads.openwrt.org/releases/24.10.2/targets/ath79/generic/openwrt-24.10.2-ath79-generic-tplink_archer-c7-v2-squashfs-factory.bin")

In the same directory as the firmware, you'll also find the configuration file used, named `config.buildinfo`:

```
wget https://downloads.openwrt.org/releases/24.10.2/targets/ath79/generic/config.buildinfo -O .config
```

When using this configuration the correct defaults will already be selected for the Target and Subtarget but **not** for the Target profile so you will have to modify the configuration to limit it to the specific device if you want to build only that image.

### Custom Files

In case you want to include some custom configuration files, the correct place to put them is:

- **`<buildroot>/files/`**

For example, let's say that you want an image with a custom **`/etc/config/firewall`** or a custom **`etc/sysctl.conf`** , then create this files as:

- `<buildroot>/files/etc/config/firewall`
- `<buildroot>/files/etc/sysctl.conf`

E.g. if your `<buildroot>` is `~/source` and you want some files to be copied into firmware image's `/etc/config` directory, the correct place to put them is `~/source/files/etc/config`.

It is strongly recommended to use [uci-defaults](/docs/guide-developer/uci-defaults "docs:guide-developer:uci-defaults") to incrementally integrate only the required customization. This helps minimize conflicts with auto-generated settings which can change between versions.

### Defconfig

```
make defconfig
```

will produce a default configuration of the target device and build system, including a check of dependencies and prerequisites for the build environment.

Defconfig will also remove outdated items from `.config`, e.g. references to non-existing packages or config options.

It also checks the dependencies and will add possibly missing necessary dependencies. This can be used to “expand” a short .config recipe (like diffconfig output, possible even pruned further) to a full .config that the make process accepts.

### Kernel

Note that `make kernel_menuconfig` modifies the Kernel configuration templates of the build tree and clearing the build\_dir will not revert them. ![:!:](/lib/images/smileys/exclaim.svg) Also you won't be able to install kernel packages from the official repositories when you make changes here.

While you won't typically need to do this, first define the target, subtarget, and device in a `.config`, for example:

```
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_x86_64_DEVICE_generic=y
```

Now run the following where subtarget is not a variable, it is a literal and it references the `.config` we just created (in this case x86/64):

```
make kernel_menuconfig CONFIG_TARGET=subtarget
```

CONFIG\_TARGET allows you to select which config you want to edit, possible options: target, subtarget, env.

The changes can be reviewed and reverted with:

```
git diff target/linux/
git checkout target/linux/
```

### Source mirrors

The 'Build system settings' include some efficient options for changing package locations which makes it easy to handle a local package set:

1. Local mirror for source packages
2. Download folder

In the case of the first option, you simply enter a full URL to the HTTP or FTP server on which the package sources are hosted. Download folder would in the same way be the path to a local folder on the build system (or network). If you have a web/ftp-server hosting the tarballs, the build system will try this one before trying to download from the location(s) mentioned in the Makefiles. Similar if a local 'download folder', residing on the build system, has been specified.

The 'Kernel modules' option is required if you need specific (non-standard) drivers and so forth – this would typically be things like modules for USB or particular network interface drivers etc.

### Download sources and multi core compile

Before running final make it is best to issue make download command first, this step will pre-fetch all source code for all dependencies, this enables you compile with more CPU cores, e.g. `make -j10`, for 4 core, 8 thread CPU works great.

If you try compiling OpenWrt on multiple cores and don't download all source files for all dependency packages it is very likely that your build will fail.

```
make download
```

## Building

Everything is now ready for building the image(s), which is done with one single command:

```
make
```

This should compile toolchain, cross-compile sources, package packages, and generate an image ready to be flashed.

### Make tips

See also: [Compiler optimization tweaks](https://forum.openwrt.org/viewtopic.php?id=35323 "https://forum.openwrt.org/viewtopic.php?id=35323")

`make download` will pre-download all source code for all dependencies, this will enable multi core compilation to succeed, without it is is very likely to fail. `make -j`**N** will speed up compilation by using up to **N** cores or hardware threads to speed up compilation, `make -j9` fully uses 8 cores or hardware threads.

Example of pre-downloading and building the images on a 4 core CPU:

```
make -j5 download world
```

You can use [''nproc'' command to get available CPU count](https://unix.stackexchange.com/questions/208568/how-to-determine-the-maximum-number-to-pass-to-make-j-option "https://unix.stackexchange.com/questions/208568/how-to-determine-the-maximum-number-to-pass-to-make-j-option"):

```
make -j $(nproc) download world
```

or a better macro with `nproc+1`:

```
make -j $(($(nproc)+1))
```

#### Building in the background

If you intend to use your system while building, you can have the build process use only idle I/O and CPU capacity like this (4 core, 8 thread CPU):

```
make download
ionice -c 3 chrt --idle 0 nice -n19 make -j9
```

#### Building single packages

When developing or packaging software, it is convenient to be able to build only the package in question, e.g. with package `jsonpath`:

```
make package/utils/jsonpath/compile V=s
```

For a rebuild:

```
make package/utils/jsonpath/{clean,compile} V=s
```

It doesn't matter what feed the package is located in, this same syntax works for any installed package.

Note: you must have done a full tree build (make, or make world) beforehand for this to work reliably.

#### Spotting build errors

If for some reason the build fails, the easiest way to spot the error is to do:

```
make V=s 2>&1 | tee build.log | grep -i -E "^make.*(error|[12345]...Entering dir)"
 
make V=s 2>&1 | tee build.log | grep -i '[^_-"a-z]error[^_-.a-z]' 
(may not work)
```

![:!:](/lib/images/smileys/exclaim.svg) If **grep** throws an error, use **fgrep** instead.

The above saves a full verbose copy of the build output (with stdout piped to stderr) in `~/source/build.log` and shows errors on the screen (along with a few spurious instances of 'error').

Another example:

```
ionice -c 3 nice -n 20 make -j 2 V=s CONFIG_DEBUG_SECTION_MISMATCH=y 2>&1 | tee build.log
```

The above saves a full verbose copy of the build output (with stdout piped to stderr) in build.log while building using only background resources on a dual core CPU.

Yet another way to focus on the problem without having to wade through tons of output from Make as described above is to check the corresponding log in `logs` folder. i.e. if the build fails at `make[3] -C package/kernel/mac80211 compile`, then you can go to `<buildroot>/logs/package/kernel/mac80211` and view the `compile.txt` found there.

#### Getting beep notification

Depending on your CPU, the process will take a while, or while longer. If you want an acoustic notification, you could use this way:

```
make ...; echo -e '\a'
```

#### Ignore build errors

If you are building everything (not just the packages to make a flashable image), you will probably want to keep building all packages even if some have compile errors and won't be built.

```
# Ignore compilation errors
IGNORE_ERRORS=1 make ...
 
# Ignore all errors including firmware assembly stage
make -i ...
```

#### Make a summary information of generated image

```
make json_overview_image_info
```

Generate a summary of the image (including default packages, type of target, etc... ) in JSON format. The output is available in `<BUILD_DIR>/profiles.json`.

#### Calculate checksum for generated files

```
make checksum
```

The following action will take place: a checksum will be computed and saved for the output files. This checksum will then be stored in the '&lt;BIN\_DIR&gt;/sha256sums' .

## Cleaning Up

You might need to clean your *build environment* every now and then.

The build artefacts, toolchain, build tools and downloaded feeds &amp; sources files can be cleaned selectively.  
The following `make`-targets are useful for that job.  
`make clean` is the most frequently needed clean operation.

&gt; Cleaned components &gt;  
v make argument v Compiled binaries:  
firmware, kernel, packages Toolchain  
(target-specific) Build tools,  
tmp/  
Compiled  
config tools .config

feeds, .ccache,  
downloaded source files clean x targetclean x x dirclean x x x x config-clean x distclean x x x x x x

### Clean

```
make clean
```

Deletes contents of the directories `/bin` and `/build_dir`. This doesn't remove the toolchain, and it also avoids cleaning architectures/targets other than the one you have selected in your `.config`. It is a good practice to do `make clean` before a build to ensure that no outdated artefacts have been left from the previous builds. That may not be necessary always, but as a general rule it helps to ensure quality builds.

### Targetclean

```
make targetclean
```

This cleans also the target-specific toolchain in addition of doing `make clean`. This may be needed when the toolchain components like musl or gcc change.  
Does a `make clean` and deletes also the directories `/build_dir/toolchain*` and `/staging_dir/toolchain*` (= the cross-compile tools).

Note: `make targetclean` has been introduced in 22.03 and is not found in earlier OpenWrt versions.

### Dirclean

```
make dirclean
```

This is your basic “full clean” operation. Cleans all compiled binaries, tools, toolchain, tmp/ etc.  
Deletes contents of the directories `/bin` and `/build_dir` and `/staging_dir` (= tools and the cross-compile toolchain), `/tmp` (e.g data about packages) and `/logs`.

### Distclean

```
make distclean
```

Nukes everything you have compiled or configured and also deletes all downloaded feeds contents and package sources. ![:!:](/lib/images/smileys/exclaim.svg) In addition to all else, this will **erase your build configuration `<buildroot>/.config`** . Use only if you need a “factory reset” of the build system!

### Selective cleanup

In more time, you may not want to clean so many objects, then you can use some of the commands below to do it.

```
# Clean linux objects
make target/linux/clean
 
# Clean package base-files objects
make package/base-files/clean
 
# Clean luci objects
make package/luci/clean
```

## Developing

### Updating

#### Sources

![:!:](/lib/images/smileys/exclaim.svg) The development branch changes frequently. It is recommended that you work with the latest sources by periodically running:

```
git pull
```

#### Feeds

To pull the latest updates for the feeds, run:

```
./scripts/feeds update -a
```

And then to make any new packages available in `make menuconfig` (this can help to avoid problems like `WARNING: Makefile 'package/utils/busybox/Makefile' has a dependency on 'libpam', which does not exist`):

```
./scripts/feeds install -a
```

Or, alternatively, for a single package:

```
./scripts/feeds install <package_name>
```

### Custom Feeds

1. Prepare your `<buildroot>` with git cloning openwrt sources from github (e.g. from your fork).
2. Create a dir: `mkdir -p <buildroot>/my_packages/<section>/<category>/<package_name>`.  
   Replace the `<package_name>` with the name of your package.  
   e.g. `mkdir -p my_packages/net/network/rpcbind`.  
   The section and category can be found in the `Makefile`.
3. Write a Makefile or download one `Makefile` from another package, look at samples on github.  
   Edit your Makefile and add necessary files, sources...  
   More: [Creating packages](/docs/guide-developer/packages "docs:guide-developer:packages") &amp; [Creating a package from your application](/docs/guide-developer/helloworld/chapter3 "docs:guide-developer:helloworld:chapter3")
4. Append a line with your custom feed to `feeds.conf.default`:  
   `src-link my_packages <buildroot>/my_packages`  
   Replace the `<buildroot>` with cloned openwrt sources directory e.g. `/home/user/openwrt` (the path must be absolute).  
   Move the line with your custom feed above standard feeds to override them.
5. Now run: `./scripts/feeds update -a; ./scripts/feeds install <package_name>`  
   If you are doing this to resolve a dependency you can run `./scripts/feeds install <package_name>` one more time and you should notice the dependency has been resolved.
6. Build your package.  
   Select it in the menu of `Make menuconfig`  
   Build it with `make package/my_package_name/{clean,compile}`  
   More: [Building a single package](/docs/guide-developer/toolchain/single.package "docs:guide-developer:toolchain:single.package")

### Switching Releases

#### Note

![:!:](/lib/images/smileys/exclaim.svg) When switching between branches/tags/commits, it is recommended to perform a thorough scrub of your source tree by using the `make distclean` command. This ensures that your source tree does not contain any build artifacts or configuration files from previous build runs.

![:!:](/lib/images/smileys/exclaim.svg) Note that switching is also likely to update the `feeds.conf.default` file, meaning that you'll switch to different package feeds, unless you have a custom `feeds.conf` (which you should review carefully).

#### Branches

Each branch contains the most recent code for a given major release, e.g. `openwrt-24.10`, `openwrt-23.05` (and `main`/`master` contains the bleeding edge development branch). Except for `master`, each branch is intended to contain **stable** code with carefully selected fixes and backports.

To use a branch, clone the Git repository using the `git clone` command explained above and then move to the branch by using the `git checkout` command.

1. Update branches:
   
   ```
   git fetch -a
   ```
2. List branches:
   
   ```
   git branch -a
   ```
3. Switch to the development branch:
   
   ```
   git checkout master
   ```
4. Switch to the OpenWrt 24.10 branch:
   
   ```
   git checkout openwrt-24.10
   ```

#### Tags

Each minor release has a corresponding tag in git, which allows you to work on a more specific version:

1. Update tags:
   
   ```
   git fetch -a -t
   ```
2. List tags:
   
   ```
   git tag | grep v24.10
   v24.10.0
   v24.10.0-rc1
   ...
   v24.10.1
   v24.10.2
   ```
3. Switch to the 24.10.2 release:
   
   ```
   git checkout v24.10.2
   ```

#### Commits

On an even more lower level, you can also switch to a specific commit:

1. Select a specific commit hash:
   
   ```
   REV_HASH="4c73c34ec4215deb690bf03faea2a0fe725476f0"
   git checkout ${REV_HASH}
   REV_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
   ```
2. Replace all references to `src-git` with `src-git-full` in your [feeds](https://openwrt.org/docs/guide-developer/feeds#feed_configuration "https://openwrt.org/docs/guide-developer/feeds#feed_configuration"):
   
   ```
   sed -e "/^src-git\S*/s//src-git-full/" feeds.conf.default > feeds.conf
   ./scripts/feeds update -a
   ```
3. Edit every line of feeds.conf in a loop to point to a specific commit:
   
   ```
   sed -n -e "/^src-git\S*\s/{s///;s/\s.*$//p}" feeds.conf \
   | while read -r FEED_ID
   do
   REV_DATE="$(git log -1 --format=%cd --date=iso8601-strict)"
   REV_HASH="$(git -C feeds/${FEED_ID} rev-list -n 1 --before=${REV_DATE} ${REV_BRANCH})"
   sed -i -e "/\s${FEED_ID}\s.*\.git$/s/$/^${REV_HASH}/" feeds.conf
   done
   ```
4. Refresh your feeds:
   
   ```
   ./scripts/feeds update -a
   ./scripts/feeds install -a
   ```

## Examples

- [https://github.com/mwarning/openwrt-examples](https://github.com/mwarning/openwrt-examples "https://github.com/mwarning/openwrt-examples")
- [https://forum.openwrt.org/viewtopic.php?pid=129319#p129319](https://forum.openwrt.org/viewtopic.php?pid=129319#p129319 "https://forum.openwrt.org/viewtopic.php?pid=129319#p129319")
- [https://forum.openwrt.org/viewtopic.php?id=28267](https://forum.openwrt.org/viewtopic.php?id=28267 "https://forum.openwrt.org/viewtopic.php?id=28267")

## Troubleshooting

- Beware of [unusual environment variables](/docs/guide-developer/toolchain/install-buildsystem#build_system_setup "docs:guide-developer:toolchain:install-buildsystem").
- First get more information on the problem using the make option `make V=sc` or enable logging.
- Read more about make options: [Buildroot Techref](/docs/techref/buildroot "docs:techref:buildroot").

#### Missing source code file, due to download problems

First check if the URL path in the make file contains a trailing slash, then if it does, try with it removed (helped several times). Otherwise try to download the source code manually and put it into `dl` directory.

#### Compilation errors

Try to update the main source and all the feeds, however beware of other potential problems. Check for related issues in the [bugtracker](/bugs "bugs"), otherwise report the problem there mentioning the package, target (CPU, image, etc.) and code revisions (main &amp; package).

Some packages may not be updated properly and built after they got stuck with old dependencies, resulting in warnings at the beginning of the compilation looking similar to:

```
WARNING: Makefile 'package/feeds/packages/openssh/Makefile' has a dependency on 'libfido2', which does not exist
```

The build environment can be recovered by uninstalling and reinstalling the failing package

```
$ ./scripts/feeds uninstall openssh
Uninstalling package 'openssh'
$ ./scripts/feeds install openssh
Installing package 'openssh' from packages
Installing package 'libfido2' from packages
Installing package 'libcbor' from packages
```

#### WARNING: skipping &lt;package&gt; -- package not selected

Run `make menuconfig` and enable compilation for your package. It should be labeled with `<*>` or `<M>` to work correctly.

#### Flashable images for my device are not generated

When you execute `make` to build a flashable image for your device, both a sysupgrade and a factory image should be generated for every board that is linked to the device profile that you have selected via `make config` or `make menuconfig`.

If running `make` does *not* yield images for one (or even all) of the boards linked to the device profile that you have selected, than you probably have selected/enabled too many options or packages, and the image was too big to be flashed onto your device.
