#!/bin/bash
set -o errexit # -o pipefail -o noclobber #-o nounset
. util.sh ${*}

## help message
_help_="Ubuntu Setup Scripts - Master script made by Raj Derasari
Available at:  https://www.github.com/raj-derasari/My-Ubuntu-Setup-Scripts/
All command line options in this project are lower-case and case sensitive, be careful when using these.
Usage:
	-f (filepath) or --file (filepath)   | Uses specified script in setup, default ./configs/config_recommended.sh
	-d            or --dry-run           | Dry-run the script, doesn't have any user prompt, displays commands that will be executed.
	-c            or --clear-logs        | Clears the folder of *.log files before execution"

## Command line options parsing
while true; do
case "$1" in
	-h|--help)
		echo -e "\n$_help_\n"
		shift
		exit 0
	;;
	-x|--print-commands-only)
		DRYFLAG=`echo "$DRYFLAG -x"`
		shift
	;;
	-c|--clear-logs)
		pprint "Clearing log files."
		rm *.log 2>&1 > /dev/null && log $INFO "cleared all logs. Time// `date`"
		if [ $? -eq 0 ]; then
			pprint "Logs have been cleared"
		else
			pprint "Logs could not be cleared. Some files may not have been deleted."
		fi
		shift
	;;
	-d|--dry-run)
		DRYFLAG=`echo "$DRYFLAG -d"`
		shift
	;;
	-f|--file)
		CONFIG_FILE="$2"
		log $INFO "exec custom config file" $CONFIG_FILE
		shift 2
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
# use the display function to print this
disp "Ubuntu Master Script"
if [[ -z $CONFIG_FILE ]]; then
	# config file used is the default/recommended one
	CONFIG_FILE=./configs/config_recommended.sh
	read -p "Using the recommended configuration file (./configs/config_recommended.sh) 
Press (Enter) to continue, and the (Ctrl+C) combination to exit
" DMMYDMMY
	pprint "Executing with the default Configuration-File: ${CONFIG_FILE}"
elif [ ! -e $CONFIG_FILE ]; then
	## CFG file does not exist
	echo "Error - Configuration file does not exist!
	Please pass a valid Configuration File with the \"-f\" argument."
	exit 3
else
	# config file exists and can be loaded - probably is a good file, I should add some validation for that
	. "${CONFIG_FILE}"
	if [ $? -ne 0 ]; then
		pprint "Errors in completing configuration! Cannot continue!"
		exit 5
	fi
fi

##begin
export startDir=`pwd`
export ERRORFILE=`pwd`/log_errors.log
## Configuration loaded, run apt-get update first things first
pprint "Running sudo apt-get update"

apt_update && log $INFO "first run of apt-get update in masterscript"

## ALIAS SETUP
checkBash="`grep \"alias brc=\" ${BF}`"
if [[ ! -z $checkBash ]]; then
	log $INFO "common-aliases - Seems like aliases are already setup. Not modifying ${BF}"
	pprint "Common aliases and commands are already setup for you, not modifying profile"
else
	log $INFO "common-aliases - UPDATING ${BF}"
	pprint "Setting up aliases and commands in your profile!"
	## redirecting output to your bashrc file
	## the first line permanently sets the BF variable as your bash profile
	cat bash_aliases.txt >> ${BF}
	## alternative:
	# mv bash_aliases.txt ~/.bash_aliases
fi

## virtualenv aliases
if [ $Setup_VirtualEnv -eq 1 ]; then
	log $INFO "installing virtualenv for python"
	## aliases for virtualenv setup
	## this part is under investigation.
	checkBash="VIRTUALENVNOWORKMAN"
	if [[ ! -z $checkBash ]]; then
		log $INFO "virtualenvwrapper - Seems like aliases are already setup. Not modifying ${BF}"
	else
		log $INFO "virtualenvwrapper - Updating ${BF}"
	## redirecting output to the bash profile
	cat <<EOT >> ${BF}
