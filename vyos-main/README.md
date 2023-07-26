# vyos-main


### on ubuntu jumpbox.
#### clone scripts.

```
git clone https://github.com/myminseok/vyos-main
cd vyos-main

```
####  edit govc.env


```
cp -r env-template /tmp/vyos-env-h2o
export ENV_DIR=/tmp/vyos-env-h2o

```

#### add_portgroup_to_vcenter 
```
./vcenter-pg-add.sh
```
#### create vyos vm.
download iso: https://vyos.net/get/nightly-builds/
and create folder to vcenter>datastore and upload the iso
edit vcenter-vyos-create-vm.sh
```
govc vm.create -annotation="TKG Networking Fabric" \
  -c=2 -iso=FILE/vyos-1.4-rolling-202211120317-amd64.iso \
  -m=2048 \
  -disk=20GB \
  -net="esxi-mgmt" \
  -net.adapter=vmxnet3 "tkg-router";
```

```
./vcenter-vyos-create-vm.sh
```

#### configure the VM.
goto vcenter UI and click console and setup the vyos VM.
```
install image
...

change password: vyos
...

```
#### assign IP to the vyos vm.

```
configure
set interfaces loopback lo # Might already exist
set interfaces ethernet eth0 # Might already exist
set interfaces ethernet eth0 address 192.168.0.4/24
set interfaces ethernet eth0 description WAN
set protocols static route 0.0.0.0/0 next-hop 192.168.0.1
```
```
set service ssh
commit 
save

```

check network.
```
vyos@vyos# ifconfig eth0
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.0.4  netmask 255.255.255.0  broadcast 192.168.0.255
        inet6 fe80::250:56ff:fe83:3403  prefixlen 64  scopeid 0x20<link>
        ether 00:50:56:83:34:03  txqueuelen 1000  (Ethernet)
        RX packets 3038  bytes 296910 (289.9 KiB)
        RX errors 0  dropped 46  overruns 0  frame 0
        TX packets 6811  bytes 856410 (836.3 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

[edit]
vyos@vyos# traceroute 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  192.168.0.1 (192.168.0.1)  0.722 ms  0.582 ms  0.523 ms
 2  * * *
 3  112.190.20.41 (112.190.20.41)  2.368 ms  2.018 ms  1.847 ms
 4  112.190.1.249 (112.190.1.249)  1.912 ms 112.190.2.249 (112.190.2.249)  5.753 ms 112.190.2.21 (112.190.2.21)  2.450 ms
 5  * * *
 6  112.174.90.50 (112.174.90.50)  20.894 ms 112.174.90.146 (112.174.90.146)  7.301 ms 112.174.90.50 (112.174.90.50)  20.111 ms
 7  112.174.84.18 (112.174.84.18)  8.790 ms 112.174.84.34 (112.174.84.34)  9.605 ms 112.174.84.62 (112.174.84.62)  9.558 ms
 8  142.250.165.78 (142.250.165.78)  31.461 ms 72.14.202.136 (72.14.202.136)  34.193 ms 142.250.165.78 (142.250.165.78)  30.456 ms
 9  * * *
10  8.8.8.8 (8.8.8.8)  31.060 ms  30.004 ms  31.980 ms
[edit]


vyos@vyos:~$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=107 time=30.3 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=106 time=30.1 ms
```


#### ssh into the vyos vm.

```
ssh vyos@192.168.0.4

vyos@192.168.0.4's password: vyos

```



#### DNS

```
vyos@vyos:~$ configure

set system name-server 10.79.2.5
set system name-server 10.79.2.6


show system name-server
 name-server 10.79.2.5
 name-server 10.79.2.6
[edit]

commit
save
exit
```


#### NTP

```
vyos@vyos:~$ configure

set system ntp server time1.oc.vmware.com
set system ntp server time2.oc.vmware.com
set system ntp server time3.oc.vmware.com
set system ntp server time4.oc.vmware.com


show system ntp
 server time1.oc.vmware.com {
 }
 server time1.vyos.net {
 }
 server time2.oc.vmware.com {
 }
 server time2.vyos.net {
 }
 server time3.oc.vmware.com {
 }
 server time3.vyos.net {
 }
 server time4.oc.vmware.com {
 }
[edit]


commit
save
exit
```


#### add port group to the vyos vm.
in the jumpbox vm,  run `vcenter-vyos-add-pg.sh`

```
vyos-main# ./vcenter-vyos-add-pg.sh
```

in vcenter UI> vyos vm> summary, the vm will have portgroups.

#### Configuring vyos vm > interface
in the jumpbox vm, 

