#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/govc.env
source $SCRIPTDIR/common.sh

if [ "$1" == "-h" ]; then
  echo ""
  echo "This script clones a vm from '${VM_NAME_PREFIX}-template' with params defined in 'vm-deployment.env'"
  echo "  Usage: $0 [VM_NAME]"
  echo "  Tip: run 3-vm-template-upload.sh to upload VM template"
  exit 0;
fi

check_executable "govc"
check_executable "jq"

VM_NAME="${1}"
if [ -z "$VM_NAME" ]; then
  read -p "Enter VM name to be created (hit enter key for default: $VM_NAME_PREFIX): " VM_NAME_READ
  VM_NAME=${VM_NAME_READ:-$VM_NAME_PREFIX}  
fi

echo "Restarting off $VM_NAME"
govc vm.power -off $VM_NAME
govc vm.power -on $VM_NAME
govc vm.info -waitip=true $VM_NAME

echo "Successfully Restarting the VM."
