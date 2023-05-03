docker rm -f vn1
sudo aa-teardown
sudo rm -f ovsdata/*
sudo rm -f ovndata/*
docker run -d --name vn1 \
	--restart=always \
	--network="host" \
	--privileged \
	--cap-add=ALL \
	--cap-add=SYS_RAWIO \
	--device /dev/mem:/dev/mem \
	--device /dev/kvm:/dev/kvm \
	--device /dev/shm:/dev/shm \
	--device /dev/pts:/dev/pts \
	--mount type=tmpfs,destination=/run \
	--mount type=tmpfs,destination=/var/run/openvswitch \
	--mount type=tmpfs,destination=/var/run/ovn \
	-v /var/run/docker.sock:/var/run/docker.sock:rw \
	-v $(pwd)/scripts/:/tmp/scripts/ \
	-v /sys/fs/cgroup:/sys/fs/cgroup:rw \
	-v /dev/kvm:/dev/kvm \
	-v /dev/shm:/dev/shm \
	-v /dev/pts:/dev/pts \
	-p 20000:25000 \
	-p 5900:6000 \
	-p 6653:6653 \
	-p 9302:9302 \
	--env-file ./settings.env \
	royyana/vmdev:1.00

#docker exec -ti vn1 /bin/bash
#-v $(pwd)/ovsdata:/var/run/openvswitch/ \
#-v $(pwd)/ovndata:/var/run/ovn/ \
#--security-opt apparmor=unconfined \

