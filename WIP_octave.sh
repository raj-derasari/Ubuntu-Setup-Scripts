DRY_MODE=0
dry_echo=""

# argv will be commdline arg inside .m files
if [ "$1" = "-D" ] || [ "$1" = "--dry-run" ]; then
	echo "Running octave setup in dry mode!"
	DRY_MODE=1
	dry_echo="echo "
fi

_pkg_list() {
	$dry_echo octave-cli --eval "pkg list"
}
_install_() {
	$dry_echo octave-cli --eval "pkg install -forge ${*}"
}
_uninstall_() {
	$dry_echo octave-cli --eval "pkg uninstall ${*}"
}

_install_and_disp_()
{
	echo "--------------------------------------------------------"
	echo "$1"
	echo "--------------------------------------------------------"
	_install_ $1
	#_uninstall_ $1
	_pkg_list
}
## First install the core packages that make octave what it is
#echo "The very basic packages, that make octave what it is:"
# no dependencies, base packages
#_install_and_disp_ cgi
#_install_and_disp_ general
#_install_and_disp_ io
#_install_and_disp_ struct
## compilaiton error while cmake mpi
##_install_and_disp_ mpi
#_install_and_disp_ sockets
#_install_and_disp_ strings
#_install_and_disp_ symbolic
#_install_and_disp_ dataframe
#_install_and_disp_ doctest
#_install_and_disp_ linear-algebra
#_install_and_disp_ generate_html
#_install_and_disp_ geometry
## GSL package NAME exists but no index (url) so couldnt download/install
##_install_and_disp_ gsl

#_install_and_disp_ communications

# # error running the configuration script for dicom, fem-fenics
# _install_and_disp_ dicom
# _install_and_disp_ fem-fenics

### Other stuff based on previous stuff

## general dependency
## compiling miscellaenous failed
#_install_and_disp_ miscellaneous

## control dependency
#_install_and_disp_ control
#_install_and_disp_ signal
## compiling communications failed
#_install_and_disp_ communications

## struct dependency
#_install_and_disp_ parallel
# didnt install, parallel did work though
#_install_and_disp_ database

## io dependency
##works
#_install_and_disp_ financial
##works
#_install_and_disp_ statistics

#needs struct and statistics
##works
#_install_and_disp_ optim
##works
#_install_and_disp_ optiminterp

## optim dependency
##works
#_install_and_disp_ data-smoothing
##works
#_install_and_disp_ econometrics


### no dependencies, but highly specific usecases
##works
#_install_and_disp_ fuzzy-logic-toolkit
##works
#_install_and_disp_ ga
# works
#_install_and_disp_ image
#doesn't configure
#_install_and_disp_ image-acquisition
#works
#_install_and_disp_ instrument-control
#doesn't configure
#_install_and_disp_ interval
#works
#_install_and_disp_ level-set
#works
#_install_and_disp_ lssa
#works
#_install_and_disp_ mapping
#works
#_install_and_disp_ mvn
#doesnt configure
#_install_and_disp_ netcdf
#works
#_install_and_disp_ optics
#doesnt work, octave version too old, wat
#_install_and_disp_ sparsersb
#works
#_install_and_disp_ splines
# doesnt work
#_install_and_disp_ video
#works
#_install_and_disp_ windows
#doesnt compile
#_install_and_disp_ zeromq
#worked
#_install_and_disp_ quaternion
#worked
#_install_and_disp_ queueing

### Highly specific packages, but with dependencies
## arduino needs instrument-control
#worked
# _install_and_disp_ arduino
#needs  linear-algebra miscellaneous struct statistics
# if no misecellaneous, wont compile duh
#_install_and_disp_ vrml


### Third-party packages, may have dependencies, upto you
# for working with NAN variables (blank values)
#_install_and_disp_ nan
# for solving DC/AC equations
# needs odepkg
#_install_and_disp_ ocs
# for freq/time analysis in signals processing
# worked fine
#_install_and_disp_ ltfat
