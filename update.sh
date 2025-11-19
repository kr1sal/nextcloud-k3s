#!/bin/bash

sudo apt remove --purge bh-nextcloud -y
source ./build.sh
sudo apt install ./package.deb -y