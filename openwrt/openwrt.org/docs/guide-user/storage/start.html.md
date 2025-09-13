# Storage functions

[Continue with the « docs » section at the top...](#top-1146481036 "Continue with the « docs » section at the top...")

# [Continue with the « docs » section at the top...](#top-1146481036 "Continue with the « docs » section at the top...")[Documentation](/docs/start "docs:start")

[Continue with the « docs » section at the top...](#top-1146481036 "Continue with the « docs » section at the top...")

## [Continue with the « docs » section at the top...](#top-1146481036 "Continue with the « docs » section at the top...")[User guide](/docs/guide-user/start "docs:guide-user:start")

[Continue with the « docs » section at the top...](#top-1146481036 "Continue with the « docs » section at the top...")

### [Continue with the « docs » section at the top...](#top-1146481036 "Continue with the « docs » section at the top...")[Storage functions](/docs/guide-user/storage/start "docs:guide-user:storage:start")

- [Disk Encryption](/docs/guide-user/storage/disk.encryption "docs:guide-user:storage:disk.encryption")
- [Filesystems](/docs/guide-user/storage/filesystems-and-partitions "docs:guide-user:storage:filesystems-and-partitions")
- [Fstab Configuration](/docs/guide-user/storage/fstab "docs:guide-user:storage:fstab")
- [hd-idle Configuration](/docs/guide-user/storage/hd-idle "docs:guide-user:storage:hd-idle")
- [Installing and troubleshooting USB Drivers](/docs/guide-user/storage/usb-installing "docs:guide-user:storage:usb-installing")
- [mountd Configuration](/docs/guide-user/storage/mountd "docs:guide-user:storage:mountd")
- [Using storage devices](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives")[Continue with the «  » section at the top...](#top-1146481036 "Continue with the «  » section at the top...")

#### ...

- [Writable NTFS](/docs/guide-user/storage/writable_ntfs "docs:guide-user:storage:writable_ntfs")

## Where can I learn more about installing a USB drive on my OpenWrt device and running the OS from that drive?

The key pages for installing a USB drive on an OpenWrt system and configuring the OS to run from the USB drive.

- [Quick Start for Adding a USB drive](/docs/guide-user/storage/usb-drives-quickstart "docs:guide-user:storage:usb-drives-quickstart")

 

- [Extroot configuration](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration")

 

- [Installing and troubleshooting USB Drivers](/docs/guide-user/storage/usb-installing "docs:guide-user:storage:usb-installing")

 

- [Using storage devices](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives")

 

### How should I use these resources?

The answer depends on your goals.

#### Option 1: I just want extra storage space and do not care about installing and running packages

Examples of use cases for this option include storing large log files, capturing data from sensors, and other instances where you simply need more storage space for storing static files.

If you just want to install a USB drive and mount it as an additional directory to store generic files, start with [usb-drives-quickstart](/docs/guide-user/storage/usb-drives-quickstart "docs:guide-user:storage:usb-drives-quickstart"). Note that this option by itself will not give you additional room to install and run new packages. However, it is the first step to being able to install and run new packages. If you want to install and run new packages, proceed to the next option.

#### Option 2: I want extra storage space in addition to being able to install and run more packages

If your goal is to install a USB drive so that you will have more room to install and run new packages, visit [extroot\_configuration](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration"). Please be aware that this page contains an overview of the OpenWrt file system, but it also has instructions for installing a new USB drive and configuring the OpenWrt OS to run from the USB drive. Much of the information on this page for installing a new USB drive is duplicated on the [usb-drives-quickstart](/docs/guide-user/storage/usb-drives-quickstart "docs:guide-user:storage:usb-drives-quickstart") page. Therefore, if you've already installed a USB drive by following the *USB Drive Install Quick Start Guide*, just be aware that you might encounter warnings or errors when running the instructions on this page.

#### Should I be worried about frequently writing and deleting data to a USB storage device?

Please be aware that electronic storage media such as SD cards and USB drives degrade much more quickly than traditional hard disks or SSDs with multiple write/delete cycles. Some manufacturers market *high-endurance* storage media for devices such as security cameras that undergo frequent write/delete cycles. Whether or not these cards live up to their claims is a subject of debate. Although removable media are not going to be as robust as proper hard disks and SSDs, many people use these removable media to run OpenWrt daily for years with no problem. Regardless of what type of media being used to run an OS or store critical data, a backup strategy should be implemented that takes into account the risk of data loss. Besides mechanical failures, an OS can become corrupted through user error (*e.g* misconfiguration), installation of buggy packages, malicious actors, *etc*. An effective backup strategy will mitigate the risk associated with all of these hazards.

### Why are there 4 different pages about installing and configuring USB drives on OpenWrt?

At present (Dec 24, 2020), the documentation pages that detail installing and configuring USB drives for OpenWrt are not well-coordinated. Much of the same information is repeated across these pages, and for a new OpenWrt user trying to install a USB drive on their hardware and configure it to run the OS, the process is not clear at all. This problem is compounded if the user is not experienced with Linux CLI commands and scripting. These pages need to be refactored to coordinate them and make the instructions for installing and configuring USB storage clearer.
