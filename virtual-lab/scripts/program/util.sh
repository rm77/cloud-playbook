#!/bin/sh
#
# Copyright IBM, Corp. 2010  
#
# Authors:
#  Anthony Liguori <aliguori@us.ibm.com>
#
# This work is licensed under the terms of the GNU GPL, version 2.  See
# the COPYING file in the top-level directory.

# Set to the name of your bridge
#BRIDGE=br0

# Network information
#NETWORK=192.168.53.0
#NETMASK=255.255.255.0
#GATEWAY=192.168.53.1
#DHCPRANGE=192.168.53.2,192.168.53.254

# Optionally parameters to enable PXE support
TFTPROOT=
BOOTP=

do_brctl() {
    brctl "$@"
}

do_ifconfig() {
    ifconfig "$@"
}

do_dd() {
    dd "$@"
}

do_iptables_restore() {
    iptables-restore "$@"
}

do_dnsmasq() {
    dnsmasq "$@"
}

check_bridge() {
    if do_brctl show | grep "^$1" > /dev/null 2> /dev/null; then
	return 1
    else
	return 0
    fi
}

create_bridge() {
    do_brctl addbr "$1"
    do_brctl stp "$1" off
    do_brctl setfd "$1" 0
    do_ifconfig "$1" "$GATEWAY" netmask "$NETMASK" up
    echo "ip link del $1 " > delete-switch.sh
}

create_bridge_ovs() {
    #do_brctl addbr "$1"
    #do_brctl stp "$1" off
    #do_brctl setfd "$1" 0
    #do_ifconfig "$1" "$GATEWAY" netmask "$NETMASK" up
    ovs-vsctl add-br $1
    do_ifconfig "$1" "$GATEWAY" netmask "$NETMASK" up
    echo "ovs-vsctl del-br $1 " > delete-switch.sh
    echo "ip link del $1 " >> delete-switch.sh
}

enable_ip_forward() {
    #echo 1 | do_dd of=/proc/sys/net/ipv4/ip_forward > /dev/null
    echo 1 > /proc/sys/net/ipv4/ip_forward
}

add_filter_rules() {

chainname=x$BRIDGE

iptables -t nat -N $chainname-POSTROUTING
iptables -t nat -A $chainname-POSTROUTING  -s $NETWORK/$NETMASK -j MASQUERADE 
iptables -t nat -A POSTROUTING -j $chainname-POSTROUTING

echo iptables -t nat -D POSTROUTING -j $chainname-POSTROUTING > delete-rule.sh
echo iptables -t nat -F $chainname-POSTROUTING >> delete-rule.sh
echo iptables -t nat -X $chainname-POSTROUTING >> delete-rule.sh

iptables -N $chainname-INPUT
iptables -A $chainname-INPUT  -i $BRIDGE -p tcp -m tcp --dport 67 -j ACCEPT 
iptables -A $chainname-INPUT  -i $BRIDGE -p udp -m udp --dport 67 -j ACCEPT 
iptables -A $chainname-INPUT  -i $BRIDGE -p tcp -m tcp --dport 53 -j ACCEPT 
iptables -A $chainname-INPUT  -i $BRIDGE -p udp -m udp --dport 53 -j ACCEPT 
iptables -A INPUT -j $chainname-INPUT

echo iptables -D INPUT -j $chainname-INPUT >> delete-rule.sh
echo iptables -F $chainname-INPUT >> delete-rule.sh
echo iptables -X $chainname-INPUT >> delete-rule.sh


iptables -N $chainname-FORWARD
iptables -A $chainname-FORWARD -i $1 -o $1 -j ACCEPT 
iptables -A $chainname-FORWARD -s $NETWORK/$NETMASK -i $BRIDGE -j ACCEPT 
iptables -A $chainname-FORWARD -d $NETWORK/$NETMASK -o $BRIDGE -m state --state RELATED,ESTABLISHED -j ACCEPT 
iptables -A $chainname-FORWARD -o $BRIDGE -j REJECT --reject-with icmp-port-unreachable 
iptables -A $chainname-FORWARD -i $BRIDGE -j REJECT --reject-with icmp-port-unreachable 
iptables -A FORWARD -j $chainname-FORWARD

echo iptables -D FORWARD -j $chainname-FORWARD >> delete-rule.sh
echo iptables -F $chainname-FORWARD >> delete-rule.sh
echo iptables -X $chainname-FORWARD >> delete-rule.sh



}

