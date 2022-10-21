#!/bin/bash
## download VM ova.

SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common.sh

VM_OVA_FILE=$(basename $VM_OVA_SOURCE_URL)
VM_OVA_FILE_PATH=$PATH_TO_DOWNLOAD/$VM_OVA_FILE

if [ "$1" == "-h" ]; then
  echo ""
  echo "This script downloads VM OVA from 'VM_OVA_SOURCE_URL' and  save to 'PATH_TO_DOWNLOAD' defined in 'vm-deployment.env' file."
  echo "  Usage: $0 "
  exit 0;
fi

echo "Checking ova file in $VM_OVA_FILE_PATH"
if [ ! -f "$VM_OVA_FILE_PATH" ]; then
  echo "Downloading $VM_OVA_SOURCE_URL to $PATH_TO_DOWNLOAD"
  wget $VM_OVA_SOURCE_URL -P "$PATH_TO_DOWNLOAD"
fi
echo "OVA file is ready in $VM_OVA_FILE_PATH"