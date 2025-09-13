# 802.11s Rapid Deployment

An 802.11s mesh backhaul can be rapidly deployed by taking advantage of the OpenWrt Firmware Selector (or the Image Builder) and the [Mesh11sd](https://github.com/openNDS/mesh11sd/#1-the-mesh11sd-project "https://github.com/openNDS/mesh11sd/#1-the-mesh11sd-project") package.

Rapid Deployment involves a few simple steps to create a flash image that contains all that is required to deploy a mesh network. The core of the mesh network is the mesh backhaul as it is the virtual wireless infrastructure that carries user data from one point to another in the background.

Full details including a working configuration can be found in the [Mesh11sd Project documentation](https://github.com/openNDS/mesh11sd/#41-rapid-deployment-firmware-flash "https://github.com/openNDS/mesh11sd/#41-rapid-deployment-firmware-flash").

### Major Features

1. Auto configuration of 802.11s mesh backhaul
2. Optional Bridge Portal mode supporting VLAN trunking over the mesh backhaul.
3. Optional Trunk Peer Mode providing ethernet downstream VLAN support.
4. Optional Customer/Client Premises Mode (CPE)
5. Default support for Opportunistic Wireless Encryption (OWE), with OWE Transition.
6. Optional portal node to multi point peer group, enabling “guest” networking over mesh backhaul without the need for setting up a VLAN.
7. Centralised Access Point usage database, enabling connected client statistics to be viewed.
