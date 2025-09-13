# Scripts to get information from modems

## Get IP address

### Fibertel Cisco DPC3825 DOCSIS 3.0 Data Gateway

```
#!/bin/sh
wget -q --post-data="username_login=admin&password_login=password" \
  --timeout=1 http://192.168.100.1/goform/Docsis_system -O /dev/null
wget -qO - http://192.168.100.1/Status.asp | sed -n -e \
  '/InternetIPAddress/ s/^.*>\([0-9][0-9\.]*\)<.*$/\1/p'
```

## Get speed

### Arnet P.DG A4001N

```
#!/bin/sh
 
# Reads modem speed
 
wget -qO - http://10.0.0.2/info.html | sed -e \
  '1,/>Line Rate - Upstream (Kbps):</d' | sed -e \
  '6,$ d' -e '2,4 d' -e 's/<\/.*$//' -e 's/.*>//'
```
