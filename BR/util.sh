#!/bin/bash 
source `which virtualenvwrapper.sh`
#logging function
caller=`basename "$0"`
#String operations, build logfile Name
LOGGER=`pwd`/log_${caller:0:-3}.log
DEBUG="DEBUG: "
log() {
	echo -e "[`lsb_release -ds`]\t[${USER}]\t[`date`]\t${*}" >> "${LOGGER}"
}

disp() {
	echo -e "----------------------------------------------------\n\t\t${*}\n----------------------------------------------------"
}


##################### REst of it is command line parsing
! getopt --test > /dev/null 
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo "I’m sorry, `getopt --test` failed in this environment."
    echo -e "Please run \n sudo apt-get install util-linux"
    exit 127
fi

OPTIONS=hCf:v:dDp:
#hDdv:p
LONGOPTS=clear-logs,file,verbose,debug
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
