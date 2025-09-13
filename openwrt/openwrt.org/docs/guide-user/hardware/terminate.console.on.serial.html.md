# Terminate UART Console

- **Related Documentation:**
  
  - [Serial Console](/docs/techref/hardware/port.serial "docs:techref:hardware:port.serial")
  - [Cannot Disable Serial Console on AR71xx](https://dev.openwrt.org/ticket/11243 "https://dev.openwrt.org/ticket/11243")
  - [Debugging Techniques](http://web.cecs.pdx.edu/~jrb/ui/linux/driver4.txt "http://web.cecs.pdx.edu/~jrb/ui/linux/driver4.txt")
  - [Monitoring Session - Using Basic Linux Utility Programs](https://www.networksecuritytoolkit.org/nst/docs/user/ch11s02.html "https://www.networksecuritytoolkit.org/nst/docs/user/ch11s02.html")
- **Forum Discussion:**
  
  - [Disable UART Console (without recompiling the patched firmware)](https://forum.openwrt.org/viewtopic.php?id=47723 "https://forum.openwrt.org/viewtopic.php?id=47723")

## w/o Kernel Rebuild

If needing to utilize the terminal for RAW data/Modem data, reconfigure `/dev/tty` via the [**coreutils-stty**](/packages/pkgdata/coreutils-stty "packages:pkgdata:coreutils-stty") module.

1. **Add** `kernel.printk = 0 4 1 7` **to** `/etc/sysctl.d/`**:**
   
   ```
    echo "kernel.printk = 0 4 1 7" > /etc/sysctl.d/10-printk.conf
   ```
2. **Edit** `/etc/inittab`**:**
   
   1. Comment out lines starting with `ttyS0:*`, `ttyATH0:*` and `::askconsole:*`
      
      ```
      sed -i -r -e "s/^((ttyS0|ttyATH0|::askconsole):.*)/#\0/" /etc/inittab
      ```
3. **Reboot**

## With Kernel Rebuild

1. **Modify Kernel config in** `<buildroot>/target/linux/ar71xx/config-`*`x.xx`:* ( *`x.xx`* = kernel version)
   
   1. **Terminates Kernel console output early:**
      
      1. Add `CONFIG_MESSAGE_LOGLEVEL_DEFAULT=0`
   2. **Terminates Kernel console output later in boot process:**
      
      1. Add `loglevel=0` to `CONFIG_CMDLINE=“rootfstype=squashfs,jffs2 noinitrd”`
         
         ```
         sed -i -r -e 's/(CONFIG_CMDLINE=".*)(")/\1 loglevel=0\2/' target/linux/ar71xx/config-x.xx
         ```
2. **Recompile Kernel:**
   
   ```
   make target/linux/{clean,prepare} V=s QUILT=1 && make V=s
   ```
3. **Flash recompiled image**
