# OpenWrt security features

This page should give an overview of the current features used to secure OpenWrt.

## build system

### package signing

The list of available packages which a user can later install is digitally signed by default. This way a OpenWrt instance can verify the integrity of the package list. This package list contains the SHA256 hash values of all available packages. The build key used for the OpenWrt binary releases is signed by many OpenWrt committers. In private builds the build system automatically generates a private and public key to sign the package list.

## Build hardening

### RELRO protection

Link-time protection known as RELRO (Relocation Read Only) which helps to protect from certain type of exploitation techniques altering the content of some ELF sections. “Partial” RELRO makes the .dynamic section not writable after initialization, introducing almost no performance penalty, while “full” RELRO also marks the GOT as read-only at the cost of initializing all of it at startup. Full is used by default.

### Buffer-overflow detection (FORTIFY\_SOURCE)

The \_FORTIFY\_SOURCE macro which introduces additional checks to detect buffer-overflows in the following standard library functions: memcpy, mempcpy, memmove, memset, strcpy, stpcpy, strncpy, strcat, strncat, sprintf, vsprintf, snprintf, vsnprintf, gets. “Conservative” (\_FORTIFY\_SOURCE set to 1) only introduces checks that shouldn't change the behavior of conforming programs, while “aggressive” (\_FORTIFY\_SOURCES set to 2) some more checking is added, but some conforming programs might fail. Conservative is used by default.

### Kernel space Stack-Smashing Protection

GCC Stack-Smashing Protection (SSP) for the kernel Regular is used by default

### User space Stack-Smashing Protection

GCC Stack Smashing Protection (SSP) for user space applications Regular is used by default

### GCC format-security

Add -Wformat -Werror=format-security to the CFLAGS. You can disable this per package by adding PKG\_CHECK\_FORMAT\_SECURITY:=0 in the package Makefile.

## Separation

### Separate users for processes

procd can start a process under a different user, this account is automatically created by the build system. When someone attacks this application the attacker does not gain root privileges immediately.

### procd jail

In addition to running processes under different users, it is possible to put them into a own chroot environment where they can only access a limited number of resources which are needed by this daemon.

## Incident handling

Like every Linux distribution, OpenWrt ships a lot of different components and researchers constantly find security problems in them. For example between January and June 2017 over 300 security issues were found and fixed in the Linux kernel. The projects behind OpenSSL, Samba, mbedtls and many other applications/libraries are shipping versions which are fixing severe security problems multiple times a year which have to get addressed by the OpenWrt project.

### Userspace applications

When we get informed by a security problem in some third party application, like from the press, or from some announcement mail or form the upstream project, we try to integrate the fix into the OpenWrt master code based and also backport it to the latest release branch. Sometimes only the minimal patch which fixes the problem gets backported, sometimes the next minor version of the application is used.

In addition we use this uscan tool which checks if new versions of some application are available and the maintainer of such an application gets a mail notification. Then the maintainer should check if this new version contains important updates. uscan is also able to check for CVE numbers, but this does not work very reliable. [https://sdwalker.github.io/uscan](https://sdwalker.github.io/uscan "https://sdwalker.github.io/uscan")

For our released versions, all the shared userspace applications (e.g. openssl, samba, mbedtls) are rebuilt after someone pushed an update to the repository. After they are rebuilt, they are automatically getting shipped to the user who can install them on their devices with opkg.

TODO: extend opkg

### Kernel

Update of the Linux kernel is not so easy on most device supported by OpenWrt, because the kernel is stored directly on some partition on flash and the root file system is directly appended to the kernel image. Security updates to the Linux kernel and its modules are only shipped with a next minor release version which is created every 1 to 3 months. This update requires a complete OpenWrt upgrade using sysupgrade. Before a new minor release is done the kernel is upgraded to the latest stable kernel version e.g. from 4.4.61 to 4.4.71 on all targets.

## Remote access

Login via encrypted SSH is supported by default. Telnet access is not supported. When LUCI is installed login with unencrypted HTTP is supported. When LUCI and SSL package is installed in addition login over TLS encrypted HTTP is supported. The server keys for SSH and TLS are generated at first boot and are self-signed. This way each device uses an individual and unpredictable private key. There is only one account (root) that can be used to log in by default.

The UART allows passwordless root login all the time, but to access it physical access to the device is needed. This helps for recovery and for debugging. An attacker with physical access could also directly read and write from the flash chip without using the main application processor.

### Initial setup

OpenWrt uses passwordless SSH to provide access by default . OpenWrt does not use an individual default password because OpenWrt is not installed by the vendor onto the device who can do an individual provisioning of the device. When an image with an Web UI was installed it also allows passwordless login there.

A warning message that encourages to set a individual password is shown when no password was is set.

### After initial configuration

An individual root password should be set by the user, then password less login is not possible any more. It is also possible to use SSH private public keys for authentication.
