#! /bin/sh
# Copyright (C) 2016, Siemens AG, Wolfgang Mauerer <wolfgang.mauerer@siemens.com>
# SPDX-License-Identifier:	Apache-2.0
# Install kernelci backend
echo "START: install_backend.sh"

cd $HOME && mkdir git-repos && cd git-repos
git clone https://github.com/kernelci/kernelci-backend-config.git kernelci-backend
cd kernelci-backend

#commit 00bded1b69fa6233daf2837f383b5279acc21c44
#Author: Milo Casagrande <milo.casagrande@linaro.org>
#Date:   Mon Dec 12 18:10:41 2016 +0100
#
#    Fix nginx configuration
#
git checkout 00bded1b69fa6233daf2837f383b5279acc21c44
cd ..
cp /vagrant/config/secrets-backend.yml kernelci-backend/secrets.yml

# Fixme: Don't let ansible try to create the file in the first place.
if [ ! -d /etc/sysfs.d/ ]; then
    sudo mkdir /etc/sysfs.d
fi
sudo touch /etc/sysfs.d/99-thp-defrag.conf

# TODO: This asks for a sudo password, which we need to provide non-interactively
cd kernelci-backend
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
