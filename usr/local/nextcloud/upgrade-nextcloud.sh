#!/bin/bash
set -e

K3S_CONFIG_FILE=~/.kube/config-nextcloud

mkdir -p ~/.kube
sudo cp -f /etc/rancher/k3s/k3s.yaml $K3S_CONFIG_FILE
sudo chown $(id -u):$(id -g) $K3S_CONFIG_FILE
sudo chmod +r $K3S_CONFIG_FILE

sudo k3s kubectl get namespace nextcloud >/dev/null 2>&1 || sudo k3s kubectl create namespace nextcloud

# helm --kubeconfig $K3S_CONFIG_FILE repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
# if ! helm --kubeconfig $K3S_CONFIG_FILE list -n nextcloud | grep -q nfs-provisioner; then
#   helm --kubeconfig $K3S_CONFIG_FILE install nfs-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner -f ./nfs-provisioner-values.yaml -n nextcloud
# else
#   helm --kubeconfig $K3S_CONFIG_FILE upgrade nfs-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner -f ./nfs-provisioner-values.yaml -n nextcloud
# fi

helm --kubeconfig $K3S_CONFIG_FILE repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
if ! helm --kubeconfig $K3S_CONFIG_FILE list -n kube-system | grep -q csi-driver-nfs; then
  helm --kubeconfig $K3S_CONFIG_FILE install csi-driver-nfs csi-driver-nfs/csi-driver-nfs --namespace kube-system
else
  helm --kubeconfig $K3S_CONFIG_FILE upgrade csi-driver-nfs csi-driver-nfs/csi-driver-nfs --namespace kube-system
fi

sudo k3s kubectl apply -f nfs-csi.yaml

if ! helm --kubeconfig $K3S_CONFIG_FILE list -n nextcloud | grep -q postgresql; then
  helm --kubeconfig $K3S_CONFIG_FILE install postgresql oci://registry-1.docker.io/bitnamicharts/postgresql -f postgresql-values.yaml -n nextcloud
else
  helm --kubeconfig $K3S_CONFIG_FILE upgrade postgresql oci://registry-1.docker.io/bitnamicharts/postgresql -f postgresql-values.yaml -n nextcloud
fi

# helm --kubeconfig $K3S_CONFIG_FILE repo add jetstack https://charts.jetstack.io
# if ! helm --kubeconfig $K3S_CONFIG_FILE list -n cert-manager | grep -q cert-manager; then
#   helm --kubeconfig $K3S_CONFIG_FILE install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.19.1 --set crds.enabled=true
# else
#   helm --kubeconfig $K3S_CONFIG_FILE upgrade cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.19.1 --set crds.enabled=true
# fi

# sudo k3s kubectl apply -f self-signed-issuer.yaml
# sudo k3s kubectl apply -f nextcloud-cert.yaml

helm repo add nextcloud https://nextcloud.github.io/helm/
if ! helm --kubeconfig $K3S_CONFIG_FILE list -n nextcloud | grep -q nextcloud-server; then
  helm --kubeconfig $K3S_CONFIG_FILE install nextcloud-server nextcloud/nextcloud -f nextcloud-values.yaml -n nextcloud
else
  helm --kubeconfig $K3S_CONFIG_FILE upgrade nextcloud-server nextcloud/nextcloud -f nextcloud-values.yaml -n nextcloud
fi

sudo k3s kubectl apply -f httproute.yaml