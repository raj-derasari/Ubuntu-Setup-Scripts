# My-Ubuntu-Setup-Scripts

Author: Raj Derasari

Description:
Some Ubuntu setup scripts that I wrote, to do some of my (and general) tasks after a fresh Ubuntu installation

The scripts are modular, you can run any of these based on your requirements. If you are not running from master.sh and are running any script by itself, please read the script first; you may want to edit something in it.

Scripts are written in Bash, but I hope to fork a Dash build someday.

Some tasks (mentioned as TODO) in the scripts are not yet completed.

Scripts with various configurations have been tested in VMs and found to be working fine.


Supported Stuff:
Python2/3 with virtualenv
Oracle Java8/10
Tensorflow with GPU/CPU optimizations (Supports MKL but assumes you have it already installed) (Re. Nvidia GPU configuration, )
Docker with/without sudo access

Usage:
bash (selected-script).sh (arguments)
Requires: the "-f" argument with a configuration file (See ./configs/\*.sh)
You can pass the --help argument to display a help message for the given scripts.

Scripts and Descriptions:

final-setup.sh - You can directly download this script, which in turn installs git and downloads this Repository to your PC
The next 3 commands will get the repository onto your PC:
	wget -qo- https://raw.githubusercontent.com/raj-derasari/My-Ubuntu-Setup-Scripts/master/final-setup.sh
	chmod 777 final-setup.sh
	./final-setup.sh

./configs/config_{}.sh - Configuration files for selecting software, which you should modify before you run master.sh

docker.sh - Docker install/reinstall script

master.sh - The parent script, which contains aliases, etc. and calls the below mentioned scripts:

./BR/BR_{DE}.sh - Bloatremove script, depending on your detected desktop environment, can uninstall loads of bloatware 
** The bloatremove (BR) script for KDE/XFCE/Pantheon has not been built or tested. **

libsdeps.sh - Installs common dependencies that you will probably use in your Ubuntu installation at some point

software.sh - Installs common software, web browsers, etc. (Uses configuration file)

python.sh - Installs common Python libraries and aliases (Uses configuration file)

tensorflow.sh - Compiles and Installs Tensorflow (Uses configuration file - Different from others - tensorflow_config.sh)