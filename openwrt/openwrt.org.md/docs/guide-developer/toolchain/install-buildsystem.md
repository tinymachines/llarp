# Build system setup

1. Assuming a [GNU/Linux](https://en.wikipedia.org/wiki/Linux "https://en.wikipedia.org/wiki/Linux") environment, otherwise see [alternative guides](/docs/guide-developer/toolchain/start "docs:guide-developer:toolchain:start").
2. Install `Git` to download the source code, and your distro's default `build tools` metapackage to do the cross-compilation process.
3. You may also need to install `Subversion (SVN)` or `Mercurial` to fetch the source-code for some feeds which are not available over Git.
4. Install other prerequisite packages, as indicated in the table and examples below.
5. Unset environment variables like `SED` and `GREP_OPTIONS` and aliases/functions like `which`.

## Prerequisites

This table contains the package name for each build prerequisite in different GNU/Linux and Unix like distributions.

- Bleeding edge distros like [Arch Linux may fail to build base-files](https://forum.openwrt.org/t/solved-build-from-master-on-archlinux-gives-error-for-freadahead-c/18693/6?u=brianbaligad "https://forum.openwrt.org/t/solved-build-from-master-on-archlinux-gives-error-for-freadahead-c/18693/6?u=brianbaligad") if `Cryptographically signed package lists` in `Global build settings` is enabled.

Prerequisite Debian SUSE Red Hat macOS (via MacPorts) Fedora Arch Gentoo asciidoc asciidoc asciidoc asciidoc asciidoc asciidoc asciidoc app-text/asciidoc [GNU Bash](https://en.wikipedia.org/wiki/Bash%20%28Unix%20shell%29 "https://en.wikipedia.org/wiki/Bash (Unix shell)") bash bash bash bash bash bash app-shells/bash [GNU Binutils](https://en.wikipedia.org/wiki/GNU%20Binutils "https://en.wikipedia.org/wiki/GNU Binutils") binutils binutils binutils binutils binutils binutils sys-devel/binutils [bzip2](https://en.wikipedia.org/wiki/bzip2 "https://en.wikipedia.org/wiki/bzip2") bzip2 bzip2 bzip2 bzip2 bzip2 bzip2 app-arch/bzip2 [flex](https://en.wikipedia.org/wiki/flex%20lexical%20analyser "https://en.wikipedia.org/wiki/flex lexical analyser") flex flex flex flex flex flex sys-devel/flex [git](https://en.wikipedia.org/wiki/Git%20%28software%29 "https://en.wikipedia.org/wiki/Git (software)") git git-core git git-core git-core git dev-vcs/git [GNU C++ Compiler](https://en.wikipedia.org/wiki/GNU%20C++%20Compiler "https://en.wikipedia.org/wiki/GNU C++ Compiler") g++ gcc-c++ gcc-c++ ? gcc-c++ gcc sys-devel/gcc [GNU C Compiler](https://en.wikipedia.org/wiki/GNU%20C%20Compiler "https://en.wikipedia.org/wiki/GNU C Compiler") gcc gcc gcc ? gcc gcc sys-devel/gcc GNU Time time time ? gtime ? time sys-process/time getopt util-linux util-linux util-linux getopt util-linux util-linux sys-apps/util-linux [GNU awk](https://en.wikipedia.org/wiki/GNU%20awk "https://en.wikipedia.org/wiki/GNU awk") gawk gawk gawk gawk gawk gawk sys-apps/gawk [gzip](https://en.wikipedia.org/wiki/gzip "https://en.wikipedia.org/wiki/gzip") gzip gzip gzip gzip gzip gzip app-arch/gzip help2man help2man help2man ? help2man help2man help2man sys-apps/help2man intltool-update intltool intltool intltool intltool intltool intltool dev-util/intltool libelf-dev libelf-dev libelf-devel ? libelf elfutils-libelf-devel libelf virtual/libelf libz, libz-dev zlib1g-dev zlib-devel zlib-devel zlib, libzip, libzzip zlib-devel zlib sys-libs/zlib [GNU make](https://en.wikipedia.org/wiki/make%20%28software%29 "https://en.wikipedia.org/wiki/make (software)") make make make gmake make make sys-devel/make [ncurses](https://en.wikipedia.org/wiki/ncurses "https://en.wikipedia.org/wiki/ncurses") libncurses-dev ncurses-devel ncurses-devel ncurses ncurses-devel ncurses sys-libs/ncurses openssl/ssl.h libssl-dev libopenssl-devel openssl-devel openssl openssl-devel openssl dev-libs/openssl patch patch patch patch patchutils patch patch sys-devel/patch perl-ExtUtils-MakeMaker perl-modules perl-ExtUtils-MakeMaker perl-ExtUtils-MakeMaker p5-extutils-makemaker perl-ExtUtils-MakeMaker perl-extutils-makemaker virtual/perl-ExtUtils-MakeMaker perl-FindBin perl-FindBin perl-IPC-Cmd perl-IPC-Cmd perl-Thread-Queue libthread-queue-any-perl ? ? ? perl-Thread-Queue ? virtual/perl-Thread-Queue perl-Time-Piece perl-Time-Piece python2-dev python2-dev python-devel ? python27 ? python2 dev-lang/python:2 ? python3-dev ? ? python310 ? ? ? rsync rsync [SWIG](https://en.wikipedia.org/wiki/SWIG "https://en.wikipedia.org/wiki/SWIG") swig swig swig swig swig swig dev-lang/swig tar tar unzip unzip unzip unzip unzip unzip unzip app-arch/unzip [GNU Wget](https://en.wikipedia.org/wiki/GNU%20Wget "https://en.wikipedia.org/wiki/GNU Wget") wget wget wget wget wget wget net-misc/wget which which xgettext gettext gettext-tools gettext gettext gettext gettext sys-devel/gettext xsltproc xsltproc libxslt-tools ? libxslt libxslt libxslt dev-libs/libxslt zlib, zlib-static zlib1g-dev zlib-devel-static zlib-devel zlib zlib-devel,zlib-static zlib sys-libs/zlib (USE=static-libs)

Note that the advice above may be somewhat outdated. E.g. python3 is currently the default in OpenWrt master, 22.03 and 21.02, while python2.7 has been removed due its end-of-life.

## Package prerequisites

Unfortunately not all dependencies are checked by `make config`, especially for packages. You may encounter compile errors because you need a specific library in your system, and the only way is to search the missing library from the compiler error log and see what package contains it in your own distro.

The following table is a partial list of such dependencies:

Package Prerequisite Debian SUSE Red Hat macOS (via MacPorts) Fedora Arch Gentoo boost bjam / boost-jam libboost-dev boost-devel boost-jam boost-build boost-jam boost dev-util/boost-build intltool \[Perl] XML::Parser libxml-parser-perl perl-XML-Parser perl-XML-Parser p5.28-xml-parser p5.30-xml-parser perl-XML-Parser intltool dev-perl/XML-Parser libftdi (aka: libftdi0) libusb-config libusb-dev libusb-1\_0-devel libusb libusb-devel libusb dev-libs/libusb-compat lilo as86,ld86 bin86 bin86 ([https://software.opensuse.org/package/bin86](https://software.opensuse.org/package/bin86 "https://software.opensuse.org/package/bin86")) binutils dev86 bin86 sys-devel/bin86 lilo bcc[1](http://v3.sk/~lkundrak/dev86/ "http://v3.sk/~lkundrak/dev86/") bcc dev86 ([https://software.opensuse.org/package/dev86](https://software.opensuse.org/package/dev86 "https://software.opensuse.org/package/dev86")) dev86 [aur/bcc](https://aur.archlinux.org/packages/bcc/ "https://aur.archlinux.org/packages/bcc/") sys-devel/dev86 lilo uudecode sharutils sharutils sharutils sharutils sharutils app-arch/sharutils luajit,xdp-tools x86 g++ libs on amd64 hosts gcc-multilib classpath (aka: gnu-classpath) [1](https://en.wikipedia.org/wiki/GNU_Classpath "https://en.wikipedia.org/wiki/GNU_Classpath") javac, gcj openjdk-7-jdk-headless java-1\_8\_0-openjdk-devel openjdk7-zulu java-1.8.0-openjdk-devel jdk7-openjdk dev-java/oracle-jdk-bin, sys-devel/gcc\[gcj], and one (or both) of dev-java/icedtea-bin:7 and dev-java/icedtea:7 mac80211 b43-fwcutter[1](https://wireless.wiki.kernel.org/en/users/drivers/b43 "https://wireless.wiki.kernel.org/en/users/drivers/b43") (Broadcom/BCM) b43-fwcutter b43-fwcutter b43-fwcutter b43-fwcutter net-wireless/b43-fwcutter jamvm[1](https://en.wikipedia.org/wiki/JamVM "https://en.wikipedia.org/wiki/JamVM") zip zip zip zip zip app-arch/zip

## Linux (GNU-Linux) distributions:

Distribution-specific instructions.

Please note that OpenWrt master, 22.03 and 21.02 branches do not need python2.7 any more. Python3 should be your default.

### Alpine

```
apk add argp-standalone asciidoc bash bc binutils bzip2 cdrkit coreutils \
  diffutils elfutils-dev findutils flex musl-fts-dev g++ gawk gcc gettext git \
  grep gzip intltool libxslt linux-headers make musl-libintl musl-obstack-dev \
  ncurses-dev openssl-dev patch perl python3-dev rsync tar \
  unzip util-linux wget zlib-dev
 
# python2-dev required for OpenWrt 19.07 and earlier is not available on Alpine Linux 3.16 and newer 
 
# missing dependency workaround (libtinfo is not installable by any APK package,
# but can be simulated via libncurses (see: https://stackoverflow.com/a/41517423 )
# w/o this - ERROR: package/boot/uboot-mvebu failed to build (build variant: clearfog)
ln -s /usr/lib/libncurses.so /usr/lib/libtinfo.so 
```

### Arch / Manjaro / EndeavourOS

Arch users may install the [openwrt-devel](https://aur.archlinux.org/packages/openwrt-devel/ "https://aur.archlinux.org/packages/openwrt-devel/") meta-package from the [AUR](https://wiki.archlinux.org/index.php/Arch_User_Repository "https://wiki.archlinux.org/index.php/Arch_User_Repository") or alternatively, manually install the build dependencies as follows:

```
# Essential prerequisites
pacman -S --needed base-devel bash bzip2 git libelf libxslt ncurses openssl rsync swig time unzip util-linux wget which zlib
 
# Optional prerequisites, depend on the package selection, there is NOT a need to install all of these
pacman -S --needed asciidoc help2man intltool perl-extutils-makemaker python-setuptools
```

### Fedora / Nobara

```
sudo dnf --setopt install_weak_deps=False --skip-broken install \
bash-completion bzip2 file gcc gcc-c++ git-core make ncurses-devel patch \
rsync tar unzip wget which diffutils python3 python3-setuptools perl-base \
perl-Data-Dumper perl-File-Compare perl-File-Copy perl-FindBin \
perl-IPC-Cmd perl-JSON-PP perl-lib perl-Thread-Queue perl-Time-Piece
```

### Debian / Ubuntu / Mint

Modernized set for Ubuntu 24.04 that has Python 3.12 without python3-distutils: (OpenWrt main/master in Apr 2024)

```
sudo apt update
sudo apt install build-essential clang flex bison g++ gawk \
gcc-multilib g++-multilib gettext git libncurses5-dev libssl-dev \
python3-setuptools rsync swig unzip zlib1g-dev file wget
```

set for Ubuntu 22.04 (that has older Python 3.xx):

```
sudo apt update
sudo apt install build-essential clang flex bison g++ gawk \
gcc-multilib g++-multilib gettext git libncurses-dev libssl-dev \
python3-distutils python3-setuptools rsync swig unzip zlib1g-dev file wget
```

Older advice (for 19.07 and earlier that need python2.7):

```
sudo apt update
sudo apt install build-essential ccache ecj fastjar file g++ gawk \
gettext git java-propose-classpath libelf-dev libncurses5-dev \
libncursesw5-dev libssl-dev python python2.7-dev python3 unzip wget \
python3-distutils python3-setuptools python3-dev rsync subversion \
swig time xsltproc zlib1g-dev 
```

### Gentoo

```
echo \
app-arch/{bzip2,sharutils,unzip,zip} sys-process/time \
app-text/asciidoc \
dev-libs/{libusb-compat,libxslt,openssl} dev-util/intltool \
dev-vcs/{git,mercurial} net-misc/{rsync,wget} \
sys-apps/util-linux sys-devel/{bc,bin86,dev86} \
sys-libs/{ncurses,zlib} virtual/perl-ExtUtils-MakeMaker \
| sed "s/\s/\n/g" \
| sort \
| sudo tee /etc/portage/sets/openwrt-prerequisites \
&& sudo emerge -DuvNa "@openwrt-prerequisites"
```

### openSUSE

```
sudo zypper install --no-recommends asciidoc bash bc binutils bzip2 \
fastjar flex gawk gcc gcc-c++ gettext-tools git git-core intltool \
libopenssl-devel libxslt-tools make mercurial ncurses-devel patch \
perl-ExtUtils-MakeMaker python-devel rsync sdcc unzip util-linux \
wget zlib-devel
```

### Void

```
sudo xbps-install -Su asciidoc bash bc binutils bzip2 cdrtools \
coreutils diffutils findutils flex gawk gcc gettext git grep intltool \
libxslt linux-headers make ncurses-devel openssl-devel patch perl \
pkg-config python3-devel rsync tar unzip util-linux wget \
zlib-devel time libelf perl-ExtUtils-MakeMaker-CPANfile \
help2man swig
 
# for musl version, also install: argp-standalone musl-fts-devel musl-obstack-devel
```

## macOS distributions:

macOS distribution-specific instructions. macOS uses Darwin unix as its core. Xcode/CLT toolchain, &amp; 3rd-party package-manager tool allows to load various common build tools.  
More info: [buildroot.exigence.macosx](https://openwrt.org/docs/guide-developer/toolchain/buildroot.exigence.macosx "https://openwrt.org/docs/guide-developer/toolchain/buildroot.exigence.macosx").

### macOS / Darwin (x86\_64) + MacPorts

```
sudo port install libiconv gettext-runtime coreutils findutils gwhich \
gawk zlib pcre bzip2 ncurses grep getopt gettext-tools-libs gettext \
diffutils sharutils util-linux libxslt libxml2 help2man readline gtime \
gnutar unzip zip lzma xz libelf fastjar libusb libftdi0 expat sqlite3 \
openssl3 openssl kerberos5 dbus lz4 libunistring nettle icu gnutls \
p11-kit wget quilt subversion gmake pkgconfig libzip cdrtools ccache \
curl xxhashlib rsync libidn perl5 p5.28-xml-parser p5.30-xml-parser \
p5-extutils-makemaker p5-data-dumper boost-jam boost boost-build bash \
bash-completion binutils m4 flex intltool patchutils swig git-extras \
git openjdk17 openjdk7-zulu luajit libtool glib2 file python27 \
python310 libzzip mercurial asciidoc sdcc gnu-classpath
```

## Unix distributions:

Distribution-specific instructions.

### FreeBSD

```
...
```
