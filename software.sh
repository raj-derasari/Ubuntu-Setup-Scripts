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
	$apt_update > /dev/null 2>&1
	$apt_prefix_rec curl
fi
log $INFO "Begin"
if [ $Install_Atom -eq 1 ]; then
	$addaptrepo ppa:webupd8team/atom
fi
if [ $Install_Audacity -eq 1 ]; then
	$addaptrepo ppa:ubuntuhandbook1/audacity
fi
if [ $Install_Flatpak -eq 1 ]; then
	$addaptrepo ppa:alexlarsson/flatpak
fi
if [ $Install_Flux -eq 1 ]; then
	$addaptrepo ppa:nathan-renniewaldock/flux
fi
if [ $Install_Grive_GoogleDrive -eq 1 ]; then
	$addaptrepo ppa:nilarimogard/webupd8
fi
if [ $Install_Octave -eq 1 ]; then
	$addaptrepo ppa:octave/stable
fi
if [ $Install_Oracle_Java -eq 1 ]; then
	if [ $Install_Java_Version -eq 8 ]; then
		$addaptrepo ppa:webupd8team/java
	fi
	if [ $Install_Java_Version -eq 10 ]; then
		$addaptrepo ppa:linuxuprising/java
	fi
fi
if [ $Install_QPDFView -eq 1 ]; then
	$addaptrepo ppa:adamreichold/qpdfview-dailydeb
fi
if [ $Install_QBitTorrent -eq 1 ]; then
	$addaptrepo ppa:qbittorrent-team/qbittorrent-stable
fi
if [ $Install_UGET -eq 1 ]; then
	$addaptrepo ppa:plushuang-tw/uget-stable
fi
if [ $Install_VLCMediaPlayer -eq 1 ]; then
	$addaptrepo ppa:strukturag/libde265
fi

_architecture=`uname -m`
if [ $_architecture = x86_64 ]; then
	_architecture="[arch=amd64] "
elif [ $_architecture = i386 ]; then
	_architecture="[arch=i386] "
fi

## Pycharm installation not implemented yet - The PPA with pycharm is quite old
#if [ $Install_PyCharm -eq 1 ]; then
	#echo "deb http://archive.getdeb.net/ubuntu $(lsb_release -cs)-getdeb apps" | sudo tee /etc/apt/sources.list.d/getdeb-apps.list
	#wget -q -O- http://archive.getdeb.net/getdeb-archive.key | sudo apt-key add -
	## pycharm installation via apt-get or otherwise is not supported by this project yet. # can add it via snap, easy
# But i am an anti-snap person so..
# if [ $Install_PyCharm -eq 1 ]; then
# 	log $INFO "install Pycharm"
# 	$apt_prefix pycharm
# fi
#fi
if [ $DRY_MODE -eq 0 ]; then
	if [ $Install_Docker -eq 1 ]; then
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
		echo "deb $_architecture https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
		fi
	if [ $Install_GoogleChrome -eq 1 ]; then
		curl https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
		echo "deb $_architecture http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
	fi
	if [ $Install_SublimeText -eq 1 ]; then
		curl https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
		echo "deb $_architecture https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
	fi
	if [ $Install_VisualStudioCode -eq 1 ]; then
		curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
		echo "deb $_architecture https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
	fi
	if [ $Install_Vivaldi -eq 1 ]; then
		curl http://repo.vivaldi.com/stable/linux_signing_key.pub | sudo apt-key add -
		echo "deb $_architecture http://repo.vivaldi.com/stable/deb/ stable main" | sudo tee /etc/apt/sources.list.d/vivaldi.list
	fi
elif [ $DRY_MODE -eq 1 ]; then
	if [ $Install_Docker -eq 1 ]; then
		echo "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
		echo "echo deb $_architecture https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable | sudo tee /etc/apt/sources.list.d/docker.list"
	fi
	if [ $Install_GoogleChrome -eq 1 ]; then
		echo "curl https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -"
		echo "echo deb $_architecture http://dl.google.com/linux/chrome/deb/ stable main | sudo tee /etc/apt/sources.list.d/google-chrome.list"
	fi
	if [ $Install_SublimeText -eq 1 ]; then
		echo "curl https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -"
		echo "echo deb $_architecture https://download.sublimetext.com/ apt/stable/ | sudo tee /etc/apt/sources.list.d/sublime-text.list"
	fi
	if [ $Install_VisualStudioCode -eq 1 ]; then
		echo "curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -"
		echo "echo deb $_architecture https://packages.microsoft.com/repos/vscode stable main | sudo tee /etc/apt/sources.list.d/vscode.list"
	fi
	if [ $Install_Vivaldi -eq 1 ]; then
		echo "curl http://repo.vivaldi.com/stable/linux_signing_key.pub | sudo apt-key add -"
		echo "echo deb $_architecture http://repo.vivaldi.com/stable/deb/ stable main | sudo tee /etc/apt/sources.list.d/vivaldi.list"
	fi
