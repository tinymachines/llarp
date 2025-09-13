# GNU Debugger

- **`Note:`** This guide is by no means a Howto, just some short instructions to use GDB on OpenWrt.  
  Please look upstream for multilingual instructions and manuals, like e.g. here: [https://sourceware.org/gdb/documentation/](https://sourceware.org/gdb/documentation/ "https://sourceware.org/gdb/documentation/")

## Compiling Tools

in [menuconfig](/docs/guide-developer/toolchain/use-buildsystem#image_configuration "docs:guide-developer:toolchain:use-buildsystem") enable gdb

```
Advanced configuration options (for developers) -> Toolchain Options ->  Build gdb
```

and gdbserver

```
Development -> gdbserver
```

## Add debugging to a package

Add CFLAGS to the package Makefile and recompile it.

```
TARGET_CFLAGS += -ggdb3
```

Alternatively recompile the package with `CONFIG_DEBUG` set

```
make package/busybox/{clean,compile} V=s CONFIG_DEBUG=y
```

Or you can enable debug info in [menuconfig](/docs/guide-developer/toolchain/use-buildsystem#image_configuration "docs:guide-developer:toolchain:use-buildsystem")

```
Global build settings > Compile packages with debugging info
```

## Starting GNU Debugger

Start gdbserver on target (router)

```
gdbserver :9000 /bin/ping example.org
```

Start gdb on host (in compiling tree)

```
./scripts/remote-gdb 192.168.1.1:9000 ./build_dir/target-*/busybox-*/busybox
```

now you have a gdb shell. Set breakpoints, start program, backtrace etc.

```
(gdb) b source-file.c:123
(gdb) c
(gdb) bt
```

If you want to restart the program, you'll need to set the remote path and arguments

```
(gdb) set remote exec-file /usr/bin/blah
(gdb) set args -v -x -merry-fishing
(gdb) run
```
