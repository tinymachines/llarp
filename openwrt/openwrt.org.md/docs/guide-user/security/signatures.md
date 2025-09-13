# OpenWrt Public Keys

This page lists the fingerprints of all public keys in use by OpenWrt and is automatically generated from the developer keys present in the [keyring.git](https://git.openwrt.org/?p=keyring.git "https://git.openwrt.org/?p=keyring.git") repository.

Refer to our [signing documentation page](/docs/guide-user/security/release_signatures "docs:guide-user:security:release_signatures") to learn more about file verification and key generation.

### GnuPG key fingerprints

GnuPG keys are mainly used to verify the integrity of firmware image downloads.

Signature verification ensures that image downloads have not been tampered with and that the third-party download mirrors serve genuine content. ---

#### Universal GPG signing key from Nitrokey 3A key

This key is available only from Nitrokey 3A Mini USB security key, [Prepare Nitrokey 3A Mini for build artifact signing](/docs/guide-developer/releases/provision-nitrokey3 "docs:guide-developer:releases:provision-nitrokey3") and [?p=keyring.git;a=commit;h=6b42a5c8b7dc049b899869b2a1b94daf69ceb2f5](https://git.openwrt.org/?p=keyring.git%3Ba%3Dcommit%3Bh%3D6b42a5c8b7dc049b899869b2a1b94daf69ceb2f5 "https://git.openwrt.org/?p=keyring.git;a=commit;h=6b42a5c8b7dc049b899869b2a1b94daf69ceb2f5") provides more details. Deployed to production build infra since [2024-11-05](https://lists.openwrt.org/pipermail/openwrt-devel/2024-November/043358.html "https://lists.openwrt.org/pipermail/openwrt-devel/2024-November/043358.html")

User ID: **OpenWrt Build System (Nitrokey3)** [contact@openwrt.org](mailto:contact@openwrt.org "contact@openwrt.org")  
Public Key: **0x1D53D1877742E911** (ed25519, created 2023-05-18, expires 2033-05-18)  
Fingerprint: `8A8B C12F 46B8 36C0 F9CD B36F 1D53 D187 7742 E911`  
Signing Subkey: **0x2B0151090606D1D9** (ed25519, created 2022-03-25, expires 2025-04-03)  
Fingerprint: `92C5 61DE 55AE 6552 F3C7 36B8 2B01 5109 0606 D1D9`  
[Last change: 2023-05-18 16:01:25 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dcommit%3Bh%3D6b42a5c8b7dc049b899869b2a1b94daf69ceb2f5 "https://git.openwrt.org/?p=keyring.git;a=commit;h=6b42a5c8b7dc049b899869b2a1b94daf69ceb2f5") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dgpg%2F0x1D53D1877742E911.asc "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=gpg/0x1D53D1877742E911.asc")

\---

#### PGP key for 17.01 "Reboot" release builds

User ID: **OpenWrt Build System** [pgpsign-17.01@openwrt.org](mailto:pgpsign-17.01@openwrt.org "pgpsign-17.01@openwrt.org")  
Public Key: 0x833C6010**D52BBB6B** (4096 Bit RSA, created 2017-01-16, expires 2020-07-22)  
Fingerprint: `B09B E781 AE8A 0CD4 702F DCD3 833C 6010 D52B BB6B`  
[Last change: 2019-07-24 16:55:07 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dgpg%2FD52BBB6B.asc "https://git.openwrt.org/?p=keyring.git;a=history;f=gpg/D52BBB6B.asc") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dgpg%2FD52BBB6B.asc "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=gpg/D52BBB6B.asc")

\---

#### PGP key for 18.06 release builds

User ID: **OpenWrt Build System** [pgpsign-18.06@openwrt.org](mailto:pgpsign-18.06@openwrt.org "pgpsign-18.06@openwrt.org")  
Public Key: 0xFBCB78F0**15807931** (4096 Bit RSA, created 2019-07-15, expires 2021-07-14)  
Fingerprint: `AD05 0736 3D2B CE9C 9E36 CEC4 FBCB 78F0 1580 7931`  
[Last change: 2019-07-24 16:55:07 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dgpg%2F15807931.asc "https://git.openwrt.org/?p=keyring.git;a=history;f=gpg/15807931.asc") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dgpg%2F15807931.asc "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=gpg/15807931.asc")

