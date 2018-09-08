#!/bin/bash
#set -o errexit # -o pipefail -o noclobber #-o nounset
## get util functions loaded
. util.sh

# use the display function to print this
disp "Ubuntu Master Script"

#logging/utils/help
INFO="Master: INFO: "
ERROR="Master: ERROR: "

##begin
export startDir=`pwd`
export ERRORFILE=`pwd`/log_errors.log

## Command line options parsing
### TODOS
## check out apt-get install byobu"

DRY_RUN=0
DEBUG=0
echo "Parsing command line parameters:"
while true; do
    case "$1" in
    	-h|--help)
			echo "master script made by Raj D."
			echo "Usage: "
			echo " -f <configuration script> : Uses specified script in setup, defaults to config_recommended.sh"
			echo " -D : Dry-run the script, doesn't have any user prompt, displays commands that will be executed."
			echo " There are other parameters which I will detail laters"
			shift
			exit 0
			;;
        -C|--clear-logs)
			echo "Clearing log files."
			rm *.log 2>&1 > /dev/null && log $INFO "cleared all logs. Time// `date`"
			if [ $? -eq 0 ]; then 
				echo "Logs have been cleared"
			else
				echo "Logs could not be cleared. Some files may not have been deleted."
			fi
			shift
			;;
		-f|--file)
			CustomConfig=1
			CONFIG_FILE="$2"
			echo "Loading configuration from input file."
			log $INFO "exec custom config file"
			shift 2
			;;
		-v|--verbose)
			VERBOSE=1
			echo "Verbose Mode - All execution will be displayed in the console"
			log $INFO "verbose mode"
			shift
			;;
		-d|--debug)
			DEBUG_MODE=1;
			echo "Debug Mode - "
			log $INFO $DEBUG "Running in debug mode"
			shift
			;;
		-D|--dry-run)
			DRY_RUN=1
			dry_echo="echo "
			DRYFLAG=" -D "
			echo "Dry-Run: No commands will be executed"
			log $INFO $DEBUG "Running in debug mode"
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

if [ $DRY_RUN -eq 1 ]; then
	dry_echo="echo "
	DRYFLAG=" -D "
else
	dry_echo=""
	DRYFLAG=""
fi


if [ -z $CustomConfig ]; then
	echo "Executing with the default Configuration-File: config_recommended.sh"
	CONFIG_FILE=./configs/config_recommended.sh
fi

. "${CONFIG_FILE}" && echo "Loading Configuration!"
if [ $? -ne 0 ]; then
	echo "Errors in completing configuration! Exit?"
	read -p  "Continue at your own risk! (Enter y/Y to exit) - " ex
	if test "$ex" = "y" -o "$ex" = "Y"; then
		exit 5
	else
		echo "Continuing setup!"
	fi
fi

## Configuration loaded, run apt-get update first things first
NewShell=0
echo "Running sudo apt-get update"
log $INFO "first run of apt-get update in masterscript" && $dry_echo sudo apt-get update

## ALIAS SETUP
checkBash="`grep \"alias brc=\" ${BF}`"
if [[ ! -z $checkBash ]]; then
	log $INFO "common-aliases - Seems like aliases are already setup. Not modifying ${BF}"
	NewShell=$((NewShell+1))
else
	## redirecting output to your bashrc file
	## the first line permanently sets the BF variable as your bash profile
	cat <<EOT >> ${BF}
export BF=${BF}
# Execute bash instead of sh
alias sh=bash
# You can later replace nano with a text editor of your choice - gedit, subl, vim, emacs, ...
alias brc="sudo nano \${BF}"
# Loads the bashrc profile
alias sbrc="source \${BF}"
alias sau="sudo apt-get update"
alias sai="sudo apt-get install"
alias saiy="sudo apt-get -y install"
alias aptgetupgrade="sudo apt-get upgrade"
#Aliases to replace your pip install hardwork
alias py2install="python2 -m pip install --user "
alias py3install="python3 -m pip install --user "
# If you ever get APT lock errors aptreset will do your work for ya
alias aptreset="mkdir -p ~/locks/apt/list; mkdir -p ~/locks/dpkg; sudo mv /var/lib/apt/lists/lock ~/locks/apt/list; sudo mv /var/lib/dpkg/lock ~/locks/dpkg/lock; sudo mv /var/cache/apt/archives/lock ~/locks/apt; sudo dpkg --configure -a"
_sai_complete() { 
	mapfile -t COMPREPLY < <(apt-cache --no-generate pkgnames "$2");
}
complete -F _sai_complete sai
complete -F _sai_complete saiy
EOT
fi

