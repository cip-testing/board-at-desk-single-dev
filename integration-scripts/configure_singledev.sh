#! /bin/sh
# Copyright (C) 2017, Codethink, Ltd., Don Brown <don.brown@codethink.co.uk>
# SPDX-License-Identifier:	Apache-2.0
# Configure KernelCI for 'Single Developer at Desk with Board' Use Case
echo "START: configure_singledev.sh"

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

# Start the KernelCI webserver to run in the background
/vagrant/scripts/start_webserver.sh &

echo "END: configure_singledev.sh"
