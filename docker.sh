#!/bin/bash 
source `which virtualenvwrapper.sh`
LOGGER=`pwd`/log_docker.log
echo "----------------------------------------------------------------------------"
echo "                            Docker Script"
echo "----------------------------------------------------------------------------"
sudo apt-get remove docker docker-engine docker.io 2>>$LOGGER
sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual 2>>$LOGGER
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common 2>>$LOGGER
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key -y add -
sudo apt-key fingerprint 0EBFCD88 2>>$LOGGER
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" 2>>$LOGGER
sudo apt-key update 1>/dev/null 2>>$LOGGER
sudo apt-get update 1>/dev/null
sudo apt-get -y install docker-ce 2>>$LOGGER
echo -e "Testing if docker installed fine\n"
sudo docker run hello-world
