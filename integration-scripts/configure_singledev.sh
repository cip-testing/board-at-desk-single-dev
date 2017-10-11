#! /bin/sh
# Copyright (C) 2017, Codethink, Ltd., Don Brown <codethink@codethink.co.uk>
# SPDX-License-Identifier:	AGPL-3.0
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

# Configure KernelCI for 'Single Developer at Desk with Board' Use Case
echo "START: configure_singledev.sh"

set -e

# To make KernelCI Server available to host machine
# Add host to /srv/kernelci-frontend/app/server.py
sudo sed -ie 's/app.run(thread/app.run(host='\''0.0.0.0'\'', thread/g' /srv/kernelci-frontend/app/server.py

# Set default ports to 81
sudo sed -ie '/listen/s/\*/\*:81/' /etc/nginx/nginx.conf
sudo sed -ie '/listen/s/\[::\]/\[::\]:81/' /etc/nginx/nginx.conf

# To Make KernelCI use the local machine for the "KernelCI Storage Server"
# 1. Add this line in Vagrantfile, where ports are forwarded:
# Make FILE_SERVER_URL point to 'http://localhost:8010/' instead of 'localhost'.
sudo sed -ie "/FILE_SERVER_URL/s/localhost/http:\/\/localhost:8010\//g" /etc/linaro/kernelci-frontend.cfg

# 2. The first is /etc/linaro/kernelci-frontend.cfg:
# Make FILE_SERVER_URL point to "http://127.0.0.1:8010/" instead of "127.0.0.1".
sudo sed -ie "/FILE_SERVER_URL/s/127.0.0.1/127.0.0.1:8010/g" /srv/kernelci-frontend/app/dashboard/default_settings.py

# Comment out listen 80 lines in /etc/nginx/sites-available/default to avoid port 80 conflict
sudo sed -ie '/#/!s/listen/# listen/g' /etc/nginx/sites-available/default

# 3. Run the fileserver from the directory that has the build.log, kernel.config, system.map, zImage and dtbs:
sudo mkdir /var/www/images/kernel-ci
sudo chown www-data:www-data /var/www/images/kernel-ci

# Storage Server runs under Nginx per /etc/nginx/conf.d/local-storage-server.conf
sudo cp /vagrant/scripts/local-storage-server.conf /etc/nginx/conf.d/

# Will need to be restarted when kernel is built
# Start the KernelCI webserver to run in the background
#/vagrant/scripts/start_webserver.sh &

# Add port 8020 to the ser2net to connect to the Beaglebone Black over telnet & Restart ser2net daemon
echo "8020:telnet:0:/dev/ttyUSB0:115200 8DATABITS NONE 1STOPBIT banner" | sudo DEBIAN_FRONTEND=noninteractive tee -a /etc/ser2net.conf
sudo systemctl restart ser2net.service

echo "END: configure_singledev.sh"
