# The CPU (Intellectual property core)

## CPU classification

When looking at the usual [Central processing unit](https://en.wikipedia.org/wiki/Central%20processing%20unit "https://en.wikipedia.org/wiki/Central processing unit") a couple of things come into mind:

1. its [**Instruction set**](https://en.wikipedia.org/wiki/Instruction%20set "https://en.wikipedia.org/wiki/Instruction set") (jump directly to a [List of instruction sets](https://en.wikipedia.org/wiki/List%20of%20instruction%20sets "https://en.wikipedia.org/wiki/List of instruction sets")) and then see [**OpenWrt Buildroot - Supported ARCHes**](https://dev.openwrt.org/browser/trunk/target/Config.in "https://dev.openwrt.org/browser/trunk/target/Config.in")
2. [**Extensions**](https://en.wikipedia.org/wiki/Template:Multimedia%20extensions "https://en.wikipedia.org/wiki/Template:Multimedia extensions") to the Instruction Set, e.g. [MMX](https://en.wikipedia.org/wiki/MMX%20%28instruction%20set%29 "https://en.wikipedia.org/wiki/MMX (instruction set)") or [AVX](https://en.wikipedia.org/wiki/Advanced%20Vector%20Extensions "https://en.wikipedia.org/wiki/Advanced Vector Extensions") or [AES-NI](https://en.wikipedia.org/wiki/AES-NI "https://en.wikipedia.org/wiki/AES-NI"))
3. and its [design](https://en.wikipedia.org/wiki/CPU%20design "https://en.wikipedia.org/wiki/CPU design") manifesting into a concrete [**Microarchitecture**](https://en.wikipedia.org/wiki/Microarchitecture "https://en.wikipedia.org/wiki/Microarchitecture") (e.g. [Core2](https://en.wikipedia.org/wiki/Intel%20Core%20%28microarchitecture%29 "https://en.wikipedia.org/wiki/Intel Core (microarchitecture)") or [NetBurst](https://en.wikipedia.org/wiki/NetBurst%20%28microarchitecture%29 "https://en.wikipedia.org/wiki/NetBurst (microarchitecture)") or [AMD\_K5](https://en.wikipedia.org/wiki/AMD_K5 "https://en.wikipedia.org/wiki/AMD_K5"))
4. concrete CPUs designed conforming to the same microarchitecture further differentiate from one another in the Frequency and Cache sizes

Examples:

- x86 is one distinct ISA and the i386SX was one distinct microarchitecture, and the i486DX2 another one, and the Cyrix
- ARMv5 is one distinct ISA and the ARM926EJ-S is one distinct microarchitecture based upon it
- MIPS32 is one distinct ISA and the MIPS 24K, 34K or the 74K are all based upon it.

You could also look at the type of Processor:

- common processor with [Arithmetic logic unit](https://en.wikipedia.org/wiki/Arithmetic%20logic%20unit "https://en.wikipedia.org/wiki/Arithmetic logic unit") [Memory management unit](https://en.wikipedia.org/wiki/Memory%20management%20unit "https://en.wikipedia.org/wiki/Memory management unit") and [Floating-point unit](https://en.wikipedia.org/wiki/Floating-point%20unit "https://en.wikipedia.org/wiki/Floating-point unit").
- [Digital signal processor](https://en.wikipedia.org/wiki/Digital%20signal%20processor "https://en.wikipedia.org/wiki/Digital signal processor")
- what once was a distinct chip [Graphics processing unit](https://en.wikipedia.org/wiki/Graphics%20processing%20unit "https://en.wikipedia.org/wiki/Graphics processing unit") is now merely an [SIMD Engine Array](http://pics.computerbase.de/3/7/8/1/8/1_m.jpg "http://pics.computerbase.de/3/7/8/1/8/1_m.jpg")

## Semiconductor companies

- There are fabless companies who do only CPU design (e.g. [ARM Holdings](https://en.wikipedia.org/wiki/ARM%20Holdings "https://en.wikipedia.org/wiki/ARM Holdings"), [Imagination Technologies](https://en.wikipedia.org/wiki/Imagination%20Technologies "https://en.wikipedia.org/wiki/Imagination Technologies"), [Nvidia](https://en.wikipedia.org/wiki/Nvidia "https://en.wikipedia.org/wiki/Nvidia"), and [Advanced Micro Devices](https://en.wikipedia.org/wiki/Advanced%20Micro%20Devices "https://en.wikipedia.org/wiki/Advanced Micro Devices"))
- and there are companies who own and operate Chip foundries (e.g. [Taiwan Semiconductor Manufacturing Company](https://en.wikipedia.org/wiki/Taiwan%20Semiconductor%20Manufacturing%20Company "https://en.wikipedia.org/wiki/Taiwan Semiconductor Manufacturing Company"), [GlobalFoundries](https://en.wikipedia.org/wiki/GlobalFoundries "https://en.wikipedia.org/wiki/GlobalFoundries"), [Samsung](https://en.wikipedia.org/wiki/Samsung "https://en.wikipedia.org/wiki/Samsung"), etc.).
- And then there is the [Intel Corporation](https://en.wikipedia.org/wiki/Intel%20Corporation "https://en.wikipedia.org/wiki/Intel Corporation"), who still does both.

## CPU purchase

When you want to purchase a CPU (or a couple of thousand) you have three choices:

- buy hardware, a Chip, which is a [Die (integrated circuit)](https://en.wikipedia.org/wiki/Die%20%28integrated%20circuit%29 "https://en.wikipedia.org/wiki/Die (integrated circuit)") on a/bonded to a [Chip carrier](https://en.wikipedia.org/wiki/Chip%20carrier "https://en.wikipedia.org/wiki/Chip carrier")
- buy Hard IP
- buy Soft IP

To understand the difference between Hard IP and Soft IP you have to get a grasp of the processes of designing and of manufacturing of IC.

## Explanation

### The ISA (Instruction set architecture)

Without going into detail you could say, the ISA is the whole of commands (absolute instructions/machine code instruction) the programmer/compiler can see and use. If you program in assembler (or write machine code), you will have to know these instructions. If you program in a higher language, the compiler (or the cross-compiler) will take care of this for you. It will translate your source code into machine code for the ISA (in compiler surroundings abbreviated ARCH for architecture) specified.

When you “cross compile” it means that you compile the source code on a machine that has a different ISA than that of the target machine you will run the compiled code on. For this the compiler needs to know the ISA for your target ARCH (architecture). Follow this link to learn how to [cross compile](/docs/guide-developer/toolchain/crosscompile "docs:guide-developer:toolchain:crosscompile"). For more information on ISA, see the white paper at: [Instruction set](https://en.wikipedia.org/wiki/Instruction_set_architecture "https://en.wikipedia.org/wiki/Instruction_set_architecture").

Designing an Instruction Set is more just saying “I want to use these instructions”. The underlying logic of how data goes in/out and how it is manipulated when instructions are processed, this has to be designed as well. How all of this can be implemented in a physical [Integrated Circuit](https://en.wikipedia.org/wiki/Integrated%20Circuit "https://en.wikipedia.org/wiki/Integrated Circuit") (IC or simply Chip) has to be designed too. Some stages of this overall design are often covered by patents or other Intellectual Property protections. Some CPU design companies exist only to create and license their designs to others who will integrate them into their own physical devices.

- see [Calling convention](https://en.wikipedia.org/wiki/Calling%20convention "https://en.wikipedia.org/wiki/Calling convention")
- see [Opcode](https://en.wikipedia.org/wiki/Opcode "https://en.wikipedia.org/wiki/Opcode")

#### Example: MIPS

You can find a distinct Wiki for GNU/Linux and the MIPS instruction set here: [http://www.linux-mips.org/wiki/Main\_Page](http://www.linux-mips.org/wiki/Main_Page "http://www.linux-mips.org/wiki/Main_Page").

MIPS (Microprocessor without Interlocked Pipeline Stages) is a instruction set architecture (ISA) developed by MIPS Computer Systems. Multiple revisions of the MIPS instruction set exist the only current ones being MIPS32 and MIPS64. As there are *extensions* to the x86 ISA, like MMX, SSE, 3DNow!, etc, there are some available for MIPS as well. MIPS Technologies calls them ASE (Application-specific extensions). Read about them here: [http://www.imgtec.com/mips/architectures/](http://www.imgtec.com/mips/architectures/ "http://www.imgtec.com/mips/architectures/").

[![cores_fchart08.jpg](/lib/exe/fetch.php?tok=c22ce9&media=http%3A%2F%2Fwww.embeddeddeveloper.com%2Fcores%2Fimages%2FCores_FChart08.jpg "cores_fchart08.jpg")](/lib/exe/fetch.php?tok=c22ce9&media=http%3A%2F%2Fwww.embeddeddeveloper.com%2Fcores%2Fimages%2FCores_FChart08.jpg "http://www.embeddeddeveloper.com/cores/images/Cores_FChart08.jpg")

MIPS Classic Processors MIPS Aptiv Processors MIPS Warrior 4KSd M4K M14K 4KE M14Kc 24K 24KE 34K 74K 1004K 1074K microAptiv interAptiv proAptiv Warrior-M Warrior-I Warrior-P MIPS32 ✔ ✔ ✔ ✔ ✔ ✔ ✔ ✔ ✔ ✔ MIPS64 MIPS16e O O O ✔ ✔ ✔ ✔ ✔ MIPS DSP ASE ✔ ✔ ✔ ✔ MIPS MT ASE ✔ ✔ SmartMIPS ASE ✔ microMIPS ✔ ✔ MIPS-3D ASE

- AFAIK all MIPS classic processors are [in-order execution](https://en.wikipedia.org/wiki/Out-of-order%20execution "https://en.wikipedia.org/wiki/Out-of-order execution") CPUs because the developers claimed, that the silicon surface and power consumption of the OUT-OF-ORDER logic would outweigh the processing power benefit. Instead they experimented with Multi-Threading and such to achieve a similar processing power increase but with less silicon.
- The newer MIPS Aptiv Processors are reported to be all [Out-of-order](https://en.wikipedia.org/wiki/Out-of-order%20execution "https://en.wikipedia.org/wiki/Out-of-order execution") CPUs.
- Please do note, that there are a couple of MIPS32 and/or MIPS64 instruction set licensees, e.g. Broadcom, who design their own CPU Architectures based on the MIPS Instruction sets. Cf. [companies](/docs/techref/hardware/soc#companies "docs:techref:hardware:soc") for some overview.
- Dunno about Linux support for this stuff here: [http://www.imgtec.com/ensigma/ensigma-technology.asp](http://www.imgtec.com/ensigma/ensigma-technology.asp "http://www.imgtec.com/ensigma/ensigma-technology.asp")

To understand the concrete differences between the different CPU designs, you will have to go [http://www.mips.com/products/cores/](http://www.mips.com/products/cores/ "http://www.mips.com/products/cores/"). This should only give you an overview to get a better grasp of the embedded world. And please understand, that *24KE* is not necessarily a CPU you can buy, or even a CPU contained on the SoC. It the a plan to manufacture the IC of a CPU! A contractor can realize this 1:1 into IC but does not have to.

To understand a bit better, how this is embedded on the SoC, see [http://www.mips.com/products/platforms/](http://www.mips.com/products/platforms/ "http://www.mips.com/products/platforms/").

#### Example: ARM

The abbreviation stands for Advanced RISC Machine aka Acorn RISC Machine. ARM Holdings.

For some reasons, the companies does not want to compete with each other, so on the router/wifi market MIPS cores are predominant. On the smart phone market it is the other way around, and we have ARM exclusively. However there is at least one neat device on which OpenWrt is running, so we will include this:

ISA ISA+Extensions CPU Features Cache (I/D), MMU Devices Products ARMv5ARMv5 TEJ ARM926EJ-S Thumb, Jazelle DBX, Enhanced DSP instructions variable, TCMs, MMU Texas Instruments OMAP1710, OMAP1610, OMAP1611, OMAP1612, OMAP-L137, OMAP-L138; Qualcomm MSM6100, MSM6125, MSM6225, MSM6245, MSM6250, MSM6255A, MSM6260, MSM6275, MSM6280, MSM6300, MSM6500, MSM6800; Freescale i.MX21, i.MX27, Atmel AT91SAM9, NXP Semiconductors, Samsung S3C2412 LPC30xx, NEC C10046F5-211-PN2-A SoC – undocumented core in the ATi Hollywood graphics chip used in the Wii,\[25] Telechips TCC7801, TCC7901, ZiiLABS ZMS-05, Rockchip RK2806 and RK2808, NeoMagic MiMagic Family MM6, MM6+, MM8, MTV. Mobile phones: Sony Ericsson (K, W series); Siemens and Benq (x65 series and newer); LG Arena; , GPH Wiz, Squeezebox Duet Controller (Samsung S3C2412). Squeezebox Radio; Buffalo TeraStation Live (NAS); Drobo FS (NAS); Western Digital MyBook I World Edition; Western Digital MyBook II World Edition; Seagate FreeAgent DockStar STDSD10G-RK; Seagate FreeAgent GoFlex Home; Chumby Classic

To understand the concrete differences between the different versions, you will have to go somewhere else. This should only give you an overview to get a better grasp of the embedded world. And please understand, that *ARM926EJ-S* is not necessarily a CPU you can buy, or even a CPU contained on the SoC. It is only the model of a CPU! A contractor can realize this 1:1 into IC but does not have to. For example the manufacturer Marvell make the *Marvell Feroceon CPU*, which is based on the Design of the *ARM926EJ-S* (sometimes it includes CESA). *Marvell Kirkwood* is the denomination of a family of SoCs, not of a CPU design.

- [http://www.arm.com/markets/enterprise/home-networking.php](http://www.arm.com/markets/enterprise/home-networking.php "http://www.arm.com/markets/enterprise/home-networking.php") about SoC
- [CPUs based on ARM Instruction set](https://en.wikipedia.org/wiki/Template:ARM-based_chips "https://en.wikipedia.org/wiki/Template:ARM-based_chips")

On [http://hackipedia.org/Hardware/CPU/](http://hackipedia.org/Hardware/CPU/ "http://hackipedia.org/Hardware/CPU/"), for example, there are some txt-documents about the ARM-architecture.

#### Example: Other

[x86](https://en.wikipedia.org/wiki/x86 "https://en.wikipedia.org/wiki/x86"), [Ubicom32](https://en.wikipedia.org/wiki/Ubicom32 "https://en.wikipedia.org/wiki/Ubicom32"), [DEC Alpha](https://en.wikipedia.org/wiki/DEC%20Alpha "https://en.wikipedia.org/wiki/DEC Alpha"), [PowerPC](https://en.wikipedia.org/wiki/PowerPC "https://en.wikipedia.org/wiki/PowerPC"), [Intel Itanium architecture](https://en.wikipedia.org/wiki/Intel%20Itanium%20architecture "https://en.wikipedia.org/wiki/Intel Itanium architecture"), [SuperH](https://en.wikipedia.org/wiki/SuperH "https://en.wikipedia.org/wiki/SuperH"), etc.

#### Extensions

Code compiled for ARM should run on any ARM-ISA, but code speficifally compiled for ARMv7 will not run smoothly or not at all on an ARMv5 ISA. So, it is imperative to keep the ISA stable for many years, thus there are only few or no updates at all! To still be able to develop and advance the ISA, and thus give the programmer (or the compiler) more options to do theirs stuff, manufactures (or better developers) extend ISAs with so called extensions. See [Template:Multimedia\_extensions](https://en.wikipedia.org/wiki/Template:Multimedia_extensions "https://en.wikipedia.org/wiki/Template:Multimedia_extensions").

**NOTE:** In the FOSS-“World”, this isn't such a big issue, since we have the Source-Code and with an updated compiler we can recompile the code as we like and obtain binaries that work an any architecture. And actually we do exactly that at OpenWrt. When you choose the option [toolchain](/docs/guide-developer/toolchain/start "docs:guide-developer:toolchain:start") you do download the very latest source code for the cross compiler and cross compile the source code with that!

### The microarchitecture

While the ISA is only the set of commands available, to use it, you need to create a CPU based on one. While an abstraction of the ISA is build in silicon, the CPU needs more functional units to be able to work and also to perform as well as possible. The denomination for this is not clear-cut, everyone names differently. Instead of *microarchitecture*, sometimes this is referred to as *“processor organization”* or *“processor design”* or *“processor implementation”*. It deals with the organization of the different functional units of the CPU. For the same ISA, you could develop a whole lot of microarchitectures. A hopefully good example is the intel i486 and the intel Pentium Pro (it's the immediate predecessor the Pentium II, whereas the Pentium is not). Both CPU have (almost) the same ISA, but very different MAs.

- CPU components (functional units): [Microcode](https://en.wikipedia.org/wiki/microcode "https://en.wikipedia.org/wiki/microcode") [Arithmetic logic unit (ALU)](https://en.wikipedia.org/wiki/Arithmetic%20logic%20unit "https://en.wikipedia.org/wiki/Arithmetic logic unit") [Address generation unit (AGU)](https://en.wikipedia.org/wiki/Address%20generation%20unit "https://en.wikipedia.org/wiki/Address generation unit") [Barrel shifter](https://en.wikipedia.org/wiki/Barrel%20shifter "https://en.wikipedia.org/wiki/Barrel shifter") [Floating-point unit (FPU)](https://en.wikipedia.org/wiki/Floating-point%20unit "https://en.wikipedia.org/wiki/Floating-point unit") [Back-side bus](https://en.wikipedia.org/wiki/Back-side%20bus "https://en.wikipedia.org/wiki/Back-side bus") [Multiplexer](https://en.wikipedia.org/wiki/Multiplexer "https://en.wikipedia.org/wiki/Multiplexer") [Demultiplexer](https://en.wikipedia.org/wiki/Demultiplexer "https://en.wikipedia.org/wiki/Demultiplexer") [Registers](https://en.wikipedia.org/wiki/Processor%20register "https://en.wikipedia.org/wiki/Processor register") [Memory management unit (MMU)](https://en.wikipedia.org/wiki/Memory%20management%20unit "https://en.wikipedia.org/wiki/Memory management unit") [Translation lookaside buffer (TLB)](https://en.wikipedia.org/wiki/Translation%20lookaside%20buffer "https://en.wikipedia.org/wiki/Translation lookaside buffer") [Cache](https://en.wikipedia.org/wiki/CPU%20cache "https://en.wikipedia.org/wiki/CPU cache") [Register file](https://en.wikipedia.org/wiki/register%20file "https://en.wikipedia.org/wiki/register file")[Control unit](https://en.wikipedia.org/wiki/control%20unit "https://en.wikipedia.org/wiki/control unit") [Clock rate](https://en.wikipedia.org/wiki/clock%20rate "https://en.wikipedia.org/wiki/clock rate")
- see [CPU design](https://en.wikipedia.org/wiki/CPU%20design "https://en.wikipedia.org/wiki/CPU design") to learn about the tasks CPU design focuses on
- see [Microarchitecture](https://en.wikipedia.org/wiki/Microarchitecture "https://en.wikipedia.org/wiki/Microarchitecture") to learn about some micro-architectural concepts with the help of some schematic examples from the x86

## IP core

IP core means “Intellectual Property Core”. It is a piece of software that can be licensed from companies such as MIPS or ARM. It's a chip layout design and consists of schematics and descriptions to manufacture ICs with the functionality of a CPU. With this, the licensee can go to a semiconductor foundry and commission the manufacturing of Chips with the functionality of merely the CPU purchased. But usually, the designs of the CPU are combined with the designs of other ICs serving other tasks. Then the licensee commissions the manufacture of Chips, which do have the functionality of a complete [soc](/docs/techref/hardware/soc "docs:techref:hardware:soc"), and not merely that of a CPU.

Often different types can be licensed, a *soft IP core* or *hard IP core*. To understand the difference between them you need to understand even more of the chip design process. Maybe the article [ic](/docs/techref/hardware/ic "docs:techref:hardware:ic") helps a little with that.

Also, exceptionally there is a good article about this in the wikipedia: [IP core](http://en.wikipedia.org/wiki/Semiconductor_intellectual_property_core "http://en.wikipedia.org/wiki/Semiconductor_intellectual_property_core").

## The SoC

→ [SoC](/docs/techref/hardware/soc "docs:techref:hardware:soc") What do licensees include in a SoC?

## The device

→ [toh](/toh/start "toh:start")

A Manufacturer of “devices”/routers/access points buys SoCs, RAM-Chips, Flash-Chips, etc. from the manufacturers of these and solder them onto a circuit board. Then they put the whole thing into a body housing, write documentation for the end customer and sell them whole sale.

For a List of Devices and Manufacturers, simply have look at the [Table of Hardware](/toh/start "toh:start").

## Manufacturing

→ [Integrated Circuit](/docs/techref/hardware/ic "docs:techref:hardware:ic") whether [CPU](https://en.wikipedia.org/wiki/Central%20processing%20unit "https://en.wikipedia.org/wiki/Central processing unit"), [GPU](https://en.wikipedia.org/wiki/Graphics%20processing%20unit "https://en.wikipedia.org/wiki/Graphics processing unit"), [DRAM](https://en.wikipedia.org/wiki/Dynamic%20random-access%20memory "https://en.wikipedia.org/wiki/Dynamic random-access memory"), [SRAM](https://en.wikipedia.org/wiki/Static%20random-access%20memory "https://en.wikipedia.org/wiki/Static random-access memory"), [DPS](https://en.wikipedia.org/wiki/Digital%20signal%20processor "https://en.wikipedia.org/wiki/Digital signal processor"), [FPU](https://en.wikipedia.org/wiki/Floating-point%20unit "https://en.wikipedia.org/wiki/Floating-point unit") etc. all are realized as ICs.

### Wiki articles

- [Integrated\_circuit#Manufacturing](https://en.wikipedia.org/wiki/Integrated_circuit#Manufacturing "https://en.wikipedia.org/wiki/Integrated_circuit#Manufacturing") ← mediocre article
- [Semiconductor device fabrication](https://en.wikipedia.org/wiki/Semiconductor%20device%20fabrication "https://en.wikipedia.org/wiki/Semiconductor device fabrication") ← miserable article, please replace with something better
- [Application binary interface](https://en.wikipedia.org/wiki/Application%20binary%20interface "https://en.wikipedia.org/wiki/Application binary interface")
