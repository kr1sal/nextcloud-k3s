#!/bin/bash
set -e

export FORCE_REMOVE="false"

source /usr/libexec/bh-utils/load-env.sh --env-file=/etc/nextcloud/.env

args=("$@")
for ((i=0; i<${#args[@]}; i++)); do
  case "${args[$i]}" in
    -f|--force) FORCE_REMOVE="true" ;;
  esac
done

sudo docker compose -f /etc/nextcloud/compose.yaml down
if [ "$FORCE_REMOVE" = "true" ]; then
    sudo rm -fr /etc/nextcloud/certs
    sudo rm -fr /srv/nfs/nextcloud
fi