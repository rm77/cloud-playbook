docker rm -f vn1
sudo rm -f ovsdata/*
sudo rm -f ovndata/*
docker run -d --name vn1 \
	--restart=always \
	--network="host" \
	--privileged \
	--cap-add=ALL \
	--cap-add SYS_RAWIO \
	--device /dev/mem:/dev/mem \
	--device /dev/kvm:/dev/kvm \
	-v $(pwd)/scripts/:/tmp/scripts/ \
	-v $(pwd)/ovsdata:/var/run/openvswitch/ \
	-v $(pwd)/ovndata:/var/run/ovn/ \
	-v $(pwd)/inst/:/etc/faucet/ \
	-v $(pwd)/inst/:/var/log/faucet/ \
	-v /sys/fs/cgroup:/sys/fs/cgroup:rw \
	-v /dev/kvm:/dev/kvm \
	-p 5900:6000 \
	-p 6653:6653 \
	-p 9302:9302 \
	royyana/vmdev:1.00

docker exec -ti vn1 /bin/bash


