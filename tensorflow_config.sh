## LOAD YOUR TENSORFLOW CONFIGURATION HERE:

# CUDA COMPUTE CAPABILITY of your GPU must be enterred -- IF you are building for NVIDIA GPU
export TF_CUDA_COMPUTE_CAPABILITIES=6

## if your pc doesn't have java, it will be installed here
## supported values; 8 and 10
export TF_JAVA_VERSION=10

# path where tensorflow is downloaded from github
## best to use an absolute/complete path here
tfGitRoot=~/SetupScript/tensorflow_source

## other TF variables, you probably wont be using them
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