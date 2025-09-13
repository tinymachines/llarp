# Using the Image Builder

See also: [Image Builder frontends](/docs/guide-developer/imagebuilder_frontends "docs:guide-developer:imagebuilder_frontends"), [Using the toolchain](/docs/guide-developer/start#using_the_toolchain "docs:guide-developer:start"), [Quick image building guide](/docs/guide-developer/toolchain/beginners-build-guide "docs:guide-developer:toolchain:beginners-build-guide")

The Image Builder (previously called the Image Generator) is a pre-compiled environment suitable for creating custom images without the need for compiling them from source. It downloads pre-compiled packages and integrates them in a single flashable image.

Doing so is useful if:

- you want to fit more packages in a small flash size
- you want to follow development snapshots
- your device has 32MB or less RAM and opkg does not work properly
- you want to mass-flash dozens of devices and you need a specific firmware setup

The Image Builder images are not identical to official images as they obtain pre-generated packages. When recent/important changes are made, there can be some delay for these packages to propagate and it is best to check that packages were uploaded after the date of the imagebuilder/change.

## Prerequisites

- The Image Builder runs only in 64-bit Linux. You can however run a 64-bit Linux in PC or VM, e.g. VirtualBox, even from 32-bit Windows.
- The Image Builder has similar prerequisites as the [Build system](/docs/guide-developer/toolchain/install-buildsystem "docs:guide-developer:toolchain:install-buildsystem").

Example dependencies in the most common distros:

### Arch

```
sudo pacman -S --needed base-devel ncurses zlib gawk git gettext \
openssl libxslt wget unzip python python-distutils-extra
```

### Fedora

```
sudo dnf install git gawk gettext ncurses-devel zlib-devel \
openssl-devel libxslt wget which @c-development @development-tools \
@development-libs zlib-static which python3 perl
```

### Debian / Ubuntu / Mint

```
sudo apt install build-essential file libncurses-dev zlib1g-dev gawk git \
gettext libssl-dev xsltproc rsync wget unzip python3 python3-distutils
```

### WSL

This method is NOT officially supported.

But it works. [Build system setup WSL](/docs/guide-developer/toolchain/wsl "docs:guide-developer:toolchain:wsl")

Recommend to use VirtualBox with Debian or DietPi(Debian) for less resource and config.

## Obtaining the Image Builder

You can download an archive that contains the **Image Builder**, it is usually located in the same download page where you find the firmware image for your device.

For example, this is the page where you can download all firmware images for **ath79/generic** devices: [https://downloads.openwrt.org/snapshots/targets/ath79/generic/](https://downloads.openwrt.org/snapshots/targets/ath79/generic/ "https://downloads.openwrt.org/snapshots/targets/ath79/generic/") and you will find a **openwrt-imagebuilder-ath79-generic.Linux-x86\_64.tar.zst** archive with the image builder in it. Also, it is always created by the build system because it is needed to create the image file. If the option “**Build the OpenWrt Image Builder**” is enabled, the image builder will be generated in the same folder you find firmware images (`source/bin/targets/xxx`) and you can use it to create more images from the packages you obtained during compilation.

## Usage

All operations should be performed with a non-root user account.

Unpack the archive and change the working directory:

```
tar --zstd -xvf openwrt-imagebuilder-*.tar.zst
cd openwrt-imagebuilder-*/
```

The image building can be customized with the following variables:

Variable Description `PROFILE` Specifies the target image to build `PACKAGES` A list of packages to embed into the image `FILES` Directory with custom files to include `BIN_DIR` Alternative output directory for the images `EXTRA_IMAGE_NAME` Add this to the output image filename (sanitized) `DISABLED_SERVICES` A list of services to disable `ROOTFS_PARTSIZE` Size of root partition, in megabytes

Run `make help` to get [detailed help](/docs/guide-user/additional-software/imagebuilder#detailed_help "docs:guide-user:additional-software:imagebuilder").

### Selecting profile

The `PROFILE` variable specifies the target image to build.

```
PROFILE="profile-name"
```

Run `make info` to obtain a list of [available profiles](/docs/guide-user/additional-software/imagebuilder#available_profiles "docs:guide-user:additional-software:imagebuilder").

### Selecting packages

The `PACKAGES` variable allows to include and/or exclude packages in the firmware image. By default (empty PACKAGES variable) the Image Builder will create a minimal image with device-specific kernel and drivers, uci, ssh, switch, firewall, ppp and ipv6 support.

```
PACKAGES="pkg1 pkg2 pkg3 -pkg4 -pkg5 -pkg6"
```

The example above will include pkg1, pkg2, pkg3, and exclude pkg4, pkg5, pkg6, note the “-” before each excluded package.

You don't need to list all dependencies of the packages you need in this list, the Image Builder uses `opkg` to resolve automatically the package dependencies and install other required packages.

The list of currently installed packages on your device can be obtained with the following command:

```
echo $(opkg list-installed | sed -e "s/\s.*$//")
```

Many devices are limited in storage capacity and there is no guarantee that the build system will detect when you have added too many packages to fit into the device storage space, which may render the device unbootable if installed. If in doubt, do not go overboard. Use what you had installed on the device last as a guide or create a minimal image first, install it to the device and test what you would like to add first. Consider removing unnecessary packages to [save firmware space](/docs/guide-user/additional-software/saving_space "docs:guide-user:additional-software:saving_space").

In addition ABI versioned packages such as `libubus20191227` or similar may cause problems with image builder. You may get compile errors when these are provided as packages. To avoid issues you should omit them from image builder and let the correct versions be installed via package dependencies. The `--strip-abi` parameter can be used to export a normalized package list.

### Custom packages

If there is a custom package or ipk you would prefer to use create a `packages` directory if one does not exist and place your custom ipk within this directory.

### Custom files

The `FILES` variable allows custom configuration files to be included in images built with Image Builder. This is especially useful if you need to change the network configuration from default before flashing, or if you are preparing an image for mass-flashing many devices.

```
FILES="files"
```

The `files` directory should be placed in the Image Builder root directory where you issue the make command, otherwise specify an absolute/full path.

It is strongly recommended to use [uci-defaults](/docs/guide-developer/uci-defaults "docs:guide-developer:uci-defaults") to incrementally integrate only the required customization. This helps minimize conflicts with auto-generated settings which can change between versions.

see: [uci-default\_example](/docs/guide-user/additional-software/imagebuilder#restricting_root_access "docs:guide-user:additional-software:imagebuilder")

### Building image

After you select the appropriate profile, packages and custom files, pass it to the `make image` command.

```
make image \
PROFILE="profile-name" \
PACKAGES="pkg1 pkg2 pkg3 -pkg4 -pkg5 -pkg6" \
FILES="files" \
DISABLED_SERVICES="svc1 svc2 svc3"
```

After the make command is finished, the generated images are stored in the bin*/device-architecture* directory, just like if you were compiling them.

The built image will be found under the subdirectory `./bin/targets/<target>/generic` or look inside .`/build_dir/` for a files `*-squashfs-sysupgrade.bin` and `*-squashfs-factory.bin` (e.g. `/build_dir/target-mips_24kc_musl/linux-ar71xx_tiny/tmp/openwrt-18.06.2-ar71xx-tiny-tl-wr740n-v6-squashfs-factory.bin`)

### Cleaning up

To clean up temporary build files and generated images, use the `make clean` command.

### Examples

The following example shows:

- Creating the directory for the configuration files.
- Using `scp` to transfer `uci` configuration files from a WL500GP router to the `files/etc/config` directory.
- Generating an image for WL500GP with custom packages and `uci` configuration files.

```
mkdir -p files/etc/config
scp root@192.168.1.1:/etc/config/network files/etc/config/
scp root@192.168.1.1:/etc/config/wireless files/etc/config/
scp root@192.168.1.1:/etc/config/firewall files/etc/config/
make image \
PROFILE="wl500gp" \
PACKAGES="nano openvpn -ppp -ppp-mod-pppoe" \
FILES="files" \
DISABLED_SERVICES="dnsmasq firewall odhcpd"
```

## Troubleshooting

1. Did you run everything as a non-root user?
2. Check the logged output, are there package issues (conflicts, improper names)?
3. Check the logged output, did you exceed maximum space?
4. Check the logged output, are there other obvious errors?
5. Wait a few hours/day(s) upstream packages may be in an inconsistent state especially on master/snapshot
6. Verify you have a supported OS, prerequisites, file system and path naming

## Extras

The topics below go beyond simple usage and aimed at developers and advanced users.

### Detailed help

See also: [ImageBuilder makefile](https://github.com/openwrt/openwrt/blob/master/target/imagebuilder/files/Makefile "https://github.com/openwrt/openwrt/blob/master/target/imagebuilder/files/Makefile")

Getting detailed help:

```
# make help

Available Commands:
	help:	This help text
	info:	Show a list of available target profiles
	clean:	Remove images and temporary build files
	image:	Build an image (see below for more information).

Building images:
	By default 'make image' will create an image with the default
	target profile and package set. You can use the following parameters
	to change that:

	make image PROFILE="<profilename>" # override the default target profile
	make image PACKAGES="<pkg1> [<pkg2> [<pkg3> ...]]" # include extra packages
	make image FILES="<path>" # include extra files from <path>
	make image BIN_DIR="<path>" # alternative output directory for the images
	make image EXTRA_IMAGE_NAME="<string>" # Add this to the output image filename (sanitized)
	make image DISABLED_SERVICES="<svc1> [<svc2> [<svc3> ..]]" # Which services in /etc/init.d/ should be disabled
	make image ADD_LOCAL_KEY=1 # store locally generated signing key in built images
	make image ROOTFS_PARTSIZE="<size>" # override the default rootfs partition size in MegaBytes


Print manifest:
	List "all" packages which get installed into the image.
	You can use the following parameters:

	make manifest PROFILE="<profilename>" # override the default target profile
	make manifest PACKAGES="<pkg1> [<pkg2> [<pkg3> ...]]" # include extra packages
	make manifest STRIP_ABI=1 # remove ABI version from printed package names
```

### Available profiles

Listing available profiles:

```
# make info

Available Profiles:

Default:
    Default Profile
    Packages: kmod-usb-core kmod-usb2 kmod-usb-ohci kmod-usb-ledtrig-usbport
ai-br100:
    Aigale Ai-BR100
    Packages: kmod-usb2 kmod-usb-ohci
rp-n53:
    Asus RP-N53
    Packages:
rt-n14u:
    Asus RT-N14u
    Packages:
whr-1166d:
    Buffalo WHR-1166D
    Packages:
whr-300hp2:
    Buffalo WHR-300HP2
    Packages:
...
```

### Building the Image Builder with all packages inside

It is possible to use a buildroot to create your own Image Builder and integrate in it all packages so it will be able to generate images without downloading packages.

In the graphical configuration, select “**Build the OpenWrt Image Builder**” to build the image builder, then select **Global Build Settings → Select all packages by default**, save and exit. You can [ignore build errors](/docs/guide-developer/toolchain/use-buildsystem#ignore_build_errors "docs:guide-developer:toolchain:use-buildsystem") if you encounter unmaintained packages that fail to compile, assuming this doesn't affect kernel and core dependencies.

Don't call `make defconfig` or leave an old `.config` file in the path as `Select all packages by default` will only set the package selection to `[m]` for packages that are not already configured otherwise! `make defconfig` will set most packages to `[n]`, i.e. *do not build*.

### Adding package repositories

The Image Builder you download from the OpenWrt pages is already configured to download any non-default packages from official repositories. The package sources are configured in the `repositories.conf` file in the extracted directory. Sources are specified in *opkg* native config format. This can be either the official package repositories or custom generated repositories.

An example of the contents of the `repositories.conf` from the **openwrt-imagebuilder-18.06.0-rc2-ramips-mt7621.Linux-x86\_64.tar.xz**:

```
## Place your custom repositories here, they must match the architecture and version.
# src/gz %n http://downloads.openwrt.org/releases/18.06.0-rc2
# src custom file:///usr/src/openwrt/bin/ramips/packages
 
## Remote package repositories
src/gz openwrt_core http://downloads.openwrt.org/releases/18.06.0-rc2/targets/ramips/mt7621/packages
src/gz openwrt_base http://downloads.openwrt.org/releases/18.06.0-rc2/packages/mipsel_24kc/base
src/gz openwrt_luci http://downloads.openwrt.org/releases/18.06.0-rc2/packages/mipsel_24kc/luci
src/gz openwrt_packages http://downloads.openwrt.org/releases/18.06.0-rc2/packages/mipsel_24kc/packages
src/gz openwrt_routing http://downloads.openwrt.org/releases/18.06.0-rc2/packages/mipsel_24kc/routing
src/gz openwrt_telephony http://downloads.openwrt.org/releases/18.06.0-rc2/packages/mipsel_24kc/telephony
 
## This is the local package repository, do not remove!
src imagebuilder file:packages
```

The `repositories.conf` in an imagebuilder you compile from source will lack the “Remote package repositories” links.

If you want to add a custom local repository, copy the `src custom file:///usr/src/openwrt/bin/ramips/packages` line and modify it to point to the local folder where you have your packages and package lists ([example package list](https://downloads.openwrt.org/releases/21.02.3/targets/ramips/mt7621/packages/Packages "https://downloads.openwrt.org/releases/21.02.3/targets/ramips/mt7621/packages/Packages")). If you have problems with using you local repository because the “Signature check failed” then remove the line `option check_signature` from `repositories.conf`

If you have custom repositories online, copy and modify the `src/gz reboot http://downloads.openwrt.org/snapshots` line instead.

NOTE: if you want to override packages coming from an existing feed, you must write your custom feed ABOVE the line of the package feed containing the packages you want to override, as shown in the examples above.

### Restricting root access

Create a non-privileged admin user and lock root password. Configure privilege elevation with sudo. Set up key-based authentication and disable password authentication for Dropbear.

```
mkdir -p files/etc/uci-defaults
cat << "EOF" > files/etc/uci-defaults/99-custom
USER_NAME="admin"
USER_SSHPUB="SSH_PUBLIC_KEY"
USER_SHELL="/bin/ash"
SUDO_USER="root"
SUDO_GROUP="sudo"
groupadd -r "${SUDO_GROUP}"
useradd -m -G "${SUDO_GROUP}" -s "${USER_SHELL}" "${USER_NAME}"
passwd -l "${SUDO_USER}"
cat << EOI > /etc/sudoers.d/00-custom
%${SUDO_GROUP} ALL=(ALL) ALL
EOI
USER_HOME="$(eval echo ~"${USER_NAME}")"
mkdir -p "${USER_HOME}"/.ssh
cat << EOI > "${USER_HOME}"/.ssh/authorized_keys
${USER_SSHPUB}
EOI
uci set dropbear.@dropbear[0].PasswordAuth="0"
uci set dropbear.@dropbear[0].RootPasswordAuth="0"
uci commit dropbear
/etc/init.d/dropbear restart
EOF
make image \
FILES="files" \
PACKAGES="nano shadow sudo"
```

### Adding/modifying profiles

Examples below may contain version dependent / legacy information and are for informational purposes. They are very low level so expect to have a good level of skill and familiarity with the ImageBuilder / OpenWrt in general.

The image building is tied to the profile names. If you add a new profile without also adding an appropriate macro to the image-generation Makefile, no suitable firmware file will get generated when using the custom profile. Remove the `/tmp` directory to properly apply the modified package selection from profiles.

The location of the profiles for the pre-compiled package for *brcm47xx-for-Linux-i686* was *target/linux/brcm47xx/profiles*/

Remarkably, all that needs to be done to add a new profile, is to add a new file to the *profiles* directory. *While this may have been the case in earlier releases, for 17.01, it appears that manual editing of `.targetinfo` is also required.*

Here is what the *profiles/100-Broadcom-b43.mk* profile file looks like:

```
define Profile/Broadcom-b43
	NAME:=Broadcom BCM43xx WiFi (default)
	PACKAGES:=kmod-b43 kmod-b43legacy
endef
 
define Profile/Broadcom-b43/Description
	Package set compatible with hardware using Broadcom BCM43xx cards
endef
$(eval $(call Profile,Broadcom-b43))
```

Alternately edit the hidden .profile.mk file at the top level directory of the image builder and manually add the names of the desired packages to be added to the output image. An “ls -a” will reveal the files hidden in the various directories.

### Removing useless files from firmware

This is not a standard feature of the Image Builder.

It is highly recommended that you test file removal prior to incorporating such changes at the image builder level or that you have low level means to recover a device before attempting this type of mod, as bricking / non booting may result.

Note that it requires patching of the `Makefile`

It is based on older Chaos Calmer era code... and not applicable to modern ImageBuilders but useful as a reference...

Create file `files_remove` with full filenames:

```
/lib/modules/3.10.49/ts_bm.ko
/lib/modules/3.10.49/nf_nat_ftp.ko
/lib/modules/3.10.49/nf_nat_irc.ko
/lib/modules/3.10.49/nf_nat_tftp.ko
```

Patch Makefile:

```
 ifneq ($(USER_FILES),)
 	$(MAKE) copy_files
 endif
+
+ifneq ($(FILES_REMOVE),)
+	@echo
+	@echo Remove useless files
+
+	while read filename; do \
+	    rm -rfv "$(TARGET_DIR)$$filename"; \
+	done < $(FILES_REMOVE);
+endif
+
 	$(MAKE) package_postinst
 	$(MAKE) build_image
```

Rebuild firmware:

```
make image \
PROFILE="tlwr841" \
PACKAGES="igmpproxy ip iptraf kmod-ipt-nathelper-extra openvpn-polarssl tcpdump-mini -firewall -ip6tables -kmod-ip6tables -kmod-ipv6 -odhcp6c -ppp -ppp-mod-pppoe" \
FILES_REMOVE="files_remove"
```
