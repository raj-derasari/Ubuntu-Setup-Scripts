#!/bin/bash 
source `which virtualenvwrapper.sh`
echo "----------------------------------------------------------------------------"
echo "                        Ubuntu Master Script"
echo "----------------------------------------------------------------------------"
#logging/utils/help
LOGGER=`pwd`/log_master.log
INFO="Master: INFO: "
ERROR="Master: ERROR: "
DEBUG="DEBUG: "
log()
{
	echo -e "[${USER}]\t[`date`]\t${*}" >> "${LOGGER}"
}

PYTHON_DEBUG_MODE=0

##begin
export startDir=`pwd`
export ERRORFILE=`pwd`/log_errors.log

if test "$1" = "--clear-logs"; then
	echo "Clear Logs!"
	rm *.log 2>/dev/null
	log $INFO "cleared all logs"
elif [[ ! -z "$1" ]]; then
	echo "Did not understand command-line argument. Did you perhaps mean \"--clear-logs\"?"
	exit
fi

checkBash="`grep \"alias brc=\" ~/.bashrc`"
if [[ ! -z $checkBash ]]; then
	log $INFO "Seems like aliases are already setup. Not modifying ~/.bashrc"
else
	cat <<EOT >> ~/.bashrc
venvwrap="virtualenvwrapper.sh"
# /usr/bin/which -a \$venvwrap
if [ \$? -eq 0 ]; then
venvwrap=\`/usr/bin/which \$venvwrap\`
source \$venvwrap
fi
alias brc="sudo nano ~/.bashrc"
alias sbrc="source ~/.bashrc"
alias sau="sudo apt-key update;sudo apt-get update"
alias sai="sudo apt-get install"
alias saiy="sudo apt-get -y install"
alias aptgetupgrade="sudo apt-get upgrade"
alias aptreset="sudo mv /var/lib/apt/lists/lock ~/locks/apt/list; sudo mv /var/lib/dpkg/lock ~/locks/dpkg;sudo mv /var/cache/apt/archives/lock ~/locks/apt; sudo dpkg --configure -a"
_sai_complete() { 
	mapfile -t COMPREPLY < <(apt-cache --no-generate pkgnames "$2");
}
complete -F _sai_complete sai
complete -F _sai_complete saiy
EOT
	source ~/.bashrc
	log $INFO "Updated .bashrc profile and loaded in bash"
fi

### Variables to set-up installation of Applications, Bloatware and whatnot
Do_AptGetUpgradeLast=1
Do_CleanupAfterExec=1

Master_Dependencies=1
Master_RemoveBloatware=1
Master_Software=1
Master_Python=1

# strongly recommended packages
export Install_EXFatUtils=1
export Install_Flux=1
export Install_GEdit=1
export Install_Git=1
export Install_GParted=1
export Install_IntelFirmware=1
export Install_P7Zip=1
export Install_QBitTorrent=1
export Install_QPDFView=1
export Install_UGET=1
export Install_VLCMediaPlayer=1
export Install_ZSH=1

# choose a web browser
export Install_Chromium=1
export Install_GoogleChrome=1
export Install_MozillaFirefox=1
export Install_Vivaldi=1

# audacity audio editing application
export Install_Audacity=1
export Install_WinFF=1

## other packages: editors/programming, remoting, password mgmt, office tools
export Install_Docker=1
export Install_Grive_GoogleDrive=1
export Install_KeepassPasswordManager=1
export Install_Octave=1
export Install_Okular=1
export Install_TildaTmux=1  # terminal client/replacement for ctrl+alt+t

#TexStudio
export Install_TexStudio=1

#Java
export Remove_OpenJDK=0
export Install_OracleJava8=0

export Install_Atom=0
export Install_SublimeText=1
export Install_VisualStudioCode=1

export Install_LibreOffice=1
export LibreOffice_Base=1
export LibreOffice_Draw=1
export LibreOffice_Impress=1
export LibreOffice_Math=1
export LibreOffice_Writer=1

export Install_TeamViewer=1
#TODO
#export Install_RealVNC_Server=1
export Install_RealVNC_Viewer=1
export Install_PyCharm=1

export Setup_Python_Dev=1
export Setup_VirtualEnv=1

## python stuff will be installed in a virtual env, name here
export VirtualEnv_Name="seas"
export VirtualEnv_Directory=~/.virtualenvs/$VirtualEnv_Name

# set one value from 2 and 3
export Python_PreferredVersion=2
export Python_InstallBasics=1
export Python_InstallWebDevelopmentTools=1
export Python_InstallJupyter=1
export Python_InstallMachineLearningTools=1     # Must set to 1 if you want to install tensorflow!
export Python_InstallComputerGraphicsTools=0    ## TODO, not implemented
export Python_InstallNLTK=1
export Python_Compile_Tensorflow=0
export Python_Tensorflow_CPUOnly=0
export Python_Tensorflow_GPU=0
export Python_Tensorflow_MKL=0

sudo apt-key update && sudo apt-get update > /dev/null

if [ $Master_Dependencies -eq 1 ]; then
	log $INFO "Setting up lib* and dependencies"
	bash libsdeps.sh 2>>"$ERRORFILE"
else
	log $INFO "NOT setting up lib* and dependencies"
fi

if [ $Master_RemoveBloatware -eq 1 ]; then
	log $INFO "Setting up bloatware removal"
	bash bloatremove.sh 2>>"$ERRORFILE"
else
	log $INFO "NOT setting up bloatware removal"
fi

if [ $Master_Software -eq 1 ]; then
	log $INFO "Setting up software"
	bash software.sh 2>>"$ERRORFILE"
else
	log $INFO "NOT setting up software"
fi

if [ $Master_Python -eq 1 ]; then
	if [ $PYTHON_DEBUG_MODE -eq 1 ]; then
		log $INFO "DRY RUN python - debug mode"
		bash python_util.sh --debug $Python_PreferredVersion $VirtualEnv_Name 2>>"$ERRORFILE"
	else
		log $INFO "Setting up python"
		bash python_util.sh $Python_PreferredVersion $VirtualEnv_Name 2>>"$ERRORFILE"
	fi
else
	log $INFO "NOT setting up python"
fi

# Cleanup
if [ $Do_CleanupAfterExec -eq 1 ]; then
	log $INFO "Cleaning up cached, tmp, deb files"
	sudo apt-get install -fy 2>>"$ERRORFILE" # fix dependencies
	sudo apt -y autoclean 2>>"$ERRORFILE" # removes extra cache files
	sudo apt -y autoremove 2>>"$ERRORFILE" # removes deb packages but not all of them sadly
	rm -rfd ~/.cache/pip 2>>"$ERRORFILE" # removes pip packages
	rm -rfd /tmp/ 2>/dev/null # removes temp files not made by user
	sudo rm -f /var/cache/apt/archives/*.deb   # removes deb files apt cache
fi

if [ $Do_AptGetUpgradeLast -eq 1 ]; then
	log $INFO "apt-get upgrade before exit"
	sudo apt-get upgrade -y 2>>"$ERRORFILE" # fix dependencies
	sudo apt -y autoremove 2>>"$ERRORFILE" # removes packages
	
	#Cleanup after upgrade
	log $INFO "Cleanup cache tmp and deb -- after upgrade"
	rm -rfd /tmp/ 2>/dev/null
	sudo apt -y autoclean 2">>$ERRORFILE" # removes extra cache files
	sudo rm /var/cache/apt/archives/*.deb 2>>"$ERRORFILE"
	echo "It is recommended to restart your computer now."
	echo -e "Enter y to restart, or anything else to exit.\n"
	read shut
	if test "$shut" = "y"; then
		log $INFO "Finish_With_Reboot"
		sudo shutdown -r 0
	else
		log $INFO "Finish_No_Reboot"
		echo -e "Logs are stored in $startDir \n"
		echo "Done setting up. GL & HF!"
		exit
	fi
fi
exit