fi

#	if [ $Install_R_Version -eq 3.5 ]; then
#	gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
##	gpg -a --export E298A3A825C0D65DFD57CBB651716619E084DAB9 | sudo apt-key add -
	#	echo 'https://cloud.r-project.org/bin/linux/ubuntu `lsb_release -cs`-cran35/' > /etc/apt/sources.list.d/r-base.list

	# $dry_echo sudo add-apt-repository -y "https://cloud.r-project.org/bin/linux/ubuntu `lsb_release -cs`-cran35/" # &> /dev/null
	# $dry_echo echo "https://cloud.r-project.org/bin/linux/ubuntu `lsb_release -cs`-cran35/" >> /etc/apt/sources.list

## Update sources
$apt_update
# First things first: Check Install microcode
$apt_prefix microcode.ctl intel-microcode amd64-microcode

## The very first thing to install will be sublime text - Rest of the packages are alphabetical
if [ $Install_SublimeText -eq 1 ]; then
	log $INFO "install sublime text"
	$apt_prefix sublime-text 
fi

## Installations based on command line checking
if [ $Install_Audacity -eq 1 ]; then
	$apt_prefix_rec audacity
fi
if [ $Install_Chromium -eq 1 ]; then
	log $INFO "install chromium"
	$apt_prefix chromium-browser
fi
if [ $Install_Docker -eq 1 ]; then
	log $INFO "install docker"
	$apt_prefix apt-transport-https ca-certificates curl software-properties-common
	$apt_prefix docker docker-compose docker-ce docker-doc docker-registry

	if [ $Docker_Remove_SUDO -eq 1 ]; then
		# -f will suppress output if group already exists, and $? will echo 0
		$dry_echo sudo groupadd -f docker
		$dry_echo sudo gpasswd -a $USER docker
		## Docker run won't work on the first-run because you must login/logout, entering a new session, making docker run fine.
		# docker run hello-world 
	fi
fi
if [ $Install_Emacs -eq 1 ]; then
	log $INFO "install emacs"
	$apt_prefix emacs
fi
if [ $Install_EXFatUtils -eq 1 ]; then
	log $INFO "install exfat-utils"
	$apt_prefix_rec exfat-fuse exfat-utils
fi
if [ $Install_Flatpak -eq 1 ]; then
	log $INFO "install Flatpak"
	$apt_prefix flatpak
	$dry_echo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi
if [ $Install_Flux -eq 1 ]; then
	log $INFO "install Flux"
	$apt_prefix fluxgui
fi
if [ $Install_GEdit -eq 1 ]; then
	log $INFO "install gedit"
	$apt_prefix gedit
fi
if [ $Install_GoogleChrome -eq 1 ]; then
	log $INFO "install google chrome"
	$apt_prefix google-chrome-stable
fi
if [ $Install_GParted -eq 1 ]; then
	log $INFO "install gparted"
	$apt_prefix gparted
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
	$apt_prefix grive
fi
if [ $Install_GUFW -eq 1 ]; then
	$apt_prefix gufw
fi
if [ $Install_KeepassPasswordManager -eq 1 ]; then
	log $INFO "install keypass"
	$apt_prefix keepassx
fi
if [ $Install_MozillaFirefox -eq 1 ]; then
	log $INFO "install firefox"
	$apt_prefix firefox
fi
if [ $Install_Okular -eq 1 ]; then
	log $INFO "install okular"
	$apt_prefix okular
fi
if [ $Install_Oracle_Java -eq 1 ]; then 
	if [ $Purge_OpenJDK -eq 1 ]; then
		log $INFO "PURGE OpenJDK"
		$dry_echo sudo apt-get purge -y openjdk-\*
	fi
	if [ $Install_Java_Version -eq 7 -o $Install_Java_Version -eq 8 -o $Install_Java_Version -eq 10 ]; then
		log $INFO "install oracle java version - Installing Java $Install_Java_Version"
	else
		echo "You are installing a possibly UNEXPECTED version of Oracle Java! Be careful about purging OpenJDK!"
		log $INFO "Unexepected oracle java version - Trying Java $Install_Java_Version"
	fi
	if [ $DRY_MODE -eq 0 ]; then
		echo "oracle-java${Install_Java_Version}-installer shared/accepted-oracle-license-v1-1 select true" | sudo /usr/bin/debconf-set-selections
		echo "oracle-java${Install_Java_Version}-installer shared/accepted-oracle-license-v1-1 seen true" | sudo /usr/bin/debconf-set-selections
	else
		echo "echo oracle-java${Install_Java_Version}-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections"
		echo "echo oracle-java${Install_Java_Version}-installer shared/accepted-oracle-license-v1-1 seen true | sudo /usr/bin/debconf-set-selections"
	fi
	$apt_prefix oracle-java${Install_Java_Version}-installer
	$apt_prefix oracle-java${Install_Java_Version}-set-default
