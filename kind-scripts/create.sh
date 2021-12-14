#!/bin/bash
HOME_DIR=`dirname $(readlink -f ${BASH_SOURCE})`

kind delete cluster -q
kind create cluster --image=kindest/node:v1.21.1 --name kind --config $HOME_DIR/kind-with-harbor-ca.yml
docker exec -it kind-control-plane /bin/bash update-ca-certificates
docker exec -it kind-control-plane /bin/bash service containerd restart
kind get kubeconfig > $HOME_DIR/kubeconfig-kind.yml
kubectl --kubeconfig=$HOME_DIR/kubeconfig-kind.yml get nodes
