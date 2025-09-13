# 802.11s - The Mesh11sd Project

Mesh11sd is a tool for OpenWrt users looking to create and manage wireless mesh networks using the 802.11s standard.

It helps automate the process, which can be complex, especially for those new to networking or for the more experienced wanting to rapidly deploy larger networks.

***Please read the documentation before installing the mesh11sd package!***  
***[Mesh11sd Documentation](https://github.com/openNDS/mesh11sd/#1-the-mesh11sd-project "https://github.com/openNDS/mesh11sd/#1-the-mesh11sd-project")***

### Are You Sure You Want a Mesh?

***If you are looking for a solution to enable your user devices to seamlessly roam from one access point to another in your home, you need 802.11r (roaming), not 802.11s.***

It is unfortunate that some manufacturers have used the word “Mesh” for marketing purposes to describe their non-standard, closed source, proprietary “roaming” functionality and this causes great confusion to many people when they enter the world of international standards and open source firmware for their network infrastructure.

The accepted standard for mesh networks is ieee802.11s.  
The accepted standard for fast roaming of user devices is ieee802.11r.

These are two completely unrelated standards.

### Will I Brick My Router?

Mesh11sd provides an escapable “Confidence Test”, a means of creating a basic reflash image that allows the mesh11sd daemon to be manually started in autoconfig mode.  
If, in the worst case, it becomes impossible to access the node being tested, a simple power cycle will restore an accessible state.

### Do Not Use Mesh11sd with Other Mesh Management Systems

The mesh11sd package is a fully fledged mesh backhaul management system.

***As you might expect, problems will be inevitable if another mesh backhaul management system is installed at the same time (for example the batman-adv package).***

### Reporting Issues

Create an issue on the Github repository at:  
[https://github.com/openNDS/mesh11sd/issues](https://github.com/openNDS/mesh11sd/issues "https://github.com/openNDS/mesh11sd/issues")
