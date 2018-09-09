#!/bin/bash
# set -o errexit -o pipefail -o noclobber #-o nounset
## get util functions loaded
. util.sh
#. `which virtualenvwrapper.sh`

# use the display function to print this
disp "Ubuntu Python Tensorflow Compile/Install Script"

CONFIGFILE=tensorflow_config.sh

#logging/utils/help
INFO="TF: INFO: "
ERROR="TF: ERROR: "

## Variables to use while setting up tensorflow
DEBUG_MODE=0
DRY_MODE=0
dry_echo=""
startDir=`pwd`

## Help Message (Tensorflow/Python)
_help_() {
	echo "
	Usage: bash tensorflow_setup.sh <arguments>
	-D or --dry-run        | Dry-run
	-d or --debug-mode     | To run in debug mode
	-f or --file           | (Optional) Select a configuration file (Bash script similar to tensorflow_config.sh in this directory)
	                          If no argument is passed, tensorflow_config.sh will be loaded, you can edit it for your own use
	-p or --python-version | (Required) Set the Python Version for your Tensorflow compilation [Supported- Python2 and Python3]
	-v or --virtual-env    | (Optional) Virtual Environment to use. [If no argument is passed, uses system-wide installation]
	-a or --automated      | (Optional) Run in automated mode and Disable all user prompts
	-b or --build-for      | (Required) Build mode for compiling. [Supported- GPU,CPU,MKL] (case insensitive)
	                          \"gpu\": Build with NVIDIA; [Do set up CUDA Compute Capability in your configuration script!]
	                          \"mkl\": Build with Intel MKL
	                          \"cpu\": Build with Intel SSE/FMA/AVX instructions
	-m or --mode           | (Required) Mode to build in:
	                           clean: executes \"bazel clean\" - Undoes bazel-build and ./configure
	                           configure-only: executes \"./configure\"
	                           reconfigure: executes \"bazel clean\" to undo configure; followed by \"./configure\"
	                           build-only: executes \"bazel-build\" -- Useful if you want to only compile now.
	                           build-and-wheel: executes \"bazel-build\" followed by \"bazel-bin/...build-pip-package\" -- Useful if you want to see the pip whl
	                           wheel-and-install: executes \"bazel-bin\" followed by \"pip-install\" -- Useful if you have already compiled and want to install now
	                           build-and-install: same as --build-and-wheel, also followed by \"pip install /tmp/tensorflow..\"
	                           pip-install-only: executes \"pip install /tmp/tensorflow_pkg/tensorflow*.whl\"
	                           all: \"bazel clean; ./configure; bazel build; bazel-bin/..build-pip-package; pip install\"
	----------------------------------------------------------------------------------------------------------------------
	The script executes compilation steps-
	1. Clones tensorflow from Github
	2. Loads your tensorflow configuration file
	3. Installs any missing dependencies
	4. Does a bazel-build from the source code, using your configuration (command - bazel-build)
	5. From the bazel build, a bazel binary is compiled (command - bazel-bin)
	6. The bazel binary is converted to a pip package (command - build-pip-package, creates a wheel/.whl file)
	7. Python-pip installs the pip package from the previous step (command - pip install <>)
	8. That's it, you can now install keras if you wish to, or run \"import tensorflow\"
	   from your Python executable to check if it installed correctly!
	----------------------------------------------------------------------------------------------------------------------
	If this is your first-ever run of the tensorflow compilation, select \"all\" "; exit 0
	}

# Bazel-build function
_bazel_build() {
	if [[ $Python_Tensorflow_GPU -eq 1 ]]; then
		log $INFO "start bazel build for GPU"
		bazel build --config=opt --config=cuda --verbose_failures //tensorflow/tools/pip_package:build_pip_package
	elif [[ $Python_Tensorflow_MKL -eq 1 ]]; then 
		log $INFO "start bazel build for MKL"
		bazel build --config=opt --config=mkl --verbose_failures //tensorflow/tools/pip_package:build_pip_package
	elif [[ $Python_Tensorflow_CPUOnly -eq 1 ]]; then
		log $INFO "start bazel build for CPU"
		bazel build --config=opt --verbose_failures //tensorflow/tools/pip_package:build_pip_package
	fi
}

