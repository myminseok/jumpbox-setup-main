#!/bin/bash

#set -x
set -e
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ENV_DIR=${ENV_DIR:-$SCRIPTDIR/env-template}
echo "Using env from '$ENV_DIR'"
source $ENV_DIR/vm-deployment.env
source $ENV_DIR/govc.env

function check_executable {
  if ! command -v $1 &> /dev/null
  then
    echo "ERROR: executable not found: '$1'"
    exit 1
  fi
}
## return true if OVA name includes "vmware" string.
## photon-3-kube-v1.21.2+vmware.1-tkg.3-6345993713475494409.ova ==> true
## ubuntu-2004-kube-v1.23.8+vmware.2-tkg.1-85a434f93857371fccb566a414462981.ova ==> true
## ubuntu-18.04-server-cloudimg-amd64.ova => false 
function is_vmware_tanzu_ova {
  VM_OVA_NAME=$1
  [[ "$VM_OVA_NAME" =~ "vmware"  ]]
}