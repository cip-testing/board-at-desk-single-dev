#! /bin/sh
# Copyright (C) 2017, Codethink, Ltd., Robert Marshall <robert.marshall@codethink.co.uk>
# SPDX-License-Identifier:	Apache-2.0
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

# check we're in initramfs
wdir=`pwd`
locn=`basename $wdir`
if [ $locn != "initramfs" ]; then
    echo this script must be run from the initramfs directory
    exit 1
fi
# create /dev and special files
mkdir dev

sudo mknod dev/console c 5 1
sudo mknod dev/null c 1 3
sudo mknod dev/zero c 1 5

# populate /lib
mkdir lib usr/lib

rsync -a /usr/arm-linux-gnueabihf/lib/ ./lib/
rsync -a /usr/arm-linux-gnueabihf/lib/ ./usr/lib/

# add mount points
mkdir proc sys root
# /etc and configuration files
mkdir etc

echo "null::sysinit:/bin/mount -a" > etc/inittab
echo "null::sysinit:/bin/hostname -F /etc/hostname" >> etc/inittab
echo "null::respawn:/bin/cttyhack /bin/login root" >> etc/inittab
echo "null::restart:/sbin/reboot" >> etc/inittab

echo "proc  /proc proc  defaults  0 0" > etc/fstab
echo "sysfs /sys  sysfs defaults  0 0" >> etc/fstab

echo  beagleboneblack > etc/hostname

echo "root::0:0:root:/root:/bin/sh" > etc/passwd

# NO!!! ??
wget https://gitlab.com/cip-project/cip-testing/testing/snippets/1666441 -O init
chmod +x init
#or?
ln -s sbin/init init

# create the initramfs?
find . -depth -print | cpio -ocvB | gzip -c > ../initramfs.cpio.gz
