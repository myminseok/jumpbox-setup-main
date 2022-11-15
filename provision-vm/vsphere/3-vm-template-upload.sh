#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source $SCRIPTDIR/common.sh

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

VM_SSH_PUBLIC_KEY=$(cat "$VM_SSH_PUBLIC_KEY_FILE_PATH")

echo "Extracting ova spec file ... from $PATH_TO_DOWNLOAD/$VM_OVA_FILE"
govc import.spec $PATH_TO_DOWNLOAD/$VM_OVA_FILE > "${GOVC_OPTION_FILE_PATH}.tmp"

echo "Generating govc option file ... ${GOVC_OPTION_FILE_PATH}"
function replace_json_element {
  eval "jq $1 ${GOVC_OPTION_FILE_PATH}.tmp > ${GOVC_OPTION_FILE_PATH}.tmp1"
  mv ${GOVC_OPTION_FILE_PATH}.tmp1 ${GOVC_OPTION_FILE_PATH}.tmp
}
replace_json_element "'.PowerOn=false'"
replace_json_element "'.MarkAsTemplate=true'"
replace_json_element "'.WaitForIP=false'"
replace_json_element "--arg newValue '$VM_OVA_TEMPLATE' '.Name=\$newValue'"
## below code only valid for ubuntu-18.04-server-cloudimg-amd64.ova. not for the OVA using cloud-init such as Tanzu OVA(photon, ubuntu)
if ! is_vmware_tanzu_ova $VM_OVA_TEMPLATE; then
  echo "Additional OVA options such as network, ssh key , password for ubuntu 64-bit Cloud image ..."
  ##replace_json_element "--arg newValue '$VM_NETWORK' '.NetworkMapping[].Name=\$newValue'"
  replace_json_element "--arg newValue '$VM_NETWORK' '.NetworkMapping[].Network=\$newValue'"
  replace_json_element "--arg newValue '$VM_PASSWORD_TEMP'  '.PropertyMapping=[.PropertyMapping[] | if .Key==\"password\" then .Value=\$newValue else . end]'"
  replace_json_element "--arg newValue '$VM_SSH_PUBLIC_KEY' '.PropertyMapping=[.PropertyMapping[] | if .Key==\"public-keys\" then .Value=\$newValue else . end]'"
fi

mv ${GOVC_OPTION_FILE_PATH}.tmp ${GOVC_OPTION_FILE_PATH}
echo "Successfully Generated govc option file: ${GOVC_OPTION_FILE_PATH}"

echo ""
VM_OVA_FILE=$(basename $VM_OVA_SOURCE_URL)
VM_OVA_FILE_PATH="$PATH_TO_DOWNLOAD/$VM_OVA_FILE"
echo "Uploading VM Template $VM_OVA_TEMPLATE"
govc import.ova  --options="$GOVC_OPTION_FILE_PATH" $VM_OVA_FILE_PATH
echo "Successfully uploaded the VM template"
