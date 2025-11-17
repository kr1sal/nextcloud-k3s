#!/bin/bash
set -e

NFS_CLIENT=${1:-*}
NFS_PATH=${2:-/srv/nfs/nextcloud}

mkdir -p /srv/nfs/nextcloud
sudo chown -R nobody:nogroup /srv/nfs/nextcloud
sudo chmod 0777 /srv/nfs/nextcloud

if ! dpkg -l | grep -qw nfs-kernel-server; then
  sudo apt update
  sudo apt install -y nfs-kernel-server
fi

EXPORT_LINE="$NFS_PATH $NFS_CLIENT(rw,sync,no_subtree_check,no_root_squash)"
if ! grep -qF "$EXPORT_LINE" /etc/exports; then
    echo "$EXPORT_LINE" | sudo tee -a /etc/exports
fi

sudo exportfs -a
if systemctl is-enabled nfs-kernel-server | grep enabled; then
  sudo systemctl restart nfs-kernel-server
fi
sudo systemctl enable --now nfs-kernel-server
showmount -e "$NFS_CLIENT"

echo
echo "nfs is ready!"
