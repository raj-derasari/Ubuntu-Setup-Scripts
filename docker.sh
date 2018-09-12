#!/bin/bash
#set -o errexit -o pipefail -o noclobber #-o nounset
#. `which virtualenvwrapper.sh`
## get util functions loaded
. util.sh ${*}

disp "Ubuntu Docker Install/Reinstall Script"

## vars, independent of util file (usage is limited to this script)
AUTO=0

# use the display function to print this
#disp "Docker REINSTALLATION Script"
## If you are running docker directly from here, please set the SUDO choice here.
if [ -z $Install_Docker ]; then
	echo "Not called from master script, setup variables here in docker.sh!"
	
	## This is the variable to set - if you set this to 1 you don't have to "sudo docker" everytime
	export Docker_Remove_SUDO=0
	if [ $AUTO -eq 0 ]; then
		read -p "Press Enter to exit, or any other key to continue: - " exitqn
		if test "$exitqn" = ""; then
			echo "Exiting"; exit 127
		else
			echo "Continuing Docker Installation"
		fi
		
		read -p "Uninstall previous versions of Docker? (y/Y for yes) - " uninstqn
		if [ "$uninstqn" = "n" ]; then
			echo "Not uninstalling previous versions of Docker.";
		else
			echo "Uninstalling previous versions of Docker.";
			$dry_echo sudo apt-get remove -y docker docker-engine docker.io
		fi
	fi
fi

#sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual}"
#echo "Installing docker dependencies";
$dry_echo sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common;
if [ "$dry_echo" = "" ]; then 
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
fi
echo "Adding docker repository to lists";
$dry_echo sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" # &> /dev/null
#$dry_echo sudo add-apt-repository "deb https://apt.dockerproject.org/repo/ ubuntu-$(lsb_release -cs) main"

#echo "Running apt-get update"; 
$dry_echo sudo apt-get update
#echo "Running apt-get install docker"
$dry_echo sudo apt-get install -y docker docker-compose docker-ce docker-doc docker-registry
disp "Testing Docker"
if [ $Docker_Remove_SUDO -eq 1 ]; then
	# -f will suppress output if group already exists, and $? will echo 0
	$dry_echo sudo groupadd -f docker
	$dry_echo sudo gpasswd -a $USER docker
	## Docker run won't work on the first-run because you must login/logout, entering a new session, making docker run fine.
	# docker run hello-world 
else
	$dry_echo sudo docker run hello-world
	# Verifying if sudo docker run... works.
	if [ "$dry_echo" = "" ]; then 
		if [  $? -eq 0 ]; then
			log "Docker installed fine"
			disp "Docker installed fine!"
		else
			log "Docker did not install fine"
			disp "Docker did not install fine!"
		fi
	fi
fi
