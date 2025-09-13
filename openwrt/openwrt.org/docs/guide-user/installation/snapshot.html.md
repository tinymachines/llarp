# Filesystem snapshot feature: /sbin/snapshot

This feature was listed in [Barrier Breaker announce, documentation requested](https://lists.openwrt.org/pipermail/openwrt-devel/2014-July/026713.html "https://lists.openwrt.org/pipermail/openwrt-devel/2014-July/026713.html"). The following information comes from [this post on the Battlemesh mailing list](http://ml.ninux.org/pipermail/battlemesh/2014-March/002894.html "http://ml.ninux.org/pipermail/battlemesh/2014-March/002894.html") by the programmer who implemented it.

## Use cases

*There are many use cases where this makes sense, however it should not be seen as the new replacement for jffs2.*  
This stuff is aimed at deployments, where many units run the same firmware and should all get the same updates at the same time. We aim to store config and small fixes in the block chain. After all, it is a tmpfs we run on.

The cool thing is, that you can simply rollback to an existing snapshot if anything fails. A trigger for a rollback could be “can't connect to mesh anymore” etc.

## Implementation details

Normally we have squash + jffs2 overlay. What we do instead is this...

We don't use rootfs\_data for jffs2 anymore but instead use it to store a chain of erasesize aligned blocks. Each block has a header and a tar file inside it. Header has size, hash, and type. There are snapshot and volatile blocks. The volatile entry can only exist once and as the last sentinel of the block chain.

Upon boot, the unit mounts squash, does an overlayfs mount, but uses a tmpfs instead of the usual jffs2 (which doesn't exist anymore). We unpack the tar files in the order found inside the chain. Once all snapshot blocks are unpacked, we do another stacked overlayfs mount with a tmpfs and unpack our volatile block into it. We now have a stacked overlay root with `/snapshot` holding the delta of the first and `/overlay` holding the delta of the second mount.

## Usage

You can test this in trunk images right now. The tool is deployed in the default config since Barrier Breaker. Once your system has booted and jffs2 init is done, simply call

```
# snapshot convert
```

This will turn your current jffs2 overlay delta into a block chain with a single volatile block. The system is now essentially similar to an initramfs image, where the changes in `/etc/config/` get lost on boot.  
So there is a mechanism to write the content of `/overlay` into the volatile block.

```
# snapshot config
```

If at any point I am happy with my current config, I can also snapshot the system. This will essentially convert an existing volatile entry to a snapshot entry.

```
# snapshot push
```

When overwriting blocks (i.e. writing a new volatile over an existing one or while converting a volatile to a snapshot) we use the last few sectors of the flash as a back buffer. This way we have a valid copy of the “data to be deleted” while we are overwriting it. This allows us to always be able to fallback to the last known working version.

There is also

```
# snapshot upgrade
```

This will try to pull opkg updates from the server, for example a security fix, and if it does find one or more it will automagically install the updates and then save this as a snapshot entry in the chain.
