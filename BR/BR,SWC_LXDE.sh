#!/bin/bash 
. br_util.sh ${*}

# called from main menu
if [ -z $Master_RemoveBloatware ]; then
	_help_;
	#exit 5;
fi

splash_msg="----------------------------------------------
Removing unneeded packages, followed by default software:
----------------------------------------------\n"
pprint "$splash_msg"

# pkg to remove, remove lines or add packages below with a backslash (\) at the end, to uninstall
# Make sure that there is no space after the backslash!
pkgs="
gnome-disk-utility \
gnome-mplayer \
simple-scan \
xfburn"

# pkgs to remove, same as above, but many more dependency/packages coz these are full software
sws="
abiword* \
alsa* \
audacious* \
gnome-mpv \
gnumeric* \
leafpad \
pidgin* \
slypheed* \
transmission*"

themes="
adwaita-icon-theme \
dmz-cursor-theme \
gnome-icon-theme \
gtk-update-icon-cache \
humanity-icon-theme \
hicolor-icon-theme \
"

pprint "Packages: "$pkgs
pprint "Softwares: "$sws
pprint "Themes: "$themes

$br_purge $pkgs
$br_purge $sws
$themes_remove $themes

$dry_echo sudo dpkg --configure -a
$dry_echo sudo apt -y autoremove
$apt_prefix -f

$apt_prefix alsa-utils
if [ $DRY_MODE -eq 1 ]; then
	$dry_echo sed -i \'s/amixer -q sset Master toggle/amixer -D pulse set Master toggle/g\' ${HOME}/.config/openbox/lubuntu-rc.xml && openbox --reconfigure
else
	sed -i 's/amixer -q sset Master toggle/amixer -D pulse set Master toggle/g\' ${HOME}/.config/openbox/lubuntu-rc.xml && openbox --reconfigure
fi
exit 0