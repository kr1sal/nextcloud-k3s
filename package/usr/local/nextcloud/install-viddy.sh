#!/bin/bash

set -e

if ! command -v viddy >/dev/null 2>&1; then
  sudo wget -O viddy.tar.gz https://github.com/sachaos/viddy/releases/download/v1.3.0/viddy-v1.3.0-linux-x86_64.tar.gz && sudo tar xvf viddy.tar.gz && sudo mv viddy /usr/local/bin
fi
