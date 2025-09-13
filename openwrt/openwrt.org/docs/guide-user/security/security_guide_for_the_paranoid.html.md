# Security Guide for the Paranoid

This guide is a work in progress.

Please don't modify this guide before it is finished.

You may react and discuss using this forum thread:

[https://forum.openwrt.org/t/security-guide-for-the-paranoid/](https://forum.openwrt.org/t/security-guide-for-the-paranoid/ "https://forum.openwrt.org/t/security-guide-for-the-paranoid/")

## Who is this guide for?

With today's fast DSL speed lines, cables or fiber optics, security is a matter of interest for everyone:

1. Security officers
2. Network admins
3. Home users

Security is not simply avoiding a hack, it is about preserving the valuable data of your company or of your daily life.

This guide targets medium to high security for everyone. But it will not stop governments from digging in your personal computers or strolling your home network, as governments have access to undocumented “zero day” attacks or in some cases can access a secondary CPU hidden in the main CPU of your computer, even if your computer seems to be shut-down.

## Basic rules for security

These are very basic rules!

1. Minimize the attack space. Don't use applications or computers that you don't need and use only the needed resources. Especially, the main firewall in contact with the Internet should run very minimal software.
2. Do not trust security. If you do hold secrets, do not share them using a computer. Once you completed this guide, don't expect to save your credit card informations somewhere on your computer.
3. Create layers of defense, that will slow-down an attack and leave time for your to shutdown computers and recover from backups. In French this notion is described as “défense en profondeur” (i.e. “Deep-Defense”). An example of Deep-Defense in history is the defense of Russians against Napoleon during the Russian campaign.
4. Manage quality and improve your defense step by step. Use only software validated by communities, i.e. Free Software. Do not use commercial software with no access to source code (“Management by obscurity”).

## Why use LEDE ?

In the past, several well-known communities providing firewalls and network appliance failed to share information about their compilation platforms. Especially, part of the kernel code remained unknown. This is why LEDE was created : a free community offering state-of-the art firmware based on recent versions of GNU/Linux.

The beauty of LEDE is that thanks to a wide support of equipments, a complete network topology for home user may cost less than 500 EUR.

In this tutorial, we will also give information about electrical consumption, showing that choosing the right embedded equipment can save a lot in energy and there is no need to go for expensive, unsecure and power consuming devices.

Furthermore, LEDE devices are so small and so cheap, that for security issues, you may fill them with stone-glue to avoid any opening and we will show you how to do it using professional techniques.

## Network topology

The proposed network topology is for home users and small companies. You may adapt it to your needs and available hardware. LEDE is able to do all this on a single router, but it preferable to add defense space and use several of them. The inetwork topology includes:

- A main LEDE router
- A switch with VLAN support and port mirroring.
- Secondary LEDE routers organized by zones: trusted, untrusted, DMZ.
- A logging server and network probes.
- A serial console server and an administration console, with no connection to Internet.

[![](/_media/media/docs/howto/security_topology_0001.png)](/_detail/media/docs/howto/security_topology_0001.png?id=docs%3Aguide-user%3Asecurity%3Asecurity_guide_for_the_paranoid "media:docs:howto:security_topology_0001.png")

As you can notice, the topology is designed to resist attacks using deep defense:

- The main router may be penetrated.
- The switch may be penetrated.
- Secondary routers may be penetrated.
- Zones or stations may be penetrated.
- But the main administration console and some equipment like network probes may NOT be penetrated, as they have no connection to the Internet.

This should leave space and time for proper reaction.

Also, please note that zones are organized according to security principles:

- The Admin console zone is name **paranoiac zone**. It is not connected to Internet and you should never update/install software. It is encrypted and connects to other stations using a serial console server. Serial console is an old secure and simple protocol. This zone may only be penetrated using professional penetration tools which cannot be purchased easily: false keyboards with key loggers, electrical equipment with hidden network, wireless screen viewer, remote access to a hidden network card hidden in a sound card. If your activities are legal, you should be safe.
- The DMZ zone is a **high security zone**. It should be locked in a small cabinet with no human access except you and your top-boss. In fact, even in a 1000 people company, only you.
- The “Trusted zone” is a **daily security zone**, which means you should care for security, but in a usual way: install updates, be sure to avoid unknown software, etc. This zone includes should include only trusted hosts connected using wires (no WIFI). The question whether Windows OS is trusted or not remains and only you can answer. IMHO, Windows cannot be trusted as most recent desasters are due to poor security in Windows. Do don't expect to fix this alone.
- The **Untrusted zone** is a zone where untrusted computers, phones and tablets are living their daily unsecure life. This is where you should also put any equipment managed remotely: game stations, connected TVs, etc. We could also call it “Mission impossible zone”, as it is really too difficult to manage.
