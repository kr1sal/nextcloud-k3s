#!/bin/bash

set -e

if ! command -v k3s >/dev/null 2>&1; then
  curl -sfL https://get.k3s.io | sh -
fi


if ! systemctl is-active --quiet k3s; then
  sudo systemctl enable k3s
  sudo systemctl start k3s
fi

if [ ! -f /etc/rancher/k3s/k3s.yaml ]; then
  echo "kubeconfig not found! Please, try install again"
  exit 1
fi

echo "Check if cluster is ready..."
for i in {1..10}; do
  if sudo k3s kubectl get nodes | grep -q ' Ready '; then
    echo "Cluster node is ready!"
    sudo k3s kubectl get nodes
    break
  else
    echo "Waiting ready ($i/10)"
    sleep 5
  fi
done

if ! sudo k3s kubectl get nodes | grep -q ' Ready '; then
  echo "Cluster node is not ready. Check logs k3s:"
  echo "    sudo journalctl -u k3s -f"
  exit 1
fi

echo
echo "K3s is ready for work!"
echo "kubeconfig: /etc/rancher/k3s/k3s.yaml"
echo "You can execute:"
echo "  kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get nodes"
echo "  helm --kubeconfig /etc/rancher/k3s/k3s.yaml list"
echo
