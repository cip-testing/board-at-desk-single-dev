#! /bin/sh
# Copyright (C) 2016, Codethink, Ltd., Don Brown <don.brown@codethink.co.uk>
# SPDX-License-Identifier:	Apache-2.0
# Install LAVA v2

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