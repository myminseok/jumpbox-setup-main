

## keyclock 

install java : https://davelogs.tistory.com/71

```
$ sudo apt-get update
$ sudo apt-get upgrade
$ sudo apt-get install openjdk-17-jdk

sudo apt-get purge openjdk*

```


```
mkdir -p /data/keyclock
cd /data/keyclock
cp -r /data/jumpbox-main/keyclock-main/* .
```

download keyclock :  https://www.keycloak.org/downloads

wget https://github.com/keycloak/keycloak/releases/download/22.0.5/keycloak-22.0.5.tar.gz

```
generate domain cert: 
generate-self-signed-cert-keyclock

cat start-kc.sh
export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD='VMware1!'
./keycloak-22.0.0/bin/kc.sh start-dev --https-certificate-file=/data/keyclock/generate-self-signed-cert-keyclock/domain.crt --https-certificate-key-file=/data/keyclock/generate-self-signed-cert-keyclock/domain.key --enable-http=true

```

setup keyclocn sample:  https://www.keycloak.org/getting-started/getting-started-docker
configure : https://www.keycloak.org/server/enabletls

didnot use: keyclock docker
didnot use: keyclock bitnami docker-compose   https://github.com/bitnami/containers/tree/main/bitnami/keycloak#how-to-use-this-image

https://keyclock.lab.pcfdemo.net:8443
https://keyclock.lab.pcfdemo.net:8443/realms/myrealm/account/#/

test: curl https://keyclock.lab.pcfdemo.net:8443/realms/myrealm/.well-known/openid-configuration

add custom CA to TKG node, OIDC package

