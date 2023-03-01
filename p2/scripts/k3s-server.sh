#!/bin/bash

apk add curl
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san $(hostname) --node-ip $1 --bind-address=$1" sh -s -
sleep 15
kubectl apply -f /vagrant/apps/services.yml
sleep 5
kubectl apply -f /vagrant/apps/deployments.yml
sleep 5
kubectl apply -f /vagrant/apps/ingress.yml
sleep 5