# oxnas

A family of ARM-based SoCs developed by Oxford Semi, later sold to PLXTECH.

SoC cores S-ATA PCIe GigE OpenWrt support OX815SE ARM10 1 - 1 no OX815DSE ARM10 2 - 1 no OX820  
NAS7820 2x ARM11MPcore 2 1 1 yes OX821  
NAS7821 2x ARM11MPcore 2 1 1 yes NAS7825 2x ARM11MPcore 2 2 2 ?

## OX82x / NAS782x architecture overview

- 2x ARM11MPCORE (ARMv7) core
- LEON2 (SPARC v8) co-processor usable for power-management and DMA offloading tasks
- no PCIe on OX820/NAS7820, 1x PCIe on OX821/NAS7821, 2x PCIe on NAS7825
- up to 512MB DDR2 SDRAM
- NAND or SPI serial flash (128MiB NAND typically found in the wild)
- DesignWare/ST GigE core with GMII/RMGII (2x in NAS7825)
- EHCI USB 2.0 Host (USB gadget mode might be possible as well)
- OX934 single-DMA dual-port S-ATA controller (SoC supports JBOD and RAID0/1 in hardware, OpenWrt doesn't yet)
- 2x DesignWare/Synopsis S-ATA phy
- Crypto engine (?)

## History and availability

- originally developed at Oxford Semi
- Oxford Semi acquired by PLXTECH, NAS products renamed
- PLXTECH acquired by Avago, announced end-of-life for NAS products
- however, Avago got bulk-agreement with Rochester...

## Known Limitations

The OpenWrt oxnas target doesn't support all hardware features of the SoC.

- vendor's U-Boot doesn't support booting modern kernels
  
  - chain-load a recent U-Boot which does  
    This additional U-Boot stage uses UBI to load OpenWrt and stores it's environment in UBI  
    In future, it may instead be feasible to replace the stock loader, kwboot-like serial recovery yet needs to be found...
    
    - PLL and SDRAM setup is board specific and needs to be taken care of if we want that

<!--THE END-->

- S-ATA core requires host-lock for port transfers
  
  - S-ATA performance sucks when using both drivers simultanously e.g. for RAID-1  
    vendor's Linux SDK uses hardware-supported RAID and JBOD, OpenWrt doesn't (yet)  
    reference code: [https://github.com/kref/linux-oxnas/blob/reference/sdk/drivers/md/ox820hwraid.c](https://github.com/kref/linux-oxnas/blob/reference/sdk/drivers/md/ox820hwraid.c "https://github.com/kref/linux-oxnas/blob/reference/sdk/drivers/md/ox820hwraid.c")

<!--THE END-->

- no USB gadget support

<!--THE END-->

- USB 1.1 isochronous transfers are broken. As a work-around an extra USB 2.0 hub between the oxnas box and USB 1.x devices making use of isochronous transfers (e.g. USB audio interfaces) can be used.

<!--THE END-->

- Crypto engine undocumented/unsupported in all known GPL drops, no support in OpenWrt

<!--THE END-->

- LEON microcode loading not yet implemented, thus no watchdog and wake-on-lan  
  reference code: [https://github.com/kref/linux-oxnas/blob/reference/sdk/arch/arm/plat-oxnas/leon.c](https://github.com/kref/linux-oxnas/blob/reference/sdk/arch/arm/plat-oxnas/leon.c "https://github.com/kref/linux-oxnas/blob/reference/sdk/arch/arm/plat-oxnas/leon.c")  
  The GPL tarball WD-GPL-v1.18 of the Western Digital “My Book World Edition II (blue rings)” contains toolchain and sources of some LEON programs meant to be used with older oxnas SoCs. Besides the addresses, this looks very much the same as on newer SoCs.

<!--THE END-->

- no decent hddtemp-driven fancontrol for devices with fan implemented in OpenWrt  
  reference code: [https://github.com/kref/linux-oxnas/blob/reference/sdk/arch/arm/plat-oxnas/thermAndFan.c](https://github.com/kref/linux-oxnas/blob/reference/sdk/arch/arm/plat-oxnas/thermAndFan.c "https://github.com/kref/linux-oxnas/blob/reference/sdk/arch/arm/plat-oxnas/thermAndFan.c")  
  [https://github.com/kref/linux-oxnas/blob/reference/sdk/arch/arm/plat-oxnas/thermistorCalibration.h](https://github.com/kref/linux-oxnas/blob/reference/sdk/arch/arm/plat-oxnas/thermistorCalibration.h "https://github.com/kref/linux-oxnas/blob/reference/sdk/arch/arm/plat-oxnas/thermistorCalibration.h")

The Chaos Calmer 15.05 images for the Oxnas targets are missing some essential packages and kernel modules, most notably **iptables** and the **conntrack** kernel modules which are required for the firewall to work correctly. If you reconfigure the firewall or network (for example to create a WAN interface), be sure to install the respective packages beforehand.

## Supported boards/devices

k=known backdoor  
i=installer/flash image available  
h=how-to available  
s=serial access required for installation  
0=missing fdt, please get in touch if you got that board/device and want to help porting or loan or donate hardware

board name product name status wiki page stg-212 ZyXEL NSA-212 / MitraStra STG-212 / Medion ... k,h [md86587](/toh/medion/md86587 "toh:medion:md86587") pogoplug-pro Cloud Engines PogoPlug Pro (with mPCIe slot) k,s [Pogoplug Pro](/toh/cloud_engines/pogoplugpro "toh:cloud_engines:pogoplugpro") pogoplug-v3 Cloud Engines PogoPlug v3 (no PCIe) k,s [pogoplugpro](/toh/cloud_engines/pogoplugpro "toh:cloud_engines:pogoplugpro") kd20 Shuttle OMNINAS KD20 i [kd20](/toh/shuttle/kd20 "toh:shuttle:kd20") ch3hnas2 Conceptronic CH3HNAS2 0 em4172 Eminent EM4172 / Akitio MyCloud Duo 0 hmnhdce iomega Home Media Network Hard Drive Cloud Edition 0 akitio Silverstone DC01 / Akitio MyCloud mini s voyager Corsair Voyager Air 0

## Devices

The list of related devices: [ToH:oxnas](/toh/views/toh_dev_arch-target-cpu?dataflt%5BTarget_target%2A~%5D=oxnas "toh:views:toh_dev_arch-target-cpu")
