#!/bin/bash

set -x

source ./upload-files.sh

rm -rf ./pssh-*

### sudo apt-get install -y pssh
parallel-ssh -h nodeip-list.txt -l ubuntu  -v --timeout=180 -p 20 -e ./pssh-err -o ./pssh-out ~/workspace/files/remote-setup-nginx-stream.sh

parallel-ssh -h nodeip-list.txt -l ubuntu  -v --timeout=180 -p 20 -e ./pssh-err -o ./pssh-out netstat -nlp | grep 8443

grep -r 8443 ./pssh-out/*
