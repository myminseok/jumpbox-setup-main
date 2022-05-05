#!/bin/bash

set +x
set -e #fail-fast

mkdir -p ~/workspace
cd ~/workspace
rm -rf nginx-stream
git clone https://github.com/myminseok/nginx-stream
cd nginx-stream/ubuntu18
echo "setup"
sudo ./setup.sh
