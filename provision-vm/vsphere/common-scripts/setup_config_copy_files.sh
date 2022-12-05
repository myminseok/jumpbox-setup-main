#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../env-template/vm-deployment.env
copy_to_dir_if_not_exist "$SCRIPTDIR/../env-template/govc.env" $ENV_DIR