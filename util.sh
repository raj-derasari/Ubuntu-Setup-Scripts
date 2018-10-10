#!/bin/bash 
#logging function

## make string comparisons case insensitive
shopt -s nocasematch

caller="`basename $0`"
Fname=${caller:0:-3}

#String operations, build logfile Name
LOGGER=`pwd`/log_${Fname}.log

# DEBUG var for logging
DEBUG="${Fname}: DEBUG: "
 INFO="${Fname}: INFO: "
ERROR="${Fname}: ERROR: "

## logging function
log() {
	echo -e "[`lsb_release -ds`]\t[${USER}]\t[`date`]\t${*}" >> "${LOGGER}"
}

disp() {
	echo -e "----------------------------------------------------\n\t\t${*}\n----------------------------------------------------"
}

pprint(){
    echo ${*}
}

#####################################################################
# Command line arguments parsing

! getopt --test > /dev/null 
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo "I’m sorry, `getopt --test` failed in this environment."
    echo -e "Please run \n sudo apt-get install util-linux"
    exit 127
fi

OPTIONS=hxdcaf:v:p:b:m:
LONGOPTS=help,print-commands-only,dry-run,clear-logs,automated,file:,virtualenv:,python-version:,build-for:,mode:

# -use ! and PIPESTATUS to get exit code with errexit set
# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly

! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"
#####################################################################
DRY_MODE=0
# if any cmdline arg is -d . run in drymode
for var in "$@"
do
    if [ "$var" = "-d" ]; then
        DRY_MODE=1
        if [[ -z $dry_echo ]]; then
            dry_echo="echo \$ "
        fi
    fi
    if [ "$var" = "-x" ]; then
        disp() {
            echo "a" > /dev/null
        }
        pprint(){
            echo 'a' > /dev/null
        }
        dry_echo="echo "
    fi
done
######################################################################
addaptrepo="$dry_echo sudo add-apt-repository -y "
# Maybe add sudo apt-key update depending on lsb_release
apt_update="$dry_echo sudo apt-get update "
apt_prefix="$dry_echo sudo apt-get install -y "
apt_prefix_rec="$dry_echo sudo apt-get install -y --install-recommends "