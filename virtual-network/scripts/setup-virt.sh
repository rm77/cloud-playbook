libvirtd -d
virtlogd -d
mkdir -p /var/lib/libvirt/boot
ip link delete myvirbr0 type bridge
cat <<EOF >network-default.xml
<network>
    <name>mydefault</name> 
    <forward mode='nat'> 
        <nat> 
            <port start='1024' end='65535'/> 
        </nat>
    </forward>
    <bridge name='myvirbr0'  macTableManager='libvirt' delay='0'/> 
    <ip address='192.168.122.1' netmask='255.255.255.0'> 
        <dhcp> 
            <range start='192.168.122.2' end='192.168.122.254'/> 
        </dhcp> 
    </ip>    
</network>
EOF
virsh net-create network-default.xml
rm -f network-default.xml
