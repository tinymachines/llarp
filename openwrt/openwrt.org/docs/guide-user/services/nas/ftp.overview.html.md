# FTP servers

## Links

- [Evaluating FTP Servers: ProFTPd vs PureFTPd vs vsftpd](https://systembash.com/evaluating-ftp-servers-proftpd-vs-pureftpd-vs-vsftpd/ "https://systembash.com/evaluating-ftp-servers-proftpd-vs-pureftpd-vs-vsftpd/")

## Quickguides:

### vsftpd

The smallest of the three popular FTP servers

1. Install from web-interface or command-line: “**opkg install vsftpd**”
2. You might want to start and enable the vsftpd service in web-interface “System/Startup”
3. Configuration file is located in “**/etc/vsftpd.conf**”
4. To set the default FTP folder add the following to the config file: “**local\_root=/mnt/usb1**”
5. To enable PASSIVE mode, add the following to the config file: “pasv\_enable=YES”, “pasv\_min\_port=10090”, and “pasv\_max\_port=10100”
6. The vsftpd service can be controlled with the usual commands:

```
   /etc/init.d/vsftpd start     (Start the service)
   /etc/init.d/vsftpd stop      (Stop the service)
   /etc/init.d/vsftpd restart   (Restart the service)
   /etc/init.d/vsftpd reload    (Reload configuration files (or restart if that fails))
   /etc/init.d/vsftpd enable    (Enable service autostart)
   /etc/init.d/vsftpd disable   (Disable service autostart)
```

To support FTPD server through a firewall “opkg install kmod-nf-nathelper” (Not typically needed)

[This guide](https://web.archive.org/web/20230928140326/https://www.linuxscrew.com/vsftpd-anonymous-ftp-server "https://web.archive.org/web/20230928140326/https://www.linuxscrew.com/vsftpd-anonymous-ftp-server") easily explains how to setup an **anonymous ftp server** with vsftpd.
