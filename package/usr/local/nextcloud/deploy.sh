#!/bin/bash
set -e

#sudo docker volume create --driver local --opt type=nfs --opt o=addr=127.0.0.1,rw,nfsvers=4  --opt device=:/srv/nfs/nextcloud nextcloud
#sudo docker run -d -p 8080:80 -v nextcloud:/var/www/html nextcloud

sudo mkdir -p /srv/nfs/nextcloud/server
sudo mkdir -p /srv/nfs/nextcloud/data
sudo mkdir -p /srv/nfs/nextcloud/users
# sudo chown -R 33:33 /srv/nfs/nextcloud/server
# sudo chown -R 33:33 /srv/nfs/nextcloud/data
# sudo chown -R 999:999 /srv/nfs/nextcloud/users

mkdir -p certs
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout certs/server.key \
  -out certs/server.crt \
  -subj "/CN=nextcloud.build-hub.local"

sudo docker compose up -d
export NEXTCLOUD_CONTAINER_HASH=$(sudo docker ps --filter "name=nextcloud" --format "{{.ID}}")
sudo docker exec -it $NEXTCLOUD_CONTAINER_HASH php /var/www/html/occ config:system:set trusted_domains 2 --value=*