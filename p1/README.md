# Part 1

The goal here is to install [k3s](https://k3s.io/) on two virtual machines, one server and one worker using [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/). For this, we'll need to create a Vagrantfile and provisioning scripts.

## 📄 Vagrantfile

The Vagrantfile is the configuration file for Vagrant. It contains the configuration for the virtual machines we want to create. First we'll need to set the version of Vagrant we want to use:

```ruby
Vagrant.configure("2") do |config|
  # ...
end
```

Then we'll need to define the virtual machines we want to create. We'll use the [generic/alpine317](https://app.vagrantup.com/generic/boxes/alpine317) box, which is an Alpine Linux 3.17 box.

```ruby
config.box = "generic/alpine317"
```

> ℹ️ In Vagrant's context, a box is a pre-built image that contains an operating system and some basic tools. It can be understood the same way as a [Docker image](https://docs.docker.com/engine/reference/commandline/images/).

We also need to deffine how virtual machines would be created, for this we'll use the [VirtualBox provider](https://www.vagrantup.com/docs/providers/virtualbox/).

```ruby
config.vm.provider "virtualbox" do |virtualbox|
  # ...
end
```

> ℹ️ In Vagrant's context, a provider is a plugin that allows Vagrant to interact with a hypervisor or a virtual machine manager in simple terms. For example, the VirtualBox provider allows Vagrant to interact with VirtualBox.

In this `virtualbox` block, we can define some properties of the subsequent virtual machines. For example, we can define maximum CPU and memory resources.

```ruby
virtualbox.memory = 1024
virtualbox.cpus = 1
```

> ℹ️ `memory` is expressed in MB and `cpus` is the number of virtual CPUs to assign to the virtual machine.

Then, all we need to do is to define the virtual machines we want to create.

```ruby
config.vm.define "server" do |server|
  # ...
end

config.vm.define "worker" do |worker|
  # ...
end
```

Each virtual machine properties are then defined in the corresponding block. In our case, we want to specify, IP addresses, hostnames and provisioning scripts as well as a synchronized folder.

It looks something like this for the server machine:

```ruby
server.vm.hostname = "server"
server.vm.network "private_network", ip: "XXX.XXX.XXX.XXX"
server.vm.synced_folder "source-path/on/host", "destination-path/on/guest"
server.vm.provision "shell", privileged: true, path: "./server-provision-script.sh"
```

> ℹ️ We need to create a private network between the two virtual machines to put them in the same k3s cluster. Also, specifying IP addresses instead of letting the DHCP server chose ease up configuration process. At last, for the provisioning script, we need to specify that it should be run as root, hence the `privileged: true` option (more on that later).

For the complete Vagrantfile, see [here](./Vagrantfile).

## 💻 Provisioning scripts

Provisioning scripts are ran when the virtual machine is created. They are used to install and configure initial software within the virtual machine's context.

### Server script

For this part, we'll use the [k3s install script](https://get.k3s.io/) to install k3s as a server and specify the IP address so that the worker can join the cluster.

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --node-ip $1 --bind-address=$1" sh -s -
```

> ℹ️ `INSTALL_K3S_EXEC` is a variable that can be used to pass flags to the k3s install script. Check [this](https://www.rancher.co.jp/docs/k3s/latest/en/installation/) to get more information. Here, `$1` is the server IP address we specified as script argument in the [Vagrantfile](./Vagrantfile).

Once k3s is installed, we need to retrieve the cluster token to allow the worker to join the cluster.

```bash
cp /var/lib/rancher/k3s/server/node-token /vagrant/.
```

> ℹ️ This is why we set up a synchronized folder. This way, we can retrieve the cluster token from the server machine and use it to join the cluster from the worker machine.

Full script available [here](./scripts/k3s-server.sh).

### Worker script

For this part, we'll use the [k3s install script](https://get.k3s.io/), once again, to install k3s as a worker and specify the IP address and the cluster token so that the worker can join the cluster we created on the server machine.

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://$1:6443 --token-file /vagrant/node-token --node-ip=$2" sh -s -
```

> ℹ️ Once more, check [this](https://www.rancher.co.jp/docs/k3s/latest/en/installation/) to get more information on the flags used in the `INSTALL_K3S_EXEC` variable.  Here, `$1` is the server IP address and `$2` is the worker IP address we specified as script arguments in the [Vagrantfile](./Vagrantfile).

Full script available [here](./scripts/k3s-worker.sh).