# OpenWrt SystemReady

Document the effort to support SystemReady in OpenWrt. Show the current status. Track the [SystemReady IR certified systems](https://www.arm.com/architecture/system-architectures/systemready-certification-program/ir "https://www.arm.com/architecture/system-architectures/systemready-certification-program/ir") support in OpenWrt.

## Get Started

[Initial SystemReady support](https://git.openwrt.org/?p=openwrt%2Fopenwrt.git&a=search&h=HEAD&st=commit&s=systemready "https://git.openwrt.org/?p=openwrt%2Fopenwrt.git&a=search&h=HEAD&st=commit&s=systemready") in OpenWrt started by Mathew McBride from Traverse. `armsr` target was introduced as well as enabling most of the boards found in [ARM SystemReady IR Certified Systems page](https://www.arm.com/architecture/system-architectures/systemready-certification-program/ir "https://www.arm.com/architecture/system-architectures/systemready-certification-program/ir").

### How to build OpenWrt SystemReady image

Follow the steps at [Build system usage](/docs/guide-developer/toolchain/use-buildsystem "docs:guide-developer:toolchain:use-buildsystem"). Make sure to switch to the `main/master` branch because it has the most recent changes as of the moment of writing this Wiki page.

When running `make menuconfig` select SystemReady target and architecture as it's documented at [Menuconfig](/docs/guide-developer/toolchain/use-buildsystem#menuconfig "docs:guide-developer:toolchain:use-buildsystem").

After a successful build, the built image(s) can be found as explained at [Locating images](/docs/guide-developer/toolchain/use-buildsystem#locating_images "docs:guide-developer:toolchain:use-buildsystem").

### How to boot OpenWrt SystemReady image

Please refer to [OpenWrt Target -&gt; armsr -&gt; README](https://git.openwrt.org/?p=openwrt%2Fopenwrt.git%3Ba%3Dblob%3Bf%3Dtarget%2Flinux%2Farmsr%2FREADME%3Bhb%3DHEAD "https://git.openwrt.org/?p=openwrt/openwrt.git;a=blob;f=target/linux/armsr/README;hb=HEAD") to get the instructions on how to boot the OpenWrt SystemReady image.

## SystemReady IR Certified Systems in OpenWrt

All SystemReady Certificated boards are under `amrsr` OpenWrt target. Most of them are not being tested in real HW. They have been added on a best-effort basis.

Company System SoC Family Kernel OpenWrt branch Tested in HW Status AAEON AAEON SRG-IMG8P NXP i.MX8M Plus 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested ADLINK ADLINK I-Pi SMARC IMX8M Plus (2 GB LPDDR4) NXP i.MX8M Plus 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested Advantech Advantech RSB-3720WQ NXP i.MX8M Plus 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested Arduino Arduino Portenta-X8 and ASX00031 Portenta Breakout NXP i.MX8MM 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested Arm Arm Corstone-1000 MPS3 Arm Corstone-1000 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested ASUS ASUS PE100A NXP i.MX8M 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested Compulab Compulab IOT-GATE-iMX8 NXP i.MX8M Mini 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested Congatec Congatec conga-SMX8-Plus (4 GB LPDDR4) &amp; conga-SMC1/SMARC-ARM NXP i.MX8M Plus 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested Eurotech Eurotech ReliaGATE 10-14-35 NXP i.MX8M Mini 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested Google Google Coral Dev Board (1 GB LPDDR4) NXP i.MX8M 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested Kontron Kontron KBox A-230-LS (4GB DDR3L, 32GB eMMC) NXP Layerscape LS1028A 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested Lenovo Lenovo Leez P710 Gateway Rockchip RK3399 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested NXP NXP i.MX8M Quad EVK (MCIMX8M-EVKB) NXP i.MX8M Quad 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested PINE64 PINE64 ROCKPro64 Rockchip RK3399 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested Radxa Radxa ROCK PI 4B Plus Rockchip RK3399 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested Raspberry Pi Raspberry Pi 4 Model B Broadcom BCM2711 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested Renesas Renesas HiHope RZ/G2M RZ/G2M 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested Rockchip Rockchip TB-RK3399ProD Rockchip RK3399 Pro 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested SECO SECO SBC-C61 (i.MX8MM, 4GB) NXP i.MX8M Mini 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested Socionext Socionext SynQuacer E-Series Socionext SynQuacer SC2A11 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested STMicroelectronics STMicroelectronics STM32MP157C-EV1 Evaluation board STM32MP157C ![:?:](/lib/images/smileys/question.svg) Variscite Variscite DART-MX8M-PLUS with VAR-DT8MCustomBoard (Quad-core @1.8 GHz, 4 GB LPDDR4, 16 GB eMMC) NXP i.MX8M Plus 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested WinSystems System: WinSystems ITX-P-C444 (ITX-P-444Q-4-32, quad-core, 4 GB LPDDR4, 32GB onboard eMMC) NXP i.MX8MQ 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested Xilinx Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit Xilinx Zynq UltraScale+ ZU9EG MPSoC 6.1 main ![:?:](/lib/images/smileys/question.svg) HW tested

## FAQ

#### How to get the list of installed packages from OpenWrt SystemReady build?

From the host where OpenWrt is built, installed packages are saved in `bin/targets/armsr/armv8/openwrt-armsr-armv8-generic.manifest` file; it contains the same \`opkg list\` output from OpenWrt host. The manifest file is in the same [directory where the target images are created](/docs/guide-developer/toolchain/use-buildsystem#locating_images "docs:guide-developer:toolchain:use-buildsystem"). For `ARM32`, replace `armv8` with `armv7`.
