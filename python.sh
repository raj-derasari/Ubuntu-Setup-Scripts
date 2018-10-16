#!/bin/bash
## get util functions loaded
. util.sh ${*}

# use the display function to print this
disp "Ubuntu Python Script"

if [ -z $Setup_Python_Dev ]; then
	log $INFO "Called from terminal"
	pprint "Looks like this script was run from the terminal (as a master variable is unset)."
	pprint "Parameters are now loaded from config file"
	## your bashrc profile/main profile file.
	USER_HOME=~
	# If you are working with LIVE ISO customization like me
	#USER_HOME=/etc/skel
	BF=${USER_HOME}/.bashrc 
	
	# Enter the path to your virtualenv parent directory, eg. if you venv is "myVE" and path is
	# ${HOME}/.virtualenvs/myVE/
	# then enter ${HOME}/.virtualenvs WITHOUT QUOTES - THIS IS IMPORTANT!
	# The default value is set below as ${USER_HOME}/.virtualenvs
	VirtualEnv_Directory=${USER_HOME}/.virtualenvs
	
	## Python installation params
	Python_InstallBasics=0
	Python_InstallWebDevelopmentTools=0
	Python_InstallDjango=0
	Python_InstallJupyter=0
	Python_InstallMachineLearningTools=0
	Python_InstallNLTK=0
	Python_Compile_Tensorflow=1
	# allowed values: gpu, cpu, mkl
	Python_Tensorflow_Target="gpu"
fi

## Prints Help Message for command line (Tensorflow/Python)
_help_() {
echo "
Usage: bash python_util.sh <arguments>
-h  or  --help               |  Print this message
-x  or  --print-commands-only| 	Disables all output messages from the script, but prints errors and commands (DOES NOT EXECUTE ANY COMMANDS)
-d  or  --dry-run            |  Dry-run
-v  or  --virtual-env        |  Virtual Environment to use. [If no argument is passed, system-wide installation]
-p  or  --preferred-version  |  Python Version [accepted values: 2, 3]
"; exit 122
}

pprint "Parsing command line parameters."
while true; do
	case "$1" in
		-h|--help) _help_
			shift
			;;
		-x|--print-commands-only)
			DRYFLAG=`echo "$DRYFLAG -x"`
			shift
			;;
		-d|--dry-run)
			pprint "Dry-running installation of Python!"
			DRYFLAG=`echo "$DRYFLAG -d"`
			shift
			;;
		-v|--virtualenv)
			VE="$2"
			shift 2
			;;
		-p|--python-version)
			PV="$2"
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
## PV sanity check
if [[ -z $PV ]]; then
	pprint "Python Version argument not passed!"
	_help_
	exit 127
elif [ ! $PV -eq 2 ] && [ ! $PV -eq 3 ]; then
	if [[ ! -z $Python_PreferredVersion ]]; then
		pprint "Master Script has set Python_Version as Python"$Python_PreferredVersion
		pprint "Using master-script python version!"
		PV=$Python_PreferredVersion
	else
		log $INFO "FATAL: python version unknown. entered value: "$1
		pprint "Python version entered is not 2 or 3!"
		_help_
		exit 127
	fi
fi

## VE sanity check
# Called from terminal and Venv wasnt used, OR called from master and venv wasnt used
if [[ -z $Setup_VirtualEnv ]]; then
	## called from terminal, Venv wasnt used
	log "DEBUG: line 96 Py"
	Setup_VirtualEnv=0
	pip_install() { $dry_echo sudo -H python${PV} -m pip install --user --upgrade ${*}; } # this is used if NOT using virtualenv
	pprint "Not installing to any virtualenv!"
elif [ $Setup_VirtualEnv -eq 0 ]; then
	log "DEBUG: line 119 Py"
	Setup_VirtualEnv=0
	pip_install() { $dry_echo sudo -H python${PV} -m pip install --user --upgrade ${*}; } # this is used if NOT using virtualenv
	pprint "Not installing to any virtualenv!"