\---

#### PGP key for 19.07 release builds

User ID: **OpenWrt Build System** [pgpsign-19.07@openwrt.org](mailto:pgpsign-19.07@openwrt.org "pgpsign-19.07@openwrt.org")  
Public Key: 0x28A39BC3**2074BE7A** (4096 Bit RSA, created 2019-07-14, expires 2022-08-09)  
Fingerprint: `D9C6 901F 45C9 B868 5868 7DFF 28A3 9BC3 2074 BE7A`  
[Last change: 2021-08-09 21:30:39 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dgpg%2F2074BE7A.asc "https://git.openwrt.org/?p=keyring.git;a=history;f=gpg/2074BE7A.asc") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dgpg%2F2074BE7A.asc "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=gpg/2074BE7A.asc")

\---

#### PGP key for 21.02 release builds

User ID: **OpenWrt Build System** [pgpsign-21.02@openwrt.org](mailto:pgpsign-21.02@openwrt.org "pgpsign-21.02@openwrt.org")  
Public Key: 0x88CA59E8**8F681580** (4096 Bit RSA, created 2021-02-20, expires 2024-04-03)  
Fingerprint: `6672 05E3 79BA F348 863A 5C66 88CA 59E8 8F68 1580`  
Signing Subkey: 0xD3867007 **F801C9B3** (4096 Bit RSA, created 2021-02-20, expires 2024-04-03)  
Fingerprint: `EF36 6A7C D0AD B704 3094 11E6 D386 7007 F801 C9B3`  
[Last change: 2023-04-04 10:32:24 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dgpg%2F88CA59E8.asc "https://git.openwrt.org/?p=keyring.git;a=history;f=gpg/88CA59E8.asc") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dgpg%2F88CA59E8.asc "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=gpg/88CA59E8.asc")

\---

#### PGP key for 22.03 release builds

User ID: **OpenWrt Build System** [pgpsign-22.03@openwrt.org](mailto:pgpsign-22.03@openwrt.org "pgpsign-22.03@openwrt.org")  
Public Key: 0xCD54E82D**ADB3684D** (4096 Bit RSA, created 2022-03-25, expires 2025-04-03)  
Fingerprint: `BF85 6781 A012 93C8 409A BE72 CD54 E82D ADB3 684D`  
Signing Subkey: 0xAB3F4049 **13AA0D5A** (4096 Bit RSA, created 2022-03-25, expires 2025-04-03)  
Fingerprint: `1FDF CF69 F6FB 7776 B14D D61D AB3F 4049 13AA 0D5A`  
[Last change: 2023-04-04 10:33:03 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dgpg%2FCD54E82DADB3684D.asc "https://git.openwrt.org/?p=keyring.git;a=history;f=gpg/CD54E82DADB3684D.asc") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dgpg%2FCD54E82DADB3684D.asc "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=gpg/CD54E82DADB3684D.asc")

\---

#### PGP key for unattended snapshot builds (deprecated)

User ID: **OpenWrt Build System** [pgpsign-snapshots@openwrt.org](mailto:pgpsign-snapshots@openwrt.org "pgpsign-snapshots@openwrt.org")  
Public Key: 0xCD84BCED**626471F1** (4096 Bit RSA, created 2016-07-26)  
Fingerprint: `54CC 7430 7A2C 6DC9 CE61 8269 CD84 BCED 6264 71F1`  
Signing Subkey: 0xF93525A8 **8B699029** (4096 Bit RSA, created 2016-07-26)  
Fingerprint: `6D92 78A3 3A9A B314 6262 DCEC F935 25A8 8B69 9029`  
[Last change: 2019-07-24 18:05:02 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dgpg%2F626471F1.asc "https://git.openwrt.org/?p=keyring.git;a=history;f=gpg/626471F1.asc") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dgpg%2F626471F1.asc "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=gpg/626471F1.asc")

