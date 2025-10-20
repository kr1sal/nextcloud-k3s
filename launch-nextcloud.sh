#!/bin/bash
set -e

sudo cp nextcloud-port-forward.sh /usr/local/bin/nextcloud-port-forward.sh
sudo cp ./nextcloud-port-forward.service /etc/systemd/system/nextcloud-port-forward.service

if ! systemctl is-enabled nextcloud-port-forward.service | grep enabled; then
  sudo systemctl daemon-reload
  sudo systemctl enable --now nextcloud-port-forward
fi
