#!/bin/bash

#backup original init file
for f in /etc/systemd/network/10-cloud-init*; do
    fileext=$(echo $f | rev | cut -d'.' -f1 | rev)
    if [ "$fileext" != "orig" ]; then
      echo "renaming $f"
      mv -- "$f" "${f%}.orig"
    fi
done

mv /tmp/10-static-en.network /etc/systemd/network/10-static-en.network
chmod 644  /etc/systemd/network/10-static-en.network

ls -al /etc/systemd/network
echo ""
echo "/etc/systemd/network/10-static-en.network"
cat  /etc/systemd/network/10-static-en.network

systemctl restart systemd-networkd
echo "applied "
