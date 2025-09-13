# Hardware

An embedded system consist of several components.

- Core System: [soc](/docs/techref/hardware/soc "docs:techref:hardware:soc") ([cpu](/docs/techref/hardware/cpu "docs:techref:hardware:cpu") , architecture specific)
- Peripherals connected via: [PCI](https://en.wikipedia.org/wiki/Conventional_PCI "https://en.wikipedia.org/wiki/Conventional_PCI"), [PCIe](https://en.wikipedia.org/wiki/PCI_Express "https://en.wikipedia.org/wiki/PCI_Express"), [I2C](/docs/techref/hardware/port.i2c "docs:techref:hardware:port.i2c"), [SPI](https://en.wikipedia.org/wiki/Serial_Peripheral_Interface_Bus "https://en.wikipedia.org/wiki/Serial_Peripheral_Interface_Bus"), [GPIO](/docs/techref/hardware/port.gpio "docs:techref:hardware:port.gpio"), [USB](https://en.wikipedia.org/wiki/USB "https://en.wikipedia.org/wiki/USB"), Vendor specific
- Special Hardware: [cryptographic.hardware.accelerators](/docs/techref/hardware/cryptographic.hardware.accelerators "docs:techref:hardware:cryptographic.hardware.accelerators")
- Hardware developers often use interfaces that can directly write to chip registers or flash: [JTAG](/docs/techref/hardware/port.jtag "docs:techref:hardware:port.jtag"), debug ports/pins
- Wireless

Embedded systems are designed and often have drawbacks for their advantages. Low power consumption and low [performance](/docs/techref/hardware/performance "docs:techref:hardware:performance") (benchmark: performance/watt comparisons) In contrast to the early age of computers many vendors do not publish data sheets or programming handbooks for their SoC, wireless chips, boards, etc...

## Index

[Index of hardware pages](/docs/techref/hardware/index "docs:techref:hardware:index")
