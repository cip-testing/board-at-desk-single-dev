#! /bin/sh
# Copyright (C) 2016, Siemens AG, Wolfgang Mauerer <wolfgang.mauerer@siemens.com>
# Copyright (C) 2017 Linux Foundation
# Authors: Don Brown <don.brown@codethink.co.uk>,
#          Wolfgang Mauerer <wolfgang.mauerer@siemens.com>
# SPDX-License-Identifier:	AGPL-3.0
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

# Install kernelci frontend
echo "START: install_frontend.sh"

set -e

cd $HOME/git-repos
git clone https://github.com/kernelci/kernelci-frontend-config.git kernelci-frontend

TOKEN=`cat $HOME/backend-admin-token.txt`
cat /vagrant/config/secrets-frontend.yml | sed -e "s/TOKEN/${TOKEN}/" \
    > kernelci-frontend/secrets.yml

cd kernelci-frontend
sed -i group_vars/all -e 's/^role: production/role: atdesk/'

set +e
ansible-playbook -i hosts site.yml -l local -c local -K -D \
                 -e secrets.yml -e "@secrets.yml"
# TODO: Fix error during the first run (second run succeeds deterministically)
set -e
ansible-playbook -i hosts site.yml -l local -c local -K -D \
                 -e secrets.yml -e "@secrets.yml"

# set up token for frontend
sudo sed -i /srv/kernelci-frontend/app/dashboard/default_settings.py -e 's/^BACKEND_TOKEN = None/BACKEND_TOKEN = \'${TOKEN}\'/'
sudo sed -i /srv/kernelci-frontend/app/dashboard/default_settings.py -e 's/^SECRET_KEY = None/SECRET_KEY = \'${TOKEN}\'/'

# set up build area
sudo mkdir -p /var/www/images
sudo chown -R www-data.www-data /var/www

echo "END: install_frontend.sh"
