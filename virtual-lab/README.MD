untuk menjalankan virtual-lab

requirements:
- docker, install dengan sudo apt install -y docker.io
- pastikan docker dapat berjalan dengan docker ps --all

menjalankan:
- sh run.sh, akan menjalankan container dengan nama vn1

menghentikan/menghapus:
- docker rm -f vn1, akan menghapus data virtualisasi yang telah dijalankan

masuk ke dalam environment:
- docker exec -ti vn1 /bin/bash
- setelah masuk, pindahlah ke direktori /tmp/scripts dengan cd /tmp/scripts
- membuat deployment virtual machine
  - jalankan libvirtd dengan sh setup-virt.sh
  - setup default network, akan digunakan sebagai network komunikasi antar virtual machine
    - cd 0-ovn
    - sh setup-network-bridge.sh
      akan muncul "Network network-tenant0 created from network-default.xml"
      network ini adalah virtual network dengan konfigurasi
      * network id: network-tenant0 (akan digunakan waktu pembuatan vm)
	mode : bridge
        - forward mode : NAT
        alokasi IP dengan dhcp dengan ketentuan
        - range 192.168.122.10 sd 100
        - alokasi static IP berdasarkan macaddress dari VM
          - 00:00:00:00:00:10 mendapat IP 192.168.122.3
          - 00:00:00:00:00:11 mendapat IP 192.168.122.4
  - setup virtual machine, ada di direktori 1-vm, cd 1-vm
    - terdapat direktori run-script yang berisikan
      * provision.sh, yang merupakan script untuk otomasi instalasi virtual machine menggunakan virt-install dan cloud-images
        akan dijalankan di masing-masing direktori vm
        beberapa detail dari file provison.sh
        - melakukan penentuan besar volume sebesar 5GB
    - untuk setup vm, akan digunakan ubuntu cloud images versi 22 (baca images.txt)
      cloud image merupakan distribusi linux yang memungkinkan konfigurasi dasar dilakukan di awal menggunakan 
      konfigurasi metadata yang terpisah
    - downloadlah dengan perintah
         wget -O cloudimg.img https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img
         akan menghasilkan file cloudimg.img, akan menjadi basis dari instalasi virtual machine
    - akan dibuat 2 buah vm, yaitu
      - nama instance vm0, dengan macaddress 00:00:00:00:00:10, berada di vm0, diakses dengan vnc di port 5900
      - nama instance vm1, dengan macaddress 00:00:00:00:00:11, berada di vm1, diakses dengan vnc di port 5901
      - untuk melakukan provisioning, dimasing-masing direktori perlu ada file cloudimg.img yang merupakan installer dari ubuntu cloud-image
        tidak perlu dicopy, gunakan perintah ln dari file cloudimg.img di direktori atasnya
           ln -s ../cloudimg.img .
      - jalankan provisioning vm dengan sh install-config.sh
        tunggu beberapa saat
    
    

