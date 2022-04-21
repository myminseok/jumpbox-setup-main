#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TARGET="/data/gitlab-data/config/ssl"
rm -rf $TARGET
mkdir -p $TARGET
ln  $SCRIPT_DIR/generate-self-signed-cert/domain.crt $TARGET/gitlab2.lab.pcfdemo.net.crt
ln  $SCRIPT_DIR/generate-self-signed-cert/domain.key $TARGET/gitlab2.lab.pcfdemo.net.key
ls -al $TARGET
