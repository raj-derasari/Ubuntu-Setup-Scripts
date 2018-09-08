#!/bin/bash
#set -o errexit -o pipefail -o noclobber #-o nounset
## get util functions loaded
. util.sh
. `which virtualenvwrapper.sh`
#. ${BF}

# use the display function to print this
disp "Ubuntu Python Script"
if [ -z $Setup_Python_Dev ]; then
	log $INFO "Called from terminal"
	echo "Looks like this script was run from the terminal (as a master variable is unset)."
	echo "Parameters are now loaded from config file"
	## your bashrc profile/main profile file.
	BF=~/.bashrc
	#Setup_VirtualEnv=0
	# Enter the path to your virtualenv parent directory, eg. if you venv is "myVE" and path is
	# ~/.virtualenvs/myVE/
	# then enter ~/.virtualenvs
	# without quotes
	VirtualEnv_Directory=~/.virtualenvs
	## Python installation params
	Python_InstallBasics=1
	Python_InstallWebDevelopmentTools=1
	Python_InstallDjango=1
	Python_InstallJupyter=1
	Python_InstallMachineLearningTools=1
	Python_InstallNLTK=1
	Python_Compile_Tensorflow=1
	Python_Tensorflow_GPU=1
	Python_Tensorflow_MKL=0
	Python_Tensorflow_CPUOnly=0
fi

#logging/utils/help
INFO="Py: INFO: "
ERROR="Py: ERROR: "

#base/Initial variables
dry_echo=""

## Prints Help Message for command line (Tensorflow/Python)
_help_() {
echo "
Usage: bash python_util.sh <arguments>
-h  or  --help               |  Print this message
-D  or  --dry-run            |  Dry-run
-d  or  --debug-mode         |  To run in debug mode
-v  or  --virtual-env        |  Virtual Environment to use. [If no argument is passed, system-wide installation]
-p  or  --preferred-version  |  Python Version [accepted values: 2, 3]
"; exit 0
}

echo "Parsing command line parameters."
while true; do
    case "$1" in
        -h|--help) _help_
			shift
			;;
        -D|--dry-run)
			DRY_RUN=1
			dry_echo="echo "
			#set -v
			echo "In dry-run mode"
			shift
			;;
        -d|--debug-mode)
			DEBUG=1
			echo "In debug mode"
			shift
			;;
        -v|--virtual-env)
			Setup_VirtualEnv=1
			VE="$2"
			venv_prefix="python -m pip install --user --upgrade " # this is used if NOT using virtualenv
			shift 2
			;;
        -p|--preferred-version)
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
	echo "Python Version argument not passed!"
	_help_
	exit 127
elif [ ! $PV -eq 2 ] && [ ! $PV -eq 3 ]; then
	if [[ ! -z $Python_PreferredVersion ]]; then
		echo "Master Script has set Python_Version as Python"$Python_PreferredVersion
		echo "Using master-script python version!"
		PV=$Python_PreferredVersion
	else
		log $INFO "FATAL: python version unknown. entered value: "$1
		echo "Python version entered is not 2 or 3!"
		_help_
		exit 127
	fi
fi

## VE sanity check
# Called from terminal and Venv wasnt used, OR called from master and venv wasnt used
if [[ -z $Setup_VirtualEnv ]] | [ $Setup_VirtualEnv -eq 0 ]; then
	log "DEBUG: line 96 Py"
	Setup_VirtualEnv=0
	venv_prefix="sudo -H python${PV} -m pip install --user --upgrade " # this is used if NOT using virtualenv
	echo "Not installing to any virtualenv!"