#### 18.06 Signing Key

User ID: **OpenWrt Release Builder** [openwrt-devel@lists.openwrt.org](mailto:openwrt-devel@lists.openwrt.org "openwrt-devel@lists.openwrt.org")  
Public Key: 0x0F202574**17E1CE16** (4096 Bit RSA, created 2018-05-16, expires 2020-05-15)  
Fingerprint: `6768 C55E 79B0 32D7 7A28 DA5F 0F20 2574 17E1 CE16`  
[Last change: 2018-05-18 07:48:41 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dgpg%2F17E1CE16.asc "https://git.openwrt.org/?p=keyring.git;a=history;f=gpg/17E1CE16.asc") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dgpg%2F17E1CE16.asc "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=gpg/17E1CE16.asc")

\---

#### Public key of Alexander Couzens

User ID: **Alexander Couzens** [lynxis@fe80.eu](mailto:lynxis@fe80.eu "lynxis@fe80.eu")  
Public Key: 0xC29E9DA6**A0DF8604** (4096 Bit RSA, created 2012-12-18, expires 2017-09-14)  
Fingerprint: `390D CF78 8BF9 AA50 4F8F F1E2 C29E 9DA6 A0DF 8604`  
Signing Subkey: 0xB43BC93C **03A94AEB** (4096 Bit RSA, created 2012-12-18, expires 2017-09-14)  
Fingerprint: `E838 0FB2 1525 57F5 B6A6 7C78 B43B C93C 03A9 4AEB`  
[Last change: 2017-06-09 10:07:28 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dgpg%2FA0DF8604.asc "https://git.openwrt.org/?p=keyring.git;a=history;f=gpg/A0DF8604.asc") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dgpg%2FA0DF8604.asc "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=gpg/A0DF8604.asc")

\---

#### Public key of Álvaro Fernández Rojas

User ID: **Álvaro Fernández Rojas** [noltari@gmail.com](mailto:noltari@gmail.com "noltari@gmail.com")  
Public Key: 0x9E2ADB5C**AA382EC1** (4096 Bit RSA, created 2016-04-16)  
Fingerprint: `5155 F5AE EACC 0C33 E8A3 6F2A 9E2A DB5C AA38 2EC1`  
Signing Subkey: 0x9712EBC9 **A7DCDFFB** (4096 Bit RSA, created 2016-04-16, expires 2018-04-16)  
Fingerprint: `FB89 4037 B454 05CA 95EE 34DC 9712 EBC9 A7DC DFFB`  
[Last change: 2016-04-16 09:59:03 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dgpg%2FA7DCDFFB.asc "https://git.openwrt.org/?p=keyring.git;a=history;f=gpg/A7DCDFFB.asc") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dgpg%2FA7DCDFFB.asc "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=gpg/A7DCDFFB.asc")

\---

#### Public key of Florian Fainelli

User ID: **Florian Fainelli** [f.fainelli@gmail.com](mailto:f.fainelli@gmail.com "f.fainelli@gmail.com")  
Public Key: 0xED7282E2**08DAF586** (4096 Bit RSA, created 2016-08-26)  
Fingerprint: `10BD EE38 E7DF DFC7 D5D3 CC09 ED72 82E2 08DA F586`  
Signing Subkey: 0x411E8E8B **13CEE033** (4096 Bit RSA, created 2016-08-26, expires 2018-08-26)  
Fingerprint: `3892 DB8D 02B0 2F94 4457 F826 411E 8E8B 13CE E033`  
[Last change: 2017-01-15 04:17:20 +0100](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dgpg%2F08DAF586.asc "https://git.openwrt.org/?p=keyring.git;a=history;f=gpg/08DAF586.asc") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dgpg%2F08DAF586.asc "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=gpg/08DAF586.asc")

\---

#### Public key of Hans Dedecker

