## SET YOUR TENSORFLOW CONFIGURATION HERE:

## BTW - This script/configuration of Tensorflow is basically a beta-version because
# I have only tested CPU,GPU compilations and an MKL compilation after installing Intel MKL
# In all my installations, the last set of variables (from Android... TensorRT) were set as 0
# So if you configure Tensorflow with any of these as 1; It is possible that it may not compile
# CUDA COMPUTE CAPABILITY of your GPU must be enterred -- IF you are building for NVIDIA GPU
export TF_CUDA_COMPUTE_CAPABILITIES=6

## if you don't have java installed, it will be installed in the script
## supported values; 8 and 10
export TF_JAVA_VERSION=10

# path where tensorflow is downloaded from github
## best to use an absolute/complete path here
tfGitRoot=${HOME}/SetupScript/tensorflow_source

## other TF variables - Not sure how it does whatever it does, Never used these
export TF_DOWNLOAD_MKL=0
export TF_DOWNLOAD_CLANG=0

# other TF compilation variables
export TF_SET_ANDROID_WORKSPACE=0
export TF_CONFIGURE_ANDROID=0
export TF_ENABLE_XLA=0
export TF_NEED_AWS=0
export TF_NEED_GCP=0
export TF_NEED_GDR=0
export TF_NEED_HDFS=0
export TF_NEED_JEMALLOC=0
export TF_NEED_KAFKA=0
export TF_NEED_MPI=0
export TF_NEED_NGRAPH=0
export TF_NEED_OPENCL_SYCL=0
export TF_NEED_S3=0
export TF_NEED_TENSORRT=0
export TF_NEED_VERBS=0
export TF_NEED_RTCOM=0