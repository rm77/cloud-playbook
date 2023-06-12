UBUNTUNAME=jammy
curl -L https://cloud-images.ubuntu.com/jammy/current/unpacked/$UBUNTUNAME-server-cloudimg-amd64-vmlinuz-generic -o vmlinuz
#dd if=vmlinuz bs=1 skip=24584 | zcat > vmlinux
#rm -f vmlinuz $UBUNTUNAME-server-cloudimg*
