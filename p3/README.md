# Part 3

The goal here is to create a cluster with [k3d](https://k3d.io/v5.4.7/) in which [argoCD](https://argo-cd.readthedocs.io/en/stable/) will watch some git repository and deploy a new version when modifications are registered.

## 💻 Installation

In order to use `k3d` we need to install [docker](https://docs.docker.com/engine/install/ubuntu/) and [kubectl](https://kubernetes.io/docs/reference/kubectl/) beforehand. The script for this step can be found [here](./scripts/install-dependencies.sh).

## 📦 k3d Configuration

As requested in the specifications, we need to create a cluster with two namespaces:

- argocd: where argoCD will be installed
- dev: where the application we want to track and update will be deployed

```bash
sudo k3d cluster create iot-kibotrel-yforeau -p 8080:80@loadbalancer -p 8443:443@loadbalancer -p 8888:8888@loadbalancer
sudo kubectl create namespace argocd
sudo kubectl create namespace dev
```

> ℹ️ We create a k3d cluster called `iot-kibotrel-yforeau` with 3 ports exposed: **8080**, **8443** and **8888**. The first two are used to access the cluster and the last one is used by argoCD to communicate with the deployed app within the cluster.

Since we didn't install k3s, we need to export the kubeconfig file in order to use `kubectl`:

```bash
k3d kubeconfig get iot-kibotrel-yforeau > ~/.kube/config
```

> ℹ️ `~/.kube/config` is the default location for the kubeconfig file.

Then we setup argoCD using the [base manifest](https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml) and we tweak settings to enable loadbalancer.

```bash
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sudo kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

At this point, ArgoCD is correctly setup and all we need is to wait for the deployment in the cluster to be ready, then exctract the default password to login to the web interface at https://localhost:8080:

```bash
sudo kubectl -n argocd rollout status deployment argocd-server
sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

> ℹ️ According to the documentation, the default password to access the web interface as user `admin` is stored in the `argocd-initial-admin-secret` secret.

The full script can be found [here](./scripts/start-cluster.sh).

## 📦 ArgoCD Configuration

Now that we have a cluster with ArgoCD installed, we need to configure it to watch a git repository and deploy a new version when modifications are registered. It uses the same kind of configuration files as kubernetes. The type used here is:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
```

Then, we can specify some metadata about the application, the project it belongs to...

```yaml
metadata:
  name: playground-argocd
  namespace: argocd
```

And finally, how the application should be tracked and deployed by ArgoCD:

```yaml
spec:
  project: default
  source:
    repoURL: path/to/git/repository
    targetRevision: HEAD
    path: app
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
```

> ℹ️ `source` represent the git repository to watch, `destination` the namespace where the application should be deployed and `syncPolicy` the way ArgoCD should handle the deployment. In this case, it will automatically deploy a new version when modifications are registered in the git repository and it will prune the old version.

The full configuration file can be found [here](./apps/argocd.yaml).
