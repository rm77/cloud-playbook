NAMA=cloudimg.img
VNCPORT=5900
INSTANCE=vm0
MACADDRESS=00:00:00:00:00:10
TENANT=tenant0


#setup disk image
rm -f $NAMA.qcow2
rm -f cloud-init.iso

qemu-img convert -f qcow2 -O qcow2 $NAMA $NAMA.qcow2
qemu-img resize $NAMA.qcow2 5G
qemu-img info $NAMA.qcow2


cat <<EOF >./user-data.cfg
#cloud-config
instance-id: $INSTANCE
local-hostname: $INSTANCE
hostname: $INSTANCE
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

cat <<EOF >./network-config.cfg
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

#setup data
rm -f cloud-init.iso
#jika ingin menggunakan static IP
#cloud-localds -v -m local --network-config=network-config.cfg cloud-init.iso user-data.cfg 

#menggunakan dynamic IP address via DHCP
cloud-localds -v -m local cloud-init.iso user-data.cfg 

#hapus config
rm -f user-data.cfg network-config.cfg

#run vm
virsh destroy $INSTANCE
virsh undefine $INSTANCE
virt-install \
  --name $INSTANCE \
  --check all=off \
  --memory 1024 \
  --vcpus 2 \
  --graphics=vnc,listen=0.0.0.0,port=$VNCPORT \
  --os-variant detect=on \
  --import \
  --disk path=$NAMA.qcow2,bus=virtio,cache=none \
  --disk path=cloud-init.iso,device=cdrom \
  --network network=network-$TENANT,model=e1000,mac=$MACADDRESS \
  --console pty,target_type=virtio \
  --serial pty --noautoconsole 


