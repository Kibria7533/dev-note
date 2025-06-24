To upgrade 
Apt instal kubeadm=xxx kubelet=xxx kubectl=xxx
Kubeadm upgrade apply v1.31.1


Etcd backup
 Need to go master using ssh
https://discuss.kubernetes.io/t/etcd-backup-ssues/8304


Restore
https://discuss.kubernetes.io/t/etcd-backup-ssues/8304
Then stop kubelet
Then delete  rm -rf /var/lib/etcd/*
Mv default.etcd/* /var/lib/etcd/
Then start kubelet


Kubernetes manifests
/etc/kubernetes/manifests


Manifest buildup

Kubectl run any_name –image=nginx –dry-run -o yaml > pod.yaml
