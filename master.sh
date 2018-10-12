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
	CONFIG_FILE=./configs/config_recommended.sh
fi
pprint "Executing with the default Configuration-File: ${CONFIG_FILE}"
. "${CONFIG_FILE}"
if [ $? -ne 0 ]; then
	pprint "Errors in completing configuration! Cannot continue!"
	exit 5
fi

##begin
export startDir=`pwd`
export ERRORFILE=`pwd`/log_errors.log
## Configuration loaded, run apt-get update first things first
pprint "Running sudo apt-get update"

$apt_update && log $INFO "first run of apt-get update in masterscript"
## ALIAS SETUP
checkBash="`grep \"alias brc=\" ${BF}`"
if [[ ! -z $checkBash ]]; then
	log $INFO "common-aliases - Seems like aliases are already setup. Not modifying ${BF}"
else
	log $INFO "common-aliases - UPDATING ${BF}"
	## redirecting output to your bashrc file
	## the first line permanently sets the BF variable as your bash profile
	cat <<EOT >> ${BF}
# Stores the bashrc file in BF
export BF=${BF}
# -------------------------------------
# You can later replace nano with a text editor of your choice - gedit, subl, vim, emacs, ...
#alias brc="sudo nano \${BF}"
alias brc="subl \${BF}"
alias sbrc="source \${BF}"
# -------------------------------------
# Makes bash the default instead of sh
alias sh=bash
# -------------------------------------
# Python 3 instead of Python 2
alias python=python3
# -------------------------------------
# apt aliases
alias sau="sudo apt-get update"
alias sai="sudo apt-get install"
alias aptgetupgrade="sudo apt-get upgrade"
alias sarm="sudo apt-get remove "
alias sap="sudo apt-get purge"
# If you ever get APT lock errors aptreset will do your work for ya
alias aptreset="sudo rm -rf ~/locks; mkdir -p ~/locks/apt/list ~/locks/dpkg; sudo mv /var/lib/apt/lists/lock ~/locks/apt/list; sudo mv /var/lib/dpkg/lock ~/locks/dpkg/lock; sudo mv /var/cache/apt/archives/lock ~/locks/apt; sudo dpkg --configure -a"
# -------------------------------------
# Aliases to replace your pip installs easier
alias py2install="python2 -m pip install --user "
alias py3install="python3 -m pip install --user "
# -------------------------------------
# function for apt completion, currently doesn't work
_sai_complete() {
	mapfile -t COMPREPLY < <(apt-cache --no-generate pkgnames "");
}
complete -F _sai_complete sai
complete -F _sai_complete saiy
# -------------------------------------
# other shell aliases
# to find the PID of any process
alias psfind = "ps aux | grep"
# Network utilities
alias listen="lsof -P -i -n"
alias port='netstat -tulanp'
alias ipinfo="curl ifconfig.me && curl ifconfig.me/host"
# -------------------------------------
# utility functions
# generates a random password of length \$1
genpasswd() { strings /dev/urandom | grep -o '[[:alnum:]]' | head -n \$1 | tr -d '\n'; echo; }
# sorts directory items, by size
sbs() { du -b --max-depth 1 \$1 | sort -nr | perl -pe 's{([0-9]+)}{sprintf "%.1f%s", \$1>=2**30? (\$1/2**30, "G"): \$1>=2**20? (\$1/2**20, "M"): \$1>=2**10? (\$1/2**10, "K"): (\$1, "")}e';}
# list of directorys under arg1, sorted by size
dir_size_list() { du -h --max-depth=1 \$1 | sort -hr; }
# make directory and switch to it
mcd() { mkdir -p "\$1"; cd "\$1";}
# quickly backup a file
bak() { cp "\$1"{,.bak};}
## extracts any archive
extract() {
	if [ -f '\$1' ]; then
		case \$1 in
		*.tar.bz2)	tar xjf \$1 ;;
		*.tar.gz)	tar xzf \$1 ;;
		*.bz2)		bunzip2 \$1 ;;
		*.rar)		unrar e \$1 ;;
		*.gz)		gunzip \$1 ;;
		*.tar)		tar xf \$1 ;;
		*.tbz2)		tar xjf \$1 ;;
		*.tgz)		tar xzf \$1 ;;
		*.zip)		unzip \$1  ;;
		*.Z)		uncompress \$1  ;;
		*.7z)		7z x \$1  ;;
		*)	 echo "'\$1' cannot be extracted via extract()" ;;
		esac
	else
		echo "'\$1' is not a valid file"
	fi

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
LOCKDIR=~/locks
alias aptreset="mkdir -p ${LOCKDIR}/apt/list ${LOCKDIR}/dpkg; sudo mv /var/lib/apt/lists/lock ${LOCKDIR}/apt/list; sudo mv /var/lib/dpkg/lock ${LOCKDIR}/dpkg/lock; sudo mv /var/cache/apt/archives/lock ${LOCKDIR}/apt; sudo dpkg --configure -a"
# for some reason, this breaks beyond Ubuntu 16, 18 but worked perfecto on my Lubuntu 16 - No idea how I'll fix this
_sai_complete() {
	mapfile -t COMPREPLY < <(apt-cache --no-generate pkgnames "$2")
}
complete -F _sai_complete sai
complete -F _sai_complete saiy
EOT
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
		$apt_prefix virtualenv python-virtualenv virtualenvwrapper
	elif [ $Python_PreferredVersion -eq 3 ]; then
		$apt_prefix virtualenv python3-virtualenv virtualenvwrapper
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
alias pip3install=python3 -m pip install --user --upgrade
alias pip2install=python2 -m pip install --user --upgrade" >> ${BF}
	
	pprint "Aliases for Python have been setup"
	log $INFO "Make python${Python_PreferredVersion} default python in bashrc"
	fi
fi

# git and vcsh - vcsh allows you to manage multiple git repos in one directory
if [ $Install_Git -eq 1 ]; then
	disp "Git Setup"
	log $INFO "install Git VCSH"
	$apt_prefix vcsh git
	if [ $Install_Git_SSHKeys -eq 1 ]; then
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
	
	#$dry_echo git config --global user.name "${Git_YourName}"
	#$dry_echo git config --global user.email "${Git_Email}"
	$dry_echo git config --global alias.add-commit '!git add -A && git commit -m '
	$dry_echo git config --global alias.ls 'log --pretty=format:"%C(green)%h\\ %C(yellow)[%ad]%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=relative'
	$dry_echo git config --global alias.ll 'log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --numstat'
	$dry_echo git config --global alias.lnc 'log --pretty=format:"%h\\ %s\\ [%cn]"'
	pprint -e "Git aliases set up.\nYou can use this to directly commit a directory:\n\tgit add-commit '<Commit-Message>'\n"
	pprint -e "You can use this to see lists of commits:\n\tgit ls\n\tgit ll\n\tgit lnc"
fi

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
	$apt_prefix -f 2>>"${ERRORFILE}"
	
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