## virtualenv aliases
if [ $Setup_VirtualEnv -eq 1 ]; then 
	log $INFO "installing virtualenv for python"
	
	## aliases
	# checkBash="`grep \"virtualenvwrapper.sh\" ${BF}`"
	## this part is under investigation.
	checkBash="VIRTUALENVNOWORKMAN"
	if [[ ! -z $checkBash ]]; then
		log $INFO "virtualenvwrapper - Seems like aliases are already setup. Not modifying ${BF}"
		NewShell=$((NewShell+1))
	else
		## redirecting output to your bashrc file
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
		$dry_echo sudo apt-get install -y virtualenv python-virtualenv virtualenvwrapper
	elif [ $Python_PreferredVersion -eq 3 ]; then
		$dry_echo sudo apt-get install -y virtualenv python3-virtualenv virtualenvwrapper
	fi
else
	log $INFO "Not setting up virtualenv"
fi

## python=python3 alias if Python3 is the desired version
if [ $Python_PreferredVersion -eq 3 ] | [ $Python_PreferredVersion -eq 2 ]; then
	checkBash="`grep \"alias python=python${Python_PreferredVersion}\" ~/.bashrc`"
	if [[ ! -z $checkBash ]]; then
		echo "\"python${Python_PreferredVersion}\" is already linked to \"python\" in this Ubuntu installation"
		log $INFO "python${Python_PreferredVersion} is already linked as python for terminals"
		NewShell=$((NewShell+1))
	else
		echo "# Python aliases-------------------" >> ${BF}
		echo "alias python=python${Python_PreferredVersion}" >> ${BF}
		echo "alias pip3install=python3 -m pip install --user --upgrade " >> ${BF}
		echo "alias pip2install=python2 -m pip install --user --upgrade " >> ${BF}
		echo "Aliases for Python have been setup"
		log $INFO "Make python${Python_PreferredVersion} default python in bashrc"
	fi
fi

if [ $NewShell -eq 3 ]; then
	## All bash vars are set already
	echo ${*}
	read -p "fine?? - " var
	x-terminal-emulator -e ~/SetupScript/My-Ubuntu-Setup-Scripts/master.sh -C -f 
fi

# git and vcsh - vcsh allows you to manage multiple git repos in one directory
if [ $Install_Git -eq 1 ]; then
	disp "Git Setup"
	log $INFO "install Git"
	$dry_echo sudo apt-get install -y vcsh git
	if [ $Install_Git_SSHKeys -eq 1 ]; then
		if [ -e ${Github_SSH_File} ]; then
    		echo "you have already generated the ssh-key, displaying Pub-Key:"
		else
			ssh-keygen -t rsa -b 4096 -C "${Git_Email}" -f "${Github_SSH_File}"
			eval "$(ssh-agent -s)"
			ssh-add ${Github_SSH_File}
		fi
		echo "Visit https://github.com/settings/keys and add this key in your SSH keys: " >| ~/Desktop/Git_PublicKey.txt
		cat ${Github_SSH_File}.pub >>~/Desktop/Git_PublicKey.txt && echo "You can copypasta your Github key, refer Desktop/Git_PublicKey.txt"
		git config --global user.name "${Git_YourName}"
		git config --global user.email "${Git_Email}"
		git config --global alias.add-commit '!git add -A && git commit -m '
		git config --global alias.ls 'log --pretty=format:"%C(green)%h\\ %C(yellow)[%ad]%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=relative'
    	git config --global alias.ll 'log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --numstat'
    	git config --global alias.lnc 'log --pretty=format:"%h\\ %s\\ [%cn]"'
		echo -e "Git aliases set up.\nYou can use this to directly commit a directory:\n\tgit add-commit '<Commit-Message>'\n"
		echo -e "You can use this to see lists of commits:\n\tgit ls\n\tgit ll\n\tgit lnc"
	fi
fi

