

## DNS using FreeIPA on ubuntu

#### setup docker.


#### disable port 53

```
systemctl disable bind9
systemctl stop bind9


systemctl disable systemd-resolved.service
systemctl stop systemd-resolved.service
```

#### start free ipa


```
docker run  --rm   --name freeipa-server  -ti  \
        -h ipa.lab.pcfdemo.net -p 53:53/udp -p 53:53  \
        -p 80:80 -p 443:443  -p 389:389  -p 636:636 -p 88:88 -p 464:464 -p 88:88/udp \
        -p 464:464/udp -p 123:123/udp --read-only  \
        --sysctl net.ipv6.conf.all.disable_ipv6=0  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
        -v /root/freeipa-data:/data:Z  freeipa/freeipa-server:fedora-34-4.9.6
```


### start on boot: add to crontab
```
cat > /root/freeipa.sh <<EOF

#!/bin/bash

# systemctl disable bind9
# systemctl disable systemd-resolved.service
# systemctl stop systemd-resolved.service
#
#	1. You must make sure these network ports are open:
#		TCP Ports:
#		  * 80, 443: HTTP/HTTPS
#		  * 389, 636: LDAP/LDAPS
#		  * 88, 464: kerberos
#		  * 53: bind
#		UDP Ports:
#		  * 88, 464: kerberos
#		  * 53: bind
#		  * 123: ntp


docker run --detach   --rm   --name freeipa-server  -ti  \
        -h ipa.lab.pcfdemo.net -p 53:53/udp -p 53:53  \
        -p 80:80 -p 443:443  -p 389:389  -p 636:636 -p 88:88 -p 464:464 -p 88:88/udp \
        -p 464:464/udp -p 123:123/udp --read-only  \
        --sysctl net.ipv6.conf.all.disable_ipv6=0  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
        -v /root/freeipa-data:/data:Z  freeipa/freeipa-server:fedora-34-4.9.6

EOF
```


add to crontab to start on boot.
```
chmod +x /root/freeipa.sh

crontab -e

@reboot  /root/freeipa.sh
```


#### connect 
```
vi /etc/hosts
192.168.0.5 ipa.lab.pcfdemo.net
```

https://ipa.lab.pcfdemo.net/

add dns records
```
Network Services > DNS> DNS Zones
```

dig @192.168.0.5 test.lab.pcfdemo.net