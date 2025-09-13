# OpenSSH Multi Factor Authentication

The following tutorial will set up two-factor authentication for OpenSSH on my OpenWrt x86 router (v19.07.06). It comes from a [post in the OpenWrt forums](https://forum.openwrt.org/t/howto-openssh-with-mfa-on-openwrt-19-07-x-using-google-authenticator/88025 "https://forum.openwrt.org/t/howto-openssh-with-mfa-on-openwrt-19-07-x-using-google-authenticator/88025")

## Start

In this tutorial the router IP is the default 192.168.1.1.

Configure OpenWrt's built-in Dropbear SSH to work on LAN only and away from port 22 (e.g., 20022). This can be done in Luci at [http://192.168.1.1/cgi-bin/luci/admin/system/admin/dropbear](http://192.168.1.1/cgi-bin/luci/admin/system/admin/dropbear "http://192.168.1.1/cgi-bin/luci/admin/system/admin/dropbear"). If anything goes wrong with OpenSSH, you still should be able to log in from your local network using Dropbear: [![Luci Dropbear](/_media/docs/guide-user/services/ssh/openssh_mfa_auth_1_luci_dropbear.jpeg?w=700&tok=14dd67 "Luci Dropbear")](/_media/docs/guide-user/services/ssh/openssh_mfa_auth_1_luci_dropbear.jpeg "docs:guide-user:services:ssh:openssh_mfa_auth_1_luci_dropbear.jpeg")

Log into the router using Dropbear and install the openssh-server-pam and google-authenticator-libpam packages:

```
ssh -p 20022 root@192.168.1.1
opkg update
opkg install google-authenticator-libpam openssh-server-pam
```

Set up OpenSSH public/private key authentication. This is no different from a typical non-MFA scenario, I've just followed [this excellent guide](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-2 "https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-2").

Restart the OpenSSH service (service sshd restart from the stil-open Dropbear session of step 2) and test that you can connect to OpenSSH as root on port 22, from some other host:

```
ssh root@192.168.1.1
```

Run google-authenticator (in the open Dropbear session) and enroll in MFA. Follow [this guide](https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-ubuntu-16-04 "https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-ubuntu-16-04") precisely, starting from “**Run the initialization app**” and stopping at “**Step 2 — Configuring OpenSSH**”.  
You can use Google Authenticator, Microsoft Authenticator or any other MFA app that implements the standard Time-based One-time Password Algorithm [(TOTP - RFC 6238)](https://tools.ietf.org/html/rfc6238 "https://tools.ietf.org/html/rfc6238").

Edit /etc/ssh/sshd\_config (with nano /etc/ssh/sshd\_config) to make these scattered changes:

```
PermitRootLogin yes
PubkeyAuthentication yes
ChallengeResponseAuthentication yes
UsePAM yes
AuthenticationMethods publickey,keyboard-interactive
```

Here is a working version of /etc/ssh/sshd\_config:

```
    #       $OpenBSD: sshd_config,v 1.103 2018/04/09 20:41:22 tj Exp $

    # This is the sshd server system-wide configuration file.  See
    # sshd_config(5) for more information.

    # This sshd was compiled with PATH=/usr/bin:/bin:/usr/sbin:/sbin

    # The strategy used for options in the default sshd_config shipped with
    # OpenSSH is to specify options with their default value where
    # possible, but leave them commented.  Uncommented options override the
    # default value.

    Port 22
    #AddressFamily any
    #ListenAddress 0.0.0.0
    #ListenAddress ::

    HostKey /etc/ssh/ssh_host_rsa_key
    HostKey /etc/ssh/ssh_host_ecdsa_key
    HostKey /etc/ssh/ssh_host_ed25519_key

    # Ciphers and keying
    #RekeyLimit default none

    # Logging
    #SyslogFacility AUTH
    #LogLevel INFO

    # Authentication:

    #LoginGraceTime 2m
    PermitRootLogin yes
    #StrictModes yes
    #MaxAuthTries 6
    #MaxSessions 10

    PubkeyAuthentication yes

    # The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
    # but this is overridden so installations will only check .ssh/authorized_keys
    AuthorizedKeysFile      .ssh/authorized_keys

    #AuthorizedPrincipalsFile none

    #AuthorizedKeysCommand none
    #AuthorizedKeysCommandUser nobody

    # For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
    #HostbasedAuthentication no
    # Change to yes if you don't trust ~/.ssh/known_hosts for
    # HostbasedAuthentication
    #IgnoreUserKnownHosts no
    # Don't read the user's ~/.rhosts and ~/.shosts files
    #IgnoreRhosts yes

    # To disable tunneled clear text passwords, change to no here!
    #PasswordAuthentication yes
    #PermitEmptyPasswords no

    # Change to no to disable s/key passwords
    ChallengeResponseAuthentication yes

    # Kerberos options
    #KerberosAuthentication no
    #KerberosOrLocalPasswd yes
    #KerberosTicketCleanup yes
    #KerberosGetAFSToken no

    # GSSAPI options
    #GSSAPIAuthentication no
    #GSSAPICleanupCredentials yes

    # Set this to 'yes' to enable PAM authentication, account processing,
    # and session processing. If this is enabled, PAM authentication will
    # be allowed through the ChallengeResponseAuthentication and
    # PasswordAuthentication.  Depending on your PAM configuration,
    # PAM authentication via ChallengeResponseAuthentication may bypass
    # the setting of "PermitRootLogin without-password".
    # If you just want the PAM account and session checks to run without
    # PAM authentication, then enable this but set PasswordAuthentication
    # and ChallengeResponseAuthentication to 'no'.
    UsePAM yes

    AuthenticationMethods publickey,keyboard-interactive

    #AllowAgentForwarding yes
    #AllowTcpForwarding yes
    #GatewayPorts no
    #X11Forwarding no
    #X11DisplayOffset 10
    #X11UseLocalhost yes
    #PermitTTY yes
    #PrintMotd yes
    #PrintLastLog yes
    #TCPKeepAlive yes
    #PermitUserEnvironment no
    #Compression delayed
    #ClientAliveInterval 0
    #ClientAliveCountMax 3
    #UseDNS no
    #PidFile /var/run/sshd.pid
    #MaxStartups 10:30:100
    #PermitTunnel no
    #ChrootDirectory none
    #VersionAddendum none

    # no default banner path
    #Banner none

    # override default of no subsystems
    Subsystem       sftp    /usr/lib/sftp-server

    # Example of overriding settings on a per-user basis
    #Match User anoncvs
    #       X11Forwarding no
    #       AllowTcpForwarding no
    #       PermitTTY no
    #       ForceCommand cvs server
```

Edit **/etc/pam.d/sshd** (with **nano /etc/pam.d/sshd**) to make these changes:  
**#auth include common-auth** (must be commented out)  
**auth required /usr/lib/security/pam\_google\_authenticator.so** (append at the very end of the file)

**NOTE:** The above two lines are very important and a difference from all the guides I've linked above. They were suggested using “auth required pam\_google\_authenticator.so”. However, at least in OpenWrt 19.07, pam.d tries to load this plugin from /lib/security and that fails, because the current google-authenticator-libpam package installs pam\_google\_authenticator.so into /usr/lib/security.

Here is a working version of /etc/pam.d/sshd:

```
    # PAM configuration for the Secure Shell service

    # Read environment variables from /etc/environment and
    # /etc/security/pam_env.conf.
    auth       required     pam_env.so

    # Skip Google Authenticator if logging in from the local network.
    # auth [success=1 default=ignore] pam_access.so accessfile=/etc/security/access-sshd-local.conf
    # Google Authenticator 2-step verification.
    #auth       requisite    pam_google_authenticator.so

    # Standard Un*x authentication.
    #auth       include      common-auth

    # Disallow non-root logins when /etc/nologin exists.
    account    required     pam_nologin.so

    # Uncomment and edit /etc/security/access.conf if you need to set complex
    # access limits that are hard to express in sshd_config.
    # account    required     pam_access.so

    # Standard Un*x authorization.
    account    include      common-account

    # Standard Un*x session setup and teardown.
    session    include      common-session

    # Print the message of the day upon successful login.
    session    optional     pam_motd.so

    # Print the status of the user's mailbox upon successful login.
    session    optional     pam_mail.so standard noenv

    # Set up user limits from /etc/security/limits.conf.
    session    required     pam_limits.so

    # Set up SELinux capabilities (need modified pam)
    # session    required     pam_selinux.so multiple

    # Standard Un*x password updating.
    password   include      common-password

    auth       required     /usr/lib/security/pam_google_authenticator.so
```

Restart sshd (**service sshd restart**) and try to connect to it from another machine. You should be prompted for a one-time MFA password.

Configure your Firewall trafic rules ([http://192.168.1.1/cgi-bin/luci/admin/network/firewall/rules](http://192.168.1.1/cgi-bin/luci/admin/network/firewall/rules "http://192.168.1.1/cgi-bin/luci/admin/network/firewall/rules")) if you want to be able to connect to OpenSSH from the Internet.

Congrats, you've hardened your OpenWrt OpenSSH root access with two-factor authentication.

**NOTE:** The OTP codes are time-based. My x86 router has an RTC clock, so the MFA should work even if the router is offline. OpenWrt automatically syncs time using NTP, so as long as the router is online, the MFA still should work. Otherwise, if the router is offline and there's no RTC, you should still have an option to connect from the LAN using Dropbear on port 20022.

### Some helpful resources

- [Installing Google Authenticator for SSH, OpenConnect, OpenVPN? 6](https://forum.openwrt.org/t/installing-google-authenticator-for-ssh-openconnect-openvpn/31439 "https://forum.openwrt.org/t/installing-google-authenticator-for-ssh-openconnect-openvpn/31439")
- [https://forum.archive.openwrt.org/viewtopic.php?id=38905](https://forum.archive.openwrt.org/viewtopic.php?id=38905 "https://forum.archive.openwrt.org/viewtopic.php?id=38905")
- [https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-ubuntu-16-04](https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-ubuntu-16-04 "https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-ubuntu-16-04") 2
- [https://www.vultr.com/docs/how-to-use-twofactor-authentication-with-ubuntu-20-04](https://www.vultr.com/docs/how-to-use-twofactor-authentication-with-ubuntu-20-04 "https://www.vultr.com/docs/how-to-use-twofactor-authentication-with-ubuntu-20-04") 1
