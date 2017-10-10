#! /bin/sh
# Copyright (C) 2016, Siemens AG, Wolfgang Mauerer <wolfgang.mauerer@siemens.com>
# Copyright (C) 2017 Linux Foundation
# Authors: Don Brown <codethink@codethink.co.uk>,
#          Wolfgang Mauerer <wolfgang.mauerer@siemens.com>
# SPDX-License-Identifier:	AGPL-3.0
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

# Install kernelci backend
echo "START: install_backend.sh"

set -e

cd $HOME && mkdir git-repos && cd git-repos
git clone https://github.com/kernelci/kernelci-backend-config.git kernelci-backend

# revert to using version of kernelci-backend that works without substantial changes for the release
cd kernelci-backend
git checkout 22eea06bce942980c9f0be2e5221e19f3b8fb6db
cd ..

cp /vagrant/config/secrets-backend.yml kernelci-backend/secrets.yml

# Fixme: Don't let ansible try to create the file in the first place.
if [ ! -d /etc/sysfs.d/ ]; then
    sudo mkdir /etc/sysfs.d
fi
sudo touch /etc/sysfs.d/99-thp-defrag.conf

cd kernelci-backend
# Use port 80 for apt-key to prevent problems when running behind a web proxy
sed -i 's/hkp:\/\/keyserver.ubuntu.com/hkp:\/\/keyserver.ubuntu.com:80/g' roles/install-deps/tasks/install-mongodb.yml
# TODO: This asks for a sudo password, which we need to provide non-interactively
ansible-playbook -i hosts site.yml -l local -c local -K -e "@secrets.yml" \
                 -e "@secrets.yml" --skip-tags=backup,firewall,web-server

# Make sure the backend REST service started to listen  on port 8888 before
# trying to obtain an admin session token
while netstat -lnt | awk '$4 ~ /:8888$/ {exit 1}'; do sleep 2; done

# Obtain the session token with admin privileges.
MASTER_KEY=`cat /vagrant/config/secrets-backend.yml | grep master_key | \
           awk '{print $2;}'`
TOKEN=`python /vagrant/scripts/get_admin_token.py ${MASTER_KEY}`
echo $TOKEN > $HOME/backend-admin-token.txt

# Create a configuration file for the build script
echo "[CIP-KernelCI]" > $HOME/.buildpy.cfg
echo "token=$TOKEN" >> $HOME/.buildpy.cfg
echo "url=http://localhost:8888" >> $HOME/.buildpy.cfg

echo "END: install_backend.sh"
