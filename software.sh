#!/bin/bash
#set -o errexit -o pipefail -o noclobber #-o nounset
## get util functions loaded
. util.sh
#. `which virtualenvwrapper.sh`

# use the display function to print this
disp "Software Setup Script - Raj Derasari"

#logging/utils/help
INFO="SW: INFO: "
ERROR="SW: ERROR: "

addaptrepo=" sudo add-apt-repository -y "
prefix=" sudo apt-get install -y "

## can add config file here if not in command line arguments (bash software.sh -f <configFile>)
CFGFILE=""

DRYRUN=0
dry_echo=""
DEBUGMODE=0
VERBOSE=0

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
			DRYRUN=1
			DRY_FLAG="-D"
			addaptrepo="echo sudo add-apt-repository -y "
			prefix="echo sudo apt-get install -y "
			dry_echo="echo "
			echo "Software setup script in dry-run mode"
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

#begin
#ADDREPO=""
curl > /dev/null 2>&1
if [ $? -eq 127 ]; then
	echo "curl not installed. This can cause problems in adding HTTPS repositories. installing curl now!"
	echo "sudo apt-get update" && $dry_echo sudo apt-get update > /dev/null 2>&1
	$prefix curl
fi

log $INFO "Begin"
if [ $Install_Flux -eq 1 ]; then
	$addaptrepo ppa:nathan-renniewaldock/flux
fi
if [ $Install_VLCMediaPlayer -eq 1 ]; then
	 $addaptrepo ppa:strukturag/libde265
fi
if [ $Install_Grive_GoogleDrive -eq 1 ]; then
	 $addaptrepo ppa:nilarimogard/webupd8
fi
if [ $Install_Java_Version -eq 8 ]; then
	 $addaptrepo ppa:webupd8team/java
fi
if [ $Install_Java_Version -eq 10 ]; then
	 $addaptrepo ppa:linuxuprising/java
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

## Pycharm installation not implemented yet
#if [ $Install_PyCharm -eq 1 ]; then
	#echo "deb http://archive.getdeb.net/ubuntu $(lsb_release -cs)-getdeb apps" | sudo tee /etc/apt/sources.list.d/getdeb-apps.list
	#wget -q -O- http://archive.getdeb.net/getdeb-archive.key | sudo apt-key add -
#fi
if [ $DRYRUN -ne 1 ]; then 
	if [ $Install_SublimeText -eq 1 ]; then
		curl https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add - 2>&1 >$(tty)
		echo "deb [arch=amd64] https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
	fi

	if [ $Install_Vivaldi -eq 1 ]; then
		curl http://repo.vivaldi.com/stable/linux_signing_key.pub | sudo apt-key add - 2>&1 >$(tty)
		echo "deb [arch=amd64] http://repo.vivaldi.com/stable/deb/ stable main" | sudo tee /etc/apt/sources.list.d/vivaldi.list
	fi

	if [ $Install_VisualStudioCode -eq 1 ]; then
		curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - 2>&1 >$(tty)
		echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
	fi

	if [ $Install_GoogleChrome -eq 1 ]; then
		curl https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 2>&1 >$(tty)
		echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
	fi
fi

## dont update if in drymode
# sudo apt-key update && 
$dry_echo sudo apt-get update #>&/dev/null

# First things first: Check if install AMD or Intel microcode:
if [ $DRYRUN -ne 1 ]; then
	sudo lshw -c CPU | grep -q -i intel
	if [ $? -eq 0 ]; then 
		log $INFO "install intel microcode"
		$prefix microcode.ctl intel-microcode
	else
		sudo lshw -c CPU | grep -q -i amd
		if [ $? -eq 0 ]; then
			log $INFO "install amd microcode"
			$prefix microcode.ctl amd64-microcode
		else
			echo "Your processor platform (Not Intel or AMD) could not be determined!"
		fi
	fi
