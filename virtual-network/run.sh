docker rm -f vn1
sudo rm -f ovsdata/*
sudo rm -f ovndata/*
docker run -d --name vn1 --restart=always \
	--network="host" --privileged --cap-add=ALL --device /dev/mem:/dev/mem --device /dev/kvm:/dev/kvm --cap-add SYS_RAWIO \
	-v $(pwd)/scripts/:/tmp/scripts/ \
	-v $(pwd)/ovsdata:/var/run/openvswitch/ \
	-v $(pwd)/ovndata:/var/run/ovn/ \
	-v $(pwd)/inst/:/etc/faucet/ \
	-v $(pwd)/inst/:/var/log/faucet/ \
	-v /dev/kvm:/dev/kvm \
	-p 5900:6000 \
	-p 6653:6653 -p 9302:9302 vmdev

docker exec -ti vn1 /bin/bash


