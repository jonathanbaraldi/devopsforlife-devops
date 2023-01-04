#!/bin/bash
curl https://releases.rancher.com/install-docker/20.10.sh | sh
#net.bridge.bridge-nf-call-iptables=1
docker run -d --restart=unless-stopped \
  -p 80:80 -p 443:443 \
  --privileged \
  rancher/rancher:v2.6.9