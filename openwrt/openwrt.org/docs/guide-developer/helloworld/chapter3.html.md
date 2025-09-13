← [Previous Chapter](/docs/guide-developer/helloworld/chapter2 "docs:guide-developer:helloworld:chapter2")  

 [Next Chapter](/docs/guide-developer/helloworld/chapter4 "docs:guide-developer:helloworld:chapter4") →

# Creating a package from your application

This is the third chapter in the “Hello, world!” for OpenWrt article series. At this point, you should've already accomplished the following tasks:

- Commissioned your development environment
- Prepared, configured and built the tools and the cross-compilation toolchain
- Configured the PATH environment variable
- Created a simple “Hello, world!” application using native compilation tools

If you missed one or more of these steps, review the previous chapters.

## Creating a package feed for your packages

The OpenWrt build system revolves heavily around the concept of packages. They are the bread and butter of the system. No matter the software, there's almost always a package for it. This applies to nearly everything in the system, be it the target-independent tools, the cross-compilation toolchain, the Linux kernel of the target firmware, the additional modules that are bundled with the kernel or the various applications that will be installed onto the root file system of the target firmware.

Due to this package-oriented nature, it is only logical to utilize the same approach for the “Hello, World! -application as well.

The primary delivery system for packages that are not an integral part of the build system itself is a package feed. It is simply a repository of packages that are candidates for inclusion into the final firmware. The repository can reside on a local directory, or it can be on a network share or it can be on a version control system such as GitHub. Creating and maintaining a package feed allows us to maintain our separation of concerns by keeping the package-related files separate from the source code of our sample application.

For the purposes of this article, we create a new package repository into a local directory. The name of this repository is 'mypackages', and it contains a single category called 'examples'. In this category, there is only a single entry, our 'helloworld' application:

```
cd /home/buildbot
mkdir -p mypackages/examples/helloworld
```

## Creating the package manifest file

Each package in the OpenWrt build system is described by a package manifest file. The manifest file is responsible for describing the package, what it does, and must at least provide instructions on where to obtain the source code, how to build it and which files should be contained in the final installable package. A package manifest may additionally contain options for optional configuration scripts, specify dependencies between packages and so on.

In order for the source code of our application to become a package, and become a part of the package repository that we previously created, we will need to create a package manifest for it:

```
cd home/buildbot/mypackages/examples/helloworld
touch Makefile
```

Using your favorite text editor, enter the following text as the content of the package manifest. Note that several sections of this file are used by the build system's own GNU make tool, and for this reason, there are **both shorter and longer whitespace indentations** in the file. Shorter ones are simple space characters, while the longer ones are hard tabs. Note that some code editors may convert the tab character to space characters but [GNU make does not accept spaces](https://beebo.org/haycorn/2015-04-20_tabs-and-makefiles.html "https://beebo.org/haycorn/2015-04-20_tabs-and-makefiles.html").

[Makefile](/_export/code/docs/guide-developer/helloworld/chapter3?codeblock=2 "Download Snippet")

```
include $(TOPDIR)/rules.mk
 
# Name, version and release number
# The name and version of your package are used to define the variable to point to the build directory of your package: $(PKG_BUILD_DIR)
PKG_NAME:=helloworld
PKG_VERSION:=1.0
PKG_RELEASE:=1
 
# Source settings (i.e. where to find the source codes)
# This is a custom variable, used below
SOURCE_DIR:=/home/buildbot/helloworld
 
include $(INCLUDE_DIR)/package.mk
 
# Package definition; instructs on how and where our package will appear in the overall configuration menu ('make menuconfig')
define Package/helloworld
  SECTION:=examples
  CATEGORY:=Examples
  TITLE:=Hello, World!
endef
 
# Package description; a more verbose description on what our package does
define Package/helloworld/description
  A simple "Hello, world!" -application.
endef
 
# Package preparation instructions; create the build directory and copy the source code. 
# The last command is necessary to ensure our preparation instructions remain compatible with the patching system.
define Build/Prepare
		mkdir -p $(PKG_BUILD_DIR)
		cp $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
		$(Build/Patch)
endef
 
# Package build instructions; invoke the target-specific compiler to first compile the source file, and then to link the file into the final executable
define Build/Compile
		$(TARGET_CC) $(TARGET_CFLAGS) -o $(PKG_BUILD_DIR)/helloworld.o -c $(PKG_BUILD_DIR)/helloworld.c
		$(TARGET_CC) $(TARGET_LDFLAGS) -o $(PKG_BUILD_DIR)/$1 $(PKG_BUILD_DIR)/helloworld.o
endef
 
# Package install instructions; create a directory inside the package to hold our executable, and then copy the executable we built previously into the folder
define Package/helloworld/install
		$(INSTALL_DIR) $(1)/usr/bin
		$(INSTALL_BIN) $(PKG_BUILD_DIR)/helloworld $(1)/usr/bin
endef
 
# This command is always the last, it uses the definitions and variables we give above in order to get the job done
$(eval $(call BuildPackage,helloworld))
```

A complete dissection of the package manifest file will not be performed in this article, as that is a subject best left to an article of its own. Hopefully the comments will assist in understanding what each section is intended for. There are many, many ways to define packages and their build instructions; this example is just one of many.

The package manifest system contains a lot of variables and intelligent defaults, and often giving explicit instructions like we do above is not even necessary. For the purposes of this article, the level of detail in the package manifest is higher. We also make use of some of these pre-defined variables to determine the cross-compilation tool, and target-dependent compilation and linking flags. Again, wading through all of these defaults and variables is a subject for another article altogether.

## Conclusion

In this chapter, we created a new local package feed and added a package manifest file for the application, specifying the name, version, description and build instructions on how to construct an installable package from the source code we wrote in the previous chapter.

← [Previous Chapter](/docs/guide-developer/helloworld/chapter2 "docs:guide-developer:helloworld:chapter2")  

[Helloworld overview](/docs/guide-developer/helloworld/start "docs:guide-developer:helloworld:start")  

 [Next Chapter](/docs/guide-developer/helloworld/chapter4 "docs:guide-developer:helloworld:chapter4") →
