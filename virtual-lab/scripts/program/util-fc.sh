#!/bin/sh
ximages=/tmp/scripts/images
UBUNTU_VERSION=bionic
IMAGE_ROOTFS=$ximages/$UBUNTU_VERSION/$UBUNTU_VERSION.rootfs
KERNEL_IMAGE=$ximages/$UBUNTU_VERSION/$UBUNTU_VERSION.vmlinux
INITRD=$ximages/$UBUNTU_VERSION/$UBUNTU_VERSION.initrd
image_tar=$UBUNTU_VERSION-server-cloudimg-amd64-root.tar.xz
kernel=$UBUNTU_VERSION-server-cloudimg-amd64-vmlinuz-generic
initrd=$UBUNTU_VERSION-server-cloudimg-amd64-initrd-generic
RANDOM1=$(date +%s)
RANDOM2=$(date +%s)
export ximages UBUNTU_VERSION IMAGE_ROOTFS KERNEL_IMAGE INITRD image_tar kernel initrd

curl_args() {
	curl --unix-socket $socket \
		-H 'Accept: application/json'	\
		-H 'Content-Type: application/json'	\
		$*
}

firecracker_http_file() {
	curl_args -X $1 'http://localhost/'$2 --data-binary "@"$3
}



download() {
	echo "Downloading $2..."

	curl -s -o $1 $2
}

download_if_not_present() {
	[ -f $1 ] || download $1 $2
}

generate_image() {
	set -x
	local imgsize=$1
	local localrootfs=$2
	echo "Generating $localrootfs..."
	rm -f $localrootfs 
	#cloud-localds -v -m local $localrootfs user-data.cfg
	cloud-localds -v -m local cloud-init.iso user-data.cfg

	truncate -s $imgsize $localrootfs
	#dd if=/dev/zero of=$localrootfs bs=100M count=30
	#mkfs.ext4 $localrootfs > /dev/null 2>&1
	mkfs.ext4 $localrootfs 

	local tmppath=/tmp/.$RANDOM1-$RANDOM2
	mkdir -p $tmppath
	mount $localrootfs -o loop $tmppath
	tar -xf $ximages/$UBUNTU_VERSION/download/$image_tar --directory $tmppath
	umount $tmppath
	rmdir $tmppath
}

extract_vmlinux() {
	echo "Extracting vmlinux to $KERNEL_IMAGE..."

	local extract_linux=/tmp/.$RANDOM2-$RANDOM1
	curl -s -o $extract_linux https://raw.githubusercontent.com/torvalds/linux/master/scripts/extract-vmlinux
	chmod +x $extract_linux
	$extract_linux $ximages/$UBUNTU_VERSION/download/$kernel > $KERNEL_IMAGE
	rm $extract_linux
}


generate_setup_vm_image(){

# Download components
mkdir -p $ximages/$UBUNTU_VERSION/download

download_if_not_present \
	$ximages/$UBUNTU_VERSION/download/$image_tar \
	https://cloud-images.ubuntu.com/$UBUNTU_VERSION/current/$image_tar

download_if_not_present \
	$ximages/$UBUNTU_VERSION/download/$kernel \
	https://cloud-images.ubuntu.com/$UBUNTU_VERSION/current/unpacked/$kernel

download_if_not_present \
	$ximages/$UBUNTU_VERSION/download/$initrd \
	https://cloud-images.ubuntu.com/$UBUNTU_VERSION/current/unpacked/$initrd


# Generate image, kernel and link initrd
#[ -f $IMAGE_ROOTFS ] || generate_image $VMSIZE

[ -f $INITRD ] || ln -s download/$initrd $INITRD

[ -f $KERNEL_IMAGE ] || extract_vmlinux



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

cat > vmconfig.json <<EOF
{
  "boot-source": {
    "kernel_image_path": "$KERNEL_IMAGE",
    "boot_args": "console=ttyS0 reboot=k panic=1 pci=off",
    "initrd_path": "$INITRD"
  },
  "drives": [
    {
      "drive_id": "cloud-init",
      "path_on_host": "cloud-init.iso",
      "is_root_device": false,
      "partuuid": null,
      "is_read_only": false,
      "cache_type": "Unsafe",
      "io_engine": "Sync",
      "rate_limiter": null
    },
    {
      "drive_id": "rootfs",
      "path_on_host": "root.fs",
      "is_root_device": true,
      "partuuid": null,
      "is_read_only": false,
      "cache_type": "Unsafe",
      "io_engine": "Sync",
      "rate_limiter": null
    }
  ],
  "machine-config": {
    "vcpu_count": $VMCPU,
    "mem_size_mib": $VMMEMORY,
    "smt": false,
    "track_dirty_pages": false
  },
  "balloon": null,
  "network-interfaces": [
    {
      "iface_id": "1",
      "host_dev_name": "$VMNAME-tap0",
      "guest_mac": "$MACADDRESS",
      "rx_rate_limiter": null,
      "tx_rate_limiter": null
    }
  ],
  "vsock": null,
  "logger": null,
  "metrics": null,
  "mmds-config": null
}

EOF


}

update_vm_image(){
	set -x


	lokalrootfs=$(pwd)/root.fs
	cp $IMAGE_ROOTFS $lokalrootfs
	#[ -f $lokalrootfs ] || generate_image $VMSIZE $lokalrootfs
	generate_image $VMSIZE $lokalrootfs


	#ln -s $IMAGENAME $NAMA
	
	#setup disk image
	#rm -f $NAMA.qcow2
	#rm -f cloud-init.iso


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

#   cat <<EOF >start.sh 
#        if [ -f "firsttime" ]; then echo "harap cek dulu di file .settings\nlalu jalankan sh update.sh"; exit 1; else echo "ok";fi
#	. ./.settings.json
#	. \$(pwd)/../../../program/util.sh
#	qemu-system-x86_64 \\
#        -daemonize  \\
#        -enable-kvm \\
#        -name $VMNAME \\
#        -m $VMMEMORY \\
#        -smp $VMCPU \\
#        -drive file=cloudimg.img.qcow2,if=virtio \\
#        -drive file=cloud-init.iso,media=cdrom,if=virtio \\
#        -monitor telnet:0.0.0.0:$MONITORPORT,server,nowait,nodelay \\
#        -serial telnet:0.0.0.0:$SERIALPORT,server,nowait,nodelay \\
#        -vnc :$VNCPORT \\
#        -netdev tap,id=interface0,ifname=$VMNAME-tap0,script=net-up.sh,downscript=net-down.sh \\
#        -device virtio-net-pci,netdev=interface0,mac=$MACADDRESS \\
#        -pidfile $VMNAME.pid 
#EOF
#
#
	cat > start.sh <<EOF
        . ./.settings.json
        . \$(pwd)/../../../program/util-fc.sh




        socketfile=\$(pwd)/$VMNAME.socket
        logfile=\$(pwd)/$VMNAME.log
        configfile=$(pwd)/vmconfig.json
        FC=/usr/sbin/firecracker-v1.3.2-x86_64
	(
        	rm -f \$socketfile \$logfile
        	touch \$logfile
        	\$FC --api-sock \$socketfile --log-path \$logfile --config-file \$configfile --level Debug &> /dev/null &
        	pid=\$!
        	echo \$pid > $VMNAME.pid
        	echo firecracker started with pid \$pid
	)

	while [ ! -e \$sockerfile ]; do
		sleep 1s
	done
	
	sh ./net-up.sh $VMNAME-tap0
	

EOF
}

