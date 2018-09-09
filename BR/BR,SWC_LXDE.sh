#bloatware removal script
. util.sh
DRY_RUN=0
dry_echo=""
DEBUG=0

if test "$1" = "-D"; then
	echo "Bloatremove running in --dry-run mode"
	DRY_RUN=1
	dry_echo="echo "
fi

br_purge="$dry_echo sudo apt-get purge -y "

if [ -z $Master_RemoveBloatware ]; then
	## variable wasn't defined
	echo "Lubuntu Bloatremove/Configuration-Fixing script"
	echo "Recommended software after this script completes:"
	echo "Sublime Text 3/emacs for editing text files"
	echo "VLC Media Player for media files"
	echo "Gparted for partition configuration"
	echo "QPDFView (lightweight) and Okular (features) for PDF suites"
	echo "Thunderbird for email client"
	echo "UGet and Qbittorrent for download-management"
	echo "LibreOffice for an office suite"
else
	log $INFO "lubuntu-bloatremove was called"
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
gpicview \
guvcview \
mtools \
mtpaint \
mtr-tiny \
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
sylpheed* \
transmission*"

echo "Packages: "$pkgs
echo "Softwares: "$sws

$br_purge $pkgs
$br_purge $sws
$dry_echo sudo dpkg --configure -a
$dry_echo sudo apt -y autoremove
$dry_echo sudo apt-get install -fy

# to fix mute button problems in Lubuntu
$dry_echo sudo apt-get install alsa-utils

# makes the mute button TOGGLE mute/unmute instead of FORCING mute every time its pressed
$dry_echo sed -i 's/amixer -q sset Master toggle/amixer -D pulse set Master toggle/g' ~/.config/openbox/lubuntu-rc.xml && openbox --reconfigure
