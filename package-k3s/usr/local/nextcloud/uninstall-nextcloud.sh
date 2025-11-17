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