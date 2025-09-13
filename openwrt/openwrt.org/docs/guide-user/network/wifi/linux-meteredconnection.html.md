## Identify Wi-Fi connection as metered on Linux automatically

[NetworkManager](https://networkmanager.dev/ "https://networkmanager.dev/") (**NM**) has [implemented](https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/commit/5307b1ed733fd0b91a1ef8bd5c58d8c68312ee2c "https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/commit/5307b1ed733fd0b91a1ef8bd5c58d8c68312ee2c") detection of metered connnection based on `MS-NCT` protocol nearly same as [Microsoft Windows](/docs/guide-user/network/wifi/ms-meteredconnection "docs:guide-user:network:wifi:ms-meteredconnection") does.

To implement metered connection detection, set **cost level** to `0x02` or `0x03` as described in [Microsoft Windows article](/docs/guide-user/network/wifi/ms-meteredconnection "docs:guide-user:network:wifi:ms-meteredconnection").

* * *

![:!:](/lib/images/smileys/exclaim.svg) **NM 1.31.5 and before** has a [bug](https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/issues/734 "https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/issues/734") in MS-NCT implementation because second `Reserved` byte is used instead of `Cost_Level` byte.  
According to **NM** code, value of this byte must be **greater** than `0x01` to make **NM** think connection is metered.  
According to [\[MS-NCT\]](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-nct/ "https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-nct/"), the byte used by **NM** **SHOULD** always be 0x00, so it may cause compatibility errors, so you can change it on your own risk.

```
DD 08 00 50 F2 11 02 00 02 00
                            ^
                            |
               Only this byte is 
           taken into account by NM
```

Please refer to [**Identify Wi-Fi connection as metered on Windows automatically**](/docs/guide-user/network/wifi/ms-meteredconnection "docs:guide-user:network:wifi:ms-meteredconnection") page for details.
