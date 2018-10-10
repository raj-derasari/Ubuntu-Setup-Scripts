#!/bin/bash
## get util functions loaded
. util.sh ${*}

disp "Ubuntu Python Tensorflow Compile/Install Script"

CONFIGFILE=tensorflow_config.sh

## Variables to use while setting up tensorflow
startDir=`pwd`

## Help Message (Tensorflow/Python)
_help_(){
echo "
	Usage: bash tensorflow_setup.sh <arguments>
	-d or --dry-run        | Dry-run
	-f or --file           | (Optional) Select a configuration file (Bash script similar to config_tensorflow.sh in this directory)
							  If no argument is passed, config_tensorflow.sh will be loaded, you can edit it for your own use
	-p or --python-version | (Required) Set the Python Version for your Tensorflow compilation [Supported- Python2 and Python3]
	-v or --virtual-env    | (Optional) Virtual Environment to use. [If no argument is passed, uses system-wide installation]
	-a or --automated      | (Optional) Run in automated mode and Disable all user prompts
	-b or --build-for      | (Required) Build mode for compiling. [Supported- GPU,CPU,MKL] (case insensitive)
							  \"gpu\": Build with NVIDIA; [Do set up CUDA Compute Capability in your configuration script!]
							  \"mkl\": Build with Intel MKL
							  \"cpu\": Build with Intel SSE/FMA/AVX instructions
	-m or --mode           | (Required) Mode to build in:
							   clean:             \"bazel clean\" - THIS ACTION UNDOES bazel-build AND ./configure!
							   configure-only:    \"./configure\"
							   reconfigure:       \"bazel clean\";\"./configure\"
							   build-only:        \"bazel-build\" -- Useful if you want to only compile now and wheel-and-install later.
							   build-and-wheel:   \"bazel-build\";\"bazel-bin/../build-pip-package\" - build pip whl, doesnt \"pip install\"
							   wheel-and-install: \"bazel-bin\";\"pip-install\" -- Used after build-only, also does \"pip install\"
							   build-and-install: \"bazel-build\";\"bazel-bin\";\"pip install /tmp/tensorflow..\"
							   pip-install-only:  \"pip install /tmp/tensorflow_pkg/tensorflow*.whl\"
							   all:               \"bazel clean; ./configure; bazel build; bazel-bin/..build-pip-package; pip install\"
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
	If this is your first-ever run of the tensorflow compilation, select \"all\" "; exit 122
}

# Bazel-build function
_bazel_build() {
	if [ "$BUILDFOR" = "gpu" ]; then
		TF_TARGET="--config=cuda"
	elif [ "$BUILDFOR" = "mkl" ]; then
		TF_TARGET="--config=mkl"
	elif [ "$BUILDFOR" = "cpu" ]; then
		TF_TARGET=""
	fi
	log $INFO "start bazel build for: " $BUILDFOR
	$dry_echo bazel build --config=opt $TF_TARGET --verbose_failures //tensorflow/tools/pip_package:build_pip_package
}

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
			pprint "Configuration file loaded."
		else
			pprint "The configuration file does not exist."
			exit 5
		fi
		shift 2
	;;
	-x|--print-commands-only)
		shift
	;;
	-d|--dry-run)
		pprint "Executing installation of Tensorfow in dry-run mode"
		log $INFO $DEBUG "Running in dry mode"
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
	-b|--build-for)
		BUILDFOR="$2"
		shift 2
	;;
	-m|--mode)
		MODE="$2"
		shift 2
	;;
	-a|--automated)
		AUTOMODE=1
		pprint "Running in fully automated Tensorflow setup mode - All prompts disabled"
		shift
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

## For debugging purposes
# echo "Loaded values:"
# echo "File:: " $CONFIGFILE
# echo "Debug Mode:: " $DEBUG_MODE
# echo "Dry Mode:: " $DRY_MODE
# echo "Python Version:: " $PV
# echo "Build For:: " $BUILDFOR
# echo "Selected Mode:: " $MODE
# echo "Virtualenv: " $VE

