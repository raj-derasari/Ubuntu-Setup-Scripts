#!/bin/bash
## get util functions loaded
. util.sh ${*}

# use the display function to print this
disp "Ubuntu - Software Setup Script"

## If you want to automate this script and add a config file here itself, uncomment the next line
# CFGFILE=""

## Command line parsing - you do not need to modify anything here, and you SHOULDNT
while true; do
	case "$1" in
	-f|--file)
		pprint "Loading software parameters from Configuration Profile:" $2
		CFGFILE="$2"
		. $CFGFILE
		shift 2
	;;
		-x|--print-commands-only)
		DRYFLAG=`echo "$DRYFLAG -x"`
		shift
	;;
	-d|--dry-run)
		pprint "Dry-running installation of software!"
		DRYFLAG=`echo "$DRYFLAG -d"`
		shift
	;;
	--)
		shift
		break
	;;
	*)
		echo "Programming error"
		exit 126
	;;
	esac
done

if [ -z $CFGFILE ]; then
	if [ "$1" = "teamviewer" ]; then
		echo "Installing only teamviewer!"
	fi
	## CFG file is not defined
	echo "Error - Configuration file is not loaded or defined!
	Please use the \"-f\" argument and pass a valid Configuration File!
	Alternatively you can edit the file `basename $0` and define the variable CFGFILE"
	exit 3
elif [ ! -e $CFGFILE ]; then
	## CFG file is not defined
	echo "Error - Configuration file does not exist!
	Please use the \"-f\" argument and pass a valid Configuration File!
	Alternatively you can edit the file `basename $0` and define the variable CFGFILE"
	exit 3
fi
	
#begin
# Copy paste templates and begin proceedings
if [ $Setup_Templates -eq 1 ]; then
	$dry_echo unzip -n -qq Templates.zip -d ${USER_HOME}/Templates
fi

#Check if curl is installed, if not then install it
if [[ -z `which curl` ]]; then
	pprint "curl not installed. This can cause problems in adding HTTPS repositories. installing curl now!"
	apt_update > /dev/null 2>&1
	apt_install_recommends curl
fi

log $INFO "Begin with software"

[ `uname -m` = x86_64 ] && _architecture="[arch=amd64]" || _architecture="[arch=i386]";

[ $Install_Atom -eq 1 ] && add_apt_repository ppa:webupd8team/atom;
[ $Install_Audacity -eq 1 ] && add_apt_repository ppa:ubuntuhandbook1/audacity;
[ $Install_Flatpak -eq 1 ] && add_apt_repository ppa:alexlarsson/flatpak;
[ $Install_Flux -eq 1 ] && add_apt_repository ppa:nathan-renniewaldock/flux;
[ $Install_Grive_GoogleDrive -eq 1 ] && add_apt_repository ppa:nilarimogard/webupd8;
[ $Install_Octave -eq 1 ] && add_apt_repository ppa:octave/stable;
[ $Install_Oracle_Java -eq 1 ] && ( [ $Install_Java_Version -ge 9 ] && add_apt_repository ppa:linuxuprising/java || add_apt_repository ppa:webupd8team/java )
[ $Install_QPDFView -eq 1 ] && add_apt_repository ppa:adamreichold/qpdfview-dailydeb
[ $Install_QBitTorrent -eq 1 ] && add_apt_repository ppa:qbittorrent-team/qbittorrent-stable;
[ $Install_UGET -eq 1 ] && add_apt_repository ppa:plushuang-tw/uget-stable;
[ $Install_VLCMediaPlayer -eq 1 ] && add_apt_repository ppa:strukturag/libde265;


## Pycharm installation not implemented yet - The PPA with pycharm is quite old
#if [ $Install_PyCharm -eq 1 ]; then
	#echo "deb http://archive.getdeb.net/ubuntu $(lsb_release -cs)-getdeb apps" | sudo tee /etc/apt/sources.list.d/getdeb-apps.list
	#wget -q -O- http://archive.getdeb.net/getdeb-archive.key | sudo apt-key add -
	## pycharm installation via apt-get or otherwise is not supported by this project yet. # can add it via snap, easy