start_dnsmasq() {
    do_dnsmasq \
	--strict-order \
	--except-interface=lo \
	--interface=$BRIDGE \
	--listen-address=$GATEWAY \
	--bind-interfaces \
	--dhcp-range=$DHCPRANGE \
	--conf-file="" \
	--pid-file=$(pwd)/dnsmasq.pid \
	--dhcp-leasefile=$(pwd)/dnsmasq.leases \
	--dhcp-no-override \
	${TFTPROOT:+"--enable-tftp"} \
	${TFTPROOT:+"--tftp-root=$TFTPROOT"} \
	${BOOTP:+"--dhcp-boot=$BOOTP"}
	echo "kill -9 \$(cat dnsmasq.pid)" >> delete-switch.sh
}

setup_bridge_nat() {
    if check_bridge "$1" ; then
	create_bridge "$1"
	enable_ip_forward
	add_filter_rules "$1"
	start_dnsmasq "$1"
    fi
}

setup_bridge_nat_ovs() {
    if check_bridge "$1" ; then
	create_bridge_ovs "$1"
	enable_ip_forward
	add_filter_rules "$1"
	start_dnsmasq "$1"
    fi
}

setup_bridge_vlan() {
    if check_bridge "$1" ; then
	create_bridge "$1"
	start_dnsmasq "$1"
    fi
}


generate_setup_vm_image(){
cat <<EOF >user-data.cfg
#cloud-config
instance-id: $PROJECT-$VMNAME
local-hostname: $PROJECT-$VMNAME
hostname: $PROJECT-$VMNAME
manage_etc_hosts: false
ssh_pwauth: true
disable_root: false
users:
  - default
  - name: ubuntu
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
chpasswd:
  list: |
    root:password
    ubuntu:myubuntu
  expire: false
bootcmd:
- uuidgen | md5sum | cut -d" " -f1 > /etc/machine-id
EOF

cat <<EOF >network-config.cfg
version: 2
ethernets:
    ens3:
      dhcp4: false
      gateway4: 192.168.0.1
      addresses:
      - 192.168.0.100/24
      nameservers:
          search: [its.ac.id]
          addresses: [8.8.8.8] 
EOF
   	
}

update_vm_image(){
	set -x
	IMAGENAME=$(pwd)/../../../images/cloudimg.img
	NAMA=$(basename $IMAGENAME)
	ln -s $IMAGENAME $NAMA
	
	#setup disk image
	rm -f $NAMA.qcow2
	rm -f cloud-init.iso


	qemu-img convert -f qcow2 -O qcow2 $NAMA $NAMA.qcow2
	qemu-img resize $NAMA.qcow2 $VMSIZE
	qemu-img info $NAMA.qcow2


	#setup data
	rm -f cloud-init.iso
	#jika ingin menggunakan static IP
	#harus menjalankan generate_network_config
	#cloud-localds -v -m local --network-config=network-config.cfg cloud-init.iso user-data.cfg 

	#menggunakan dynamic IP address via DHCP
	cloud-localds -v -m local cloud-init.iso user-data.cfg 

	#hapus config
	#rm -f user-data.cfg network-config.cfg
}

generate_start_vm(){
   set -x

   
   VMNAME=$(basename $(pwd))
   rm -f net-up.sh
   rm -f net-down.sh
   ln -s ../$BRIDGE/up.sh net-up.sh
   ln -s ../$BRIDGE/down.sh net-down.sh
   chmod +x ../$BRIDGE/up.sh
   chmod +x ../$BRIDGE/down.sh

   cat <<EOF >start.sh 
        if [ -f "firsttime" ]; then echo "harap cek dulu di file .settings\nlalu jalankan sh update.sh"; exit 1; else echo "ok";fi
	. ./.settings.json
	. \$(pwd)/../../../program/util.sh
	qemu-system-x86_64 \\
        -daemonize  \\
        -enable-kvm \\
        -name $VMNAME \\
        -m $VMMEMORY \\
        -smp $VMCPU \\
        -drive file=cloudimg.img.qcow2,if=virtio \\
        -drive file=cloud-init.iso,media=cdrom,if=virtio \\
        -monitor telnet:0.0.0.0:$MONITORPORT,server,nowait,nodelay \\
        -serial telnet:0.0.0.0:$SERIALPORT,server,nowait,nodelay \\
        -vnc :$VNCPORT \\
        -netdev tap,id=interface0,ifname=$VMNAME-tap0,script=net-up.sh,downscript=net-down.sh \\
        -device virtio-net-pci,netdev=interface0,mac=$MACADDRESS \\
        -pidfile $VMNAME.pid 
EOF
}

#setup_bridge_nat "$BRIDGE"

#if test "$1" ; then
#    do_ifconfig "$1" 0.0.0.0 up
#    do_brctl addif "$BRIDGE" "$1"
#fi
