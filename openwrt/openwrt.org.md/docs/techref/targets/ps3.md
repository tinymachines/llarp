# ps3

- Sony PS3 Game Console

## Status

- Stable, [unmaintained](https://git.openwrt.org/?p=openwrt%2Fopenwrt.git%3Ba%3Dcommit%3Bh%3D979bc5536dd4960748cc7a96426abdc8ace15131 "https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=979bc5536dd4960748cc7a96426abdc8ace15131").
- Can be build with the petitboot package to create a PS3 bootloader.

## Contact

- mailto:geoff-at-infradead.org
- [http://www.kernel.org/pub/linux/kernel/people/geoff/cell/](http://www.kernel.org/pub/linux/kernel/people/geoff/cell/ "http://www.kernel.org/pub/linux/kernel/people/geoff/cell/")

## Notes

```
OpenWrt on the Sony PS3 Game Console

The OpenWrt build will create both a 1st stage PS3-Linux image
suitable for programming into the PS3 flash memory, and a 2nd
stage PS3-Linux image suitable for loading via bootloaders or
the kexec utility.

The 2nd stage image is convenient for testing new builds.  It can
be loaded from disk, USB device, or the network by an existing
Other OS bootloader.  After the 2nd stage image is tested and
found to be good, the 1st stage image can then be programmed into
flash memory.  It is recommended to use this method during
development to avoid corrupting the flash memory contents, which
requires a reboot to the Game OS to repair.

Known good Other OS bootloader images and installation information
can be found here:

  http://www.kernel.org/pub/linux/kernel/people/geoff/cell/

The 2nd stage image file is bin/openwrt-ps3-vmlinux.elf.  It can
be loaded with an entry in the bootloader config file.  It has
no initrd file.

The 1st stage image is named bin/otheros.bld.  It can be programmed
into flash memory either from Linux or the Game OS.  From Linux,
use the command:

  ps3-flash-util -w otheros.bld

From the Game OS, use the menu item 'Install Other OS'.

Tips on how to recover your PS3-Linux system when it hangs up or no
longer boots can be found here:

  http://www.kernel.org/pub/linux/kernel/people/geoff/cell/ps3-howto/ps3-boot-recovery-howto.txt

To alter the kernel command line options, run 'make kernel_menuconfig'
and go to 'Kernel Options' -> 'Initial kernel command string'.

The default video behavior is to autodetect the monitor capabilities,
which should work for most monitors.  More info on video modes can be
found in the man page of the ps3-video-mode utility.
```

```
Petitboot - kexec based bootloader

Petitboot is a kexec based bootloader.  It supports graphical
and command-line front-ends.  The command-line front-end
can be used over telnet.  Petitboot can load kernel images
and initrd files from any mountable linux device, plus can
load from the network using TFTP, NFS, HTTP, HTTPS, and SCP.
```

- [Latest git commits for this target](https://git.lede-project.org/?p=source.git&a=search&h=HEAD&st=commit&s=ps3%3A "https://git.lede-project.org/?p=source.git&a=search&h=HEAD&st=commit&s=ps3:")
- Link to [Image builders](/docs/guide-user/additional-software/imagebuilder "docs:guide-user:additional-software:imagebuilder") for each target/subtarget

## Devices with this target

Show devices with this target

Hide devices with this target

[Filter: Subtarget](#folded_98aaf27ed33a88a79f694c97caeaabb2_1)

[Filter: Package architecture](#folded_98aaf27ed33a88a79f694c97caeaabb2_2)
