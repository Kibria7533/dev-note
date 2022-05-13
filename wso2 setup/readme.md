`sudo apt-get install nfs-common`
kubectl patch pvc {PVC_NAME} -p '{"metadata":{"finalizers":null}}'

https://artifacthub.io/packages/helm/wso2/am-pattern-1