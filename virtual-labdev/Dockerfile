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
    curl -Lo /usr/sbin/kind https://kind.sigs.k8s.io/dl/v0.18.0/kind-linux-amd64 && chmod +x /usr/sbin/kind && \
    curl -Lo /usr/sbin/kubectl https://dl.k8s.io/release/v1.27.1/bin/linux/amd64/kubectl && chmod +x /usr/sbin/kubectl && \
    curl -Lo /usr/sbin/k0sctl https://github.com/k0sproject/k0sctl/releases/download/v0.15.0/k0sctl-linux-x64 && \
         chmod +x /usr/sbin/k0sctl && \
    wget -O /tmp/helm.tar.gz https://get.helm.sh/helm-v3.12.0-rc.1-linux-amd64.tar.gz && \
         cd /tmp/ && tar -xzvf helm.tar.gz && mv linux-amd64/helm /usr/sbin/helm && \
         chmod +x /usr/sbin/helm && \
    wget -O octant.tar.gz https://github.com/vmware-archive/octant/releases/download/v0.25.1/octant_0.25.1_Linux-64bit.tar.gz && \
         cd /tmp/ && tar -xzvf octant.tar.gz && mv octant_0.25.1_Linux-64bit/octant /usr/sbin/octant && \
         chmod +x /usr/sbin/octant
RUN echo "deb [trusted=yes] https://apt.fury.io/netdevops/ /" | tee -a /etc/apt/sources.list.d/netdevops.list && apt -y update && apt install containerlab

CMD ["/bin/sh","-c","while true;do sleep 1000;done"]
