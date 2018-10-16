#!/bin/bash
if [[ "$1" = "ssh" ]]; then
	gitURL=ssh://git@github.com/raj-derasari/My-Ubuntu-Setup-Scripts.git
	echo "Clone via SSH"
else
	gitURL=https://github.com/raj-derasari/My-Ubuntu-Setup-Scripts.git
	echo "Clone via HTTPS"
fi

if [[ -z `which git` ]]; then
	echo "install git!"
	sudo apt-get update
	sudo apt-get install -y git
	sudo apt-get install -fy
else
	echo "Git already installed"
fi

mkdir -p ~/SetupScript
cd ~/SetupScript
if [ -d ./My-Ubuntu-Setup-Scripts ]; then
	# bak latest repo if already exists
	mv My-Ubuntu-Setup-Scripts/ My-Ubuntu-Setup-Scripts.bak/
fi

git clone $gitURL
cd $My-Ubuntu-Setup-Scripts
chmod 777 master.sh
echo "READY"

# reset; bash master.sh -C -D -f configs/config_full.sh > ~/Desktop/send_rd.txt
# read -p "Looking fine? Exec without dry-run? (Enter for yes, warna anything else) - " prom
# if test "$prom" = ""; then
# 	reset; 
# 	bash master.sh -C -f configs/config_full.sh 2>>"log_errors_new.log"
# else
# 	exit 127
# fi
