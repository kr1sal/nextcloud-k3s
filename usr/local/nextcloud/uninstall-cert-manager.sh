#!/bin/bash
set -e

K3S_CONFIG_FILE=~/.kube/config-nextcloud

if helm --kubeconfig $K3S_CONFIG_FILE list -n cert-manager | grep "cert-manager"; then
  helm delete cert-manager --namespace cert-manager
fi
