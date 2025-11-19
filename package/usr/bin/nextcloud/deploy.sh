#!/bin/bash
set -e

source /usr/libexec/bh-utils/load-env.sh --env-file=/etc/nextcloud/.env

#sudo docker volume create --driver local --opt type=nfs --opt o=addr=127.0.0.1,rw,nfsvers=4  --opt device=:/srv/nfs/nextcloud nextcloud
#sudo docker run -d -p 8080:80 -v nextcloud:/var/www/html nextcloud

sudo mkdir -p ${NEXTCLOUD_PATH}/server
sudo mkdir -p ${NEXTCLOUD_PATH}/data
sudo mkdir -p ${NEXTCLOUD_PATH}/users
# sudo chown -R 33:33 ${NEXTCLOUD_PATH}/server
# sudo chown -R 33:33 ${NEXTCLOUD_PATH}/data
# sudo chown -R 999:999 ${NEXTCLOUD_PATH}/users

sudo yq -i ".volumes.nextcloud_data.driver_opts.device = \":${NEXTCLOUD_PATH}/data\"" /etc/nextcloud/compose.yaml
sudo yq -i "(.services.app.environment.[] | select(. == \"NEXTCLOUD_ADMIN_USER=*\")) |= \"NEXTCLOUD_ADMIN_USER=${NEXTCLOUD_ADMIN_USER}\"" /etc/nextcloud/compose.yaml
sudo yq -i "(.services.app.environment.[] | select(. == \"NEXTCLOUD_ADMIN_PASSWORD=*\")) |= \"NEXTCLOUD_ADMIN_PASSWORD=${NEXTCLOUD_ADMIN_PASSWORD}\"" /etc/nextcloud/compose.yaml
if [ "$NFS_ENABLED" = "true" ]; then
  DRIVER_OR_PATH=nextcloud_data
else
  DRIVER_OR_PATH="${NEXTCLOUD_PATH}/data"
fi
sudo yq -i "(.services.app.volumes.[] | select(. == \"*:/var/www/html/data\")) |= \"${DRIVER_OR_PATH}:/var/www/html/data\"" /etc/nextcloud/compose.yaml
sudo yq -i ".volumes.nextcloud_data.driver_opts.o = \"addr=${NFS_SERVER},rw\"" /etc/nextcloud/compose.yaml
sudo yq -i ".volumes.nextcloud_data.driver_opts.device = \":${NFS_PATH}\"" /etc/nextcloud/compose.yaml

mkdir -p /etc/nextcloud/certs
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /etc/nextcloud/certs/server.key \
  -out /etc/nextcloud/certs/server.crt \
  -subj "/CN=nextcloud.build-hub.local"

sudo docker compose -f /etc/nextcloud/compose.yaml up -d
NEXTCLOUD_CONTAINER=$(sudo docker ps --filter "name=nextcloud" --format "{{.ID}}")
sudo docker exec -it $NEXTCLOUD_CONTAINER php /var/www/html/occ config:system:set trusted_domains 2 --value=*
sudo docker exec -it $NEXTCLOUD_CONTAINER php /var/www/html/occ config:system:set forwarded_for_headers 0 --value="HTTP_X_FORWARDED_FOR"
sudo docker exec -it $NEXTCLOUD_CONTAINER php /var/www/html/occ config:system:set forwarded_for_headers 1 --value="HTTP_X_FORWARDED"
sudo docker exec -it $NEXTCLOUD_CONTAINER php /var/www/html/occ config:system:set forwarded_for_headers 2 --value="HTTP_FORWARDED_FOR"
sudo docker exec -it $NEXTCLOUD_CONTAINER php /var/www/html/occ config:system:set forwarded_for_headers 3 --value="HTTP_FORWARDED"
