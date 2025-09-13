# How to create a major release

Here is an example how to create the major release 21.02.

1. create a commit to set branch defaults
2. create branches
3. create release keys
4. configure build bots

## Create a branch openwrt-21.02

First create the release branch on

- source.git (main repo)
- package.git
- routing.git
- telephony.git
- lucy.git

## Create a commit changing the defaults

similiar to [?p=openwrt/openwrt.git;a=commit;h=1cd121dd11aadc799b179ebb8600f27621acc84f](https://git.openwrt.org/?p=openwrt%2Fopenwrt.git%3Ba%3Dcommit%3Bh%3D1cd121dd11aadc799b179ebb8600f27621acc84f "https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=1cd121dd11aadc799b179ebb8600f27621acc84f")

### feeds.conf.default:

append the branch as ;21.02. E.g. src-git packages [https://git.openwrt.org/feed/packages.git;openwrt-21.02](https://git.openwrt.org/feed/packages.git;openwrt-21.02 "https://git.openwrt.org/feed/packages.git;openwrt-21.02")

### include/version.mk:

```
VERSION_NUMBER = 21.02-SNAPSHOT
VERSION_REPO = "http://downloads.openwrt.org/releases/21.02-SNAPSHOT"
```

### package/base-files/image-config.in

```
VERSION_REPO:
  default: http://downloads.openwrt.org/releases/21.02-SNAPSHOT
```

TODO: put this patching step into maketag.sh ([https://github.com/KanjiMonster/maintainer-tools](https://github.com/KanjiMonster/maintainer-tools "https://github.com/KanjiMonster/maintainer-tools"))
