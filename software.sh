#!/bin/bash
#set -o errexit -o pipefail -o noclobber #-o nounset
#. `which virtualenvwrapper.sh`
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
			echo "Loading software parameters from Configuration Profile:" $2
			CFGFILE="$2"
			. $CFGFILE
			shift 2
			;;
		-d|--dry-run)
			echo "Dry-running installation of software!"
			DRY_FLAG="-d"
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
elif [ -e $CFGFILE ]; then
	## CFG file is not defined
	echo "Error - Configuration file does not exist!
	Please use the \"-f\" argument and pass a valid Configuration File!
	Alternatively you can edit the file `basename $0` and define the variable CFGFILE"
	exit 3
fi
		
#begin
#Check if curl is installed, if not then install it
curl > /dev/null 2>&1
if [ $? -eq 127 ]; then
	echo "curl not installed. This can cause problems in adding HTTPS repositories. installing curl now!"
	$apt_update > /dev/null 2>&1
	$apt_prefix_rec curl
fi

log $INFO "Begin"
if [ $Install_Flatpak -eq 1 ]; then
	$addaptrepo ppa:alexlarsson/flatpak
fi
if [ $Install_Flux -eq 1 ]; then
	$addaptrepo ppa:nathan-renniewaldock/flux
fi
if [ $Install_VLCMediaPlayer -eq 1 ]; then
	 $addaptrepo ppa:strukturag/libde265
fi
if [ $Install_Grive_GoogleDrive -eq 1 ]; then
	 $addaptrepo ppa:nilarimogard/webupd8
fi
if [ $Install_Oracle_Java -eq 1 ]; then
	if [ $Install_Java_Version -eq 8 ]; then
	 	$addaptrepo ppa:webupd8team/java
	fi
	if [ $Install_Java_Version -eq 10 ]; then
		 $addaptrepo ppa:linuxuprising/java
	fi
fi
if [ $Install_UGET -eq 1 ]; then
	 $addaptrepo ppa:plushuang-tw/uget-stable
fi
if [ $Install_QPDFView -eq 1 ]; then
	 $addaptrepo ppa:adamreichold/qpdfview-dailydeb
fi
if [ $Install_Octave -eq 1 ]; then
	 $addaptrepo ppa:octave/stable
fi
if [ $Install_QBitTorrent -eq 1 ]; then
	 $addaptrepo ppa:qbittorrent-team/qbittorrent-stable
fi
if [ $Install_Atom -eq 1 ]; then
	 $addaptrepo ppa:webupd8team/atom
fi
if [ $Install_Audacity -eq 1 ]; then
	 $addaptrepo ppa:ubuntuhandbook1/audacity
fi

_architecture=`uname -m`
if [ $_architecture = x86_64 ]; then
		_architecture="[arch=amd64] "
elif [ $_architecture = i386 ]; then
		_architecture="[arch=i386] "
fi

## Pycharm installation not implemented yet
#if [ $Install_PyCharm -eq 1 ]; then
	#echo "deb http://archive.getdeb.net/ubuntu $(lsb_release -cs)-getdeb apps" | sudo tee /etc/apt/sources.list.d/getdeb-apps.list
	#wget -q -O- http://archive.getdeb.net/getdeb-archive.key | sudo apt-key add -
#fi
echo "deb $_architecture https://download.sublimetext.com/ apt/stable/" 
if [ $DRY_MODE -ne 1 ]; then
	if [ $Install_SublimeText -eq 1 ]; then
		curl https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
		echo "deb $_architecture https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
	fi

	if [ $Install_Vivaldi -eq 1 ]; then
		curl http://repo.vivaldi.com/stable/linux_signing_key.pub | sudo apt-key add -
		echo "deb $_architecture http://repo.vivaldi.com/stable/deb/ stable main" | sudo tee /etc/apt/sources.list.d/vivaldi.list
	fi

	if [ $Install_VisualStudioCode -eq 1 ]; then
		curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
		echo "deb $_architecture https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
	fi

	if [ $Install_GoogleChrome -eq 1 ]; then
		curl https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
		echo 'deb $_architecture http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
	fi
fi

## Update sources
$apt_update

