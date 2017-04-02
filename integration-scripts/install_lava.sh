#! /bin/sh
# Copyright (C) 2016, Codethink, Ltd., Don Brown <don.brown@codethink.co.uk>
# SPDX-License-Identifier:	AGPL-3.0
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.


# Install LAVA v2

set -e

# Stop nginx
sudo DEBIAN_FRONTEND=noninteractive systemctl stop nginx.service

# Add jessie-backports repository
echo "deb http://http.debian.net/debian jessie-backports main" | sudo DEBIAN_FRONTEND=noninteractive tee -a /etc/apt/sources.list

# Update the system
sudo DEBIAN_FRONTEND=noninteractive apt-get -y update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

# Install postgresql & tftp
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install postgresql tftp

# Install qemu, KVM & LAVA
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install qemu-kvm libvirt-bin lava

# Add the vagrant user to the libvirtd and kvm groups
sudo DEBIAN_FRONTEND=noninteractive usermod -a -G libvirt,kvm vagrant

# Configure Apache web server & restart the apache2 service
sudo DEBIAN_FRONTEND=noninteractive a2dissite 000-default
sudo DEBIAN_FRONTEND=noninteractive a2enmod proxy
sudo DEBIAN_FRONTEND=noninteractive a2enmod proxy_http
sudo DEBIAN_FRONTEND=noninteractive a2ensite lava-server.conf
sudo DEBIAN_FRONTEND=noninteractive service apache2 restart

# Start nginx
sudo DEBIAN_FRONTEND=noninteractive systemctl start nginx.service

cd ~
