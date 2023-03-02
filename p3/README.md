# Part 3

The goal here is to create a cluster with [k3d](https://k3d.io/v5.4.7/) in which [argoCD](https://argo-cd.readthedocs.io/en/stable/) will watch some git repository and deploy a new version when modifications are registered.

## 💻 Installation

In order to use `k3d` we need to install [docker](https://docs.docker.com/engine/install/ubuntu/) and [kubectl](https://kubernetes.io/docs/reference/kubectl/) beforehand. The script for this step can be found [here](./scripts/install-dependencies.sh).
