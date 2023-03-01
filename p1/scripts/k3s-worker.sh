#!/bin/bash

apk add curl
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://$1:6443 --token-file /vagrant/node-token --node-ip=$2" sh -s -