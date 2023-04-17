FROM ubuntu:jammy

USER root
RUN apt -y update && \
    apt install -y openvswitch-switch openvswitch-common \
	ovn-common ovn-host ovn-central ovn-controller-vtep ovn-docker ovn-ic \
	vim iproute2 iptables \
	qemu-system cloud-utils curl \
	libvirt-daemon libvirt-clients 

CMD ["/bin/sh","-c","while true;do sleep 1000;done"]