#OPTIONS=hf:v:dDp:b:m:a
while true; do
    case "$1" in
    	-h|--help)
			_help_
			shift
			exit 0
			;;
		-f|--file)
			CONFIGFILE="$2"
			if [ -e "$2" ]; then
				echo "Configuration file loaded"
			else
				echo "The configuration file you input does not exist!"
				exit 5
			fi
			shift 2
			;;
		-D|--dry-run)
			DRY_MODE=1
			dry_echo="echo "
			DRYFLAG=" -D "
			echo "Dry-Run: No commands will be executed"
			log $INFO $DEBUG "Running in debug mode"
			shift
			;;
		-v|--virtualenv)
			Setup_VirtualEnv=1
			VE="$2"
			shift 2
			;;
        -p|--python-version)
			PV="$2"
			shift 2
			;;
		## ALLOWED VALUES: GPU,MKL,CPU
		-b|--build-for)
			BUILDFOR="$2"
			shift 2
			;;
		## mode can have tons of values - check this out
		-m|--mode)
			MODE="$2"
			shift 2
			;;
		-a|--automated)
			AUTOMODE=1
			echo "Running in fully automated Tensorflow setup mode - All prompts disabled"
			shift
			#echo "Running in auto mode, all user inputs disabled!"
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

## This next part has been tested to be working fine, so commented it out
	# echo "Loaded values:"
	# echo "File:: " $CONFIGFILE
	# echo "Debug Mode:: " $DEBUG_MODE
	# echo "Dry Mode:: " $DRY_MODE
	# echo "Python Version:: " $PV
	# echo "Build For:: " $BUILDFOR
	# echo "Selected Mode:: " $MODE
	# echo "Virtualenv: " $VE
## Command line args parse successfully, now do a sanity check
## Python version Sanity Check
if [[ -z $PV ]]; then
	## Python version not passed
	echo "Required: Python Version command line argument"
	_help_
	exit 3
elif [ $PV -ne 2 ] && [ $PV -ne 3 ]; then
	echo "Cannot recognize Python version"
	echo "Supported Python versions are Python2 and Python3"
	_help_
	exit 5
#Python version is OK
## Build target sanity check
elif [[ -z $BUILDFOR  ]]; then
	## Build Target Unclear (CPU/GPU/MKL)
	echo "Required: Build-target command line argument"
	_help_
	exit 3
elif [ ! "$BUILDFOR" = "mkl" ] && [ ! "$BUILDFOR" = "gpu" ] && [ ! "$BUILDFOR" = "cpu" ]; then
	echo "Cannot recognize BUILDFOR variable"
	echo "Did you select one of the three allowed values (CPU,GPU,MKL)?"
	_help_
	exit 5
## Buildfor target is OK
## MODE sanity check
elif [[ ! -z $MODE ]]; then
	# 	echo "Required: Mode command line argument"
	# 	_help_
	# 	exit 3
	# elif [[  ]]; then
	case $MODE in
	## All allowed values, pass these
	"clean") ;;
	"configure-only") ;;
	"reconfigure") ;;
	"build-only") ;;
	"build-and-wheel") ;;
	"build-and-install") ;;
	"wheel-and-install") ;;
	"pip-install-only") ;;
	"all") ;;
	# Any other value, fail
	*)
	echo "Cannot recognize MODE variable"
	echo "Did you select one of the allowed values for MODE?"
	_help_
	exit 5
	;;
	esac
fi

## Verify virtualenv usage and auto mode
if [[ -z $Setup_VirtualEnv ]]; then
	## wasnt passed in master-script OR in command line
	Setup_VirtualEnv=0
	## DO other venv stuff here
	PIP_PREFIX="sudo -H python$PV -m pip install --upgrade"
elif [ $Setup_VirtualEnv -eq 1 ]; then
	PIP_PREFIX="python$PV -m pip install --upgrade"
fi
if [[ -z $AUTOMODE ]]; then
	## NOT in AUTOMODE, yes in interactive mode
	AUTOMODE=0
fi
## Everything is sane!

## LOAD TF CONFIG
. ${CONFIGFILE}

## Sanity check on GPU-Nvidia
#if [[ "$BUILDFOR" = "gpu" || "$BUILDFOR" = "gpu" ]] && [ "$TF_CUDA_COMPUTE_CAPABILITIES" -eq 0 ]; then
if [ "$BUILDFOR" = "gpu" ]; then
	if [ "$TF_CUDA_COMPUTE_CAPABILITIES" -eq 0 ]; then
		echo "You have not set the variable TF_CUDA_COMPUTE_CAPABILITIES in your configuration"
		echo "Please set TF_CUDA_COMPUTE_CAPABILITIES according to your GPU before you can continue!"
		exit 0
	elif [ -z `which nvcc` ]; then
			log $ERROR "FATAL: Cannot build for GPU, CUDA Toolkit is not installed."
			echo -e "FATAL ERROR: CUDA Toolkit not installed!\nPerhaps try running \"nvidia_setup_cuda.sh\"?"
			echo -e "Download CUDA: https://developer.nvidia.com/cuda-downloads \nDownload CUDNN: https://developer.nvidia.com/cudnn"
			echo "You will also have to restart your computer after installing nvcc, and re-run this script"
			echo -e "Fatal error: nvcc not installed. \nCould not install tensorflow"
			exit
	else
		## nvcc found AND CUDA COMP is nonzero
		echo "Seems like nvcc is installed fine!"
		echo "You have set TF_CUDA_COMPUTE_CAPABILITIES as:" $TF_CUDA_COMPUTE_CAPABILITIES
		Python_Tensorflow_GPU=1	
		Python_Tensorflow_MKL=0
		Python_Tensorflow_CPUOnly=0
	fi
