## it will create ~/.tapconfig which will use to load `TAP_ENV` environment variable
## and copy TanzuPlatformAssetKR/tap/install-tap/tap-env.template to ~/tap-config/tap-env

#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh

if [ -z $1 ]; then
  echo "Usage: $0 /path/to/env-file"
  echo " - /path/to/tap-env-file: it can be existing path to env file or new path."
  echo "   the directory will be created if not exist and env-tempates/* will be copied"
  echo "   /path/to/env-file path will be saved to ~/.provision_vm_config"
  exit 1
fi

ENV_FILE_PATH=$1
set_envconfig $ENV_FILE_PATH
