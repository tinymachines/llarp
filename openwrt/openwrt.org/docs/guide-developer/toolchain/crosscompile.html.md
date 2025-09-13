# Cross compiling

If you want to use a [program](https://en.wikipedia.org/wiki/Computer_program "https://en.wikipedia.org/wiki/Computer_program"), currently not contained in the OpenWrt repository, you probably won't find a binary compiled for your CPU. Provided that it is released as open source, you can download the code and compile it using the [OpenWrt Buildroot](/docs/guide-developer/toolchain/start "docs:guide-developer:toolchain:start").

Note that not every code is compilable for every CPU architecture. Also performance and available RAM on embedded systems is limited compared to ordinary computers.

## Procedure

- Follow the build instructions outlined in [OpenWrt Buildroot – Usage](/docs/guide-developer/toolchain/start "docs:guide-developer:toolchain:start")
- Locate the toolchain binaries in the `staging_dir/toolchain-architecture_gcc-compilerver_uClibc-libcver/bin/` directory
- Add that directory to the `PATH` environment variable:
  
  - `PATH=$PATH:(your toolchain/bin directory here)`
  - `export PATH`
- Set the `STAGING_DIR` environment variable to the above toolchain dir and export it:
  
  - `STAGING_DIR=(your toolchain directory here)`
  - `export STAGING_DIR`
- Download and unpack the code to be compiled, change into the unpacked directory
- Pass the *host* and *build* to the build system of the package to trigger cross-compile
  
  - For GNU configure, use `--build=architecture-unknown-linux-gnu --host=architecture-openwrt-linux-uclibc` (for example: `./configure --build=x86_64-unknown-linux-gnu --host=mips-openwrt-linux-uclibc`)
    
    - Run `./config.guess` to get the `--build=` option.
    - Check the output and ensure that `'checking whether we are cross compiling... yes`' is yes.
  - For GNU make, override the `CC` and `LD` environment variables (usually not needed if GNU configure was used)
    
    - `make CC=architecture-openwrt-linux-uclibc-gcc` `LD=architecture-openwrt-linux-uclibc-ld`
- The compiled program will be somewhere inside the folder your run ./configure and make from, try doing `find -iname *program*`
- Run `file program` to confirm cross-compiling was successful.
- If compilation aborts due to missing header files or shared objects, you might need to override `CFLAGS` and `LDFLAGS` to point to the `staging_dir/target-architecture_uClibc-libcver/usr/include` and `.../usr/lib` directories
- Debugging requires gdb in the toolchain. Default config does not include it. Include using `make menuconfig`. \[Advanced configuration options→Toolchain Options→Build gdb]
- Remote debugging can be done using script `./scripts/remote-gdb`

When compilation is finished, copy the resulting binary and related libraries to the target device to test it. It might be necessary to set `LD_LIBRARY_PATH` on the target to point the binary to libraries in non-standard locations.

If the program works well enough, you maybe want to build a real package for the opkg package manager and make it easily accessible for everyone out there. See [Creating your own packages](/docs/guide-developer/packages "docs:guide-developer:packages") and [Using Dependencies](/docs/guide-developer/dependencies "docs:guide-developer:dependencies") for further information on that.
