#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/../env-template/

if [ "$1" == "-h" ]; then
  echo ""
  echo "This script add a new NIC to vm"
  echo "  Usage: $0 [VM_NAME] [VM_NETWORK]"
  echo ""
  exit 0;
fi

check_executable "govc"
check_executable "jq"

VM_NAME="${1}"
if [ -z "$VM_NAME" ]; then
  read -p "Enter VM name to be created (hit enter key for default: $VM_NAME_PREFIX): " VM_NAME_READ
  VM_NAME=${VM_NAME_READ:-$VM_NAME_PREFIX}  
fi

VM_NETWORK="${2}"
if [ -z "$VM_NETWORK" ]; then
  read -p "Enter VM Network name to be used for the vm (hit enter key for default: $VM_NETWORK_DEFAULT): " VM_NETWORK_READ
  VM_NETWORK="${VM_NETWORK_READ:-$VM_NETWORK_DEFAULT}"
fi

echo ""
echo "Current Network adapters of VM '$VM_NAME':"
govc device.info -vm="$VM_NAME" -json 'ethernet-*'  | jq -r '.Devices[] | .Name, .DeviceInfo'

## add the new vm network
MATCHED_VM_NETWORK=$(govc vm.info -json $VM_NAME | \
jq --arg keyword "$VM_NETWORK" '.VirtualMachines[].Config.Hardware.Device[] | select (.DeviceInfo.Label | startswith("Network adapter")).DeviceInfo | select(.Summary==$keyword)')
if [ "x$MATCHED_VM_NETWORK" == "x" ]; then
  echo ""
  echo "Adding network: '$VM_NETWORK' "
  govc vm.network.add -vm="$VM_NAME" -net.adapter=vmxnet3 -net="$VM_NETWORK"
  echo "Successfully Added network: '$VM_NETWORK' "
  echo ""
  echo "Final Network adapters of VM '$VM_NAME':"
  govc device.info -vm="$VM_NAME" -json 'ethernet-*'  | jq -r '.Devices[] | .Name, .DeviceInfo'
  echo ""
  echo "IMPORTANT Follow up Action required: To get IP assigned properly"
  echo "  1. ssh into the VM and Modify network for this NIC"
  echo "  2. identify device name such as 'ens224' with command: ip link show"
  echo "  3. and set the device with dncp enabled in /etc/netplan/50-cloud-init.yaml"
  echo "
  network:
    ethernets:
        ens192:
            dhcp4: true
            match:
                macaddress: 00:50:56:83:1e:58
            set-name: ens192
        ens224:
            dhcp4: true
    version: 2
  "
  echo "  4. apply with command: sudo netplan apply "
  echo "  5. check the IP assngned: ifconfig "
else
  echo ""
  echo "Skipping to add network as it exists already: $VM_NETWORK"
fi 

