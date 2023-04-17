FROM ubuntu:jammy

USER root
RUN mkdir -p /var/log/libvirt && \
    groupadd kvm && useradd libvirt-qemu && \
    apt -y update && \
    apt install -y openvswitch-switch openvswitch-common \
	ovn-common ovn-host ovn-central ovn-controller-vtep ovn-docker ovn-ic \
	vim iproute2 iptables \
	qemu-system cloud-utils curl \
	libvirt-daemon libvirt-clients virtinst

CMD ["/bin/sh","-c","while true;do sleep 1000;done"]
