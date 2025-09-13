# USB 3.0 and Wi-Fi problems

Unfortunately USB 3.0 and Wireless in the 2.4 GHz and even Bluetooth are interfering in the same frequency spectrum, which often causes problems. See [PC Mag Article about USB 3.0 and 2.4 GHz wireless issues](http://uk.pcmag.com/networking-reviews-ratings-comparisons/13179/opinion/wireless-witch-the-truth-about-usb-30-and-wi-fi-interference "http://uk.pcmag.com/networking-reviews-ratings-comparisons/13179/opinion/wireless-witch-the-truth-about-usb-30-and-wi-fi-interference").

The problems caused by these interferences do not affect the drive activity, but can seriously impact your 2.4 GHz Wi-Fi, if there is an USB 3.0 storage device attached to your OpenWrt Wi-Fi device:

- 2.4 GHz Wi-Fi clients may be unable to connect to your 2.4 GHz Wi-Fi radio.
- Already connected 2.4 GHz WiFi clients experience connection timeouts or seriously stalling or interrupted data transfers.

These problems will most likely also appear, while the drive is idle.

Workarounds may vary for your situation, you may try:

- Use 5 GHz Wi-Fi for your Wi-Fi client devices, as this problem only affects 2.4 GHz Wi-Fi.
- Use an USB 2.0 drive casing instead of a USB 3.0, as USB 2.0 does not interfere in the 2.4 GHz spectrum or disable the USB3 driver to force fallback to USB 2.0. Many current OpenWrt devices aren't even noticably faster on USB3.0 data transfers compared to 2.0.
- If your USB 3.0 storage device is an external USB3 harddrive drive, you could try a different casing that hopefully has better shielding.
- You could try a different USB3.0 cable, it could be that the vendor-provided cable included with your USB 3.0 device might have bad shielding. But unfortunately several USB casing vendors use cables with proprietary USB connectors on the drive side that aren't easy to get in a better shielded variant on the market.
- You could try to reposition your USB 3.0 storage device further away from your OpenWrt Wi-Fi device.
- You could try a custom improvised shielding for your USB 3.0 storage device or the USB 3.0 cable, if you are technically gifted.
- It could even be that the power cable or a network cable connected to your OpenWrt Wi-Fi device has bad shielding.
- You could try, if using a different and fixed channel for your 2.4 GHz radio slightly improves the issue: try channels 1, 6 and 11 and try Wi-Fi channel width 20 (if you were using 40 before).
