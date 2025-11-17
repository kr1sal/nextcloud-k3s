#!/bin/bash
set -e

viddy -n 0.1 sudo k3s kubectl get pods -A
