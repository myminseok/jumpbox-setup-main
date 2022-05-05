#!/bin/bash

set -x
export SSHPASS='PASS'

while IFS= read -r IP; do
IP="$(echo $IP | tr -d '[:space:]')"
if [[ "$IP" =~ ^#.* ]]; then
    echo "skip $IP"
    continue
fi

set +e
sshpass -e ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q -t ubuntu@"$IP" <<EOF
rm -rf ~/workspace/files
EOF
sshpass -e scp -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r ./files ubuntu@$IP:~/workspace/
sshpass -e ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q -t ubuntu@"$line" <<EOF
  chmod +x /home/ubungu/workspace/files/*.sh
EOF

done < nodeip-list.txt
