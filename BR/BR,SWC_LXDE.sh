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

languagepacks="
language-pack-de* language-pack-de-base* language-pack-gnome-de* language-pack-gnome-de-base* \
language-pack-es* language-pack-es-base* language-pack-gnome-es* language-pack-gnome-es-base* \
language-pack-it* language-pack-it-base* language-pack-gnome-it* language-pack-gnome-it-base* \
language-pack-pt* language-pack-pt-base* language-pack-gnome-pt* language-pack-gnome-pt-base* \
language-pack-gnome-ru* language-pack-gnome-ru-base* language-pack-ru* language-pack-ru-base* \
language-pack-zh-hans* language-pack-zh-hans-base* language-pack-gnome-zh-hans* language-pack-gnome-zh-hans-base* "

pprint "Packages: "$pkgs
pprint "Softwares: "$sws
pprint "Themes: "$themes
pprint "Language Packs: "$languagepacks

$br_purge $pkgs
$br_purge $sws
$additional_remove $themes
$additional_remove $languagepacks

$dry_echo sudo dpkg --configure -a
$dry_echo sudo apt -y autoremove
$apt_prefix -f

$apt_prefix alsa-utils alsamixer
if [ $DRY_MODE -eq 1 ]; then
	$dry_echo sed -i \'s/amixer -q sset Master toggle/amixer -D pulse set Master toggle/g\' ${HOME}/.config/openbox/lubuntu-rc.xml && openbox --reconfigure
else
	sed -i 's/amixer -q sset Master toggle/amixer -D pulse set Master toggle/g\' ${HOME}/.config/openbox/lubuntu-rc.xml && openbox --reconfigure
fi
exit 0