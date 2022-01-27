# How to run gitlab in air-gapped env.

## On internet facing Network

1. prepare VM by following [preparing jumpbox VM](https://github.com/myminseok/jumpbox-setup-main/blob/main/offline/jumpbox.md)
- ubuntu 20.04
- docker engine installed

2. download gitlab docker image
```
git clone https://github.com/myminseok/jumpbox-setup-main
cd gitlab-main/docker-compose

docker save gitlab/gitlab-ce:latest -o ./gitlab-ce_latest
```
3. copy director `gitlab-main/docker-compose` to internal VM.

## On internal VM.
1. design installation parameters
- gitlab domain: gitlab.lab.pcfdemo.net
- jumpbox IP where the gitlab docker-compose will be running: 192.168.0.6 
- gitlab data root folder: /data/gitlab-data
 
2. prepare VM by following [preparing jumpbox VM](https://github.com/myminseok/jumpbox-setup-main/blob/main/offline/jumpbox.md)
- ubuntu 20.04
- docker engine installed

3. load docker image
```
cd ./gitlab-main/docker-compose
docker load -i ./gitlab-ce_latest
```
4. generate self-signed certs
```
vi gitlab-main/docker-compose/generate-self-signed-cert/openssl-domain.conf

[ alt_names ]
DNS.1 = gitlab.lab.pcfdemo.net
IP.1   = 127.0.0.1
IP.2 = 192.168.0.6
```
> DNS.1 : domain name for gitlab server.
> IP.2. : put jumpbox IP where the gitlab docker-compose will be running.

5. generate certs by running generate.sh
```
cd gitlab-main/docker-compose/generate-self-signed-cert/
./generate.sh
```
6. copy certs to gitlab data folder.
```
mkdir -p /data/gitlab-data/config/ssl
cd ./gitlab-main/docker-compose
cp  ./generate-self-signed-cert/domain.crt /data/gitlab-data/config/ssl/gitlab.lab.pcfdemo.net.crt
cp  ./generate-self-signed-cert/domain.key /data/gitlab-data/config/ssl/gitlab.lab.pcfdemo.net.key
```

7. edit docker-compose.yml
```
cd ./gitlab-main/docker-compose
vi ./docker-compose.yml

web:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: 'gitlab.lab.pcfdemo.net'
  environment:
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'https://gitlab.lab.pcfdemo.net'
      #external_url 'http://gitlab.lab.pcfdemo.net'
      # Add any other gitlab.rb configuration here, each on its own line
      gitlab_rails['initial_root_password'] = 'VMware1!'
      gitlab_rails['display_initial_root_password'] = true
      letsencrypt['enable'] = false
      gitlab_rails['gitlab_shell_ssh_port'] = 2222
  ports:
    - '80:80'
    - '443:443'
    # - '22:22'
    - '2222:22'
  volumes:
    - '/data/gitlab-data/config:/etc/gitlab'
    - '/data/gitlab-data/logs:/var/log/gitlab'
    - '/data/gitlab-data/data:/var/opt/gitlab'
  ```
  
8. run docker-compose
```
docker-compose up -d
```
9. configure DNS or /etc/hosts
```
192.168.0.5 gitlab.lab.pcfdemo.net
```
10. access gitlab
```
open https://gitlab.lab.pcfdemo.net
```
  