User ID: **Hans Dedecker** [dedeckeh@gmail.com](mailto:dedeckeh@gmail.com "dedeckeh@gmail.com")  
Public Key: 0xAAD7E169**0C74E7B8** (4096 Bit RSA, created 2016-12-06)  
Fingerprint: `569E 3F24 712D EF28 C244 8C12 AAD7 E169 0C74 E7B8`  
Signing Subkey: 0xB4662C25 **42AB0412** (4096 Bit RSA, created 2016-12-06, expires 2018-12-06)  
Fingerprint: `FBDA 576F 6054 FE3B 8A74 7233 B466 2C25 42AB 0412`  
[Last change: 2016-12-07 20:27:23 +0100](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dgpg%2F0C74E7B8.asc "https://git.openwrt.org/?p=keyring.git;a=history;f=gpg/0C74E7B8.asc") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dgpg%2F0C74E7B8.asc "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=gpg/0C74E7B8.asc")

\---

#### Public key of Hauke Mehrtens

User ID: **Hauke Mehrtens** [hauke@hauke-m.de](mailto:hauke@hauke-m.de "hauke@hauke-m.de")  
Public Key: 0x93DD2063**0910B515** (4096 Bit RSA, created 2018-07-15)  
Fingerprint: `B8FB F3F0 AB56 4EE8 4F7F B1D3 93DD 2063 0910 B515`  
Signing Subkey: 0xF1B76785 **9CB2EBC7** (2048 Bit RSA, created 2018-07-15)  
Fingerprint: `CB3D 3FB8 071D F89C 179B 0B43 F1B7 6785 9CB2 EBC7`  
[Last change: 2018-07-15 17:25:50 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dgpg%2F9CB2EBC7.asc "https://git.openwrt.org/?p=keyring.git;a=history;f=gpg/9CB2EBC7.asc") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dgpg%2F9CB2EBC7.asc "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=gpg/9CB2EBC7.asc")

\---

#### Public key of John Crispin

User ID: **John Crispin** [john@phrozen.org](mailto:john@phrozen.org "john@phrozen.org")  
Public Key: 0x9E8F1F29**34E5BBCC** (4096 Bit RSA, created 2016-04-14)  
Fingerprint: `B4DE 4970 B205 473D 26CD 818F 9E8F 1F29 34E5 BBCC`  
Signing Subkey: 0x3D8BE4EB **49785F4F** (4096 Bit RSA, created 2016-04-14, expires 2018-04-14)  
Fingerprint: `AA98 B891 5121 33A3 CD28 BB4A 3D8B E4EB 4978 5F4F`  
[Last change: 2016-04-14 12:40:54 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dgpg%2F34E5BBCC.asc "https://git.openwrt.org/?p=keyring.git;a=history;f=gpg/34E5BBCC.asc") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dgpg%2F34E5BBCC.asc "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=gpg/34E5BBCC.asc")

\---

#### Public key of Jo-Philipp Wich

User ID: **Jo-Philipp Wich** [jo@mein.io](mailto:jo@mein.io "jo@mein.io")  
Public Key: 0x3AA1F5B3**47D94086** (4096 Bit RSA, created 2015-04-28, expires 2021-07-23)  
Fingerprint: `6598 853C 5C2E C44B F362 224B 3AA1 F5B3 47D9 4086`  
Signing Subkey: 0x42E2CBBF **3A2E66D3** (4096 Bit RSA, created 2016-02-29, expires 2021-07-23)  
Fingerprint: `A040 E369 712C 66FF F3D1 60F2 42E2 CBBF 3A2E 66D3`  
[Last change: 2019-07-24 18:04:39 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dgpg%2F47D94086.asc "https://git.openwrt.org/?p=keyring.git;a=history;f=gpg/47D94086.asc") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dgpg%2F47D94086.asc "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=gpg/47D94086.asc")

\---

#### Public key of Stijn Tintel

