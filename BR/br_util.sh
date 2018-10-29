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
}
pprint(){
	echo ${*}
}

#####################################################################
# Command line arguments parsing block - only modify the opts and longopts
OPTIONS=hxdltcaf:
LONGOPTS=help,print-commands-only,dry-run,remove-language-packs,remove-themes,clear-logs,automated,file
#####################################################################
# Command line arguments parsing
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
	# e.g. return 1 <- getopt has complained about wrong arguments to stdout
	exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"
#####################################################################
DRY_MODE=0
additional_remove="echo "
# if any cmdline arg is -d . run in drymode
for var in "$@"
do
	if [ "$var" = "-d" ] || [ "$var" = "--dry-run" ]; then
		DRY_MODE=1
		if [[ -z $dry_echo ]]; then
			dry_echo="echo \$ "
		fi
	fi
	if [ "$var" = "-x" ] || [ "$var" = "--print-commands-only" ]; then
		DRY_MODE=1
		dry_echo="echo "
		disp() { :; }
		pprint(){ :; }
	fi
	if [ "$var" = "-t " ] || [ "$var" = "--remove-themes" ] || [ "$var" = "-l " ] || [ "$var" = "--remove-language-packs" ]; then
		additional_remove="$dry_echo apt_purge"
	fi
done

######################################################################
# add sudo apt-key update to apt-get update, depending on lsb_release
release_version=`lsb_release -rs`
int=${release_version%.*}
if [[ $int -lt 18 ]]; then
	apt_update(){ $dry_echo sudo apt-get update; sudo apt-key update; }
else
	apt_update(){ $dry_echo sudo apt-get update; }
fi
## additional declared functions
add_apt_repository(){ $dry_echo sudo add-apt-repository -y $1; }
apt_install(){ $dry_echo sudo apt-get install -y ${*}; }
apt_install_recommends(){ $dry_echo sudo apt-get install -y --install-recommends ${*}; }
apt_purge(){ $dry_echo sudo apt-get purge -y ${*}; }
apt_purge_autoremove(){ $dry_echo sudo apt-get purge --auto-remove -y ${*}; }

apt_key_dl() { $wget_echo curl -fsSL ${*} " " | ( [ $DRY_MODE -eq 1 ] && cat | tr -d '\n');
	$aptkey_echo sudo apt-key add -; }
apt_src_add() { $wget_echo echo deb [arch=amd64] $1 | ( [ $DRY_MODE -eq 1 ] && cat | tr -d '\n');
	$aptkey_echo sudo tee /etc/apt/sources.list.d/${2}.list; }

## help echo command
_help_(){
	echo "
Ubuntu Bloatremove/Configuration-Fixing script
Recommended software after this script completes:
	Sublime Text 3/emacs for editing text files
	VLC Media Player for media files
	Gparted for disk management
	QPDFView (lightweight) and Okular (features) for PDF suites
	Thunderbird for email client
	UGet and Qbittorrent for download-management
	LibreOffice for an office suite";
}

languagepacks="
language-pack-de* language-pack-de-base* language-pack-gnome-de* language-pack-gnome-de-base* \
language-pack-es* language-pack-es-base* language-pack-gnome-es* language-pack-gnome-es-base* \
language-pack-it* language-pack-it-base* language-pack-gnome-it* language-pack-gnome-it-base* \
language-pack-pt* language-pack-pt-base* language-pack-gnome-pt* language-pack-gnome-pt-base* \
language-pack-gnome-ru* language-pack-gnome-ru-base* language-pack-ru* language-pack-ru-base* \
language-pack-zh-hans* language-pack-zh-hans-base* language-pack-gnome-zh-hans* language-pack-gnome-zh-hans-base* "
