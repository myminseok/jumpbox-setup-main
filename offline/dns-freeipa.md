

# DNS using FreeIPA on ubuntu

## setup docker.

### prepare ubuntu

You must make sure these network ports are open:
```
        TCP Ports:
                * 80, 443: HTTP/HTTPS
                * 389, 636: LDAP/LDAPS
                * 88, 464: kerberos
                * 53: bind
        UDP Ports:
                * 88, 464: kerberos
                * 53: bind
                * 123: ntp
```

disable port 53
```
systemctl disable bind9
systemctl stop bind9


systemctl disable systemd-resolved.service
systemctl stop systemd-resolved.service
```
configure



### INSTALL freeipa with docker

mkdir -p /root/freeipa40-data

cat > /root/install-freeipa.sh <<EOF
```
docker run    --rm   --name freeipa-server  -ti  \
        -h ipa.lab.pcfdemo.net -p 53:53/udp -p 53:53  \
        -p 80:80 -p 443:443  -p 389:389  -p 636:636 -p 88:88 -p 464:464 -p 88:88/udp \
        -p 464:464/udp  --read-only -e PASSWORD="VMware1!"  \
        --sysctl net.ipv6.conf.all.disable_ipv6=0  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
        -v /root/freeipa40-data:/data:Z  freeipa/freeipa-server:fedora-40
```
> `/root/freeipa40-data` is your directory on jumpbox. `/data:Z` will be on container. such as `/data/etc/named...`
> ntp(123) is not working in freeIPA. so remove `-p 123:123/udp`. setup [ntp](ntp.md)



### configure dns forwarders

```
vi /data/freeipa40-data/etc/named/ipa-options-ext.conf


/* User customization for BIND named
 *
 * This file is included in /etc/named.conf and is not modified during IPA
 * upgrades.
 *
 * It must only contain "options" settings. Any other setting must be
 * configured in /data/etc/named/ipa-ext.conf.
 *
 * Examples:
 * allow-recursion { trusted_network; };
 * allow-query-cache { trusted_network; };
 */

/* turns on IPv6 for port 53, IPv4 is on by default for all ifaces */
listen-on-v6 { any; };

/* dnssec-enable is obsolete and 'yes' by default */
dnssec-validation no;        // Add this!! 
recursion yes;               // Add this!! 
allow-recursion { any; };    // Add this!! 
allow-recursion-on { any; }; // Add this!! 

``` 

### start freeipa on boot: add to crontab

script to run as background. add `--detach ` option.
```
cat > /root/start-freeipa.sh <<EOF

#!/bin/bash

docker run  --detach  --rm   --name freeipa-server  -ti  \
        -h ipa.lab.pcfdemo.net -p 53:53/udp -p 53:53  \
        -p 80:80 -p 443:443  -p 389:389  -p 636:636 -p 88:88 -p 464:464 -p 88:88/udp \
        -p 464:464/udp  --read-only -e PASSWORD="VMware1!"  \
        --sysctl net.ipv6.conf.all.disable_ipv6=0  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
        -v /root/freeipa40-data:/data:Z  freeipa/freeipa-server:fedora-40

EOF
```
> `/root/freeipa40-data` is your directory on jumpbox. `/data:Z` will be on container. such as `/data/etc/named...`
> ntp(123) is not working in freeIPA. so remove `-p 123:123/udp`. setup [ntp](ntp.md)

add to crontab to start on boot.
```
chmod +x /root/start-freeipa.sh

crontab -e

@reboot  /root/start-freeipa.sh
```


#### connect to ipa portal.
```
vi /etc/hosts
192.168.0.5 ipa.lab.pcfdemo.net
```

https://ipa.lab.pcfdemo.net/ root / VMware1!

- You will be required to login with the user admin and the password you created during the installation.
  
add dns records
```
Network Services > DNS> DNS Zones
```
test
```
dig @192.168.0.5 test.lab.pcfdemo.net

```

#### test
connect to other jumpbox wehere it points to freeipa dns.
```
root@jumpbox-2004:~#  systemd-resolve --status | grep DNS
  ...
  Current DNS Server: 192.168.0.5
         DNS Servers: 192.168.0.5


root@jumpbox-2004:~# cat /etc/resolv.conf
nameserver 127.0.0.53
options edns0 trust-ad

```

```
dig @192.168.0.5 projects.registry.vmware.com

; <<>> DiG 9.16.1-Ubuntu <<>> @192.168.0.5 projects.registry.vmware.com
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 55461
;; flags: qr rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: f245926620cf89a50100000065ade266220a3f25ad04f395 (good)
;; QUESTION SECTION:
;projects.registry.vmware.com.	IN	A

;; ANSWER SECTION:
projects.registry.vmware.com. 3214 IN	CNAME	s14749d.vmware.com.edgekey.net.
s14749d.vmware.com.edgekey.net.	21600 IN CNAME	e14749.dsce4.akamaiedge.net.
e14749.dsce4.akamaiedge.net. 20	IN	A	184.30.161.126

;; Query time: 292 msec
;; SERVER: 192.168.0.5#53(192.168.0.5)
;; WHEN: Mon Jan 22 03:35:02 UTC 2024
;; MSG SIZE  rcvd: 186

ping projects.registry.vmware.com
PING e14749.dsce4.akamaiedge.net (104.74.52.45) 56(84) bytes of data.
64 bytes from a104-74-52-45.deploy.static.akamaitechnologies.com (104.74.52.45): icmp_seq=1 ttl=44 time=146 ms
64 bytes from a104-74-52-45.deploy.static.akamaitechnologies.com (104.74.52.45): icmp_seq=2 ttl=44 time=146 ms
```


## troubleshooting

```
root@ubuntu:~/freeipa-data/etc/named# docker ps
CONTAINER ID   IMAGE                                    COMMAND                  CREATED         STATUS         PORTS                                                                                                                                                                                                                                                                                                                                                                                                                     NAMES
2351517086a4   freeipa/freeipa-server:fedora-34-4.9.6   "/usr/local/sbin/init"   6 minutes ago   Up 6 minutes   0.0.0.0:53->53/tcp, :::53->53/tcp, 0.0.0.0:80->80/tcp, 0.0.0.0:53->53/udp, :::80->80/tcp, :::53->53/udp, 0.0.0.0:88->88/udp, :::88->88/udp, 0.0.0.0:88->88/tcp, :::88->88/tcp, 0.0.0.0:389->389/tcp, :::389->389/tcp, 0.0.0.0:443->443/tcp, :::443->443/tcp, 0.0.0.0:464->464/tcp, :::464->464/tcp, 0.0.0.0:636->636/tcp, 0.0.0.0:464->464/udp, :::636->636/tcp, :::464->464/udp   freeipa-server

```

## reference
- https://computingforgeeks.com/install-and-configure-freeipa-server-on-ubuntu/
- https://computingforgeeks.com/run-freeipa-server-in-docker-podman-containers/

