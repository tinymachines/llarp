# arm\_mpcore

The Cortex-A9 MPCore processor consists of:

- From one to four Cortex-A9 processors in a cluster and a Snoop Control Unit (SCU) that can be used to ensure coherency within the cluster.
- A set of private memory-mapped peripherals, including a global timer, and a watchdog and private timer for each Cortex-A9 processor present in the cluster.
- An integrated Interrupt Controller that is an implementation of the Generic Interrupt Controller architecture. The integrated Interrupt Controller registers sit beside the timers and watchdog control registers in the private memory region of the Cortex-A9 MPCore.

Individual Cortex-A9 processors in the Cortex-A9 MPCore cluster can be implemented with their own hardware configurations. See the Cortex-A9 Technical Reference Manual for additional information on possible Cortex-A9 processor configurations. ARM recommends you implement symmetric configurations for software ease of use.  
There are other configuration options that impact Cortex-A9 MPCore system integration. The major options are:

- One or two AXI master port interfaces, with address filtering capabilities
- An optional Accelerator Coherency Port (ACP) suitable for coherent memory transfers
- A configurable number of interrupt lines.

[source (technical reference manual)](http://infocenter.arm.com/help/topic/com.arm.doc.ddi0407e/DDI0407E_cortex_a9_mpcore_r2p0_trm.pdf "http://infocenter.arm.com/help/topic/com.arm.doc.ddi0407e/DDI0407E_cortex_a9_mpcore_r2p0_trm.pdf")

## Download Packages

HTTP [https://downloads.openwrt.org/releases/packages-18.06/arm\_mpcore/](https://downloads.openwrt.org/releases/packages-18.06/arm_mpcore/ "https://downloads.openwrt.org/releases/packages-18.06/arm_mpcore/") FTP [ftp://ftp.halifax.rwth-aachen.de/lede/releases/packages-18.06/arm\_mpcore/](ftp://ftp.halifax.rwth-aachen.de/lede/releases/packages-18.06/arm_mpcore/ "ftp://ftp.halifax.rwth-aachen.de/lede/releases/packages-18.06/arm_mpcore/")

See [Mirrors](/downloads#mirrors "downloads") for more download sites.

## Devices with this instructionset