## libsdeps
if [ $Master_Dependencies -eq 1 ]; then
	#sudo apt-key update && 
	disp "Master - Executing Dependencies Install"
	log $INFO "Setting up lib* and dependencies"
	bash libsdeps.sh $DRYFLAG 2>>"${ERRORFILE}"
else
	log $INFO "NOT setting up lib* and dependencies"
fi

## bloatremove
if [ $Master_RemoveBloatware -eq 1 ]; then
	disp "Master - Executing Bloatware Removal"
	echo "Detected Desktop Environment: " $XDG_CURRENT_DESKTOP
	echo "------------------------------------------"
	log $INFO "Bloatremove: Detected Desktop:" ${XDG_CURRENT_DESKTOP}
	case $XDG_CURRENT_DESKTOP in
		Unity|LXDE|GNOME) #|XFCE|KDE|Pantheon)  # have to work on the rest
		echo "Running bloatremove for ${XDG_CURRENT_DESKTOP}"
		bash ./BR/BR,SWC_${XDG_CURRENT_DESKTOP}.sh $DRYFLAG 2>>"${ERRORFILE}";
	;;
	esac
else
	log $INFO "NOT setting up bloatware removal"
fi

export PATH=$PATH:~/.local/bin
source ${BF} && log $INFO "Updated .bashrc profile and loaded in bash"
 

## softwares
if [ $Master_Software -eq 1 ]; then
	#sudo apt-key update && 
	echo "Running sudo apt-get update" && log $INFO "APT-GET-UPDATE - before Software Script" &&  $dry_echo  sudo apt-get update
	disp "Master - Executing Software Installation"
	log $INFO "Setting up software"
	bash software.sh $DRYFLAG 2>>"${ERRORFILE}"
else
	log $INFO "NOT setting up software"
fi

## python
if [ $Master_Python -eq 1 ]; then
	#sudo apt-key update && 
	echo "Running sudo apt-get update" && log $INFO "APT-GET-UPDATE - before Python Script" &&  $dry_echo  sudo apt-get update
	disp "Master - Setting up Python"
	log $INFO "Setting up python"
	bash python.sh $DRYFLAG -p $Python_PreferredVersion -v $VirtualEnv_Name 
else
	log $INFO "NOT setting up python"
fi

#  ------------------------------------------
##                    APT-GET-UPGRADE
if [ $Do_AptGetUpgradeLast -eq 1 ]; then
	log $INFO "apt-get upgrade before exit"
	#sudo apt-key update && 
	$dry_echo sudo apt-get update # > /dev/null
	$dry_echo sudo apt-get upgrade -y # 2>>"${ERRORFILE}"; # fix dependencies
	$dry_echo sudo apt -y autoremove # 2>>"${ERRORFILE}"; # removes packages
fi
#  ------------------------------------------
##                    CLEANUP
if [ $Do_CleanupAfterExec -eq 1 ]; then
	log $INFO "Cleaning up ~/.cache/pip, tmp, deb files"
	disp "Cleaning up ~/.cache/pip, /tmp, .deb files"
	$dry_echo sudo apt-get install -fy # 2>>"${ERRORFILE}"; # fix dependencies, install/uninstall stuff
	$dry_echo sudo apt -y autoclean #> /dev/null 2>>"${ERRORFILE}"; # removes extra cache files
	$dry_echo sudo apt -y autoremove #2>>"${ERRORFILE}"; # removes deb packages but not all of them sadly
	$dry_echo rm -rfd ~/.cache/pip   # removes pip packages
	$dry_echo rm -rfd /tmp/ > /dev/null  2>&1  # removes temp files made only by the user, keeps system etc. files
	## Todo: This is safe to execute - I know that from results - but do i keep this
	# sudo rm -f /var/cache/apt/archives/*.deb   # removes deb files apt cache
fi

disp "Completed"
echo "It is highly recommended to restart your computer now."
$dry_echo read -p "Press Enter, or y/Y to restart right now, or anything else to exit. - " shut
if test "$shut" = "y" -o "$shut" = "Y" -o "$shut" = ""; then
	log $INFO "Finish_With_Reboot" && echo "REBOOTING"
	$dry_echo sudo shutdown -r 0
else
	log $INFO "Finish_No_Reboot"
	echo "Not restarting your computer."
	echo "Logs are stored in ${startDir}"
fi
exit 0
