# mips64el\_mips64

Imagination’s MIPS64 architecture has been used in a variety of applications including game consoles, office automation and set-top boxes, and maintains popularity today in networking and telecommunications infrastructure applications. As design complexity and software footprints increase, the benefits of 64-bit computing become attractive to a broader set of applications including servers, next generation mobile and connected consumer devices and SOHO networking products.

The MIPS64® architecture provides a solid high-performance foundation for future MIPS processor-based development by incorporating powerful features, standardizing privileged mode instructions, supporting past ISAs, and providing a seamless upgrade path from the MIPS32 architecture.

The MIPS32 and MIPS64 architectures incorporate important functionality including SIMD (Single Instruction Multiple Data) and virtualization. These technologies, in conjunction with technologies such as multi-threading (MT), DSP extensions and EVA (Enhanced Virtual Addressing), enrich the architecture for use with modern software workloads which require larger memory sizes, increased computational horsepower and secure execution environments.

The MIPS64 architecture is based on a fixed-length, regularly encoded instruction set, and it uses a load/store data model. It is streamlined to support optimized execution of high-level languages. Arithmetic and logic operations use a three-operand format, allowing compilers to optimize complex expressions formulation. Availability of 32 general-purpose registers enables compilers to further optimize code generation by keeping frequently accessed data in registers.

By providing backward compatibility, standardizing privileged mode, and memory management and providing the information through the configuration registers, the MIPS64 architecture enables real-time operating systems and application code to be implemented once and reused with future members of both the MIPS32 and the MIPS64 processor families.

**High-Perfomance Caches**  
Flexibility of high-performance caches and memory management schemes are strengths of the MIPS architecture. The MIPS64 architecture extends these advantages with well-defined cache control options. The size of the instruction and data caches can range from 256 bytes to 4 MB. The data cache can employ either a write-back or write-through policy. A no-cache option can also be specified. The memory management mechanism can employ either a TLB or a Block Address Translation (BAT) policy. With a TLB, the MIPS64 architecture meets the memory management requirements of Linux, Android™, Windows® CE and other historically popular operating systems.

The addition of data streaming and predicated operations supports the increasing computation needs of the embedded market. Conditional data move and data prefetch instructions are standardized, allowing for improved system-level data throughput in communication and multimedia applications.

**Fixed-Point DSP-Type Instructions**  
Fixed-point DSP-type instructions further enhance multimedia processing. These instructions that include Multiply (MUL), Multiply and Add (MADD), Multiply and Subtract (MSUB), and “count leading 0s/1s,” previously available only on some 64-bit MIPS processors, provide greater performance in processing data streams such as audio, video, and multimedia without adding additional DSP hardware to the system.

**Powerful 64-bit Floating-Point Registers**  
Powerful 64-bit floating-point registers and execution units speed the tasks of processing some DSP algorithms and calculating graphics operations in real-time. Paired-single instructions pack two 32-bit floating-point operands into a single 64-bit register, allowing Single Instruction Multiple Data operations (SIMD). This provides twice as fast execution compared to traditional 32-bit floating-point units. Floating point operations can optionally be emulated in software.

**Addressing Modes**  
The MIPS64 architecture features both 32-bit and 64-bit addressing modes, while working with 64-bit data. This allows reaping the benefits of 64-bit data without the extra memory needed for 64-bit addressing. In order to allow easy migration from the 32-bit family, the architecture features a 32-bit compatibility mode, in which all registers and addresses are 32-bit wide and all instructions present in the MIPS32 architecture are executed.

[source](https://imgtec.com/mips/architectures/mips64/ "https://imgtec.com/mips/architectures/mips64/")

## Download Packages

HTTP [https://downloads.openwrt.org/releases/packages-18.06/mips64el\_mips64/](https://downloads.openwrt.org/releases/packages-18.06/mips64el_mips64/ "https://downloads.openwrt.org/releases/packages-18.06/mips64el_mips64/") FTP [ftp://ftp.halifax.rwth-aachen.de/lede/releases/packages-18.06/mips64el\_mips64/](ftp://ftp.halifax.rwth-aachen.de/lede/releases/packages-18.06/mips64el_mips64/ "ftp://ftp.halifax.rwth-aachen.de/lede/releases/packages-18.06/mips64el_mips64/")

See [Mirrors](/downloads#mirrors "downloads") for more download sites.

## Devices with this instructionset
