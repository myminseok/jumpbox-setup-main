#!/bin/bash

set +x
set -e #fail-fast
IP=`ifconfig | grep 192.168 | awk '{print $2}'`
echo $IP
cf login -a api.sys.data.kr --skip-ssl-validation -u minseok -p PASS -o EDU01 -s test
cf delete cloud-native-spring-$IP -f -r

mkdir -p ~/workspace
cd ~/workspace
rm -rf spring-cloud-sample
git clone https://github.com/myminseok/spring-cloud-sample
cd spring-cloud-sample/lab-building-spring-boot-app/complete/cloud-native-spring
echo "building"
mvn clean package -DskipTests
#gradle clean build
echo "cf push"
cf push cloud-native-spring-$IP -f manifest.yml 
