#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common.sh
set -x
#ifaces=$(sshpass -p vyos ssh -t -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q vyos@$VYOS_IP find /sys/class/net -mindepth 1 -maxdepth 1 -not -name lo -printf "%P: " -execdir cat '{}/address' '\;')
ifaces=$(ssh -t -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q vyos@$VYOS_VM_IP find /sys/class/net -mindepth 1 -maxdepth 1 -not -name lo -printf "%P: " -execdir cat '{}/address' '\;')

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

set +x

echo "[DEBUG] $ifaces"
echo ""

vm_device_list=$(govc vm.info -json=true tkg-router | jq -r '.VirtualMachines[0].Config.Hardware.Device[] | select(.MacAddress != null)')
echo "[DEBUG] $vm_device_list"
echo ""

echo "configure following command on VYOS vm."
echo "--------------------------"

echo "configure"
  govc vm.info -json=true tkg-router | \
	jq -r '.VirtualMachines[0].Config.Hardware.Device[] | select(.MacAddress != null and .DeviceInfo.Summary != "VM Network") | .MacAddress + ";" + .DeviceInfo.Summary' | \
while read -r line;
  do
    mac=$(echo "$line" | cut -f1 -d ';');
    # ${name}-${cidr}-${vlan}
    pg=$(echo "$line" | cut -f2 -d ';');
    ## return empty if no delimiter found. ex "VM Network"
    gw=$(echo "$pg" | cut -f2 -d '-' -s | cut -f1 -d '_')
    if [ -z "${gw}" ]; then
      echo "## SKIP portgroup \"$pg\" as there is no gateway address info in the naming"
      continue
    fi  

    eth=$(match_iface $mac | cut -f1 -d ':' )
    if [ -z "${eth}" ]; then
      echo "## ERROR  in processing $line"
      continue
    fi  
    if [[ "$eth" == *"eth0"* ]]; then
      echo "## skip in processing $eth"
      continue
    fi  

    echo "delete interfaces ethernet $eth"
    echo "set interfaces ethernet $eth address \"${gw}/24\"";
    echo "set interfaces ethernet $eth description \"$pg\"";

  done

echo "show interface ethernet"


