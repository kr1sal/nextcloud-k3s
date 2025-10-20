#!/bin/bash
set -e

K3S_CONFIG_FILE=~/.kube/config-nextcloud

mkdir -p ~/.kube
sudo cp -f /etc/rancher/k3s/k3s.yaml $K3S_CONFIG_FILE
sudo chown $(id -u):$(id -g) $K3S_CONFIG_FILE
sudo chmod +r $K3S_CONFIG_FILE

if ! sudo ls /etc/hosts | grep -q nextcloud.local; then
  echo "127.0.0.1	nextcloud.local" | sudo tee -a /etc/hosts
fi

sudo k3s kubectl get namespace nextcloud >/dev/null 2>&1 || sudo k3s kubectl create namespace nextcloud

helm --kubeconfig $K3S_CONFIG_FILE repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm --kubeconfig $K3S_CONFIG_FILE install nfs-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner -f ./nfs-provisioner-values.yaml -n nextcloud

helm --kubeconfig $K3S_CONFIG_FILE install postgresql oci://registry-1.docker.io/bitnamicharts/postgresql -f postgresql-values.yaml -n nextcloud

if ! sudo k3s kubectl get secret -n nextcloud | grep -q nextcloud-tls-secret; then
  sudo k3s kubectl create secret tls nextcloud-tls-secret --cert=tls.crt --key=tls.key -n nextcloud
fi

helm repo add nextcloud https://nextcloud.github.io/helm/
helm --kubeconfig $K3S_CONFIG_FILE install nextcloud-server nextcloud/nextcloud -f nextcloud-values.yaml -n nextcloud

echo "Waiting cluster ready..."
while true
do
  if ( sudo k3s kubectl get pods -n nextcloud | grep -q "nextcloud-server.*3/3.*Running" && sudo k3s kubectl get pods -n nextcloud | grep -q "nfs-provisioner-.*1/1.*Running" && sudo k3s kubectl get pods -n nextcloud | grep -q "postgresql.*1/1.*Running" ); then
    echo "Cluster is ready for work!"
    break
  else
    sleep 10
  fi
done

