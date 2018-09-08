#!/bin/bash
#set -o errexit -o pipefail -o noclobber #-o nounset
## get util functions loaded
. util.sh
#. `which virtualenvwrapper.sh`

# use the display function to print this
disp "Ubuntu Dependency/Package Script"

#logging/utils/help
INFO="Lib-Dep: INFO: "
ERROR="Lib-Dep: ERROR: "

DRY_RUN=0
dry_echo=""
DEBUG=0

if test "$1" = "-D"; then
	DRY_RUN=1
	dry_echo="echo "
fi


log $INFO "Adding default ubuntu repositories!"
$dry_echo sudo add-apt-repository universe
$dry_echo sudo add-apt-repository restricted
$dry_echo sudo add-apt-repository multiverse
#sudo apt-key update && 
$dry_echo sudo apt-get update

# get ifconfig working on Ubuntu Unity/Budgie/gnome
log $INFO "IFCONFIG"
$dry_echo sudo apt install -y net-tools

# build tools
log $INFO "Build Tools - cmake, etc."
$dry_echo sudo apt-get install -y \
build-essential \
cmake \
curl \
pkg-config \
libx264-dev \
libgtk2.0-dev

# better stuff
log $INFO "C/C++ SO files"
$dry_echo sudo apt-get install -y --install-recommends \
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
$dry_echo sudo apt-get install -y --install-recommends \
gconf2 \
gconf2-common \
gconf-service \
gconf-editor \
gconf-defaults-service \
gconf-service-backend

exit 0
