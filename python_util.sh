#!/bin/bash 
source `which virtualenvwrapper.sh`
echo "----------------------------------------------------------------------------"
echo "                        Ubuntu Python Script"
echo "----------------------------------------------------------------------------"
#logging/utils/help
LOGGER=`pwd`/log_python.log
INFO="Python: INFO: "
ERROR="Python: ERROR: "
DEBUG="DEBUG: "
log()
{
	echo -e "[${USER}]\t[`date`]\t${*}" >> "${LOGGER}"
}
#debug mode variable
export DEBUGMODE=0

#base/Initial variables
venv_prefix="sudo -H " # this is used if NOT using virtualenv, else replaced with ""

## Prints Help Message for command line (Tensorflow/Python)
_help_() {
echo "
bash python_util.sh --help
Prints this message.

Usage: bash python_util.sh <debug_mode> <preferred_python_version> <virtualenv name>;
	*. <debug_mode>:: Optional, pass \"--debug\" - To run in Debug Mode
	1. preferred_python_version: takes value either \"2\" or \"3\"]
	2. virtualenv_name: OPTIONAL: string argument that defines \"What environment to work in.\"
	   If nothing is passed, I work on global/system level without creating environment
	   Pass NULL as a virtualenv if you want to run in debug mode
"
}

if test "$1" = "--debug";  then
	export DEBUGMODE=1;
	shift
fi

if test "$1" = "--help"; then
	_help_
	exit
elif [ -z $1 ]; then
	echo "Incorrect usage"
	_help_
	exit
elif [ ! $1 -eq 2 ] && [ ! $1 -eq 3 ]; then
	log $INFO "FATAL: python version unknown. entered value: "$1
	echo "python version entered is not 2 or 3"
	exit
elif [ -z $2 ]; then
	## seems like arg1 is fine, set the python version
	Python_PreferredVersion="$1"
	if [ -z $VirtualEnv_Name ]; then
		log $INFO "NOT run via Master-Script"
		log $INFO "NOT working in virtualenv"
		echo "No virtualenv specified, working on global level"
		use_virtualenv=0
	else
		log $INFO "Virtual env specified in Master: " $VirtualEnv_Name
		echo "working on virtualenv "$VirtualEnv_Name
		venv_prefix=""
		use_virtualenv=1
		if [[ -z "${VirtualEnv_Directory}" ]]; then
			log $INFO "Virtual environment directory: set as default to ~/.virtualenvs/$VirtualEnv_Name"
			VirtualEnv_Directory=~/.virtualenvs/$VirtualEnv_Name
		fi
	fi
else
	# case where $1 is a good argument, and, $2 is also passed as a parameter
	## seems like arg1 is fine, set the python version
	Python_PreferredVersion="$1"
	
	log $INFO "Virtual env specified in commandline: "$2
	echo "Overwriting master virtualenv, and working on virtualenv "$2
	venv_prefix=""
	use_virtualenv=1
	if [[ -z "$VirtualEnv_Directory" ]]; then
		log $INFO "Virtual environment directory: set as default to ~/.virtualenvs/$2"
		VirtualEnv_Directory=~/.virtualenvs/$2
	fi
	VirtualEnv_Name=$2
fi

if [ -z $Setup_Python_Dev ]; then
	log $INFO "Called from terminal"
	echo "Looks like this script was run from the terminal (as a master variable is unset)."
	echo "Parameters are set up in this section! (lines 48 onwards)"
	Python_InstallBasics=1
	Python_InstallWebDevelopmentTools=0
	Python_InstallJupyter=0
	Python_InstallMachineLearningTools=0
	Python_InstallNLTK=0
	Python_Compile_Tensorflow=0
	Python_Tensorflow_GPU=0
	Python_Tensorflow_MKL=0
	Python_Tensorflow_CPUOnly=0
	if [ $DEBUGMODE -eq 1 ]; then
		echo $DEBUG "Will NOT install, but ONLY dry-run"
		log $INFO $DEBUG "Working in debug mode"
	else
		echo "Preparing..."
		log $INFO "Working in installation mode"
	fi
fi

#mkvirtualenv $VirtualEnv_Name
#workon $VirtualEnv_Name
## mkvirtualenv can be replaced with
#virtualenv --system-site-packages -p python2 ~/.virtualenvs/$VirtualEnv_Name
## workon $ENV$ can be replaced with
#source /$VENV_PATH$/$ENV$/bin/activate

if [ $DEBUGMODE -eq 0 ]; then
	if [ $use_virtualenv -eq 1 ]; then
		if [ ! -e  $VirtualEnv_Directory/bin/activate ]; then
			log $INFO "Creating virtualenv $VirtualEnv_Name"
			echo "Creating virtualenv $VirtualEnv_Name!"
			virtualenv --system-site-packages -p python2 $VirtualEnv_Directory
		fi
		source $VirtualEnv_Directory/bin/activate
	fi
