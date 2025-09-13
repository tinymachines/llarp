# OpenWrt as DomU in Debian Xen4 in a private network

Based on this other wiki article: [xen](/docs/guide-user/virtualization/xen "docs:guide-user:virtualization:xen")

The main point of this howto is the network configuration. We are using a dummy0 device from dom0 to communicate with domU openwrt nodes. So the domU network will be isolated from the real one. If we want to provide internet to nodes, we can use NAT from dom0.

- Install Debian Squeeze on the computer

<!--THE END-->

- Install Xen (package version could vary)

```
aptitude install linux-image-2.6.32-5-xen-amd64 xen-hypervisor-4.0-amd64 xen-tools xen-utils-4.0 bridge-utils
```

- Update grub2 and reboot

```
mv /etc/grub.d/10_linux /etc/grub.d/50_linux
update-grub2
reboot
```

- Configure file `/etc/xen/xend-config.sxp`:

```
(network-script network-custom)
(vif-script     vif-custom)
```

And comment the rest about network and vif

- Create the scripts

`/etc/xen/scripts/network-custom`

```
 #!/bin/sh
 dir=$(dirname "$0")
 "$dir/network-route"  "$@" netdev=eth0
 "$dir/network-bridge" "$@" netdev=dummy0
```

`/etc/xen/scripts/vif-custom`

```
 #!/bin/sh
 dir=$(dirname "$0")
 IFNUM=$(echo ${vif} | awk -F. '{ print $2 }')
 if [[ "$IFNUM" == "0" ]] ; then
  "$dir/vif-route"  "$@"
 else
  "$dir/vif-bridge" "$@"
 fi
```

- Configure networking in `/etc/network/interfaces`:

```
 auto dummy0
 iface dummy0 inet static
   address 192.168.1.254
   netmask 255.255.255.0
```

- Compile OpenWrt for *x86* and *XEN* target (consult [OpenWrt Buildroot – Usage](/docs/guide-developer/toolchain/start "docs:guide-developer:toolchain:start"))

<!--THE END-->

- Example of xen domU configuration

```
memory = 256
name = "25"
kernel = "/root/VM/25/openwrt-x86-xen_domu-vmlinuz"
disk = ["file:///root/VM/25/openwrt-x86-xen_domu-rootfs-ext4.img,xvda2,w"]
vif = [ 'mac=00:16:3E:6:11:2' ]
vcpus = 1
on_reboot = 'restart'
on_crash = 'destroy'
root = '/dev/xvda2 rw'
```

- Start domU

```
xm create xen_domU.conf -c
```

## Script to manage nodes

Using this system you will be able to create as nodes you need using just one command.

**Create needed directories**

```
cd /root/
mkdir VM
mkdir config
mkdir images
```

**Create this two files:**

- config/network
  
  ```
  config interface loopback
          option ifname   lo
          option proto    static
          option ipaddr   127.0.0.1
          option netmask  255.0.0.0
  
  config interface lan
          option ifname   eth0
          option proto    static
          option ipaddr   192.168.1.#ID
          option netmask  255.255.255.0
  ```
- config/template.conf

```
memory = 256
name = "#ID"
kernel = "/root/VM/#PROFILE/#ID/kernel.img"
disk = ["file:///root/VM/#PROFILE/#ID/fs.img,xvda2,w"]
vif = [ 'mac=00:16:3E:#R1:#R2:#R3' ]
vcpus = 1
on_reboot = 'restart'
on_crash = 'destroy'
root = '/dev/xvda2 rw'
```

**Put these two images from OpenWrt buildroot inside images directory**

```
mv openwrt-x86-xen_domu-rootfs-ext4.img images/fs.img
mv openwrt-x86-xen_domu-vmlinuz images/kernel.img
```

**Copy this script to /root/manage\_nodes.sh**

