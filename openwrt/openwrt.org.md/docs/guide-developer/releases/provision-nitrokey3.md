# Prepare Nitrokey 3A Mini for build artifact signing

These are collected notes of the steps we've done during preparation of Nitrokey 3A Mini (nk3) key for use during build artifacts signing.

This guide was written using following environment:

- Fedora 38 container
- gpg (GnuPG) 2.4.0
- libgcrypt 1.10.2-unknown

## Install nitropy toolkit

```
python3.10 -m venv venv
source venv/bin/activate
pip install -U pip
pip install pipx
pipx install nitropy
pipx list
...
pynitrokey 0.4.36, installed using Python 3.10.6
```

## Upgrade nk3 firmware to v1.4.0

```
nitropy nk3 update --version v1.4.0
nitropy nk3 status
 ...
Firmware version:   v1.4.0
```

## Perform nk3 factory reset and enable KDF-DO

Factory default admin PIN is **12345678** and PIN is **123456**

```
gpg --card-edit
gpg/card> admin
gpg/card> factory-reset
gpg/card> kdf-setup
```

and double check, that KDF is **on**:

```
gpg/card> list
 ...
 KDF setting ......: on
```

## Generate GPG key

Gather some entropy from nk3

```
nitropy nk3 rng --length 4096 | sudo tee /dev/random | hexdump -C
```

Generate keys:

```
export PASSPHRASE=$(gpg --gen-random --armor 0 60)
 
export GNUPGHOME=$(mktemp -d -t gnupg_openwrt_nk3_$(date +%Y%m%d%H%M)_XXX)
 
cat > $GNUPGHOME/gpg.conf << EOF
  personal-cipher-preferences AES256 AES192 AES
  personal-digest-preferences SHA512 SHA384 SHA256
  personal-compress-preferences ZLIB BZIP2 ZIP Uncompressed
  default-preference-list SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed
  cert-digest-algo SHA512
  s2k-digest-algo SHA512
  s2k-cipher-algo AES256
  charset utf-8
  fixed-list-mode
  no-comments
  no-emit-version
  keyid-format 0xlong
  list-options show-uid-validity
  verify-options show-uid-validity
  with-fingerprint
  require-cross-certification
  no-symkey-cache
  use-agent
  throw-keyids
EOF
 
cat > $GNUPGHOME/gpg-generate-nk3-keys.txt << EOF
  %echo Generating a Openwrt Build System signing key for Nitrokey3
  Key-Type: eddsa
  Key-Curve: ed25519
  Key-Usage: cert
  SubKey-Type: eddsa
  SubKey-Curve: ed25519
  SubKey-Usage: sign
  Name-Real: OpenWrt Build System
  Name-Comment: Nitrokey3
  Name-Email: contact@openwrt.org
  Expire-Date: 10y
  Passphrase: $PASSPHRASE
  %commit
  %echo done
EOF
 
gpg --batch --generate-key $GNUPGHOME/gpg-generate-nk3-keys.txt
gpg: Generating a Openwrt Build System signing key for Nitrokey3
gpg: /tmp/gnupg_openwrt_nk3_202305130941_eoc/trustdb.gpg: trustdb created
gpg: directory '/tmp/gnupg_openwrt_nk3_202305130941_eoc/openpgp-revocs.d' created
gpg: revocation certificate stored as '/tmp/gnupg_openwrt_nk3_202305130941_eoc/openpgp-revocs.d/E9025ED843D0FDC7866F7064CAE438715492B555.rev'
gpg: done
```

Export public key

```
export KEYID=$(gpg --list-signatures --with-colons | grep sig: | cut -d: -f 5 | head -1)
 
gpg --export --armor | tee $GNUPGHOME/gnupg-openwrt-nk3-$KEYID.asc
```

## Setup nk3 key

```
gpg --card-edit
gpg/card> admin
 
gpg/card> key-attr
ECC / Curve 25519
 
gpg/card> forcesig
 
gpg/card> name
Cardholder's surname: Build System Key 3.
Cardholder's given name: OpenWrt
 
gpg/card> url
URL to retrieve public key: https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=gpg/CAE438715492B555.asc;hb=HEAD
```

Gather some entropy from nk3

```
nk3 rng --length 4096 | sudo tee /dev/random | hexdump -C
```

Generate nk3 PIN, Admin PIN and Reset PIN

```
$ for k in $(seq 1 3); do gpg --gen-random --armor 0 60; sleep 60; done
```

Write down the keys and set the keys on the nk3 key

```
  gpg/card> passwd
  1 - change PIN
  4 - set the Reset Code
  3 - change Admin PIN
```

Verify correct settings

```
  gpg/card> list
  Name of cardholder: OpenWrt Build System Key 3.
  URL of public key : https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=gpg/CAE438715492B555.asc;hb=HEAD
  Signature PIN ....: not forced
  Key attributes ...: ed25519 cv25519 ed25519
```

## Transfer GPG keys to nk3

```
gpg --edit-key $KEYID
 
  gpg (GnuPG) 2.4.0; Copyright (C) 2021 Free Software Foundation, Inc.
 
  Secret key is available.
 
  sec  ed25519/0xCAE438715492B555
       created: 2023-05-13  expires: 2033-05-10  usage: C   
       trust: ultimate      validity: ultimate
  ssb  ed25519/0x78BBEC94A894C992
       created: 2023-05-13  expires: 2033-05-10  usage: S   
  [ultimate] (1). OpenWrt Build System (Nitrokey3) <contact@openwrt.org>
```

Select signing key

