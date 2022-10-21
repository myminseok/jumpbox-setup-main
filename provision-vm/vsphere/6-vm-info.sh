#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/govc.env
source $SCRIPTDIR/common.sh

check_executable "govc"

VM_NAME=${1}
if [ -z "$VM_NAME" ]; then
  read -p "Enter VM name (hit enter key for default: $VM_NAME_PREFIX): " VM_NAME_READ
  VM_NAME=${VM_NAME_READ:-$VM_NAME_PREFIX}  
fi

echo "Fetching VM Info '$VM_NAME' ..."
govc vm.info -waitip=false $VM_NAME