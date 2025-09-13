# SSH FileSystem

Both solutions [samba](/docs/guide-user/services/nas/samba "docs:guide-user:services:nas:samba") and [nfs.server](/docs/guide-user/services/nas/nfs.server "docs:guide-user:services:nas:nfs.server") do not offer security though encryption and are thus only suited for use in a closed intranet. If you need to remotely access files over the internet it is better to use an encrypted solution. The two common ways to do that are to use sshfs or to use samba or nfs over a VPN. In this recipe you will be shown how to set up and configure sshfs. sshfs is based on SFTP so you need to install sftp support on the server.

## Needed Packages

- openssh-sftp-server (for server)
- sshfs (for client)

## Configuration

By default OpenWrt uses Dropbear for its ssh client/server, and it is this that sshfs will use for its actual ssh connection backbone. On the client side you need to create an ssh key:

```
dropbearkey -t ed25519 -f ~/.ssh/id_dropbear
```

This will save the private key to where dropbear's ssh client can find it. It will also print out a line with the public key. It's a good idea to save the printed public key line in a file on the client - the typical place is in ~/.ssh/id\_dropbear.pub. This public key line also needs to be copied to the server and placed in the file /etc/dropbear/authorized\_keys

There is nothing more to be done on the server. Now you can mount your sshfs on the client by executing:

```
sshfs [user@]host:[dir] mountpoint
```

If you did not install the package to the standard destination (e.g. using opkg -d ram), you need to specify the sftp executable in your sshfs command:

```
sshfs [user@]host:[dir] mountpoint -o sftp_server=/tmp/usr/libexec/sftp-server
```

The more convenient way would be to link the binary to the default destination, so execute on your OpenWrt:

```
mkdir -p /usr/libexec
ln -s /tmp/usr/libexec/sftp-server /usr/libexec/sftp-server
```

## Links

- [http://en.wikipedia.org/wiki/Secure\_Shell\_Filesystem](http://en.wikipedia.org/wiki/Secure_Shell_Filesystem "http://en.wikipedia.org/wiki/Secure_Shell_Filesystem")
- [http://fuse.sourceforge.net/sshfs.html](http://fuse.sourceforge.net/sshfs.html "http://fuse.sourceforge.net/sshfs.html")
