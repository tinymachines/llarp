← [Previous Chapter](/docs/guide-developer/helloworld/chapter4 "docs:guide-developer:helloworld:chapter4")  

 [Next Chapter](/docs/guide-developer/helloworld/chapter6 "docs:guide-developer:helloworld:chapter6") →

# Building, deploying and testing your application

This is the fifth chapter in the “Hello, world!” for OpenWrt article series. At this point, you should've already accomplished the following tasks:

- Commissioned your development environment
- Prepared, configured and built the tools and the cross-compilation toolchain
- Configured the PATH environment variable
- Created a simple “Hello, world!” application using native compilation tools
- Created a local package feed for your application
- Created a package manifest file for your application
- Included your new package feed into the OpenWrt build system
- Updated the package index, and installed your package from the feed

If you missed one or more of these steps, review the previous chapters.

## Building the package

Our OpenWrt build system should now be ready for integrating the package to our firmware. In order to do so, we first need to include our package into the target firmware's configuration, and then issue the necessary commands to build it.

Run 'make menuconfig', and select the “Examples” sub-menu. Highlight the “helloworld” entry underneath this menu, and click on the 'Y' key to include this package into the firmware configuration.

Exit the menu, saving your changes. You can then build the package by issuing the following command:

```
make package/helloworld/compile
```

If everything went successfully, we are presented with a brand new package named `helloworld_1.0-1_<arch>.ipk` in `bin/packages/<arch>/mypackages` folder.

## Deploying and testing your package

Now that the package is ready, we can deploy and install it on the target router. The author recommends using a SCP client such as WinSCP in order to transfer the file from the development environment into your router. For installation purposes, you can save the package to the `/tmp` folder on your router.

Assuming you transferred the package to the `/tmp` folder, you can use the OPKG tool to install the package using the following command:

```
root@OpenWrt:/# opkg install /tmp/helloworld_1.0-1_<arch>.ipk
Installing helloworld (1.0-1) to root...
Configuring helloworld.
```

After installation, you should be able to run the application by calling the executable:

```
root@OpenWrt:/# helloworld

Hello, world!
```

## Removing your package

You can remove the installation of the package using the OPKG tool:

```
root@OpenWrt:/# opkg remove helloworld
Removing package helloworld from root...
```

And you can delete the installation package, if you no longer need it:

```
root@OpenWrt:/# rm /tmp/helloworld_1.0-1_<arch>.ipk
```

## Conclusion

In this chapter, we built our package, deployed and installed it to the target device and tested the application to ensure it can be run successfully. Finally, we cleaned up afterwards by removing the package installation and the package file.

← [Previous Chapter](/docs/guide-developer/helloworld/chapter4 "docs:guide-developer:helloworld:chapter4")  

[Helloworld overview](/docs/guide-developer/helloworld/start "docs:guide-developer:helloworld:start")  

 [Next Chapter](/docs/guide-developer/helloworld/chapter6 "docs:guide-developer:helloworld:chapter6") →
