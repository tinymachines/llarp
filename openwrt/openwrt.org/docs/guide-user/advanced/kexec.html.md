# Configuring kexec

I have a working kexeced system on a TP-Link TL-WR741ND. After making the USB mod, and additional experimenting, I ended up with a working kexeced system.

## Prepare USB Bootable System

01. **Download sources:**
    
    ```
    svn checkout svn://svn.openwrt.org/openwrt/branches/backfire
    ```
02. **Change directory to bildroot, then update &amp; install feeds:**
    
    ```
    cd backfire && ./scripts/feeds update && ./scripts/feeds install -a
    ```
03. **Create defconfig and enter MenuConfig:**
    
    ```
    make V=s defconfig && make menuconfig
    ```
    
    1. **Select the following:**
       
       1. `Target System` → `Atheros AR71xx/AR7240/AR913x`
       2. `Target Profile` → `TP-LINK TL-WR741ND v1`
       3. `Target Images` → `ramdisk` → `Compression` → `lzma`
       4. `Target Images` → `tar.gz`
       5. `Kernel modules` → `Filesystems` →
          
          1. `kmod-fs-ext2`
          2. `kmod-fs-ext3`
       6. `Kernel modules` → `USB Support` → `kmod-usb-core`
          
          1. `kmod-usb-ohci`
          2. `kmod-usb-storage`
       7. `Utilities` → `kexec tools` → `Configuration` → `(mips) Target name for kexec kernel`
    2. **Exit from menu and save configuration**
04. ```
    make V=s
    ```
05. **Modify:**
    
    1. **`./build_dir/linux-ar71xx/linux-2.6.32.27/arch/mips/kernel/machine_kexec.c`**
       
       1. **Change Line 55 to:** `kexec_start_address = (unsigned long) phys_to_virt(image→start);`
    2. **`./build_dir/toolchain-mips_r2_gcc-4.3.3+cs_uClibc-0.9.30.1/linux-2.6.32.27/arch/mips/kernel/machine_kexec.c`**
       
       1. **Change Line 55 to:** `kexec_start_address = (unsigned long) phys_to_virt(image→start);`
    3. **For USB support:**
       
       1. **`./target/linux/ar71xx/files/arch/mips/ar71xx/Kconfig`**
          
          1. **Add new line 176** *(under `config AR71XX_MACH_TL_WR741ND`):* `select AR71XX_DEV_USB`
       2. **`./target/linux/ar71xx/files/arch/mips/ar71xx/mach-tl-wr741nd.c`**
          
          1. **Add Line 22** *(under `includes`):* `#include “dev-usb.h”`
          2. **Add line 102** *(under `static void __init tl_wr741nd_setup(void)`):* `ar71xx_add_device_usb();`
06. ```
    make kernel_menuconfig
    ```
    
    1. **Select the following:**
       
       1. `Kernel type` → `Kexec system call`
       2. `General setup` → `Support initial ramdisks compressed using LZMA`
          
          1. `Built-in initramfs compression mode` → `LZMA`
       3. `Device Drivers` → `SCSI device support` → `M SCSI device support`
          
          1. `M SCSI disk support`
          2. `Probe all LUNs on each SCSI device`
       4. `Device Drivers` → `USB support` → `M Support for Host-side USB`
          
          1. `M OHCI HCD support` → `USB OHCI support for Atheros AR71xx`
             
             1. `M USB Mass Storage support`
             2. `USB announce new devices`
       5. `Kernel hacking` → `Default kernel command string` → `rootfstype=ext2 noinitrd console=ttyS0,115200 board=TL-WR741ND`
07. **Modify: `./package/base-files/files/etc/preinit`**
    
    1. **Below `. /etc/diag.sh`, add line:** `rootfs=/dev/sda1`
    2. **Optionally you can modify: `./target/linux/generic-2.6/base-files/init`**
       
       1. **Change line 50 to:** `mount $rootfs /mnt -o noatime`
          
          - *Blocks wear out faster if written to every time a file is accessed*
08. ```
    make clean && make V=s
    ```
09. **Repeat Step 5**
    
    - *Clean operation creates issues, however it's necessary for the USB patch to work*
10. ```
    make V=s
    ```
11. **Partition external storage, then format first partition as ext2**
12. **Extract contents of `./bin/ar71xx/openwrt-ar71xx-rootfs.tar.gz` to root of file system**
13. **Copy `./bin/ar71xx/openwrt-ar71xx-vmlinux-initramfs.elf` to root of file system**

*(to be continued)*
