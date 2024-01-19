## 

-  ifconfig
```
apt install net-tools -y
```

## networking.

reference to 
- ubuntu-static-ip-config
- photon-static-ip

check routes
```
route add default gw 192.168.0.1
```
- user
```
groupadd ubuntu
useradd   -s /bin/bash  -m --home-dir=/home/ubuntu -G ubuntu -g ubuntu  ubuntu 
su - ubuntu
```
- hostname
```
hostnamectl set-hostname my-jumpbox-2204
```

# disk mount
https://github.com/myminseok/jumpbox-setup-main/blob/main/offline/mount.md


# docker
https://github.com/myminseok/jumpbox-setup-main/blob/main/offline/docker.md


# harbor
https://github.com/myminseok/jumpbox-setup-main/blob/main/offline/harbor.md

# jumpbox bosh
https://github.com/myminseok/jumpbox-setup-main/blob/main/offline/jumpbox-bosh.md
