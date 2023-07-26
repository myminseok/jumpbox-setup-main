#!/bin/bash

#set -x
set -e

echo "TIP: customizing env"
echo "  cp -r env-template /tmp/vyos-env-dev"
echo "  export ENV_DIR=/tmp/vyos-env-dev"
echo ""
echo "  then run script "
echo ""


SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ENV_DIR=${ENV_DIR:-$SCRIPTDIR/env-template}
echo "Using env from '$ENV_DIR'"
source $ENV_DIR/common.env
source $ENV_DIR/govc.env



function check_executable {
  if ! command -v $1 &> /dev/null
  then
    echo "ERROR: executable not found: '$1'"
    exit 1
  fi
}