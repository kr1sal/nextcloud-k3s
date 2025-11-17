#!/bin/bash
set -e

sudo docker compose down
sudo rm -fr certs
sudo rm -fr /srv/nfs/nextcloud