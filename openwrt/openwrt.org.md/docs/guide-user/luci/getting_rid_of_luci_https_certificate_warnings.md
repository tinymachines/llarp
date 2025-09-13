# How to get rid of LuCI HTTPS certificate warnings

Do you like the security of using LuCI-SSL (or Luci-SSL-OpenSSL), but sick of the security warnings your browser gives you because of an invalid certificate?

You can fix this by installing a certificate in LuCI that will be trusted automatically by most modern browsers (such as a (wildcard) certificate issued by Let's Encrypt) or by installing a self-signed certificate and manually telling your devices to trust this certificate.

# Option A: Automatic free HTTPS certificate from LetsEncrypt

This may only work if your router is accessible from the public internet. For detailed instructions, refer to [Get a free HTTPS certificate from LetsEncrypt for OpenWrt with ACME.sh](/docs/guide-user/services/tls/acmesh "docs:guide-user:services:tls:acmesh").

# Option B: Installing any publicly trusted certificate

These instructions are tested with a (wildcard) certificate issued by Let's Encrypt, but should work for any certificate signed by an official certificate authority. Pre-requisites for this option are:

- You have control over a **public domain name** (e.g. `example.com`)
- You have configured a (local) DNS resolver to **point** (a subdomain of) **your public domain name to the IP address of the OpenWRT** installation of interest. (For an individual machine this can be as simple as adding `192.168.0.1 openwrt.example.com` to `/etc/hosts/`.)
- You have access to **a certificate file and its private key** for the (sub)domain pointing to you OpenWRT installation. (E.g. a certificate signed by Let's Encrypt for `*.example.com`. For this, you must be able to publicly prove you own `example.com`, but you do not have to expose your OpenWRT installation to the public.)
- You have **ssh access** to your OpenWRT installation. We assume a ssh config has been set up so that `ssh openwrt` will be enough to get access.

Given these pre-requisites, there are three simple steps to start using your publicly trusted certificate. First we **convert the certificate** to a format LuCI/uhttpd likes. Next we put the converted certificate on the **correct location**. Lastly we **restart `uhttpd`** to start using the certificate.

### Place the PEM files at the right location

PEM files can be either individual or “inline” as a single file including cert, key, and CA (NGINX format.) Should you use an inline, simply make two copies of it and name them according to the information that follows. these PEM certificate files must be placed at `/etc/uhttpd.key` and `/etc/uhttpd.crt` on the OpenWRT installation respectively. Before doing this, you may want to back up whatever is currently stored at that location (e.g. `cp /etc/uhttpd.key /etc/uhttpd.key.bak` and `cp /etc/uhttpd.crt /etc/uhttpd.crt.bak`on the OpenWRT machine). Alternatively, configure uhttpd to look at another location by setting the `key` and `cert` paths (see [uhttpd](/docs/guide-user/services/webserver/uhttpd "docs:guide-user:services:webserver:uhttpd")) Then, if you have `rsync` activated on OpenWRT, you can use:

```
rsync /tmp/uhttpd.key openwrt:/etc/uhttpd.key
rsync /tmp/uhttpd.crt openwrt:/etc/uhttpd.crt
```

where `openwrt` is recognised from your ssh config. If you do not want to use `rsync` you can use `scp` instead, or do a simple `cp` if you issued the `openssl` commands already on the OpenWRT machine. The main goal is to put the DER-formatted certificate files to wherever the `key` and `cert` parameters of `/etc/config/uhttpd` are pointing.

### Activate the certificate

Lastly, issue the following command to restart `uhttpd` and thereby start using the new certificate:

```
ssh openwrt "/etc/init.d/uhttpd restart"
```

Now, when navigating to `openwrt.example.com` the connection should be automatically trusted. Note that, since all the above commands can be issued on an external machine with `ssh` access to the OpenWRT install, you can create a script to automatically update the certificate without having to touch OpenWRT yourself.

# Option C: Creating, installing &amp; trusting a self-signed certificate

With these instructions, you can generate your own self-signed certificate, which your browser will accept as valid.

One new headache was that, browsers usually only look at one key part of a self-signed certificate, the CN (common name). However, starting with Chrome version 58, it not only looks at the CN (common name) in the certificate, but also at the SAN (subject alt name or DNS name), which makes generating a certificate more complicated than before. You might have even had a certificate you made yourself, that worked until recently, stop working when Chrome 58 was released and most likely automatically updated and installed.

So, to get rid of the annoying “Warning, this is an insecure site, do you want to proceed?” warning messages, and other similar messages from other browsers, proceed with the following.

I know it looks long, but it's easy and goes fast. Should take about 10 minutes tops.

## Create &amp; Install

01. Connect via SSH
02. Install the openssl-util and LuCI uhttpd packages. This is required to generate a new certificate in the way you want it to be, and to be able to easily tell LuCI how to use it.
    
    ```
    opkg update && opkg install openssl-util luci-app-uhttpd
    ```
03. Create `/etc/ssl/myconfig.conf` with the following content:
    
    [myconfig.conf](/_export/code/docs/guide-user/luci/getting_rid_of_luci_https_certificate_warnings?codeblock=3 "Download Snippet")
    
    ```
    [req]
    distinguished_name  = req_distinguished_name
    x509_extensions     = v3_req
    prompt              = no
    string_mask         = utf8only
     
    [req_distinguished_name]
    C                   = US
    ST                  = VA
    L                   = SomeCity
    O                   = OpenWrt
    OU                  = Home Router
    CN                  = luci.openwrt
     
    [v3_req]
    keyUsage            = nonRepudiation, digitalSignature, keyEncipherment
    extendedKeyUsage    = serverAuth
    subjectAltName      = @alt_names
    basicConstraints    = CA:true
     
    [alt_names]
    DNS.1               = luci.openwrt
    IP.1                = 192.168.1.1
    ```
04. You can edit the values for C (country), ST (state), L (location), O (organization), OU (organization unit) to whatever you want.
    
    1. It's **extremely important** the values for **CN** and **DNS.1** match, and also that **IP.1** has the correct private IP address for the device.
       
       - Some of you might have a different IP, or you might access it via a hostname; the hostname should go in both CN and DNS.1 fields. The correct private IP address should go into IP.1.
05. Save the file and then navigate to /etc/ssl with the following command:
    
    ```
    cd /etc/ssl
    ```
06. Then issue the following command:
    
    ```
    openssl req -x509 -nodes -days 397 -newkey rsa:2048 -keyout mycert.key -out mycert.crt -config myconfig.conf
    ```
    
    This will create two files, `mycert.key` and `mycert.crt`  
    Alternatively you can create ECDSA certificate (to speedup key exchange phase) with the following command:
    
    ```
    openssl req -x509 -nodes -days 397 -newkey ec:<(openssl ecparam -name prime256v1) -keyout mycert.key -out mycert.crt -config myconfig.conf
    ```
07. Note that in the commands above, the validity of the certificate was set to 13 months (397 days, the “-days” option), so the process would need to be repeated when the period lapses. Some (all) browsers do not accept longer validity: [https://github.com/cabforum/servercert/blob/90a98dc7c1131eaab01af411968aa7330d315b9b/docs/BR.md?plain=1#L175](https://github.com/cabforum/servercert/blob/90a98dc7c1131eaab01af411968aa7330d315b9b/docs/BR.md?plain=1#L175 "https://github.com/cabforum/servercert/blob/90a98dc7c1131eaab01af411968aa7330d315b9b/docs/BR.md?plain=1#L175")
08. In LuCI, go to Services → uHTTPd
    
    - In the field for HTTPS Certificate, select the file `/etc/ssl/mycert.crt`, or select “Upload file” to transfer it from your PC (`mycert.crt`)
    - In the field for HTTPS Private Key, select the file `/etc/ssl/mycert.key`, or select “Upload file” to transfer it from your PC (`mycert.key`)
    - Hit save and apply.
09. Restart uhttpd
    
    ```
    /etc/init.d/uhttpd restart
    ```
10. Now to make it so that those 2 files are saved when you make a backup, in LuCI, go to System → Backup/Flash Firmware, Click Configuration tab, then add `/etc/ssl/mycert.crt` &amp; `/etc/ssl/mycert.key`
    
    - **When you make and restore a backup, your cert and key will automatically be backed up and restored.** The changes you made in LuCI → Services → uHTTPd will automatically be backed up because `/etc/config/uhttpd` is automatically backed up.
11. Hit Submit ( Or Save and Apply, depending on the LuCI Theme you're using )

## Chain of trust

- Now we have to get your computer to trust the certificate. They will get all browsers (IE, Edge, Firefox, etc) to work. You need to pull /etc/ssl/mycert.crt off your router. If you followed the previous step, an easy way is to click “Generate archive” in LuCI → System &gt; Backup / Flash Firmware and extract /etc/ssl/mycert.crt from the resulting archive (or you can use SCP).
- Alternatively, you can use Google Chrome to do the process. If you don't use Chrome, install it for now, and you can uninstall it after.
- Reload 192.168.1.1 (or however you access LuCI) in Chrome. Make sure you close and refresh the page after restarting uhttpd. Ignore the warning, and get to at least the login screen.
- Hit F12, click the security tab, click on view certificate, click the details tab, and click copy to file, just keep hitting next (don't change anything), and save (just name it, don't give it an extension as it'll be automatically added for you) the certificate somewhere easy to find. You can name it anything. Now close that window and the window that opened when you pressed F12.
- Proceed below depending on your operating system

### Windows (older versions of Chrome only)

- In Chrome, go to settings, advanced, and click manage certificates.
- Select the Trusted Root Certification Authorities tab and click import.
- Just follow the prompts, find the location of where you saved the certificate, and just keep clicking next. (Don't change anything, make sure it says it's going to place it in the Trusted Root Certification Authorities store which it should have selected by default).
- Close all the windows and chrome and all your browsers. Next time you access LuCI, it will show the certificate and connection as valid and secure.

### Windows (script)

- Go back to cert location
  
  ```
  cd /etc/ssl
  ```
- Export the cert key pair to pfx:
  
  ```
  openssl pkcs12 -export -out mycert.pfx -inkey mycert.key -in mycert.crt
  ```
- Enter password 1234
- Download the pfx file to pc (using WinSCP for example)
- Run this powershell script as admin from pfx file location:
  
  ```
  $mypwd = ConvertTo-SecureString -String "1234" -Force -AsPlainText
  Import-pfxCertificate -FilePath mycert.pfx -Password $mypwd -CertStoreLocation "Cert:\LocalMachine\Root"
  ```
- This will add the certificate as trusted to the system store.
- IE Edge and Chrome will use this automatically.
- For Firefox either add the certificate to trusted certificates manually or enable using Windows trusted store in about:config by setting security.enterprise\_roots.enabled to true

### GNU/Linux

- For Firefox, just visit LUcI and add an exception and everything will work.
- For Chrome-based browsers, you will need to install the libnss3-tools package first if you don't have certutil on your machine. Using your system's package manager, for example:
  
  ```
  apt-get install libnss3-tools
  ```
- The following command will add the certificate to your current user's NSS database. Make sure you are in the directory containing the `mycert.crt` file or adjust the `-i` parameter accordingly.
  
  ```
  certutil -d sql:$HOME/.pki/nssdb -A -t "CT,C,c" -n LuCI -i mycert.crt
  ```
- You can now restart your browser. The certificate errors when accessing LuCI should now be gone. However, On Chrome some people report that the error gets worse without you bein able to override it: [https://forum.openwrt.org/t/https-connection-to-luci-is-discarded/123904/30](https://forum.openwrt.org/t/https-connection-to-luci-is-discarded/123904/30 "https://forum.openwrt.org/t/https-connection-to-luci-is-discarded/123904/30") and [https://github.com/openwrt/luci/issues/6701](https://github.com/openwrt/luci/issues/6701 "https://github.com/openwrt/luci/issues/6701") .

Enjoy!!

*All the credit for the creation of (part C of) this walk-through goes to @StarCMS who originally posted this in @Davidc502's [thread](https://forum.openwrt.org/viewtopic.php?id=64949&p=81 "https://forum.openwrt.org/viewtopic.php?id=64949&p=81"). Minor changes and wiki formatting by @mariano.silva ( mariano.silva@gmail.com )*

# Option D: Let OpenWRT generate a new self-signed certificate

This was tested with OpenWrt 23.05 and not sure whether it will work with older versions. Also certificate may not be ideal if created with version before this pull request was merged [https://github.com/openwrt/openwrt/pull/1536](https://github.com/openwrt/openwrt/pull/1536 "https://github.com/openwrt/openwrt/pull/1536")

OpenWrt will generate on boot a new self-signed certificate in case existing one is removed. To remove the existing certificate, open an ssh terminal to your router and run `rm -i /etc/uhttpd.*` and confirm deleting `uhttpd.crt` and `uhttpd.key`. Then issue the `service uhttpd restart` command.

You can use the luci-app-uhttpd extension to get more control over the generated new certificate. Otherwise you will still not set proper `subjectAltName` and will need to add a new security exception in your browser to open LuCI. If you set proper `subjectAltName`, you can follow instructions in option C to install the certificate on your machine.
