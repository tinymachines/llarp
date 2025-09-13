# RouterBOOT

RouterBOOT is MikroTik's closed source bootloader. See [the Mikrotik documentation](https://wiki.mikrotik.com/wiki/Manual:RouterBOOT "https://wiki.mikrotik.com/wiki/Manual:RouterBOOT") for details.

The information contained in this page is based on reverse engineering experiments and may not be fully accurate.

### Findings

#### Version 6.46.4 on RB493G

Routerboot will load an ELF binary under the following conditions:

- 0x8000-0000 ⇐ load address &lt; 0x8070-0000
- load address + size &lt; 0x8070-0000

Any other value will trigger a « kernel is out of range » error. Thus only 7MB is available to load an ELF binary from TFTP.

The load address doesn’t seem to have to satisfy any wide alignment: 0x802D-1BC4 was successfully loaded.

RouterBOOT seems to honor the entry point address (TBC).

It also appears that RouterBOOT tftp routine loads at offset 0x80A0-0000

##### Implications

The standard self-decompressing kernel is linked at a load address that starts after the decompressed kernel (it is computed in arch/mips/boot/compressed/calc\_vmlinuz\_load\_addr): it's thus not suitable because it makes the problem worse.
