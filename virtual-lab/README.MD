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


    

