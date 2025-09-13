# Preserving OpenWrt settings during firmware upgrade

While upgrading OpenWrt firmware using web interface, you can utilize the “Keep settings” checkbox. It performs OpenWrt backup before upgrade and restores it after upgrade.

If you do not precisely understand the button's use cases, **uncheck “Keep Settings”** every time you flash a new OpenWrt sysupgrade to your device, to **not** preserve settings.

- Only check the “Keep settings” checkbox on minor bug fix upgrades that are known to not change the config structure.
- Only use it for the same firmware channel (release → release, snapshot → snapshot).
- Checking it will preserve several specific config files on the upgrade, but not the whole overlay partition.
- If you flash your device regularly, preferably consider unchecking “Keep Settings” every time you flash the router and instead create a [custom script](/docs/guide-developer/uci-defaults "docs:guide-developer:uci-defaults") for your customization.
- Cautiousness is mostly needed with major version upgrades, e.g. from 18.06 to 19.07, or from 19.07 to 21.02, etc.
- It is possible that settings change critically inside a release branch, but that is rare.
- Settings can change more often inside the master branch which reflects the bleeding edge development. But even with master branch snapshots, the settings change only rarely.

See also: [Backup and restore](/docs/guide-user/troubleshooting/backup_restore "docs:guide-user:troubleshooting:backup_restore")

## Upgrade compatibility

***The following section only applies if image metadata is used for the upgrade process.***

We regularly encounter the situation that devices are subject to changes that will make them incompatible to previous versions. This typically happens when the setup of a device has changed in a way so that the configuration cannot be migrated or filesystem changes won't allow sysupgrade.

Since August 2020 (20.xx release), an additional mechanism makes sure that users are warned when upgrading between incompatible versions like that.

The is achieved by a compatibility version number that is stored on the device and the images. The compat-version is built from a major revision x and a minor revision y: **x.y**

For all devices and image before the introduction, the default value “1.0” is assumed. The value is assigned for individual devices, so it does not tell anything about the general revision of OpenWrt.

If an incompatible change is introduced, one can increase either the minor version (1.0→1.1) or the major version (1.0→2.0).

**Minor version increment:**

This will still allow sysupgrade, but require to reset config (uncheck “Keep Settings”, run `sysupgrade -n` or `SAVE_CONFIG=0`). If sysupgrade is called without, a corresponding message will be printed. If sysupgrade is called and settings are reset, it will just pass, with supported devices being checked as usual.

**Major version increment:**

This is meant for potential (rare) cases where sysupgrade is not possible at all, because it would “break” the device. In this case, a warning will be printed, and resetting config (`sysupgrade -n`) won't help. You will need to research instructions on how to proceed.

Typically, in addition to the increment of the compatibility version, developers will also specify a message to be printed with the warnings above giving a first hint about the problem.

### Forcing upgrade

In any case, upgrade can still be forced (`sysupgrade -F`) as usual, but then you will obviously run into the very problem the mechanism tries to save you from.

If you do that, please note that the compatibility version on the device is a property of the config, i.e. the value is stored in uci: `system.@system[0].compat_version`

Consequently, as a forced update won't reset your config, it also won't bump your compat-version, and you will have to do that manually afterwards, e.g.

```
uci set system.@system[0].compat_version="1.1"
uci commit system
```

### Backward compatibility

As stated above, all devices and images without compat-version set will be treated as “1.0”.

However, the new compat-version-aware upgrade mechanism will only be available on devices flashed after that point.

For older devices, the metadata in new images has been altered to provide a similar experience for incremented compat-version.

On those devices, when upgrading into an “incompatible” image, incompatibility warnings and hint message will be printed. However, upgrade has to be forced in all cases (`sysupgrade -F -n`). Be sure to also reset config in addition to the “force” parameter, otherwise you will end up as described in “Forcing upgrade” section above. The only exception applies to early DSA-adopters, which can keep their config. Details are found in “Forcing upgrade” section above.

### Implementation details

***This section is focussed on developers wanting to implement compat-version after introducing an incompatible change.***

Setup consists of two parts:

#### Image metadata

To set the version of an image, which is checked against the locally installed OpenWrt config version, the variables DEVICE\_COMPAT\_VERSION and DEVICE\_COMPAT\_MESSAGE may be added to a device definition:

```
define Device/somedevice
  ...
  DEVICE_COMPAT_VERSION := 1.1
  DEVICE_COMPAT_MESSAGE := Config cannot be migrated from swconfig to DSA
endef
```

The DEVICE\_COMPAT\_VERSION is mandatory for any value other than “1.0”. The DEVICE\_COMPAT\_MESSAGE is optional and should be used to provide a hint about the problem and/or possibly measures for the user.

#### Device config

Beyond the image metadata, the compat-version also needs to be available on the running device, so it can be compared against any images.

Like for the LED/network setup, this will be achieved by a command “ucidef\_set\_compat\_version” to set the compat\_version in board.d files, e.g.

```
    ucidef_set_compat_version "1.1"
```

During *firstboot*, this will then add a string to /etc/board.json, which will be translated into uci system config.

By this, the compat\_version, being a version of the config, will also be exposed to the user.

Therefore, the on-device compat-version is a property of the config, not of the installation. Consequently, it will be affected by Backup/Restore, but can also be adjusted by the user if necessary.
