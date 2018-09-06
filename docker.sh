#!/bin/bash
set -o errexit -o pipefail -o noclobber #-o nounset
## get util functions loaded
. util.sh
. `which virtualenvwrapper.sh`

# use the display function to print this
disp "Docker REINSTALLATION Script"

#logging/utils/help
if test "$1" = "--dry-run" -o "$1" = "-D" ; then 
	disp "--dry-run mode"
	set -v
#    set -n
fi
## If you are running docker directly from here, please set the SUDO choice here.
if [ -z $Install_Docker ]; then
	echo "Not called from master script, setup variables here in docker.sh!"
	
	## This is the variable to set - if you set this to 1 you don't have to "sudo docker" everytime
	export Docker_Remove_SUDO=0

	read -p "Press Enter to exit, or any other key to continue: - " exitqn
	if test "$exitqn" = ""; then
		echo "Exiting"; exit 127
	else
		echo "Continuing Docker Installation"
	fi
	
	read -p "Uninstall previous versions of Docker? (y/Y for yes) - " uninstqn
	if test "$uninstqn" = "N" -o "$uninstqn" = "n"; then
		echo "Not uninstalling previous versions of Docker.";
	else
		echo "Uninstalling previous versions of Docker.";
		sudo apt-get remove -y docker docker-engine docker.io
	fi
fi

#sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual}"
#echo "Installing docker dependencies";
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common;
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
echo "Adding docker repository to lists";
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" # &> /dev/null

#echo "Running apt-get update"; 
sudo apt-get update
#echo "Running apt-get install docker"
sudo apt-get install -y docker docker-compose docker-ce docker-doc docker-registry
disp "Testing Docker"
if [ $Docker_Remove_SUDO -eq 1 ]; then
	sudo groupadd docker
	sudo gpasswd -a $USER docker
	docker run hello-world
else
	sudo docker run hello-world
fi
if [  $? -eq 0 ]; then
	disp "Docker installed fine!"
else
	disp "Docker did not install fine!"
fi
