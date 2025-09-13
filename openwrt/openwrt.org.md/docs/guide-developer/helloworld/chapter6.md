← [Previous Chapter](/docs/guide-developer/helloworld/chapter5 "docs:guide-developer:helloworld:chapter5")  

 [Next Chapter](/docs/guide-developer/helloworld/chapter7 "docs:guide-developer:helloworld:chapter7") →

# Migrating to use GNU make in your application

This is the sixth chapter in the “Hello, world!” for OpenWrt article series. At this point, you should've already accomplished the following tasks:

- Commissioned your development environment
- Prepared, configured and built the tools and the cross-compilation toolchain
- Configured the `PATH` environment variable
- Created a simple “Hello, world!” application using native compilation tools
- Created a local package feed for your application
- Created a package manifest file for your application
- Included your new package feed into the OpenWrt build system
- Updated the package index, and installed your package from the feed
- Built, deployed and tested the application on your target device

If you missed one or more of these steps, review the previous chapters.

## Why use GNU make ?

Our test application is still quite simple, containing only a single source file. As a result, it is quite straightforward to compile and link it, although the syntax to do so is somewhat obscure in the package manifest:

[Makefile](/_export/code/docs/guide-developer/helloworld/chapter6?codeblock=0 "Download Snippet")

```
# Package build instructions; invoke the target-specific compiler to first compile the source file, and then to link the file into the final executable
define Build/Compile
        $(TARGET_CC) $(TARGET_CFLAGS) -o $(PKG_BUILD_DIR)/helloworld.o -c $(PKG_BUILD_DIR)/helloworld.c
        $(TARGET_CC) $(TARGET_LDFLAGS) -o $(PKG_BUILD_DIR)/$1 $(PKG_BUILD_DIR)/helloworld.o
endef
```

As we can see, it is necessary to specify quite many options, including compilation and linking flags, source and object file names, and even the final executable name.

The working directory of the build system, when executing the instructions in the package manifest file, is the root directory where the package manifest file itself is found. As a result, if the folder variables such as $(PKG\_BUILD\_DIR) are not used, then the source files may not be found or the build artifacts may be placed into the incorrect directory.

Using GNU make is one approach to solving some of these problems.

## Creating a Makefile

In order to use GNU make, it is necessary to create a Makefile for our test application. When writing the Makefile, you will only need to pay attention to the source files of your application; the integration into the OpenWrt build system is done at a later stage.

Let's change to the source directory of the application and create the Makefile:

[Makefile](/_export/code/docs/guide-developer/helloworld/chapter6?codeblock=1 "Download Snippet")

```
cd /home/buildbot/helloworld
touch Makefile
```

Using a text editor, paste the following content into the file. Note that similar to the package manifest, the Makefile contains long whitespace indentations. They should be replaced with a hard tab character when editing the file:

[Makefile](/_export/code/docs/guide-developer/helloworld/chapter6?codeblock=2 "Download Snippet")

```
# Global target; when 'make' is run without arguments, this is what it should do
all: helloworld
 
# These variables hold the name of the compilation tool, the compilation flags and the link flags
# We make use of these variables in the package manifest
CC = gcc
CFLAGS = -Wall
LDFLAGS = 
 
# This variable identifies all header files in the directory; we use it to create a dependency chain between the object files and the source files
# This approach will re-build your application whenever any header file changes. In a more complex application, such behavior is often undesirable
DEPS = $(wildcard *.h)
 
# This variable holds all source files to consider for the build; we use a wildcard to pick all files
SRC = $(wildcard *.c)
 
# This variable holds all object file names, constructed from the source file names using pattern substitution
OBJ = $(patsubst %.c, %.o, $(SRC))
 
# This rule builds individual object files, and depends on the corresponding C source files and the header files
%.o: %.c $(DEPS)
        $(CC) -c -o $@ $< $(CFLAGS)
 
# To build 'helloworld', we depend on the object files, and link them all into a single executable using the compilation tool
# We use automatic variables to specify the final executable name 'helloworld', using '$@' and the '$^' will hold the names of all the
# dependencies of this rule
helloworld: $(OBJ)
        $(CC) -o $@ $^ $(LDFLAGS)
 
# To clean build artifacts, we specify a 'clean' rule, and use PHONY to indicate that this rule never matches with a potential file in the directory
.PHONY: clean
 
clean:
        rm -f helloworld *.o        
```

## Testing the Makefile using native tools

Before modifying our package manifest, it is important that we test the makefile-based build process. To build the 'helloworld' executable, you can simply issue the following command:

```
make
```

If you get the message ``make: Nothing to be done for `all` `` this means the executable is already up to date. To mimic a change in the code, let's update the source file, then try the make command again:

```
touch helloworld.c
make
```

This will build the application using the native compilation tools.

You'll see that GNU `make` will output the steps it took to build the application and that these steps are quite similar to the manual steps you took in chapter 2. If you encounter errors during the process, then one of the most common errors is that the whitespaces at the start of the rows in the Makefile are not tab characters.

## Modifying the package manifest, and testing the build

Now that our package's Makefile is created and tested, we can integrate it into the package manifest. To do so, we modify the build instructions in the package manifest to contain the necessary instructions. This file is located in `/home/buildbot/mypackages/examples/helloworld/` directory. Open this particular `Makefile` in your preferred editor.

When migrating to use the GNU make tool, you might not need to use hard tabs anymore. However, I find it good practise to use a hard tab at the start of each command row. When using the multi-line separator '\\', the adjacent lines do not need hard tabs.

[Makefile](/_export/code/docs/guide-developer/helloworld/chapter6?codeblock=5 "Download Snippet")

```
# Package build instructions; invoke the GNU make tool to build our package
define Build/Compile
        $(MAKE) -C $(PKG_BUILD_DIR) \
               CC="$(TARGET_CC)" \
           CFLAGS="$(TARGET_CFLAGS)" \
          LDFLAGS="$(TARGET_LDFLAGS)"
endef
```

After modifying your package manifest, test the package build process again from the OpenWrt build system's folder:

```
cd /home/buildbot/source
make package/helloworld/{clean,compile}
```

This command performs both package clean and compile in a one-liner.

If you encounter errors when building it using GNU make, it is sometimes necessary to manually update and install the feeds. Perform the same steps that we did in chapter 4:

```
cd /home/buildbot/source
./scripts/feeds update mypackages
./scripts/feeds install -a -p mypackages
```

If still having issues, ensure your source directory (/home/buildbot/helloworld) is cleaned of any \*.o files or final executables built for your host rather than OpenWRT (only `.c` and `Makefile`).

## Conclusion

In this lengthy chapter, we modified our original application to use GNU make instead of direct compilation commands. We wrote a simple makefile to evaluate all source code files in the directory, compile them, and link the generated object files into an executable. We then tested the makefile using native compilation tools to ensure it runs properly, and finally modified our package manifest to use the GNU make build process instead of the hard-coded compilation commands.

← [Previous Chapter](/docs/guide-developer/helloworld/chapter5 "docs:guide-developer:helloworld:chapter5")  

[Helloworld overview](/docs/guide-developer/helloworld/start "docs:guide-developer:helloworld:start")  

 [Next Chapter](/docs/guide-developer/helloworld/chapter7 "docs:guide-developer:helloworld:chapter7") →
