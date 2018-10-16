#!/bin/bash 
## make string comparisons case insensitive
shopt -s nocasematch

#String operations, to get the logfile Name
caller="`basename $0`"
Fname=${caller:0:-3}
LOGGER=`pwd`/log_${Fname}.log

# DEBUG var for logging
DEBUG="${Fname}: DEBUG: "
INFO="${Fname}: INFO: "
ERROR="${Fname}: ERROR: "

log() {
	echo -e "[`lsb_release -ds`]\t[${USER}]\t[`date`]\t${*}" >> ${LOGGER}
}
disp() {
	echo -e "----------------------------------------------------\n\t\t${*}\n----------------------------------------------------"
	#:
}
pprint(){
	echo ${*}
	#:
}

#####################################################################
# Command line arguments parsing block - only modify the opts and longopts
OPTIONS=hxdcaf:v:p:b:m:
LONGOPTS=help,print-commands-only,dry-run,clear-logs,automated,file:,virtualenv:,python-version:,build-for:,mode:
#####################################################################
! getopt --test > /dev/null 
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
	echo "I’m sorry, `getopt --test` failed in this environment."
	echo -e "Please run \n sudo apt-get install util-linux"
	exit 127
fi
# -use ! and PIPESTATUS to get exit code with errexit set
# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via -- "$@" to separate them correctly
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
	# e.g. return 1 <-  getopt has complained about wrong arguments to stdout
	exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"
#####################################################################
DRY_MODE=0
for var in "$@"
do
	if [ "$var" = "-d" ] ||  [ "$var" = "--dry-run" ]; then
		DRY_MODE=1
		if [[ -z $dry_echo ]]; then
			dry_echo="echo \$ "
			wget_echo="echo -e "
			aptkey_echo="echo | "
		fi
	fi
	if [ "$var" = "-x" ] ||  [ "$var" = "--print-commands-only" ]; then
		DRY_MODE=1
		disp() {
			:
		}
		pprint(){
			:
		}
		dry_echo="echo "
		wget_echo="echo -e "
		aptkey_echo="echo | "
	fi
done
######################################################################
# add sudo apt-key update to apt-get update, depending on lsb_release
release_version=`lsb_release -rs`
int=${release_version%.*}
if [[ $int -lt 18 ]]; then
	apt_update(){ $dry_echo sudo apt-get update; sudo apt-key update }
else
	apt_update(){ $dry_echo sudo apt-get update; }
fi
## additional declared functions
add_apt_repository(){ $dry_echo sudo add-apt-repository -y $1; }
apt_install(){ $dry_echo sudo apt-get install -y ${*}; }
apt_install_recommends(){ $dry_echo sudo apt-get install -y --install-recommends ${*}; }
apt_purge(){ $dry_echo sudo apt-get purge -y ${*}; }
apt_purge_autoremove(){ $dry_echo sudo apt-get purge --auto-remove -y ${*}; }
