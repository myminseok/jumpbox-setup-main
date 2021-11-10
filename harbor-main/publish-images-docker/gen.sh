
#!/bin/bash
DOWNLOAD_PATH="/data/harbor-bin/harbor-images"
mkdir -p $DOWNLOAD_PATH 
grep -r "image:" ../harbor/docker-compose.yml | awk -F"/" '{print "echo " $2 "; docker save goharbor/"$2 " -o /data/harbor-bin/harbor-images/"$2}'> download.sh
grep -r "image:" ../harbor/docker-compose.yml | awk -F"/" '{print "echo " $2 "; docker load -i /data/harbor-bin/harbor-images/"$2}'> load.sh

echo "echo goharbor/prepare:v2.3.3; docker save goharbor/prepare:v2.3.3 -o /data/harbor-bin/harbor-images/goharbor_prepare:v2.3.3" >> download.sh
echo "echo goharbor/prepare:v2.3.3; docker load -i /data/harbor-bin/harbor-images/goharbor_prepare:v2.3.3" >> load.sh
chmod +x *.sh
