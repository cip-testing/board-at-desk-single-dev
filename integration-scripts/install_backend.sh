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
# test whether the tmphosts marker file is already created
if [ -f ~/git-repos/kernelci-backend/tmphosts ] ; then
# install backend partially done, continuing..
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

    # with stretch an explicit install of bc is required
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install bc
    rm ~/git-repos/kernelci-backend/tmphosts
    echo "END: install_backend.sh"
    # move onto the next provisioning stage
    exit 0

fi

cd $HOME && mkdir git-repos && cd git-repos
git clone https://github.com/kernelci/kernelci-backend-config.git kernelci-backend

sudo DEBIAN_FRONTEND=noninteractive apt-get -y install nginx nginx-extras

cp /vagrant/config/secrets-backend.yml kernelci-backend/secrets.yml

# Fixme: Don't let ansible try to create the file in the first place.
if [ ! -d /etc/sysfs.d/ ]; then
    sudo mkdir /etc/sysfs.d
fi
sudo touch /etc/sysfs.d/99-thp-defrag.conf

cd kernelci-backend
# Use port 80 for apt-key to prevent problems when running behind a web proxy
sed -i 's/hkp:\/\/keyserver.ubuntu.com/hkp:\/\/keyserver.ubuntu.com:80/g' roles/install-deps/tasks/install-mongodb.yml
echo "storage_certname: localhost" >> group_vars/all
sed -i group_vars/all -e 's/hostname: kernelci-backend/hostname: localhost/'

cat > tmphosts  <<EOF
[dev]
# this machine will be managed directly via root
localhost ansible_ssh_user=root
[rec]
# this machine will be managed via the user admin becoming root via "su"
localhost ansible_ssh_user=admin become_method=su
[prod]
# this machine will be managed via the user admin using sudo
localhost ansible_ssh_user=admin become_method=sudo
EOF

sudo mkdir -p /etc/ansible
sudo DEBIAN_FRONTEND=noninteractive bash -c "cat tmphosts >> /etc/ansible/hosts"
 

set +e
ansible-playbook -i hosts site.yml -l local -c local -K -e "@secrets.yml" \
                 -e "@secrets.yml" --skip-tags=backup,firewall,web-server
# TODO: Fix error during the first run (second run succeeds deterministically)
set -e
# TODO: This asks for a sudo password, which we need to provide non-interactively
ansible-playbook -i hosts site.yml -l local -c local -K -e "@secrets.yml" \
                 -e "@secrets.yml" --skip-tags=backup,firewall,web-server

# with stretch a install of net-tools for netstat is required
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install net-tools

sudo sed -i 's/^[ ]*ssl/    # ssl/' /etc/nginx/sites-enabled/storage.kernelci.org.conf
sudo sed -i 's/resolver False/# resolver False/' /etc/nginx/sites-enabled/storage.kernelci.org.conf


echo now run 'vagrant halt; vagrant up; vagrant provision; '
echo 'to complete b@d provisioning'
exit 1

