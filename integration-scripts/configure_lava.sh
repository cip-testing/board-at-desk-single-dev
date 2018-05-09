#! /bin/sh
# Copyright (C) 2018, Codethink, Ltd., Robert Marshall <robert.marshall@codethink.co.uk>
# Copyright (C) 2017, Codethink, Ltd., Don Brown <codethink@codethink.co.uk>
# SPDX-License-Identifier:	AGPL-3.0
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

# Configure Lava Server (V2 or "pipeline" jobs only)
echo "START: configure_lava.sh"

set -e

#BugFix: tftp error - set TFTP_DIRECTORY="/var/lib/lava/dispatcher/tmp/"
sudo sed -ie 's/srv\/tftp/var\/lib\/lava\/dispatcher\/tmp/g' /etc/default/tftpd-hpa

# QEMU

# Add a Device Type qemu and Device qemu01 for the QEMU VM
cd /etc/lava-server/dispatcher-config/device-types/
sudo DEBIAN_FRONTEND=noninteractive lava-server manage device-types add qemu 
sudo DEBIAN_FRONTEND=noninteractive lava-server manage devices add --device-type qemu --worker $(hostname --long) qemu01
# Create the Device Dictionary file for a QEMU VM and store it in ~/myqemu.dat
cd ~
echo "{% extends 'qemu.jinja2' %}" > myqemu.dat 
echo "{% set no_kvm = True %}" >> myqemu.dat
echo "{% set mac_addr = '52:54:00:12:34:59' %}" >> myqemu.dat
echo "{% set memory = '1024' %}" >> myqemu.dat

# Import the QEMU Device Dictionary file into the LAVA2 Server
# needs authentication token setting up
sudo DEBIAN_FRONTEND=noninteractive cp myqemu.dat /etc/lava-server/dispatcher-config/devices/qemu01.jinja2
# lava-tool device-dictionary --update myqemu.dat http://lavauser@localhost:8080/RPC2 qemu01

# Beaglebone Black
# Add a Device Type beaglebone-black and Device bbb01 for the Beaglebone Black
cd /etc/lava-server/dispatcher-config/device-types/
sudo DEBIAN_FRONTEND=noninteractive lava-server manage device-types add beaglebone-black 
sudo DEBIAN_FRONTEND=noninteractive lava-server manage devices add --device-type beaglebone-black --worker $(hostname --long) bbb01

# Create the Device Dictionary file for the Beaglebone Black and store it in ~/mybbb.dat
cd ~
echo "{% extends 'beaglebone-black.jinja2' %}" > mybbb.dat
#echo "{% set connection_command = 'telnet localhost 8020' %}" >> mybbb.dat
echo "{% set connection_command = '/vagrant/scripts/connectBBB.sh 192.168.22.1 8020 root lavauser123' %}"  >> mybbb.dat

# Import the Beaglebone Black Device Dictionary file into the LAVA2 Server
# needs authentication token setting up
sudo DEBIAN_FRONTEND=noninteractive cp mybbb.dat /etc/lava-server/dispatcher-config/devices/bbb01.jinja2
# lava-tool device-dictionary --update mybbb.dat http://lavauser@localhost:8080/RPC2 bbb01

# Renesas iwg20m
sudo DEBIAN_FRONTEND=noninteractive cp -v /vagrant/device-types/renesas-iwg20m.jinja2 /etc/lava-server/dispatcher-config/device-types/
sudo DEBIAN_FRONTEND=noninteractive lava-server manage device-types add renesas-iwg20m
sudo DEBIAN_FRONTEND=noninteractive lava-server manage devices add --device-type renesas-iwg20m --worker $(hostname --long) iwg20m01
sudo DEBIAN_FRONTEND=noninteractive cp -v /vagrant/device-dictionary/myiwg20m.jinja2 /etc/lava-server/dispatcher-config/devices/iwg20m01.jinja2
cp -v /vagrant/device-dictionary/myiwg20m.jinja2 ~/myrenesas.dat

# set permissions on the devices/device types
sudo DEBIAN_FRONTEND=noninteractive chown lavaserver.lavaserver /etc/lava-server/dispatcher-config/devices/*
sudo DEBIAN_FRONTEND=noninteractive chown lavaserver.lavaserver /etc/lava-server/dispatcher-config/device-types/*

echo "END: configure_lava.sh"
