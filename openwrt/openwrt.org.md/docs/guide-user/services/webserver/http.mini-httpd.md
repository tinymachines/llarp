# mini-httpd webserver

## Installation

See →`opkg` on its usage.

First update, then install mini-httpd, openssl-util, and libopenssl.

```
opkg update
opkg install mini-httpd
opkg install mini-httpd-openssl
opkg install openssl-util
```

## Configuration

### Get mini-httpd-openssl working without SSL Certificate errors

Quick guide for Chaos Calmer and later (using self-signed certs):

1. The certificate's 'common-name' must match the host part of the URL which you use to access your router. OpenWRT defaults to 'OpenWRT', as the common name, so if you don't plan to use [https://OpenWRT/](https://OpenWRT/ "https://OpenWRT/"), then edit /etc/config/uhttpd so that the commonname reflects the host part of the URL you'll be using. You'll then need to rm (or backup) /etc/uhttpd.key and /etc/uhttpd.crt, and regenerate them with: /etc/init.d/uhttpd restart
2. Set your web browser to recognise the self-signed key without lots of scary warnings etc. This is very platform specific but the following guides may be useful (please add to this list):

<!--THE END-->

- Chrome / Linux [https://chromium.googlesource.com/chromium/src/+/master/docs/linux\_cert\_management.md](https://chromium.googlesource.com/chromium/src/+/master/docs/linux_cert_management.md "https://chromium.googlesource.com/chromium/src/+/master/docs/linux_cert_management.md")
- Chrome (and other browsers, since Chrome uses the OS's native cert management) on various desktop platforms [http://stackoverflow.com/questions/7580508/getting-chrome-to-accept-self-signed-localhost-certificate](http://stackoverflow.com/questions/7580508/getting-chrome-to-accept-self-signed-localhost-certificate "http://stackoverflow.com/questions/7580508/getting-chrome-to-accept-self-signed-localhost-certificate")

### Get mini-httpd-openssl working without SSL Certificate errors

As with Telnet, HTTP will transmit your usernames, passwords, and all data in clear text across the network. This means that anyone on the same subnet on either the client or the server networks could intercept the traffic and steal your credentials. Using packages from Backports, you can install an HTTPS-only Web server.

This guide will show you how to turn on SSL access to your OpenWrt running LuCI. Enabling https access to your router, and disabling http access, will provide greater security. This guide will also show you how to install your certificate in Windows 7, which will get rid of browser errors stating the certificate is not valid.

**`Note:`** My build at the time of this article trunk (r32793)

### Process Breakdown

1. Create keys and certs
2. Create mini\_httpd.pem
3. Install cert to Windows 7
4. Upload mini\_httpd.pem
5. Enable / Start mini\_httpd
6. Test
7. Disable http access

#### Backup your mini-httpd.pem

[![?400](/_media/doc/howto/winscp-ss1.png "?400")](/_detail/doc/howto/winscp-ss1.png?id=docs%3Aguide-user%3Aservices%3Awebserver%3Ahttp.mini-httpd "doc:howto:winscp-ss1.png")

Next, get into the router using WinSCP (don't forget to change the protocol) and navigate to /etc Make a backup of `mini_httpd.pem` and stick it in a secure place, just in case you need to revert back to this original key at some point. What I did was copy the file to my desktop and renamed it to `mini_httpd-ORG.pem`

#### A Simple Understanding of TLS and SSL

After much discussion with mancha in the #openssl IRC channel, he explained some basics about the underlying encrypted network connections that I feel are important for those of you who are doing this. Without knowing some of what this guide will teaching, changing it to suit your situation will be more difficult. Creating a certificate is for your router to say to a browser, “Hey this is me and you can trust it is me.” The webserver on the router and your browser will use transport protocol SSL or TLS to negotiate a cipher. Your browser client says “Here are the ciphers I understand”. The server will reply “Good, I understand this subset of ciphers, now pick this one.” This all goes on without our interaction. We just see a browser connecting via HTTPS. This process has nothing to do with the certificate we are creating. This is important to understand, as creating a strong certificate does *not* mean mini\_httpd and your browser will use the *maximum* available cipher. So you can generate a 4096-bit RSA certificate, only to have your browser and the server decide to use DES-CBC-SHA (Kx=RSA Au=RSA Enc=DES(56) Mac=SHA1) which is considered a Medium Strength Cipher (&gt;= 56-bit and &lt; 112-bit key). Fortunately, we can force mini-httpd to always use a stronger one. This is detailed below in the section *Forcing a strong SSL/TLS Cipher*.

#### Creating the 1024-bit key and certificate

Step 1: Using PuTTY to access the router over SSH, we then make our keys using openssl by issuing these commands:

```
openssl req -nodes -new > cert.csr
```

This requests the key and certificate creation. `-nodes` creates a key which will not be encrypted with a DES pass phrase. More info [here](http://www.madboa.com/geek/openssl/#cert-self "http://www.madboa.com/geek/openssl/#cert-self")

#### Optional: Create a 2048-bit key and certificate instead

If you prefer to have stronger than 1024-bit encryption, use this command *instead* to get 2048-bit encryption:

```
openssl req -nodes -newkey rsa:2048 -new > cert.csr
```

#### Fill in the certificate

Step 2: Next enter this stuff based on your own info:

`Country Name: US State/Province: CA Locality Name: Los Angeles Organization Name: You may hit enter to leave blank. Organization Unit Name: You may hit enter to leave blank. Common Name: 192.168.1.1 Email Address: You may hit enter to leave blank. A Challenge Password: You may hit enter to leave blank. Optional company name: You may hit enter to leave blank.`

Note that `Common Name:` is VERY important. Without this entered properly, it will always error out. Make this the IP of the router, and *do not* suffix it with the cgi-bin/luci.

#### Convert and sign the certificate

Step 3: Lastly, issue this command:

```
openssl x509 -in cert.csr -out cert.pem -req -signkey privkey.pem -days 365
```

x509 option converts the certificate (.csr) to .pem certificate. It then signs the privkey.pem and makes it valid for 1 year. For more info [see this page](http://en.wikipedia.org/wiki/X.509#Certificate_filename_extensions "http://en.wikipedia.org/wiki/X.509#Certificate_filename_extensions")

#### Grabbing the key and certificate

Use WinSCP to login and navigate to /root Copy these 2 files to your OS, as you will be manipulating them (I threw mine on my desktop):

```
cert.pem (copy to OS, then delete)
privkey.pem (copy to OS, then delete)
cert.csr (Just delete)
```

#### Creating a new mini-httpd.pem

Open `cert.pem` with a text editor and copy the contents from the top starting with:

```
-----BEGIN CERTIFICATE-----
```

all the way to the end and including the line

```
-----END CERTIFICATE-----
```

Open `privkey.pem`, and right after

```
-----END RSA PRIVATE KEY-----
```

Paste onto the line below it, the contents of cert.pem that you copied.

It should look like this:

```
-----BEGIN PRIVATE KEY-----
RANDOM GARBLED ENCRYPTION RANDOM GARBLED ENCRYPTION
RANDOM GARBLED ENCRYPTION RANDOM GARBLED ENCRYPTION
RANDOM GARBLED ENCRYPTION RANDOM GARBLED ENCRYPTION
RANDOM GARBLED ENCRYPTION RANDOM GARBLED ENCRYPTION
RANDOM GARBLED ENCRYPTION RANDOM GARBLED ENCRYPTION
RANDOM GARBLED ENCRYPTION RANDOM GARBLED ENCRYPTION
RANDOM GARBLED ENCRYPTION RANDOM GARBLED ENCRYPTION
RANDOM GARBLED ENCRYPTION RANDOM GARBLED ENCRYPTION
RANDOM GARBLED ENCRYPTION RANDOM GARBLED ENCRYPTION
-----END PRIVATE KEY-----
-----BEGIN CERTIFICATE-----
RANDOM GARBLED ENCRYPTION RANDOM GARBLED ENCRYPTION
RANDOM GARBLED ENCRYPTION RANDOM GARBLED ENCRYPTION
RANDOM GARBLED ENCRYPTION RANDOM GARBLED ENCRYPTION
RANDOM GARBLED ENCRYPTION RANDOM GARBLED ENCRYPTION
RANDOM GARBLED ENCRYPTION RANDOM GARBLED ENCRYPTION
RANDOM GARBLED ENCRYPTION RANDOM GARBLED ENCRYPTION
RANDOM GARBLED ENCRYPTION RANDOM GARBLED ENCRYPTION
RANDOM GARBLED ENCRYPTION RANDOM GARBLED ENCRYPTION
RANDOM GARBLED ENCRYPTION RANDOM GARBLED ENCRYPTION
-----END CERTIFICATE-----
```

Save `privkey.pem`. Then rename it to: `mini_httpd.pem`

## Installing the certificate to Windows 7

[![](/_media/doc/howto/chromeerror.png?w=400&tok=3690fe)](/_detail/doc/howto/chromeerror.png?id=docs%3Aguide-user%3Aservices%3Awebserver%3Ahttp.mini-httpd "doc:howto:chromeerror.png") [![](/_media/doc/howto/ie-cert-error.jpg?w=400&tok=46fd35)](/_detail/doc/howto/ie-cert-error.jpg?id=docs%3Aguide-user%3Aservices%3Awebserver%3Ahttp.mini-httpd "doc:howto:ie-cert-error.jpg")

To avoid issues with your browser whining that the SSL connection is not secure, we will install the certificate we made to the OS, so that it knows it is indeed safe. Note: At this point in the guide you won't see the above erros in your browser, as the service is not started. They are to demonstrate what it will whine about after you have the service running, but have not yet installed the certificate to your OS.

To accomplish this, we need to install `cert.pem` on the computer(s) accessing the WebGUI. On Windows 7 execute:

```
certmgr.msc
```

Next, on the left pane click on Trusted Root Certification Authorities, expand it, or double click on Certificates in the right pane. You should now see a bunch of other certificates.

[![?300](/_media/doc/howto/certmgr-ss.jpg "?300")](/_detail/doc/howto/certmgr-ss.jpg?id=docs%3Aguide-user%3Aservices%3Awebserver%3Ahttp.mini-httpd "doc:howto:certmgr-ss.jpg")

Now, Right-click in the right pane (or click Action in the toolbar) and choose 'All Tasks' then 'Import...' Click on next. Click Browse, in the explorer window that pops up, change the extension (bottom right) from 'X.509 Certificate (\*.cer,\*.crt) to All Files (\*.\*) then select `cert.pem` from your Desktop.

[![?300](/_media/doc/howto/cert-ext-window-ss.png "?300")](/_detail/doc/howto/cert-ext-window-ss.png?id=docs%3Aguide-user%3Aservices%3Awebserver%3Ahttp.mini-httpd "doc:howto:cert-ext-window-ss.png")

Then click on next. Choose 'Place all certificates in the following store. If 'Trusted Root Certification Authorities' *is* select already, click next, then Finish. If it *is not* already selected, click browse and then click on 'Trusted Root Certification Authorities' and click ok. Then click next, and Finish.

Now, it will issue a security warning. It warns you that it cannot validate the certificate is actually from your router IP address. As this is a self-signed certificate, you know it's from you, so click on YES to install the certificate. It will then successfully install to the Trusted Root Certification Authorities. If you do not see it in the list, simply hit right-click in the right pane, and choose 'Refresh'. Ta-da!

## Upload mini\_httpd.pem and starting the service

Now, before you can access the router by HTTPS, you will need to do a couple more things: giving the router the private key and cert in the form of the `mini_httpd.pem`, and enabling then starting the service.

Now, we already created `mini_httpd.pem` above, so let's place it on the router where it belongs. Using WinSCP, login and navigate to /etc. Delete the existing`mini_httpd.pem` from the router (If you have been following this word for word, then you should already have a backup named `mini_httpd-ORG.pem` on the desktop or wherever) and copy your created `mini_httpd.pem` over to /etc.

Once that is completed, you can close WinSCP.

## Starting the service

```
/etc/init.d/mini_httpd enable
/etc/init.d/mini_httpd start
```

### Testing

Try opening a browser and navigate to: [https://192.168.1.1](https://192.168.1.1 "https://192.168.1.1")

If you have trouble, try: Clearing the cookies/cache in your browser. Trying Incognito mode (Chrome) or InPrivate (Internet Explorer) Try navigating to the full url: `https://192.168.1.1/cgi-bin/luci`

You should get NO error regarding the certificate. :)

### Shutting Down regular HTTP access (uhttpd)

Before Chaos Calmer:

```
/etc/init.d/uhttpd stop
/etc/init.d/uhttpd disable
```

To test it's down, navigate to your [http://192.168.1.1](http://192.168.1.1 "http://192.168.1.1") and it should error out.

You can also stop and disable this through Luci. Log into Luci (HTTPS), go to the System tab, then to the Startup sub tab. Find uhttpd and choose STOP. Then DISABLE.

Chaos Calmer and later:

uhttpd listens on both http and https, so stopping / disabling uhttpd will turn off both. Instead, tell uhttpd not to listen on http - edit /etc/config/uhttpd and remove the 'listen\_http' lines stop listening on port 80. Then:

```
/etc/init.d/uhttpd restart
```

and use:

```
netstat -l
```

to verify that nothing is listening on http / TCP port 80.

## Forcing a strong SSL/TLS Cipher

As written above, creating a strong certificate does not mean mini\_httpd and your browser will use the maximum available cipher.  
Following [information that I found here](http://www.skytale.net/blog/archives/22-SSL-cipher-settings.html "http://www.skytale.net/blog/archives/22-SSL-cipher-settings.html"), I found some strong SSL ciphers and plugged them into mini-httpd.

You will need to find which cipher you prefer, or you should be able to use one of the following:  
**SSL v3**  
DES-CBC3-SHA  
RC4-MD5  
RC4-SHA

**TLSv1**  
DES-CBC3-SHA  
AES128-SHA  
AES256-SHA  
RC4-MD5  
RC4-SHA  
SEED-SHA

You can find out more about the different ciphers by running:

```
openssl ciphers -v
```

The format being Cipher name, Key eXchange, Authentication, Encryption method, and Message Authentication Code

Now, if you run [mini\_httpd --help](http://www.digipedia.pl/man/doc/view/mini-httpd.8/ "http://www.digipedia.pl/man/doc/view/mini-httpd.8/") you will see that there is a \[-Y cipher] option. To utilize this, edit your mini\_httpd.conf

```
vi /etc/mini_httpd.conf
```

At the bottom, insert a new line:

```
cipher=<NAME OF CIPHER>
```

Obviously replacing &lt;NAME OF CIPHER&gt; with one of those from above. For example:

```
cipher=AES128-SHA
```

Save the file. Restart mini\_httpd.

## Using a different port

By using an un-standard port to run mini-httpd, you add one more layer to the onion of security. Security by obscurity may not be an end-all-be-all, but it never hurts.  
Dynamic/Private ports exist in this range: 49152-65535.

If you run [mini\_httpd --help](http://www.digipedia.pl/man/doc/view/mini-httpd.8/ "http://www.digipedia.pl/man/doc/view/mini-httpd.8/") you will see that there is a \[-p port] option. To utilize this, edit your mini\_httpd.conf

```
vi /etc/mini_httpd.conf
```

At the bottom, insert a new line:

```
port=<PORT NUMBER>
```

Obviously replacing &lt;PORT NUMBER&gt; with something other than 80 or 443. For example:

```
port=51529
```

Save the file. Restart mini\_httpd.

## Troubleshooting

**Help! I need my http back!**

Now, if something happened and need to get back into your router through the normal HTTP GUI. It’s easy to bring it back using SSH.

Login to your router by SSH. Issue the following 2 commands:

```
/etc/init.d/uhttpd enable
/etc/init.d/uhttpd start
```

Now, try accessing your 192.168.1.1 via regular http and not https. It should be back up and running.

## Notes

I found that a couple of times, I needed to run the commands to shut down and disable uhttpd and restart mini\_httpd like this

```
/etc/init.d/uhttpd stop
/etc/init.d/uhttpd disable
/etc/init.d/mini_httpd stop
/etc/init.d/mini_httpd disable
/etc/init.d/mini_httpd enable
/etc/init.d/mini_httpd start
```