```
#!/bin/bash
CONFIG="config/template.conf"
NETWORK="config/network"
IMAGE_DIR="images"
IMAGE_FS="fs.img"
IMAGE_KR="kernel.img"
VM_DIR="VM"
MNT="/mnt"
CURRENT_PROFILE=".xmn_profile"
PROFILE="default"

function new_node {

        R1=`echo $RANDOM%16 | bc`
        R2=`echo $RANDOM%16 | bc`
        R3=`echo $RANDOM%16 | bc`
        ID=`echo $RANDOM%100 | bc`

        mkdir -p $VM_DIR/$PROFILE/$ID

        cat $CONFIG | sed -e s/#ID/$ID/g -e s/#PROFILE/$PROFILE/g \
        -e s/#R1/$R1/g -e s/#R2/$R2/g -e s/#R3/$R3/g > $VM_DIR/$PROFILE/$ID/xen.conf

        cp -f $IMAGE_DIR/$PROFILE/$IMAGE_FS $VM_DIR/$PROFILE/$ID/
        cp -f $IMAGE_DIR/$PROFILE/$IMAGE_KR $VM_DIR/$PROFILE/$ID/

        config_network $ID
        start_node $ID
}


function rm_node {
        read -p "Are you sure you want do destroy node $1? [y|N] " q
        [ "$q" == "y" ] && rm -rf $VM_DIR/$PROFILE/$1
}

function rm_all {
        read -p "Are you sure you want do destroy all nodes from profile $PROFILE? [y|N] " q
        [ "$q" == "y" ] && { stop_all ; rm -rf $VM_DIR/$PROFILE/*; }
}


function multiple_node {
        [ -z "$1" ] && { echo "Please, specify the number of nodes you wan to create"; exit 1;} 
        for i in $(seq 1 $1); do
                echo "Creating node $i"
                new_node
                sleep 3
        done
}

function config_network {
        mount $VM_DIR/$PROFILE/$1/$IMAGE_FS $MNT -o loop
        [ $? -ne 0 ] && { echo "Cannot mount image!"; exit 1;}
        cat $NETWORK | sed s/#ID/$1/g > /mnt/etc/config/network
        umount $MNT
}

function dom0_network {
        ip tuntap add mode tap
        brctl addbr br0
        brctl addif br0 tap0
        ifconfig tap0 0.0.0.0 promisc
        ifconfig br0 192.168.1.254
}

function start_node {
        xm create $VM_DIR/$PROFILE/$1/xen.conf
        if [ $? -eq 0 ]; then 
                echo "New node with ID $1 has been created"
        else
                echo "Some problem starting node, check previous log"
        fi
} 

function list_nodes {
        ls $VM_DIR/$PROFILE/
}

function start_all {
        for m in $(ls $VM_DIR/$PROFILE/); do
                start_node $m
        done
}

function stop_node {
        xm destroy $1 2>/dev/null
}

function stop_all {
        for m in $(ls $VM_DIR/$PROFILE/); do
                xm destroy $m 2>/dev/null
        done
}

function new_profile {
        profile="$1"
        [ -z "$profile" ] && { echo "You must specify profile name" ; help; }
        [ -d "$VM_DIR/$profile" ] && { echo "Profile $profile exists, please remove it"; exit 1; }  
        mkdir -p $VM_DIR/$profile
        mkdir -p $IMAGE_DIR/$profile
        cp -f $IMAGE_DIR/$IMAGE_FS $IMAGE_DIR/$profile/
        cp -f $IMAGE_DIR/$IMAGE_KR $IMAGE_DIR/$profile/
        echo "New profile $profile successful created. Now you can use it: $0 profile $profile"
}

function profile {
        profile="$1"
        [ -z "$profile" ] && { echo "You must specify profile name" ; help; }
        [ ! -d "$VM_DIR/$profile" ] && { echo "This profile does not exist, please create it using: $0 new_profile $profile"; exit 1; }
        echo "$profile" > $CURRENT_PROFILE
        echo "Active profile is now $profile"
}

function rm_profile {
        [ -z "$1" ] && help
        read -p "Are you sure you want do destroy profile $1? [y|N] " q
        [ "$q" == "y" ] && { rm -rf $VM_DIR/$1; rm -rf $IMAGE_DIR/$1; }
        echo "Profile $1 removed"
}

function show_profile {
        echo "Current profile is: $PROFILE"
}

function list_profiles {
        ls $VM_DIR/
}

function help {
        echo "Usage: $0 option [arguments]"
        echo ""
        echo "Available options are:"
        echo ""
        echo "  profile <name> : Select profile <name>"
        echo "  new_profile <name> : Create a new profile <name>"
        echo "  show_profile : Show current profile"
        echo "  list_profiles : List all available profiles"
        echo "  rm_profile <name> : Remove profile <name> and all related files"
        echo ""
        echo "  new_node : Create a new node"
        echo "  rm_node <ID> : Remove the node with name ID"
        echo "  rm_all : Remove all nodes from current profile"
        echo "  multiple_node <#n> : Create #n nodes"
        echo "  list_nodes : List all nodes from current profile"
        echo ""
        echo "  start_node <#n> : Start node with ID #n"
        echo "  start_all : Start all nodes from current profile"
        echo "  stop_node <#n> : Stop node with ID #n"
        echo "  stop_all : Stop all nodes"
        echo ""
        echo "The images used for new virtual machines are placed in $IMAGE_DIR/[CURRENT_PROFILE]/"
        exit 0
}



[ -z "$1" ] && help
[ -f "$CURRENT_PROFILE" ] && PROFILE="$(cat $CURRENT_PROFILE)"
$1 $2 $3 $4 $5
```

Now you can execute it using bash to see help

```
root@p4u:~# bash manage_nodes.sh 
Usage: ./manage_nodes.sh option [arguments]

Available options are:

  profile <name> : Select profile <name>
  new_profile <name> : Create a new profile <name>
  show_profile : Show current profile
  list_profiles : List all available profiles
  rm_profile <name> : Remove profile <name> and all related files

  new_node : Create a new node
  rm_node <ID> : Remove the node with name ID
  rm_all : Remove all nodes from current profile
  multiple_node <#n> : Create #n nodes
  list_nodes : List all nodes from current profile

  start_node <#n> : Start node with ID #n
  start_all : Start all nodes from current profile
  stop_node <#n> : Stop node with ID #n
  stop_all : Stop all nodes

The images used for new virtual machines are placed in images/[CURRENT_PROFILE]/
```

For instance, to create 10 nodes just use:

```
./manage_nodes.sh new_profile p4u
./manage_nodes.sh profile p4u
./manage_nodes.sh multiple_node 10
```

You can see them using “xm list”. The name (ID), is the last IP digit for each one, so node 67 will be 192.168.1.67
