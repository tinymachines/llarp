# Building OpenWrt Kernel for Debian System

For now this page serves to keep some notes about using OpenWrt kernels with Debian distribution.

## Floating Point Unit (MIPS)

If you boot OpenWrt kernel and expects it to start init but you see a kernel panic:

`Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000004`

OpenWrt userland packages are compiled with soft-FPU instructions by default. (The floating point math is emulated by the compiler during compile time.)

Debian binaries (jessie) are compiled with hard FPU instructions. As most embedded devices do not have FPUs, it's usually necessary for the kernel to emulate them in order for these instructions to be executed correctly. Since OpenWrt makes use of soft-FPU, the FPU emulation is turned off in the kernel by default. Inability to execute FP instructions is a possible reason for the crash.

To compile the kernel with FPU emulation, in kernel configuration check that you set CONFIG\_MIPS\_FPU\_EMULATOR=y. See [Kernel configuration (optional)](/docs/guide-developer/toolchain/use-buildsystem#kernel_configuration_optional "docs:guide-developer:toolchain:use-buildsystem").

## udev

Debian uses udev to populate /dev. For udev to work, devtmpfs pseudo filesystem must be enabled. Check that CONFIG\_DEVTMPFS=y in kernel\_menuconfig and CONFIG\_KERNEL\_DEVTMPFS=y in menuconfig.

## SELinux

Debian bins (e.g. init) are compiled with SELinux support. Init will try to initialise SELinux when starting. Since SELinux is not enabled in OpenWrt kernel, init might display a failure:

`Mount failed for selinuxfs on /sys/fs/selinux: No such file or directory`

This message is safe to ignore. Basically selinux initialisation attempts to mount the selinux filesystem but fails. Init ignores this failure and carries on booting as long as you do not provide enforcing=1 in kernel cmdline.

## IKConfig

The OpenWrt system messes with the kernel .config so you might not end up with the same options you set when you run kernel\_menuconfig. If you want to know the final kernel options, look in your build\_dir (e.g. build\_dir/target-mips\_34kc\_glibc-2.19/linux-ar71xx\_mikrotik/linux-3.18.23/.config). Alternatively if you can afford a bigger kernel, set CONFIG\_IKCONFIG=y and CONFIG\_IKCONFIG\_PROC=y in kernel\_menuconfig so that the kernel .config is saved in the kernel itself.