```
vyos-main# ./vyos-command-configure-interface.sh
[DEBUG] eth3:00:50:56:83:a1:f0
eth1:00:50:56:83:45:89
eth6:00:50:56:83:97:c4
eth4:00:50:56:83:52:af
eth2:00:50:56:83:af:11
eth0:00:50:56:83:34:03
eth7:00:50:56:83:c6:a6
eth5:00:50:56:83:ea:6d

```
run the output in the vyos vm `configure` mode.
```
## SKIP portgroup "VM Network2" as there is no gateway address info in the naming
delete interfaces ethernet eth1
set interfaces ethernet eth1 address "192.168.10.1/24"
set interfaces ethernet eth1 description "nsx_alb_management_pg-192.168.10.1"
delete interfaces ethernet eth2
set interfaces ethernet eth2 address "192.168.40.1/24"
set interfaces ethernet eth2 description "tkg_mgmt_pg-192.168.40.1"
delete interfaces ethernet eth3
set interfaces ethernet eth3 address "192.168.50.1/24"
set interfaces ethernet eth3 description "tkg_mgmt_vip_pg-192.168.50.1"
delete interfaces ethernet eth4
set interfaces ethernet eth4 address "192.168.80.1/24"
set interfaces ethernet eth4 description "tkg_cluster_vip_pg-192.168.80.1"
delete interfaces ethernet eth5
set interfaces ethernet eth5 address "192.168.70.1/24"
set interfaces ethernet eth5 description "tkg_workload_vip_pg-192.168.70.1"
delete interfaces ethernet eth6
set interfaces ethernet eth6 address "192.168.60.1/24"
set interfaces ethernet eth6 description "tkg_workload_pg-192.168.60.1"

```
check and commit and save
```
vyos@vyos# show interface ethernet
 ethernet eth0 {
     address 192.168.0.4/24
     description WAN
     hw-id 00:50:56:83:34:03
 }
 ethernet eth1 {
     address 192.168.10.1/24
     description nsx_alb_management_pg-192.168.10.1
 }
 ethernet eth2 {
     address 192.168.40.1/24
     description tkg_mgmt_pg-192.168.40.1
 }
 ethernet eth3 {
     address 192.168.50.1/24
     description tkg_mgmt_vip_pg-192.168.50.1
 }
 ethernet eth4 {
     address 192.168.80.1/24
     description tkg_cluster_vip_pg-192.168.80.1
 }
 ethernet eth5 {
     address 192.168.70.1/24
     description tkg_workload_vip_pg-192.168.70.1
 }
 ethernet eth6 {
     address 192.168.60.1/24
     description tkg_workload_pg-192.168.60.1
 }
 ethernet eth7 {
     address 192.168.70.1/24
     description tkg_workload_vip_pg-192.168.70.1
     hw-id 00:50:56:83:c6:a6
 }
[edit]

vyos@vyos# commit
[edit]
vyos@vyos# save
Saving configuration to '/config/config.boot'...
Done
[edit]


```

#### Configuring vyos vm > dhcp-server
in the jumpbox vm, 
```
root@ubuntu:/data/vyos-main# ./vyos-command-configure-dhcp.sh

set service dhcp-server dynamic-dns-update
delete service dhcp-server shared-network-name nsx-alb-mgmt-network
set service dhcp-server shared-network-name nsx-alb-mgmt-network authoritative
set service dhcp-server shared-network-name nsx-alb-mgmt-network subnet 192.168.10.0/24
set service dhcp-server shared-network-name nsx-alb-mgmt-network subnet 192.168.10.0/24 default-router 192.168.10.1
...

```
copy the output and, in the vyos vm, run the output in the vyos vm `configure` mode

```
vyos@vyos:~$ configure

```
```
set service dhcp-server dynamic-dns-update
delete service dhcp-server shared-network-name nsx-alb-mgmt-network
set service dhcp-server shared-network-name nsx-alb-mgmt-network authoritative
set service dhcp-server shared-network-name nsx-alb-mgmt-network subnet 192.168.10.0/24
set service dhcp-server shared-network-name nsx-alb-mgmt-network subnet 192.168.10.0/24 default-router 192.168.10.1
set service dhcp-server shared-network-name nsx-alb-mgmt-network subnet 192.168.10.0/24 name-server 192.168.0.5
set service dhcp-server shared-network-name nsx-alb-mgmt-network subnet 192.168.10.0/24 lease 86400
set service dhcp-server shared-network-name nsx-alb-mgmt-network subnet 192.168.10.0/24 range 0 start 192.168.10.200
set service dhcp-server shared-network-name nsx-alb-mgmt-network subnet 192.168.10.0/24 range 0 stop 192.168.10.252
delete service dhcp-server shared-network-name tkg-mgmt-network
set service dhcp-server shared-network-name tkg-mgmt-network authoritative
set service dhcp-server shared-network-name tkg-mgmt-network subnet 192.168.40.0/24
set service dhcp-server shared-network-name tkg-mgmt-network subnet 192.168.40.0/24 default-router 192.168.40.1
set service dhcp-server shared-network-name tkg-mgmt-network subnet 192.168.40.0/24 name-server 192.168.0.5
set service dhcp-server shared-network-name tkg-mgmt-network subnet 192.168.40.0/24 lease 86400
set service dhcp-server shared-network-name tkg-mgmt-network subnet 192.168.40.0/24 range 0 start 192.168.40.200
set service dhcp-server shared-network-name tkg-mgmt-network subnet 192.168.40.0/24 range 0 stop 192.168.40.252
delete service dhcp-server shared-network-name tkg-workload-network
set service dhcp-server shared-network-name tkg-workload-network authoritative
set service dhcp-server shared-network-name tkg-workload-network subnet 192.168.60.0/24
set service dhcp-server shared-network-name tkg-workload-network subnet 192.168.60.0/24 default-router 192.168.60.1
set service dhcp-server shared-network-name tkg-workload-network subnet 192.168.60.0/24 name-server 192.168.0.5
set service dhcp-server shared-network-name tkg-workload-network subnet 192.168.60.0/24 lease 86400
set service dhcp-server shared-network-name tkg-workload-network subnet 192.168.60.0/24 range 0 start 192.168.60.200
set service dhcp-server shared-network-name tkg-workload-network subnet 192.168.60.0/24 range 0 stop 192.168.60.252

set service dhcp-server shared-network-name nsx-alb-mgmt-network name-server 192.168.0.5
set service dhcp-server shared-network-name tkg-mgmt-network name-server 192.168.0.5
set service dhcp-server shared-network-name tkg-workload-network name-server 192.168.0.5

```
check and commit
```

vyos@vyos# show service dhcp-server

vyos@vyos# commit

vyos@vyos# save
Saving configuration to '/config/config.boot'...
```
#### Configuring vyos vm > nat

