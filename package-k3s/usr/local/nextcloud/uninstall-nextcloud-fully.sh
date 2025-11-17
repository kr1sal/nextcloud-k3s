#!/bin/bash
set -e

K3S_CONFIG_FILE=/usr/local/nextcloud/config-nextcloud

if helm --kubeconfig $K3S_CONFIG_FILE list -n nextcloud | grep -q nextcloud-server; then
  helm --kubeconfig $K3S_CONFIG_FILE uninstall nextcloud-server -n nextcloud
fi

if helm --kubeconfig $K3S_CONFIG_FILE list -n nextcloud | grep -q postgresql; then
  helm --kubeconfig $K3S_CONFIG_FILE uninstall postgresql -n nextcloud
fi

if helm --kubeconfig $K3S_CONFIG_FILE list -n nextcloud | grep -q nfs-provisioner; then
  helm --kubeconfig $K3S_CONFIG_FILE uninstall nfs-provisioner -n nextcloud
fi

if sudo k3s kubectl get namespace nextcloud >/dev/null 2>&1; then
  sudo k3s kubectl delete namespace nextcloud
fi


echo "You need manually delete PV from cluster"
echo "  sudo k3s kubectl get pv"
echo "  sudo k3s kubectl delete pv <PV_NAME>"
echo "  sudo rm -rf /srv/nfs/nextcloud/*"
