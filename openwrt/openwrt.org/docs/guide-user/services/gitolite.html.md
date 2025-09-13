# Gitolite user-restricted git hosting

Gitolite is a user-restricted git hosting system after ssh authorized a user.

### A typical usage scenario / Why gitolite?

You and a colleague would like to develop something together, so you'd usually like to have some kind of version control system (VCS). The things you're developing should be no open source software, so you can't use platforms like Github. You'll want to have some 24/7 server in order to let both of you pull and push source whenever you want though. So setting up a VCS on your OpenWrt router which is running 24/7 anyways would make sense.

Because your project isn't open source nobody else should be able to see it. So you need a way to encrypt data before it is sent to your OpenWrt box. One idea would be to install an apache server including the svn module, but you'll run into two problems:

- The SVN module usually isn't compiled in the OpenWrt packages to save space.
- You'll need to encrypt the data using SSL.

Setting up this solution isn't trivial.

This is the point where you'll like to set up a git repository using tools already packaged by the OpenWrt developers. Git usually offers two mechanisms for authentication and encryption:

- SSH
- HTTPS-Basic

Getting a valid HTTPS certificate which won't make clients complain every time usually costs money, so you'd like to use SSH. If you know your colleague very well you two could just use the root account on the OpenWrt box. You could log into that SSH-Account using git and would be done.

If you don't trust your colleague that much you'd most likely just want them to be able to access the repositories R/W and nothing further should be possible. On many other UNIX boxes you could just create them another system account and point the login shell to the so called 'git-shell'. If you set up your system this way, they would reach a shell which only allows them to issue git-commands after they have authenticated themself.

This would be the simpliest way to do authentification, but be carefull. Creating a new account for your colleage could also open doors on other services than ssh. In a worst case scenario a service configured to let any authenticated user connect by default could make the git-shell restrictions useless. Another problem you'll get is that multi-user setups are usually [omitted on OpenWrt](https://forum.openwrt.org/viewtopic.php?id=4409 "https://forum.openwrt.org/viewtopic.php?id=4409"). You just don't know if the guy who packaged for example your ftp service ever thought about the fact that there could be more users than root on an OpenWrt box. This is probably the point where you'll want to set up gitolite.

Gitolite acts after your ssh-authentification mechanism and will differ and authorize users by their SSH-public keys. It will in turn log them into different shells (Normal ash or gitolite) using ony one system account.

A typical git clone on your local box would look like that:

```
git clone git@OpenWrt:repository
```

### Prerequisites

openssh-server

## Installation and Setup for 18.06.0 and later

### Size/Storage

