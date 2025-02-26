# vyos-main

update to vyos-1.5-rolling-202502190007-generic-amd64.iso (https://vyos.net/get/nightly-builds/)


### on ubuntu jumpbox.
#### jumpbox) clone scripts.

```
git clone https://github.com/myminseok/vyos-main
cd vyos-main

```
####  jumpbox)  edit govc.env


```
cp -r env-template /tmp/vyos-env-h2o
export ENV_DIR=/tmp/vyos-env-h2o

```

# add port group to vcenter
add port group to vcenter by running vcenter-add-pg.sh
```
jumpbox) vcenter-pg-add.sh
```

#### jumpbox) upload vyos iso
download iso: https://vyos.net/get/nightly-builds/
and create folder to vcenter> datastore #> FILE and upload the iso

#### jumpbox) create vyos vm.
edit vyos-vm-create.sh
```
govc vm.create -annotation="TKG Networking Fabric" \
  -c=2 -iso=FILE/vyos-1.4-rolling-202211120317-amd64.iso \
  -m=2048 \
  -disk=20GB \
  -net="esxi-mgmt" \
  -net.adapter=vmxnet3 "tkg-router";
```

```
./vyos-vm-create.sh

TIP: customizing env
  cp -r env-template /tmp/vyos-env-dev
  export ENV_DIR=/tmp/vyos-env-dev

  then run script 

Using env from '/tmp/vyos-env-h2o'
+ govc vm.create '-annotation=TKG Networking Fabric' -c=2 -iso=vyos-1.5-rolling-202502190007-generic-amd64.iso -m=2048 -disk=20GB '-net=VM Network' -net.adapter=vmxnet3 tkg-router
```


#### vcenter UI) configure the VM.
goto vcenter UI and click console and setup the vyos VM.
https://docs.vyos.io/en/sagitta/installation/install.html
```
sudo su

install image
...

change password: vyos
...

sudo reboot -n

```
#### vcenter UI) assign IP to the vyos vm.

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


#### jumpbox) ssh into the vyos vm.

```
ssh vyos@192.168.0.4

vyos@192.168.0.4's password: vyos

```



#### DNS

```
vyos@vyos:~$ configure

set system name-server 192.168.0.5


show system name-server
 name-server 10.79.2.5
[edit]

commit
save
exit
```


#### NTP

```
vyos@vyos:~$ configure

set service ntp server 192.168.0.5


allow-client {
     address 127.0.0.0/8
     address 169.254.0.0/16
     address 10.0.0.0/8
     address 172.16.0.0/12
     address 192.168.0.0/16
     address ::1/128
     address fe80::/10
     address fc00::/7
 }
+server 192.168.0.5 {
+}
 server time1.vyos.net {
 }
 server time2.vyos.net {
 }
 server time3.vyos.net {
 }
[edit]


commit
save
exit
```


#### add port group to the vyos vm.
in the jumpbox vm,  run `vm-add-pg.sh`

```
 vyos-main git:(main) ✗ ./vm-add-pg.sh                        
TIP: customizing env
  cp -r env-template /tmp/vyos-env-dev
  export ENV_DIR=/tmp/vyos-env-dev

  then run script 

Using env from '/tmp/vyos-env-h2o'

Enter VM name to be created (hit enter key for default: tkg-router): 

Are you sure the target 'tkg-router'? (Y/y) y
+ govc vm.network.add -vm=tkg-router -net.adapter=vmxnet3 -net=nsx_alb_management_pg-192.168.10.1
+ govc vm.network.add -vm=tkg-router -net.adapter=vmxnet3 -net=tkg_mgmt_pg-192.168.40.1
+ govc vm.network.add -vm=tkg-router -net.adapter=vmxnet3 -net=tkg_mgmt_vip_pg-192.168.50.1
+ govc vm.network.add -vm=tkg-router -net.adapter=vmxnet3 -net=tkg_cluster_vip_pg-192.168.80.1
+ govc vm.network.add -vm=tkg-router -net.adapter=vmxnet3 -net=tkg_workload_vip_pg-192.168.70.1
+ govc vm.network.add -vm=tkg-router -net.adapter=vmxnet3 -net=tkg_workload_pg-192.168.60.1
```

in vcenter UI> vyos vm> summary, the vm will have portgroups.

#### Configuring vyos vm > interface
in the jumpbox vm, 

vi /tmp/vyos-env-h2o/common.env
```
## generate-vyos-command-configure-interface.sh
export VYOS_VM_IP=192.168.0.4
```

```
vyos-main# ./generate-vyos-command-configure-interface.sh
[DEBUG] eth3:00:50:56:83:a1:f0
eth1:00:50:56:83:45:89
eth6:00:50:56:83:97:c4
eth4:00:50:56:83:52:af
eth2:00:50:56:83:af:11
eth0:00:50:56:83:34:03
eth7:00:50:56:83:c6:a6
eth5:00:50:56:83:ea:6d

...

configure
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
show interface ethernet

```
run the output from above starting "configure" line in the vyos vm on `configure` mode. 

SKIP portgroup "VM Network2" as there is no gateway address info in the naming

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
root@ubuntu:/data/vyos-main# ./generate-vyos-command-configure-dhcp.sh

configure
set service dhcp-server dynamic-dns-update
delete service dhcp-server shared-network-name nsx-alb-mgmt-network
set service dhcp-server shared-network-name nsx-alb-mgmt-network authoritative
set service dhcp-server shared-network-name nsx-alb-mgmt-network subnet 192.168.10.0/24
set service dhcp-server shared-network-name nsx-alb-mgmt-network subnet 192.168.10.0/24 subnet-id 192168100
set service dhcp-server shared-network-name nsx-alb-mgmt-network subnet 192.168.10.0/24 option default-router 192.168.10.1
set service dhcp-server shared-network-name nsx-alb-mgmt-network subnet 192.168.10.0/24 option name-server 8.8.8.8
set service dhcp-server shared-network-name nsx-alb-mgmt-network subnet 192.168.10.0/24 lease 86400
set service dhcp-server shared-network-name nsx-alb-mgmt-network subnet 192.168.10.0/24 range 0 start 192.168.10.20
set service dhcp-server shared-network-name nsx-alb-mgmt-network subnet 192.168.10.0/24 range 0 stop 192.168.10.252
delete service dhcp-server shared-network-name tkg-mgmt-network
set service dhcp-server shared-network-name tkg-mgmt-network authoritative
set service dhcp-server shared-network-name tkg-mgmt-network subnet 192.168.40.0/24
set service dhcp-server shared-network-name tkg-mgmt-network subnet 192.168.40.0/24 subnet-id 192168400
set service dhcp-server shared-network-name tkg-mgmt-network subnet 192.168.40.0/24 option default-router 192.168.40.1
set service dhcp-server shared-network-name tkg-mgmt-network subnet 192.168.40.0/24 option name-server 8.8.8.8
set service dhcp-server shared-network-name tkg-mgmt-network subnet 192.168.40.0/24 lease 86400
set service dhcp-server shared-network-name tkg-mgmt-network subnet 192.168.40.0/24 range 0 start 192.168.40.20
set service dhcp-server shared-network-name tkg-mgmt-network subnet 192.168.40.0/24 range 0 stop 192.168.40.252
delete service dhcp-server shared-network-name tkg-workload-network
set service dhcp-server shared-network-name tkg-workload-network authoritative
set service dhcp-server shared-network-name tkg-workload-network subnet 192.168.60.0/24
set service dhcp-server shared-network-name tkg-workload-network subnet 192.168.60.0/24 subnet-id 192168460
set service dhcp-server shared-network-name tkg-workload-network subnet 192.168.60.0/24 option default-router 192.168.60.1
set service dhcp-server shared-network-name tkg-workload-network subnet 192.168.60.0/24 option name-server 8.8.8.8
set service dhcp-server shared-network-name tkg-workload-network subnet 192.168.60.0/24 lease 86400
set service dhcp-server shared-network-name tkg-workload-network subnet 192.168.60.0/24 range 0 start 192.168.60.20
set service dhcp-server shared-network-name tkg-workload-network subnet 192.168.60.0/24 range 0 stop 192.168.60.252

set service dhcp-server shared-network-name nsx-alb-mgmt-network name-server 8.8.8.8
set service dhcp-server shared-network-name tkg-mgmt-network name-server 8.8.8.8
set service dhcp-server shared-network-name tkg-workload-network name-server 8.8.8.8
set service dhcp-server shared-network-name nsx-alb-mgmt-network name-server 4.4.4.4
set service dhcp-server shared-network-name tkg-mgmt-network name-server 4.4.4.4
set service dhcp-server shared-network-name tkg-workload-network name-server 4.4.4.4
show service dhcp-server
...

```
copy the output and, in the vyos vm, run the output in the vyos vm `configure` mode

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
set nat source rule 1 outbound-interface name eth0
set nat source rule 1 translation address masquerade
```
check and commit, save.
```
vyos@vyos# show nat

vyos@vyos# commit

vyos@vyos# save
Saving configuration to '/config/config.boot'...

```
# add port group to any target vm(jumpbox)
```
➜  vyos-main git:(main) ✗ ./vm-add-pg.sh                        
TIP: customizing env
  cp -r env-template /tmp/vyos-env-dev
  export ENV_DIR=/tmp/vyos-env-dev

  then run script 

Using env from '/tmp/vyos-env-h2o'

Enter VM name to be created (hit enter key for default: tkg-router): pivotal-ops-manager3.0.37

Are you sure the target 'pivotal-ops-manager3.0.37'? (Y/y) y
+ govc vm.network.add -vm=pivotal-ops-manager3.0.37 -net.adapter=vmxnet3 -net=nsx_alb_management_pg-192.168.10.1
+ govc vm.network.add -vm=pivotal-ops-manager3.0.37 -net.adapter=vmxnet3 -net=tkg_mgmt_pg-192.168.40.1
+ govc vm.network.add -vm=pivotal-ops-manager3.0.37 -net.adapter=vmxnet3 -net=tkg_mgmt_vip_pg-192.168.50.1
+ govc vm.network.add -vm=pivotal-ops-manager3.0.37 -net.adapter=vmxnet3 -net=tkg_cluster_vip_pg-192.168.80.1
+ govc vm.network.add -vm=pivotal-ops-manager3.0.37 -net.adapter=vmxnet3 -net=tkg_workload_vip_pg-192.168.70.1
+ govc vm.network.add -vm=pivotal-ops-manager3.0.37 -net.adapter=vmxnet3 -net=tkg_workload_pg-192.168.60.1
```


```
➜  vyos-main git:(main) ✗ ./generate-vm-command-configure-network.sh 
TIP: customizing env
  cp -r env-template /tmp/vyos-env-dev
  export ENV_DIR=/tmp/vyos-env-dev

  then run script 

Using env from '/tmp/vyos-env-h2o'
Enter VM IP: 192.168.0.6
Enter VM name: jumpbox-2004
Enter VM user name: ubuntu
[DEBUG] interface list
ens224:00:50:56:95:f6:0e
veth8d64a2b:12:46:f4:6d:7f:b6
ens192:00:50:56:95:79:ba
docker0:02:42:71:52:f1:90
ens257:00:50:56:95:53:f3
vethbbb32cf:a6:d6:c5:19:86:ed
veth242dc8d:c6:58:54:8a:92:d3
br-96524863a94e:02:42:0b:e4:f0:a5
ens225:00:50:56:95:fc:fd
br-5bb3d2261723:02:42:de:66:f0:14
br-4b64f96920f8:02:42:91:8e:79:d1
veth48cd29b:9a:92:90:3a:dc:b8
veth3bde313:62:50:7b:c9:d2:77
ens193:00:50:56:95:a6:77
veth90f1ef3:de:f2:ca:3c:18:cb
veth041fc23:6a:0d:a3:77:c4:f0
br-c7957bf1ba3d:02:42:77:5d:f8:82
ens256:00:50:56:95:a1:f3
ens161:00:50:56:95:6b:5a
veth4199084:5e:45:88:49:b3:f7
veth0d7952a:fe:d1:51:e6:20:d1

[DEBUG] VM device list
00:50:56:95:f6:0e;nsx_alb_management_pg-192.168.10.1
00:50:56:95:a1:f3;tkg_mgmt_pg-192.168.40.1
00:50:56:95:6b:5a;tkg_mgmt_vip_pg-192.168.50.1
00:50:56:95:a6:77;tkg_cluster_vip_pg-192.168.80.1
00:50:56:95:fc:fd;tkg_workload_vip_pg-192.168.70.1
00:50:56:95:53:f3;tkg_workload_pg-192.168.60.1

configure following command on VM
/etc/netplan/50-cloud-init.yaml
netplan apply
--------------------------

# existing network config.
network:
    version: 2
    ethernets:
        ens192:
            dhcp4: no
            addresses:
            - 10.220.15.90/27
            gateway4: 10.220.15.94
            nameservers:
              addresses: [10.79.2.5]
            match:
              macaddress: ...

# TKG network config.
        ens224: # nsx_alb_management_pg-192.168.10.1
            dhcp4: no
            addresses:
            - 192.168.10.199/24
        ens256: # tkg_mgmt_pg-192.168.40.1
            dhcp4: no
            addresses:
            - 192.168.40.199/24
        ens161: # tkg_mgmt_vip_pg-192.168.50.1
            dhcp4: no
            addresses:
            - 192.168.50.199/24
        ens193: # tkg_cluster_vip_pg-192.168.80.1
            dhcp4: no
            addresses:
            - 192.168.80.199/24
        ens225: # tkg_workload_vip_pg-192.168.70.1
            dhcp4: no
            addresses:
            - 192.168.70.199/24
        ens257: # tkg_workload_pg-192.168.60.1
            dhcp4: no
            addresses:
            - 192.168.60.199/24
```



```
# on jumpbox, check the added ip links, identify the nic name by the mac address
root@ubuntuguest:/etc/netpla# ip link show

# update 
root@ubuntuguest:/etc/netplan# vi /etc/netplan/50-cloud-init.yaml

# apply
root@ubuntuguest:/etc/netplan# netplan apply

# check
root@ubuntuguest:/etc/netplan# ifconfig | grep inet | grep mask
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