# But i am an anti-snap person so..
# if [ $Install_PyCharm -eq 1 ]; then
# 	log $INFO "install Pycharm"
# 	apt_install pycharm
# fi
#fi
## following part is equivalent to:
# if [ $Install_Docker -eq 1 ]; then
# 	apt_key_dl https://download.docker.com/linux/ubuntu/gpg
# 	apt_src_add "https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable " "docker"
# fi
#	if [ $Install_R_Version -eq 3.5 ]; then
#	gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
##	gpg -a --export E298A3A825C0D65DFD57CBB651716619E084DAB9 | sudo apt-key add -
	#	echo 'https://cloud.r-project.org/bin/linux/ubuntu `lsb_release -cs`-cran35/' > /etc/apt/sources.list.d/r-base.list

	# $dry_echo sudo add-apt-repository -y "https://cloud.r-project.org/bin/linux/ubuntu `lsb_release -cs`-cran35/" # &> /dev/null
	# $dry_echo echo "https://cloud.r-project.org/bin/linux/ubuntu `lsb_release -cs`-cran35/" >> /etc/apt/sources.list

[ $Install_Docker -eq 1 ] && (apt_key_dl https://download.docker.com/linux/ubuntu/gpg; apt_src_add "https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable " "docker";);
[ $Install_GoogleChrome -eq 1 ] && ( apt_key_dl dl-ssl.google.com/linux/linux_signing_key.pub; apt_src_add "https://dl.google.com/linux/chrome/deb/ stable main" "google-chrome";);
[ $Install_SublimeText -eq 1 ] && ( apt_key_dl https://download.sublimetext.com/sublimehq-pub.gpg; apt_src_add "https://download.sublimetext.com/ apt/stable/" "sublime-text";);
[ $Install_VisualStudioCode -eq 1 ] && ( apt_key_dl https://packages.microsoft.com/keys/microsoft.asc; apt_src_add "https://packages.microsoft.com/repos/vscode stable main" "vscode";);
[ $Install_Vivaldi -eq 1 ] && ( apt_key_dl https://repo.vivaldi.com/stable/linux_signing_key.pub; apt_src_add "http://repo.vivaldi.com/stable/deb/ stable main" "vivaldi";);

## Update sources
apt_update
# First things first: Check Install microcode
apt_install microcode.ctl intel-microcode amd64-microcode

## The very first thing to install will be sublime text - Rest of the packages are alphabetical

[ $Install_SublimeText -eq 1 ] && apt_install sublime-text 
[ $Install_Audacity -eq 1 ] && apt_install_recommends audacity
[ $Install_Chromium -eq 1 ] && apt_install chromium-browser 

if [ $Install_Docker -eq 1 ]; then
	log $INFO "install docker"
	apt_install apt-transport-https ca-certificates curl software-properties-common
	apt_install docker docker-compose docker-ce docker-doc docker-registry

	if [ $Docker_Remove_SUDO -eq 1 ]; then
		# -f will suppress output if group already exists, and $? will echo 0
		$dry_echo sudo groupadd -f docker
		$dry_echo sudo gpasswd -a $USER docker
		## Docker run won't work on the first-run because you must login/logout, entering a new session, making docker run fine.
		# docker run hello-world 
	fi
fi
if [ $Install_Grive_GoogleDrive -eq 1 ]; then
	checkBash="`grep \"alias fetchd=\" ${BF}`"
	if [[ ! -z $checkBash ]]; then
		log $INFO "grive aliases already exist"
	else
		log $INFO "Setting up grive aliases"
		echo "alias fetchd=\"grive -f --dry-run\"
alias fetch=\"grive -f\"
alias uploadall=\"grive -u\"" >> ${BF}
	fi
	log $INFO "install grive"
	apt_install grive
fi

[ $Install_Emacs -eq 1 ] && apt_install emacs;
[ $Install_EXFatUtils -eq 1 ] && apt_install_recommends exfat-fuse exfat-utils
[ $Install_Flatpak -eq 1 ] && ( apt_install flatpak; $dry_echo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo; )
[ $Install_Flux -eq 1 ] &&  apt_install fluxgui;
[ $Install_GEdit -eq 1 ] &&  apt_install gedit;
[ $Install_GoogleChrome -eq 1 ] &&  apt_install google-chrome-stable;
[ $Install_GParted -eq 1 ] &&  apt_install gparted;
[ $Install_GUFW -eq 1 ] && apt_install gufw;
[ $Install_KeepassPasswordManager -eq 1 ] && apt_install keepassx;
[ $Install_MozillaFirefox -eq 1 ] && apt_install firefox;
[ $Install_Okular -eq 1 ] && apt_install okular;
[ $Install_P7Zip -eq 1 ] && apt_install_recommends p7zip p7zip-rar p7zip-full;

[ $Install_QBitTorrent -eq 1 ] && apt_install qbittorrent;
[ $Install_QPDFView -eq 1 ] && apt_install qpdfview;
[ $Install_Slurm -eq 1 ] && apt_install slurm;
[ $Install_Thunderbird -eq 1 ] && apt_install thunderbird;
[ $Install_TildaTmux -eq 1 ] && apt_install tilda tmux;
[ $Install_UGET -eq 1 ] && apt_install uget;
[ $Install_VisualStudioCode -eq 1 ] && apt_install code;
[ $Install_Vivaldi -eq 1 ] && apt_install vivaldi-stable;
[ $Install_VLCMediaPlayer -eq 1 ] && apt_install_recommends vlc libde265-0; # vlc-plugin-libde265
[ $Install_WinFF -eq 1 ] && apt_install winff libavcodec-extra;
[ $Install_ZSH -eq 1 ] && apt_install zsh;



if [ $Install_Oracle_Java -eq 1 ]; then 	
	[ $Purge_OpenJDK -eq 1 ] && apt_purge -y openjdk-\*;
	log $INFO "Java version: " $Install_Java_Version
	
	[ $DRY_MODE -eq 0 ] && \
		( echo "oracle-java${Install_Java_Version}-installer shared/accepted-oracle-license-v1-1 select true" | sudo /usr/bin/debconf-set-selections;
		echo "oracle-java${Install_Java_Version}-installer shared/accepted-oracle-license-v1-1 seen true" | sudo /usr/bin/debconf-set-selections; ) || \
		( echo "echo oracle-java${Install_Java_Version}-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections";
		echo "echo oracle-java${Install_Java_Version}-installer shared/accepted-oracle-license-v1-1 seen true | sudo /usr/bin/debconf-set-selections";);
	apt_install oracle-java${Install_Java_Version}-installer
	apt_install oracle-java${Install_Java_Version}-set-default
fi
if [ $Install_PulseAudioEqualizer -eq 1 ]; then
	pulse_config_file=/etc/pulse/default.pa
	log $INFO "install qpaeq"
	apt_install pulseaudio-equalizer
	checkBash="`grep 'load-module module-equalizer-sink' /etc/pulse/default.pa`"
	if [[ ! -z $checkBash ]]; then
		log $INFO "qpaeq setup, not modifying /etc/pulse/default.pa"
		pprint "qpaeq setup, not modifying /etc/pulse/default.pa"
		## make sure that the lines which enable the equalizer are uncommented
		if [ $DRY_MODE -eq 0 ]; then
			sudo sed -i 's/#load-module module-equalizer-sink/load-module module-equalizer-sink/g' $pulse_config_file
			sudo sed -i 's/#load-module module-dbus-protocol/load-module module-dbus-protocol/g' $pulse_config_file
		else
			echo sed -i \'s/#load-module module-equalizer-sink/load-module module-equalizer-sink/g\' $pulse_config_file
			echo sed -i \'s/#load-module module-dbus-protocol/load-module module-dbus-protocol/g\' $pulse_config_file
		fi
	else
		log $INFO "qpaeq modules are now being setup"
		pprint "qpaeq modules are now being setup"
		if [ $DRY_MODE -eq 1 ]; then
			echo "echo load-module module-equalizer-sink | sudo tee -a $pulse_config_file"
			echo "echo load-module module-dbus-protocol | sudo tee -a $pulse_config_file"
		else
			echo "load-module module-equalizer-sink" | sudo tee -a $pulse_config_file
			echo "load-module module-dbus-protocol" | sudo tee -a $pulse_config_file
		fi
	fi
fi

## LARGE installations
if [ $Install_LibreOffice -eq 1 ]; then
	log $INFO "install libreoffice-stuff"
	libre_stuff=""
	[ $LibreOffice_Base -eq 1 ] && libre_stuff="`echo $libre_stuff` libreoffice-base";
	[ $LibreOffice_Draw -eq 1 ] && libre_stuff="`echo $libre_stuff` libreoffice-draw";
	[ $LibreOffice_Impress -eq 1 ] && libre_stuff="`echo $libre_stuff` libreoffice-impress";
	[ $LibreOffice_Calc -eq 1 ] && libre_stuff="`echo $libre_stuff` libreoffice-calc";
	[ $LibreOffice_Math -eq 1 ] && libre_stuff="`echo $libre_stuff` libreoffice-math";
	[ $LibreOffice_Writer -eq 1 ] && libre_stuff="`echo $libre_stuff` libreoffice-writer";
	pprint "Installing: " $libre_stuff
	apt_install $libre_stuff
fi
if [ $Install_TexStudio -eq 1 ]; then
	checkBash="`grep \"alias texcleanAuxFiles=\" ${BF}`"
	if [[ ! -z $checkBash ]]; then
		log $INFO "Clean alias for texstudio already exists"
	else
		log $INFO "Setting up texcleanAuxFiles alias for latex"
		echo "alias texcleanAuxFiles=\"rm *.aux *.bbl *.syn* *.toc *.blg *.log *.out\"" >> ${BF}
	fi
	log $INFO "install LaTeX"
	apt_install texlive-latex-base texlive-latex-extra texlive-science texlive-lang-english texstudio texlive-publishers
fi
if [ $Install_Octave -eq 1 ]; then
	log $INFO "install octave"
	apt_install_recommends liboctave-dev octave
fi
if [ $Install_Atom -eq 1 ]; then
	log $INFO "install atom"
	apt_install atom
fi

# support for "urgent teamviewer mode" if you really need quick and purely-remote access - just run
# the script as ./software.sh teamviewer and the setup, etc, will be finished!
if [ "$1" = "teamviewer" ] || [ $Install_TeamViewer -eq 1 ]; then
	if [ ! -z `which teamviewer` ]; then
		log $INFO "teamviewer already installed, downloading latest teamviewer debian package"
		pprint "Teamviewer is already installed! downloading the latest teamviewer.deb file from the server"
		$dry_echo wget -q https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
		pprint "teamviewer downloaded. To install, enter the command:"
		pprint "sudo dpkg -i teamviewer_amd64.deb"
	else
	log $INFO "install teamviewer"
	$dry_echo wget -qo- https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
	# This is definitely gonna fail and be fixed in the next step
	$dry_echo sudo dpkg -i teamviewer_amd64.deb &>/dev/null 
	# In this step, teamviewer will definitely be fixed, which is why i supressed the previous output.
	apt_install -f
	$dry_echo rm teamviewer_amd64.deb
	fi
fi
exit 0
