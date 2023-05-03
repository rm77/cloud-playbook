fname=.switch.json
part=sw

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
NETWORK=192.168.53.0
NETMASK=255.255.255.0
GATEWAY=192.168.53.1
DHCPRANGE=192.168.53.2,192.168.53.254

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
    		do_ifconfig "\$1" 0.0.0.0 up
   		do_brctl addif "\$PROJECT-\$BRIDGE" "\$1"
		exit 0
	fi
EOF

cat > down.sh <<EOF
#!/bin/sh

set -x
        . ./.settings.json
	. $(pwd)/../../../program/util.sh
	if test "\$1" ; then
    		do_ifconfig "\$1" down
		ip tuntap del "\$1"
		exit 0
	fi
EOF

. ./.settings.json
. $(pwd)/../../../program/util.sh
setup_bridge_nat $BRIDGE



