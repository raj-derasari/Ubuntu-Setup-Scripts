#!/bin/bash
export XDG_CURRENT_DESKTOP=GNOME
# Possible values: 
# Unity,GNOME,XFCE,KDE,LXDE,Pantheon

## you can set up your own variables, values here:
export BF=~/.bashrc ## your bashrc profile file

### Variables to set-up installation of Applications, Bloatware and whatnot
Do_AptGetUpgradeLast=1
Do_CleanupAfterExec=1

Master_Dependencies=1
Master_RemoveBloatware=1
Master_Software=1
Master_Python=1

# debugging some stuff
PYTHON_DEBUG_MODE=0
MASTER_DEBUG_MODE=0

# strongly recommended packages
export Install_EXFatUtils=1
export Install_Flux=1
export Install_Git=1
export Install_GParted=1
export Install_P7Zip=1
export Install_QBitTorrent=1
export Install_QPDFView=1
export Install_UGET=1
export Install_VLCMediaPlayer=1
export Install_ZSH=1

# choose a web browser
export Install_Chromium=1
export Install_GoogleChrome=0
export Install_MozillaFirefox=1
export Install_Vivaldi=0

# audacity audio editing application
export Install_Audacity=1
export Install_WinFF=1

## other packages: editors/programming, remoting, password mgmt, office tools
export Install_Docker=1
export Docker_Remove_SUDO=1
export Install_Grive_GoogleDrive=1
export Install_KeepassPasswordManager=1
export Install_Octave=1
export Install_Okular=1
export Install_TildaTmux=1  # terminal client/replacement for ctrl+alt+t

#TexStudio
export Install_TexStudio=1

#Java
export Remove_OpenJDK=1
export Install_OracleJava8=0;
export Install_OracleJava10=1;  ## todo, not implemented

# Gedit is a regular text editor but can be quite handy
export Install_GEdit=1
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
export Install_PyCharm=0

# setting up python for developers
export Setup_Python_Dev=1

# virtualenv - if you are using Ubuntu 18 or above, it is highly recommended to use virtualenv with Python2 or Python3
export Setup_VirtualEnv=1

# if 1 above, consider setting up the next two parameters
export VirtualEnv_Name="venv1"
export VirtualEnv_Directory=~/.virtualenvs/$VirtualEnv_Name

# set one value from 2 and 3
export Python_PreferredVersion=3

#python setup - installing python libraries
export Python_InstallBasics=1
export Python_InstallWebDevelopmentTools=1
export Python_InstallDjango=1
export Python_InstallJupyter=1
export Python_InstallMachineLearningTools=1     # Must set to 1 if you want to install tensorflow!
export Python_InstallComputerGraphicsTools=0    ## TODO, not implemented
export Python_InstallNLTK=1
export Python_Compile_Tensorflow=0
export Python_Tensorflow_CPUOnly=1
export Python_Tensorflow_GPU=0
export Python_Tensorflow_MKL=0

## configuration is finished here
## master script begins here

echo "----------------------------------------------------------------------------"
echo "                        Ubuntu Master Script"
echo "----------------------------------------------------------------------------"
##TODO: check out apt-get install byobu"

#logging/utils/help
LOGGER=`pwd`/log_master.log
INFO="Master: INFO: "
ERROR="Master: ERROR: "
DEBUG="DEBUG: "

#define the logging function
log()
{
	echo -e "[${USER}]\t[`date`]\t${*}" >> "${LOGGER}"
}

##begin
export startDir=`pwd`
export ERRORFILE=`pwd`/log_errors.log

## CLEAR-LOG-CONDITION
if test "$1" = "--clear-logs"; then
	echo " ------------------------------------------ "
	echo "              Clearing Logs"
	echo " ------------------------------------------ "
	rm *.log 2>&1 > /dev/null && echo "Logs have been cleared"
	log $INFO "cleared all logs"
elif [[ ! -z "$1" ]]; then
	echo "Did not understand command-line argument. Did you mean \"--clear-logs\"?"
	exit
fi

## ALIAS SETUP
checkBash="`grep \"alias brc=\" $BF`"
if [[ ! -z $checkBash ]]; then
	log $INFO "common-aliases - Seems like aliases are already setup. Not modifying $BF"
else
	# the first line permanently sets your bash file in the $BF variable
	cat <<EOT >> $BF
alias sh=bash
export BF=$BF
alias brc="sudo nano $BF"
alias sbrc="source $BF"
alias sau="sudo apt-get update"
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
fi

source $BF
log $INFO "Updated .bashrc profile and loaded in bash"

checkBash="`grep \"virtualenvwrapper.sh\" $BF`"
if [[ ! -z $checkBash ]]; then
	log $INFO "virtualenvwrapper - Seems like aliases are already setup. Not modifying $BF"
else
	cat <<EOT >> $BF
