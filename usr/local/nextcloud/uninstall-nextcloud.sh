#!/bin/bash
set -e

K3S_CONFIG_FILE=~/.kube/config-nextcloud

if helm --kubeconfig $K3S_CONFIG_FILE list -n nextcloud | grep -q nextcloud-server; then
  helm --kubeconfig $K3S_CONFIG_FILE uninstall nextcloud-server -n nextcloud
fi

if helm --kubeconfig $K3S_CONFIG_FILE list -n cert-manager | grep -q "cert-manager"; then
  helm delete cert-manager --namespace cert-manager
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

#sudo k3s kubectl delete namespace nextcloud
