#!/bin/bash

sudo k3d cluster create iot-kibotrel-yforeau -p 8080:80@loadbalancer -p 8443:443@loadbalancer -p 8888:8888@loadbalancer

sudo kubectl create namespace argocd
sudo kubectl create namespace dev

k3d kubeconfig get iot-kibotrel-yforeau > ~/.kube/config

sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

sudo kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

sudo kubectl -n argocd rollout status deployment argocd-server
sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

sudo kubectl apply -f ./apps/argocd.yaml -n argocd
