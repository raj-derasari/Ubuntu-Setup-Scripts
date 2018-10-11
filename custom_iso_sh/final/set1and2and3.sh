sudo apt-get update
sudo apt upgrade -y
sudo apt-get install -y virtualenv python3-virtualenv virtualenvwrapper
sudo apt-get install -y vcsh git
git config --global alias.add-commit '!git add -A && git commit -m'
git config --global alias.ls 'log --pretty=format:"%C(green)%h\\ %C(yellow)[%ad]%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=relative'
git config --global alias.ll 'log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --numstat'
git config --global alias.lnc 'log --pretty=format:"%h\\ %s\\ [%cn]"'
sudo add-apt-repository -y universe
sudo add-apt-repository -y restricted
sudo add-apt-repository -y multiverse
sudo apt-get update
sudo apt-get install -y net-tools build-essential cmake curl pkg-config libx264-dev libgtk2.0-dev
sudo apt-get install -y gcc-6-base:i386 libbz2-1.0:i386 libc6:i386 libgcc1:i386 libgpm2:i386 libncurses5:i386 libstdc++6:i386 libc6-i386 lib32z1 lib32ncurses5 lib32z1 libtinfo5:i386
sudo apt-get install -y libbz2-dev libssl-dev libreadline-dev libsqlite3-dev tk-dev
sudo apt-get install -y gconf2 gconf2-common gconf-service gconf-editor gconf-defaults-service gconf-service-backend
sudo apt-get purge -y --auto-remove gnome-disk-utility gnome-mplayer simple-scan xfburn
sudo apt-get purge -y --auto-remove abiword* alsa* audacious* gnome-mpv gnumeric* leafpad pidgin* sylpheed* transmission*
sudo apt-get purge -y --auto-remove language-pack-de* language-pack-de-base* language-pack-gnome-de* language-pack-gnome-de-base* language-pack-es* language-pack-es-base* language-pack-gnome-es* language-pack-gnome-es-base* language-pack-it* language-pack-it-base* language-pack-gnome-it* language-pack-gnome-it-base* language-pack-pt* language-pack-pt-base* language-pack-gnome-pt* language-pack-gnome-pt-base* language-pack-gnome-ru* language-pack-gnome-ru-base* language-pack-ru* language-pack-ru-base* language-pack-zh-hans* language-pack-zh-hans-base* language-pack-gnome-zh-hans* language-pack-gnome-zh-hans-base*
sudo apt-get purge -y --auto-remove firefox-locale-[dfiprsz] firefox-locale-es*
sudo dpkg --configure -a
sudo apt -y autoremove
sudo apt-get install -y -f
sudo apt-get install -y alsa-utils alsamixer
sed -i 's/amixer -q sset Master toggle/amixer -D pulse set Master toggle/g' /etc/skel/.config/openbox/lubuntu-rc.xml
unzip -n -qq Templates.zip -d /etc/skel/Templates
sudo add-apt-repository -y ppa:alexlarsson/flatpak
sudo add-apt-repository -y ppa:nathan-renniewaldock/flux
sudo add-apt-repository -y ppa:linuxuprising/java
sudo add-apt-repository -y ppa:adamreichold/qpdfview-dailydeb
sudo add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable
sudo add-apt-repository -y ppa:plushuang-tw/uget-stable
sudo add-apt-repository -y ppa:strukturag/libde265
curl https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo deb [arch=amd64]  https://download.sublimetext.com/ apt/stable/ | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt-get update
sudo apt-get install -y microcode.ctl intel-microcode amd64-microcode
sudo apt-get install -y sublime-text
sudo apt-get install -y --install-recommends exfat-utils
sudo apt-get install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo apt-get install -y fluxgui
sudo apt-get install -y gparted
sudo apt-get install -y gufw
sudo apt-get install -y firefox
sudo apt-get install -y okular
sudo apt-get purge -y openjdk-*
echo oracle-java10-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
echo oracle-java10-installer shared/accepted-oracle-license-v1-1 seen true | sudo /usr/bin/debconf-set-selections
sudo apt-get install -y oracle-java10-installer
sudo apt-get install -y oracle-java10-set-default
sudo apt-get install -y --install-recommends p7zip p7zip-rar p7zip-full
sudo apt-get install -y pulseaudio-equalizer
echo load-module module-equalizer-sink | sudo tee -a /etc/pulse/default.pa
echo load-module module-dbus-protocol | sudo tee -a /etc/pulse/default.pa
sudo apt-get install -y qbittorrent
sudo apt-get install -y qpdfview
sudo apt-get install -y slurm
sudo apt-get install -y thunderbird
sudo apt-get install -y uget
sudo apt-get install -y --install-recommends vlc libde265-0
sudo apt-get install -y zsh
sudo apt-get install -y libreoffice-base
sudo apt-get install -y libreoffice-impress
sudo apt-get install -y libreoffice-calc
sudo apt-get install -y libreoffice-math
sudo apt-get install -y libreoffice-writer
sudo apt-get install -y -f
sudo apt-get update
sudo apt-get install -y --install-recommends python3-pkgconfig python3-pkg-resources python3-tk
sudo apt-get install -y --install-recommends python3-pip
sudo apt-get install -y -f
python3 -m pip install --user --upgrade pip
python3 -m pip install --user --upgrade virtualenvwrapper
python3 -m pip install --user --upgrade pip
python3 -m pip install --user --upgrade Requests
python3 -m pip install --user --upgrade scipy
python3 -m pip install --user --upgrade sklearn
python3 -m pip install --user --upgrade matplotlib
python3 -m pip install --user --upgrade pandas
python3 -m pip install --user --upgrade BeautifulSoup4
#!/bin/sh
cp /root/.gitconfig /etc/skel/.gitconfig
rm -rfd /etc/skel/.cache/pip
rm -rfd /root/.cache/pip
rm -rfd /tmp/*
sudo rm -rfd /var/cache/oracle-jdk*-installer/jdk*.tar.gz
sudo rm -rfd /var/lib/apt/lists/
sudo apt clean
