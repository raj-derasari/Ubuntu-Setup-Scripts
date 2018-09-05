#!/bin/bash 
source `which virtualenvwrapper.sh`
LOGGER=`pwd`/log_docker.log
if [ -z $Setup_Python_Dev ]; then
	echo "Not called from master script, setup variables here in docker.sh!"
	export Docker_Remove_SUDO=0
fi
echo "----------------------------------------------------------------------------"
echo "                   Docker Reinstallation Script"
echo "----------------------------------------------------------------------------"
sudo apt-get remove docker docker-engine docker.io > /dev/null 2>>"${LOGGER}"
#sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual 2>>"${LOGGER}"
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common 2>>"${LOGGER}"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# for testing/debug
#echo -e "Result of key-fingerprint for Docker: \n"
#sudo apt-key fingerprint 0EBFCD88
sudo apt-get update > /dev/null
sudo apt-get install -y docker docker-compose docker-ce docker-doc docker-registry 2>>"${LOGGER}"
echo -e "Testing Docker\n"

if [ $Docker_Remove_SUDO -eq 1 ]; then
	sudo groupadd docker 2>/dev/null
	sudo gpasswd -a $USER docker 2>/dev/null
	docker run hello-world
else
	sudo docker run hello-world
fi

if [  $? -eq 0 ]; then
	echo "Docker installed fine!"
else
	echo "Docker did not install fine!"
fi