```
  gpg> key 1
 
  sec  ed25519/0xCAE438715492B555
       created: 2023-05-13  expires: 2033-05-10  usage: C   
       trust: ultimate      validity: ultimate
  ssb* ed25519/0x78BBEC94A894C992
       created: 2023-05-13  expires: 2033-05-10  usage: S   
  [ultimate] (1). OpenWrt Build System (Nitrokey3) <contact@openwrt.org>
```

Move signing key to card

Transferring keys to nk3 using *keytocard* is a destructive, one-way operation only. Make sure you've made a backup before proceeding: *keytocard* converts the local, on-disk key into a stub, which means the on-disk copy is no longer usable to transfer to subsequent security key devices or mint additional keys.

```
  gpg> keytocard
  Please select where to store the key:
    (1) Signature key
    (3) Authentication key
  Your selection? 1
 
  sec  ed25519/0xCAE438715492B555
       created: 2023-05-13  expires: 2033-05-10  usage: C   
       trust: ultimate      validity: ultimate
  ssb* ed25519/0x78BBEC94A894C992
       created: 2023-05-13  expires: 2033-05-10  usage: S   
  [ultimate] (1). OpenWrt Build System (Nitrokey3) <contact@openwrt.org>
 
  gpg> save
```

Check the keyring content

```
  $ gpg -K
  /tmp/gnupg_openwrt_nk3_202305130941_eoc/pubring.kbx
  ---------------------------------------------------
  sec   ed25519/0xCAE438715492B555 2023-05-13 [C] [expires: 2033-05-10]
        Key fingerprint = E902 5ED8 43D0 FDC7 866F  7064 CAE4 3871 5492 B555
  uid                   [ultimate] OpenWrt Build System (Nitrokey3) <contact@openwrt.org>
  ssb>  ed25519/0x78BBEC94A894C992 2023-05-13 [S] [expires: 2033-05-10]
```

Check nk3 card content, secret key *sec#* and sub-key *ssb&gt;* means, that key move went fine.

```
  $ gpg --card-status 
  Name of cardholder: OpenWrt Build System Key 3.
  URL of public key : https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=gpg/CAE438715492B555.asc;hb=HEAD
  Signature PIN ....: not forced
  Key attributes ...: ed25519 cv25519 ed25519
  KDF setting ......: off
  Signature key ....: 6079 C3B2 0643 36C9 59E7  B37D 78BB EC94 A894 C992
        created ....: 2023-05-13 08:08:40
  Encryption key....: [none]
  Authentication key: [none]
  General key info..: sub  ed25519/0x78BBEC94A894C992 2023-05-13 OpenWrt Build System (Nitrokey3) <contact@openwrt.org>
  sec#  ed25519/0xCAE438715492B555  created: 2023-05-13  expires: 2033-05-10
  ssb>  ed25519/0x78BBEC94A894C992  created: 2023-05-13  expires: 2033-05-10
                                    card-no: 000F XXXXXXXX
```

### Cross sign new GPG key

![FIXME](/lib/images/smileys/fixme.svg) [http://lists.openwrt.org/pipermail/openwrt-devel/2018-December/020856.html](http://lists.openwrt.org/pipermail/openwrt-devel/2018-December/020856.html "http://lists.openwrt.org/pipermail/openwrt-devel/2018-December/020856.html")

```
  $ gpg --list-signatures $KEYID
  pub   ed25519/0xCAE438715492B555 2023-05-13 [C] [expires: 2033-05-10]
        Key fingerprint = E902 5ED8 43D0 FDC7 866F  7064 CAE4 3871 5492 B555
  uid                   [ultimate] OpenWrt Build System (Nitrokey3) <contact@openwrt.org>
  sig 3        0xCAE438715492B555 2023-05-13  OpenWrt Build System (Nitrokey3) <contact@openwrt.org>
  sig          0xCD84BCED626471F1 2023-05-13  OpenWrt Build System (PGP key for unattended snapshot builds) <pgpsign-snapshots@openwrt.org>
  sig          0xCD54E82DADB3684D 2023-05-13  OpenWrt Build System (GnuPGP key for 22.03 release builds) <pgpsign-22.03@openwrt.org>
  sig          0x88CA59E88F681580 2023-05-13  OpenWrt Build System (PGP key for 21.02 release builds) <pgpsign-21.02@openwrt.org>
  sub   ed25519/0x78BBEC94A894C992 2023-05-13 [S] [expires: 2033-05-10]
  sig          0xCAE438715492B555 2023-05-13  OpenWrt Build System (Nitrokey3) <contact@openwrt.org>
```

### Upload public key to various public key servers

```
gpg --send-key $KEYID
gpg --keyserver pgp.mit.edu --send-key $KEYID
gpg --keyserver keys.gnupg.net --send-key $KEYID
gpg --keyserver hkps://keyserver.ubuntu.com:443 --send-key $KEYID
```

## Add GPG key to keyring.git repo

1. [gpg: add OpenWrt 21.02 signing key](https://git.openwrt.org/?p=keyring.git%3Ba%3Dcommit%3Bh%3Dbc4d80f064f2af385a78705d5de0fc8e882c3991 "https://git.openwrt.org/?p=keyring.git;a=commit;h=bc4d80f064f2af385a78705d5de0fc8e882c3991")

### Update package/system/openwrt-keyring/Makefile package

1. [openwrt-keyring: add OpenWrt 21.02 GPG/usign keys](https://git.openwrt.org/?p=openwrt%2Fopenwrt.git%3Ba%3Dcommit%3Bh%3D1bf6d70e60fdb45d81a8f10b90904cef38c73f70 "https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=1bf6d70e60fdb45d81a8f10b90904cef38c73f70")

### Add new GPG key information to the release signatures page

1. Add new key info to [signatures](/docs/guide-user/security/signatures "docs:guide-user:security:signatures") page