# First things first: Check if install AMD or Intel microcode:
if [ $DRY_MODE -ne 1 ]; then
	sudo lshw -c CPU | grep -q -i intel
	if [ $? -eq 0 ]; then 
		log $INFO "install intel microcode"
		$apt_prefix microcode.ctl intel-microcode
	else
		sudo lshw -c CPU | grep -q -i amd
		if [ $? -eq 0 ]; then
			log $INFO "install amd microcode"
			$apt_prefix microcode.ctl amd64-microcode
		else
			echo "Your processor platform (Not Intel or AMD) could not be determined!"
		fi
	fi
fi
#Zshell extension for bourne shell which is default = This allows for some better scripting
if [ $Install_ZSH -eq 1 ]; then
	log $INFO "install zsh"
	$apt_prefix zsh
fi

if [ $Install_Flux -eq 1 ]; then
	log $INFO "install Flatpak"
	$apt_prefix flatpak
fi
if [ $Install_Flux -eq 1 ]; then
	log $INFO "install Flux"
	$apt_prefix fluxgui
fi

# password manager
if [ $Install_KeepassPasswordManager -eq 1 ]; then
	log $INFO "install keypass"
	$apt_prefix keepassx
fi

# next 4web browsers options
if [ $Install_Chromium -eq 1 ]; then
	log $INFO "install chromium"
	$apt_prefix chromium-browser
fi

if [ $Install_TexStudio -eq 1 ]; then
	checkBash="`grep \"alias texcleanAuxFiles=\" ~/.bashrc`"
	if [[ ! -z $checkBash ]]; then
		log $INFO "Clean alias for texstudio already exists"
	else
		log $INFO "Setting up texcleanAuxFiles alias for latex"
		alias texcleanAuxFiles="rm *.aux *.bbl *.syn* *.toc *.blg *.log *.out" >> ~/.bashrc
	fi
	log $INFO "install LaTeX"
	$apt_prefix texlive-latex-base texlive-latex-extra texlive-science texlive-lang-english texstudio texlive-publishers
fi

if [ $Install_GoogleChrome -eq 1 ]; then
	log $INFO "install google chrome"
	$apt_prefix google-chrome-stable
fi

if [ $Install_MozillaFirefox -eq 1 ]; then
	log $INFO "install firefox"
	$apt_prefix firefox
fi

if [ $Install_Vivaldi -eq 1 ]; then
	log $INFO "install vivaldi"
	$apt_prefix vivaldi-stable
fi
if [ $Install_Emacs -eq 1 ]; then
	log $INFO "install emacs"
	$apt_prefix emacs
fi

if [ $Install_GEdit -eq 1 ]; then
	log $INFO "install gedit"
	 $apt_prefix gedit
fi

## pycharm installation via apt-get or otherwise is not supported by this project yet.
# if [ $Install_PyCharm -eq 1 ]; then
# 	log $INFO "install Pycharm"
# 	$apt_prefix pycharm
# fi
if [ $Install_Thunderbird -eq 1 ]; then
	## commenting in case of future adding of Mailspring
	#log "Downloading mailspring deb" 
	## mailspring, not mailspring
	# curl https://updates.getmailspring.com/download?platform=linuxDeb
	$apt_prefix thunderbird
fi
# exfat
if [ $Install_EXFatUtils -eq 1 ]; then
	log $INFO "install exfat-utils"
	 $apt_prefix_rec exfat-fuse exfat-utils	
fi

# vlc
if [ $Install_VLCMediaPlayer -eq 1 ]; then
	log $INFO "install vlc AND x265 codec"
	$apt_prefix_rec vlc libde265-0
	#$apt_prefix_rec vlc vlc-plugin-libde265 
fi

# 7z
if [ $Install_P7Zip -eq 1 ]; then
	log $INFO "install p7zip"
	 $apt_prefix_rec p7zip p7zip-rar p7zip-full
fi

#qpdfview- lighter than okular and faster than evince: However, limited functionality
if [ $Install_QPDFView -eq 1 ]; then
	log $INFO "install qpdfview"
	 $apt_prefix qpdfview
fi

