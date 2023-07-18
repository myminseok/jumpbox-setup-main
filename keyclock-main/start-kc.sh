export KEYCLOAK_ADMIN=admin 
export KEYCLOAK_ADMIN_PASSWORD='VMware1!'
./keycloak-22.0.0/bin/kc.sh start --https-certificate-file=/data/keyclock/generate-self-signed-cert-keyclock/domain.crt --https-certificate-key-file=/data/keyclock/generate-self-signed-cert-keyclock/domain.key  --hostname-strict-https=false --hostname=keyclock.lab.pcfdemo.net
