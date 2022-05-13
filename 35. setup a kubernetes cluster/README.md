# Purpose
Here we manually deploy a kubernetes cluster ourselves. And deploy our app in that cluster.

# Pre Requisites
### In windows machine we may need to set the hypervisorlaunchtype to off
`bcdedit /set hypervisorlaunchtype off`

Then restart, **You might need to restart 2 times.
**Caution**: After doing this docker and WSL will stop working.

# Manual setup
## Setup vagrant (optional)
### Install vagrant using
[https://www.vagrantup.com/docs/installation](https://www.vagrantup.com/docs/installation)


## Setting up vagrant VMs
### Bring up all the necessary VMs
```
cd manual-setup/master-node-01
vagrant up
cd ../worker-node-01
vagrant up
cd ../worker-node-02
vagrant up
```

### If error
```
There was an error while executing `VBoxManage`, a CLI used by Vagrant
for controlling VirtualBox. The command and stderr is shown below
```
### vargrant ssh error or password not working error
`Please update vagrant and oracal vm and use ip range 192.168.56.4 Or 192.168.56.4`

### SSH into the vagrant boxes using 
`vagrant ssh`

## At first make sure that the worker node and master nodes can communicate
From master node

`ping <worker_node_ip>`

From worker nodes

`ping <master_node_ip>`

** You may need to enable ICMP traffic from the security group for aws ec2.


## Do this on both the worker and master nodes

### Disable swap
```
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```
### If you incresase or decrese ram or cpu after one vagrant file change then run `vagrant reload` and again run the above command

### Enable iptables bridged traffic
```
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```
### Install docker

```
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
```
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
```
### Enable docker cgroup
```
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
```
```
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker
```
## Install kubeadm, kubelet and kubectl

```
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
```
`echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list`

### if unable to AWS error - sudo: unable to resolve host ip-10-0-xx-xx then edit /etc/hosts

```
127.0.0.1 localhost
127.0.0.1 ip-xxx-xx-x-xx
```

```
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
```

### IF error Unable to locate package kubectl when installing the kubectl kubeadm for kubernetes installation then again do this
`
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
`


`sudo apt-mark hold kubelet kubeadm kubectl`

```
sudo apt install net-tools
```
## Do these in master node
<!-- IPADDR="10.10.10.100" -->
### See the ip address of eth0 using
`ifconfig`
set the ipv4 address as the `IPADDR`
### Setup environment variables for node setup
```
IPADDR="<master_node's_eth0's_ip>"
NODENAME=$(hostname -s)
```
### For vagrant only
NODENAME=master-node-01
IPADDR=10.10.12.94

```
IPADDR="192.168.56.5"
NODENAME=$(hostname -s)

```

```
IPADDR="192.168.56.5"
NODENAME=$(hostname -s)
```

<!-- ### (optional) In ec2 we may need to add the NODENAME in the hosts file
`sudo nano /etc/hosts` -->

`sudo kubeadm init --apiserver-advertise-address=$IPADDR  --apiserver-cert-extra-sans=$IPADDR  --pod-network-cidr=192.168.0.0/16 --node-name $NODENAME --ignore-preflight-errors Swap --v=5`
<!-- `curl -fsL https://raw.githubusercontent.com/minhaz1217/linux-configurations/master/bash/03.%20installing%20docker/install_docker.sh | bash -` -->

### If error (Unimplemented desc = unknown service runtime.v1alpha2.RuntimeService)
`sudo rm /etc/containerd/config.toml
 sudo systemctl restart containerd
`

### To use kubectl do this as normal user
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
or if this error occurs when trying any kubectl command `The connection to the server localhost:8080 was refused - did you specify the right host or port?`


### Create a token for worker nodes to connect
`sudo kubeadm token create --print-join-command`

## If anything bad happens during kubeadm init or join we can reset by using
```
sudo rm /etc/kubernetes/kubelet.conf
sudo rm -rf /etc/kubernetes/pki
sudo systemctl stop kubelet
```
`sudo kubeadm reset`

# Do these to setup the worker node
`NODENAME=$(hostname -s)`

### Copy the contents of `/etc/kubernetes/admin.conf` from the master machine to the worker machine
`sudo cat /etc/kubernetes/admin.conf`

# And copy that content to worker machine
`sudo nano /etc/kubernetes/admin.conf`

and paste


### (optional) check the hash of the admin.conf in both master and worker node to make sure that they are identical
`sudo sha256sum /etc/kubernetes/admin.conf`

### In the master node generate the string for joining
`kubeadm token create --print-join-command`
### Paste the join command in the worker node

### In the master node label the node as worker node
`kubectl label node worker-node-01 node-role.kubernetes.io/worker=worker`


### Now we should be able to see our worker node from the master node using
`kubectl get nodes`

![Nodes connected properly but status is not ready](https://raw.githubusercontent.com/minhaz1217/devops-notes/master/35.%20setup%20a%20kubernetes%20cluster/images/worker%20node%20is%20showing%20from%20master%20node.png)

The node status should be not ready.

### We can inspect that the nodes are having problem using
`kubectl describe nodes`

We'll notice that the error is **container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:docker: network plugin is not ready: cni config uninitialized**

### We can see the pods of the default kubernetes namespace using
`kubectl get pods -n kube-system`

We'll see that 2 coredns pods are showing status pending.

### To solve these we'll install a network plugin named Calico

## Setting up network plugin
There are many plugins 3 most popular are `flanel`, `calio` or `weave`

### Download the calico plugin
`curl https://projectcalico.docs.tigera.io/manifests/calico.yaml -O`

### Apply it
`kubectl apply -f calico.yaml`

If default configuration is changed we may need to follow calico plugin's installation guide

### Now if we get nodes we'll see status **Ready**
`kubectl get nodes`

### We can get kube system pods using
`kubectl get pods -n kube-system`


### For taint checks
`sudo apt install jq`
`kubectl get nodes -o json | jq '.items[].spec.taints'`
# Testing
### Paste these
`nano rc.yaml`
```
apiVersion: v1
kind: ReplicationController
metadata:
  name: microservice
spec:
  replicas: 3
  selector:
    app: microservice
  template:
    metadata:
      name: microservice
      labels:
        app: microservice
    spec:
      containers:
      - name: microservice
        image: minhaz1217/simple-dotnet
        ports:
        - containerPort: 80
```

### Create the replication controller using
`kubectl create -f rc.yaml`

### Make sure the pods are running using
`kubectl get pods`

![all pods are running](https://raw.githubusercontent.com/minhaz1217/devops-notes/master/35.%20setup%20a%20kubernetes%20cluster/images/kubernates%20cluster%20is%20up.png)

### We can see that the pods are running in our worker nodes using
`kubectl describe pods`

### Now access the kubernetes dashboard(first create the dashboard using this command)
`kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml
`
### You can check with below commands:
`kubectl get all -n kubernetes-dashboard`

### Now Create a Role 
`kubectl create -f  https://raw.githubusercontent.com/minhaz1217/devops-notes/master/22.%20kubernates%20dashboard/service-user.yaml
`
###Binding to access the dashboard
`
kubectl create -f https://raw.githubusercontent.com/minhaz1217/devops-notes/master/22.%20kubernates%20dashboard/cluster-role-binding.yaml`

### Make the dashboard service as NodePort
`kubectl --namespace kubernetes-dashboard patch svc kubernetes-dashboard -p '{"spec": {"type": "NodePort"}}'
`

## And now check your svc
`kubectl get svc -n kubernetes-dashboard`

### Go to firefox browser not chrome
## Now generate and save the token for further uses
`kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"`

### Now create a nodeport service to expose our pods using
`nano nodeport.yaml`
```
apiVersion: v1
kind: Service
metadata:
  name: nodeport-svc
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30123
  selector:
    app: microservice
```

### Create the nodeport using
`kubectl create -f nodeport.yaml`

### Curl to the external port using
`curl 10.10.10.100:30123`

![nodeport working](https://raw.githubusercontent.com/minhaz1217/devops-notes/master/35.%20setup%20a%20kubernetes%20cluster/images/exposing%20service%20with%20nodeport%20working.png)

![exposing via nodeport working](https://raw.githubusercontent.com/minhaz1217/devops-notes/master/35.%20setup%20a%20kubernetes%20cluster/images/cluster%20lb%20working%20using%20nodeport.png)

** Here we are exposing the cluster ip directly but in real scenario we'll use a load balancer in front of the cluster.

<!-- ```
for (($i = 0); $i -lt 10; $i++){ 
    curl.exe 10.10.10.100:30123
    "" 
}
``` -->


## Reference
[https://devopscube.com/setup-kubernetes-cluster-kubeadm/](https://devopscube.com/setup-kubernetes-cluster-kubeadm/)

[https://projectcalico.docs.tigera.io/getting-started/kubernetes/self-managed-onprem/onpremises](https://projectcalico.docs.tigera.io/getting-started/kubernetes/self-managed-onprem/onpremises)