fi
#Zshell extension for bourne shell which is default = This allows for some better scripting
if [ $Install_ZSH -eq 1 ]; then
	log $INFO "install zsh"
	$prefix zsh
fi

if [ $Install_Flux -eq 1 ]; then
	log $INFO "install Flux"
	$prefix fluxgui
fi

# password manager
if [ $Install_KeepassPasswordManager -eq 1 ]; then
	log $INFO "install keypass"
	$prefix keepassx
fi

# next 4web browsers options
if [ $Install_Chromium -eq 1 ]; then
	log $INFO "install chromium"
	$prefix chromium-browser
fi

if [ $Install_TexStudio -eq 1 ]; then
	checkBash="`grep \"alias clean=\" ~/.bashrc`"
	if [[ ! -z $checkBash ]]; then
		log $INFO "Clean alias already exists"
	else
		log $INFO "Setting up clean alias for latex"
		alias texcleanAuxFiles="rm *.aux *.bbl *.syn* *.toc *.blg *.log *.out" >> ~/.bashrc
	fi
	log $INFO "install LaTeX"
	$prefix texlive-latex-base texlive-latex-extra texlive-science texlive-lang-english texstudio texlive-publishers
fi

if [ $Install_GoogleChrome -eq 1 ]; then
	log $INFO "install google chrome"
	$prefix --install-recommends google-chrome-stable
fi

if [ $Install_MozillaFirefox -eq 1 ]; then
	log $INFO "install firefox"
	$prefix --install-recommends firefox firefox-locale-en
fi

if [ $Install_Vivaldi -eq 1 ]; then
	log $INFO "install vivaldi"
	$prefix --install-recommends vivaldi-stable
fi
if [ $Install_Emacs -eq 1 ]; then
	log $INFO "install emacs"
	$prefix --install-recommends emacs
fi

if [ $Install_GEdit -eq 1 ]; then
	log $INFO "install gedit"
	 $prefix gedit
fi

## pycharm installation via apt is not supported by this project yet.
# if [ $Install_PyCharm -eq 1 ]; then
# 	log $INFO "install Pycharm"
# 	$prefix pycharm
# fi

# exfat
if [ $Install_EXFatUtils -eq 1 ]; then
	log $INFO "install exfat-utils"
	 $prefix --install-recommends exfat-fuse exfat-utils	
fi

# vlc
if [ $Install_VLCMediaPlayer -eq 1 ]; then
	log $INFO "install vlc"
	 $prefix --install-recommends vlc browser-plugin-vlc libde265-0
	# $prefix --install-recommends vlc-plugin-libde265 
fi

# 7z
if [ $Install_P7Zip -eq 1 ]; then
	log $INFO "install p7zip"
	 $prefix --install-recommends p7zip p7zip-rar p7zip-full
fi

#qpdfview- lighter than okular and faster than evince: However, limited functionality
if [ $Install_QPDFView -eq 1 ]; then
	log $INFO "install qpdfview"
	 $prefix qpdfview
fi

#qbittorrent
if [ $Install_QBitTorrent -eq 1 ]; then
	log $INFO "install qbittorrent"
	 $prefix qbittorrent
fi

# gparted
if [ $Install_GParted -eq 1 ]; then
	log $INFO "install gparted"
	 $prefix --install-recommends gparted
fi

#octave
if [ $Install_Octave -eq 1 ]; then
	log $INFO "install octave"
	 $prefix --install-recommends liboctave-dev octave
fi

if [ $Install_UGET -eq 1 ]; then
	$prefix uget
fi

#okular
if [ $Install_Okular -eq 1 ]; then
	log $INFO "install okular"
	$prefix --install-recommends okular
fi

