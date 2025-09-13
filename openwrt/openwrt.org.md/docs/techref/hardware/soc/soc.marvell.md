# Marvell Technology Group SoCs

- [Marvell Technology Group](https://en.wikipedia.org/wiki/Marvell%20Technology%20Group "https://en.wikipedia.org/wiki/Marvell Technology Group")
- [http://wikidevi.com/wiki/Marvell](http://wikidevi.com/wiki/Marvell "http://wikidevi.com/wiki/Marvell")

## Marvell designed CPUs

Marvell holds a full architecture license for the ARM instruction set, allowing it to design CPUs to implement the ARM instruction set, and not to just license a processor core designed by ARM holdings. E.g.

- Marvell Feroceon has a variable-length processing pipeline that allows out-of-order instruction execution. The Feroceon made some significant changes to the standard ARM fixed pipeline, with a variable-stage pipeline that ranges from six stages to eight if the writeback stage is included.
  
  - Most ARM processors (and many other embedded processors) employ an in-order, fixed-stage pipeline design because it is simpler to construct and uses less logic. The instructions per cycle (IPC) of an in-order, fixed-stage pipeline will often be fairly low unless other features are added, such as multithreading or superscalarity.
  - In contrast, a variable-stage pipeline optimizes the number of clock cycles needed from issue to retire on each instruction, avoids wasting processor resources, and minimizes the branch penalty from dead clock cycles. With these changes to the ARM core, the Feroceon processor could also support dual-issue operation.
- Marvell Sheeva 88SV131 = Marvell designed ARMv5TE-compliant
- Marvell Flareon PJ4 = Marvell designed armv7-a-compliant?

<!--THE END-->

- [http://www.anandtech.com/show/2860](http://www.anandtech.com/show/2860 "http://www.anandtech.com/show/2860")

See also [marvell\_cesa](/docs/techref/hardware/cryptographic.hardware.accelerators#marvell_cesa "docs:techref:hardware:cryptographic.hardware.accelerators")

### Naming confusion

There seem to be some confusion regarding the Names *“Sheeva”* and *“Feroceon”*. One pdfs states: “The Marvell® 88F6192 SoC with SheevaTM embedded CPU technology, is a high-performance integrated controller for value class applications. It integrates the Marvell Sheeva CPU core which is fully ARMv5TE-compliant with a 256KB L2 Cache. The 88F6192 builds upon Marvell’s innovative Feroceon® family of processors.

Oh, also read: [http://lists.infradead.org/pipermail/linux-arm-kernel/2012-July/109891.html](http://lists.infradead.org/pipermail/linux-arm-kernel/2012-July/109891.html "http://lists.infradead.org/pipermail/linux-arm-kernel/2012-July/109891.html")

## Marvell SoCs

- For mainline Linux kernel support see [Documentation/arm/Marvell/README](https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/tree/Documentation/arm/Marvell/README?h=linux-3.9.y "https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/tree/Documentation/arm/Marvell/README?h=linux-3.9.y")
- [mvebu: add inital support for Marvell Armada XP/370 SoCs](https://git.openwrt.org/?p=openwrt%2Fopenwrt.git%3Ba%3Dcommit%3Bh%3D25475a095e "https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=25475a095e")

Target CPU Series SoC CPU cores CPU MHz GbE Ports Sata Ports Notes [orion](/toh/views/toh_dev_arch-target-cpu?dataflt%5Btarget%2A~%5D=orion "toh:views:toh_dev_arch-target-cpu") MV88 F5 xxx 1 500 ? ? [kirkwood](/toh/views/toh_dev_arch-target-cpu?dataflt%5Btarget%2A~%5D=kirkwood "toh:views:toh_dev_arch-target-cpu") Sheeva MV88 F6 xxx 88F6180 1 800 1 0 88F6190 1 600 1 1 88F6192 1 800 2 2 88F6280 1 1 0 88F6281, 88F6282, 88F6283 1 1500 2 2 88F632X 2 1 2 [mvebu](/toh/views/toh_dev_arch-target-cpu?dataflt%5Btarget%2A~%5D=mvebu "toh:views:toh_dev_arch-target-cpu") Cortex-A9 ARMADA 370 88F6710, 88F6707 1 1200 2 2 VFP3-d16 88F6W11 1 1200 2 0 ARMADA 375 88F6720 2 1000 2 2 VFP3-d16 + NEON ARMADA XP MV78230 2 1600 3 2 VFP3-d16 + LPAE MV78260 2 1600 4 2 MV78460 4 1600 4 2 ARMADA 38x 88F6810 1 1330 2 2 VFP3-d32 + NEON + LPAE 88F6811 1 1866 2 2 88F6820 2 1866 3 2 88F6821 2 1330 2 2 88F6825, 88F6828 2 1866 3 4 88F6W21 2 1200 2 1 Cortex-A53 ARMADA LP 88F3710 1 1000 2x 2.5GbE 1 88F3720 2 1000 2x 2.5GbE 1 Cortex-A72 ARMADA 7K/8K 88F6040 4 600 2x 2.5GbE  
1x 10GbE 2 88F7020 2 1600 2x 2.5GbE  
1x 10GbE 2 88F7040 4 1400 2x 2.5GbE  
1x 10GbE 2 88F8020 2 2000 4x 2.5GbE  
2x 10GbE 4 88F8040 4 2000 4x 2.5GbE  
2x 10GbE 4 n/a ARMADA 300/310 1 2 just a rebranded kirkwood??? ARMADA 510 1 ? (aka “dove”): ARMv7 (PJ4)+VFP3 AVANTA 88F6510/30/50/60 1 ? Cortex-A9 AVANTA-LP 88F6650/60 2 ? similar to Armada 375

### Orion

Boards based on the Marvell MV88 F5 18x / MV88 F5 28x SoCs .

- → [WNR854T](/toh/netgear/wnr854t "toh:netgear:wnr854t")
- → [WRT350Nv2](/toh/linksys/wrt350nv2 "toh:linksys:wrt350nv2")
- [orion](/tag/orion?do=showtag&tag=orion "tag:orion")

### Kirkwood

Boards based on the Marvell MV88 F6 1xx / MV88 F6 2xx SoCs.

- → [Dockstar](/toh/seagate/dockstar "toh:seagate:dockstar")
- → [iconnect](/toh/iomega/iconnect "toh:iomega:iconnect")
- → [goflexnet](/toh/seagate/goflexnet "toh:seagate:goflexnet")
- → [dgs-1210](/toh/d-link/dgs-1210 "toh:d-link:dgs-1210")
- → [sheevaplug](/toh/globalscale/sheevaplug "toh:globalscale:sheevaplug")
- → [ea4500](/toh/linksys/ea4500 "toh:linksys:ea4500")
- [kirkwood](/tag/kirkwood?do=showtag&tag=kirkwood "tag:kirkwood")

## NIC/WNIC

- Marvell MV88Exxx “Alaska” Ethernet NIC:
- Marvell “Libertas” WNIC: `libertas` and especially: [http://wiki.laptop.org/go/Marvell\_microkernel](http://wiki.laptop.org/go/Marvell_microkernel "http://wiki.laptop.org/go/Marvell_microkernel")
- [http://wiki.debian.org/libertas](http://wiki.debian.org/libertas "http://wiki.debian.org/libertas")
- The Marvell® Avastar™ 88W8764 is a highly integrated 4×4 wireless local area network (WLAN) system-on-chip (SoC); the [Marvell SmilePlug](/toh/globalscale/smileplug "toh:globalscale:smileplug") is based on it. Like the Libertas WNIC, it also seems to contain an ARM9-CPU with very much closed source firmware running on it. This is not so cool. On the other side, it is advertised to offer 4×4 MIMO, and has working DFS-support for 5GHz.

[![Marvell 4x4 MIMO](/lib/exe/fetch.php?w=400&tok=98635f&media=http%3A%2F%2Fwikidevi.com%2Fw%2Fimages%2F2%2F22%2FActiontec_TwinTower-1A_802DRN_shield_off.jpg "Marvell 4x4 MIMO")](/lib/exe/fetch.php?tok=39763c&media=http%3A%2F%2Fwikidevi.com%2Fw%2Fimages%2F2%2F22%2FActiontec_TwinTower-1A_802DRN_shield_off.jpg "http://wikidevi.com/w/images/2/22/Actiontec_TwinTower-1A_802DRN_shield_off.jpg")

### Switches

- Marvell 88E6060, 88E6131, 88E6123, 88E6161, 88E6165 [this switch has NO support for 802.1q and uses a proprietary 'vlan trailer'.](https://forum.openwrt.org/viewtopic.php?pid=49696#p49696 "https://forum.openwrt.org/viewtopic.php?pid=49696#p49696")
  
  - [http://marc.info/?l=linux-netdev&amp;m=122265586218156&amp;w=2](http://marc.info/?l=linux-netdev&m=122265586218156&w=2 "http://marc.info/?l=linux-netdev&m=122265586218156&w=2")
- google for: DSA (Distributed Switch Architecture) protocol
  
  - [http://permalink.gmane.org/gmane.linux.network/164272](http://permalink.gmane.org/gmane.linux.network/164272 "http://permalink.gmane.org/gmane.linux.network/164272")

## Marvell Hardware

- [http://wikidevi.com/wiki/Marvell](http://wikidevi.com/wiki/Marvell "http://wikidevi.com/wiki/Marvell")
- many other

## Devices

The list of related devices: [feroceon](/tag/feroceon?do=showtag&tag=feroceon "tag:feroceon"), [kirkwood](/tag/kirkwood?do=showtag&tag=kirkwood "tag:kirkwood"), [mvebu](/tag/mvebu?do=showtag&tag=mvebu "tag:mvebu"), [orion](/tag/orion?do=showtag&tag=orion "tag:orion")
