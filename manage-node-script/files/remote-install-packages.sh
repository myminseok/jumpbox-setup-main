#!/bin/bash

set -e #fail-fast
sudo su
id
set +e
killall -9 apt-get
dpkg --configure -a
set -e # fail-fast
wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
apt update
apt install openjdk-8-jdk -y
sudo apt install maven -y
sudo apt-get install git -y
sudo apt-get update -y
sudo apt-get install cf-cli -y

java -version
git version
mvn -v
