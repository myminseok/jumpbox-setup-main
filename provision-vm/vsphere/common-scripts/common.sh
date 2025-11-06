#!/bin/bash
set -e

## this is for this program only.
## check debug flag
for i in "$@"; do
  if [ "$i" == "--debug" ]; then
    DEBUG="y"
    set -x
  fi
done

function print_debug {
  if [ "$DEBUG" == "y" ]; then
    echo "  DEBUG: $1"  
  fi
}

function print_help_customizing {
  echo "  Setup onfig:"
  echo "    script/sh ~/any/path/env"
  echo "    it will do:"
  echo "      cp -r env.template /any/path/env"
  echo "      export ENV_FILE=/path/to/env > ~/.provision_vm_config"
  echo "      export ENV_DIR=/path/to/ > ~/.provision_vm_config" 
  echo ""
}

function set_envconfig {
  DEFAULT_ENV_FILE="$SCRIPTDIR/env-template/vm-deployment.env" 
  ENV_FILE=${1:-$DEFAULT_ENV_FILE}  

  ENV_DIR=$(echo $ENV_FILE | rev | cut -d'/' -f2- | rev)
  echo "$ENV_DIR"
  if [ ! -d "$ENV_DIR" ]; then
    echo "Creating folder $ENV_DIR"
    mkdir -p "$ENV_DIR"
  fi

  ABS_ENV_DIR="$( cd "$( dirname "${ENV_FILE[0]}" )" && pwd )"
  ABS_ENV_FILE="$( cd "$( dirname "${ENV_FILE[0]}" )" && pwd )/$(basename -- $ENV_FILE)"

  copy_to_file_if_not_exist $SCRIPTDIR/env-template/vm-deployment.env $ABS_ENV_FILE
  
  echo "Creating ~/.provision_vm_config for ABS_ENV_PATH: $ABS_ENV_FILE"
  echo "export ENV_FILE=$ABS_ENV_FILE" > ~/.provision_vm_config
  echo "export ENV_DIR=$ABS_ENV_DIR" >> ~/.provision_vm_config
  cat ~/.provision_vm_config
  echo ""
  echo "Coping env-values templates to ABS_ENV_DIR: $ABS_ENV_DIR"
  echo " finding setup_config_copy_files.sh under '$SCRIPTDIR'"
  for file in $(find $SCRIPTDIR -name "setup_config_copy_files.sh") ; do
    echo "executing $file"
    chmod +x $file
    $file
  done
}

function _decide_envconfig {
  if [ -f ~/.provision_vm_config ]; then
    echo "[ENV] Loading env from ~/.provision_vm_config"
    source ~/.provision_vm_config
  fi

  ENV_FILE=${ENV_FILE:-$DEFAULT_ENV_FILE}
  if [ ! -f $ENV_FILE ]; then
    echo "ERROR: Env file not found '$ENV_FILE'"
    print_help_customizing
    exit 1
  fi
  echo "[ENV] Using env from '$ENV_FILE'"
  source $ENV_FILE
  export ENV_FILE=$ENV_FILE
  export ENV_DIR=$ENV_DIR
}

function trim_string {
    echo $(echo $1 | xargs)
}

function load_env_file {
  DEFAULT_ENV_DIR=$1
  _decide_envconfig "$DEFAULT_ENV_DIR/vm-deployment.env"
  source $ENV_FILE
  source $ENV_DIR/govc.env
}

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
  [[ "$VM_OVA_NAME" =~ "vmware" || "$VM_OVA_NAME" =~ "tanzu"  ]]
}

function copy_to_dir_if_not_exist {
  SRC_FILE=$1
  DEST_DIR=$2
  SRC_FILENAME=$(echo $SRC_FILE | rev | cut -d'/' -f1 | rev)
  if [ -f $DEST_DIR/$SRC_FILENAME ]; then
    echo "Skip Coping. File already exist: $DEST_DIR/$SRC_FILENAME "
  else
    echo "Coping $SRC_FILE to $DEST_DIR"
    cp $SRC_FILE $DEST_DIR/
  fi
}

function copy_to_file_if_not_exist {
  SRC_FILE=$1
  DEST_FILE=$2
  if [ -f $DEST_FILE ]; then
    echo "Skip Coping. File already exist: $DEST_FILE "
  else
    echo "Coping $SRC_FILE to $DEST_FILE"
    cp $SRC_FILE $DEST_FILE
  fi
}