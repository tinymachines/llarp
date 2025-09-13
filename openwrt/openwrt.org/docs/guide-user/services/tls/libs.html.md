## TLS libraries

There is few crypto libraries for TLS that works on OpenWrt:

- [OpenSSL](https://en.wikipedia.org/wiki/OpenSSL "https://en.wikipedia.org/wiki/OpenSSL") is a de-facto standard. It's libopenssl takes more than a 1Mb of disk space.
- [MbedTLS](https://en.wikipedia.org/wiki/Mbed_TLS "https://en.wikipedia.org/wiki/Mbed_TLS") is a small library developed for embedded devices. Was used by default in OpenWrt before.
- [WolfSSL](https://en.wikipedia.org/wiki/WolfSSL "https://en.wikipedia.org/wiki/WolfSSL") is a small library developed for embedded devices. Supports TLS1.3. Installed by default in OpenWrt 21. But in future this may be changed back to MbedTLS.
- [Nettle](https://www.lysator.liu.se/~nisse/nettle/ "https://www.lysator.liu.se/~nisse/nettle/") just a small crypto library without TLS support.
- [GnuTLS](https://en.wikipedia.org/wiki/GnuTLS "https://en.wikipedia.org/wiki/GnuTLS") is GNU project but not often used. Internally uses Nettle.
- [LibTomCrypt](https://github.com/libtom/libtomcrypt "https://github.com/libtom/libtomcrypt"): used internally in Dropbear SSH daemon. It's not a TLS lib that you may use but all routers have it.

When you are installing some program you may check which library you already have and install a specific version to reuse existing dependency. For example rtty daemon has three versions `rtty-mbedtls`, `rtty-openssl`, `rtty-wolfssl`. Some OpenWrt only packages like `kadnode` uses only mbedtls and other libraries aren't supported yet.

See also [Comparison of TLS implementations](https://en.wikipedia.org/wiki/Comparison%20of%20TLS%20implementations "https://en.wikipedia.org/wiki/Comparison of TLS implementations")
