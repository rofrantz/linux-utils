#!/bin/sh

confirm () {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

echo

RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

atLeastNthKenrnelVersions=1	# number of kerner versions to keep for backup
currentKernel=`uname -r`
oldKernels=`dpkg -l | grep ^ii | grep -E -o "linux-image-([0-9]+.)+\w+" | grep -Fv $currentKernel | tail -n +$(($atLeastNthKenrnelVersions + 1))`

countOldKernels=$(echo $oldKernels | wc -w)

if [ $countOldKernels = 0 ]; then
    echo "No kernel headers need to be purged. Keeping current version ${RED}${currentKernel}${NC}"
else
    echo "\nThe following ${countOldKernels} old kernel header(s) will be removed while version ${RED}${currentKernel}${NC} will be kept:\n"
    for kernel in $oldKernels
    do
        echo "  - ${BLUE}${kernel}${NC}"
    done
    echo

    if confirm "Are you sure you want to purge the following ${countOldKernels} old kernel header(s) [y/N] ?"; then
        apt-get purge --assume-yes $oldKernels
        update grub
    fi
fi

echo
