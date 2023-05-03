FROM ubuntu:lunar

USER root
RUN mkdir -p /var/log/libvirt && \
    groupadd kvm && useradd libvirt-qemu && useradd libvirt-dnsmasq && \
    apt -y update && \
    apt install -y openvswitch-switch openvswitch-common \
	ovn-common ovn-host ovn-central ovn-controller-vtep ovn-docker ovn-ic \
	vim iproute2 iptables bridge-utils \
	qemu-system cloud-utils curl \
	libvirt-daemon libvirt-clients virtinst dnsmasq net-tools docker.io iptraf-ng mc htop docker-compose
RUN curl -sSLf https://get.k0s.sh | sh && \
    curl -Lo /usr/sbin/kind https://kind.sigs.k8s.io/dl/v0.18.0/kind-linux-amd64 && chmod +x /usr/sbin/kind 

CMD ["/bin/sh","-c","while true;do sleep 1000;done"]
#CMD ["/usr/sbin/libvirtd","-v"]
