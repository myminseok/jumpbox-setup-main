#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common.sh


echo "set service dhcp-server dynamic-dns-update"
echo "delete service dhcp-server shared-network-name nsx-alb-mgmt-network"
echo "set service dhcp-server shared-network-name nsx-alb-mgmt-network authoritative"
echo "set service dhcp-server shared-network-name nsx-alb-mgmt-network subnet $NSX_ALB_MGMT_NETWORK_PREFIX.0/24"
echo "set service dhcp-server shared-network-name nsx-alb-mgmt-network subnet $NSX_ALB_MGMT_NETWORK_PREFIX.0/24 default-router $NSX_ALB_MGMT_NETWORK_PREFIX.1"
echo "set service dhcp-server shared-network-name nsx-alb-mgmt-network subnet $NSX_ALB_MGMT_NETWORK_PREFIX.0/24 name-server ${NAMESERVERS[0]}"
echo "set service dhcp-server shared-network-name nsx-alb-mgmt-network subnet $NSX_ALB_MGMT_NETWORK_PREFIX.0/24 lease 86400" # 1day
echo "set service dhcp-server shared-network-name nsx-alb-mgmt-network subnet $NSX_ALB_MGMT_NETWORK_PREFIX.0/24 range 0 start $NSX_ALB_MGMT_NETWORK_PREFIX.20"
echo "set service dhcp-server shared-network-name nsx-alb-mgmt-network subnet $NSX_ALB_MGMT_NETWORK_PREFIX.0/24 range 0 stop $NSX_ALB_MGMT_NETWORK_PREFIX.252"


echo "delete service dhcp-server shared-network-name tkg-mgmt-network"
echo "set service dhcp-server shared-network-name tkg-mgmt-network authoritative"
echo "set service dhcp-server shared-network-name tkg-mgmt-network subnet $TKG_MGMT_NETWORK_PREFIX.0/24"
echo "set service dhcp-server shared-network-name tkg-mgmt-network subnet $TKG_MGMT_NETWORK_PREFIX.0/24 default-router $TKG_MGMT_NETWORK_PREFIX.1"
echo "set service dhcp-server shared-network-name tkg-mgmt-network subnet $TKG_MGMT_NETWORK_PREFIX.0/24 name-server ${NAMESERVERS[0]}"
echo "set service dhcp-server shared-network-name tkg-mgmt-network subnet $TKG_MGMT_NETWORK_PREFIX.0/24 lease 86400" # 1day
echo "set service dhcp-server shared-network-name tkg-mgmt-network subnet $TKG_MGMT_NETWORK_PREFIX.0/24 range 0 start $TKG_MGMT_NETWORK_PREFIX.20"
echo "set service dhcp-server shared-network-name tkg-mgmt-network subnet $TKG_MGMT_NETWORK_PREFIX.0/24 range 0 stop $TKG_MGMT_NETWORK_PREFIX.252"

echo "delete service dhcp-server shared-network-name tkg-workload-network"
echo "set service dhcp-server shared-network-name tkg-workload-network authoritative"
echo "set service dhcp-server shared-network-name tkg-workload-network subnet $TKG_WORKLOAD_NETWORK_PREFIX.0/24"
echo "set service dhcp-server shared-network-name tkg-workload-network subnet $TKG_WORKLOAD_NETWORK_PREFIX.0/24 default-router $TKG_WORKLOAD_NETWORK_PREFIX.1"
echo "set service dhcp-server shared-network-name tkg-workload-network subnet $TKG_WORKLOAD_NETWORK_PREFIX.0/24 name-server ${NAMESERVERS[0]}"
echo "set service dhcp-server shared-network-name tkg-workload-network subnet $TKG_WORKLOAD_NETWORK_PREFIX.0/24 lease 86400" # 1day
echo "set service dhcp-server shared-network-name tkg-workload-network subnet $TKG_WORKLOAD_NETWORK_PREFIX.0/24 range 0 start $TKG_WORKLOAD_NETWORK_PREFIX.20"
echo "set service dhcp-server shared-network-name tkg-workload-network subnet $TKG_WORKLOAD_NETWORK_PREFIX.0/24 range 0 stop $TKG_WORKLOAD_NETWORK_PREFIX.252"

echo ""
for nameserver in ${NAMESERVERS[@]}; 
do
  for net in nsx-alb-mgmt-network tkg-mgmt-network tkg-workload-network
  do echo "set service dhcp-server shared-network-name $net name-server $nameserver"
  done
done


echo "show service dhcp-server"