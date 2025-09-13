# PPPoSSH

[PPPoSSH](/packages/pkgdata/pppossh "packages:pkgdata:pppossh") provides an L3 tunnel over SSH and specifically [Dropbear](/docs/guide-user/base-system/dropbear "docs:guide-user:base-system:dropbear"). It is easy to configure and takes little extra space to set up. Although it can be quite handy for personal use, but generally not considered for production due to the drawbacks of [TCP-over-TCP](https://en.wikipedia.org/wiki/Tunneling_protocol#Secure_Shell_tunneling "https://en.wikipedia.org/wiki/Tunneling_protocol#Secure_Shell_tunneling").

## Key management

PPPoSSH generally relies on [public-key cryptography](https://en.wikipedia.org/wiki/Public-key_cryptography "https://en.wikipedia.org/wiki/Public-key_cryptography"). It requires to generate a private and public key for each peer and exchange only the public keys. While the private key is best never disclosed outside the peer where it was generated.

## Alternatives

- [sshtunnel](/docs/guide-user/services/ssh/sshtunnel "docs:guide-user:services:ssh:sshtunnel") - allows to create TUN/TAP tunnels and forward specific ports.
- [sshuttle](https://gist.github.com/kylekyle/fcbb7b93ad9816915b31022a17f19cea "https://gist.github.com/kylekyle/fcbb7b93ad9816915b31022a17f19cea") - Python based solution for SSH tunneling.

## All articles

[Continue with the « docs » section at the top...](#top-1628095278 "Continue with the « docs » section at the top...")

# [Continue with the « docs » section at the top...](#top-1628095278 "Continue with the « docs » section at the top...")[Documentation](/docs/start "docs:start")

[Continue with the « docs » section at the top...](#top-1628095278 "Continue with the « docs » section at the top...")

## [Continue with the « docs » section at the top...](#top-1628095278 "Continue with the « docs » section at the top...")[User guide](/docs/guide-user/start "docs:guide-user:start")

[Continue with the « docs » section at the top...](#top-1628095278 "Continue with the « docs » section at the top...")

### [Continue with the « docs » section at the top...](#top-1628095278 "Continue with the « docs » section at the top...")[Additional services](/docs/guide-user/services/start "docs:guide-user:services:start")

[Continue with the « docs » section at the top...](#top-1628095278 "Continue with the « docs » section at the top...")

#### [Continue with the « docs » section at the top...](#top-1628095278 "Continue with the « docs » section at the top...")[VPN (Virtual Private Network)](/docs/guide-user/services/vpn/start "docs:guide-user:services:vpn:start")

[Continue with the « docs » section at the top...](#top-1628095278 "Continue with the « docs » section at the top...")

##### [Continue with the « docs » section at the top...](#top-1628095278 "Continue with the « docs » section at the top...")[PPPoSSH](/docs/guide-user/services/vpn/pppossh/start "docs:guide-user:services:vpn:pppossh:start")

- [PPPoSSH client](/docs/guide-user/services/vpn/pppossh/client "docs:guide-user:services:vpn:pppossh:client")
- [PPPoSSH extras](/docs/guide-user/services/vpn/pppossh/extras "docs:guide-user:services:vpn:pppossh:extras")[Continue with the «  » section at the top...](#top-1628095278 "Continue with the «  » section at the top...")

###### ...

- [PPPoSSH server](/docs/guide-user/services/vpn/pppossh/server "docs:guide-user:services:vpn:pppossh:server")