## Python version Sanity Check
if [[ -z $PV ]]; then
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
	PIP_PREFIX="sudo -H python$PV -m pip install --user --upgrade"
elif [ $Setup_VirtualEnv -eq 0 ]; then
	PIP_PREFIX="sudo -H python$PV -m pip install --user --upgrade"
else
	PIP_PREFIX="python$PV -m pip install --user --upgrade"
fi
if [[ -z $AUTOMODE ]]; then
	AUTOMODE=0
fi
## Everything is sane!

## LOAD TF CONFIG
. ${CONFIGFILE}

## Sanity check on GPU-Nvidia, loaded configuration
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
		exit 3
	else
		## nvcc found AND CUDA COMP is nonzero
		pprint "Seems like nvcc is installed fine!"
		pprint "You have set TF_CUDA_COMPUTE_CAPABILITIES as:" $TF_CUDA_COMPUTE_CAPABILITIES
	fi
elif [ $"BUILDFOR" = "mkl" ]; then
	pprint "Building tensorflow with MKL optimizations"
	pprint "I assume you have already installed Intel MKL on your system!"
	pprint "Download Intel MKL: https://software.seek.intel.com/performance-libraries"
elif [ $"BUILDFOR" = "cpu" ]; then
	pprint "Building tensorflow with CPU optimizations"
fi

if [ $AUTOMODE -eq 0 ]; then
	pprint "Steps that will be executed now:"
	pprint "Download dependencies via apt-get; Clone TF from Github; Compile from there; and execution mode: --"$MODE
	read -p "Press (y) or Enter to continue setting up, or anything else to exit." exitQn
	if [ "$exitQn" = "y" ] | [ "$exitQn" = "" ] ; then
		pprint "Building tensorflow from source..."
	else
		exit 6
	fi
fi

pprint "Setting up bazel and build tools"
if [[ -z `which bazel` ]]; then
	pprint "bazel not found, installing bazel by apt-get"
	log $INFO "bazel: Installing from this script"
	pprint "installing bazel-dependencies"
	if [[ -z `which curl` ]]; then
		pprint "installing curl!"
		$apt_update
		$apt_prefix build-essential cmake git python${PV}-dev python${PV}-distutils pylint libcupti-dev curl
	fi
	if [ $DRY_MODE -eq 1 ]; then
		echo "echo deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8 | sudo tee /etc/apt/sources.list.d/bazel.list"
		echo "curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -"
	else
		echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
		curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -
	fi
	$apt_update
	#$dry_echo sudo apt-get -o Dpkg::Options::="--force-overwrite" install -y openjdk-9-jdk
	if [[ -z `which javac` ]]; then
		if [ $AUTOMODE -eq 1 ]; then
			pprint "Javac not installed, Installing oracle javac-10"
		else
			read -p "Install oracle javac 10? (Enter/y to continue, n to exit)" install_javac
			if [ "$install_javac" = "y" ] | [ "$install_javac" = "" ]; then
				pprint "installing javac!"
			elif [ "$install_javac" = "n" ]; then
				pprint "Not installing javac, Exiting!"
				exit 122
			fi
		fi
		if [ $TF_JAVA_VERSION -eq 10 ]; then
			$dry_echo sudo add-apt-repository -y ppa:linuxuprising/java
		elif [ $TF_JAVA_VERSION -eq 8 ]; then
			$dry_echo sudo add-apt-repository -y ppa:webupd8team/java
		fi
		$apt_update
		if [ $DRY_MODE -eq 1 ]; then 
			echo "echo oracle-java${TF_JAVA_VERSION}-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections"
			echo "echo oracle-java${TF_JAVA_VERSION}-installer shared/accepted-oracle-license-v1-1 seen true | sudo /usr/bin/debconf-set-selections"
		else
			echo "oracle-java${TF_JAVA_VERSION}-installer shared/accepted-oracle-license-v1-1 select true" | sudo /usr/bin/debconf-set-selections
			echo "oracle-java${TF_JAVA_VERSION}-installer shared/accepted-oracle-license-v1-1 seen true" | sudo /usr/bin/debconf-set-selections
		fi
		$apt_prefix oracle-java${TF_JAVA_VERSION}-installer
		$apt_prefix oracle-java${TF_JAVA_VERSION}-set-default
	fi
	$apt_prefix bazel
