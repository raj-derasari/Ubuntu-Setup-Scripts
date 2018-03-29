#!/bin/bash 
source `which virtualenvwrapper.sh`
echo "----------------------------------------------------------------------------"
echo "                        Unity Bloat Removal Script"
echo "----------------------------------------------------------------------------"
#logging/utils/help
LOGGER=`pwd`/log_bloatremove.log
INFO="Bloatremove: INFO: "
ERROR="Bloatremove: ERROR: "
DEBUG="DEBUG: "
log()
{
	echo -e "[${USER}]\t[`date`]\t${*}" >> "${LOGGER}"
}
log $INFO "some bloat"
sudo apt-get purge -y gbrainy brltty landscape-common mcp-account-manager-uoa mono-common
log $INFO "literally spam content"
sudo apt-get purge -y example-content diveintopython nautilus-sendto-empathy python3-uno sane-utils
log $INFO "games, gnome spam"
sudo apt-get purge -y aisleriot gnomine gnome-contacts gnome-mahjongg gnome-mines gnome-orca gnome-screensaver gnome-games gnome-cards-data gnome-sudoku gnome-video-effects
log $INFO "accessibility:"
sudo apt-get purge -y gnome-orca brltty brltty-x11 gnome-accessibility-themes # gnome-mag libgnome-mag2
log $INFO "account bs"
sudo apt-get purge -y account-plugin-aim account-plugin-facebook account-plugin-flickr account-plugin-jabber account-plugin-salut account-plugin-twitter account-plugin-windows-live account-plugin-yahoo
#log $INFO "asian fonts:";
#sudo apt-get purge -y ttf-arabeyes ttf-arphic-uming ttf-indic-fonts-core ttf-kochi-gothic ttf-kochi-mincho ttf-lao ttf-malayalam-fonts ttf-thai-tlwg ttf-unfonts-core
log $INFO "bluetooth stuff:"
sudo apt-get purge -y bluez-audio bluez-cups bluez-gnome bluez-utils
log $INFO "deja-dup"
sudo apt-get purge -y deja-dup deja-dup-backend-gvfs
log $INFO "dialup"
sudo apt-get purge -y ppp pppconfig pppoeconf wvdial
log $INFO "duplicity"
sudo apt-get purge -y duplicity
log $INFO "empathy chat"
sudo apt-get purge -y empathy empathy-common
log $INFO "evolution email client"
sudo apt-get purge -y evolution evolution-common evolution-data-server-online-accounts libevolution
log $INFO "fortune cookie:"
sudo apt-get purge -y fortune-mod
log $INFO "friends"
sudo apt-get purge -y friends friends-dispatcher friends-facebook friends-twitter libfriends0 libfriends0:amd64 libsane libsane-common
log $INFO "libre"
sudo apt-get purge -y libreoffice-avmedia-backend-gstreamer libreoffice-ogltrans
log $INFO "rhythmbox"
sudo apt-get purge -y rhythmbox rhythmbox-plugin-zeitgeist rhythmbox-plugins
log $INFO "shotwell"
sudo apt-get purge -y shotwell shotwell-common
log $INFO "telepathy, thunderbird, totem"
sudo apt-get purge -y telepathy-gabble telepathy-haze telepathy-idle telepathy-indicator telepathy-logger telepathy-mission-control-5 telepathy-salut thunderbird thunderbird-gnome-support totem*
log $INFO "transmision:"
sudo apt-get purge -y transmission-common transmission-gtk
log $INFO "unity"
sudo apt-get purge -y unity-scope-audacious unity-scope-chromiumbookmarks unity-scope-clementine unity-scope-colourlovers unity-scope-devhelp unity-scope-firefoxbookmarks unity-scope-gdrive unity-scope-gmusicbrowser unity-scope-gourmet unity-scope-manpages unity-scope-musicstores unity-scope-musique unity-scope-openclipart unity-scope-texdoc unity-scope-tomboy unity-scope-video-remote unity-scope-virtualbox unity-scope-yelp unity-scope-zotero unity-webapps-*
log $INFO "wallpapers and stuff:"
sudo apt-get purge -y ubuntu-wallpapers-xenial ubuntu-wallpapers ubuntu-touch-sounds ubuntu-software ubuntu-artwork

log $INFO "<LUBUNTU>"
sudo apt-get purge -y gpicview leafpad pidgin* simple-scan mtpaint mtr-tiny mtools sylpheed* transmission* emacsen-common abiword* gnumeric* alsa* audacious* gnome-disk-utility gnome-mplayer guvcview xfburn ubuntu-release-upgrader-gtk

log $INFO "stage 2: autoremove"
sudo apt -y autoremove
# these did not work at all: package did not exist : hence keeping these lines commented
#log $INFO "beagle:"
sudo apt-get purge -y libbeagle1
#log $INFO "contact bs:"
sudo apt-get purge -y contact-lookup-applet
#log $INFO "openoffice:"
#sudo apt-get purge -y openoffice.org-calc openoffice.org-draw openoffice.org-impress openoffice.org-writer openoffice.org-base-core


log $INFO "stage 3: Disable evolution-services"
cd /usr/share/dbus-1/services
sudo ln -snf /dev/null  org.gnome.evolution.dataserver.AddressBook.service  
sudo ln -snf /dev/null  org.gnome.evolution.dataserver.Calendar.service 
sudo ln -snf /dev/null  org.gnome.evolution.dataserver.Sources.service 
sudo ln -snf /dev/null  org.gnome.evolution.dataserver.UserPrompter.service 
exit
