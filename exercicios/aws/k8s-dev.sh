#!/bin/bash
curl https://releases.rancher.com/install-docker/20.10.sh | sh
net.bridge.bridge-nf-call-iptables=1
sudo docker run -d --privileged --restart=unless-stopped --net=host -v /etc/kubernetes:/etc/kubernetes -v /var/run:/var/run  rancher/rancher-agent:v2.6.9 --server https://18.222.161.125 --token msf825xncxz2mtwk8qcnssjhb8tk8xnr7w6xqrmmhdwfk8rm8vljjh --ca-checksum 6bd29e8b9863e1a433b2133cc8a5cffaa506329d82f36fee7d9f4ff4bf0d265d --etcd --controlplane --worker