```
vyos@vyos:~$ configure

```
run following
```
set nat source rule 1 description "allow nat outbound"
set nat source rule 1 outbound-interface eth0
set nat source rule 1 translation address masquerade
```
check and commit, save.
```
vyos@vyos# show nat

vyos@vyos# commit

vyos@vyos# save
Saving configuration to '/config/config.boot'...

```
# on Jumpbox(bootstrap machine)

add potrgroup for connectivity by running vcenter-jumpbox-add-pg.sh

https://github.com/myminseok/jumpbox-setup-main/blob/main/provision-vm/vsphere/print-vm-command-configure-interface.sh

on jumpbox, check the added ip links, identify the nic name by the mac address

```
oot@ubuntu:/data/vyos-main# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: ens160: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 00:50:56:83:a4:56 brd ff:ff:ff:ff:ff:ff
3: ens161: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 00:50:56:83:f9:55 brd ff:ff:ff:ff:ff:ff
4: ens192: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 00:50:56:83:49:81 brd ff:ff:ff:ff:ff:ff
5: ens193: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 00:50:56:83:95:3e brd ff:ff:ff:ff:ff:ff
6: ens224: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 00:50:56:83:25:63 brd ff:ff:ff:ff:ff:ff
7: ens225: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 00:50:56:83:19:3f brd ff:ff:ff:ff:ff:ff
8: ens256: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 00:50:56:83:5b:92 brd ff:ff:ff:ff:ff:ff

```
and 
```
root@ubuntu:/data/vyos-main# cat /etc/netplan/00-installer-config.yaml
# This is the network config written by 'subiquity'
network:
  version: 2
  ethernets:
    ens160:
      addresses:
      - 192.168.0.6/24
      gateway4: 192.168.0.4
      nameservers:
        addresses:
        - 192.168.0.5
    ens161:
      addresses:
      - 192.168.80.240/24
      gateway4: 192.168.80.1
    ens192:
      addresses:
      - 192.168.10.240/24
      gateway4: 192.168.10.1
    ens193:
      addresses:
      - 192.168.70.240/24
      gateway4: 192.168.20.1
    ens224:
      addresses:
      - 192.168.40.240/24
      gateway4: 192.168.40.1
    ens225:
      addresses:
      - 192.168.60.240/24
      gateway4: 192.168.60.1
    ens226:
      addresses:
      - 192.168.80.240/24
      gateway4: 192.168.80.1
```

```
netplan apply
```

```
root@ubuntu:/etc/netplan# ifconfig | grep inet | grep mask
        inet 172.18.0.1  netmask 255.255.0.0  broadcast 172.18.255.255
        inet 172.19.0.1  netmask 255.255.0.0  broadcast 172.19.255.255
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        inet 192.168.0.6  netmask 255.255.255.0  broadcast 192.168.0.255
        inet 192.168.80.240  netmask 255.255.255.0  broadcast 192.168.80.255
        inet 192.168.10.240  netmask 255.255.255.0  broadcast 192.168.10.255
        inet 192.168.70.240  netmask 255.255.255.0  broadcast 192.168.70.255
        inet 192.168.40.240  netmask 255.255.255.0  broadcast 192.168.40.255
        inet 192.168.60.240  netmask 255.255.255.0  broadcast 192.168.60.255
```


# ref
https://github.com/vmware-tanzu-labs/tanzu-validated-solutions/blob/main/src/partials/vyatta.md
