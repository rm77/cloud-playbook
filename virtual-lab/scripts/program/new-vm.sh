fname=.vm.json
part=vm

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

VMNAME=$part$current
BRIDGE=sw0
MACADDRESS=00:00:00:12:34:56
MONITORPORT=34001
SERIALPORT=34000
VNCPORT=4
VMSIZE="3G"
VMMEMORY=2048
VMCPU=2

echo 'PROJECT='$project > .settings.json
echo 'BRIDGE='$BRIDGE >> .settings.json
echo 'VMNAME='$VMNAME >> .settings.json
echo 'VMSIZE='$VMSIZE >> .settings.json
echo 'VMMEMORY='$VMMEMORY >> .settings.json
echo 'VMCPU='$VMCPU >> .settings.json
echo 'MACADDRESS='$MACADDRESS >> .settings.json
echo 'MONITORPORT='$MONITORPORT >> .settings.json
echo 'SERIALPORT='$SERIALPORT >> .settings.json
echo 'VNCPORT='$VNCPORT >> .settings.json
echo 'export PROJECT VMNAME BRIDGE MACADDRESS MONITORPORT SERIALPORT VNCPORT ' >> .settings.json



. ./.settings.json
. $(pwd)/../../../program/util.sh

generate_setup_vm_image 
touch firsttime
#update_vm_image
generate_start_vm

cat > stop.sh <<EOF
	. ./.settings.json
	kill -9 \$(cat $VMNAME.pid)
EOF

cat > update.sh <<EOF
	. ./.settings.json
	. \$(pwd)/../../../program/util.sh
	update_vm_image
	rm -f firsttime
	generate_start_vm
EOF