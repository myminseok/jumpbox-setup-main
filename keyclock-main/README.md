

## keyclock 
OIDC, SAML

install java : https://davelogs.tistory.com/71

```
$ sudo apt-get update
$ sudo apt-get upgrade
$ sudo apt-get install openjdk-17-jdk

sudo apt-get purge openjdk*

```


```
mkdir -p /data/keyclock-main
cd /data/keyclock-main
cp -r /data/jumpbox-main/keyclock-main/* .
```

download keyclock :  https://www.keycloak.org/downloads

wget https://github.com/keycloak/keycloak/releases/download/22.0.0/keycloak-22.0.0.tar.gz

```
generate domain cert: 
generate-self-signed-cert-keyclock


cat start-kc-dev.sh
export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD='VMware1!'
/data/keyclock-main/keycloak-22.0.0/bin/kc.sh start-dev --https-certificate-file=/data/keyclock-main/generate-self-signed-cert-keyclock/domain.crt --https-certificate-key-file=/data/keyclock-main/generate-self-signed-cert-keyclock/domain.key --http-enabled=true

```

setup keyclocn sample:  https://www.keycloak.org/getting-started/getting-started-docker
configure : https://www.keycloak.org/server/enabletls

didnot use: keyclock docker
didnot use: keyclock bitnami docker-compose   https://github.com/bitnami/containers/tree/main/bitnami/keycloak#how-to-use-this-image

https://keyclock.lab.pcfdemo.net:8443
https://keyclock.lab.pcfdemo.net:8443/realms/myrealm/account/#/

test: curl https://keyclock.lab.pcfdemo.net:8443/realms/myrealm/.well-known/openid-configuration

add custom CA to TKG node, OIDC package



## prepare keyclock users(Tanzu Platform SM)
https://github.com/myminseok/tanzu-main

keyclock.lab.pcfdemo.net/ admin / VMware1!

myrealm
Clients> my_client 
General settings:
- ClientID: my_client
- Name: my_client
- Valid redirect URIs:  /*
, https://tpsm.lab.pcfdemo.net/auth/login/callback/keyclock (requiers to prevent redirect_uri error)
Capacity config



- Client authentication : on
- Authentication flow: check Standard flow, check Direct access grants
Credentials
- Client Authenicator: Client Id and Secret


## add to crontab to start on boot.

cat >/data/keyclock-main/start-kc.sh<<EOF
#!/bin/bash
export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD='VMware1!'
nohup /data/keyclock-main/keycloak-22.0.0/bin/kc.sh start --https-certificate-file=/data/keyclock-main/generate-self-signed-cert-keyclock/domain.crt --https-certificate-key-file=/data/keyclock-main/generate-self-signed-cert-keyclock/domain.key  --hostname-strict-https=false --hostname=keyclock.lab.pcfdemo.net &
EOF

make sure all absolute path in the script.

chmod +x /data/keyclock-main/start-kc.sh

cat >/etc/cron.d/keyclock<<EOF
@reboot root /data/keyclock-main/start-kc.sh 2>&1 >> /data/keyclock-main/cron.log
EOF


reboot -n

systemctl status cron
Dec 19 03:09:10 jumpbox CRON[1052]: (root) CMD (/data/keyclock-main/start-kc.sh 2>&1 >> /data/keyclock-main/cron.log)