You need enough space to install gitolite (only requires cli). A larger than 8MB flash is required for a pure CLI install of just gitolite plus storage drivers for whatever external storage you choose (assuming your flash is not multi-GB). Alternatively install using [extroot](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration").

OpenWrt's gitolite package expects that `/srv/git` is where your repos will be hosted (and will be a UNIX home directory of the `git` user). Mount your repo storage on `/srv/git` or make a symlink to a location on your storage which is mounted elsewhere.

### Access

Once you've booted into your device, set dropbear to run from a port other than port 22 (alternatively in the steps below configure openssh to run on a port other than 22 and continue to use port 22 / dropbear for device admin access).

e.g.

```
config dropbear
        option Port '22222'
        ... (other option you had before)
```

Then restart dropbear (future logins will need to be done using an SSH syntax such as `ssh -p 2222 root@192.168.1.1`).

### Copy the gitolite admin user's SSH key to your device

Assuming you changed dropbear as above, from computer from which you are using SSH into the deivice, do:

`scp -P 2222 /path/to/admin/id_rsa.pub root@192.168.1.1:admin.pub`

### The actual install

01. `opkg update && opkg install gitolite`
02. `mkdir -p /srv/git/.ssh`
03. `chmod 700 /srv/git/.ssh`
04. `cp /etc/dropbear/authorized_keys /srv/git/.ssh/authorized_keys`
05. `chmod 600 /srv/git/.ssh/authorized_keys`
06. `cp /root/admin.pub /srv/git`
07. `chown -R git:git /srv/git`
08. From the host from which you are accessing the gitolite device: `ssh git@192.168.1.1 “gitolite setup -pk admin.pub”`
09. **IFF your admin.pub is the same as a key in /etc/dropbear/authorized\_keys**:
    
    1. `ssh git@192.168.1.1.`
    2. `vi /srv/git/.ssh/authorized_keys`
    3. Use the 'j' and 'k' keys to navigate to the offending line.
    4. Press `dd`, then press the Esc or Escape key followed by `:wq`.
    5. `exit`.
10. Now if you `ssh git@192.168.1.1` you should get a list of repos readable (and/or writable) by the admin user.

## Installation and Setup before 18.06.0

This tutorial will show you how to setup the OpenWrt default SSH deamon dropbear to work together with gitolite.

### Dependencies

You'll most likely want to run your OpenWrt box from a USB memory key using [extroot](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration"). Just installing the dependencies could make small devices run out of space and you haven't even stored any repository data yet.

Gitolite was written in perl. This commands should install all required packages to run the application:

```
opkg update
opkg install git perl perlbase-essential perlbase-getopt perlbase-findbin perlbase-cwd perlbase-config perlbase-file perlbase-data perlbase-bytes perlbase-xsloader openssh-keygen perlbase-hostname perlbase-fcntl perlbase-io perlbase-symbol perlbase-selectsaver perlbase-errno perlbase-base
```

### Backing up the old dropbear configuration

Make sure your /etc/config/dropbear loos like this one, so normal password-based login will work as backup if something goes wrong:

```
config dropbear
        option Port '22'
        option PasswordAuth 'on'
```

Backup your authorized\_keys file if it is existing:

```
cp -p /etc/dropbear/authorized_keys /etc/dropbear/authorized_keys_backup
```

### Downloading and installing gitolite

Download gitolite to your homedirectory:

```
cd /root
git clone git://github.com/sitaramc/gitolite
```

Install a link to gitolite executable into /usr/bin... The gitolite developers provide a simple way for doing that in their documentation:

```
cd /root/
gitolite/install -ln /usr/bin
```

Create the gitolite logfile directory:

```
mkdir /root/.gitolite
mkdir /root/.gitolite/logs
```

Copy your ssh public key from your machine to your OpenWrt box. From your local machine issue:

```
scp ~/.ssh/id_rsa.pub root@openwrthostname:/root/
```

Back again on your openwrt box, rename the file from id\_rsa.pub to username.pub with username as the name of your useraccount on your local machine which generated the public key. This is important because gitolite will set up the default configuration with this username. An example with didi1357 as the account on your local machine:

```
cd /root/
mv id_rsa.pub didi1357.pub
```

Setup gitolite:

```
gitolite setup -pk didi1357.pub
```

Now you can delete your public key file. Gitolite already kopied it to it's keydir:

```
rm didi1357.pub
```

Gitolite sets up and expects the authorized\_keys file for the root account in /root/.ssh/, but Dropbear and LuCI expect this file to be in in /etc/dropbear/

This issue can be solved by creating a symbolic link to /root/.ssh/authorized\_keys in /etc/dropbear/authorized\_keys

```
rm /etc/dropbear/authorized_keys
ln -s /root/.ssh/authorized_keys /etc/dropbear/authorized_keys
```

Now you can append the old keys from your authorized\_keys\_backup to the authorized\_keys file, but pay attention to not having a key listed twice in that file. If you're using linux and would still want to use public key authentication you could create a public key for your local machines root account and use your usual accounts public key for gitolite.

## Administrating gitolite

Administrating gitolite usually works by cloning the gitolite-admin repository to your local machine, making changes to it and pushing them back to the openwrt box. From your local machine issue:

```
git clone root@OpenWRTBox:gitolite-admin
```

The syntax of this repository can be looked up at: [http://gitolite.com/gitolite/basic-admin.html](http://gitolite.com/gitolite/basic-admin.html "http://gitolite.com/gitolite/basic-admin.html")
