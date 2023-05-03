FROM ubuntu:lunar

USER root
RUN mkdir -p /var/log/libvirt && \
    groupadd kvm && useradd libvirt-qemu && useradd libvirt-dnsmasq && \
    apt -y update && \
    apt install -y openvswitch-switch openvswitch-common \
	ovn-common ovn-host ovn-central ovn-controller-vtep ovn-docker ovn-ic \
	vim iproute2 iptables bridge-utils \
	qemu-system cloud-utils curl \
	libvirt-daemon libvirt-clients virtinst dnsmasq net-tools

CMD ["/bin/sh","-c","while true;do sleep 1000;done"]
#CMD ["/usr/sbin/libvirtd","-v"]