# called from either source, but venv was used - hence name is definitely known
elif [ $Setup_VirtualEnv -eq 1 ]; then
	Setup_VirtualEnv=1
	pip_install() { $dry_echo python${PV} -m pip install --user --upgrade ${*}; } # this is used if NOT using virtualenv
	if [[ -z $VE ]]; then
		VE=$VirtualEnv_Name
	fi
	if [[ -z $VirtualEnv_Directory ]]; then
		echo "If you are seeing this, something is seriously wrong with my coding skills"
		VirtualEnv_Directory=~/.virtualenvs/$VE
	fi
	## virtualenv: virtualenv --system-site-packages -p python ${HOME}/.virtualenvs/$VirtualEnv_Name
	## wrapper: mkvirtualenv $VirtualEnv_Name
	## virtualenv: source /$VENV_PATH$/$ENV$/bin/activate
	## wrapper: workon $VirtualEnv_Name
	if [ ! -e  $VirtualEnv_Directory/bin/activate ]; then
		log $INFO "Creating virtualenv $VirtualEnv_Name"
		pprint "Creating virtualenv $VE!"
		$dry_echo virtualenv --system-site-packages -p python$PV $VirtualEnv_Directory
	fi
	$dry_echo source $VirtualEnv_Directory/bin/activate
fi

Python_Pkg_List="\
python-genshi \
python-colorama \
python-distlib \
python-setuptools \
python-pkg-resources \
python-tk
"
apt_update
apt_install $Python_Pkg_List	

if [ $PV -eq 2 ]; then
	apt_install_recommends python-pip
elif [ $PV -eq 3 ]; then
	apt_install_recommends python3-pip
fi

log $INFO "Upgrade pip (globally)"
pip_install pip

if [ $Setup_VirtualEnv -eq 1 ]; then
	log $INFO "Install virtualenvwrapper"
	pip_install virtualenvwrapper
fi

if [ $Python_InstallBasics -eq 1 ]; then
	log $INFO "Requests, matplotlib, pandas, h5py"
	pip_install Requests
	pip_install scipy
	pip_install sklearn
	pip_install matplotlib
	pip_install pandas
	pip_install h5py
fi

if [ $Python_InstallDjango -eq 1 ]; then
	log $INFO "Django"
	pip_install django
	pip_install geoip2
	## setup aliases
	checkBash="`grep \"alias django_runserver=\" ${BF}`"
	if [[ ! -z $checkBash ]]; then
		log $INFO "Django-aliases - Seems like aliases are already setup. Not modifying ${BF}"
	else
		cat <<EOT >> ${BF}
# -------------------------------------
# Django aliases
alias django_makemigrations="python manage.py makemigrations "
alias django_migrate="python manage.py migrate "
alias django_runserver="python manage.py runserver "
EOT
	fi
fi

if [ $Python_InstallWebDevelopmentTools -eq 1 ]; then
	log $INFO "flask, BeautifulSoup, Twisted"
	pip_install flask
	pip_install Twisted
	# html,xml parser
	pip_install lxml
	if [ $PV -eq 2 ]; then 
		pip_install BeautifulSoup
	elif [ $PV -eq 3 ]; then 
		pip_install BeautifulSoup4
	fi	
fi

if [ $Python_InstallJupyter -eq 1 ]; then
	log $INFO "IPython and Jupyter-Notebook"
	# Please Note ipython 6.x wont work with python2, needs python 3 - This is automated though
	pip_install IPython
	pip_install jupyter
fi

if [ $Python_InstallNLTK -eq 1 ]; then
	log $INFO "NLTK"
	pip_install nltk
fi

if [ $Python_InstallMachineLearningTools -eq 1 ]; then
	log $INFO "ML-Tools: TF-Theano-Keras"
	if [ $Python_Compile_Tensorflow -eq 1 ]; then
		if [ $Setup_VirtualEnv -eq 1 ]; then 
			VFlag=" -v $VE "
		fi
		log $INFO "Compiling Tensorflow - " $Python_Tensorflow_Target
		bash tensorflow.sh -a $DRYFLAG -p $PV -b $Python_Tensorflow_Target -m all $VFlag
	else
		log $INFO "Not compiling tensorflow, installing from pip"
		pip_install tensorflow
	fi
	pip_install theano
	pip_install keras
fi
exit 0
