# arm\_arm1176jzf-s\_vfp

The ARM1176JZF-S processor incorporates an integer core that implements the ARM11 ARM architecture v6. It supports the ARM and Thumb ™ instruction sets, Jazelle technology to enable direct execution of Java bytecodes, and a range of SIMD DSP instructions that operate on 16-bit or 8-bit data values in 32-bit registers.  
The ARM1176JZF-S processor features:

- TrustZone ™ security extensions
- provision for Intelligent Energy Management (IEM ™ )
- high-speed Advanced Microprocessor Bus Architecture (AMBA) Advanced Extensible Interface (AXI) level two interfaces supporting prioritized multiprocessor implementations.
- an integer core with integral EmbeddedICE-RT logic
- an eight-stage pipeline
- branch prediction with return stack
- low interrupt latency configuration
- internal coprocessors CP14 and CP15
- Vector Floating-Point (VFP) coprocessor support
- external coprocessor interface
- Instruction and Data Memory Management Units (MMUs), managed using MicroTLB structures backed by a unified Main TLB
- Instruction and data caches, including a non-blocking data cache with Hit-Under-Miss (HUM)
- virtually indexed and physically addressed caches
- 64-bit interface to both caches
- level one Tightly-Coupled Memory (TCM) that you can use as a local RAM with DMA
- trace support
- JTAG-based debug.

**Note** The only functional difference between the ARM1176JZ-S and ARM1176JZF-S processor is that the ARM1176JZF-S processor includes a Vector Floating-Point (VFP) coprocessor.

The ARM1176JZF-S processor provides support for extensions to ARMv6 that include:

- Store and Load Exclusive instructions for bytes, halfwords and doublewords and a new Clear Exclusive instruction.
- A true no-operation instruction and yield instruction.
- Architectural remap registers.
- Cache size restriction through CP15 c1. You can restrict cache size to 16KB for Operating Systems (OSs) that do not support page coloring.
- Revised use of TEX remap bits. The ARMv6 MMU page table descriptors use a large number of bits to describe all of the options for inner and outer cachability. In reality, it is believed that no application requires all of these options simultaneously. Therefore, it is possible to configure the ARM1176JZF-S processor to support only a small number of options by means of the TEX remap mechanism. This implies a level of indirection in the page table mappings. The TEX CB encoding table provides two OS managed page table bits. For binary compatibility with existing ARMv6 ports of OSs, this gives a separate mode of operation of the MMU. This is called the TEX Remap configuration and is controlled by bit \[28] TR in CP15 Register 1.
- Revised use of AP bits. In the ARM1176JZF -S processor the APX and AP\[1:0] encoding b111 is Privileged or User mode read only access. AP\[0] indicates an abort type, Access Bit fault, when CP15 c1\[29] is 1

[source (the Technical Reference Manual)](http://infocenter.arm.com/help/topic/com.arm.doc.ddi0301h/DDI0301H_arm1176jzfs_r0p7_trm.pdf "http://infocenter.arm.com/help/topic/com.arm.doc.ddi0301h/DDI0301H_arm1176jzfs_r0p7_trm.pdf")

## Download Packages

HTTP [https://downloads.openwrt.org/snapshots/packages/arm\_arm1176jzf-s\_vfp/](https://downloads.openwrt.org/snapshots/packages/arm_arm1176jzf-s_vfp/ "https://downloads.openwrt.org/snapshots/packages/arm_arm1176jzf-s_vfp/") FTP [ftp://ftp.halifax.rwth-aachen.de/lede/releases/packages-18.06/arm\_arm1176jzf-s\_vfp/](ftp://ftp.halifax.rwth-aachen.de/lede/releases/packages-18.06/arm_arm1176jzf-s_vfp/ "ftp://ftp.halifax.rwth-aachen.de/lede/releases/packages-18.06/arm_arm1176jzf-s_vfp/")

See [Mirrors](/downloads#mirrors "downloads") for more download sites.

## Devices with this instructionset
