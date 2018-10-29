#!/bin/bash 
. br_util.sh ${*}

# called from main menu
if [ -z $Master_RemoveBloatware ]; then
	_help_;
fi

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
sylpheed* \
transmission*"

themes="
adwaita-icon-theme \
dmz-cursor-theme \
gnome-icon-theme \
gtk-update-icon-cache \
humanity-icon-theme"

## language packs are declared in util.sh since they are common across distros

pprint "Packages: "$pkgs
pprint "Softwares: "$sws
pprint "Themes: "$themes
pprint "Language Packs: "$languagepacks

apt_purge $pkgs
apt_purge $sws

## to remove additional stuff pass the --remove-themes or --remove-language-packs paramters
$additional_remove $themes
$additional_remove $languagepacks

# $dry_echo sudo dpkg --configure -a
# $dry_echo sudo apt -y autoremove
# apt_install -fy

apt_install alsa-utils alsamixer
if [ $DRY_MODE -eq 1 ]; then
	$dry_echo "sed -i 's/amixer -q sset Master toggle/amixer -D pulse set Master toggle/g' ${HOME}/.config/openbox/lubuntu-rc.xml && openbox --reconfigure"
else
	sed -i 's/amixer -q sset Master toggle/amixer -D pulse set Master toggle/g' ${HOME}/.config/openbox/lubuntu-rc.xml && openbox --reconfigure
fi