NAMA=cloudimg.img
VNC=0
MONITOR=45000
INSTANCE=vm01
MACADDRESS=00:00:00:00:00:11


#setup disk image

rm -f $NAMA.qcow2
rm -f cloud-init.iso
qemu-img convert -f qcow2 -O qcow2 $NAMA $NAMA.qcow2
qemu-img resize $NAMA.qcow2 5G
qemu-img info $NAMA.qcow2


cat <<EOF >./cloud-init.cfg
#cloud-config
instance-id: vm01
local-hostname: vm01
hostname: vm01
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
EOF

cat <<EOF >./network-config.cfg
version: 2
ethernets:
    ens3:
      dhcp4:true
      match:
        macaddress: '52:54:00:12:34:56'
      set-name: ens3
EOF

cat <<EOF >./network-config-2.cfg
version: 2
ethernets:
    ens4:
      addresses:
      - 192.168.0.100/24
      routes:
      - to: default
        via: 192.168.0.1
      nameservers:
          search: [*.its.ac.id]
          addresses: [8.8.8.8] 
EOF

#setup data
rm -f cloud-init.iso
cloud-localds -v --network-config=network-config-2.cfg cloud-init.iso cloud-init.cfg 
#cloud-localds cloud-init.iso cloud-init.cfg 


#run vm
 qemu-system-x86_64   \
    -pidfile $INSTANCE.pid \
    -daemonize  \
    -net nic          \
    -net user         \
    -machine accel=kvm:tcg \
    -cpu host              \
    -smp 2                 \
    -m 512                 \
    -vnc :$VNC                \
    -monitor telnet:0.0.0.0:$MONITOR,server,nowait,nodelay \
    -cdrom cloud-init.iso \
    -hda $NAMA.qcow2 \
    -device virtio-net-pci,netdev=net0,mac=$MACADDRESS \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 
