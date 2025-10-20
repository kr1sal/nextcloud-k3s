#!/bin/bash
set -e

sleep 10

while true; do
  POD_NAME=$(sudo kubectl get pods --namespace nextcloud -l "app.kubernetes.io/name=nextcloud" -o jsonpath="{.items[0].metadata.name}")

  if [ -n "$POD_NAME" ]; then
    echo "Port-forwarding to pod $POD_NAME"
    sudo k3s kubectl port-forward --namespace nextcloud $POD_NAME 8080:80
  else
    echo "Pod not found, retrying in 5s..."
    sleep 5
  fi

  echo "Port-forward failed, retrying in 5s..."
  sleep 5
done
