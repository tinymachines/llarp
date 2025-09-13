# Replace Dropbear to OpenSSH + SFTP

The vanilla OpenWrt out of the box has a small [Dropbear](/docs/guide-user/base-system/dropbear "docs:guide-user:base-system:dropbear") SSH server. But it lacks of some other features. You can install another OpenSSH server which is bigger but has more features and default on desktop systems like Ubuntu.

Many [routers with OpenWrt as a stock firmware](/docs/guide-user/installation/openwrt-as-stock-firmware "docs:guide-user:installation:openwrt-as-stock-firmware") use it out of the box. So for this routers you really don't need anything to do and just start using it.

## Installation

To avoid port conflict we need to first move the existing Dropbear from default SSH port, then install OpenSSH, connect to it and only then remove the Dropbear.

Just to be safe if the public key authorization will be broken you'll need to use a password to connect. So ensure that the `root` user has a password by using the `passwd` command.

Set a Dropbear's port to some unused (e.g. 2222) and restart it

```
uci set dropbear.@dropbear[0].Port=2222
uci commit dropbear
/etc/init.d/dropbear restart
```

Reconnect to the SSH using the new port: `ssh root@192.168.1.1 -p 2222`

Install OpenSSH server

```
opkg update
opkg install openssh-server
```

Allow root access:

```
sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
```

On connection the Dropbear checks that your public key is allowed in a `/etc/dropbear/authorized_keys` file. But the OpenSSH checks `/root/.ssh/authorized_keys`. So it's recommended to copy the file:

```
mkdir /root/.ssh/
cp /etc/dropbear/authorized_keys /root/.ssh/
```

Enable the OpenSSH daemon and restart:

```
/etc/init.d/sshd enable
/etc/init.d/sshd restart
```

The OpenSSH now use the standard 22 port. Reconnect to SSH over the 22 port `ssh root@192.168.1.1`

During installation the OpenSSH will generate a new host keys so you'll get a warning that host key was changed.

Once connected now you can disable the Dropbear:

```
/etc/init.d/dropbear disable
/etc/init.d/dropbear stop
```

Recommended step: Install `openssh-sftp-server` package to support the [SFTP](/docs/guide-user/services/nas/sftp.server "docs:guide-user:services:nas:sftp.server") protocol

```
opkg update
opkg install openssh-sftp-server
```

If needed, configure the OpenSSH server in `/etc/ssh/sshd_config` and restart it `/etc/init.d/sshd restart`
