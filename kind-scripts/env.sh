kind get kubeconfig > kubeconfig-kind.yml
export KUBECONFIG=$(pwd)/kubeconfig-kind.yml
env | grep  KUBECONFIG

