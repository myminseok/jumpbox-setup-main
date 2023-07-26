#!/bin/bash
## upload the iso to the datastore path first.
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common.sh

check_executable "govc"
set -x

govc vm.create -annotation="TKG Networking Fabric" \
  -c=2 -iso=FILE/vyos-1.4-rolling-202211120317-amd64.iso \
  -m=2048 \
  -disk=20GB \
  -net="$VYOS_VM_NETWORK" \
  -net.adapter=vmxnet3 "$VYOS_VM_NAME";
