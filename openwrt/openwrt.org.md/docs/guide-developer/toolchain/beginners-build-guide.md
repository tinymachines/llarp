# Quick image building guide

See also: [Using the toolchain](/docs/guide-developer/start#using_the_toolchain "docs:guide-developer:start"), [Using the Image Builder](/docs/guide-user/additional-software/imagebuilder "docs:guide-user:additional-software:imagebuilder")

The goal of this guide is to let you build your own flashable firmware in as few simple steps as possible. The main advantage of building your own firmware is that it compresses the files, so that you will have room for much more stuff. It is particularly noticeable on routers with 16 MB flash RAM or less. It also lets you change some options that can only be changed at build time, for instance the features included in BusyBox and the block size of SquashFS. Larger block size will give better compression, but may also slow down the loading of files.

## Instructions

1. [Set up a build machine in VirtualBox](/docs/guide-developer/buildserver_virtualbox "docs:guide-developer:buildserver_virtualbox") This first step is optionnal, as you can use whatever build system you might want, but it is recommended to avoid possible unknown problem; look at the prerequesites in the next step.
2. [Install building dependencies](/docs/guide-developer/toolchain/install-buildsystem#debianubuntu "docs:guide-developer:toolchain:install-buildsystem")
3. [Build OpenWrt images](/docs/guide-developer/toolchain/use-buildsystem "docs:guide-developer:toolchain:use-buildsystem")

### General tips on using the config system

- You select a package using space one or more times. When you select something, always make sure it has a `*` and not an `M` in the selected field. `*` means it will be included in the image, while `M` means that it will only create a package for it, which kind of defeats the point of following this guide.
- Except for choosing the target I suggest that you don't mess with the options above Base system. Also, in general, don't uncheck anything that is selected by default unless you really know what you're doing. If something is selected with `-*-` (so you can't uncheck it) it is because something else depends on it.
- Instructions on how to include config files in the image (for instance from the backup you can download from the router): [Custom files](/docs/guide-developer/toolchain/use-buildsystem#custom_files "docs:guide-developer:toolchain:use-buildsystem")

### Determining target / Selecting the router model

1. Do a web search for &lt;your router model&gt; wikidevi. For instance, if you have an Asus RT-N56U then search for RT-N56U wikidevi. This would give [https://wikidevi.com/wiki/ASUS\_RT-N56U](https://wikidevi.com/wiki/ASUS_RT-N56U "https://wikidevi.com/wiki/ASUS_RT-N56U") as the first response on most search engines. Find CPU on the page. In the case of RT-N56U it says Ralink RT3662F. If you type / in the builder you can search for RT-N56U. This will give a bunch of hits, which among other things says Symbol: TARGET\_DEVICE\_PACKAGES\_ramips\_rt3883\_DEVICE\_rt-n56u. Notice the ramips part. Now select Target System. In the list you will find “Mediatek Ralink ARM” and “Mediatek Ralink MIPS”. Given the information we have you can probably guess that the correct choice is “Mediatek Ralink MIPS”.
2. Select Subtarget. From the wikidevi page you know that it is a Ralink RT3662F, and the best fit in the list is “RT3662/RT3883 based boards”.
3. Select Target Profile. Asus RT-N56U is now listed here, so you know you chose the correct target and subtarget.

### Tips on what to include to get a functional image

- Don't remove any of the default packages unless you know what you are doing. Some of them are crucial. See [Saving firmware space](/docs/guide-user/additional-software/saving_space "docs:guide-user:additional-software:saving_space")
- You'll probably want the LuCi web admin interface, so choose LuCi/Collections/luci. If LuCI is not available then you have not successfully checked out the feeds, or they have been removed. This can also happen if you for instance run make clean.
- The selectable software is in the submenues from “Base system” and downwards. Start by going to LuCI / Applications, as this section lists the LuCI packages for the most commonly used software. Selecting them will also include the required dependencies.
- When you build your own firmware you can't use the downloadable kernel packages (packages named kmod-&lt;something&gt;), so try to make sure you select everything you need. If you need more kernel modules later you will have to build a new firmware. It is also possible to select all the kernel modules using m and copy them to the router later if needed. Packages are placed in bin/targets/\*/\*/packages/.
