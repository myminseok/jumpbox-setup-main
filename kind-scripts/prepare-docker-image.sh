docker pull kindest/node:v1.21.1
docker save kindest/node:v1.21.1 -o kindest-node.tar

docker load -i kindest-node.tar
##kind create cluster --image=kindest/node:v1.21.1 
