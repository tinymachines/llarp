# TLS/SSL certificates for a server

[Transport\_Layer\_Security](https://en.wikipedia.org/wiki/Transport_Layer_Security "https://en.wikipedia.org/wiki/Transport_Layer_Security") (TLS, formerly called SSL) is used to encrypt and protect communication. When a webserver works with regular HTTP protocol i.e. its address starts with `http` but over the encrypted TLS this called HTTPS and a site address starts with `https`. For all HTTPS sites a web browser shows a lock icon in an address bar. For enabling HTTPS for a website's domain we need a private key and it's TSL certificate that was signed by a Certificate Authority (CA).

The OpenWrt admin site LuCI by default supports the HTTPS so you can open it with [httpS://192.168.1.1/](https://192.168.1.1/ "https://192.168.1.1/"). But it's certificate is self signed and not verified by a CA so your browser will show a warning.

You can buy a TLS cert but nowadays the [Let's Encrypt](https://letsencrypt.org/how-it-works/ "https://letsencrypt.org/how-it-works/") CA allows to sign and verify certificates for free with a **certbot** program that uses ACME protocol. The only problem is that the certificate will have a short period of validity and you have to configure certificate renewal.

There is few ACME clients that automates the cert issuing:

- [certbot](https://certbot.eff.org/ "https://certbot.eff.org/") is an official ACME client that is feature rich but is too heavy for small OpenWrt routers.
- [acme.sh](https://github.com/acmesh-official/acme.sh "https://github.com/acmesh-official/acme.sh") is small ACME client that uses shell script and has a LUCI app to configure. This is a recommended for OpenWrt.
- [uacme](https://github.com/ndilieto/uacme "https://github.com/ndilieto/uacme") lightweight ACME client written in plain C with minimal dependencies: libcurl and one of MbedTLS, OpenSSL or GnuTLS.
- Many others [ACME Client Implementations](https://letsencrypt.org/docs/client-options/ "https://letsencrypt.org/docs/client-options/")

If you have already taken care of certificate automation see also [Installing a publicly trusted certificate](/docs/guide-user/luci/getting_rid_of_luci_https_certificate_warnings#option_ainstalling_a_publicly_trusted_certificate "docs:guide-user:luci:getting_rid_of_luci_https_certificate_warnings").

## ACME.sh

See [acme.sh](/docs/guide-user/services/tls/acmesh "docs:guide-user:services:tls:acmesh")

## Self signed certs

See [HTTPS Enable and Certificate Settings and Creation](/docs/guide-user/services/webserver/uhttpd#https_enable_and_certificate_settings_and_creation "docs:guide-user:services:webserver:uhttpd") or [Getting rid of LuCI HTTPS warnings](/docs/guide-user/luci/getting_rid_of_luci_https_certificate_warnings#option_bcreating_installing_trusting_a_self-signed_certificate "docs:guide-user:luci:getting_rid_of_luci_https_certificate_warnings").

## Own Certificate Authority with PKI

See [Installing and trusting a root CA certificate in a PKI](/docs/guide-user/services/tls/pki "docs:guide-user:services:tls:pki")

## External services

You can use CloudFlare.com as a proxy that will terminate TLS and forward requests to your router with HTTP or HTTPS with a self signed certificate. Some tunnels like PageKite or localhost.run are working through HTTPS.
