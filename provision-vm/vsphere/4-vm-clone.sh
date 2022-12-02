#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common.sh

VM_OVA_FILE=$(basename $VM_OVA_SOURCE_URL)
VM_OVA_TEMPLATE="${VM_OVA_FILE}"

if [ "$1" == "-h" ]; then
  echo ""
  echo "This script clones a vm from '${VM_OVA_TEMPLATE}' with params defined in 'vm-deployment.env'"
  echo "  Usage: $0 [VM_NAME] [VM_NETWORK]"
  echo "  Tip: run 3-vm-template-upload.sh to upload VM template"
  exit 0;
fi

check_executable "govc"
check_executable "jq"

echo ""
echo "VM will be cloned from template: '${VM_OVA_TEMPLATE}'"
VM_NAME="${1}"
if [ -z "$VM_NAME" ]; then
  read -p "Enter VM name to be created (hit enter key for default: $VM_NAME_PREFIX): " VM_NAME_READ
  VM_NAME=${VM_NAME_READ:-$VM_NAME_PREFIX}  
fi
echo "VM name to be cloned: '${VM_NAME}'"
VM_NETWORK_NEW="${2}"
if [ -z "$VM_NETWORK_NEW" ]; then
  read -p "Enter New VM Network to replace from the default network (hit enter key for default: $VM_NETWORK_DEFAULT): " VM_NETWORK_READ
  VM_NETWORK_NEW="${VM_NETWORK_READ:-$VM_NETWORK_DEFAULT}"
fi
echo "Default VM Network: '${VM_NETWORK_NEW}'"

echo ""
echo "Cloning VM '$VM_NAME' from template '${VM_OVA_TEMPLATE}' ..."
set -x
govc vm.clone --vm="${VM_OVA_TEMPLATE}"  -c $VM_CPU -m $VM_MEM_MB -on=false $VM_NAME
set +x


echo ""
echo "Current Network adapters of VM '$VM_NAME':"
govc device.info -vm="$VM_NAME" -json 'ethernet-*'  | jq -r '.Devices[] | .DeviceInfo.Summary'

## change os disk size
echo "Changing OS disk size  ..."
OS_DISK_KEY=$(govc device.info --vm=$VM_NAME  --json 'disk-*' | jq -r '.Devices[0].Key')
set -x
govc vm.disk.change --vm=$VM_NAME  -disk.key $OS_DISK_KEY -size ${VM_OS_DISK_GB}G
set +x
## replace new network as default network(ethernet-0). and VM_NETWORK_DEFAULT as additional network.
MATCHED_VM_NETWORK=$(govc vm.info -json $VM_NAME | \
jq --arg keyword "$VM_NETWORK_NEW" '.VirtualMachines[].Config.Hardware.Device[] | select (.DeviceInfo.Label | startswith("Network adapter")).DeviceInfo | select(.Summary==$keyword)')
if [ "x$MATCHED_VM_NETWORK" == "x" ]; then
  echo ""
  echo "Replacing Current network to VM '$VM_NETWORK_NEW' (DHCP required to get IP assigned automatically) ..."
  govc vm.network.change -vm="$VM_NAME" -net.adapter=vmxnet3 -net="$VM_NETWORK_NEW" ethernet-0
  ## adding VM_NETWORK_DEFAULT as additional network.(mostly for default network connection)
  source $SCRIPTDIR/7-vm-nic-add.sh "$VM_NAME" "$VM_NETWORK_DEFAULT"
fi

## below code only valid for OVA using cloud-init such as Tanzu OVA(photon, ubuntu)
## donot delete '#cloud-config' in the follwing code. otherwise login will fail.
if is_vmware_tanzu_ova $VM_OVA_TEMPLATE; then
  echo "Setting 'ubuntu' as default user using cloud-init ..."
  if [ ! -f "$VM_SSH_PUBLIC_KEY_FILE_PATH" ]; then
    echo "ERROR: file not found: $VM_SSH_PUBLIC_KEY_FILE_PATH"
    exit 1
  fi
  VM_SSH_PUBLIC_KEY=$(cat "$VM_SSH_PUBLIC_KEY_FILE_PATH")

  CLOUD_INIT_FILE_PATH=$PATH_TO_DOWNLOAD/cloud-init-userdata_${VM_NAME}
cat > $CLOUD_INIT_FILE_PATH << EOF
#cloud-config

users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
EOF
echo "      - $VM_SSH_PUBLIC_KEY" >> $CLOUD_INIT_FILE_PATH

  if [[ "$(uname)" == "Darwin" ]]; then
    CLOUD_INIT_BASE64=$(base64 -b0 < ${CLOUD_INIT_FILE_PATH})
  else
    CLOUD_INIT_BASE64=$(base64 -w0 < ${CLOUD_INIT_FILE_PATH})
  fi
  eval "govc vm.change -vm=\"$VM_NAME\" -e \"guestinfo.userdata.encoding=base64\" -e \"guestinfo.userdata=$CLOUD_INIT_BASE64\""
  # echo "Fetching userdata, metadata ..."
  # govc vm.info -json $VM_NAME | jq -r 'recurse | .ExtraConfig? // empty | .[] | select(.Key=="guestinfo.metadata", .Key=="guestinfo.userdata") | .Value' | base64 -d
fi

govc vm.power -on $VM_NAME
govc vm.info -waitip=true $VM_NAME

if ! is_vmware_tanzu_ova $VM_OVA_TEMPLATE; then
  $SCRIPTDIR/5-vm-password-change-for-ubuntu-cloudimage.sh "$VM_NAME"
fi

echo "Successfully Provisioned the VM successfully."
echo ""
echo "TIPs:"
echo "- try 6-vm-info.sh to get the VM IP"
echo "- ssh into the vm with 'ubuntu' account. ex) ssh ubuntu@IP -i ~/.ssh/id_rsa"
echo "- or run 5-vm-ssh.sh alternatively"
