#!/bin/bash

set -x
export SSHPASS='PASS'

while IFS= read -r IP; do
echo $IP
set +e
sshpass -p "$SSHPASS" scp -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ~/.ssh/authorized_keys ubuntu@$IP:~/.ssh/authorized_keys
sshpass -p "$SSHPASS" scp -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ./sudoers ubuntu@$IP:/tmp/sudoers

## then manually edit /etc/suduers
## add following to /etc/sudoers
### ubuntu  ALL=(ALL) NOPASSWD: ALL

done < nodeip-list.txt
