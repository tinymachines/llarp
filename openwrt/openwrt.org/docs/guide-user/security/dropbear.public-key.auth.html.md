# Dropbear key-based authentication

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up [key-based authentication](https://en.wikipedia.org/wiki/Key%20authentication "https://en.wikipedia.org/wiki/Key authentication") for [Dropbear](/docs/guide-user/base-system/dropbear "docs:guide-user:base-system:dropbear").
- Follow [SSH access for newcomers](/docs/guide-quick-start/sshadministration#putty "docs:guide-quick-start:sshadministration") to set up key-based authentication for PuTTY.

## Goals

- Enable key-based authentication for Dropbear for convenience
- Improve security by disabling password authentication

## Generating public and private keys using SSH-Keygen on a host machine

Skip this if you already have a public / private key pair on your client machine that you intend to use to connect to the OpenWrt SSH server.

The [ssh-keygen](http://man.cx/ssh-keygen%281%29 "http://man.cx/ssh-keygen%281%29") utility can be used to generate a key pair to use for authentication. After you have used this utility, you will have two files, by default *~/.ssh/id\_&lt;keytype&gt;* (the private key) and *~/.ssh/id\_&lt;keytype&gt;.pub* (the public key). **Always keep your private key (e.g. *~/.ssh/id\_&lt;keytype&gt;*) secret and secure.**

```
# Generate a new key pair, 3072-bit RSA by default
ssh-keygen
```

```
# Generate a new Ed25519 key pair
ssh-keygen -t ed25519
```

Keep your software up-to-date to safely rely on the cryptography-related defaults.

## Generating public and private keys on the OpenWrt machine

You might want to generate a key for your device so that logins from your router can be authenticated when you connect to other machines from your router.

Dropbearkey can generate a key directly on your device, it should be placed in the `~/.ssh` directory of your user so you might need to create this directory first on a new install:

```
mkdir ~/.ssh
dropbearkey -t ed25519 -f ~/.ssh/id_dropbear
```

And you can inspect the corresponding public key for your OpenWrt device like this:

```
dropbearkey -y -f ~/.ssh/id_dropbear
```

By default Dropbear reads `~/.ssh/id_dropbear` so putting the private key there avoids the need to create an SSH configuration file.

## From the LuCI Web Interface

Once your terminal program on your laptop/desktop has a public key, you can forgo entering a password each time you SSH to your device. (This is secure: only your terminal program with the appropriate private key can log in without a password.) First, generate the public and private keys (see above). Then add your PUBLIC key (it's often called *id\_rsa.pub* - **it MUST have “.pub”** in the filename) to the device.

To do this from LuCI:

1. Navigate to **LuCI → System → Administration → SSH-Keys**
2. Copy the contents of your public key file. It will be a long string starting with `ssh-rsa ...` and ending with something like `... some-name@some-host.lan`
3. Paste that string into *Paste or drag key file...* field on the web page
4. Click the **Add key** button
5. To test: open a new window in your terminal program and enter `ssh root@your-router-address` You should be logged in without entering your password.

## From the Command-line

Read your public key (it's usually in **~/.ssh/id\_rsa.pub** on a linux system) and add it to **/etc/dropbear/authorized\_keys**.

Example:

```
ssh root@192.168.1.1 "tee -a /etc/dropbear/authorized_keys" < ~/.ssh/id_rsa.pub
```

### Using ssh-copy-id

Add your public key to the router using [ssh-copy-id](http://man.cx/ssh-copy-id%281%29 "http://man.cx/ssh-copy-id%281%29").

```
ssh-copy-id root@openwrt.lan
```

[Generate](/docs/guide-user/security/dropbear.public-key.auth#generating_public_and_private_keys "docs:guide-user:security:dropbear.public-key.auth") a new authentication key if necessary.

## Testing

Use [ssh](http://man.cx/ssh%281%29 "http://man.cx/ssh%281%29") to log in your router using command-line interface, temporarily disabling password authentication to verify that you can login and that it does not ask you for a password:

```
ssh -o PasswordAuthentication=no root@openwrt.lan
```

Until you have sucessfully completed this test, it is unwise to disable password authentication on the OpenWrt SSH server as you may lock yourself out.

## Troubleshooting

Collect and analyze the following information.

```
# Restart services
service log restart; service dropbear restart
 
# Log and status
logread -e dropbear; netstat -l -n -p | grep -e dropbear
 
# Runtime configuration
pgrep -f -a dropbear
 
# Persistent configuration
uci show dropbear; ls -l /etc/dropbear; cat /etc/dropbear/authorized_keys
```

Additionally, run your ssh client with maximum verbosity (`ssh -vvv`) and check the output. If you see something like

```
send_pubkey_test: no mutual signature algorithm
```

you might want to try to run the ssh client with the `-o PubkeyAcceptedKeyTypes=ssh-rsa` option. You can save this setting in your `.ssh/config` file in an entry dedicated to your router.

## Extras

### Showing the device's public key

This is useful if you want to connect with ssh from this device to another device, using public key auth.

```
dropbearkey -y -f /etc/dropbear/dropbear_rsa_host_key
```

And an example answer is

```
Public key portion is:
ssh-rsa AAAAB3NzaC1yc2EAdrgdftergdsfgdfgdfgdfgdfgdfgdfgJOYPF6nc41DUWDQdRrv8Ihe/zINq5CaFOsysL3LNOg90C9uDYRIp89nq9ydUIrwvjz9r8U/7HFOkLX6YQUevUZHxEyUexhWRSBLbnoQSKLHlB5WhodghdfgdfgdfgdfgdfgdfgfdgdfgfdgdfasdaaedadfasEUxiDTj74l0dqLpCCM1r9BcQd12hvQwfHvbMAcY/7l3Wb5fdAvXI5mMIXXzWPkLhSLHP1Hw1trEmuUeL2rie+WzSjaOGMzVDjOpEaZD0dT7Ib9yDwem8UDMPFuXnNmsUvpxNHakWbw+465uxlyeAzL root@VM-router
Fingerprint: sha1!! ec:66:c1:57:92:c1:ec:66:c1:57:92:c1:c7:9e:71:50:25:65:61:53:dd
```

You will copy-paste the “public key portion” to the other device's accepted keys

### Non-root users

Add authentication keys for the current non-root user.

```
ssh openwrt.lan "mkdir -p ~/.ssh; tee -a ~/.ssh/authorized_keys" < ~/.ssh/id_ed25519.pub
```

### Disabling password authentication

Harden security by disabling password authentication.

```
uci set dropbear.@dropbear[0].PasswordAuth="0"
uci set dropbear.@dropbear[0].RootPasswordAuth="0"
uci commit dropbear
service dropbear restart
```

### Fixing permissions

Set up the proper permissions.

```
chmod -R u=rwX,go= /etc/dropbear
```
