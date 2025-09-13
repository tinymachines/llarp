# ARMBoot

Developement haltet 2002. Was a sister project of [PPCboot](/docs/techref/bootloader/ppcboot "docs:techref:bootloader:ppcboot") which is now [U-Boot](/docs/techref/bootloader/uboot "docs:techref:bootloader:uboot"), so theres a chance that devices with arm boot could use U-Boot which seams to need way less space.

## Commands

- go - start application at address 'addr'
- run - run commands in an environment variable
- bootm - boot application image from memory
- bootp - boot image via network using BootP/TFTP protocol
- tftpboot- boot image via network using TFTP protocol and env variables ipaddr and serverip
- rarpboot- boot image via network using RARP/TFTP protocol
- bootd - boot default, i.e., run 'bootcmd'
- loads - load S-Record file over serial line
- loadb - load binary file over serial line (kermit mode)
- autoscr - run script from memory
- md - memory display
- mm - memory modify (auto-incrementing)
- nm - memory modify (constant address)
- mw - memory write (fill)
- cp - memory copy
- cmp - memory compare
- crc32 - checksum calculation
- base - print or set address offset
- printenv- print environment variables
- setspi- print environment variables
- getspi- print environment variables
- phywrite- print environment variables
- phyread- print environment variables
- dumpphy- print environment variables
- setenv - set environment variables
- saveenv - save environment variables to persistent storage
- protect - enable or disable FLASH write protection
- erase - erase FLASH memory
- flinfo - print FLASH memory information
- bdinfo - print Board Info structure
- iminfo - print header information for application image
- loop - infinite loop on address range
- mtest - simple RAM test
- reset - Perform RESET of the CPU
- echo - echo args to console
- sleep - delay execution for some time
- download - Perform bootload
- assign - Perform give the device a mac
- version - print monitor version
- help - print online help
- ? - alias for 'help'