#Java/JDK
if [ $Install_Oracle_Java -eq 1 ]; then 
	if [ $Install_Java_Version -eq 8 -o $Install_Java_Version -eq 10 ]; then
		log $INFO "install oracle java version -  $Install_Java_Version"
	else
		echo "You are installing a possibly UNEXPECTED version of Oracle Java! Be careful about purging OpenJDK!"
		log $INFO "install oracle java - version -  $Install_Java_Version"
	fi
	if [ $Purge_OpenJDK -eq 1 ]; then
		log $INFO "PURGE OpenJDK"
		$dry_echo sudo apt-get purge -y openjdk-\*
	fi

	if [ $DRYRUN -ne 1 ]; then 
		echo "oracle-java${Install_Java_Version}-installer shared/accepted-oracle-license-v1-1 select true" | sudo /usr/bin/debconf-set-selections
	fi
	
	$prefix oracle-java${Install_Java_Version}-installer
	$prefix oracle-java${Install_Java_Version}-set-default
fi

#coding ide
if [ $Install_VisualStudioCode -eq 1 ]; then
	log $INFO "install visual studio code"
	$prefix code
fi
#If you are using VS Code, note that you have to remove the line which modifies \$TMPDIR in your .zprofile.

#sublime
if [ $Install_SublimeText -eq 1 ]; then
	log $INFO "install sublime text"
	$prefix --install-recommends sublime-text 
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
	$prefix grive
fi
#audacity audio editor
if [ $Install_Audacity -eq 1 ]; then
	$prefix audacity
fi
#winff audio conversion
if [ $Install_WinFF -eq 1 ]; then
	 $prefix winff libavcodec-extra
fi
# tilda and tumix, for terminal
if [ $Install_TildaTmux -eq 1 ]; then
	log $INFO "install tilda"
	 $prefix tilda tmux
fi
# atom editor
if [ $Install_Atom -eq 1 ]; then
	log $INFO "install atom"
	$prefix atom
fi

if [ $Install_LibreOffice -eq 1 ]; then
	log $INFO "install libreoffice-stuff"
	if [ $LibreOffice_Base -eq 1 ]; then
		log $INFO "install libreoffice-base"
		 $prefix libreoffice-base
	fi
	if [ $LibreOffice_Draw -eq 1 ]; then
		log $INFO "install libreoffice-draw"
		 $prefix libreoffice-draw
	fi
	if [ $LibreOffice_Impress -eq 1 ]; then
		log $INFO "install libreoffice-impress"
		 $prefix libreoffice-impress
	fi
	if [ $LibreOffice_Calc -eq 1 ]; then
		log $INFO "install libreoffice-calc"
		 $prefix libreoffice-calc
	fi
	if [ $LibreOffice_Math -eq 1 ]; then
		log $INFO "install libreoffice-math"
		 $prefix libreoffice-math
	fi
	if [ $LibreOffice_Writer -eq 1 ]; then
		log $INFO "install libreoffice-writer"
		 $prefix libreoffice-writer
	fi
	$dry_echo sudo apt-get install -yf
else
	log $INFO "NOT install libreoffice"
fi


if [ "$1" = "teamviewer" ] || [ $Install_TeamViewer -eq 1 ]; then
	if [ ! -z `which teamviewer` ]; then
		log $INFO "teamviewer already installed, download teamviewer debian file"
		echo "Teamviewer is already installed! will ONLY download the latest deb file"
		$dry_echo wget -q https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
		echo "teamviewer downloaded. To install, enter the command:"
		echo "sudo dpkg -i teamviewer_amd64.deb"
	else
		log $INFO "install teamviewer"
		$dry_echo wget -q https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
		# This is definitely gonna fail and be fixed in the next step
		$dry_echo sudo dpkg -i teamviewer_amd64.deb &>/dev/null 
		# In this step, teamviewer will definitely be fixed, which is why i supressed the previous output.
		$dry_echo sudo apt-get install -fy
		$dry_echo rm teamviewer_amd64.deb	
	fi
else
	echo "Not installing teamviewer"
fi

if [ $Install_Docker -eq 1 ]; then
	log $INFO "install docker"
	bash docker.sh $DRY_FLAG
fi

exit 0
