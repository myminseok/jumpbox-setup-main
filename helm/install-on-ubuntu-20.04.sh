#!/bin/bash
set -e
CURRENT_DIR=`dirname $(readlink -f ${BASH_SOURCE})`
DOWNLOAD_PATH="$CURRENT_DIR"
msg(){
  echo ""
  echo "$1 ================================================"
}

dpkg -i $DOWNLOAD_PATH/apt-transport-https/*.deb
dpkg -i $DOWNLOAD_PATH/helm/*.deb

