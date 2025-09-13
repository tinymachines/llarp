# Cryptographic Hardware Accelerators

A Cryptographic Hardware Accelerator can be

- integrated into the [soc](/docs/techref/hardware/soc "docs:techref:hardware:soc") as a separate processor, as a special purpose CPU (aka Core).
- integrated in a [Coprocessor](https://en.wikipedia.org/wiki/Coprocessor "https://en.wikipedia.org/wiki/Coprocessor") on the circuit board
- contained on a Chip on an extension circuit board, this can be connected to the mainboard via some BUS, e.g. PCI
- an [ISA extension](https://en.wikipedia.org/wiki/Template:Multimedia_extensions "https://en.wikipedia.org/wiki/Template:Multimedia_extensions") like e.g. [AES instruction set](https://en.wikipedia.org/wiki/AES%20instruction%20set "https://en.wikipedia.org/wiki/AES instruction set") and thus integral part of the CPU (in that case, a kernel driver is not needed)

The purpose is to offload the very computing intensive tasks of encryption/decryption and compression/decompression.  
As can be seen in this [AES instruction set](https://en.wikipedia.org/wiki/AES%20instruction%20set "https://en.wikipedia.org/wiki/AES instruction set") article, the acceleration is usually achieved by doing certain arithmetic calculation in hardware.

Its use in applications usually involves a number of layers:

- The kernel needs a hardware-specific driver to use its capabilities. It is usually built into the kernel for boards that support them, and allows access by services that run in kernel-mode.

<!--THE END-->

- To use them in userspace, when the acceleration is not in the instruction set of the CPU, it is supported via a kernel driver (/dev/crypto or AF\_ALG socket).

<!--THE END-->

- The above steps provide the bare minimum to allow userspace use, but it is more usual to use them inside a crypto library, such as gnutls or openssl, allowing access by most apps linked to them.

## Performance

Depending on which arithmetic calculations are being done in the specific hardware, the results differ widely. You should not concern yourself with theoretical bla,bla but find out how a certain implementation performs in the task you want to do with it!

- You could attach a USB drive to your device and mount a [local filesystem](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives") like ext3 from it. Then you want to read from and write to this filesystem from the Internet over a secured protocol. Let's use `sshfs`. You would set up a [sshfs.server](/docs/guide-user/services/ssh/sshfs.server "docs:guide-user:services:ssh:sshfs.server") on your device and a [sshfs.client](/docs/guide-user/services/ssh/sshfs.client "docs:guide-user:services:ssh:sshfs.client") on the other end. Now how fast can you read/write to this with and without Cryptographic Hardware Accelerators. If the other end, the client, is a “fully grown PC” with a 2GHz CPU, it will probably perform fast enough to use the entire bandwidth of your Internet connection. If the server side is some embedded device, with let's say some 400MHz MIPS CPU, it will benefit highly from some integrated (and supported!) acceleration. You probably want sufficient performance such that you can consume your entire bandwidth. Now go and find some benchmark showing you the difference; both with and without acceleration. You will not be able to extrapolate this information from specifications you find on this page or on the web.

<!--THE END-->

- you may wish to run an OpenVPN or an OpenConnect server on your router/embedded device, instead of using WEP/WPA/WPA2. There will be no reading from/writing to a USB device. Find benchmarks that show you exactly the performance for this purpose. You won't be able to extrapolate this information from other benchmarks.

<!--THE END-->

- think of other practical uses, and find specific benchmarks.

## Finding out what's available in the Kernel

If your board has cryptographic acceleration hardware, the respective drivers should already be built into the kernel. Some crypto engines have their own packages, and these may need to be installed first.

To see all of the available crypto drivers running on your system (this means **after** installing the packages, if needed), take a look at `/proc/crypto`.

```
# cat /proc/crypto
name         : cbc(aes)
driver       : mv-cbc-aes
module       : kernel
priority     : 300
refcnt       : 1
selftest     : passed
internal     : no
type         : skcipher
async        : yes
blocksize    : 16
min keysize  : 16
max keysize  : 32
ivsize       : 16
chunksize    : 16
walksize     : 16

name         : cbc(aes)
driver       : cbc-aes-neonbs
module       : kernel
priority     : 250
refcnt       : 1
selftest     : passed
internal     : no
type         : skcipher
async        : yes
blocksize    : 16
min keysize  : 16
max keysize  : 32
ivsize       : 16
chunksize    : 16
walksize     : 16

name         : sha256
driver       : mv-sha256
module       : kernel
priority     : 300
refcnt       : 1
selftest     : passed
internal     : no
type         : ahash
async        : yes
blocksize    : 64
digestsize   : 32

name         : sha256
driver       : sha256-neon
module       : kernel
priority     : 250
refcnt       : 2
selftest     : passed
internal     : no
type         : shash
blocksize    : 64
digestsize   : 32

name         : sha256
driver       : sha256-asm
module       : kernel
priority     : 150
refcnt       : 1
selftest     : passed
internal     : no
type         : shash
blocksize    : 64
digestsize   : 32

name         : sha256
driver       : sha256-generic
module       : sha256_generic
priority     : 100
refcnt       : 1
selftest     : passed
internal     : no
type         : shash
blocksize    : 64
digestsize   : 32
```

This was cropped to show only AES-CBC and SHA256. Both AF\_ALG and `/dev/crypto` interfaces allow userspace access to any crypto driver offering symmetric-key ciphers, and digest algorithms. This means hardware acceleration, but also software-only drivers. The use of software drivers is almost always slower than an implementation in userspace, because the context switches slow operations down considerably.

To identify hardware-drivers, look for drivers with types `skcipher` and `shash`, having priority &gt;= 300, but beware that AES-NI and similar CPU instructions will have a high priority as well, and do not need `/dev/crypto` or AF\_ALG to be used!

Notice in this case the two drivers offering `cbc(aes)`: `cbc-aes-neonbs` (software driver, using neon asm instruction, and `mv-cbc-aes` (Marvell CESA, hw accelerated), and four offering `sha256`: `sha256-generic` (soft, generic C code), `sha256-asm` (soft, basic arm asm), `sha256-neon` (soft, using neon asm instruction), and `mv-sha256` (Marvell CESA). The kernel will export the one with the highest priority for each algorithm. In this case, it would be the hw accelerated Marvell CESA drivers: mv-cbc-aes, and mv-sha256.

For IPsec ESP, which is done by the Kernel, this will be enough to tell you if you are able to use the crypto accelerator, and you don't need to do anything further. Just make sure you're using the same algorithm made available by your crypto driver. For other uses, openssl should be checked.

## Enabling the userspace interface

The crypto drivers enable the algorithms for kernel use. To be able to access them from userspace, another driver needs to be used. In OpenWrt, there are two of them: `cryptodev`, and `AF_ALG`. Opinions on the subject may vary, but `cryptodev` has the speed advantage here.

### cryptodev

Cryptodev uses a `/dev/crypto` device to export the kernel algorithms. In OpenWrt 19.07 and later, it is provided by the `kmod-cryptodev` and is installed automatically when you install `libopenssl-devcrypto`.

In OpenWrt 18.06.x and earlier, `/dev/crypto` required compiling the driver yourself. Run `make menuconfig` and select

- kmod-crypto-core: m
  
  - kmod-cryptodev: m

Installing the \`kmod-cryptodev\` package will create a \`/dev/crypto\` device, even if you don't have any hw-crypto. **`/dev/crypto` will export kernel crypto drivers regardless of being implemented in software or hardware. Use of kernel software drivers may severely slow crypto performance, so don't install this package unless you know you have hw-crypto drivers installed!**

### AF\_ALG

The AF\_ALG interface uses sockets to allow access to the kernel crypto algorithms, so you won't see anything in the filesystem. It is provided by the `kmod-crypto-user` package.

## Checking openssl support

Openssl supports hardware crypto acceleration through an engine. You can see what engines are available, along with the enabled algorithms, and configuration commands by running `openssl engine -t -c`:

```
(devcrypto) /dev/crypto engine
 [DES-CBC, DES-EDE3-CBC, BF-CBC, AES-128-CBC, AES-192-CBC, AES-256-CBC, AES-128-CTR, AES-192-CTR, AES-256-CTR, AES-128-ECB, AES-192-ECB, AES-256-ECB, CAMELLIA-128-CBC,
CAMELLIA-192-CBC, CAMELLIA-256-CBC,MD5, SHA1, RIPEMD160, SHA224, SHA256, SHA384, SHA512]
     [ available ]
(rdrand) Intel RDRAND engine
 [RAND]
     [ available ]
(dynamic) Dynamic engine loading support
     [ unavailable ]
```

For openssl-1.0.2 and earlier, the engine was called `cryptodev`. It was renamed to `devcrypto` in openssl 1.1.0. In this example, engine 'devcrypto' is available, showing the list of algorithms available.

Starting in OpenSSL 1.1.0, an AF\_ALG engine can be used. In OpenWrt 19.07, it is packaged as `libopenssl-afalg`, but it requires a custom build: the package will not show up under 'Libraries', 'SSL', 'libopenssl' unless you go to 'Global build settings', 'Kernel build options', and select 'Compile the kernel with asynchronous IO support'. This engine supports only AES-CBC, and needs to be enabled in `/etc/ssl/openssl.cnf`, but it does not accept the `CIPHERS`, `DIGESTSS`, or `USE_SOFTDRIVERS` options.

In OpenWrt 19.07, the shipped `/etc/ssl/openssl.cnf` already has the basic engine configuration sections for both the devcrypto and the original afalg engines. To enable them, uncomment the respective lines under the `[engines]` section.

Shortly after 19.07.0 was released, an alternate AF\_ALG engine was added, `libopenssl-afalg_sync` that is basically a mirror of the devcrypto engine, but using the AF\_ALG interface. It accepts all of the options, and is configured the same way as the `devcrypto` engine. You may follow the steps below, just configure it under `afalg`, instead of `devcrypto`. As of 19.07.0, the `openssl.cnf` file does not have the `CIPHERS`, `DIGESTS` and `USE_SOFTDRIVERS` options listed, but you can just copy them from the \[devcrypto] section. Note that the OpenWrt package is called `afalg_sync`, but for openssl the engine, it is simply `afalg`. It can't coexist with the original engine. Even though opinions my vary, its creator, cotequeiroz, states that the afalg\_sync (as of v1.0.1) performance is better than the original afalg engine, but poorer than devcrypto.

## Checking openssl support for AES-NI hw crypto on x86\_64 (normal PC hardware)

OpenSSL in OpenWrt on x86 supports AES-NI CPU instructions natively and should use them automatically where available.

You can try two different commands and see whether performance differs.

This should use AES-NI and should have better performance:

```
openssl speed -elapsed -evp aes-128-cbc
```

This has a runtime switch that disables use of AES-NI in openSSL and therefore has lower performance.

```
OPENSSL_ia32cap="~0x200000200000000" openssl speed -elapsed -evp aes-128-cbc
```

This is an example of the results showing OpenSSL with AES-NI support (faster)

```
root@routegateway:~# openssl speed -elapsed -evp aes-128-cbc
You have chosen to measure elapsed time instead of user CPU time.
Doing aes-128-cbc for 3s on 16 size blocks: 117879925 aes-128-cbc's in 3.00s
Doing aes-128-cbc for 3s on 64 size blocks: 39584711 aes-128-cbc's in 3.00s
Doing aes-128-cbc for 3s on 256 size blocks: 10062149 aes-128-cbc's in 3.00s
Doing aes-128-cbc for 3s on 1024 size blocks: 2530718 aes-128-cbc's in 3.00s
Doing aes-128-cbc for 3s on 8192 size blocks: 318704 aes-128-cbc's in 3.00s
Doing aes-128-cbc for 3s on 16384 size blocks: 158373 aes-128-cbc's in 3.00s
OpenSSL 1.1.1g  21 Apr 2020
built on: Sun Aug  2 16:16:00 2020 UTC
options:bn(64,64) rc4(16x,int) des(int) aes(partial) blowfish(ptr)
compiler: x86_64-openwrt-linux-musl-gcc -fPIC -pthread -m64 -Wa,--noexecstack -Wall -O3 -pipe -fno-caller-saves -fno-plt -fhonour-copts -Wno-error=unused-but-set-variable -Wno-error=unused-result -Wformat -Werror=format-security -fstack-protector -D_FORTIFY_SOURCE=1 -Wl,-z,now -Wl,-z,relro -O3 -fpic -ffunction-sections -fdata-sections -znow -zrelro -DOPENSSL_USE_NODELETE -DL_ENDIAN -DOPENSSL_PIC -DOPENSSL_CPUID_OBJ -DOPENSSL_IA32_SSE2 -DOPENSSL_BN_ASM_MONT -DOPENSSL_BN_ASM_MONT5 -DOPENSSL_BN_ASM_GF2m -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DKECCAK1600_ASM -DRC4_ASM -DMD5_ASM -DAESNI_ASM -DVPAES_ASM -DGHASH_ASM -DECP_NISTZ256_ASM -DX25519_ASM -DPOLY1305_ASM -DNDEBUG
The 'numbers' are in 1000s of bytes per second processed.
type             16 bytes     64 bytes    256 bytes   1024 bytes   8192 bytes  16384 bytes
aes-128-cbc     628692.93k   844473.83k   858636.71k   863818.41k   870274.39k   864927.74k
```

This is the result without AES-NI support (slower).

```
root@routegateway:~# OPENSSL_ia32cap="~0x200000200000000" openssl speed -elapsed -evp aes-128-cbc
You have chosen to measure elapsed time instead of user CPU time.
Doing aes-128-cbc for 3s on 16 size blocks: 37905593 aes-128-cbc's in 3.00s
Doing aes-128-cbc for 3s on 64 size blocks: 10779104 aes-128-cbc's in 3.00s
Doing aes-128-cbc for 3s on 256 size blocks: 2769347 aes-128-cbc's in 3.00s
Doing aes-128-cbc for 3s on 1024 size blocks: 702288 aes-128-cbc's in 3.00s
Doing aes-128-cbc for 3s on 8192 size blocks: 88129 aes-128-cbc's in 3.00s
Doing aes-128-cbc for 3s on 16384 size blocks: 44055 aes-128-cbc's in 3.00s
OpenSSL 1.1.1g  21 Apr 2020
built on: Sun Aug  2 16:16:00 2020 UTC
options:bn(64,64) rc4(16x,int) des(int) aes(partial) blowfish(ptr)
compiler: x86_64-openwrt-linux-musl-gcc -fPIC -pthread -m64 -Wa,--noexecstack -Wall -O3 -pipe -fno-caller-saves -fno-plt -fhonour-copts -Wno-error=unused-but-set-variable -Wno-error=unused-result -Wformat -Werror=format-security -fstack-protector -D_FORTIFY_SOURCE=1 -Wl,-z,now -Wl,-z,relro -O3 -fpic -ffunction-sections -fdata-sections -znow -zrelro -DOPENSSL_USE_NODELETE -DL_ENDIAN -DOPENSSL_PIC -DOPENSSL_CPUID_OBJ -DOPENSSL_IA32_SSE2 -DOPENSSL_BN_ASM_MONT -DOPENSSL_BN_ASM_MONT5 -DOPENSSL_BN_ASM_GF2m -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DKECCAK1600_ASM -DRC4_ASM -DMD5_ASM -DAESNI_ASM -DVPAES_ASM -DGHASH_ASM -DECP_NISTZ256_ASM -DX25519_ASM -DPOLY1305_ASM -DNDEBUG
The 'numbers' are in 1000s of bytes per second processed.
type             16 bytes     64 bytes    256 bytes   1024 bytes   8192 bytes  16384 bytes
aes-128-cbc     202163.16k   229954.22k   236317.61k   239714.30k   240650.92k   240599.04k
```

### Using the libopenssl-devcrypto package

Starting with 19.x branch, the /dev/crypto support can be packaged separately from the main openssl library, as the `libopenssl-devcrypto` package. The engine is not enabled by default, even when the package is installed. It requires editing the `/etc/ssl/openssl.cnf`, as follows.

## Configuring the devcrypto engine

When using the standalone package, this becomes mandatory. If the engine is built into libcrypto, it is only optional.

To configure the engine, you must first add a line to the default section (i.e. the first, unnamed section), adding the following line, which tells which section is used to configure the library. The sections are lines within brackets \[]:

```
# this points to the main library configuration section
openssl_conf = openssl_def
```

This will point the main openssl configuration to be done in a section called `openssl_def`. Then, that section needs to be created, anywhere past the last line in the unnamed section. I'd just add it to the very end of the file. It will add an engine configuration section, where you can add a section for every engine you're configuring, and finally, a section to configure the engine itself. In this example, we are configuring just the /dev/crypto engine:

```
[openssl_def]
# this is the main library configuration section
engines=engine_section

[engine_section]
# this is the engine configuration section, where the engines are listed
devcrypto=devcrypto_section

[devcrypto_section]
# this is the section where the devcrypto engine commands are used
CIPHERS=ALL
DIGESTS=NONE
```

You can use the `-vv` option of the `openssl engine` command to view the available configuration commands, along with a description of each command. Notice the line disabling all digests. Digests are computed fairly fast in software, and to use hardware crypto requires a context switch, which is an “expensive” operation. So in order to be worth using an algorithm, it needs to be much faster than software to offset the cost of the context switch. Efficiency depends on the length of each operation. For ciphers, it is faster to use hardware than software in chunks of 1000 bytes or more, depending on your hardware. For digests, the size has to be 10x greater. Considering an MTU of 1500 bytes, which is the de facto limit on TLS encryption block limit, it will not be worth to enable digests. You can use a different configuration file for every application, by setting the environment variable `OPENSSL_CONF` to the full path of the configuration file to be used.

### Showing /dev/crypto algorithm information

There's a command for the devcrypto engine not to be used in `openssl.cnf` that will show some useful information about the algorithms available. It shows a list of engine-supported algorithms, whether it can be used (a session can be opened) with /dev/crypto or not, along with the corresponding kernel driver, and whether it is hw-accelerated or not. To use it, run:

```
# openssl engine -pre DUMP_INFO devcrypto
(devcrypto) /dev/crypto engine
Information about ciphers supported by the /dev/crypto engine:
Cipher DES-CBC, NID=31, /dev/crypto info: id=1, driver=mv-cbc-des (hw accelerated)
Cipher DES-EDE3-CBC, NID=44, /dev/crypto info: id=2, driver=mv-cbc-des3-ede (hw accelerated)
Cipher BF-CBC, NID=91, /dev/crypto info: id=3, CIOCGSESSION (session open call) failed
Cipher CAST5-CBC, NID=108, /dev/crypto info: id=4, CIOCGSESSION (session open call) failed
Cipher AES-128-CBC, NID=419, /dev/crypto info: id=11, driver=mv-cbc-aes (hw accelerated)
Cipher AES-192-CBC, NID=423, /dev/crypto info: id=11, driver=mv-cbc-aes (hw accelerated)
Cipher AES-256-CBC, NID=427, /dev/crypto info: id=11, driver=mv-cbc-aes (hw accelerated)
Cipher RC4, NID=5, /dev/crypto info: id=12, CIOCGSESSION (session open call) failed
Cipher AES-128-CTR, NID=904, /dev/crypto info: id=21, driver=ctr-aes-neonbs (software)
Cipher AES-192-CTR, NID=905, /dev/crypto info: id=21, driver=ctr-aes-neonbs (software)
Cipher AES-256-CTR, NID=906, /dev/crypto info: id=21, driver=ctr-aes-neonbs (software)
Cipher AES-128-ECB, NID=418, /dev/crypto info: id=23, driver=mv-ecb-aes (hw accelerated)
Cipher AES-192-ECB, NID=422, /dev/crypto info: id=23, driver=mv-ecb-aes (hw accelerated)
Cipher AES-256-ECB, NID=426, /dev/crypto info: id=23, driver=mv-ecb-aes (hw accelerated)

Information about digests supported by the /dev/crypto engine:
Digest MD5, NID=4, /dev/crypto info: id=13, driver=mv-md5 (hw accelerated), CIOCCPHASH capable
Digest SHA1, NID=64, /dev/crypto info: id=14, driver=mv-sha1 (hw accelerated), CIOCCPHASH capable
Digest RIPEMD160, NID=117, /dev/crypto info: id=102, driver=unknown. CIOCGSESSION (session open) failed
Digest SHA224, NID=675, /dev/crypto info: id=103, driver=sha224-neon (software), CIOCCPHASH capable
Digest SHA256, NID=672, /dev/crypto info: id=104, driver=mv-sha256 (hw accelerated), CIOCCPHASH capable
Digest SHA384, NID=673, /dev/crypto info: id=105, driver=sha384-neon (software), CIOCCPHASH capable
Digest SHA512, NID=674, /dev/crypto info: id=106, driver=sha512-neon (software), CIOCCPHASH capable
```

### Measuring the algorithm speed

**As stated above, the best way to determine the speed is to benchmark the actual application you're using.** If that's not feasible, `openssl speed` can be used to compare the algorithm speed with and without the engine. To measure the speed without the engine, set `CIPHERS=NONE` and `DIGESTS=NONE` in `/etc/ssl/openssl.cnf`. You must use the `-elapsed` option to get a reasonable calculation. That's because the speed command will use the CPU user time by default. When using the engine, most all of the processing will be done in kernel time, and the user time will be close to zero, yielding an exaggerated result. This is the measurement of the AES-256-CTR algorithm, implemented 100% in software (you must configure `USE_SOFTDRIVERS=1` in `openssl.cnf` to be able to use software drivers with devcrypto).

```
# time openssl speed -evp aes-256-ctr
Doing aes-256-ctr for 3s on 16 size blocks: 1506501 aes-256-ctr's in 0.32s
Doing aes-256-ctr for 3s on 64 size blocks: 830921 aes-256-ctr's in 0.18s
Doing aes-256-ctr for 3s on 256 size blocks: 526267 aes-256-ctr's in 0.15s
Doing aes-256-ctr for 3s on 1024 size blocks: 167828 aes-256-ctr's in 0.07s
Doing aes-256-ctr for 3s on 8192 size blocks: 22723 aes-256-ctr's in 0.00s
Doing aes-256-ctr for 3s on 16384 size blocks: 11400 aes-256-ctr's in 0.00s
OpenSSL 1.1.1b  26 Feb 2019
built on: Wed Dec 13 18:43:03 2017 UTC
options:bn(64,32) rc4(char) des(long) aes(partial) blowfish(ptr)
compiler: arm-openwrt-linux-muslgnueabi-gcc -fPIC -pthread -Wa,--noexecstack -Wall -O3 -pipe -mcpu=cortex-a9 -mfpu=vfpv3-d16 -fno-caller-saves -fno-plt -fhonour-copts -Wno-error=unused-but-set-variable -Wno-error=unused-result -mfloat-abi=hard -Wformat -Werror=format-security -fstack-protector -D_FORTIFY_SOURCE=1 -Wl,-z,now -Wl,-z,relro -O3 -fpic -ffunction-sections -fdata-sections -znow -zrelro -DOPENSSL_USE_NODELETE -DOPENSSL_PIC -DOPENSSL_CPUID_OBJ -DOPENSSL_BN_ASM_MONT -DOPENSSL_BN_ASM_GF2m -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DKECCAK1600_ASM -DAES_ASM -DBSAES_ASM -DGHASH_ASM -DECP_NISTZ256_ASM -DPOLY1305_ASM -DNDEBUG -DOPENSSL_PREFER_CHACHA_OVER_GCM
The 'numbers' are in 1000s of bytes per second processed.
type             16 bytes     64 bytes    256 bytes   1024 bytes   8192 bytes  16384 bytes
aes-256-ctr      75325.05k   295438.58k   898162.35k  2455083.89k         infk         infk
real    0m 18.04s
user    0m 0.72s
sys     0m 17.27s
```

Notice the infinite speeds. If you spend 0 seconds in CPU user time, and use that as a divisor, you get infinity. The speed command, with the addtion of the `-elapsed` parameter will return a more realistic result:

```
# time openssl speed -evp aes-256-ctr -elapsed
type             16 bytes     64 bytes    256 bytes   1024 bytes   8192 bytes  16384 bytes
aes-256-ctr       7975.70k    17403.54k    44777.30k    57178.79k    62076.25k    62395.73k
real    0m 18.04s
user    0m 0.88s
sys     0m 17.11s
```

This is the result of the AES-256-CTR without the engine:

```
type             16 bytes     64 bytes    256 bytes   1024 bytes   8192 bytes  16384 bytes
aes-256-ctr      39684.36k    47027.86k    53044.99k    60888.06k    63548.07k    63706.45k
real    0m 18.04s
user    0m 17.98s
sys     0m 0.00s
```

In this case `-elapsed` does not matter much, as almost 100% of the execution time is spent in user-mode, and CPU user time would actually be a better measurement by not counting time spent in other processes. With that out of the way, let's see an actual hardware-implemented cipher:

```
# time openssl speed -evp aes-256-cbc -elapsed
The 'numbers' are in 1000s of bytes per second processed.
type             16 bytes     64 bytes    256 bytes   1024 bytes   8192 bytes  16384 bytes
aes-256-cbc       1551.04k     6126.44k    21527.81k    55995.05k    95027.20k    99936.94k
real    0m 18.04s
user    0m 0.21s
sys     0m 5.13s
```

For comparison, this is the same cipher, implemented by the libcrypto software:

```
# time openssl speed -evp aes-256-cbc -elapsed
type             16 bytes     64 bytes    256 bytes   1024 bytes   8192 bytes  16384 bytes
aes-256-cbc      39603.10k    47420.37k    50270.38k    51002.71k    51249.15k    51232.77k
real    0m 18.03s
user    0m 18.00s
sys     0m 0.01s
```

This is typical for a `/dev/crypto` cipher. There's a cost in CPU usage: the context switches needed to run the code in the kernel, represented by the 5.13s of system time used. That cost will not vary much with the size of the crypto operation. Because of that, for small batches, the acceleration of hardware drivers will be penalised by context switches and slow you down considerably. As the block size increases, `/dev/crypto` becomes the best choice. Be aware of how the application uses the cipher. For example, AES-128-ECB is used by openssl to seed the rng, using 16-byte calls. I haven't seen any other use of the ECB ciphers, so it is best to disable them entirely.

### Disabling digests

Don't enable digests unless you know what you're doing. They are usually slower than software, except for large (&gt; 10k) blocks. Some applications--openssh, for example--will not work with `/dev/crypto` digests. This is a limitation of how the engine works. Openssh will save a partial digest, and then fork, duplicating that context, and working with successive copies of it, which is useful for HMAC, where the hash of the key remains constant. In the kernel, however, those contexts are still linked to the same session, so when one process calls another update, or closes that digest context, the kernel session is changed/closed for all of the instances, and you'll get a libcrypto failure. For well-behaved applications using large update blocks, you may enable digests. Use a separate copy of the `openssl.cnf` configuration file, and set `OPENSSL_CONF=_path_to_file` in the environment before running it (add it to the respective file in /etc/init.d/). Again, **benchmarking the actual application you're using is the best way to gauge the impact of hardware crypto.**

## Enabling specific hardware driver

### Soekris vpn1411

- [http://www.soekris.com/vpn1401.htm](http://www.soekris.com/vpn1401.htm "http://www.soekris.com/vpn1401.htm")

Run `make menuconfig` and select

Kernel modules → Cryptographic API modules

- kmod-crypto-core: m
  
  - kmod-crypto-aes: m
  - kmod-crypto-des: m
  - kmod-crypto-hw-hifn-795x: m

### Marvell CESA

Cryptographic Engine and Security Acceleration

- [PDF download](http://www.google.com/search?sclient=psy&hl=en&source=hp&q=site%3Awww.marvell.com%20cesa&btnG=Search "http://www.google.com/search?sclient=psy&hl=en&source=hp&q=site%3Awww.marvell.com+cesa&btnG=Search")
- [Seagate Dockstar](/toh/seagate/dockstar#crypto_hardware_acceleration "toh:seagate:dockstar")
- 2.6.32: AES [commit](http://git.kernel.org/?p=linux%2Fkernel%2Fgit%2Ftorvalds%2Flinux-2.6.git%3Ba%3Dcommitdiff%3Bh%3D85a7f0ac5370901916a21935e1fafbe397b70f80 "http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=85a7f0ac5370901916a21935e1fafbe397b70f80")
- 2.6.35: SHA1 and HMAC-SHA1 [commit](http://git.kernel.org/?p=linux%2Fkernel%2Fgit%2Ftorvalds%2Flinux-2.6.git%3Ba%3Dcommitdiff%3Bh%3D750052dd2400cd09e0864d75b63c2c0bf605056f "http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=750052dd2400cd09e0864d75b63c2c0bf605056f")
- [r22877](https://dev.openwrt.org/changeset/22877 "https://dev.openwrt.org/changeset/22877"): \[kirkwood] Add kernel package for the mv\_cesa crypto module
- [r23145](https://dev.openwrt.org/changeset/23145 "https://dev.openwrt.org/changeset/23145"): \[kirkwood] Fix mv\_cesa module dependencies and .ko file location Thanks KanjiMonster &amp; Memphiz
- [r23229](https://dev.openwrt.org/changeset/23229 "https://dev.openwrt.org/changeset/23229"): \[packages/kernel] Make mv\_cesa crypto module available on Orion as well.
- [r23383](https://dev.openwrt.org/changeset/23383 "https://dev.openwrt.org/changeset/23383"): \[package] kernel: underscores in package names are bad, rename kmod-crypto-mv\_cesa to kmod-crypto-mv-cesa
- [r26406](https://dev.openwrt.org/changeset/26406 "https://dev.openwrt.org/changeset/26406"): kernel: add a missing dependency for the mv\_cesa crypto driver
- [r26407](https://dev.openwrt.org/changeset/26407 "https://dev.openwrt.org/changeset/26407"): kernel: mv\_cesa depends on CRYPTO\_BLKCIPHER2 and CRYPTO\_HASH2
- [r26413](https://dev.openwrt.org/changeset/26413 "https://dev.openwrt.org/changeset/26413"): kernel: remove double definition of depends in crypto-mv-cesa and make it look like the other entries. Thank you Maarten

### Geode AES engine

- [using\_the\_geode\_s\_aes\_engine](/toh/pcengines/alix#using_the_geode_s_aes_engine "toh:pcengines:alix")

### VIA padlock

- [VIA Padlock security engine](http://www.via.com.tw/en/initiatives/padlock/hardware.jsp "http://www.via.com.tw/en/initiatives/padlock/hardware.jsp")
- [Padlock\_(disambiguation)](https://en.wikipedia.org/wiki/Padlock_%28disambiguation%29 "https://en.wikipedia.org/wiki/Padlock_(disambiguation)")

### Historical

**Note:** If you want to learn about the current situation, you should search the Internet or maybe ask in the forum. This is outdated. Especially if you want to know how fast a copy from a mounted filesystem (say ext3 over USB) via scp is. Search for such benchmarks.

Some models of the BCM47xx/53xx family support hardware accelerated encryption for IPSec (AES, DES, 3DES), simple hash calculations (MD5, SHA1) and TLS/SSL+HMAC processing. Not all devices have a hw crypto supporting chip. At least Asus WL500GD/X, Netgear WGT634U and Asus WL700gE do have hw crypto. Testing of a WGT634U indicates, however, that a pin under the BCM5365 was not pulled low to enable strong bulk cryptography, limiting the functionality to single DES.

- How did you find that out?
  
  - Do you get an interrupt when sending a crypto job to the chip and limiting the request to DES only?)

The specification states the hardware is able to support 75Mbps (9,4MB/s) of encrypted throughput. Without hardware acceleration using the blowfish encryption throughput is only ~0,4MB/s. Benchmark results that show the difference between software and hardware accelerated encryption/decryption can be found [here](https://web.archive.org/web/20101103235726/http://www.danm.de/files/src/bcm5365p/bench/ "https://web.archive.org/web/20101103235726/http://www.danm.de/files/src/bcm5365p/bench/"). Due to the overhead of hardware/DMA transfers and buffer copies between kernel/user space it gives only a good return for packet sizes greater than 256 bytes. This size can be reduced for IPSec, because network hardware uses DMA and there is no need to copy the (encrypted) data between kernel and user space. The hardware specification needed for programming the crypto API of the bcm5365P (Broadcom 5365P) can be found [here](http://voodoowarez.com/bcm5365p.pdf "http://voodoowarez.com/bcm5365p.pdf").

- The crypto chip is accessible through the SSB bus (Sonics Silicon Backplane). A Linux driver for SSB is available in OpenWRT's kernel &gt;= 2.6.23 (Kamikaze)
- An example about how to communicate with the crypto chip can be found [here](https://web.archive.org/web/20110606025239/https://www.danm.de/files/src/bcm5365p/ "https://web.archive.org/web/20110606025239/https://www.danm.de/files/src/bcm5365p/") (file b5365ips.tar.bz2).
- An OCF Linux driver that works with the ASUS WL500gP can be found in Trunk (SVN) or [here](http://www.danm.de/files/src/bcm5365p/ "http://www.danm.de/files/src/bcm5365p/") and is called **ubsec\_ssb**. Only OCF-enabled applications can be accelerated. That means, if you want e.g. an accelerated OpenSSH you have to manually enable cryptodev in OpenSSL. The driver is still considered experimental.
- Links to mailing-list posts with references to more recent and working version of Linux driver for Broadcom crypto chips [here](http://marc.theaimsgroup.com/?l=openssl-dev&m=110915540208913&w=2 "http://marc.theaimsgroup.com/?l=openssl-dev&m=110915540208913&w=2") and [here](http://www.mail-archive.com/openssl-dev@openssl.org/msg18804.html "http://www.mail-archive.com/openssl-dev@openssl.org/msg18804.html").
- Sun Crypto Accelerator 500 and 1000 (X6762A) cards are based on BCM5821. Might be worth checking Solaris references as well. [Here](https://web.archive.org/web/20110606041805/http://src.opensolaris.org/source/xref/crypto/quantis/usr/src/uts/common/crypto/io/ "https://web.archive.org/web/20110606041805/http://src.opensolaris.org/source/xref/crypto/quantis/usr/src/uts/common/crypto/io/") is OpenSolaris driver for Broadcom crypto chips.
- Asus WL-700gE sources come with patched FreeSwan to utilize ubsec.
- Closed-source binary included in Asus Wl-700gE sources do support AES based on headers.
- There's a [Linux port](http://ocf-linux.sourceforge.net/ "http://ocf-linux.sourceforge.net/") of the OpenBSD Cryptographic Framework (OCF) but the ubsec driver (Broadcom 58xx PCI cards) is not ported yet. If you compile OCF with the /dev/crypto device driver, userspace applications and libraries such as OpenSSL can be accelerated. There are patches for Openswan as well.
- [Discussion](http://forum.openwrt.org/viewtopic.php?id=5032 "http://forum.openwrt.org/viewtopic.php?id=5032") about hardware accelerated crypto.
- Various versions of old [BCM5820 driver sources](https://web.archive.org/web/20070502031603/http://www.sukkamehulinko.romikselle.com/openwrt/bcm5820/ "https://web.archive.org/web/20070502031603/http://www.sukkamehulinko.romikselle.com/openwrt/bcm5820/").
- BCM5801/BCM5805/BCM5820 Security Processor Software Reference Library [http://www.broadcom.com/products/access\_request.php?category\_id=0&amp;id=7&amp;filename=5801-5805-5820-SRL101-R.pdf](http://www.broadcom.com/products/access_request.php?category_id=0&id=7&filename=5801-5805-5820-SRL101-R.pdf "http://www.broadcom.com/products/access_request.php?category_id=0&id=7&filename=5801-5805-5820-SRL101-R.pdf")
- Cisco PIX VAC+ Encryption module is 64-bit PCI card based on Broadcom BCM5823. Another similar card is Checkpoint VPN-1 Accelerator Card II, III and IV from [Silicom](http://www.silicom.co.il/ "http://www.silicom.co.il/").

| SoC / CPU | Accelerated Methods | Datasheet |

| BCM94704AGR | WEP 128, AES OCB AES CCM | [94704AGR-PB00-R.pdf](https://web.archive.org/web/20070226095209/http://www.broadcom.com/collateral/pb/94704AGR-PB00-R.pdf "https://web.archive.org/web/20070226095209/http://www.broadcom.com/collateral/pb/94704AGR-PB00-R.pdf") |

| BCM?4704P | WEP 128, AES OCB, AES CCM, VPN | [94704AGR-PB00-R.pdf](http://www.broadcom.com/collateral/pb/94704AGR-PB00-R.pdf "http://www.broadcom.com/collateral/pb/94704AGR-PB00-R.pdf") |

| BCM5365 | AES (up to 256-bit CTR and CBC modes), DES, 3DES (CBC), HMAC-SHA1, HMAC-MD5, SHA1 and MD5. IPSec encryption and single pass authentication. | [5365\_5365P-PB01-R.pdf](https://web.archive.org/web/20060312204710/http://www.broadcom.com/collateral/pb/5365_5365P-PB01-R.pdf "https://web.archive.org/web/20060312204710/http://www.broadcom.com/collateral/pb/5365_5365P-PB01-R.pdf") |

| BCM5365P | AES (up to 256-bit CTR and CBC modes), DES, 3DES (CBC), HMAC-SHA1, HMAC-MD5, SHA1 and MD5. IPSec encryption and single pass authentication. | [5365\_5365P-PB01-R.pdf](http://www.broadcom.com/collateral/pb/5365_5365P-PB01-R.pdf "http://www.broadcom.com/collateral/pb/5365_5365P-PB01-R.pdf") |
