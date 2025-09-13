# kboot

kboot is a proof-of-concept implementation of a Linux boot loader based on [kexec](https://en.wikipedia.org/wiki/kexec "https://en.wikipedia.org/wiki/kexec"). kboot uses a boot loader like LILO or GRUB to load a regular Linux kernel as its first stage. Then, the full capabilities of the kernel can be used to locate and to access the kernel to be booted.

kboot integrates the various components needed for a fully featured boot loader, and demonstrates their use. While the main focus is on basic technical functionality, kboot can serve as a starting point for customized boot environments offering additional features. kboot 11 was released 2007-01-11.

See [http://kboot.sourceforge.net/](http://kboot.sourceforge.net/ "http://kboot.sourceforge.net/")
