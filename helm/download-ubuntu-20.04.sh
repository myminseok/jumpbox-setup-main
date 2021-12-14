#!/bin/bash

set -e
CURRENT_DIR=`dirname $(readlink -f ${BASH_SOURCE})`
DOWNLOAD_PATH="$CURRENT_DIR"
DOWNLOAD_TMP="/tmp/ubuntu-20-04-bin/apt"

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
  mkdir -p $DOWNLOAD_PATH

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

prepare_dir apt-transport-https
cd $(get_download_tmp_path apt-transport-https)
apt download apt-transport-https
move_download apt-transport-https

prepare_dir helm
cd $(get_download_tmp_path helm)
apt download helm
move_download helm
