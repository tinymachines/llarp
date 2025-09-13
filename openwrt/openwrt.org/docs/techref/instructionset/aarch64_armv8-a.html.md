# aarch64\_armv8-a

This instruction set is no longer used by the OpenWrt project, in favor of micro-architecture targeted ARM64 instruction sets:

[aarch64\_cortex-a53](/docs/techref/instructionset/aarch64_cortex-a53 "docs:techref:instructionset:aarch64_cortex-a53")

[aarch64\_cortex-a72](/docs/techref/instructionset/aarch64_cortex-a72 "docs:techref:instructionset:aarch64_cortex-a72")

[aarch64\_cortex-a76](/docs/techref/instructionset/aarch64_cortex-a76 "docs:techref:instructionset:aarch64_cortex-a76")

[aarch64\_generic](/docs/techref/instructionset/aarch64_generic "docs:techref:instructionset:aarch64_generic")

Original text below: ARMv8-A introduces 64-bit architecture support to the ARM architecture and includes:

- 64-bit general purpose registers, SP (stack pointer) and PC (program counter)
- 64-bit data processing and extended virtual addressing
- Two main execution states:
  
  - AArch64 - The 64-bit execution state including exception model, memory model, programmers' model and instruction set support for that state
  - AArch32 - The 32-bit execution state including exception model, memory model, programmers' model and instruction set support for that state

The execution states support three key instruction sets:

- A32 (or ARM): a 32-bit fixed length instruction set, enhanced through the different architecture variants. Part of the 32-bit architecture execution environment now referred to as AArch32.
- T32 (Thumb) introduced as a 16-bit fixed-length instruction set, subsequently enhanced to a mixed-length 16- and 32-bit instruction set on the introduction of Thumb-2 technology. Part of the 32-bit architecture execution environment now referred to as AArch32.
- A64 is a 64-bit fixed-length instruction set that offers similar functionality to the ARM and Thumb instruction sets. Introduced with ARMv8-A, it is the AArch64 instruction set.

ARM ISAs are constantly improving to meet the increasing demands of leading edge applications developers, while retaining the backwards compatibility necessary to protect investment in software development. In ARMv8-A there are some additions to A32 and T32 to maintain alignment with the A64 instruction set.

[source](http://www.arm.com/products/processors/armv8-architecture.php "http://www.arm.com/products/processors/armv8-architecture.php")
