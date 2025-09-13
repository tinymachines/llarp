## Identify Wi-Fi connection as metered on Android automatically

![:!:](/lib/images/smileys/exclaim.svg) This is specific to Android and, specifically, iOS devices do not recognize this option

[Android](https://www.android.com/ "https://www.android.com/") has [implemented](https://android.googlesource.com/platform/frameworks/base.git/+/9f6e4ba50e7e73704c7fbd3ba65fe73bdf8ad73f "https://android.googlesource.com/platform/frameworks/base.git/+/9f6e4ba50e7e73704c7fbd3ba65fe73bdf8ad73f") detection of metered connnection based on `DHCP` protocol. When a certain DHCP flag is set, Android will consider the connection as metered. This is completely different as [Microsoft Windows](/docs/guide-user/network/wifi/ms-meteredconnection "docs:guide-user:network:wifi:ms-meteredconnection") or [Linux](/docs/guide-user/network/wifi/linux-meteredconnection "docs:guide-user:network:wifi:linux-meteredconnection") do.

To mark a connection as metered on Android, you can add the “43,ANDROID\_METERED” DHCP option to the DHCP server serving the phone

* * *

### Option 1: Do it via SSH using uci

This assumes that your interface is named lan.

Open OpenWrt console and execute

```
  uci show     dhcp.lan.dhcp_option
```

Verify that the option is not already set. If not, execute the following to commands to enable it, save, and reboot:

```
  uci add_list dhcp.lan.dhcp_option="43,ANDROID_METERED"
  uci commit
  uci reboot
```

You will then need to wait for the phone to get a new DHCP lease, and it should treat the connection as metered.

* * *

### Option 2: Do it via luci (web interface)

1. Navigate to Network, then Interfaces
2. Open the Interface in question by clicking its Edit button
3. Navigate to the DHCP Server tab
4. Under DHCP Server open the Advanced tab
5. In the list DHCP-Options, add 43,ANDROID\_METERED

* * *

### Verifying if it worked

As of writing this article, there is no way in the Android UI to verify that this was taken into consideration by Android. You can however use adb. Explaining how to use adb is out of scope of this article, but the commands of interest are:

```
  adb shell dumpsys connectivity | grep "Metered hint"
  adb shell dumpsys wifi
```

The first command will show “Metered hint: true” if the above worked.

* * *

### References

- [How android knows it's on an expensive connection](https://www.lorier.net/docs/android-metered.html "https://www.lorier.net/docs/android-metered.html")
