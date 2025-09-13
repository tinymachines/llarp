# How to prepare buildbot for major release

These are collected notes of the steps we've done during preparation of buildbot infrastructure for 21.02 release.

## Generate usign key

```
usign -G -c "Public usign key for 22.03 release builds" -s secret.key -p public.key
```

### Add usign public key to keyring

```
usign -F -p public.key
2f8b0b98e08306bf
 
mv public.key openwrt/keyring.git/usign/2f8b0b98e08306bf
```

Add usign secret.key to *ansible/inventories/openwrt-secrets.yml*:

```
vault_buildbot_usign_key_openwrt_22_03:
```

## Add GPG/usign keys to keyring.git repo

1. [gpg: add OpenWrt 21.02 signing key](https://git.openwrt.org/?p=keyring.git%3Ba%3Dcommit%3Bh%3Dbc4d80f064f2af385a78705d5de0fc8e882c3991 "https://git.openwrt.org/?p=keyring.git;a=commit;h=bc4d80f064f2af385a78705d5de0fc8e882c3991")
2. [usign: add 21.02 release build pubkey](https://git.openwrt.org/?p=keyring.git%3Ba%3Dcommit%3Bh%3D49283916005d7868923d34ab34f14188cf74812d "https://git.openwrt.org/?p=keyring.git;a=commit;h=49283916005d7868923d34ab34f14188cf74812d")

### Update package/system/openwrt-keyring/Makefile package

1. [openwrt-keyring: add OpenWrt 21.02 GPG/usign keys](https://git.openwrt.org/?p=openwrt%2Fopenwrt.git%3Ba%3Dcommit%3Bh%3D1bf6d70e60fdb45d81a8f10b90904cef38c73f70 "https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=1bf6d70e60fdb45d81a8f10b90904cef38c73f70")
2. [openwrt-keyring: make opkg use 22.03 usign key](https://git.openwrt.org/2d03f27f0f0768e25f3b00fb5b4f2974144c66e3 "https://git.openwrt.org/2d03f27f0f0768e25f3b00fb5b4f2974144c66e3") (NOTE: this needs to be done only in the release branch)

### Add new GPG key information to the release signatures page

1. Add new key info to [signatures](/docs/guide-user/security/signatures "docs:guide-user:security:signatures") page

## Prepare buildbot infra and assign buildworkers

1. [inventory: add setup for 21.02 release](https://git.openwrt.org/?p=admin%2Fansible.git%3Ba%3Dcommit%3Bh%3Dec7b5803e269911aa45e86ad694f72eec57e68fd "https://git.openwrt.org/?p=admin/ansible.git;a=commit;h=ec7b5803e269911aa45e86ad694f72eec57e68fd")

### Apply new build infra 21.02

```
ansible-playbook --diff -i inventories/prod buildworker.yml --tags cfg,recreate-slave --limit fsf-02,fsf-04,osuosl-vm-03,osuosl-vm-04,truecz-01,truecz-02,buildmaster
```
