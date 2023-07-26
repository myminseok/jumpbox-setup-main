#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common.sh

## https://github.com/vmware-tanzu-labs/tanzu-validated-solutions/blob/main/src/deployment-guides/tko-on-vsphere.md
## ${name}-${cidr}-${vlan}

echo ""
read -p "Are you sure to ADD portgroups? (Y/y) " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Quitting"
    exit 1
fi
echo ""

set -x
govc host.portgroup.add -vswitch vSwitch0 -vlan=10 "nsx_alb_management_pg-192.168.10.1"
govc host.portgroup.add -vswitch vSwitch0 -vlan=40 "tkg_mgmt_pg-192.168.40.1"
govc host.portgroup.add -vswitch vSwitch0 -vlan=50 "tkg_mgmt_vip_pg-192.168.50.1"
govc host.portgroup.add -vswitch vSwitch0 -vlan=80 "tkg_cluster_vip_pg-192.168.80.1"
govc host.portgroup.add -vswitch vSwitch0 -vlan=70 "tkg_workload_vip_pg-192.168.70.1"
govc host.portgroup.add -vswitch vSwitch0 -vlan=60 "tkg_workload_pg-192.168.60.1"

