#!/bin/bash 
source `which virtualenvwrapper.sh`
LOGGER=`pwd`/log_docker.log
echo "----------------------------------------------------------------------------"
echo "                            Docker Script"
echo "----------------------------------------------------------------------------"
sudo apt-get remove docker docker-engine docker.io 2>>"${LOGGER}"
sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual 2>>"${LOGGER}"
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common 2>>"${LOGGER}"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# for testing/debug
#echo -e "Result of key-fingerprint for Docker: \n"
#sudo apt-key fingerprint 0EBFCD88
sudo apt-get update
sudo apt-get install -y docker docker-compose docker-ce docker-doc docker-registry 2>>"${LOGGER}"
echo -e "Testing Docker\n"
sudo docker run hello-world
