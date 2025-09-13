# Resetting the root password

If you have forgotten the root password or if the root password no longer works, you have to use the [Failsafe Mode and Factory Reset](/docs/guide-user/troubleshooting/failsafe_and_factory_reset "docs:guide-user:troubleshooting:failsafe_and_factory_reset").

From there, you don't have to reset the whole configuration. Note that fail safe mode does not require a password for authentication of root (!)

You only have to mount the root file system and set a new password with `passwd` and then trigger a restart. In fail safe mode, `passwd` will not ask for the old password (that you may have forgotten):

```
root@(none):~# mount_root
switching to jffs2 overlay
root@(none):/rom/root# passwd
Changing password for root
New password:
Retype password:
passwd: password for root changed by root
root@(none):/rom/root# reboot -f
```
