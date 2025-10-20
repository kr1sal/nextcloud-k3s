#!/bin/bash
set -e

K3S_CONFIG_FILE=~/.kube/config-nextcloud

helm --kubeconfig $K3S_CONFIG_FILE repo add jetstack https://charts.jetstack.io --force-update
helm --kubeconfig $K3S_CONFIG_FILE install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.19.1 --set crds.enabled=true
