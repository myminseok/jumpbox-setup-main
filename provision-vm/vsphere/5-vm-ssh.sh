#!/bin/bash

SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/govc.env
source $SCRIPTDIR/common.sh

check_executable "expect"

VM_NAME="${1}"
if [ -z "$VM_NAME" ]; then
  read -p "Enter VM name to be created (hit enter key for default: $VM_NAME_PREFIX): " VM_NAME_READ
  VM_NAME=${VM_NAME_READ:-$VM_NAME_PREFIX}  
fi

echo "Changing password for VM '$VM_NAME'"
VM_IP=$(govc vm.ip $VM_NAME)
echo "Ssh ubuntu@$VM_IP ..."
echo ""
ssh -t -o StrictHostKeyChecking=no ubuntu@$VM_IP
echo ""