User ID: **Stijn Tintel** [stijn@linux-ipv6.be](mailto:stijn@linux-ipv6.be "stijn@linux-ipv6.be")  
Public Key: 0x818021EB**B6C9ECDA** (4096 Bit RSA, created 2016-12-11)  
Fingerprint: `3176 362F 0318 F3C1 7DBF 89DE 8180 21EB B6C9 ECDA`  
Signing Subkey: 0xB36CBB03 **10F11685** (4096 Bit RSA, created 2016-12-11, expires 2018-12-11)  
Fingerprint: `6957 1749 D3D7 48C5 6B6B 742D B36C BB03 10F1 1685`  
[Last change: 2017-10-03 11:43:41 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dgpg%2F10F11685.asc "https://git.openwrt.org/?p=keyring.git;a=history;f=gpg/10F11685.asc") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dgpg%2F10F11685.asc "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=gpg/10F11685.asc")

\---

#### Public key of Ted Hess

User ID: **Ted Hess** [thess@kitschensync.net](mailto:thess@kitschensync.net "thess@kitschensync.net")  
Public Key: 0x9C46FAFC**12D89000** (4096 Bit RSA, created 2016-04-26)  
Fingerprint: `C2C9 C93B F477 5C11 D4F6 617C 9C46 FAFC 12D8 9000`  
Signing Subkey: 0x31464E53 **8A1617C4** (4096 Bit RSA, created 2016-04-26, expires 2018-04-26)  
Fingerprint: `021D 623A 818E E4D3 D1AC 6041 3146 4E53 8A16 17C4`  
[Last change: 2016-04-26 18:18:19 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dgpg%2F12D89000.asc "https://git.openwrt.org/?p=keyring.git;a=history;f=gpg/12D89000.asc") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dgpg%2F12D89000.asc "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=gpg/12D89000.asc")

### usign public keys

The *usign* EC keys are used to sign repository indexes in order to ensure that packages fetched and installed via *opkg* are unmodified and genuine.

Those keys are usually installed by default and bundled as [openwrt-keyring](https://git.lede-project.org/?p=openwrt%2Fopenwrt.git%3Ba%3Dblob%3Bf%3Dpackage%2Fsystem%2Fopenwrt-keyring%2FMakefile "https://git.lede-project.org/?p=openwrt/openwrt.git;a=blob;f=package/system/openwrt-keyring/Makefile") package.

\---

#### Public usign key for 17.01 "Reboot" release builds

- Key-ID: `792d9d9b39f180dc`
- Key-Data: `RWR5LZ2bOfGA3FGliZosEDhodiAKDOISmQs/mmjo4rhcbFtqkibJqMzo`

[Last change: 2019-07-25 17:16:14 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dusign%2F792d9d9b39f180dc "https://git.openwrt.org/?p=keyring.git;a=history;f=usign/792d9d9b39f180dc") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dusign%2F792d9d9b39f180dc "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=usign/792d9d9b39f180dc")

\---

#### Public usign key for 18.06 release builds

- Key-ID: `1035ac73cc4e59e3`
- Key-Data: `RWQQNaxzzE5Z41cVmEh2rilAPKLsyfPKm+S4BJWA1Yv+LP1hKebmGtXi`

[Last change: 2019-07-25 17:16:14 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dusign%2F1035ac73cc4e59e3 "https://git.openwrt.org/?p=keyring.git;a=history;f=usign/1035ac73cc4e59e3") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dusign%2F1035ac73cc4e59e3 "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=usign/1035ac73cc4e59e3")

\---

#### Public usign key for 19.07 release builds

- Key-ID: `f94b9dd6febac963`
- Key-Data: `RWT5S53W/rrJY9BiIod3JF04AZ/eU1xDpVOb+rjZzAQBEcoETGx8BXEK`

[Last change: 2019-07-25 17:32:16 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dusign%2Ff94b9dd6febac963 "https://git.openwrt.org/?p=keyring.git;a=history;f=usign/f94b9dd6febac963") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dusign%2Ff94b9dd6febac963 "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=usign/f94b9dd6febac963")

\---

#### Public usign key for 21.02 release builds

- Key-ID: `2f8b0b98e08306bf`
- Key-Data: `RWQviwuY4IMGvwLfs6842A0m4EZU1IjczTxKMSk3BQP8DAQLHBwdQiaU`

