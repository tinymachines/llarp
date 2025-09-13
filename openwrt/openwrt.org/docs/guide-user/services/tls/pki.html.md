# Installing and trusting a root CA certificate in a PKI

As stated above:

> For enabling HTTPS for a website's domain we need a private key and it's TLS certificate that was signed by a Certificate Authority (CA).

But what if you have your private Certificate Authority in your infrastructure? In that case, your CA will sign your certificate but the root certificate (the one from the private CA) won't be trusted by your system. It needs to be installed and added to the system's trust store.

Steps are as follow:

1. Get the root CA certificate
2. Install the root CA certificate
3. Add the root CA certificate to the system's trust store
4. A helper script

For this documentation we will assume:

- The CA name is `ca.private-domain.tld`
- The CA server is accessible at `ca.private-domain.tld`, port `443`
- The CA cert filename is `ca.private-domain.tld.cert`

### 1. Get the root CA certificate

Let's get the root CA cert.

```
openssl s_client -connect ca.private-domain.tld:443 < /dev/null > /tmp/temporary.out
openssl x509 -outform PEM < /tmp/temporary.out > /tmp/ca.private-domain.tld.cert
rm /tmp/temporary.out
```

Note: Don't forget to remove the temporary file `/tmp/temporary.out`

### 2. Install the root CA certificate

Trusted certificates are installed in `/etc/ssl/certs`. However, it is a good practice to follow the [FHS 3](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch04s09.html "https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch04s09.html") and use `/usr/local/share` for architecture-independant files.

```
mkdir -p /usr/local/share/ca-certificates
mv /tmp/ca.private-domain.tld.cert /usr/local/share/ca-certificates/
ln -s /usr/local/share/ca-certificates/ca.private-domain.tld.cert /etc/ssl/certs/ca.private-domain.tld.cert
chmod ugo-x /usr/local/share/ca-certificates/ca.private-domain.tld.cert
```

### 3. Add the root CA certificate to the system's trust store

The certificate is installed but not yet trusted. You need to provide its hash.

```
# Generate the hash
HASH="$(openssl x509 -hash -noout -in /etc/ssl/certs/ca.private-domain.tld.cert).0"
 
# Display the hash value
echo "$HASH"
 
# Link the hash to the certificate
ln -s "/etc/ssl/certs/ca.private-domain.tld.cert" "/etc/ssl/certs/$HASH"
```

Note: If another cert has the same hash use suffix `.1` or `.2` instead of `.0`.

Congratulations, you've installed and trusted your root CA certificate.

### 4. A helper script

```
CA_NAME="ca.private-domain.tld"
CERT_FILE="$CA_NAME.cert"
CERT_INSTALL_DIR="/usr/local/share/ca-certificates"
CERT_PATH="${CERT_INSTALL_DIR}/${CERT_FILE}"
 
openssl s_client -connect ${CA_NAME}:443 < /dev/null > /tmp/temporary.out
mkdir -p "$CERT_INSTALL_DIR"
openssl x509 -outform PEM < /tmp/temporary.out > "$CERT_PATH"
HASH="$(openssl x509 -hash -noout -in $CERT_PATH).0"
echo "$HASH"
 
ln -s "$CERT_PATH" "/etc/ssl/certs/$CERT_FILE"
ln -s "/etc/ssl/certs/$CERT_FILE" "/etc/ssl/certs/$HASH"
ls -al "/etc/ssl/certs/$HASH"
 
rm /tmp/temporary.out
```
