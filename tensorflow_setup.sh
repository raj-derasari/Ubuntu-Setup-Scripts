#!/bin/bash 
source `which virtualenvwrapper.sh`
echo "----------------------------------------------------------------------------"
echo "                        Ubuntu Tensorflow Script"
echo "----------------------------------------------------------------------------"
#logging/utils/help
LOGGER=`pwd`/log_tensorflow.log
INFO="TF: INFO: "
ERROR="TF: ERROR: "
DEBUG="DEBUG: "
log()
{
	echo -e "[${USER}]\t[`date`]\t${*}" >> ${LOGGER}
}
## Variables that control program flow
if [[ -z $DEBUGMODE ]]; then
	DEBUGMODE=0	
fi

## Variables to use while setting up tensorflow
venv_prefix="sudo -H " # this is used if NOT using virtualenv, else replaced with ""
export startDir=`pwd`

## Help Message (Tensorflow/Python
HELP="
Usage:
bash tensorflow_setup.sh --help
Prints this message.

bash tensorflow_setup.sh <python_version> <gpu/mkl/cpu> <mode> <unattended> <virtualenv name>

1. python_version: Required, enter
                   \"2\": To work with python2 
                   \"3\": To work with python3
2. gpu/mkl/cpu: Required, pass 
                \"gpu\" to build with NVIDIA; [Do set up CUDA Compute Capability in line 62!]
                \"mkl\" to build with Intel MKL;
                \"cpu\" to build with Intel SSE/FMA/AVX instructions
3. <mode> : Required, enter 
            --clean: executes \"bazel clean\" - Undoes bazel-build and ./configure
            --configure-only: executes \"./configure\"
            --reconfigure: executes \"bazel clean\" to undo configure; followed by \"./configure\"
            --build-only: executes \"bazel-build\" -- Useful if you want to only compile now.
            --build-and-wheel: executes \"bazel-build\" followed by \"bazel-bin/...build-pip-package\" -- Useful if you want to see the pip whl
            --wheel-and-install: executes \"bazel-bin\" followed by \"pip-install\" -- Useful if you have already compiled and want to install now
            --build-and-install: same as --build-and-wheel, also followed by \"pip install /tmp/tensorflow..\"
            --pip-install-only: executes \"pip install /tmp/tensorflow_pkg/tensorflow*.whl\"
            --all: \"bazel clean; ./configure; bazel build; bazel-bin/..build-pip-package; pip install\"
4. unattended : pass \"-y\" as a parameter if you want an automated/unattended installation
              : pass \"-n\" as a parameter for an interactive installation
5. virtualenv_name: string argument, target virtualenv to install tensorflow in
   If nothing is passed, will install tensorflow on global level [requires sudo]
"