[Last change: 2021-02-20 14:04:56 +0100](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dusign%2F2f8b0b98e08306bf "https://git.openwrt.org/?p=keyring.git;a=history;f=usign/2f8b0b98e08306bf") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dusign%2F2f8b0b98e08306bf "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=usign/2f8b0b98e08306bf")

\---

#### Public usign key for 22.03 release builds

- Key-ID: `4d017e6f1ed5d616`
- Key-Data: `RWRNAX5vHtXWFmt+n5di7XX8rTu0w+c8X7Ihv4oCyD6tzsUwmH0A6kO0`

[Last change: 2022-03-25 12:59:44 +0100](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dusign%2F4d017e6f1ed5d616 "https://git.openwrt.org/?p=keyring.git;a=history;f=usign/4d017e6f1ed5d616") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dusign%2F4d017e6f1ed5d616 "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=usign/4d017e6f1ed5d616")

\---

#### Public usign key for 24.10 release builds

- Key-ID: `d310c6f2833e97f7`
- Key-Data: `RWTTEMbygz6X95lKDAulctZy3aj15823THXfyrfXgwGbxZlXBd2brNcw`

[Last change: 2024-11-01 06:21:13 +0000](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dusign%2Fd310c6f2833e97f7 "https://git.openwrt.org/?p=keyring.git;a=history;f=usign/d310c6f2833e97f7") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dusign%2Fd310c6f2833e97f7 "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=usign/d310c6f2833e97f7")

\---

#### Public usign key for unattended snapshot builds

- Key-ID: `b5043e70f9a75cde`
- Key-Data: `RWS1BD5w+adc3j2Hqg9+b66CvLR7NlHbsj7wjNVj0XGt/othDgIAOJS+`

[Last change: 2019-07-25 17:16:14 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dusign%2Fb5043e70f9a75cde "https://git.openwrt.org/?p=keyring.git;a=history;f=usign/b5043e70f9a75cde") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dusign%2Fb5043e70f9a75cde "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=usign/b5043e70f9a75cde")

\---

#### Public usign key of Alexander Couzens

- Key-ID: `c10b9afab19ee428`
- Key-Data: `RWTBC5r6sZ7kKA/C5VnxUbJw5E0vy3MGo3MP2eXCQlgg65+2si4MKBnf`

[Last change: 2019-07-25 17:16:14 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dusign%2Fc10b9afab19ee428 "https://git.openwrt.org/?p=keyring.git;a=history;f=usign/c10b9afab19ee428") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dusign%2Fc10b9afab19ee428 "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=usign/c10b9afab19ee428")

\---

#### Public usign key of Álvaro Fernández Rojas

- Key-ID: `9ef4694208102c43`
- Key-Data: `RWSe9GlCCBAsQwI5+wztnWKHfBlvPFP2G00FvZyx+Wfv9AwSViUwo/s2`

[Last change: 2019-07-25 17:16:14 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dusign%2F9ef4694208102c43 "https://git.openwrt.org/?p=keyring.git;a=history;f=usign/9ef4694208102c43") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dusign%2F9ef4694208102c43 "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=usign/9ef4694208102c43")

\---

#### Public usign key of Hans Dedecker

- Key-ID: `5151f69420c3f508`
- Key-Data: `RWRRUfaUIMP1CAL9wvk3ABBHdUM+3SjMvIuJlK68b3b04Pw3wiaiAfxX`

[Last change: 2019-07-25 17:16:14 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dusign%2F5151f69420c3f508 "https://git.openwrt.org/?p=keyring.git;a=history;f=usign/5151f69420c3f508") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dusign%2F5151f69420c3f508 "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=usign/5151f69420c3f508")

\---

#### Public usign key of Hauke Mehrtens

- Key-ID: `b2d571e0880ff617`
- Key-Data: `RWSy1XHgiA/2F8nrQOTCa0aRCJzueqmDRzhxuwBJuC++Btb37yr7FKG0`

