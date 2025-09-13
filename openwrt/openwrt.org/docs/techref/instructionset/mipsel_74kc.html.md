# mipsel\_74kc

mipsel\_74kc stands for

- mips: [The official MIPS company](https://www.mips.com/ "https://www.mips.com/")
- el: [endian little (little-endian)](https://www.linux-mips.org/wiki/Endianness "https://www.linux-mips.org/wiki/Endianness")
- 74kc: The 74Kc/f incorporates the MIPS® DSP Module Rev2 for enhanced signal processing capabilities. The 74Kc/f includes an OCP Bus Interface Unit and connection to an optional L2 cache controller and delivers a performance of 1.93 DMIPS/MHz and 3.48 Coremarks/MHz. The core also includes an IEEE754 compliant Floating Point Unit, supporting both single and double precision datatypes. [Source](https://www.mips.com/products/classic/ "https://www.mips.com/products/classic/")

## Description

The MIPS32® 74Kc™ core from MIPS Technologies is a high-performance, low-power, 32-bit RISC Superscalar core designed for custom system-on-chip (SoC) applications. The core is designed for semiconductor manufacturing companies, ASIC developers, and system OEMs who want to rapidly integrate their own custom logic and peripherals with a high-performance RISC processor. Fully synthesizable and highly portable across processes, it can be eas- ily integrated into full SoC designs, allowing developers to focus their attention on end-user products.

The 74Kc core implements the MIPS32 Release 2 Architecture in a superscalar, out-of-order execution pipeline. The deeply pipelined core can support a peak issue and graduation rate of 2 instructions per cycle. The 74Kc core also implements the MIPS DSP ASE - Revision 2.0, which provides support for signal processing instructions, and includes support for the MIPS16e™ ASE and the 32-bit privileged resource architecture. This architecture is supported by a wide range of industry-standard tools and development systems.  
The 74Kc core has a Level-1 (L1) Instruction Cache, which is configurable at 0, 16, 32, or 64 KB in size. It is organized as 4-way set associative. Up to four instruction cache misses can be outstanding. The instruction cache is virtually indexed and physically tagged to make the data access independent of virtual to physical address translation. Instruction cache tag and data access are staggered across 2 cycles, with up to 4 instructions fetched per cycle. The superscalar 74Kc core can dispatch up to 2 instructions per cycle into one of the arithmetic-logic unit (ALU) or address generation (AGEN) pipes. The AGEN pipe executes all Load/Store and Control Transfer instructions while the ALU pipe executes all other instructions. Instructions are issued and executed out-of-order; however, the results are buffered and the architectural state of up to 2 instructions per cycle is updated in program order.

The L1 Data Cache is configurable at 0, 16, 32, or 64 KB in size. It is organized as 4-way set associative. Data cache misses are non-blocking and up to four may be outstanding. The data cache is virtually indexed and physically tagged to make the data access independent of virtual-to-physical address translation. The tag array also has a virtual address portion, which is used to compare against the virtual address being accessed and generate a data cache hit prediction. This virtual address hit prediction is always backed up by a comparison of the translated physical address against the physical tag. To achieve high frequencies while using commercially available SRAM generators, the cache access and hit determination is spread across three pipeline stages, dedicating an entire cycle for the SRAM access.  
The synthesizable 74Kc core includes a high performance Multiply/Divide Unit (MDU). The MDU is fully pipelined to support a single cycle repeat rate for MAC instructions. The CorExtend® block can utilize the accumulator registers in the MDU block, allowing specialized functions to be efficiently implemented.

The MIPS DSP ASE - Revision 2.0 provides support for a number of powerful data processing operations. There are instructions for fractional arithmetic (Q15/Q31) and for saturating arithmetic. Additionally, for smaller data sizes, SIMD operations are supported, allowing 2 × 16 bit or 4 × 8 bit operations to occur simultaneously. Another feature of the ASE is the inclusion of additional HI/LO accumulator registers to improve the parallelization of independent accumulation routines. All 32-bit operand arithmetic DSP instructions (except multiply) are executed in the ALU pipe while the 64-bit operand arithmetic and multiply class DSP instructions are executed in the MDU pipe.  
The Bus Interface Unit (BIU) implements the Open Core Protocol (OCP), which has been developed to address the needs of SoC designers. This implementation features 64-bit read and write data buses to efficiently transfer data to and from the L1 caches. The BIU also supports a variety of core/bus clock ratios to give greater flexibility for system design implementations.

Optional support for external Instruction and Data Scratchpad RAM arrays, with reference design supporting DMA interfaces for loading the arrays. An Enhanced JTAG (EJTAG) block allows for software debugging of the processor, and includes a TAP controller as well as optional instruction and data virtual address/value breakpoints. Additionally, real-time tracing of instruction program counter, data address and data values can be supported.

[source (Processor Core Datasheet)](https://people.freebsd.org/~adrian/mips/MD00496-2B-74KC-DTS-01.07.pdf "https://people.freebsd.org/~adrian/mips/MD00496-2B-74KC-DTS-01.07.pdf")

## Download Packages

HTTP [https://downloads.openwrt.org/releases/packages-18.06/mipsel\_74kc/](https://downloads.openwrt.org/releases/packages-18.06/mipsel_74kc/ "https://downloads.openwrt.org/releases/packages-18.06/mipsel_74kc/") FTP [ftp://ftp.halifax.rwth-aachen.de/lede/releases/packages-18.06/mipsel\_74kc/](ftp://ftp.halifax.rwth-aachen.de/lede/releases/packages-18.06/mipsel_74kc/ "ftp://ftp.halifax.rwth-aachen.de/lede/releases/packages-18.06/mipsel_74kc/")

See [Mirrors](/downloads#mirrors "downloads") for more download sites.

## Devices with this instructionset