elif [ $"BUILDFOR" = "mkl" ]; then
	echo "Building tensorflow with MKL optimizations"
	echo "I assume you have already installed Intel MKL on your system!"
	echo "Download Intel MKL: https://software.seek.intel.com/performance-libraries"
	Python_Tensorflow_GPU=0	
	Python_Tensorflow_MKL=1
	Python_Tensorflow_CPUOnly=0
elif [ $"BUILDFOR" = "cpu" ]; then
	echo "Building tensorflow with CPU optimizations"
	Python_Tensorflow_GPU=0	
	Python_Tensorflow_MKL=0
	Python_Tensorflow_CPUOnly=1
fi

if [ $AUTOMODE -eq 0 ]; then
	echo "Steps that will be executed now:"
	echo "Download dependencies via apt-get; Clone TF from Github; Compile from there; and execution mode: --"$MODE
	read -p "Press (y) or Enter to continue setting up, or anything else to exit." exitQn
	if [ "$exitQn" = "y" ] | [ "$exitQn" = "" ] ; then
		echo "Building tensorflow from source..."
	else
		exit 6
	fi
fi

echo "Setting up bazel and build tools"
if [[ -z `which bazel` ]]; then
	echo "bazel not found, installing bazel by apt-get"
	log $INFO "bazel: Installing from this script"
	if [ $DRY_MODE -eq 1 ]; then
		echo "Add apt-repositories for bazel"
	else
		echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
		curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -
	fi
	#sudo apt-key update && 
	$dry_echo sudo apt-get update 1>/dev/null
	#$dry_echo sudo apt-get -o Dpkg::Options::="--force-overwrite" install -y openjdk-9-jdk
	if [[ -z `which javac` ]]; then
		if [ $AUTOMODE -eq 1 ]; then
			echo "Javac not installed, Installing oracle javac-10"
		else
			read -p "Install oracle javac 10? (Enter/y to continue, n to exit)" install_javac
			if [ "$install_javac" = "y" ] | [ "$install_javac" = "" ]; then
				echo "installing javac!"
			elif [ "$install_javac" = "n" ]; then
				echo "Not installing javac, Exiting!"
				exit 122
			fi
		fi
		if [ $TF_JAVA_VERSION -eq 10 ]; then
			$dry_echo sudo add-apt-repository -y ppa:linuxuprising/java
		elif [ $TF_JAVA_VERSION -eq 8 ]; then
			$dry_echo sudo add-apt-repository -y ppa:webupd8team/java
		fi
		$dry_echo sudo apt-get update
		$dry_echo sudo apt-get install -y oracle-java${TF_JAVA_VERSION}-installer
		$dry_echo sudo apt-get install -y oracle-java${TF_JAVA_VERSION}-set-default
		if [ $DRY_MODE -ne 1 ]; then 
			echo "oracle-java${TF_JAVA_VERSION}-installer shared/accepted-oracle-license-v1-1 select true" | sudo /usr/bin/debconf-set-selections
			echo "oracle-java${TF_JAVA_VERSION}-installer shared/accepted-oracle-license-v1-1 seen true" | sudo /usr/bin/debconf-set-selections
		fi
	fi
	$dry_echo sudo apt-get install -y build-essential cmake git python{PV}-dev pylint libcupti-dev curl
	$dry_echo sudo apt-get install -y bazel
else
	echo "seems like bazel is installed, only checking for other dependencies"
	log $INFO "bazel: Already installed"
	$dry_echo sudo apt-get install -y build-essential cmake git python{PV}-dev pylint libcupti-dev curl
fi

## Now we clone from git and begin installation

$dry_echo mkdir -p $tfGitRoot
$dry_echo cd $tfGitRoot;
if [[ ! -e ./tensorflow/README.md ]]; then
	echo "Git repo is not cloned yet!"
	$dry_echo git clone https://github.com/tensorflow/tensorflow
