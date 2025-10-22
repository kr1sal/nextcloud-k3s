#!/bin/bash
set -e

K3S_CONFIG_FILE=~/.kube/config-nextcloud

if helm --kubeconfig $K3S_CONFIG_FILE list -n nextcloud | grep -q nextcloud-server; then
  helm --kubeconfig $K3S_CONFIG_FILE uninstall nextcloud-server -n nextcloud
fi

kubectl

if helm --kubeconfig $K3S_CONFIG_FILE list -n cert-manager | grep -q cert-manager; then
  helm --kubeconfig $K3S_CONFIG_FILE uninstall cert-manager -n cert-manager
fi

if helm --kubeconfig $K3S_CONFIG_FILE list -n nextcloud | grep -q postgresql; then
  helm --kubeconfig $K3S_CONFIG_FILE uninstall postgresql -n nextcloud
fi

if helm --kubeconfig $K3S_CONFIG_FILE list -n nextcloud | grep -q nfs-provisioner; then
  helm --kubeconfig $K3S_CONFIG_FILE uninstall nfs-provisioner -n nextcloud
fi

if systemctl status nextcloud-port-forward.service | grep -q " active "; then
  sudo systemctl disable --now nextcloud-port-forward.service
fi

if sudo k3s kubectl get namespace nextcloud >/dev/null 2>&1; then
  sudo k3s kubectl delete namespace nextcloud
fi

if sudo k3s kubectl get namespace cert-manager >/dev/null 2>&1; then
  sudo k3s kubectl delete namespace cert-manager
fi

echo "You need manually delete PV from cluster"
echo "  sudo k3s kubectl get pv"
echo "  sudo k3s kubectl delete pv <PV_NAME>"
