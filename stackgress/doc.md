## Install Stackgres Operator (Postgres Database) And Monitoring On k3s
---

# Prerequisites
- Existing K3s Cluster
- Helm installed
- Minio Installed

Steps:
- Install monitoring using `kube-prometheus-stack`
- Install stackgres-operator
- Create a Object Storage With minio
- Create Database with Backup config
- Take Backup(Full Backup)
- Resotre from backup

## To install monitoring
```helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add stable https://charts.helm.sh/stable
helm repo update

helm install --create-namespace --namespace monitoring \
 --set grafana.enabled=true \
 prometheus prometheus-community/kube-prometheus-stack

```

# To install stackgres

```helm repo add stackgres-charts https://stackgres.io/downloads/stackgres-k8s/stackgres/helm/

helm install --create-namespace --namespace stackgres stackgres-operator \
 --set grafana.autoEmbed=true \
 --set-string grafana.webHost=prometheus-grafana.monitoring \
 --set-string grafana.secretNamespace=monitoring \
 --set-string grafana.secretName=prometheus-grafana \
 --set-string grafana.secretUserKey=admin-user \
 --set-string grafana.secretPasswordKey=admin-password \
 --set-string adminui.service.type=NodePort \
 stackgres-charts/stackgres-operator
```


# To access stackgres UI

```kubectl get secret -n stackgres stackgres-restapi-admin --template '{{ printf "username = %s\n" (.data.k8sUsername | base64decode) }}'
kubectl get secret -n stackgres stackgres-restapi-admin --template '{{ printf "password = %s\n" (.data.clearPassword | base64decode) }}'
```

# To Create a Cluster with Db Backup

```
apiVersion: stackgres.io/v1
kind: SGCluster
metadata:
  name: demo
  namespace: demo
spec:
  postgres:
    version: '16'
  instances: 1
  pods:
    persistentVolume:
      size: '1Mi'
      storageClass: nfs-client
  configurations:
    backups:
    - sgObjectStorage: minio
      retention: 10
      cronSchedule: "*/15 * * * *"
      compression: lz4
  nonProductionOptions:
    disableClusterPodAntiAffinity: true
```

# To access db
```
kubectl -n demo get secret demo --template '{{ printf "%s" (index .data "superuser-password" | base64decode) }}'
```


# To restore from backup

Create a Instance profile first

```apiVersion: stackgres.io/v1
kind: SGInstanceProfile
metadata:
  namespace: demo
  name: size-s
spec:
  cpu: "500m"
  memory: "256Mi"
```

# Create a backup db now

```
apiVersion: stackgres.io/v1
kind: SGCluster
metadata:
  name: demo-restore
  namespace: demo
spec:
  instances: 1
  postgres:
    version: '16'
  sgInstanceProfile: 'size-s'
  pods:
    persistentVolume:
      size: '1Gi'
  initialData:
    restore:
      fromBackup:
        name: my-db-2024-09-01-05-00-04
```
## Notes
- fromBackUp will be name of the backup which we one to restore