_bazel_build()
{
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

# CUDA COMPUTE CAPABILITY of your GPU must be enterred -- IF you are building for NVIDIA GPU
export TF_CUDA_COMPUTE_CAPABILITIES=0

tfGitRoot=~/tfSource # path where tensorflow is downloaded from github
## best use an absolute/complete path here, like I did! 

if test "$1" = "--help"; then
	echo "$HELP"
	exit
elif [[ -z $1 ]] || [[ -z $2 ]]  || [[ -z $3 ]]  || [[ -z $4 ]] ; then
	echo "Incorrect usage."
	echo "$HELP"
	exit
else
	log $INFO "Set tensorflow build mode: "$2
	log $INFO "Set tensorflow steps: "$3
fi

# Now, not in help mode and all params are given: set values based on params
if [[ ! -z "$Python_PreferredVersion" ]]; then
	python_version=$Python_PreferredVersion
	log $INFO "Set python version from Master Script: python"$python_version
else
	python_version="$1"
	echo "Building tensorflow from source, for python version python$python_version"
	log $INFO "Set python version from console: python"$python_version
fi

if test $2 = "gpu"; then
	if [ $DEBUGMODE -eq 1 ]; then
		echo "Will check for NVCC and TF_CUDA_COMPUTE_CAPABILITIES"
	else
		if [ -z `which nvcc` ]; then
			log $ERROR "FATAL: Cannot build for GPU, CUDA Toolkit is not installed."
			echo -e "FATAL ERROR: CUDA Toolkit not installed!\nTry running \"nvidia_setup_cuda.sh\""
			echo -e "Download CUDA: https://developer.nvidia.com/cuda-downloads \nDownload CUDNN: https://developer.nvidia.com/cudnn"
			echo "Fatal errors encountered while installing tensorflow"
			exit
		fi
		if [ $TF_CUDA_COMPUTE_CAPABILITIES -eq 0 ]; then
			echo "FATAL error: You have not set your GPU's CUDA COMPUTE CAPABILITIES in the script - Line 13"
			log $ERROR "Cuda Compute Capabilities not set - Cannot continue"
			#echo -e "Please also note: \n\tYou have not mentioned your GPU's CUDA COMPUTE CAPABILITIES in the script\nPlease modify the script and update line 13 before you execute"
			echo "Fatal errors encountered while installing tensorflow"
			exit
		fi
		Python_Tensorflow_GPU=1	
		Python_Tensorflow_MKL=0
		Python_Tensorflow_CPUOnly=0
	fi
elif
	test $2 = "mkl"; then
	echo "I assume you have already installed Intel MKL on your system! If you haven't please exit"
	echo "Download Intel MKL: https://software.seek.intel.com/performance-libraries"
	Python_Tensorflow_GPU=0	
	Python_Tensorflow_MKL=1
	Python_Tensorflow_CPUOnly=0
elif test $2 = "cpu"; then
	echo "Building tensorflow with CPU optimizations"
	Python_Tensorflow_GPU=0	
	Python_Tensorflow_MKL=0
	Python_Tensorflow_CPUOnly=1
fi

if test $4 = "-y"; then
	log $INFO "Tensorflow in automated install mode:"
	AUTOMODE="$2"
elif test $4 = "-n"; then
	log $INFO "Tensorflow in interactive install mode:"
	AUTOMODE=""
else
	echo "Second argument not understood. Please enter \"-y\" or \"-n\""
	exit
fi

if [[ ! -z "$VirtualEnv_Name" ]]; then
	use_virtualenv=1
	log $INFO "Set virtual environment from master:" $VirtualEnv_Name
	echo "Working in virtual environment $VirtualEnv_Name"
	workon $VirtualEnv_Name
	venv_prefix=""
elif [[ ! -z "$5" ]]; then
		use_virtualenv=1
		VirtualEnv_Name="$5"
		log $INFO "Set virtual environment from console: "$5
		echo "Working in virtual environment $VirtualEnv_Name"
		workon $VirtualEnv_Name
		venv_prefix=""
else
	use_virtualenv=0
	echo "Installing Tensorflow in system, NOT in VirtualEnvironment"
	log $INFO "NOT setting up virtual environment"
	venv_prefix="sudo -H "
fi

if [[ ! -z "$AUTOMODE" ]]; then
	echo "Running in auto mode, all user inputs disabled!"
else
	#echo "Configuration you have asked for: "
	#echo "Python version: $1, TF Compile: $2"
	echo "Steps that will be executed now:"
	echo "Download dependencies via apt-get; Clone TF from Github; Compile from there; and execution mode $3"
	read -p "Press (y) or Enter to continue setting up, or anything else to exit." exitQn
fi

if [[ "$exitQn" = "y" ]]; then
	echo "Building tensorflow from source..."
elif [[ "$exitQn" = "Y" ]]; then
	echo "Building tensorflow from source..."
elif [[ ! -z "$exitQn" ]]; then ## if anything beside y/Y/enter is pressed
	echo "Exiting"
	exit
fi

# fulfil dependencies and build tools

if [ $DEBUGMODE -eq 0 ]; then
	log $INFO "Bazel and build tools"
	echo "Setting up bazel and build tools"
	if [[ -z `which bazel` ]]; then
		echo "bazel not found, installing bazel by apt-get"
		log $INFO "bazel: Installing from this script"
		echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
		curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -
		sudo apt-key update && sudo apt-get update > /dev/null
		sudo apt-get -o Dpkg::Options::="--force-overwrite" install -y openjdk-9-jdk
		sudo apt-get install -y bazel
	else
		echo "seems like bazel is installed, only checking for other dependencies"
		log $INFO "bazel: Already installed"
	fi
	if [ $python_version -eq 2 ]; then
		sudo apt-get install -y build-essential cmake git python2.7-dev pylint libcupti-dev curl
	else
		sudo apt-get install -y build-essential cmake git python3.5-dev pylint libcupti-dev curl
	fi
else
	log $INFO $DEBUG "should be installing bazel, build tools and libs now"
fi

if [ $DEBUGMODE -eq 1 ]; then
	mkdir tensorflow 2>/dev/null;
	cd tensorflow;
	echo "fake created tensorflow gitclone"
else
	if [[ ! -e $tfGitRoot/tensorflow/README.md ]]; then
		log INFO "Git Clone";
		echo "Cloning tensorflow from Github in $tfGitRoot..."
		mkdir -p $tfGitRoot;
		cd $tfGitRoot;
		git clone https://github.com/tensorflow/tensorflow
	else
		echo "NOT cloning from git"
#		ls
		cp workspace.bzl $tfGitRoot/tensorflow/tensorflow/
		cd $tfGitRoot;
		grep "nasm.us/pub/" ./tensorflow/tensorflow/workspace.bzl
	fi
	cd tensorflow;
	git checkout -- .
	log $INFO "Successfully cloned from git"
fi

export TF_ROOT=$tfGitRoot/tensorflow
export PYTHON_BIN_PATH=$(which python${python_version})
log $INFO "python bin path: "$PYTHON_BIN_PATH

if [ $use_virtualenv -eq 1 ]; then
	export PYTHON_LIB_PATH="$($PYTHON_BIN_PATH -c 'from distutils.sysconfig import get_python_lib; print(get_python_lib())')"
	log $INFO "venv python lib path: "$PYTHON_LIB_PATH
else
	export PYTHON_LIB_PATH="$($PYTHON_BIN_PATH -c 'import site; print(site.getsitepackages()[0])')"
	log $INFO "sys python lib path: "$PYTHON_LIB_PATH
fi

export PYTHONPATH=${TF_ROOT}/lib
export PYTHON_ARG=${TF_ROOT}/lib
export GCC_HOST_COMPILER_PATH=$(which gcc)
export CC_OPT_FLAGS="-march=native"

## Initial values, will actually be set up in the next block
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

#dont change the following
export TF_DOWNLOAD_MKL=0
export TF_DOWNLOAD_CLANG=0

# other TF compilation variables
export TF_SET_ANDROID_WORKSPACE=0
export TF_CONFIGURE_ANDROID=0
export TF_ENABLE_XLA=0
export TF_NEED_GCP=0
export TF_NEED_GDR=0
export TF_NEED_HDFS=0
export TF_NEED_JEMALLOC=0
export TF_NEED_KAFKA=0
export TF_NEED_MPI=0
export TF_NEED_OPENCL_SYCL=0
export TF_NEED_S3=0
export TF_NEED_TENSORRT=0
export TF_NEED_VERBS=0

case $3 in 
	"--clean")
	if [ $DEBUGMODE -eq 1 ]; then 
		echo "bazel clean"
	else
		log $INFO "executing bazel-clean because: "$3
		bazel clean;
	fi
	;;
	"--configure-only")
	if [ $DEBUGMODE -eq 1 ]; then 
		echo "./configure"
	else
		log $INFO "executing ./configure because: "$3
		./configure
	fi
	;;
	"--reconfigure")
	if [ $DEBUGMODE -eq 1 ]; then 
		echo "bazel clean; configure"
	else
		log $INFO "executing bazel clean: "$3
		bazel clean;
		log $INFO "executing ./configure: "$3
		./configure
	fi
	;;
	"--build-only")
	if [ $DEBUGMODE -eq 1 ]; then 
		echo "bazel build"
	else
		log $INFO "executing bazel build because: "$3
		_bazel_build
	fi
	;;
	"--build-and-wheel")
	if [ $DEBUGMODE -eq 1 ]; then 
		echo "bazel build; bazel-bin"
	else
		log $INFO "executing bazel build;wheel because: "$3
		log $INFO "bazel build: "$3
		_bazel_build;
		log $INFO "bazel-bin: "$3
		bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
	fi
	;;
	"--build-and-install")
	if [ $DEBUGMODE -eq 1 ]; then 
		echo "bazel build; bazel-bin; $venv_prefix pip insall"
	else
		log $INFO "executing bazel build;wheel because: "$3
		log $INFO "bazel build: "$3
		_bazel_build;
		log $INFO "bazel-bin: "$3
		bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
		log $INFO "pip install: "$3
		$venv_prefix pip$python_version install --upgrade --ignore-installed /tmp/tensorflow_pkg/tensorflow*.whl
	fi
	;;
	"--wheel-and-install")
	if [ $DEBUGMODE -eq 1 ]; then 
		echo "bazel-bin; $venv_prefix pip insall"
	else
		log $INFO "executing bazel-bin; pip install because: "$3
		log $INFO "bazel-bin: "$3
		bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
		log $INFO "pip install: "$3
		$venv_prefix pip$python_version install --upgrade --ignore-installed /tmp/tensorflow_pkg/tensorflow*.whl
	fi
	;;
	"--pip-install-only")
	if [ $DEBUGMODE -eq 1 ]; then 
		echo "$venv_prefix pip insall"
	else
		log $INFO "pip install, because: "$3
		$venv_prefix pip$python_version install --upgrade --ignore-installed /tmp/tensorflow_pkg/tensorflow*.whl
	fi
	;;
	"--all")
	if [ $DEBUGMODE -eq 1 ]; then 
		echo "bazel clean; ./configure; bazel build; bazel-bin; $venv_prefix pip insall"
	else
		log $INFO "executing EVERYTHING because: "$3
		bazel clean;
		log $INFO "./configure: "$3
		./configure;
		log $INFO "bazel-build: "$3
		_bazel_build;
		log $INFO "bazel-wheel: "$3
		bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
		log $INFO "pip install: "$3
		$venv_prefix pip$python_version install --upgrade --ignore-installed /tmp/tensorflow_pkg/tensorflow*.whl
	fi
	;;
	*)
	log $ERROR "FATAL: Misunderstood compilation steps, value: $3"
	echo "Argument $3 not understood, exiting"
	exit
	;;
esac
if [ -e /tmp/tensorflow_pkg ]; then
	if [ `sudo cp /tmp/tensorflow_pkg/tensorflow*.whl "$startDir" 2>/dev/null` ]; then
		log $INFO "Backing up tensorflow whl!"
		echo "Your tensorflow.whl file that was built, has been backuped in $startDir!"
	else
		echo "Did NOT back up tensorflow.whl. It may not be present in /tmp/tensorflow_pkg/"
	fi
else
	echo "the path /tmp/tensorflow_pkg/ does not seem to exist. huh."
fi
log $INFO "running tensorflow test script!"
cd "$startDir"
python$python_version convolutional_test.py
exit
