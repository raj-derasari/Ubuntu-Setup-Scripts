# You can set up your own variables, values here in the config files
# I provide 3 config files by default; you can create your own based on these templates
# All you have to do is set 0s and 1s and some names here and there :D

## -------------------------------------------------------------------------------------------------------------------
### CONFIGURATION FILE
### INDEX:
### 0. USER BASHRC PROFILE AND USER TEMPLATES SETUP
### 1. GITHUB SETUP
### 2. VIRTUALENV SETUP
### 3. MASTER SETUP - Select if you want to install software/remove bloatware/setup python/etc.
### 4. SOFTWARE TOOLS SETUP - RECOMMENDED UTILITIES
### 5. SOFTWARE TOOLS SETUP - WEB BROWSERS
### 6. SOFTWARE TOOLS SETUP - HANDY TOOLS
### 7. SOFTWARE TOOLS SETUP - LIBREOFFICE SUITE
### 8. PROGRAMMING TOOLS - DOCKER
### 9. PROGRAMMING TOOLS - JAVA/JDK
### 10. PROGRAMMING TOOLS - IDE
### 11. PYTHON SETUP - VERSION, LIBRARIES SELECTION
### 12. PYTHON SETUP - TENSORFLOW COMPILATION/INSTALLATION
## -------------------------------------------------------------------------------------------------------------------

### 0. BASHRC AND TEMPLATES
## -------------------------------------------------------------------------------------------------------------------
# Your bashrc profile file - Most installations will come with this
export USER_HOME=~
# If you are working with LIVE ISO customization like me
#export USER_HOME=~
export BF=${USER_HOME}/.bashrc
# You can set this next line to 0 to not copy-paste templates from the templates.zip file in the project
export Setup_Templates=1

### 1. GITHUB
## -------------------------------------------------------------------------------------------------------------------
# Github setup - This is independent of every other installation given above
export Install_Git=1
export Setup_Git_Aliases=1
export Setup_Git_SSHKeys=0
# IF you set this as 1, you will have to enter your email and name in Git_Email and Git_YourName
# Remember to unset this to some random values, or delete this file when done (If you are sharing the file, to save your data)
export Git_Email="user.name@example.com"
export Git_YourName="User Name"
# Path to your github ssh-key (Enter a private key path below, the public key will be saved as {private_key}+".pub'
export Github_SSH_File=${USER_HOME}/.ssh/github_key

### 2. VIRTUALENV SETUP
## -------------------------------------------------------------------------------------------------------------------
# virtualenv - if you are using Ubuntu 18 or above, it is highly recommended to use virtualenv with Python3 - And ditch Python2!
export Setup_VirtualEnv=1

# if 1 above, consider setting up the next two parameters
export VirtualEnv_Name="venv1"
export VirtualEnv_Directory=${USER_HOME}/.virtualenvs/$VirtualEnv_Name

### 3. MASTER SETUP - REQUIRED TO SET EITHER 1 OR 0 HERE
## -------------------------------------------------------------------------------------------------------------------
# Dependencies and Libraries - Highly recommended keep this as 1
export Master_Dependencies=1
# Bloatware removal script that checks your Desktop Environment and uninstalls bloatware based on that
export Master_RemoveBloatware=1
export Bloatware_Remove_Themes=1
export Bloatware_Remove_LanguagePacks=1
# Software setup script - Common Software, Java, Programming Tools, etc.
export Master_Software=1
# Python Libraries setup - For Python 2/3 Development, Both are supported.
export Master_Python=1
# Executes sudo apt-get upgrade after installing software
export Do_AptGetUpgradeLast=1
# cleans up your /tmp, pip cache and 
export Do_CleanupAfterExec=1

### 4. SOFTWARE TOOLS SETUP - RECOMMENDED UTILITIES
## -------------------------------------------------------------------------------------------------------------------
# Strongly recommended packages
# All of the following are affected based on the value of Master_Software being 1
# ExFat file system utilites
export Install_EXFatUtils=1
# Flatpak is a software and package installation utility which will be meta real soon
export Install_Flatpak=1
# Flux is recommended for users evening/night times.
export Install_Flux=1
# Gparted is a partition utility which is highly useful, and most recommended
export Install_GParted=1
# Graphical Firewall configuration Utility
export Install_GUFW=1
# 7-zip and other archive types support (Not a GUI, integrates with default archive applications)
export Install_P7Zip=1
# QPAEQ and PulseAudioEqualizer are utilities to work as audio equalizers for system/all output sounds
export Install_PulseAudioEqualizer=1
# Torrent Client
export Install_QBitTorrent=1
# PDF Viewer which is incredibly fast and lightweight
export Install_QPDFView=1
# slurm is a network usage monitoring utility
export Install_Slurm=1
# Thunderbird is an email client
export Install_Thunderbird=1
# Uget is a download manager
export Install_UGET=1
# VLC is the go-to media player for Linux, with various alternatives (however, I recommend VLC)
export Install_VLCMediaPlayer=1
# Z-shell, alternative for bash
export Install_ZSH=0

### 5. SOFTWARE TOOLS SETUP - WEB BROWSERS
## -------------------------------------------------------------------------------------------------------------------
# Choose a web browser
export Install_Chromium=1
export Install_GoogleChrome=1
export Install_MozillaFirefox=1
export Install_Vivaldi=1

