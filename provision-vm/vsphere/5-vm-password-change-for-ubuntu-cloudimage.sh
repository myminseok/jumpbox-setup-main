## For ubuntu cloud image OVA only(ubuntu-18.04-server-cloudimg-amd64.ova)
## the VM should be powered on.
#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/../env-template/

check_executable "expect"

VM_NAME="${1}"
if [ -z "$VM_NAME" ]; then
  read -p "Enter VM name to be created (hit enter key for default: $VM_NAME_PREFIX): " VM_NAME_READ
  VM_NAME=${VM_NAME_READ:-$VM_NAME_PREFIX}  
fi

echo "Changing password for VM '$VM_NAME'"
VM_IP=$(govc vm.ip $VM_NAME)

# remove entry from known_hosts
ssh-keygen -f ~/.ssh/known_hosts -R $VM_IP

eval "$SCRIPTDIR/vm-password-change.expect $VM_IP ubuntu '$VM_PASSWORD_TEMP' '$VM_PASSWORD'"
echo ""




