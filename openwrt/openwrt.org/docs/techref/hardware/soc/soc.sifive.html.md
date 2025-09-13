# SiFive RISC-V SoCs

RISC-V is a free, open, extensible instruction set architecture (ISA), the specification is now maintained by the nonprofit RISC-V Foundation.

## U540

U540 is the first available Linux-capable RISC-V SoC.

- 4+1 Multi-Core Coherent Configuration, up to 1.5 GHz
- 4x U54 RV64GC cores
- 1x E51 Management core
- 2MB L2 Cache
- DDR4 ECC memory

## U740

U740 is the second generation of Linux-capable RISC-V SoC.

- 4+1 Multi-Core Coherent Configuration, up to 1.5 GHz
- 4x U74 RV64GC cores
- 1x S7 Management core
- 2MB L2 Cache
- DDR4 ECC memory

### Status

There are a couple options you can use to run RISC-V:

- [HiFive Unleashed](/toh/hifive/unleashed "toh:hifive:unleashed")
- [HiFive Unmatched](/toh/hifive/unmatched "toh:hifive:unmatched")
- FPGA-based implementation (Virtex7)
- [QEMU](/docs/guide-user/virtualization/qemu#openwrt_in_qemu_risc-v "docs:guide-user:virtualization:qemu") (cheapest option)
- Other SoCs (StarFive, Allwinner D1, work is in progress for these chips)

Port status: sifiveu merged at 28/May/2023

### U540 Boot process

- The SoC is initialized by a zero/first-stage bootloader called ZSBL/FSBL which is stored in ROM.
- The FSBL goes on to boot BBL (Berkeley bootloader), which is a second-stage “proxy” kernel. A device-tree is passed on to the BBL.
- The BBL image usually includes the kernel image, which is then booted.

There were some controversies around the full openness of the ZSBL/FSBL (around the DDR init code), but that has been fixed/released in July/18. There are also efforts to replace the FSBL with a U-boot port, but that will still require the BBL to be built.

## Devices

The list of related devices: [riscv](/tag/riscv?do=showtag&tag=riscv "tag:riscv"), [riscv64](/tag/riscv64?do=showtag&tag=riscv64 "tag:riscv64")