export WORKON_HOME=${VirtualEnv_Directory}
export PROJECT_HOME=$HOME/
source /usr/local/bin/virtualenvwrapper.sh
venvwrap="virtualenvwrapper.sh"
if [ \$? -eq 0 ]; then
	venvwrap=\`/usr/bin/which \$venvwrap\`
	source \$venvwrap
fi
EOT
	fi
	if [ $Python_PreferredVersion -eq 2 ]; then
		apt_install_recommends virtualenv python-virtualenv virtualenvwrapper
	elif [ $Python_PreferredVersion -eq 3 ]; then
		apt_install_recommends virtualenv python3-virtualenv virtualenvwrapper
	fi
else
	log $INFO "Not setting up virtualenv"
fi
## python=python3 alias if Python3 is the desired version
if [ $Python_PreferredVersion -eq 3 ] | [ $Python_PreferredVersion -eq 2 ]; then
	checkBash="`grep \"alias python=python${Python_PreferredVersion}\" ${BF}`"
	if [[ ! -z $checkBash ]]; then
		pprint "\"python${Python_PreferredVersion}\" is already linked to \"python\" in this Ubuntu installation"
		log $INFO "python${Python_PreferredVersion} is already linked as python for terminals"
	else
		echo "# Python aliases----------------------------------
alias python=python${Python_PreferredVersion}
alias pip3install=\"python3 -m pip install --user --upgrade\"
alias pip2install=\"python2 -m pip install --user --upgrade\"" >> ${BF}
	
	pprint "Aliases for Python have been setup"
	log $INFO "Make python${Python_PreferredVersion} default python in bashrc"
	fi
fi

################################################################################################
# git and vcsh - vcsh allows you to manage multiple git repos in one directory
if [ $Install_Git -eq 1 ]; then
	disp "Git Setup"
	log $INFO "install Git VCSH"
	apt_install vcsh git
	$dry_echo git config --global user.name "${Git_YourName}"
	$dry_echo git config --global user.email "${Git_Email}"
fi
if [ $Setup_Git_SSHKeys -eq 1 ]; then
	if [ ! -e ${Github_SSH_File} ]; then
		$dry_echo ssh-keygen -t rsa -b 4096 -C "${Git_Email}" -f "${Github_SSH_File}"
		$dry_echo eval "$(ssh-agent -s)"
		$dry_echo ssh-add ${Github_SSH_File}
	else
		pprint "you have already generated the ssh-key, displaying Pub-Key:"
		pprint "You can copypasta your Github key, refer Desktop/Git_PublicKey.txt"
		echo "Visit https://github.com/settings/keys and add this key in your SSH keys: " >| ${USER_HOME}/Desktop/Git_PublicKey.txt
		cat ${Github_SSH_File}.pub >> ${USER_HOME}/Desktop/Git_PublicKey.txt
	fi
fi
if [ $Setup_Git_Aliases -eq 1 ]; then
	$dry_echo git config --global alias.add-commit '!git add -A && git commit -m '
	$dry_echo git config --global alias.ls 'log --pretty=format:"%C(green)%h\\ %C(yellow)[%ad]%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=relative'
	$dry_echo git config --global alias.ll 'log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --numstat'
	$dry_echo git config --global alias.lnc 'log --pretty=format:"%h\\ %s\\ [%cn]"'
	pprint "Git aliases set up.\nYou can use this to directly commit a directory:\n\tgit add-commit '<Commit-Message>'\n"
	pprint "You can use this to see lists of commits:\n\tgit ls\n\tgit ll\n\tgit lnc"
fi
################################################################################################

## libsdeps
if [ $Master_Dependencies -eq 1 ]; then
	disp "Master - Executing Dependencies Install"
	log $INFO "Setting up lib* and dependencies"
	bash dependencies.sh $DRYFLAG 2>>"${ERRORFILE}"
else
	log $INFO "NOT setting up lib* and dependencies"
fi

