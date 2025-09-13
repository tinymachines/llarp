# Breed

Boot and Recovery Environment for Embedded Devices (BREED) is A multi-task bootloader with real-time firmware upgrading progress.

- Copyright (C) 2018 HackPascal
- Revision: r1266 \[2018-12-29]

Because some official upgrade firmware comes with a bootloader, if you upgrade from the official firmware Web, it will cause Breed to be overwritten. When Breed flashes the firmware, it automatically removes the bootloader that comes with the firmware, so it can prevent Breed from being overwritten.

- Real-time flashing progress, the progress bar can accurately reflect the progress of the flashing
- Support AR7161/AR913X/AR724X/AR9331/AR934X/RT305X/RT5350/AR9344/QCA953X/QCA956X/QCA9558/MT7620/MT7621/MT7628
- Web page fast response
- Maximum firmware backup speed, depending on Flash, can generally reach 1MB / s
- Press the reset button to enter the web flash mode
- Telnet function, no TTL access to Breed command console
- Reset key defines test function
- Firmware startup failure automatically enters Web flash mode
- Environment variable blocks with customizable position and size
- [Breed manual](https://drive.google.com/file/d/1fLvRMPqluAHiG5ryLnbNhsRdcGLquotT/view "https://drive.google.com/file/d/1fLvRMPqluAHiG5ryLnbNhsRdcGLquotT/view")
- [https://breed.hackpascal.net/](https://breed.hackpascal.net/ "https://breed.hackpascal.net/")

**After updating the AR / QCA chip from U-Boot to Breed, please remember to check whether the MAC address is valid. If it is all FF, please modify it yourself! !!**