else
	pprint "seems like bazel is installed, only checking for other dependencies"
	log $INFO "bazel: Already installed"
fi

## Now we clone from git and begin compiling
$dry_echo mkdir -p $tfGitRoot
$dry_echo cd $tfGitRoot;
if [[ ! -e ./tensorflow/README.md ]]; then
	pprint "Git repo is not cloned yet!"
	$dry_echo git clone https://github.com/tensorflow/tensorflow
fi
$dry_echo cd tensorflow;
$dry_echo git checkout -- .
log $INFO "Successfully cloned from git"
# now in tensorflow git directory!
export TF_ROOT=$tfGitRoot/tensorflow
export PYTHON_BIN_PATH=$(which python${PV})
log $INFO "python bin path: "$PYTHON_BIN_PATH
pprint "Setup_VirtualEnv:" $Setup_VirtualEnv
if [ $Setup_VirtualEnv -eq 1 ]; then
	$dry_echo workon $VE
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

if [[ "$BUILDFOR" = "gpu" ]]; then 
	export TF_NEED_MKL=0
	export TF_NEED_CUDA=1
	export TF_CUDA_CLANG=0
	export CUDA_TOOLKIT_PATH=/usr/local/cuda
	export CUDNN_INSTALL_PATH=/usr/local/cuda
	export TF_CUDA_VERSION="$($CUDA_TOOLKIT_PATH/bin/nvcc --version | sed -n 's/^.*release \(.*\),.*/\1/p')"
	export TF_CUDNN_VERSION="$(sed -n 's/^#define CUDNN_MAJOR\s*\(.*\).*/\1/p' $CUDNN_INSTALL_PATH/include/cudnn.h)"
elif [[ "$BUILDFOR" = "mkl" ]]; then 
	export TF_NEED_MKL=1
	export TF_NEED_CUDA=0
elif [[ "$BUILDFOR" = "cpu" ]]; then 
	export TF_NEED_MKL=0
	export TF_NEED_CUDA=0
fi

## Build!
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
		$dry_echo $PIP_PREFIX  --ignore-installed  /tmp/tensorflow_pkg/tensorflow*.whl
	;;
	"wheel-and-install")
		$dry_echo bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
		$dry_echo $PIP_PREFIX --ignore-installed  /tmp/tensorflow_pkg/tensorflow*.whl
	;;
	"pip-install-only")
		$dry_echo $PIP_PREFIX --ignore-installed /tmp/tensorflow_pkg/tensorflow*.whl
	;;
	"all")
		#echo "bazel clean; ./configure; bazel build; bazel-bin; $PIP_PREFIX pip insall"
		$dry_echo bazel clean;
		$dry_echo ./configure;
		$dry_echo _bazel_build;
		$dry_echo bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
		$dry_echo $PIP_PREFIX --ignore-installed /tmp/tensorflow_pkg/tensorflow*.whl
	;;
esac

#########################################################################################################################
if [ -e /tmp/tensorflow_pkg ]; then
	if [ `sudo cp /tmp/tensorflow_pkg/tensorflow*.whl "$startDir" 2>/dev/null` ]; then
		log $INFO "Backing up tensorflow whl!"
		pprint "Your tensorflow.whl file that was built, has been backuped in $startDir!"
	else
		pprint "Did NOT back up tensorflow.whl. It may not be present in /tmp/tensorflow_pkg/"
	fi
else
	pprint "the path /tmp/tensorflow_pkg/ does not seem to exist. huh."
fi
cd "$startDir"
# $dry_echo python$python_version convolutional_test.py
#exit $?