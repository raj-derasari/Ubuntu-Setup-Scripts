#!/bin/bash 
. br_util.sh ${*}

# called from main menu
if [ -z $Master_RemoveBloatware ]; then
	_help_
fi
## literally bloatware, in my opinion
splash_msg="----------------------------------------------
Removing unneeded packages, followed by default software:
----------------------------------------------\n"
echo -e "$splash_msg"
# pkg to remove, remove lines or add packages below with a backslash (\) at the end, to uninstall
# Make sure that there is no space after the backslash!
pkgs="
gnome-disk-utility \
gnome-mplayer \
simple-scan \
xfburn"

# pkg to remove, same as above
sws="
abiword* \
alsa* \
audacious* \
gnome-mpv \
gnumeric* \
leafpad \
pidgin* \
transmission*"

echo "Packages: "$pkgs
echo "Softwares: "$sws

$br_purge $pkgs
$br_purge $sws

$dry_echo sudo dpkg --configure -a
$dry_echo sudo apt -y autoremove
$apt_prefix -f

# to fix mute button problems in Lubuntu
# makes the mute button TOGGLE mute/unmute instead of FORCING mute every time its pressed
$apt_prefix alsa-utils
$dry_echo sed -i 's/amixer -q sset Master toggle/amixer -D pulse set Master toggle/g' ~/.config/openbox/lubuntu-rc.xml && openbox --reconfigure
