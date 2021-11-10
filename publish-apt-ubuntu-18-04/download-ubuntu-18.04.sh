#!/bin/bash

set -e
#CURRENT_DIR=`dirname $(readlink -f ${BASH_SOURCE})`
DOWNLOAD_PATH="/data/ubuntu-18-04-bin/apt"
DOWNLOAD_TMP="/tmp/ubuntu-18-04-bin/apt"

get_download_path(){
  component="$1"
  echo "$DOWNLOAD_PATH/$component"
}

get_download_tmp_path(){
  component="$1"
  echo "$DOWNLOAD_TMP/$component"
}

## param: folder name
prepare_dir(){
  component="$1"
  download_tmp_folder=$(get_download_tmp_path $component)
  echo "==================================================="
  echo "downloading $component $download_tmp_folder"

  rm -rf $download_tmp_folder
  mkdir -p $download_tmp_folder
  chmod 777 $download_tmp_folder
}

move_download(){
  component="$1"
  download_tmp_folder=$(get_download_tmp_path $component)
  download_folder=$(get_download_path $component)
  echo "==================================================="
  echo "moving $component $download_folder"
  rm -rf $download_folder
  mv $download_tmp_folder $download_folder 
}

# for apt --fix-broken install -y
prepare_dir apt-fix-broken
cd $(get_download_tmp_path apt-fix-broken)
apt download libpam-modules
apt download update-motd
move_download apt-fix-broken

prepare_dir apt-rdepends
cd $(get_download_tmp_path apt-rdepends)
apt download apt-rdepends
apt download libapt-pkg-perl
apt remove apt-rdepends -y
dpkg -i *.deb
move_download apt-rdepends

prepare_dir python3
cd $(get_download_tmp_path python3)
apt download python3
apt download $( apt-rdepends python3| grep -v "^ "| grep -v "debconf-2.0")
apt download libpython3.6
dpkg -i *.deb
move_download python3

prepare_dir pip3
cd $(get_download_tmp_path pip3)
apt download python3-pip
apt download $( apt-rdepends python3-pip| grep -v "^ "| grep -v "debconf-2.0")
dpkg -i *.deb
pip3 -V

pip3 download setuptools setuptools_rust
#pip3 download setuptools-58.4.0-py3-none-any.whl
pip3 install *.whl

## pip upgrade
wget https://files.pythonhosted.org/packages/da/f6/c83229dcc3635cdeb51874184241a9508ada15d8baa337a41093fab58011/pip-21.3.1.tar.gz
tar xf pip-21.3.1.tar.gz
cd pip-21.3.1
python3 setup.py install
pip3 -V

move_download pip3

prepare_dir docker
cd $(get_download_tmp_path docker)
apt-get download libltdl7 docker.io
apt download $( apt-rdepends docker | grep -v "^ ")
apt download containerd
apt download runc
dpkg -i *.deb
move_download docker

prepare_dir docker-compose-pip3
cd $(get_download_tmp_path docker-compose-pip3)
pip3 download docker-compose
pip3 download wheel
pip3 download cryptography
### ERROR: Cannot uninstall 'PyYAML'. It is a distutils installed project and thus we cannot accurately determine which files belong to it which would lead to only a partial uninstall.
mv PyYAML-5.4.1-cp36-cp36m-manylinux1_x86_64.whl PyYAML-5.4.1-cp36-cp36m-manylinux1_x86_64.whl.skip
pip3 install *.tar.gz
pip3 install *.whl
docker-compose version
move_download docker-compose-pip3

prepare_dir bind9
cd $(get_download_tmp_path bind9)
apt download bind9
apt download $( apt-rdepends bind9| grep -v "^ "| grep -v "debconf-2.0")
apt download libpam-modules:amd64
apt download libpam-modules-bin
dpkg -i *.deb
move_download bind9

echo "complated ==========================================="
