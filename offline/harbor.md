
# Harbor( docker-compose)

## Preerquisites
- [IMPORTANT] should setup as ROOT and run as root.
```
sudo su
```
- docker-compose
```
/data/harbor-main/harbor# docker-compose version
docker-compose version 1.26.2, build unknown
docker-py version: 4.4.4
CPython version: 2.7.17
OpenSSL version: OpenSSL 1.1.1  11 Sep 2018
```




## download scripts
```
git clone https://github.com/myminseok/jumpbox-setup-main
```

## generate domain certificates

```
cd jumpbox-setup-main/harbor-main/generate-self-signed-cert
```

edit csr.conf
```
CN = pcfdemo.net
```
and generate.sh


## download
https://github.com/goharbor/harbor/releases
```
cd jumpbox-setup-main/harbor-main
wget https://github.com/goharbor/harbor/releases/download/v2.3.3/harbor-offline-installer-v2.3.3.tgz
wget https://github.com/goharbor/harbor/releases/download/v2.10.0/harbor-offline-installer-v2.10.0.tgz
tar xf harbor-offline-installer-v2.3.3.tgz
```

## harbor.yml
```
cd jumpbox-setup-main/harbor-main/harbor
cp harbor.yml.tmpl harbor.yml
```

##  Configure harbor.yml 
https://goharbor.io/docs/2.0.0/install-config/configure-https/

```
https:
  # https port for harbor, default is 443
  port: 443
  # The path of cert and key files for nginx
  certificate: /data/harbor-main/generate-self-signed-cert/domain.crt
  private_key: /data/harbor-main/generate-self-signed-cert/domain.key

data_volume: /data
```


```
sudo ./install.sh

sudo chown -R ubuntu:ubuntu /data/

docker-compose up
```
## insecure registry
```
root@ubuntuguest:/data/harbor-main# cat /etc/docker/daemon.json
{
  "data-root": "/data/docker",
  "insecure-registries": ["infra-harbor.lab.pcfdemo.net"]
}
```
```
systemctl restart docker
```
```
journalctl -xe -u docker
```


## restart on boot

add to crontab to start on boot.
```
chmod +x /data/harbor-main/restart-harbor.sh

crontab -e

@reboot  /root/start-freeipa.sh
```


# troubleshooting

## wget download failure
```
wget https://cli.run.pivotal.io/stable?release=debian64&source=github

root@DojoJump:/etc/ssl# --2019-04-09 16:29:55-- https://cli.run.pivotal.io/stable?release=debian64
Resolving cli.run.pivotal.io (cli.run.pivotal.io)... 34.204.136.114, 34.194.131.211
Connecting to cli.run.pivotal.io (cli.run.pivotal.io)|34.204.136.114|:443... connected.
ERROR: cannot verify cli.run.pivotal.io's certificate, issued by emailAddress=admin@abc.com,CN=ABC,OU=ABC,O=ABC,L=ABC,ST=ABC,C=KR:
Self-signed certificate encountered.
To connect to cli.run.pivotal.io insecurely, use `--no-check-certificate'

```

## how to import ABC corp certificate
```
1) export ABC corp cert(DER format)
2) copy to External jumpbox (ubuntu)
3) convert DER to PEM

openssl x509 -inform der -outform pem -in ABC.cer -out ABC.pem

4) cp ABC.pem /usr/local/share/ca-certificates/ABC.crt
Please note that the certificate filenames have to end in .crt, otherwise the update-ca-certificates script won't pick up on them.

5) root@DojoJump:/etc/ssl# update-ca-certificates
Updating certificates in /etc/ssl/certs...
1 added, 0 removed; done.

wget https://cli.run.pivotal.io/stable?release=debian64&source=github
```

## docker login fails

```
Error saving credentials: error storing credentials - err: exit status 1, out: `Cannot autolaunch D-Bus without X11 $DISPLAY`
```
```
sudo apt remove golang-docker-credential-helpers 
```

## docker login fails with `failed with status: 401 Unauthorized`
try on another ssh session
```
root@ubuntuguest:/data/harbor-main/harbor# docker login https://infra-harbor2.lab.pcfdemo.net/ -u admin  -p VMware1!
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
Error response from daemon: login attempt to https://infra-harbor2.lab.pcfdemo.net/v2/ failed with status: 401 Unauthorized
```


