#!/bin/bash
## download govc from https://github.com/vmware/govmomi/releases
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common.sh

if [ "$1" == "-h" ]; then
  echo ""
  echo "This script downloads 'govc' that matches to your OS and Arch to 'PATH_TO_DOWNLOAD' path defined in 'vm-deployment.env' file. "
  echo "  Usage: $0 "
  exit 0;
fi

if [ -f "$PATH_TO_DOWNLOAD/govc" ]; then
  echo "govc executable is ready in $PATH_TO_DOWNLOAD/govc"
  echo "TIPs: copy the executable $PATH_TO_DOWNLOAD/govc to /usr/local/bin/govc"
  exit 0;
fi

os=$(uname)
arch=$(uname -m)
FILE_TO_DOWNLOAD="govc_${os}_${arch}.tar.gz"

if [ ! -f "$PATH_TO_DOWNLOAD/$FILE_TO_DOWNLOAD" ]; then
  echo "Downloading file https://github.com/vmware/govmomi/releases/download/v0.29.0/$FILE_TO_DOWNLOAD to $PATH_TO_DOWNLOAD"
  wget https://github.com/vmware/govmomi/releases/download/v0.29.0/$FILE_TO_DOWNLOAD -P $PATH_TO_DOWNLOAD
  
fi

tar xf $PATH_TO_DOWNLOAD/$FILE_TO_DOWNLOAD -C $PATH_TO_DOWNLOAD

if [ ! -f "$PATH_TO_DOWNLOAD/govc" ]; then
  echo "ERROR: govc executable is NOT ready in $PATH_TO_DOWNLOAD/govc"
  exit 1;
fi
echo "govc executable is ready in $PATH_TO_DOWNLOAD/govc"
echo "TIPs: copy the executable $PATH_TO_DOWNLOAD/govc to /usr/local/bin/govc"

