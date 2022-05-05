#!/bin/bash
set -x

source ./upload-files.sh

### sudo apt-get install -y pssh
parallel-ssh -h nodeip-list.txt -l ubuntu  -v --timeout=180 -p 20 -e ./pssh-err -o ./pssh-out ~/workspace/scripts/remote-build-deploy-app.sh

tail -f ./pssh-out/*
