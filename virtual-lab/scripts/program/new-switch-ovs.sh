fname=.switch.json
part=swovs

if [ -e $fname ]
then
	current=$(cat $fname)
	b=$(($current+1))
	echo $b > $fname
	current=$(cat $fname)
else
	current=0
	echo $current > $fname
fi


project=$(basename $(pwd))

echo create $part $current on project $project

mkdir -p $part$current

cd $part$current

BRIDGE=$project-$part$current
NETWORK=192.168.52.0
NETMASK=255.255.255.0
GATEWAY=192.168.52.1
DHCPRANGE=192.168.52.2,192.168.52.254

echo 'PROJECT='$project > .settings.json 
echo 'BRIDGE='$BRIDGE >> .settings.json
echo 'NETWORK='$NETWORK >> .settings.json
echo 'NETMASK='$NETMASK >> .settings.json
echo 'GATEWAY='$GATEWAY >> .settings.json
echo 'DHCPRANGE='$DHCPRANGE >> .settings.json
echo 'export PROJECT BRIDGE NETWORK NETMASK GATEWAY DHCPRANGE' >> .settings.json


cat > up.sh <<EOF
#!/bin/sh

set -x
        . ./.settings.json
	. $(pwd)/../../../program/util.sh
	if test "\$1" ; then
    		#do_ifconfig "\$1" 0.0.0.0 up
		ip link set "\$1" up
   		ovs-vsctl add-port "\$PROJECT-\$BRIDGE" "\$1"
		exit 0
	fi
EOF

cat > down.sh <<EOF
#!/bin/sh

set -x
        . ./.settings.json
	. $(pwd)/../../../program/util.sh
	if test "\$1" ; then
    		#do_ifconfig "\$1" 0.0.0.0 up
		ip addr flush dev "\$1"
		ip link set "\$1" down
   		ovs-vsctl del-port "\$PROJECT-\$BRIDGE" "\$1"
		exit 0
	fi
EOF

. ./.settings.json
. $(pwd)/../../../program/util.sh
setup_bridge_nat_ovs $BRIDGE



