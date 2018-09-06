#bloatware removal script
. util.sh
DRY_RUN=0
dry_echo=""
DEBUG=0

if test "$1" = "-D"; then
	DRY_RUN=1
	dry_echo="echo "
fi

if [ -z $Master_RemoveBloatware ]; then
	## variable wasn't defined
	echo "Welcome to the LUbuntu fixer-setup script."
else
	log $INFO "lubuntu-bloatremove was called"
fi
## literally bloatware, in my opinion
help="Removing the following packages:
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
xfburn
-------------------------------------
Followed by
abiword* \
alsa* \
audacious* \
gnumeric* \
pidgin* \
sylpheed* \
transmission*
"
echo $help

$dry_echo sudo apt-get purge -y \
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
xfburn

$dry_echo sudo apt-get purge -y  \
abiword* \
alsa* \
audacious* \
gnumeric* \
pidgin* \
sylpheed* \
transmission*

$dry_echo sudo apt-get install -fy
# to fix mute button problems
$dry_echo sudo apt-get install alsa-utils
sed -i 's/amixer -q sset Master toggle/amixer -D pulse set Master toggle/g' ~/.config/openbox/lubuntu-rc.xml && openbox --reconfigure