#qbittorrent
if [ $Install_QBitTorrent -eq 1 ]; then
	log $INFO "install qbittorrent"
	 $apt_prefix qbittorrent
fi

# gparted
if [ $Install_GParted -eq 1 ]; then
	log $INFO "install gparted"
	 $apt_prefix gparted
fi

#octave
if [ $Install_Octave -eq 1 ]; then
	log $INFO "install octave"
	 $apt_prefix_rec liboctave-dev octave
fi

if [ $Install_UGET -eq 1 ]; then
	$apt_prefix uget
fi

#okular
if [ $Install_Okular -eq 1 ]; then
	log $INFO "install okular"
	$apt_prefix okular
fi

#Java/JDK
if [ $Install_Oracle_Java -eq 1 ]; then 
	##check if purge OpenJDK or not
	if [ $Purge_OpenJDK -eq 1 ]; then
		log $INFO "PURGE OpenJDK"
		$dry_echo sudo apt-get purge -y openjdk-\*
	fi
	# install Java 8/10
	if [ $Install_Java_Version -eq 7 -o $Install_Java_Version -eq 8 -o $Install_Java_Version -eq 10 ]; then
		log $INFO "install oracle java version - Installing Java $Install_Java_Version"
	else
		echo "You are installing a possibly UNEXPECTED version of Oracle Java! Be careful about purging OpenJDK!"
		log $INFO "Unexepected oracle java version - Trying Java $Install_Java_Version"
	fi
	## Setting some value as 1
	if [ $DRY_MODE -ne 1 ]; then 
		echo "oracle-java${Install_Java_Version}-installer shared/accepted-oracle-license-v1-1 select true" | sudo /usr/bin/debconf-set-selections
		echo "oracle-java${Install_Java_Version}-installer shared/accepted-oracle-license-v1-1 seen true" | sudo /usr/bin/debconf-set-selections
	fi
	$apt_prefix oracle-java${Install_Java_Version}-installer
	$apt_prefix oracle-java${Install_Java_Version}-set-default
fi

#coding ide
if [ $Install_VisualStudioCode -eq 1 ]; then
	log $INFO "install visual studio code"
	$apt_prefix code
fi
#If you are using VS Code, note that you have to remove the line which modifies \$TMPDIR in your .zprofile.

#sublime
if [ $Install_SublimeText -eq 1 ]; then
	log $INFO "install sublime text"
	$apt_prefix sublime-text 
fi

#google drive (3rd party)
if [ $Install_Grive_GoogleDrive -eq 1 ]; then
	checkBash="`grep \"alias fetchd=\" ~/.bashrc`"
	if [[ ! -z $checkBash ]]; then
		log $INFO "grive aliases already exist"
	else
		log $INFO "Setting up grive aliases"
		alias fetchd="grive -f --dry-run"
		alias fetch="grive -f"
		alias uploadall="grive -u"
	fi
	log $INFO "install grive"
	$apt_prefix grive
fi
#audacity audio editor
if [ $Install_Audacity -eq 1 ]; then
	$apt_prefix_rec audacity
fi
#winff audio conversion
if [ $Install_WinFF -eq 1 ]; then
	 $apt_prefix winff libavcodec-extra
fi
# tilda and tumix, for terminal
if [ $Install_TildaTmux -eq 1 ]; then
	log $INFO "install tilda"
	 $apt_prefix tilda tmux
fi
# atom editor
if [ $Install_Atom -eq 1 ]; then
	log $INFO "install atom"
	$apt_prefix atom
fi

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
else
	log $INFO "NOT install libreoffice"
fi

if [ "$1" = "teamviewer" ] || [ $Install_TeamViewer -eq 1 ]; then
	if [ ! -z `which teamviewer` ]; then
		log $INFO "teamviewer already installed, download teamviewer debian file"
		echo "Teamviewer is already installed! will ONLY download the latest deb file from the server"
		$dry_echo wget -q https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
		echo "teamviewer downloaded. To install, enter the command:"
		echo "sudo dpkg -i teamviewer_amd64.deb"
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

if [ $Install_Docker -eq 1 ]; then
	log $INFO "install docker"
	bash docker.sh $DRY_FLAG
fi
exit 0
