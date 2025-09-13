# Python

Python is a widely used general-purpose, high-level programming language. Its design philosophy emphasizes code readability, and its syntax allows programmers to express concepts in fewer lines of code than would be possible in languages such as C++ or Java.

There are three main Python packages for OpenWrt; *python*, *python3* and *micropython*.

Main *python* package is much larger than *python-mini* and *python-light* packages so we suggest that you don't even try to install full version unless you have at least 50MB of free space on your flash storage.

If you are using Chaos Calmer then *python-mini* package is replaced by *python-light* package. Currently *python* package adds a lot of dependencies so we suggest that you don't even try to install full version, unless you have at least 50MB of free space on your flash storage.

## Changes in naming since Chaos Calmer

After Barrier Breaker *python* package became:

- **python-base** - just the minimal to have a python interpreter running
- **python-light** - is a “dynamic” package; it's python (full) minus all other python-codecs, python-compiler, etc
- **python** - full python install, minus a few stuff that could be stripped \[to reduce size], like tests \[per module], some python-tk/tcl \[GUI] libs

The idea of **python-light** is that, whenever you move a Python built-in module from python-light into a separate package (like python-codecs), python-light gets lighter. The mechanism is fairly dynamic; you just need to add a new 'python-package-xxxxxxx.mk' file with some basic Makefile rules, and that's it.

People can choose to install **python-base** if they need like really-really-really-really basic python (a = b + c and maybe some other syntax). Then they can choose to install other optional packages.

All other packages depend on **python-light**, because that one has some common libs.

The above is also true for python3.

## Make Python code run much faster by pre-compiling python py modules into pyc

To compile all python modules into pyc issue this command:

```
python -m compileall
```

Make sure you have at least 7MB of free space on your internal storage!

Now my python scripts start under 1.5 seconds and previously it would take them 6-8 seconds!

If you have additional python modules installed you need to compile them also, so for me I needed to additionally run these commands:

```
python -m compileall /usr/lib/python2.7/site-packages/serial/*.py
python -m compileall /usr/lib/python2.7/site-packages/serial/tools/*.py
python -m compileall /usr/lib/python2.7/site-packages/serial/urlhandler/*.py
```

## Installing Python

### Storage use

#### Barrier Breaker and earlier

*python-mini* uses around 1.5 MB of compressed space on squashfs /overlay partition or 4.5 MB uncompressed in /tmp (tmpfs ram) partition.

To install python mini just use:

```
opkg update
opkg install python-mini
```

#### Chaos Calmer and later

*python-light* uses around 7.2 MB of space.

To install *python-light* just use:

```
opkg update
opkg install python-light
```

**Note:** all these sizes are arbitrary and have been obtained from building an **ar71xx** image.

At the time of writing this doc (3rd of July), the **python** package is comprised of

- **python-base** - takes up around 2.2 MB - you really cannot go any lower than this with Python to run
- **python-light** - (adds 5.0 MB) is **python-base** + a few python libs that have not been stripped out Python's default lib dir (like the ones below) ; all of the libs presented below take up a few hundred (or more) KB, which add up (especially when counting up dependencies) and are not used by everyone ; takes around 4 MB which is a lot of your flash size is 4-8-16-32 MB, but at least

All packages below, depend on **python-light**, so if you decide to install any of them, you'll get **python-light** too.

- **python-codecs** - (3 MB) the *import codecs* lib
- **python-compiler** - (240k) compiler lib support, for working with compiler paths/env vars
- **python-ctypes** - (580k + 44k libffi) ctypes lib/support ; this is also install the **libffi** lib
- **python-db** - (584k + 992k libdb-47) Berkley DB support; this also installs the **libdb-47** package
- **python-decimal** - (248k) - decimal support lib/logic ; it's pretty useful for abstracting numeric logic (floats and stuff) away from machine-dependant floats ; it is fairly big though just for decimals
- **python-distutils** - (1.7 MB) support for packaging for various distributions, and various distro-type support
- **python-email** - (768K) email libs/logic
- **python-logging** - (180k) *import logging*
- **python-multiprocessing** - (264k)
- **python-ncurses** - (169k + 304k libncurses) support for **libncurses** ( not **libncursesw** ) ; also install **libncuses**
- **python-openssl** - (140k + 1.9M libopenssl) Python can be compiled with SSL support, but not have this lib around; this lib is also used for MD5 and some SHA hash stuff; it also installs **libopenssl**, but on a devices where you need this, you'd typically already have it installed
- **python-pydoc** - (640k) generation of doc pages from Python comments
- **python-sqlite3** - (240k + 616k) also installs **libsqlite3**
- **python-unittest** - (400k) unit-test support
- **python-xml** - (692k + 984k libxml2) basic XML support ; Python's XML support is not that great anyway; this installs **libxml2** too

There is no general recipe that works for everyone and keeps Python small, so anyone wanting Python on a device will have to install it step-by-step depending on the features you'd want.

We hope **python-light** will accommodate most needs. This package will become lighter if it makes sense to split some other lib out of it.

#### Installing Python into tmpfs RAM drive

If you don't have at least 7.5 MB of free space on your / partition (check with “df -h”) then install *python-mini* or *python-light* to your /tmp ram drive with:

Barrier Breaker:

```
opkg update
opkg install python-mini -d ram
export PATH=$PATH:/tmp/usr/bin/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/tmp/usr/lib/
```

Chaos Calmer and later:

```
opkg update
opkg install python-light -d ram
export PATH=$PATH:/tmp/usr/bin/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/tmp/usr/lib/
```

## Installing Python3

## Building Python/Python3

Python is part of the package feeds, so you need to make sure you have the Packages feed configured in feeds.conf or feeds.conf.default.

```
src-git packages https://github.com/openwrt/packages.git
```

And then:

```
cd <your-openwrt-folder>
./scripts/feeds update packages 
./scripts/feeds install python <or python3 if you want that too>
```

Then you should have Python (and/or Python3) in your **make menuconfig** under **Languages =⇒ Python**

Note that you'll get a lot of Python/Python3 packages, as the ones detailed above, as they've been split to reduce size.
