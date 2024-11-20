
## INSTALL

[Reference](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/#deploying-the-dashboard-ui)

###### Note: if you face any error like: E0506 02:07:33.677985   41062 memcache.go:265] couldn't get current server API group list: Get "http://localhost:8080/api?timeout=32s": dial tcp 127.0.0.1:8080: connect: connection refused. then run below command.

```
export KUBECONFIG=~/.kube/config

or

sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

```bash
kubectl create ns kubernetes-dashboard
```

```bash
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
```

```bash
helm repo update kubernetes-dashboard
```

```bash
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard -n kubernetes-dashboard
```


### creating user and bind role with this user.

[Reference](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md)

```bash
kubectl apply -f ./yaml/admin-user.yaml
```

```bash
kubectl apply -f ./yaml/cluster_role_binding.yaml
```

### expose dashboard in the external network

[Reference](https://www.kerno.io/learn/kubernetes-dashboard-deploy-visualize-cluster) Figure 6 Installation

```bash
helm upgrade kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard -f ./yaml/values.yaml -n kubernetes-dashboard
```

```bash
kubectl apply -f ./dashboard.ingress.yaml --namespace kubernetes-dashboard
```


### generate the token for accessing dashboard (user --duration)

```bash
kubectl get service -n kubernetes-dashboard
```

```bash
kubectl -n kubernetes-dashboard create token admin-user --duration=8760h
```

###### browse https://MASTER-NODE-IP:KONG-PROXY-PORT/ to access the dashboard.

## CLEAN UP
```bash
helm uninstall kubernetes-dashboard -n kubernetes-dashboard
```

```bash
kubectl delete -f ./yaml/admin-user.yaml
```

```bash
kubectl delete -f ./yaml/cluster_role_binding.yaml
```

```bash
kubectl delete -f ./dashboard.ingress.yaml --namespace kubernetes-dashboard
```

```bash
kubectl delete ns kubernetes-dashboard
```