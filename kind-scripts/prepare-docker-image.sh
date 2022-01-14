docker pull kindest/node:v1.21.1
docker save kindest/node:v1.21.1 -o kindest-node.tar

docker load -i kindest-node.tar
docker tag kindest/node:v1.21.1 infra-harbor.lab.pcfdemo.net/tkg/kind/node:v1.21.2_vmware.1
docker push infra-harbor.lab.pcfdemo.net/tkg/kind/node:v1.21.2_vmware.1
##kind create cluster --image=kindest/node:v1.21.1 
