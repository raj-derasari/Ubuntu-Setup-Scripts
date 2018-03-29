#!/bin/bash 
source `which virtualenvwrapper.sh`
echo "----------------------------------------------------------------------------"
echo "                        Dependencies Script"
echo "----------------------------------------------------------------------------"
#logging/utils/help
LOGGER=`pwd`/log_dependencies.log
INFO="LibsDeps: INFO: "
ERROR="LibsDeps: ERROR: "
DEBUG="DEBUG: "
log()
{
	echo -e "[${USER}]\t[`date`]\t${*}" >> ${LOGGER}
}

log $INFO "Adding default ubuntu repositories!"
sudo add-apt-repository universe
sudo add-apt-repository restricted
sudo add-apt-repository multiverse
sudo apt-key update && sudo apt-get update >/dev/null

# get ifconfig working on Ubuntu Unity/Budgie/gnome
log $INFO "IFCONFIG"
sudo apt install -y net-tools

# build tools
log $INFO "Build Tools - cmake, etc."
sudo apt-get install -y \
build-essential \
cmake \
curl \
pkg-config \
libx264-dev \
libgtk2.0-dev

# better stuff
log $INFO "C/C++ SO files"
sudo apt-get install -y --install-recommends \
gcc-6-base:i386 \
libbz2-1.0:i386 \
libc6:i386 \
libgcc1:i386 \
libgpm2:i386 \
libncurses5:i386 \
libstdc++6:i386 \
libc6-i386 \
lib32z1 \
lib32ncurses5 \
lib32z1 \
libtinfo5:i386

log $INFO "gconf "
sudo apt-get install -y --install-recommends \
gconf2 \
gconf2-common \
gconf-service \
gconf-editor \
gconf-defaults-service \
gconf-service-backend

if [ $Setup_Python_Dev -eq 1 ]; then
	log $INFO "installing pip for python $Python_PreferredVersion!"
	if [ $Python_PreferredVersion -eq 2 ]; then
		sudo apt install -y python-pip --install-recommends
	elif [ $Python_PreferredVersion -eq 3 ]; then
		sudo apt install -y python3-pip --install-recommends
	fi
else
	log $INFO "Not installing pip!"
fi

if [ $Setup_VirtualEnv -eq 1 ]; then 
	log $INFO "installing virtualenv for python"
	if [ $Python_PreferredVersion -eq 2 ]; then
		sudo apt-get install -y virtualenv python-virtualenv virtualenvwrapper
	elif [ $Python_PreferredVersion -eq 3 ]; then
		sudo apt-get install -y virtualenv python3-virtualenv virtualenvwrapper
	fi
	pip$Python_PreferredVersion install virtualenvwrapper
else
	log $INFO "Not setting up virtualenv"
fi
exit
