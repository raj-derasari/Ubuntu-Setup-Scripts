#bloatware removal script

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

sudo apt-get purge -y \
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

sudo apt-get purge -y  \
abiword* \
alsa* \
audacious* \
gnumeric* \
pidgin* \
sylpheed* \
transmission*

sudo apt-get install -fy
# to fix mute button problems
sudo apt-get install alsa-utils
sed -i 's/amixer -q sset Master toggle/amixer -D pulse set Master toggle/g' ~/.config/openbox/lubuntu-rc.xml && openbox --reconfigure

