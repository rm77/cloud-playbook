BRIDGENAME=tenant0

ip link delete $BRIDGENAME type bridge
cat <<EOF >network-default.xml
<network>
    <name>network-$BRIDGENAME</name> 
    <forward mode='nat'> 
        <nat> 
            <port start='1024' end='65535'/> 
        </nat>
    </forward>
    <bridge name='$BRIDGENAME'  macTableManager='libvirt' /> 
    <ip address='192.168.122.1' netmask='255.255.255.0'> 
        <dhcp> 
            <range start='192.168.122.10' end='192.168.122.100'/> 
	    <host mac="00:00:00:00:00:10" ip="192.168.122.3" />
	    <host mac="00:00:00:00:00:11" ip="192.168.122.4" />
        </dhcp> 
    </ip>    
</network>
EOF
virsh net-create network-default.xml
rm -f network-default.xml
