# DFS

[Dynamic\_frequency\_selection](https://en.wikipedia.org/wiki/Dynamic_frequency_selection "https://en.wikipedia.org/wiki/Dynamic_frequency_selection") plays a role in 5GHz frequencies that are shared with weather radar. It is related to [802.11h](https://en.wikipedia.org/wiki/IEEE_802.11h "https://en.wikipedia.org/wiki/IEEE_802.11h").

DFS support is used during ACS/“survey” in hostapd to find and select free WLAN channels.

Many countries regulate operation of the 5GHz spectrum - see [List\_of\_WLAN\_channels](https://en.wikipedia.org/wiki/List_of_WLAN_channels "https://en.wikipedia.org/wiki/List_of_WLAN_channels").

![:!:](/lib/images/smileys/exclaim.svg) Due to fast development, changing hardware, regulatory changes and compliance issues there can be interoperability issues.

![:!:](/lib/images/smileys/exclaim.svg) OpenWrt uses open source drivers with varying quality and upstream support. Sometimes they can be abandoned by the manufactorer, or no longer support some 5GHz operation due to regulatory changes.

![:!:](/lib/images/smileys/exclaim.svg) OEM proprietary drivers can sometimes offer DFS when OpenWrt does not.

![:!:](/lib/images/smileys/exclaim.svg) There are different DFS schemes: DFS-FCC (USA), DFS-ETSI (Europe), DFS-JP (Japan).

![:!:](/lib/images/smileys/exclaim.svg) Try to use the non DFS channels if you have old hardware/clients.

## DFS support

- ath9k: DFS-ETSI, DFS-FCC (source: [linux-wireless](http://marc.info/?l=linux-wireless&m=144524581929146 "http://marc.info/?l=linux-wireless&m=144524581929146")), probably DFS-JP (git commits)
- ath10k: DFS-FCC (source: [linux-wireless](http://marc.info/?l=linux-wireless&m=144524581929146 "http://marc.info/?l=linux-wireless&m=144524581929146")), probably DFS-ETSI
- ath11k: DFS-FCC (source: [linux-wireless](https://marc.info/?l=linux-wireless&m=170227574420539 "https://marc.info/?l=linux-wireless&m=170227574420539")), probably DFS-ETSI
- mt76: DFS-ETSI, DFS-FCC, DFS-JP. As of 2021-02-22, DFS is unsupported on the MT7613 radio however, despite the hardware supporting it.
- mwlwifi (source:[linux-wireless](http://marc.info/?l=linux-wireless&m=146707822404863&w=2 "http://marc.info/?l=linux-wireless&m=146707822404863&w=2")), but support is problematic on some hardware and won't be fixed ([GitHub issue #75](https://github.com/kaloz/mwlwifi/issues/75 "https://github.com/kaloz/mwlwifi/issues/75"))
- mwifiex (source: git log: “DFS support in AP mode”,[kernel.org](http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=cf075eac9ca94ec54b5ae0c0ec798839f962be55 "http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=cf075eac9ca94ec54b5ae0c0ec798839f962be55"))

## DFS status unknown

- ath9k\_htc
- wlcore, wl18xx (allow using dfs channels,add radar\_debug\_mode debugfs file for DFS testing)
- brcmfmac
- brcmsmac
- b43

## No DFS support

- mwl8k
