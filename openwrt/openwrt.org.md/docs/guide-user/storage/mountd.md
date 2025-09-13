# mountd Configuration

![FIXME](/lib/images/smileys/fixme.svg) mountd is obsolete. As of December 2018, this is replaced by “fstools” (which handles block mount with the block binary) and “blockd” (which handles autofs)

The `/etc/config/mountd` configuration is provided by the *mountd* package. The `mountd` configuration file defines parameters for the OpenWrt automount daemon, a small programm that will automount USB storage devices.

## Sections

The configuration file consists of a section defining the mountd options.

#### mountd

The `mountd` section defines general daemon options. This is the default configuration for this section:

```
config 'mountd' 'mountd'
    option 'timeout' '60'
    option 'path' '/tmp/mounts/'
```

The `mountd` section contains these settings:

Name Type Required Default Description `timeout` integer `path` string
