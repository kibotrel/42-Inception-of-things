#!/bin/bash

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
sudo k3d cluster create my-cluster -p 8080:80@loadbalancer -p 8443:443@loadbalancer -p 8888:8888@loadbalancer --k3s-arg "--disable=traefik@server:0" 

sudo kubectl create namespace argocd
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sudo kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

sudo kubectl -n argocd rollout status deployment argocd-server
sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

sudo kubectl apply -f install_app.yaml
