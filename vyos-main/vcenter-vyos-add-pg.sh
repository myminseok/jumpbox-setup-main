#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common.sh

VM_NAME="${1}"
echo $VM_NAME
if [ -z "$VM_NAME" ]; then
  read -p "Enter VM name to be created (hit enter key for default: $VYOS_VM_NAME): " VM_NAME_READ
  VM_NAME=${VM_NAME_READ:-$VYOS_VM_NAME}
fi

echo ""
read -p "Are you sure the target '$VM_NAME'? (Y/y) " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Quitting"
    exit 1
fi
echo ""

set -x
govc vm.network.add -vm="$VM_NAME" -net.adapter=vmxnet3 -net="nsx_alb_management_pg-192.168.10.1"
govc vm.network.add -vm="$VM_NAME" -net.adapter=vmxnet3 -net="tkg_mgmt_pg-192.168.40.1"
govc vm.network.add -vm="$VM_NAME" -net.adapter=vmxnet3 -net="tkg_mgmt_vip_pg-192.168.50.1"
govc vm.network.add -vm="$VM_NAME" -net.adapter=vmxnet3 -net="tkg_cluster_vip_pg-192.168.80.1"
govc vm.network.add -vm="$VM_NAME" -net.adapter=vmxnet3 -net="tkg_workload_vip_pg-192.168.70.1"
govc vm.network.add -vm="$VM_NAME" -net.adapter=vmxnet3 -net="tkg_workload_pg-192.168.60.1"