## bloatremove
if [ $Master_RemoveBloatware -eq 1 ]; then
	disp "Master - Executing Bloatware Removal"
	pprint "Detected Desktop Environment: " ${XDG_CURRENT_DESKTOP}
	pprint "------------------------------------------"
	log $INFO "Bloatremove: Detected Desktop:" ${XDG_CURRENT_DESKTOP}
	# Dont modify the logic in the next part!
	case $XDG_CURRENT_DESKTOP in
		Unity|LXDE|GNOME) #|XFCE|KDE|Pantheon) # have to work on the rest
			pprint "Running bloatremove for ${XDG_CURRENT_DESKTOP}"
			cd ./BR/
			BR_FLAGS=""
			if [ $Bloatware_Remove_Themes -eq 1 ]; then
				BR_FLAGS="`echo $BR_FLAGS` --remove-themes"
			fi
			if [ $Bloatware_Remove_LanguagePacks -eq 1 ]; then
				BR_FLAGS="`echo $BR_FLAGS` --remove-language-packs "
			fi
			bash BR,SWC_${XDG_CURRENT_DESKTOP}.sh $DRYFLAG $BR_FLAGS 2>>"${ERRORFILE}"
			cd ..
		;;
	esac
else
	log $INFO "NOT setting up bloatware removal"
fi
export PATH=$PATH:~/.local/bin
source ${BF} && log $INFO "Updated .bashrc profile and loaded in bash"

## softwares
if [ $Master_Software -eq 1 ]; then
	disp "Master - Executing Software Installation"
	log $INFO "Setting up software"
	bash software.sh -f $CONFIG_FILE $DRYFLAG 2>>"${ERRORFILE}"
else
	log $INFO "NOT setting up software"
fi
## python
if [ $Master_Python -eq 1 ]; then
	disp "Master - Setting up Python"
	log $INFO "Setting up python"
	bash python.sh $DRYFLAG -p $Python_PreferredVersion -v $VirtualEnv_Name
else
	log $INFO "NOT setting up python"
fi
## APT-GET-UPGRADE
if [ $Do_AptGetUpgradeLast -eq 1 ]; then
	log $INFO "apt-get upgrade before exit"
	$dry_echo sudo apt upgrade -y
	$dry_echo sudo apt -y autoremove
fi
# ------------------------------------------
## CLEANUP
if [ $Do_CleanupAfterExec -eq 1 ]; then
	log $INFO "Cleaning up ${USER_HOME}/.cache/pip, tmp, deb files"
	disp "CLEANING UP!"

	# removes deb packages but not all of them sadly
	$dry_echo sudo apt -y autoremove 2>>"${ERRORFILE}"

	# fix dependencies, install/uninstall stuff
	apt_install -f 2>>"${ERRORFILE}"
	
	# removes pip packages
	pprint "Cleaning up pip cache"
	$dry_echo rm -rfd ${USER_HOME}/.cache/pip 2>>"${ERRORFILE}"
	
	# removes pip packages
	$dry_echo rm -rfd ~/.cache/pip 2>>"${ERRORFILE}"

	# removes temp files made only by the user, keeps system etc. files	
	pprint "Cleaning up /tmp/ files which I can access"
	$dry_echo yes n | $dry_echo rm -rd /tmp &>/dev/null

	# Cleans the apt-get update list, only the cache nothing else
	pprint "Cleaning up oracle-jdk cached installers (300MB size)"
	$dry_echo sudo rm -rfd /var/cache/oracle-jdk*-installer/jdk*.tar.gz 2>>"${ERRORFILE}"
	
	# Cleans apt-get update list cache
	pprint "Cleaning up apt lists - you can comment out this line, or run sudo apt-get update to rebuild the lists!"
	$dry_echo sudo rm -rfd /var/lib/apt/lists/ 2>>"${ERRORFILE}"
	
	# removes extra deb/cache archives
	pprint "Cleaning up apt cache"
	$dry_echo sudo apt clean
fi
disp "Completed"
pprint "It is highly recommended to restart your computer now."
# $dry_echo read -p "Press Enter, or y/Y to restart right now, or anything else to exit. - " shut
# if test "$shut" = "y" -o "$shut" = ""; then
# 	log $INFO "Finish_With_Reboot" && pprint "REBOOTING"
# 	$dry_echo sudo reboot
# else
# 	log $INFO "Finish_No_Reboot"
# 	pprint "Not restarting your computer."
# 	pprint "Logs are stored in ${startDir}"
# fi
exit 0
