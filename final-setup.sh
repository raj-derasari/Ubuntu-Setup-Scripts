#!/bin/bash
rm -rf ~/SetupScript
sudo apt-get update
sudo apt-get install -y git
sudo apt-get install -fy
mkdir -p ~/SetupScript
cd ~/SetupScript
git clone https://github.com/raj-derasari/My-Ubuntu-Setup-Scripts
cd My-Ubuntu-Setup-Scripts
echo "About to bash master.sh now"
chmod 777 master.sh
reset; bash master.sh -C -D -f configs/config_full.sh > ~/Desktop/send_rd.txt
read -p "Looking fine? Exec without dry-run? (Enter for yes, warna anything else) - " prom
if test "$prom" = ""; then
	reset; 
	bash master.sh -C -f configs/config_full.sh 2>>"log_errors_new.log"
else
	exit 127
fi
