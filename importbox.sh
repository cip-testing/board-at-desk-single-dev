#!/bin/sh
# check parameter
if [ $# -ne 1 ] ; then
	echo "Usage: $0 boxLocation" >&2
	exit 1
fi
box=$1
# make directory (what if it exists?)
#dir=importBox
#mkdir $dir
#cd $dir
# importedBox is another parameter
vagrant box add importedBox $1
if [ ! -f Vagrantfile ] ; then
    vagrant init importedBox
    git clone https://gitlab.com/cip-project/board-at-desk-single-dev.git
    rm Vagrantfile
    cp board-at-desk-single-dev/Vagrantfile .
else
    mv -f Vagrantfile Vagrantfile-tmp
    vagrant init importedBox
    mv Vagrantfile-tmp Vagrantfile
fi    
# are any mods necessary?
vagrant up
echo new KernelCI board at desk ready for use
# in $dir