[Last change: 2019-07-25 17:16:14 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dusign%2Fb2d571e0880ff617 "https://git.openwrt.org/?p=keyring.git;a=history;f=usign/b2d571e0880ff617") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dusign%2Fb2d571e0880ff617 "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=usign/b2d571e0880ff617")

\---

#### Public usign key of John Crispin

- Key-ID: `dd6de0d06bbd3d85`
- Key-Data: `RWTdbeDQa709heyMmwDZjWmlhcTCUv/q+3TBYDPdJAGRuys6xcxE09fp`

[Last change: 2019-07-25 17:16:14 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dusign%2Fdd6de0d06bbd3d85 "https://git.openwrt.org/?p=keyring.git;a=history;f=usign/dd6de0d06bbd3d85") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dusign%2Fdd6de0d06bbd3d85 "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=usign/dd6de0d06bbd3d85")

\---

#### Public usign key of Jo-Philipp Wich

- Key-ID: `72a57f2191b211e0`
- Key-Data: `RWRypX8hkbIR4FLhtx5pjXcAIsI1iPUIcI5bMG8jZoiCkrwTstECBPqL`

[Last change: 2019-07-25 17:16:14 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dusign%2F72a57f2191b211e0 "https://git.openwrt.org/?p=keyring.git;a=history;f=usign/72a57f2191b211e0") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dusign%2F72a57f2191b211e0 "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=usign/72a57f2191b211e0")

\---

#### Public usign key of Stijn Tintel

- Key-ID: `0b26f36ae0f4106d`
- Key-Data: `RWQLJvNq4PQQbSGZ05Az9jXSt/xlw/IfWc6USiB2FHEUoWL7QpMibzv6`

[Last change: 2019-07-25 17:16:14 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dusign%2F0b26f36ae0f4106d "https://git.openwrt.org/?p=keyring.git;a=history;f=usign/0b26f36ae0f4106d") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dusign%2F0b26f36ae0f4106d "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=usign/0b26f36ae0f4106d")

\---

#### Public usign key of Ted Hess

- Key-ID: `dace9d4df16896bf`
- Key-Data: `RWTazp1N8WiWvy7rYxstJqaMzGiS4XfW1oyYrk2vwJMRBeBF+8xEA+EZ`

[Last change: 2019-07-25 17:16:14 +0200](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dusign%2Fdace9d4df16896bf "https://git.openwrt.org/?p=keyring.git;a=history;f=usign/dace9d4df16896bf") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Dusign%2Fdace9d4df16896bf "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=usign/dace9d4df16896bf")

### apk public keys

The apk EC keys using NIST P-256 curve are used to sign apk's *package.adb* indexes in order to ensure that packages fetched and installed via *apk* are unmodified and genuine.

Those keys are usually installed by default and bundled as [openwrt-keyring](https://git.openwrt.org/?p=openwrt%2Fopenwrt.git%3Ba%3Dblob%3Bf%3Dpackage%2Fsystem%2Fopenwrt-keyring%2FMakefile "https://git.openwrt.org/?p=openwrt/openwrt.git;a=blob;f=package/system/openwrt-keyring/Makefile") package.

\---

#### Public apk key for unattended snapshot builds

```
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEqDM0+yparYvbHosRPBhvT5Z3MEXz
AFYrTnqJrnURywsKpD+ZKCLjPluvoHe/FABIvIuHLvICALA3IMjhm0Z0cA==
-----END PUBLIC KEY-----
```

[Last change: 2024-10-28 12:47:26 +0000](https://git.openwrt.org/?p=keyring.git%3Ba%3Dhistory%3Bf%3Dapk%2Fopenwrt-snapshots.pem "https://git.openwrt.org/?p=keyring.git;a=history;f=apk/openwrt-snapshots.pem") | [Download](https://git.openwrt.org/?p=keyring.git%3Ba%3Dblob_plain%3Bf%3Df%3Dapk%2Fopenwrt-snapshots.pem "https://git.openwrt.org/?p=keyring.git;a=blob_plain;f=f=apk/openwrt-snapshots.pem")
