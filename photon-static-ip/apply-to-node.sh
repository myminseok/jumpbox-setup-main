#!/bin/bash

GATEWAY="192.168.0.1"
DNS="192.168.0.5"
NETWORK_CONFIG_FILEPATH="./10-static-en.network"
REMOTE_UPDATE_SHELL="./remote-update-network.sh"
TARGET_NODELIST=$1
if [ -z "$TARGET_NODELIST" ]; then
  echo "please put node ip list file"
  echo "$  $(basename $BASH_SOURCE) ./target_nodelist"
  exit 1
fi


gen_node_network_config(){
cat <<EOF > $NETWORK_CONFIG_FILEPATH
[Match]
Name=eth0

[Network]
Address=$1/24
Gateway=$2
DNS=$3
EOF
}


while IFS= read -r NODE_IP; do
  echo "Applying to $NODE_IP ------------------------"
  gen_node_network_config $NODE_IP $GATEWAY $DNS

  scp -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $NETWORK_CONFIG_FILEPATH capv@"${NODE_IP}":/tmp/10-static-en.network
  scp -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $REMOTE_UPDATE_SHELL capv@"${NODE_IP}":/tmp/remote-update-network.sh
  ssh -n -q -t -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null capv@"${NODE_IP}" "sudo sh /tmp/remote-update-network.sh"
  if [ $? -eq 0 ] ;
  then
      echo "Static Network applied successfully on $NODE_IP!"
  else
      echo "There was an error Applying Static network on $NODE_IP"
      exit 2
  fi
done < $TARGET_NODELIST

rm $NETWORK_CONFIG_TEMPLATE
