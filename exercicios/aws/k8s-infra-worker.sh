#!/bin/bash
curl https://releases.rancher.com/install-docker/19.03.sh | sh
sudo docker run -d --privileged --restart=unless-stopped --net=host -v /etc/kubernetes:/etc/kubernetes -v /var/run:/var/run  rancher/rancher-agent:v2.6.9 --server https://18.116.63.35 --token v52vnlrxxjqfq5szqwfgft95z6zlpn8qnxldqwbw25lbkskk59d9r4 --ca-checksum 245727f1a124ad38447e3c1ea77db3ea4f70629f66d5906c41cf3b24317ca8fc --worker   