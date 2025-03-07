
# install docker engine
https://docs.docker.com/engine/install/ubuntu/
```
sudo apt update

apt-get upgrade -y


```
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo   "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

```
sudo apt update
```
```
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
```

```
sudo docker run hello-world
sudo docker ps -a
```


# relocate docker root directory to new mount.

```

cat >/etc/docker/daemon.json << EOF
{
  "data-root": "/data/docker"
}
EOF

```

```
sudo rsync -aP /var/lib/docker/ /data/docker
sudo mv /var/lib/docker /var/lib/docker.old
sudo service docker start
```

### add `docker` group to `ubuntu` user
```
sudo usermod -g docker ubuntu
```
re-login
```
id
uid=1000(ubuntu) gid=998(docker) groups=998(docker),4(adm),20(dialout),24(cdrom),25(floppy),27(sudo),29(audio),30(dip),44(video),46(plugdev),117(netdev),118(lxd)


docker ps


```

# install docker engine env

- 외부에서 내려받은 다커 이미지를 내부 하버에 밀어넣기 위해 내부 점프박스에 다커 엔진이 필요하다. 
- 외부 점프박스에서 받아 설치해보고 내부 점프박스에 설치.

```
apt-get download libltdl7
apt download docker.io
dpkg -i libltdl7_2.4.6-0.1_amd64.deb 
dpkg -i docker.io_18.09.2-0ubuntu1~16.04.1_amd64.deb 
apt-get install -f
root@TLKPCFJB1:/home/ubuntu# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

```
# kind

https://kind.sigs.k8s.io/docs/user/quick-start/#installing-from-release-binaries
```
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```


# docker-compose
install docker compose
```
sudo apt install docker-compose -y

sudo reboot -n

```
reboot vm.


## test docker-compose

```
git clone https://github.com/myminseok/nginx-ssl-main.git

cd nginx-ssl-main/generate-self-signed-cert 

git submodule init

git submodule update

generate.sh

cd nginx-ssl-main/nginx-docker-compose/

docker-compose up

```


# !!!!! WARNING: alternative if above way is failing

WARNING this method doesn't work ubuntu 2004.

```
sudo apt install docker-compose -y
```
> this prevent error on executing `pip3 install setuptools-rust`
>> ERROR: launchpadlib 1.10.13 requires testresources, which is not installed.
```
sudo apt remove docker-compose -y
```
```
sudo apt install python3-pip -y
```
```
sudo pip3 install setuptools-rust
```
```
sudo pip3 install --upgrade pip
```

```
pip3 install docker-compose
```

reboot vm.


