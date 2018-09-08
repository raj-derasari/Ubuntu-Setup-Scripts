#bloatware removal script
. util.sh
DRY_RUN=0
dry_echo=""
DEBUG=0

if test "$1" = "-D"; then
	DRY_RUN=1
	dry_echo="echo "
fi

br_purge="$dry_echo sudo apt-get purge -y "

if [ -z $Master_RemoveBloatware ]; then
	## variable wasn't defined
	echo "Welcome to the LUbuntu fixer-setup script."
else
	log $INFO "lubuntu-bloatremove was called"
fi
## literally bloatware, in my opinion
splash_msg="
-------------------------------------
Removing packages, followed by softwares:
"
echo $splash_msg

# pkg to remove, remove lines or add packages below with a \\ at the end, to uninstall
pkgs="
gnome-disk-utility \
gnome-mplayer \
gnome-mpv \
gpicview \
guvcview \
leafpad \
mtools \
mtpaint \
mtr-tiny \
simple-scan \
ubuntu-release-upgrader-gtk \ 
xfburn "

# pkg to remove, same as above
sw="
abiword* \
alsa* \
audacious* \
gnumeric* \
pidgin* \
sylpheed* \
transmission*
"

$br_purge $pkgs
$br_purge $sw

$dry_echo sudo dpkg --configure -a
$dry_echo sudo apt -y autoremove
$dry_echo sudo apt-get install -fy

# to fix mute button problems in Lubuntu
$dry_echo sudo apt-get install alsa-utils

# makes the mute button TOGGLE mute/unmute instead of FORCING mute every time its pressed
$dry_echo sed -i 's/amixer -q sset Master toggle/amixer -D pulse set Master toggle/g' ~/.config/openbox/lubuntu-rc.xml && openbox --reconfigure

