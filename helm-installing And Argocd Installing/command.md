### Install helm
```
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```


### Install Argocd (Node you have to make its type NodePort form kubernetes dashbord service)
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
### Get argocd secret and you know default username is admin
`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`



### In Production there may be ingress issue 
https://github.com/argoproj/argo-cd/issues/2953


use this lines
spec:
  containers:
  - command:
    - argocd-server
    - --staticassets
    - /shared/app
    - --insecure





