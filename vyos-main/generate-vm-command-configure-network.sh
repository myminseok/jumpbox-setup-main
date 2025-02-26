#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common.sh

check_executable "govc"

VM_IP=${1}
if [ -z "$VM_IP" ]; then
  read -p "Enter VM IP: " VM_IP_READ
  VM_IP=${VM_IP_READ}  
fi

if [ -z "$VM_IP" ]; then
   echo "VM_IP is required"
   exit 1
fi

VM_NAME=${2}
if [ -z "$VM_NAME" ]; then
  read -p "Enter VM name: " VM_NAME_READ
  VM_NAME=${VM_NAME_READ:-$VM_NAME_PREFIX}  
fi

if [ -z "$VM_NAME" ]; then
   echo "VM_NAME is required"
   exit 1
fi


VM_USER=${3}
if [ -z "$VM_USER" ]; then
  read -p "Enter VM user name: " VM_USER_READ
  VM_USER=${VM_USER_READ:-ubuntu}  
fi

if [ -z "$VM_USER" ]; then
   echo "VM_USER is required"
   exit 1
fi



ifaces=$(ssh -t -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $VM_USER@$VM_IP find /sys/class/net -mindepth 1 -maxdepth 1 -not -name lo -printf "%P: " -execdir cat '{}/address' '\;')

function match_iface(){
  mac=$1
  for iface in $ifaces; do
    if [[ "$iface" == *"$mac"* ]]; then
      echo "$iface"
      return
    fi
  done
  echo ""
}


echo "[DEBUG] interface list"
echo "$ifaces"
echo ""

vm_device_list=$(govc vm.info -json=true $VM_NAME | jq -r '.VirtualMachines[0].Config.Hardware.Device[] | select(.MacAddress != null and .DeviceInfo.Summary != "VM Network") | .MacAddress + ";" + .DeviceInfo.Summary ')
echo "[DEBUG] VM device list"
echo "$vm_device_list"
echo ""


echo "configure following command on VM"
echo "/etc/netplan/50-cloud-init.yaml"
echo "netplan apply"
echo "--------------------------"

echo ""
echo "# existing network config."
echo "network:"
echo "    version: 2"
echo "    ethernets:"
echo "        ens192:"
echo "            dhcp4: no"
echo "            addresses:"
echo "            - 10.220.15.90/27"
echo "            gateway4: 10.220.15.94"
echo "            nameservers:"
echo "              addresses: [10.79.2.5]"
echo "            match:"
echo "              macaddress: ..."
echo ""
echo "# add new network config below ... "

echo $vm_device_list | \
for line in $vm_device_list;
  do
    if [[ "$line" == *"DVSwitch:"* ]]; then
      #echo "## skip in processing $line"
      continue
    fi  

    mac=$(echo "$line" | cut -f1 -d ';');
    # ${name}-${cidr}-${vlan}
    pg=$(echo "$line" | cut -f2 -d ';');
    ## return empty if no delimiter found. ex "VM Network"
    gw=$(echo "$pg" | cut -f2 -d '-' -s | cut -f1 -d '_')
    if [ -z "${gw}" ]; then
      #echo "## SKIP portgroup \"$pg\" as there is no gateway address info in the naming"
      continue
    fi  

    eth=$(match_iface $mac | cut -f1 -d ':' )
    if [ -z "${eth}" ]; then
      #echo "## ERROR  in processing $line"
      continue
    fi  
    if [[ "$eth" == *"eth0"* ]]; then
      echo "## skip in processing $eth"
      continue
    fi  
    #echo "portgroup: $pg  eth: $eth gateway: ${gw}"
    echo "        $eth: # $pg"
    echo "            dhcp4: no"
    echo "            addresses:"
    echo "            - ${gw}99/24" # x.x.x.199
  done



