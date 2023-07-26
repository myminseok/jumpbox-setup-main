#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common.sh

## https://github.com/vmware-tanzu-labs/tanzu-validated-solutions/blob/main/src/deployment-guides/tko-on-vsphere.md
## ${name}-${cidr}-${vlan}
set -x

echo ""
read -p "Are you sure to DELETE portgroups? (Y/y) " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Quitting"
    exit 1
fi
echo ""

govc host.portgroup.remove "nsx_alb_management_pg-192.168.10.1"
govc host.portgroup.remove "tkg_mgmt_pg-192.168.40.1"
govc host.portgroup.remove "tkg_mgmt_vip_pg-192.168.50.1"
govc host.portgroup.remove "tkg_cluster_vip_pg-192.168.80.1"
govc host.portgroup.remove "tkg_workload_vip_pg-192.168.70.1"
govc host.portgroup.remove "tkg_workload_pg-192.168.60.1"
