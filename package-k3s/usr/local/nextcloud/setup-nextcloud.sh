#!/bin/bash
set -e

NFS_SERVER=${1:-127.0.0.1}
NFS_PATH=${2:-/srv/nfs/nextcloud}

./setup-nfs.sh $NFS_SERVER $NFS_PATH
./upgrade-nextcloud.sh