fi
$dry_echo cd tensorflow;
$dry_echo git checkout -- .
log $INFO "Successfully cloned from git"
# now in tensorflow git directory!
export TF_ROOT=$tfGitRoot/tensorflow
export PYTHON_BIN_PATH=$(which python${python_version})
log $INFO "python bin path: "$PYTHON_BIN_PATH

if [ $Setup_VirtualEnv -eq 1 ]; then
	export PYTHON_LIB_PATH="$($PYTHON_BIN_PATH -c 'from distutils.sysconfig import get_python_lib; print(get_python_lib())')"
	log $INFO "venv python lib path: "$PYTHON_LIB_PATH
else
	export PYTHON_LIB_PATH="$($PYTHON_BIN_PATH -c 'import site; print(site.getsitepackages()[0])')"
	log $INFO "sys python lib path: "$PYTHON_LIB_PATH
fi

## Initial values, will actually be set up in the next block
export PYTHONPATH="${TF_ROOT}"/lib
export PYTHON_ARG="${TF_ROOT}"/lib
export GCC_HOST_COMPILER_PATH=$(which gcc)
export CC_OPT_FLAGS="-march=native"
export TF_NEED_CUDA=0
export TF_NEED_MKL=0

if [[ $Python_Tensorflow_GPU -eq 1 ]]; then 
	export TF_NEED_MKL=0
	export TF_NEED_CUDA=1
	export TF_CUDA_CLANG=0
	export CUDA_TOOLKIT_PATH=/usr/local/cuda
	export CUDNN_INSTALL_PATH=/usr/local/cuda
	export TF_CUDA_VERSION="$($CUDA_TOOLKIT_PATH/bin/nvcc --version | sed -n 's/^.*release \(.*\),.*/\1/p')"
	export TF_CUDNN_VERSION="$(sed -n 's/^#define CUDNN_MAJOR\s*\(.*\).*/\1/p' $CUDNN_INSTALL_PATH/include/cudnn.h)"
elif [[ $Python_Tensorflow_MKL -eq 1 ]]; then
	export TF_NEED_MKL=1
	export TF_NEED_CUDA=0
elif [[ $Python_Tensorflow_CPUOnly -eq 1 ]]; then 
	export TF_NEED_MKL=0
	export TF_NEED_CUDA=0
fi



## PUt the Build Blocks here

case $MODE in 
	"clean")
		$dry_echo bazel clean;
	;;
		"configure-only")
		$dry_echo ./configure;
	;;
	"reconfigure") 
		$dry_echo bazel clean;
		$dry_echo ./configure; 
	;;
	"build-only")
		$dry_echo _bazel_build;
	;;
	"build-and-wheel")
		$dry_echo _bazel_build;
		$dry_echo bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
	;;
	"build-and-install")
		$dry_echo _bazel_build;
		$dry_echo bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
		$dry_echo $PIP_PREFIX $PIP_PREFIX /tmp/tensorflow_pkg/tensorflow*.whl
	;;
	"wheel-and-install")
		$dry_echo bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
		$dry_echo $PIP_PREFIX $PIP_PREFIX /tmp/tensorflow_pkg/tensorflow*.whl
	;;
	"pip-install-only")
		$dry_echo $PIP_PREFIX $PIP_PREFIX /tmp/tensorflow_pkg/tensorflow*.whl
	;;
	"all")
		#echo "bazel clean; ./configure; bazel build; bazel-bin; $PIP_PREFIX pip insall"
		$dry_echo bazel clean;
		$dry_echo ./configure;
		$dry_echo _bazel_build;
		$dry_echo bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
		$dry_echo $PIP_PREFIX --ignore-installed /tmp/tensorflow_pkg/tensorflow*.whl
	;;
	*)
		echo "come again?"
	;;
esac


#########################################################################################################################




if [ -e /tmp/tensorflow_pkg ]; then
	if [ `sudo cp /tmp/tensorflow_pkg/tensorflow*.whl "$startDir" 2>/dev/null` ]; then
		log $INFO "Backing up tensorflow whl!"
		echo "Your tensorflow.whl file that was built, has been backuped in $startDir!"
	else
		echo "Did NOT back up tensorflow.whl. It may not be present in /tmp/tensorflow_pkg/"
	fi
else
	echo "the path /tmp/tensorflow_pkg/ does not seem to exist. huh."
	#exit 5
fi
#log $INFO "running tensorflow test script!"
cd "$startDir"

#python$python_version convolutional_test.py
## will exit with the python code's exit condition
#exit $?