# arm\_cortex-a9\_vfpv3-d16

Due to early mvebu target SoC's (Armada XP, 370, etc...) not supporting NEON or full vFPV3-d32 instructions, all Arm A9 mvebu targets are compiled to support the lower function set in order to limit the number of OpenWrt project supported targets. The NEON instructions of this architecture would have run on the same registers, so the end performance impact mainly stems from the 16 enabled FP registers vs the 32 that some of the SoC's have on-board.

See closed GIT issue for further information: [FS#867 - mvebu: Should be split different arches, current (Armada 370, XP and other "legacy") and 385+](https://github.com/openwrt/openwrt/issues/5801 "https://github.com/openwrt/openwrt/issues/5801")

The ARM® Cortex®-A9 processor is a popular general purpose choice for low-power or thermally constrained, cost-sensitive 32-bit devices.

The Cortex-A9 processor is proven in a wide range of devices and is one of ARM's most widely deployed and mature applications processors. Cortex-A9 processor offers an overall performance enhancement over 25% higher than Cortex-A8 per core, plus the ability to implement multi-core designs that further scale the performance increase.

The Cortex-A9 implements the widely supported ARMv7-A architecture with an efficient microarchitecture:

- High-efficiency, dual-issue superscalar, out-of-order, dynamic length pipeline (8 – 11 stages)
- Highly configurable L1 caches, and optional NEON and Floating-point extensions
- Available as a Single processor configuration, or a scalable multi-core configuration with up to 4 coherent cores

For the most high-end 32-bit devices, Cortex-A17 delivers more performance and efficiency in a similar footprint than it’s predecessor, the Cortex-A9. They are based of a similar pipeline, with Cortex-A17 extending the capabilities in single thread performance and adding big.LITTLE support and virtualization that were not in the original Cortex-A9 offering.

[source](http://www.arm.com/products/processors/cortex-a/cortex-a9.php "http://www.arm.com/products/processors/cortex-a/cortex-a9.php")

This architecture is for mvebu target cortex a9 processors.

## Download Packages

HTTP [https://downloads.openwrt.org/snapshots/packages/arm\_cortex-a9\_vfpv3-d16/](https://downloads.openwrt.org/snapshots/packages/arm_cortex-a9_vfpv3-d16/ "https://downloads.openwrt.org/snapshots/packages/arm_cortex-a9_vfpv3-d16/") FTP [ftp://ftp.halifax.rwth-aachen.de/lede/snapshots/packages/arm\_cortex-a9\_vfpv3-d16/](ftp://ftp.halifax.rwth-aachen.de/lede/snapshots/packages/arm_cortex-a9_vfpv3-d16/ "ftp://ftp.halifax.rwth-aachen.de/lede/snapshots/packages/arm_cortex-a9_vfpv3-d16/")

See [Mirrors](/downloads#mirrors "downloads") for more download sites.

## Devices with this instructionset
