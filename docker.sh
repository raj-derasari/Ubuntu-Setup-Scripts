#!/bin/bash 
source `which virtualenvwrapper.sh`
LOGGER=`pwd`/log_docker.log
echo "----------------------------------------------------------------------------"
echo "                            Docker Script"
echo "----------------------------------------------------------------------------"
sudo apt-get remove docker docker-engine docker.io 2>>"${LOGGER}"
sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual 2>>"${LOGGER}"
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common 2>>"${LOGGER}"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key -y add -
# for testing
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce 2>>"${LOGGER}"
echo -e "Testing if docker installed fine\n"
sudo docker run hello-world
