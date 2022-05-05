#!/bin/bash

set -x

rm -rf ./pssh-*

parallel-ssh -h nodeip-list.txt -l ubuntu  -v --timeout=180 -p 20 -e ./pssh-err -o ./pssh-out netstat -nlp | grep 8443

grep -r 8443 ./pssh-out/*
