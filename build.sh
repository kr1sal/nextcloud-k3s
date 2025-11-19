#!/bin/bash
set -e

# TODO: build package for current architecture from remote repository

if [ -f ./package.deb ]; then
  rm ./package.deb
fi

dpkg-deb --build package