# called from either source, but venv was used - hence name is definitely known
elif [ $Setup_VirtualEnv -eq 1 ]; then
	Setup_VirtualEnv=1
	venv_prefix="python${PV} -m pip install --user --upgrade " # this is used if NOT using virtualenv
	if [[ -z $VE ]]; then
		VE=$VirtualEnv_Name
	fi
	if [[ -z $VirtualEnv_Directory ]]; then
		VirtualEnv_Directory=~/.virtualenvs/$VE
	fi
	#mkvirtualenv $VirtualEnv_Name
	#workon $VirtualEnv_Name
	## mkvirtualenv can be replaced with
	#virtualenv --system-site-packages -p python2 ~/.virtualenvs/$VirtualEnv_Name
	## workon $ENV$ can be replaced with
	#source /$VENV_PATH$/$ENV$/bin/activate
	if [ ! -e  $VirtualEnv_Directory/bin/activate ]; then
		log $INFO "Creating virtualenv $VirtualEnv_Name"
		echo "Creating virtualenv $VE!"
		$dry_echo virtualenv --system-site-packages -p python$PV $VirtualEnv_Directory
	fi
	$dry_echo source $VirtualEnv_Directory/bin/activate
fi
# ------------------------------------------------------------------------------------------------------------------
$dry_echo sudo apt install -y --install-recommends \
	python-genshi \
	python-colorama \
	python-distlib \
	python-pkg-resources \
	python-tk

if [ $PV -eq 2 ]; then
	$dry_echo sudo apt install -y python-pip --install-recommends
elif [ $PV -eq 3 ]; then
	$dry_echo sudo apt install -y python3-pip --install-recommends
fi

log $INFO "Upgrade pip (globally)"
$dry_echo $venv_prefix pip

if [ $Setup_VirtualEnv -eq 1 ]; then
	log $INFO "Install virtualenvwrapper"
	$dry_echo $venv_prefix virtualenvwrapper
fi

if [ $Python_InstallBasics -eq 1 ]; then
	log $INFO "Requests, matplotlib, pandas, h5py"
	$dry_echo $venv_prefix Requests
	$dry_echo $venv_prefix scipy
	$dry_echo $venv_prefix sklearn
	$dry_echo $venv_prefix matplotlib
	$dry_echo $venv_prefix pandas
	$dry_echo $venv_prefix h5py
fi

if [ $Python_InstallDjango -eq 1 ]; then
	log $INFO "Django"
	$dry_echo $venv_prefix django
	$dry_echo $venv_prefix geoip2
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
	$dry_echo $venv_prefix flask
	$dry_echo $venv_prefix Twisted
	# html,xml parser
	$dry_echo $venv_prefix lxml
	if [ $PV -eq 2 ]; then 
		$dry_echo $venv_prefix BeautifulSoup
	elif [ $PV -eq 3 ]; then 
		$dry_echo $venv_prefix BeautifulSoup4
	fi	
fi

if [ $Python_InstallJupyter -eq 1 ]; then
	log $INFO "IPython and Jupyter-Notebook"
	# Please Note ipython 6.x wont work with python2, needs python 3 - This is automated though
	$dry_echo $venv_prefix IPython
	$dry_echo $venv_prefix jupyter
fi

if [ $Python_InstallNLTK -eq 1 ]; then
	log $INFO "NLTK"
	$dry_echo $venv_prefix nltk
fi

if [ $Python_InstallMachineLearningTools -eq 1 ]; then
	log $INFO "ML-Tools: TF-Theano-Keras"
	if [ $Python_Compile_Tensorflow -eq 1 ]; then
		if [ $Python_Tensorflow_GPU -eq 1 ]; then
			log $INFO "Compiling Tensorflow - GPU"
			$dry_echo bash tensorflow_setup.sh $PV "gpu" "--all" "-y" $VE
		elif [ $Python_Tensorflow_MKL -eq 1 ]; then
			log $INFO "Compiling Tensorflow - MKL"
			$dry_echo bash tensorflow_setup.sh $PV "mkl" "--all" "-y" $VE
		elif [ $Python_Tensorflow_CPUOnly -eq 1 ]; then
			log $INFO "Compiling Tensorflow - CPU"
			$dry_echo bash tensorflow_setup.sh $PV "cpu" "--all" "-y" $VE
		fi
	else
		log $INFO "Not compiling tensorflow, installing from pip"
		$dry_echo $venv_prefix tensorflow
	fi
	$dry_echo $venv_prefix theano
	$dry_echo $venv_prefix keras
fi
exit