venvwrap="virtualenvwrapper.sh"
if [ \$? -eq 0 ]; then
	venvwrap=\`/usr/bin/which \$venvwrap\`
	source \$venvwrap
fi
EOT
fi

## libsdeps
if [ $Master_Dependencies -eq 1 ]; then
	#sudo apt-key update && 
	echo "Running sudo apt-get update" && log $INFO "first run of apt-get update in masterscript" && sudo apt-get update > /dev/null

	echo " ------------------------------------------ "
	echo "      Basic Libraries and dependencies"
	echo " ------------------------------------------ "
	log $INFO "Setting up lib* and dependencies"
	bash libsdeps.sh 2>>"${ERRORFILE}"
	if [ $Setup_VirtualEnv -eq 1 ]; then
		source $BF
	fi
else
	log $INFO "NOT setting up lib* and dependencies"
fi


## bloatremove
if [ $Master_RemoveBloatware -eq 1 ]; then
	echo " ------------------------------------------ "
	echo "      Bloatware removal"
	echo " ------------------------------------------ "
	echo "      Detected Desktop Environment: " $XDG_CURRENT_DESKTOP
	echo " ------------------------------------------ "
	log $INFO "Bloatremove: Detected Desktop:" ${XDG_CURRENT_DESKTOP}
	case $XDG_CURRENT_DESKTOP in
		Unity|LXDE|GNOME) #|XFCE|KDE|Pantheon)  # have to work on the rest
		echo "Running bloatremove for ${XDG_CURRENT_DESKTOP}" && bash BR,SWC_${XDG_CURRENT_DESKTOP}.sh 2>>"${ERRORFILE}";
	;;
esac
else
	log $INFO "NOT setting up bloatware removal"
fi


## softwares
if [ $Master_Software -eq 1 ]; then
	#sudo apt-key update && 
	echo "Running sudo apt-get update" && log $INFO "first run of apt-get update in masterscript" && sudo apt-get update > /dev/null
	echo " ------------------------------------------ "
	echo "      Installing Software"
	echo " ------------------------------------------ "
	log $INFO "Setting up software"
	bash software.sh 2>>"${ERRORFILE}"
else
	log $INFO "NOT setting up software"
fi

## python
if [ $Master_Python -eq 1 ]; then
	#sudo apt-key update && 
	echo "Running sudo apt-get update" && log $INFO "first run of apt-get update in masterscript" && sudo apt-get update > /dev/null
	if [ $PYTHON_DEBUG_MODE -eq 1 ]; then
		echo " ------------------------------------------ "
		echo "      Python - DEBUG MODE"
		echo " ------------------------------------------ "
		log $INFO "DRY RUN python - debug mode"
		bash python_util.sh --debug $Python_PreferredVersion $VirtualEnv_Name 2>>"${ERRORFILE}"
	else
		echo " ------------------------------------------ "
		echo "                 Python"
		echo " ------------------------------------------ "
		log $INFO "Setting up python"
		bash python_util.sh $Python_PreferredVersion $VirtualEnv_Name 2>>"${ERRORFILE}"
	fi
else
	log $INFO "NOT setting up python"
fi

#  ------------------------------------------
##                    APT-GET-UPGRADE
# ------------------------------------------ 
if [ $Do_AptGetUpgradeLast -eq 1 ]; then
	log $INFO "apt-get upgrade before exit"
	echo ""
	echo " ------------------------------------------ "
	echo "     Cleaning up ~/.cache/pip, /tmp, .deb files     "
	echo " ------------------------------------------ "
	echo ""
	#sudo apt-key update && 
	sudo apt-get update > /dev/null
	sudo apt-get upgrade -y 2>>"${ERRORFILE}"; # fix dependencies
	sudo apt -y autoremove 2>>"${ERRORFILE}"; # removes packages
fi
#  ------------------------------------------
##                    CLEANUP
# ------------------------------------------ 
if [ $Do_CleanupAfterExec -eq 1 ]; then
	log $INFO "Cleaning up ~/.cache/pip, tmp, deb files"
	echo ""
	echo " ------------------------------------------ "
	echo "     Cleaning up ~/.cache/pip, /tmp, .deb files     "
	echo " ------------------------------------------ "
	echo ""
	sudo apt-get install -fy 2>>"${ERRORFILE}"; # fix dependencies, install/uninstall stuff
	sudo apt -y autoclean > /dev/null 2>>"${ERRORFILE}"; # removes extra cache files
	sudo apt -y autoremove 2>>"${ERRORFILE}"; # removes deb packages but not all of them sadly
	rm -rfd ~/.cache/pip > /dev/null  2>>"${ERRORFILE}"; # removes pip packages
	rm -rfd /tmp/ 2>&1 > /dev/null; # removes temp files made only by the user, keeps system etc. files
	## Todo: This is safe to execute - I know that from results - but do i keep this
	# sudo rm -f /var/cache/apt/archives/*.deb   # removes deb files apt cache
fi
echo ""
echo " ------------------------------------------ "
echo "                Completed"
echo " ------------------------------------------ "
echo ""
echo "It is recommended to restart your computer now."
read -p "Enter y/Y to restart, or anything else to exit.    " shut
if test "$shut" = "y"; then
	log $INFO "Finish_With_Reboot"
	sudo shutdown -r 0
elif test "$shut" = "Y"; then
	log $INFO "Finish_With_Reboot"
	sudo shutdown -r 0
else
	log $INFO "Finish_No_Reboot"
	echo " ------------------------------------------ "
	echo "           Finished setting up."
	echo " ------------------------------------------ "
	echo "           Not Restarting."
	echo -e "Logs are stored in $startDir \n"
	echo "GL & HF!"
fi
# exit not required, but better to always have it
exit