fi
if [ $Install_P7Zip -eq 1 ]; then
	log $INFO "install p7zip"
	$apt_prefix_rec p7zip p7zip-rar p7zip-full
fi
if [ $Install_PulseAudioEqualizer -eq 1 ]; then
	pulse_config_file=/etc/pulse/default.pa
	log $INFO "install qpaeq"
	$apt_prefix pulseaudio-equalizer
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
			echo "load-module module-equalizer-sink | sudo tee -a $pulse_config_file"
			echo "load-module module-dbus-protocol | sudo tee -a $pulse_config_file"
		else
			echo "load-module module-equalizer-sink" | sudo tee -a $pulse_config_file
			echo "load-module module-dbus-protocol" | sudo tee -a $pulse_config_file
		fi
		
	fi
fi
if [ $Install_QBitTorrent -eq 1 ]; then
	log $INFO "install qbittorrent"
	$apt_prefix qbittorrent
fi
if [ $Install_QPDFView -eq 1 ]; then
	log $INFO "install qpdfview"
	$apt_prefix qpdfview
fi
if [ $Install_Slurm -eq 1 ]; then
	log $INFO "install slurm"
	$apt_prefix slurm
fi
if [ $Install_Thunderbird -eq 1 ]; then
	$apt_prefix thunderbird
fi
if [ $Install_TildaTmux -eq 1 ]; then
	log $INFO "install tilda"
	$apt_prefix tilda tmux
fi
if [ $Install_UGET -eq 1 ]; then
	$apt_prefix uget
fi
if [ $Install_VisualStudioCode -eq 1 ]; then
	log $INFO "install visual studio code"
	$apt_prefix code
fi
if [ $Install_Vivaldi -eq 1 ]; then
	log $INFO "install vivaldi"
	$apt_prefix vivaldi-stable
fi
if [ $Install_VLCMediaPlayer -eq 1 ]; then
	log $INFO "install vlc AND x265 codec"
	$apt_prefix_rec vlc libde265-0
	#$apt_prefix_rec vlc vlc-plugin-libde265 
fi
if [ $Install_WinFF -eq 1 ]; then
	$apt_prefix winff libavcodec-extra
fi
if [ $Install_ZSH -eq 1 ]; then
	log $INFO "install zsh"
	$apt_prefix zsh
fi

## LARGE installations
if [ $Install_LibreOffice -eq 1 ]; then
	log $INFO "install libreoffice-stuff"
	if [ $LibreOffice_Base -eq 1 ]; then
		log $INFO "install libreoffice-base"
	 	$apt_prefix libreoffice-base
	fi
	if [ $LibreOffice_Draw -eq 1 ]; then
		log $INFO "install libreoffice-draw"
	 	$apt_prefix libreoffice-draw
	fi
	if [ $LibreOffice_Impress -eq 1 ]; then
		log $INFO "install libreoffice-impress"
	 	$apt_prefix libreoffice-impress
	fi
	if [ $LibreOffice_Calc -eq 1 ]; then
		log $INFO "install libreoffice-calc"
	 	$apt_prefix libreoffice-calc
	fi
	if [ $LibreOffice_Math -eq 1 ]; then
		log $INFO "install libreoffice-math"
	 	$apt_prefix libreoffice-math
	fi
	if [ $LibreOffice_Writer -eq 1 ]; then
		log $INFO "install libreoffice-writer"
	 	$apt_prefix libreoffice-writer
	fi
	$apt_prefix -f
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
	$apt_prefix texlive-latex-base texlive-latex-extra texlive-science texlive-lang-english texstudio texlive-publishers
fi
if [ $Install_Octave -eq 1 ]; then
	log $INFO "install octave"
	$apt_prefix_rec liboctave-dev octave
fi
if [ $Install_Atom -eq 1 ]; then
	log $INFO "install atom"
	$apt_prefix atom
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
	$dry_echo wget -q https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
	# This is definitely gonna fail and be fixed in the next step
	$dry_echo sudo dpkg -i teamviewer_amd64.deb &>/dev/null 
	# In this step, teamviewer will definitely be fixed, which is why i supressed the previous output.
	$apt_prefix -f
	$dry_echo rm teamviewer_amd64.deb
	fi
fi
exit 0
