# Provisioning Jumpbox on Target Network on vSphere environment

## Prerequisites

### CLIs and OVAs
following files are required and can be download with the provided scripts. if no internet access, please download one inadvance.
- [govc](https://github.com/vmware/govmomi/releases/): (mandatory)
- [ubuntu ova](https://cloud-images.ubuntu.com/releases/bionic/release/): (mandatory) ubuntu cloud images is small enough for jumpbox purpose. please note that the Tanzu OVA such as photon, ubuntu is compatible.
- [jq] : (mandatory) json parsor. `apt-get install jq`
- [expect] : (optional) used for changing password for the newly created vm with script. `apt-get install expect` on ubuntu or `brew install expect` on OSx

### DHCP on target network 
- DHCP for the IP assignment to the new VM should be ready on the target network.

## Runbook

### prepare `vm-deployment.env` and `govc.env` file.

clone this project repo.
go to script directory for the target cloud. for example, following folder for `vsphere` cloud

```
cp -r env-template /tmp/env-dev
export ENV_DIR=/tmp/env-dev
```

edit `vm-deployment.env` file
```
## set to proper location to save the downloaded ova file. ie) '/tmp'
## place the download all of OVAs here for airgapped env.
## please note that the executable $PATH_TO_DOWNLOAD/govc need to be copoed to /usr/local/bin/govc manually.
PATH_TO_DOWNLOAD="/tmp"

## OVA formatted file only, due to ssh-key injection with 'govc'. any OS should works.
VM_OVA_SOURCE_URL=https://cloud-images.ubuntu.com/releases/bionic/release/ubuntu-18.04-server-cloudimg-amd64.ova
```

### Download Prerequisites For Air-gapped Env
download the ova to to `PATH_TO_DOWNLOAD` path defined in `vm-deployment.env` file in-advance for example, 
```
/tmp/ubuntu-18.04-server-cloudimg-amd64.ova
```
#### Setup govc (1-govc-download.sh) (internet access required)
download `govc` that matches to your OS and Arch to `PATH_TO_DOWNLOAD` path defined in `vm-deployment.env` file. 
```
/tmp/govc_Darwin_arm64.tar.gz
/tmp/govc
```
please notice that you need to copy the executable $PATH_TO_DOWNLOAD/govc to /usr/local/bin/govc manually.

#### Download OVA (2-ova-download.sh): internet access required
download the ova file that defined as `VM_OVA_SOURCE_URL` in `vm-deployment.env` to `PATH_TO_DOWNLOAD`. for `Air-gapped` env, download the ova to to `PATH_TO_DOWNLOAD` inadvance manually. for example,
```
/tmp/ubuntu-18.04-server-cloudimg-amd64.ova
```
#### Upload VM template with default network (3-vm-template-upload.sh)
it will upload the OVA as a VM template(OVA name + "-template') with following spec with the params from `vm-deployment.env` file. the template name will be 'OVA name' such as `ubuntu-18.04-server-cloudimg-amd64.ova`

```
./3-vm-template-upload.sh
Extracting ova spec file ... from /tmp/ubuntu-18.04-server-cloudimg-amd64.ova
Generating govc option file ... /tmp/ubuntu-18.04-server-cloudimg-amd64.ova-template___VM_Network___govc_options.json
Successfully Generated govc option file: /tmp/ubuntu-18.04-server-cloudimg-amd64.ova-template___VM_Network___govc_options.json

Uploading VM Template ubuntu-18.04-server-cloudimg-amd64.ova
[14-10-22 22:07:25] Warning: Line 107: Unable to parse 'enableMPTSupport' for attribute 'key' on element 'Config'.
[14-10-22 22:08:11] Uploading ubuntu-bionic-18.04-cloudimg.vmdk... OK
[14-10-22 22:08:11] Marking VM as template...
Successfully uploaded the VM template
```

#### Clone vm and replace the default with new network (4-vm-clone.sh)
it will clone the vm template with VM spec defined in  `vm-deployment.env` file. it will ask `VM name` and `VM network` params to customize optionally.
- 1 cpu
- 1 GB mem
- 50GB VM disk(default)

the `VM network` for this VM will be configured for DHCP by default. so make sure this `VM network` has DHCP to get IP assigned properly. 
```
./4-vm-clone.sh
```
you can also give custom `VM name` and new `VM network` params to provision VM WITHOUT any prompt. the new network name will replace the default network from the template. 
```
./4-vm-clone.sh preflight-jumpbox-mgmt "VM Network"
```
example output as following
```
./4-vm-clone.sh preflight-jumpbox-mgmt "VM Network"
Cloning VM 'preflight-jumpbox-mgmt' from template 'ubuntu-18.04-server-cloudimg-amd64.ova' ...
[14-10-22 22:08:54] Cloning /Datacenter/vm/ubuntu-18.04-server-cloudimg-amd64.ova-template to preflight-jumpbox-mgmt...OK

Current Network adapters of VM 'preflight-jumpbox-mgmt'
VM Network
Powering on VirtualMachine:vm-47015... OK
Name:           preflight-jumpbox-mgmt
  Path:         /Datacenter/vm/preflight-jumpbox-mgmt
  UUID:         4203c37e-b906-ebd6-98ab-7865fb013df2
  Guest name:   Ubuntu Linux (64-bit)
  Memory:       1024MB
  CPU:          1 vCPU(s)
  Power state:  poweredOn
  Boot time:    2022-10-14 13:08:56.614612 +0000 UTC
  IP address:   192.168.0.150
  Host:         192.168.0.2
Successfully Provisioned the VM successfully.

TIPs:
after the vm assigned IP, try to ssh into the vm with 'ubuntu' account. ex) ssh ubuntu@IP -i ~/.ssh/id_rsa

```
in a few minutes, you will get the VM info with IP address. 

#### (Optional) Change the Default VM Password (5-vm-password-change-for-ubuntu-cloudimage.sh): Ubuntu Cloud Image OVA only
ubuntu OVA image requires to change the default password(`VM_PASSWORD_TEMP`) on the first login. just running `5-vm-password-change-for-ubuntu-cloudimage.sh` script will do the work for you(setting  `VM_PASSWORD` from `vm-deployment.env`). please note that `5-vm-password-change-for-ubuntu-cloudimage.sh` will be invoked in `4-vm-clone.sh`.

#### SSH into the vm(5-vm-ssh.sh)
access to the vm with ssh key that matches to the `VM_SSH_PUBLIC_KEY` in the `vm-deployment.env` file. for example,
```
ssh ubuntu@192.168.0.107 -i ~/.ssh/id_rsa
```
or just run following script with vm name.
```
./5-vm-ssh.sh preflight-jumpbox-mgmt
```

#### (Optional) Fetch VM info and IP (6-vm-info.sh)
you may get VM info with following command.
```
./6-vm-info.sh preflight-jumpbox-mgmt
```


#### Restart VM (6-vm-restart.sh)
you may delete VM info with following command.
```
./6-vm-restart.sh preflight-jumpbox-mgmt
```

#### Add more networks to the VM (7-vm-nic-add.sh)
to be able to communicate to other network, it need to add additional port group to the vm. for example,
```
./7-vm-nic-add.sh preflight-jumpbox-mgmt tkg_mgmt_pg-192.168.40.1
./7-vm-nic-add.sh preflight-jumpbox-workload tkg_workload_pg-192.168.60.1
```
please note that, To get IP assigned properly, the new NIC should be configured in the vm network configuration manually.
  1. ssh into the VM and Modify network for this NIC
  2. identify device name such as 'ens224' with command: ip link show"
  3. and set the device with dncp enabled in /etc/netplan/50-cloud-init.yaml"
```
  network:
    ethernets:
        ens192:
            dhcp4: true
            match:
                macaddress: 00:50:56:83:1e:58
            set-name: ens192
        ens224:
            dhcp4: true
    version: 2

```
```
network:
    ethernets:
        id0:
            dhcp4: false
            dhcp6: false
            match:
                macaddress: 00:50:56:9d:84:fe
            set-name: eth0
            addresses:
            - 192.168.0.6/16
            gateway4: 192.168.0.1
            nameservers:
              addresses: [8.8.8.8]
            wakeonlan: true
```

  4. apply with command: sudo netplan apply
  5. check the IP assngned: ifconfig

Refer to  samples from : https://github.com/myminseok/jumpbox-setup-main/tree/main/ubuntu-static-ip-config/ubuntu/netplan

### mount disk
https://github.com/myminseok/jumpbox-setup-main/blob/main/offline/docker.md

#### Delete VM (9-vm-destroy.sh)
you may delete VM info with following command.
```
./9-vm-destroy.sh jumpbox-mgmt
```


#### 
go to script directory for the target cloud. for example, following folder for `vsphere` cloud
```
cp -r env-template /tmp/env-dev
export ENV_DIR=/tmp/env-dev
```

