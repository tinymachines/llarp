# Release Signing

## Signing Approach

OpenWrt uses both [GnuPG](https://www.gnupg.org/ "https://www.gnupg.org/") and *usign*, a derivate of the OpenBSD [signify](https://www.openbsd.org/papers/bsdcan-signify.html "https://www.openbsd.org/papers/bsdcan-signify.html") utilitiy.

The *OPKG* package manager uses *usign* Ed25519 signatures to verify repository metadata when installing packages while release image files are usually signed by one or more developers with detached GPG signatures to allow users to verify the integrity of installation files.

Our *usign* signature files carry the extension `.sig` while the detached GPG signatures end with `.asc` or, in older releases, with the `.gpg` extension.

Note that not every file is signed individually but that we’re signing the `sha256sums` or - for repositories - the `Packages` files to establish a chain of trust: The SHA256 checksum will verify the integrity of the actual file while the signature will verify the integrity of the file containing the checksums.

### Verify download integrity

In order to verify the integrity of a firmware download you need to do the following steps:

1. Download the `sha256sum` and `sha256sum.asc` files
2. Check the signature with `gpg --with-fingerprint --verify sha256sum.asc sha256sum`, ensure that the GnuPG command reports a good signature and that the fingerprint matches the ones listed on our [**fingerprints page**](/docs/guide-user/security/signatures "docs:guide-user:security:signatures").
3. Download the firmware image into the same directory as the `sha256sums` file and verify its checksum using the following command: `sha256sum -c --ignore-missing sha256sums`

### Developer Information

Developers participating in the LEDE project need to provide both *GnuPG* and *usign* public keys which are stored in the central [keyring.git](https://git.lede-project.org/?p=keyring.git "https://git.lede-project.org/?p=keyring.git") repository.

Refer to the [key generation howto](/docs/guide-user/security/keygen "docs:guide-user:security:keygen") page for instruction on how to generate suitable signing keys.
