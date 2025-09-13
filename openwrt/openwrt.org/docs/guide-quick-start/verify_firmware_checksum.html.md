# Verifying OpenWrt firmware binary

Today's Internet is a high-threat environment. In particular, supply chain attacks, in which an attacker compromises the process of downloading software and updates, are now frequent. Completely verifying any software you download before you install and use it is thus important.

Doing so for OpenWrt requires understanding the organization of the Web server that supplies the binaries you install. Using the 21.02.0 release for the x86-64 as an example, the structure is:

- [https://downloads.openwrt.org/releases/21.02.0/](https://downloads.openwrt.org/releases/21.02.0/ "https://downloads.openwrt.org/releases/21.02.0/") - all files for the 21.02.0 release
- [https://downloads.openwrt.org/releases/21.02.0/packages/](https://downloads.openwrt.org/releases/21.02.0/packages/ "https://downloads.openwrt.org/releases/21.02.0/packages/") - all packages for the 21.02.0 release
- [https://downloads.openwrt.org/releases/21.02.0/targets/](https://downloads.openwrt.org/releases/21.02.0/targets/ "https://downloads.openwrt.org/releases/21.02.0/targets/") - all firmware for the 21.02.0 release
- [https://downloads.openwrt.org/releases/21.02.0/targets/x86/](https://downloads.openwrt.org/releases/21.02.0/targets/x86/ "https://downloads.openwrt.org/releases/21.02.0/targets/x86/") - all firmware for the `x86` instruction set
- [https://downloads.openwrt.org/releases/21.02.0/targets/x86/64/](https://downloads.openwrt.org/releases/21.02.0/targets/x86/64/ "https://downloads.openwrt.org/releases/21.02.0/targets/x86/64/") - all firmware for products sharing the `64` architecture, and an index file containing a table with columns for abbreviated file names, SHA256 hash, file size and creation date for each of the firmware files.
- [https://downloads.openwrt.org/releases/21.02.0/targets/x86/64/sha256sums](https://downloads.openwrt.org/releases/21.02.0/targets/x86/64/sha256sums "https://downloads.openwrt.org/releases/21.02.0/targets/x86/64/sha256sums") - a file containing SHA256 hashes for each of the firmware files for products sharing the `x86/64` architecture
- [https://downloads.openwrt.org/releases/21.02.0/targets/x86/64/sha256sums.asc](https://downloads.openwrt.org/releases/21.02.0/targets/x86/64/sha256sums.asc "https://downloads.openwrt.org/releases/21.02.0/targets/x86/64/sha256sums.asc") - a detached GPG signature for the `sha256sums` file created by the 21.02.0 signing private key.

The 21.02.0 signing key verifies the signature in the `sha256sums.asc` file. The signature in the `sha256sums.asc` file verifies the integrity of the `sha256sums` file. The SHA256 hash in the `sha256sums` file verifies the integrity of the individual files in the `64` directory. The same goes for all the other supported architectures. Note that the URLs above are all `https:` not `http:` - some of the relevant links on [https://openwrt.org](https://openwrt.org "https://openwrt.org") are `http:` but if you find one you should change it to `https:` before using the URL. `http:` connections are vulnerable to interception and corruption.

In order to fully verify a firmware file it is necessary to download:

- The firmware file itself
- The `shasums` file
- The `sha256sums.asc` file
- The public signing key

Then the steps are:

- Verify the signature for the `sha256sums` file.
- Use the `sha256sums` file to verify the SHA256 hash of the firmware file.

If you **assume** that you are not the victim of a supply chain attack, that no-one has compromised `downloads.openwrt.org` or your connection to it, it is possible to perform a partial verification by omitting the signature check. This is **not recommended**.

If the signature check fails or if the SHA256 hashes do not match **do not flash the downloaded firmware**. Your download might be corrupted and brick your router, or it might be malware and open your network to ransomware.

## Linux

For obtaining the correct GPG key, see [OpenWrt GPG public keys and fingerprints](/docs/guide-user/security/signatures "docs:guide-user:security:signatures")

Note that 23.05 releases are signed with the “PGP key for unattended snapshot builds (deprecated)”

```
# Download files
cd /tmp
curl --progress-bar -o openwrt-21.02.0-x86-64-generic-squashfs-combined.img.gz \
    https://downloads.openwrt.org/releases/21.02.0/targets/x86/64/openwrt-21.02.0-x86-64-generic-squashfs-combined.img.gz
curl --progress-bar -o sha256sums \
    https://downloads.openwrt.org/releases/21.02.0/targets/x86/64/sha256sums
curl --progress-bar -o sha256sums.asc \
    https://downloads.openwrt.org/releases/21.02.0/targets/x86/64/sha256sums.asc
 
# Import GPG public key
gpg --receive-keys 88CA59E88F681580
 
# Check GPG public key fingerprint
gpg --fingerprint 88CA59E88F681580
 
# Verify GPG signature
gpg --status-fd 1 --with-fingerprint --verify sha256sums.asc sha256sums 2>&1 | grep -e Good
 
# Verify SHA256 checksums
sha256sum --ignore-missing -c sha256sums 2> /dev/null | grep -e OK
```

For Linux systems there is a script called [download-check-artifact.sh](https://raw.githubusercontent.com/openwrt/openwrt/refs/heads/main/scripts/download-check-artifact.sh "https://raw.githubusercontent.com/openwrt/openwrt/refs/heads/main/scripts/download-check-artifact.sh") that automates the process. Make sure to specify the URL using HTTPS. Also, make sure that you edit the script before running and replace the **deprecated sks-keyservers.net** with **keyserver.ubuntu.com** or **keys.openpgp.org** or **pgp.mit.edu** .

Here is an edited recording of a session using the script after adding the public signing key to the keyring:

```
# download-check-artifact.sh https://downloads.openwrt.org/releases/21.02.0/targets/x86/64/openwrt-21.02.0-x86-64-generic-squashfs-combined.img.gz

1) Downloading image file
=========================
[progress bar]
2) Downloading checksum file
============================
[progress bar]
3) Downloading the GPG signature
================================
[progress bar]
4) Verifying GPG signature
==========================
gpg: Signature made Thu Sep  2 09:39:21 2021 MSK
gpg:                using RSA key 667205E379BAF348863A5C6688CA59E88F681580
gpg: Good signature from "OpenWrt Build System (PGP key for 21.02 release builds) <pgpsign-21.02@openwrt.org>" [ultimate]
Primary key fingerprint: 6672 05E3 79BA F348 863A  5C66 88CA 59E8 8F68 1580

5) Verifying SHA256 checksum
============================
openwrt-21.02.0-x86-64-generic-squashfs-combined.img.gz: OK

Verification done!
==================
Firmware image placed in '~/Downloads/OpenWrt/openwrt-21.02.0-x86-64-generic-squashfs-combined.img.gz'.

Cleaning up.
```

If the script returns an error code, check its source code for an explanation of the cause of the error.

## Windows

See also: [Verifying GPG signature](/docs/guide-quick-start/verify_firmware_checksum#linux "docs:guide-quick-start:verify_firmware_checksum")

Checksums are stored in the folder view of the download server's webpage. Obtain it by following those steps:

1. Recall the URL used to download the firmware image, e.g. `https://downloads.openwrt.org/releases/21.02.0/targets/x86/64/openwrt-21.02.0-x86-64-generic-squashfs-combined.img.gz`
2. Strip of everything behind the last `/` and open the URL in your browser, e.g. `https://downloads.openwrt.org/releases/21.02.0/targets/x86/64/`
3. Find the file you downloaded. The string in the column `sha256sum` is the checksum, e.g. `c41212b58775686ad5ed38904c0798899e6b664e9856c48831f1efce85f09824`

Software to verify checksums:

- Newer Windows has a built-in tool to calculate sha256sums called `certutil`, but it has no graphical user interface so we will have to use the command line to interact with it.
- Older Windows version need to download a sha256 tool, for example [MD5 &amp; SHA Checksum Utility](https://raylin.wordpress.com/downloads/md5-sha-1-checksum-utility/ "https://raylin.wordpress.com/downloads/md5-sha-1-checksum-utility/") (the free version).

To use the built-in `certutil`:

1. Click the Windows icon, type “cmd” and hit enter.
2. Execute (assuming you downloaded the file to your Downloads folder):
   
   ```
   certutil -hashfile "%USERPROFILE%\Downloads\openwrt-file-name-here" sha256
   ```
3. This will print a checksum like this (file name followed by string with letters and numbers),
   
   ```
   SHA256-Hash of file C:\Users\USERNAME\Downloads\openwrt-21.02.0-x86-64-generic-squashfs-combined.img.gz:
   c4 12 12 b5 87 75 68 6a d5 ed 38 90 4c 07 98 89 9e 6b 66 4e 98 56 c4 88 31 f1 ef ce 85 f0 98 24
   ```
4. Remove spaces from this checksum output, e.g. using replace function in notepad:
   
   ```
   c41212b58775686ad5ed38904c0798899e6b664e9856c48831f1efce85f09824
   ```
5. Check that the checksum string without blanks matches the one you can find in the **sha256sums** field on the download page you retrieved by following the instructions above.

## macOS

See also: [Verifying GPG signature](/docs/guide-quick-start/verify_firmware_checksum#linux "docs:guide-quick-start:verify_firmware_checksum")

Checksums are stored in the folder view of the download server's webpage. Obtain it by following those steps:

1. Recall the URL used to download the firmware image, e.g. `https://downloads.openwrt.org/releases/21.02.0/targets/x86/64/openwrt-21.02.0-x86-64-generic-squashfs-combined.img.gz`
2. Strip of everything behind the last `/` and open the URL in your browser, e.g. `https://downloads.openwrt.org/releases/21.02.0/targets/x86/64/`
3. Find the file you downloaded. The string in the column `sha256sum` is the checksum, e.g. `c41212b58775686ad5ed38904c0798899e6b664e9856c48831f1efce85f09824`

Mac has an integrated tool to check sha256sums, but it has no graphical user interface so we will have to use the Terminal to interact with it.

1. Click the Finder icon in the Dock.
2. Click Applications in the Favorites list.
3. Find the Utilities folder and click to open it.
4. Locate Terminal and double-click the icon to open the program.
5. Open a terminal window, and execute (assuming you downloaded the file on the desktop):
   
   ```
   shasum -a 256 ./Desktop/file-name-here
   ```
6. it will print something like this (string with letters and numbers followed by file name):
   
   ```
   c41212b58775686ad5ed38904c0798899e6b664e9856c48831f1efce85f09824
   openwrt-21.02.0-x86-64-generic-squashfs-combined.img.gz
   ```
7. Check that the checksum string matches the one you can find in the **sha256sums** field on the download page you retrieved by following the instructions above.