### 6. SOFTWARE TOOLS SETUP - HANDY TOOLS
## -------------------------------------------------------------------------------------------------------------------
# Audacity is an audio editing application, you can also choose to install the FFMpeg library in the second option
export Install_Audacity=1
export Install_WinFF=1
# grive is an open source, third-party, command line Google-Drive tool.
export Install_Grive_GoogleDrive=1
# keepass password manager, for all your random password needs!
export Install_KeepassPasswordManager=1
# Teamviewer is a remoting software, you probably knew that already didn't ya?
export Install_TeamViewer=1
# Okular is a heavy-featured PDF Suite
export Install_Okular=0
# Terminal client/replacement for ctrl+alt+t
export Install_TildaTmux=0
# TexStudio is LaTeX software for writing up college assignments and research papers
# It's most likely not going to be used anywhere else
# Why am I even installing it I'm not even in college right now...
export Install_TexStudio=0
## -------------------------------------------------------------------------------------------------------------------
## TODO, haven't done these yet.
# Terminal management, Kinda like Tmux/Tilda
export Install_BYOBU=0
# a python coding environment. Alternative - Spyder
export Install_PyCharm=0
# Another remoting software solution - The RealVNC server does not work on Ubuntu from my attempts
# But you can definitely connect to your RealVNC Server on a remote Windows installation via this tool
# That is to say, RealVNC Viewer on Linux works fine!
export Install_RealVNC=0

### 7. SOFTWARE TOOLS SETUP - LIBREOFFICE SUITE
## -------------------------------------------------------------------------------------------------------------------
# Libre Office
export Install_LibreOffice=0
# Base is like MS Access, database software
export LibreOffice_Base=1
# Draw is for .. drawing?
export LibreOffice_Draw=0
# Impress is Presentation software
export LibreOffice_Impress=1
# Math is Workboot/Spreadsheet software
export LibreOffice_Math=1
# Calc is like MS Excel, spreadsheet software
export LibreOffice_Calc=1
# Writer is a document software
export LibreOffice_Writer=1

### 8. PROGRAMMING TOOLS - DOCKER
## -------------------------------------------------------------------------------------------------------------------
# Docker - If you select one, the docker installation script will be executed
# Be careful, because the script does a complete reinstall of any existing Docker installation
export Install_Docker=0
export Docker_Remove_SUDO=0

### 9. PROGRAMMING TOOLS - JAVA/JDK
## -------------------------------------------------------------------------------------------------------------------
# Java SE and JDK - They come combined together in Java 10
export Install_Oracle_Java=0
## JAVA VERSION - I allow 2 possible values - 8 and 10. IF oracle keeps their naming scheme
## for the packages oracle-java(X)-installer and oracle-java(X)-set-default; then
## this script may work in the future too. For now, it is confirmed to work for Java 8 and Java 10
## IF you are installing a version other than 8 or 10, please be careful about setting Purge_OpenJDK to 1
export Install_Java_Version=10
# This line uninstalls any inbuilt Java that comes with your Ubuntu/Debian installation
export Purge_OpenJDK=0

### 10. PROGRAMMING TOOLS - IDE
## -------------------------------------------------------------------------------------------------------------------
# Gedit is a regular text editor but can be quite handy
export Install_Emacs=0
export Install_GEdit=0
# Atom is one of the programming tools I provide - Handy IDE
# From my experience, apt-install atom will be a PRETTY SLOW DOWNLOAD
export Install_Atom=0
# Lightweight alternative to Atom - Sublime Text (Free Edition)
export Install_SublimeText=1
# VS Code is also a great programming IDE
export Install_VisualStudioCode=0
## TODO: Add emacs here, and... anything else?

## Scientific Coding "IDE" hah
# GNU/Octave is an open-source MATLAB alternative.
# TODO: IF possible, install the Octave Sourceforge packages directly via this script.
export Install_Octave=0

## Scientific Coding "IDE" hah
# R studio and R are open source tools
# TODO: havent implemented
export Install_R_Base=0
export Install_R_Base_Version=3.5
export Install_R_Studio=0

### 11. PYTHON SETUP - VERSION, LIBRARIES SELECTION
## -------------------------------------------------------------------------------------------------------------------
## Python Setup - installing python libraries
# setting up python-dev tools
export Setup_Python_Dev=1

# set one value from 2 and 3
export Python_PreferredVersion=3

# basic libraries - Numpy, scipy, etc. stuff that you'll most likely need
export Python_InstallBasics=1

# This includes web-dev tools 
export Python_InstallWebDevelopmentTools=1

# the DJANGO framework and some aliases that make migrating and running your server easier
export Python_InstallDjango=0

# Jupyter Notebook, because it's a pretty handy tool
export Python_InstallJupyter=0

# some OpenCV stuff that I haven't coded yet - there are scripts for it already.
# if you need it check out this cool repository:
#	https://github.com/jayrambhia/Install-OpenCV
# or if you do not want that, try this search!
#	https://github.com/search?q=opencv+install+script
export Python_InstallComputerGraphicsTools=0    ## TODO, not implemented

# NLTK if you're into it
export Python_InstallNLTK=0

# Installs ML tools - theano (Not Thanos), Tensorflow, Keras, etc - you can select your own tensorflow below if you want to
# but to have tensorflow installed the next variable must definitely be 1
# Must set to 1 if you want to install tensorflow!
export Python_InstallMachineLearningTools=0

### 12. PYTHON SETUP - TENSORFLOW COMPILATION/INSTALLATION
## -------------------------------------------------------------------------------------------------------------------
## Tensorflow compilation script - If you'd like a custom tensorflow installation
## and if you have a machine that can compile tensorflow;
## then you can select 1 below and choose any modes (CPU, CUDA/GPU, Intel MKL)
## -------------------------------------------------------------------------------------------------------------------
export Python_Compile_Tensorflow=0
## Select one of the next 3 as 1, if you don't select any of them as 1
## I will be really sad :(
## allowed values: cpu, gpu, mkl - Case sensitive (probably)
export Python_Tensorflow_Target=cpu