else
	if [ $use_virtualenv -eq 1 ]; then
		echo $INFO "Activating virtualenv $VirtualEnv_Name"
		if [ ! -e  $VirtualEnv_Directory/bin/activate ]; then
			log $INFO "Required: Creating virtualenv $VirtualEnv_Name"
			echo "Creating virtualenv $VirtualEnv_Name!"
			virtualenv --system-site-packages -p python2 $VirtualEnv_Directory
		fi
		source $VirtualEnv_Directory/bin/activate
		venv_prefix=""
	fi
fi

if [ $DEBUGMODE -eq 0 ]; then
	log $INFO "Setting up apt"
	sudo apt install -y --install-recommends python-genshi \
		python-colorama \
		python-distlib \
		python-pkg-resources \
		python-tk
		
	log $INFO "Upgrade pip (globally)"
	pip$Python_PreferredVersion install --upgrade pip
else
	echo "I install apt packages and pip install --upgrade pip now"
fi

if [ $Python_InstallBasics -eq 1 ]; then
	log $INFO "Requests, matplotlib, pandas, h5py"
	if [ $DEBUGMODE -eq 1 ]; then
		echo $INFO $DEBUG $venv_prefix "pip$Python_PreferredVersion install Requests"
	else
		$venv_prefix pip$Python_PreferredVersion install Requests
		$venv_prefix pip$Python_PreferredVersion install matplotlib
		$venv_prefix pip$Python_PreferredVersion install pandas
		$venv_prefix pip$Python_PreferredVersion install h5py
	fi
fi

if [ $Python_InstallWebDevelopmentTools -eq 1 ]; then
	log $INFO "flask, BeautifulSoup, Twisted"
	if [ $DEBUGMODE -eq 1 ]; then
		echo $INFO $DEBUG $venv_prefix "pip$Python_PreferredVersion install flask"
	else
	$venv_prefix pip$Python_PreferredVersion install flask
	$venv_prefix pip$Python_PreferredVersion install BeautifulSoup
	$venv_prefix pip$Python_PreferredVersion install Twisted
	fi
fi

if [ $Python_InstallJupyter -eq 1 ]; then
	log $INFO "IPython and Jupyter-Notebook"
	if [ $DEBUGMODE -eq 1 ]; then
		echo $INFO $DEBUG $venv_prefix "pip$Python_PreferredVersion install IPython"
	else
		# Please Note ipython 6.x wont work with python2, needs python 3 - This is automated though
		$venv_prefix pip$Python_PreferredVersion install IPython
		$venv_prefix pip$Python_PreferredVersion install jupyter
	fi
fi

if [ $Python_InstallNLTK -eq 1 ]; then
	log $INFO "NLTK"
	if [ $DEBUGMODE -eq 1 ]; then
		echo $INFO $DEBUG $venv_prefix "pip$Python_PreferredVersion install nltk"
	else
		$venv_prefix pip$Python_PreferredVersion install nltk
	fi
fi

if [ $Python_InstallMachineLearningTools -eq 1 ]; then
	log $INFO "ML-Scipy-Scikit_learn-TF-Theano-Keras"
	if [ $DEBUGMODE -eq 1 ]; then
		echo $INFO $DEBUG $venv_prefix "pip$Python_PreferredVersion install scipy sklearn tensorflow keras"
		echo $INFO $DEBUG $venv_prefix "pip$Python_PreferredVersion install tensorflow theano"
	else
		$venv_prefix pip$Python_PreferredVersion install scipy ## also installs numpy
		$venv_prefix pip$Python_PreferredVersion install sklearn
	fi
	if [ $Python_Compile_Tensorflow -eq 1 ]; then
		if [ $Python_Tensorflow_GPU -eq 1 ]; then
			log $INFO "Compiling Tensorflow - GPU"
			bash tensorflow_setup.sh $Python_PreferredVersion "gpu" "--all" "-y" $VirtualEnv_Name 
		elif [ $Python_Tensorflow_MKL -eq 1 ]; then
			log $INFO "Compiling Tensorflow - MKL"
			bash tensorflow_setup.sh $Python_PreferredVersion "mkl" "--all" "-y" $VirtualEnv_Name 
		elif [ $Python_Tensorflow_CPUOnly -eq 1 ]; then
			log $INFO "Compiling Tensorflow - CPU"
			bash tensorflow_setup.sh $Python_PreferredVersion "cpu" "--all" "-y" $VirtualEnv_Name 
		fi
	else
		log $INFO "Not compiling tensorflow, installing from pip"
		$venv_prefix pip$Python_PreferredVersion install tensorflow theano keras
	fi
fi
exit
