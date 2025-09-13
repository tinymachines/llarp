# User Configuration

**Outdated Information!**  
This article contains information that is outdated or no longer valid. You can edit this page to update it.

The *UCI configuration file*, which needs to be placed at `/etc/config/users` on your OpenWrt installation, serves as a central user database for different services. Therefore, unlike most Unix/Linux systems, with OpenWrt, you do not have to create additional users by editing `/etc/passwd`. For more information about OpenWrt configuration files, see [configuration\_files](/docs/guide-user/base-system/uci#configuration_files "docs:guide-user:base-system:uci").

## Sections

### user

NameTypeRequiredDefaultDescription enabledbooleanno0Active flag. User is available for authentication (=1) or not (=0) namestringyes(none)Name of the user passwordstringyes(none)Password of the user xauthbooleanno0User is available for IPsec [road warrior](/docs/guide-user/services/vpn/strongswan/roadwarrior "docs:guide-user:services:vpn:strongswan:roadwarrior") XAuth hybrid authentication if set to 1 crt\_subjectstringno(none)Subject of the user/machine certificate for [road warriors](/docs/guide-user/services/vpn/ipsec/start "docs:guide-user:services:vpn:ipsec:start")

## Examples

```
config 'user'
  option 'enabled' '1'
  option 'name' 'otto'
  option 'password' 'this_is_ottos_password'
  option 'xauth' '1'
  option 'crt_subject' 'CN=otto01@acme.com'
```

## Does OpenWrt support managing users with the traditional Unix/Linux commands such as useradd, passwd, sudo, and su?

The short answer is *YES*, but before proceeding, you should be aware of an important caveat.

### What is the caveat?

If you prefer to create new users and manage existing users by using the traditional Unix/Linux commands such as `useradd` and `passwd`, you will need to install additional packages that require precious amounts of storage space. For most embedded devices, if you have not installed and configured additional memory, these packages will be much too large for your stock device. However, if your hardware supports storage such as USB, at the time of this update, 64 GB USB drives can be purchased for less than $10 USD.

### How can I learn more about managing OpenWrt users with traditional Unix/Linux commands?

Follow the guide located at [create\_a\_non-privileged\_user\_in\_openwrt](/docs/guide-user/security/secure.access#create_a_non-privileged_user_in_openwrt "docs:guide-user:security:secure.access").

### Where can I learn more about installing a USB drive on my OpenWrt device and running the OS from that drive?

Visit [storage](/docs/guide-user/storage/start "docs:guide-user:storage:start").
