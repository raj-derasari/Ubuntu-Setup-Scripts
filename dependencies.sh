#!/bin/bash
#set -o errexit -o pipefail -o noclobber #-o nounset
#. `which virtualenvwrapper.sh`
## get util functions loaded
. util.sh ${*}

# use the display function to print this
disp "Ubuntu Dependency/Package Script"

if [ $DRY_MODE -eq 1 ]; then
	pprint "Dry-running installation of dependencies!"
fi

log $INFO "Adding default ubuntu repositories!"
add_apt_repository universe
add_apt_repository restricted
add_apt_repository multiverse

apt_update

# get ifconfig working on Ubuntu Unity/Budgie/gnome
log $INFO "IFCONFIG"
apt_install_recommends net-tools

# build tools
log $INFO "Build Tools - cmake, etc."
apt_install_recommends \
build-essential \
cmake \
curl \
pkg-config \
libx264-dev \
libgtk2.0-dev

# better stuff
log $INFO "C/C++ SO files"
apt_install \
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

apt_install_recommends \
libbz2-dev \
libssl-dev \
libreadline-dev \
libsqlite3-dev tk-dev

log $INFO "gconf "
apt_install \
gconf2 \
gconf2-common \
gconf-service \
gconf-editor \
gconf-defaults-service \
gconf-service-backend

exit 0
