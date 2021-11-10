#!/bin/bash
set -e
set +x
DOWNLOAD_PATH="/data/ubuntu-18-04-bin/apt"

msg(){
  echo ""
  echo "$1 ================================================"
}
msg "Installing apt-rdepends"
##apt remove apt-rdepends -y
dpkg -i $DOWNLOAD_PATH/apt-rdepends/*.deb
dpkg -i $DOWNLOAD_PATH/python3/*.deb
python3 -V

msg "Installing pip3"
dpkg -i $DOWNLOAD_PATH/pip3/*.deb
pip3 -V
pip3 install $DOWNLOAD_PATH/pip3/*.whl

## upgrade pip
msg "upgrading pip3"
cd $DOWNLOAD_PATH/pip3/
tar xf pip-21.3.1.tar.gz
cd pip-21.3.1
python3 setup.py install
pip3 -V
cd $DOWNLOAD_PATH 

msg "Installing docker"
dpkg -i $DOWNLOAD_PATH/docker/*.deb
pip3 install $DOWNLOAD_PATH/docker-compose-pip3/*.tar.gz
pip3 install $DOWNLOAD_PATH/docker-compose-pip3/*.whl

docker-compose version

msg "Installing bind9"
dpkg -i $DOWNLOAD_PATH/bind9/*.deb

msg "apt --fix-broken install"
dpkg -i $DOWNLOAD_PATH/apt-fix-broken/*.deb
apt --fix-broken install -y

