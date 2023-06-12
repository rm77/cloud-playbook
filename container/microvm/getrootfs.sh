#membutuhkan guestfs-tools
#sudo apt install -y guestfs-tools



DOCKERIMAGE=ubuntu:jammy
IMAGENAME=ubuntu_jammy
docker export $(docker run -d $DOCKERIMAGE) -o image.tar

sudo virt-make-fs --format=qcow2 --size=+200M image.tar image_large.qcow2
sudo qemu-img convert image_large.qcow2 -O qcow2 $IMAGENAME.qcow2
rm -f image_large.qcow2 image.tar


