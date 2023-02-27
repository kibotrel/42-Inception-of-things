# Part 2

The goal here is to create a cluster with 3 applications with one of them having 3 replicas.

## 📄 Vagrantfile

It's basically the same as the one from the previous part, except we only need the server, you can find it [here](./Vagrantfile).

## 💻 Provisioning script

Same as the previous part's server script, except that this time, we need to apply some configuration to create, deploy and expose the applications using `kubectl`.

```bash
kubectl apply -f /path/to/config.yaml
```

> ℹ️ The configuration files are located in [apps](./apps) directory and will be explained in the next section.

Full script available [here](./scripts/k3s-server.sh).

## 📦 Configuration files

As mentioned in the previous section, we need to create, deploy and expose the applications. Kubernetes uses YAML files to do so and have a specific syntax that starts with the following:

```yaml
apiVersion: name-of-the-used-api/version
kind: type-of-resource
```

To reach our goal we need to create 3 configuration files: one for [services](https://kubernetes.io/docs/concepts/services-networking/service/), another for [deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) and the last one for [ingresses](https://kubernetes.io/docs/concepts/services-networking/ingress/).

### Services

This first one is used to explain how Kubernetes should expose an application as a network service. We'll use the following type:

```yaml
apiVersion: v1
kind: Service
```

Then we need to specify the name of the service...

```yaml
metadata:
  name: name-of-the-service
```

> ℹ️ This name will help us to identify ther service easier and see how it interacts with other resources within the cluster.

And finally, the actual service configuration:

```yaml
spec:
  selector:
    app: name-of-the-application
  ports:
    - protocol: TCP
      port: 80
      targetPort: XXXX
```

> ℹ️ In this case, the created service will expose any [pod](https://kubernetes.io/docs/concepts/workloads/pods/pod/) that has the label `app: name-of-the-application` on port `80` and redirect the traffic to the port `XXXX` of this pod so that the application running on it can handle it.

Since we have 3 applications, we need 3 services, you can find the full configuration file [here](./apps/services.yml).

### Deployments

We previously created services but we still need to create the pods that will run the applications with the correct labels. We'll use the following type:

```yaml
apiVersion: apps/v1
kind: Deployment
```

Then we need to specify some metadata once again...

```yaml
metadata:
  name: name-of-the-deployment
  labels:
    app: name-of-the-application
```

> ℹ️ `metadata.name` is used for multiple purposes, one of them is to identify the deployment easier and it will be the base name for the [pods](https://kubernetes.io/docs/concepts/workloads/pods/pod/) and [replica sets](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/) created. `metadata.labels` is used to identify the pods created by this deployment. Here specified for the previously created services.

Then the actual deployment configuration:

```yaml
spec:
  replicas: X
  selector:
    matchLabels:
      app: name-of-the-application
```

> ℹ️ `spec.replicas` is used to specify how many replicas of the following pod should be created and `spec.selector` is used to tell Kubernetes which [pods](https://kubernetes.io/docs/concepts/workloads/pods/pod/) should be part of this [replica set](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/).

And finally, the pod configuration itself:

```yaml
template:
    metadata:
      labels:
        app: name-of-the-application
    spec:
      containers:
      - name: name-of-the-application
        image: image-name:tag
        ports:
        - containerPort: XXXX
```

> ℹ️ Here `template.labels.app` is used to identify the pod itself so that it can we later referenced like in order to put it in a [replica set](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/). Another important thing to mention is that `template.spec.containers.port.containerPort` is used to specify the port that the application is listening on. It **MUST** match the `ports.targetPort` of the related service so that the traffic can be redirected correctly.

Full configuration file available [here](./apps/deployments.yml).

### Ingresses

The last configuration file is used to expose the applications to the outside world. We'll use the following type:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
```

Then we need to specify some metadata once again...

```yaml
metadata:
  name: name-of-the-ingress
```

> ℹ️ This name main purpose is to identify the ingress easier.

And finally, the actual ingress configuration. Since we need to expose 3 services and that the configuration is the same for all of them, we'll only show the configuration for one:

```yaml
spec:
  rules:
  - host: hostname.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: name-of-the-service
            port:
              number: XXXX
```

> ℹ️ There's a lot going on here. To expose service we need to specify some rules. In our case the desired behaviour is to expose the service on the root path of the domain `hostname.com`. on port `XXXX`.  If we then send a request that matches this rule, Kubernetes will redirect the traffic to the service `name-of-the-service` on the right port since we configured it correcty.

Full configuration file available [here](./apps/ingress.yml).