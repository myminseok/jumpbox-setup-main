#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/../env-template/

if [ "$1" == "-h" ]; then
  echo ""
  echo "This script destroys the given VM"
  echo "  Usage: $0 [VM NAME]"
  exit 0;
fi


check_executable "govc"

VM_NAME=${1}
if [ -z "$VM_NAME" ]; then
  read -p "Enter VM name (hit enter key for default: $VM_NAME_PREFIX): " VM_NAME_READ
  VM_NAME=${VM_NAME_READ:-$VM_NAME_PREFIX}  
fi
echo ""
read -p "Are you sure to delete the VM '$VM_NAME'? (Y/y) " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  echo "Quitting with no change."
  exit 1
fi
echo ""
echo "Deleting VM '$VM_NAME' ..."
govc vm.destroy $VM_NAME

echo "Successfully Deleted VM '$VM_NAME'"