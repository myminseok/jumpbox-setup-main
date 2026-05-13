#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/../env-template/

if [ "$1" == "-h" ]; then
  echo ""
  echo "This script uploads OVA as a VM template '${VM_NAME_PREFIX}-template' with the params from 'vm-deployment.env' file."
  echo "  Usage: $0 "
  echo "  Tip: "
  echo "    - run 2-ova-download.sh to download VM OVA from internet"
  echo "    - for air-gapped env, download the ova to to 'PATH_TO_DOWNLOAD' defined in 'vm-deployment.env' file."
  exit 0;
fi

check_executable "govc"
check_executable "jq"

VM_OVA_FILE=$(basename $VM_OVA_SOURCE_URL)
VM_OVA_TEMPLATE="${VM_OVA_FILE}"
VM_NETWORK="${VM_NETWORK_DEFAULT}"

GOVC_OPTION_FILE="${VM_OVA_TEMPLATE}___${VM_NETWORK}___govc_options.json"
## need to eleminate whitespace in GOVC_OPTION_FILE sometimes.
GOVC_OPTION_FILE_PATH=$PATH_TO_DOWNLOAD/$(echo $GOVC_OPTION_FILE | sed 's/ /_/g')

if [ ! -f $PATH_TO_DOWNLOAD/$VM_OVA_FILE ]; then
  echo "ERROR: file not found: '$PATH_TO_DOWNLOAD/$VM_OVA_FILE'"
  exit 1
fi
if [ ! -f "$VM_SSH_PUBLIC_KEY_FILE_PATH" ]; then
  echo "ERROR: file not found: $VM_SSH_PUBLIC_KEY_FILE_PATH"
  exit 1
fi

echo "Extracting ova spec file ... from $PATH_TO_DOWNLOAD/$VM_OVA_FILE to ${GOVC_OPTION_FILE_PATH}.tmp"
govc import.spec $PATH_TO_DOWNLOAD/$VM_OVA_FILE > "${GOVC_OPTION_FILE_PATH}.tmp"

if [ ! -f "${GOVC_OPTION_FILE_PATH}.tmp" ]; then
  echo "ERROR: file not found: ${GOVC_OPTION_FILE_PATH}.tmp"
  exit 1
fi

echo "Generating govc option file ... ${GOVC_OPTION_FILE_PATH}"
function replace_json_element {
  eval "jq $1 ${GOVC_OPTION_FILE_PATH}.tmp > ${GOVC_OPTION_FILE_PATH}.tmp1"
  mv ${GOVC_OPTION_FILE_PATH}.tmp1 ${GOVC_OPTION_FILE_PATH}.tmp
}
replace_json_element "'.DiskProvisioning=\"thin\"'"
replace_json_element "'.PowerOn=false'"
replace_json_element "'.MarkAsTemplate=true'"
replace_json_element "'.WaitForIP=false'"
replace_json_element "--arg newValue '$VM_OVA_TEMPLATE' '.Name=\$newValue'"


mv ${GOVC_OPTION_FILE_PATH}.tmp ${GOVC_OPTION_FILE_PATH}
echo "Successfully Generated govc option file: ${GOVC_OPTION_FILE_PATH}"
