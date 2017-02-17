#! /bin/sh
# Copyright (C) 2016, Siemens AG, Wolfgang Mauerer <wolfgang.mauerer@siemens.com>
# SPDX-License-Identifier:	Apache-2.0
echo "START: install_dependencies.sh"

#Add repositories
# Add Testing repository - main branch
echo "deb http://http.us.debian.org/debian testing main" | sudo DEBIAN_FRONTEND=noninteractive tee -a /etc/apt/sources.list
echo "deb-src http://http.us.debian.org/debian testing main" | sudo DEBIAN_FRONTEND=noninteractive tee -a /etc/apt/sources.list

# Add Architectures that you will be building
sudo DEBIAN_FRONTEND=noninteractive sudo dpkg --add-architecture armhf

# Update & upgrade the system
sudo DEBIAN_FRONTEND=noninteractive apt-get -y update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

# Install the dependencies
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install git python-pip python-dev python-concurrent.futures python-tornado libffi-dev libyaml-dev libssl-dev rng-tools python-requests ser2net telnet screen

# Install the ARM Toolchain
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install gcc-arm-linux-gnueabi gcc-arm-linux-gnueabihf

# Remove library 
sudo DEBIAN_FRONTEND=noninteractive apt-get -y remove libgnutls-deb0-28

# Install dependencies using pip
sudo -H DEBIAN_FRONTEND=noninteractive pip install --upgrade pip
sudo -H DEBIAN_FRONTEND=noninteractive pip install --upgrade cffi
sudo -H DEBIAN_FRONTEND=noninteractive pip install ansible
sudo -H DEBIAN_FRONTEND=noninteractive pip install markupsafe
sudo -H DEBIAN_FRONTEND=noninteractive pip install simplejson

# Start rngd service
sudo DEBIAN_FRONTEND=noninteractive rngd -r /dev/urandom &
echo "END: install_dependencies.sh"

