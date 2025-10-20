#!/bin/bash
set -e

watch -n 1 sudo k3s kubectl get pods -n nextcloud
