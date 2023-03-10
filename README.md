# 42-Inception-of-things

This is an introductory project that teaches how to use an orchestration tool called [Kubernetes](https://kubernetes.io/) to better understand how to scale and manage a cluster of servers. It is part of the [42 Paris](https://www.42.fr/) program.

Using [Vagrant](https://www.vagrantup.com/) and [Virtualbox](https://www.virtualbox.org/), we'll create virtual environments with different configurations to tinker with Kubernetes.

## 📑 Breakdown

| Part | Description |
| :-: | :-: |
| [1](./p1/README.md) | Install [k3s](https://k3s.io/) and create a server/worker cluster. |
| [2](./p2/README.md) | Create a cluster with multiple web applications |
| [3](./p3/README.md) | CI/CD Pipeline using [k3d](https://k3d.io/v5.4.7/) and [argoCD](https://argo-cd.readthedocs.io/en/stable/)|

## :books: Resources

### Kubernetes

- [k3s](https://k3s.io/)
- [k3s flags documentation](https://www.rancher.co.jp/docs/k3s/latest/en/installation/)
- [k3s configuration](https://docs.k3s.io/installation/configuration)
- [k3s networking](https://docs.k3s.io/installation/requirements#networking)
- [k3d](https://k3d.io/v5.4.7/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/)
- [Pods](https://kubernetes.io/docs/concepts/workloads/pods/pod/)
- [Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Ingresses](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Replica sets](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)

### Docker

- [Installation](https://docs.docker.com/engine/install/ubuntu/)
- [Post-installation](https://docs.docker.com/engine/install/linux-postinstall/)

### Virtualization

- [Virtualbox](https://www.virtualbox.org/)
- [Virtualbox Guest Additions installation](https://www.youtube.com/watch?v=w4E1iqsn_wA&ab_channel=tanzTalks.tech)
- [Enable nested virtualization](https://forums.virtualbox.org/viewtopic.php?t=90831)
- [Vagrant](https://www.vagrantup.com/)
- [Vagrantfile](https://www.vagrantup.com/docs/vagrantfile/)

*Made in collaboration with [@taiwing](https://github.com/Taiwing)*
