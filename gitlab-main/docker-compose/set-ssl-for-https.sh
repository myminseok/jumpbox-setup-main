TARGET="/data/gitlab-data/config/ssl"
rm -rf $TARGET
mkdir -p $TARGET
ln  /data/gitlab-main/generate-self-signed-cert/domain.crt $TARGET/gitlab2.lab.pcfdemo.net.crt
ln  /data/gitlab-main/generate-self-signed-cert/domain.key $TARGET/gitlab2.lab.pcfdemo.net.key
ls -al $TARGET
