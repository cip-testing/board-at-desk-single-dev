#! /bin/sh
# Copyright (C) 2017, Codethink, Ltd., Don Brown <don.brown@codethink.co.uk>
# SPDX-License-Identifier:	AGPL-3.0
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

# Configure Lava Server (V2 or "pipeline" jobs only)

set -e

#BugFix: tftp error - set TFTP_DIRECTORY="/var/lib/lava/dispatcher/tmp/"
sudo sed -ie 's/srv\/tftp/var\/lib\/lava\/dispatcher\/tmp/g' /etc/default/tftpd-hpa

# QEMU
# Copy latest qemu.jinja2 file to /etc/lava-server/dispatcher-config/device-types/
sudo DEBIAN_FRONTEND=noninteractive cp -v /vagrant/device-types/qemu.jinja2 /etc/lava-server/dispatcher-config/device-types/

# Add a Device Type qemu and Device qemu01 for the QEMU VM
cd /etc/lava-server/dispatcher-config/device-types/
sudo DEBIAN_FRONTEND=noninteractive lava-server manage add-device-type qemu 
sudo DEBIAN_FRONTEND=noninteractive lava-server manage add-device --device-type qemu qemu01 --worker jessie.raw

# Create the Device Dictionary file for a QEMU VM and store it in ~/myqemu.dat
cd ~
echo "{% extends 'qemu.jinja2' %}" > myqemu.dat 
echo "{% set no_kvm = True %}" >> myqemu.dat
echo "{% set mac_addr = '52:54:00:12:34:59' %}" >> myqemu.dat
echo "{% set memory = '1024' %}" >> myqemu.dat

# Import the QEMU Device Dictionary file into the LAVA2 Server
sudo DEBIAN_FRONTEND=noninteractive lava-server manage device-dictionary --hostname qemu01 --import myqemu.dat 

# Beaglebone Black
# Add a Device Type beaglebone-black and Device bbb01 for the Beaglebone Black
cd /etc/lava-server/dispatcher-config/device-types/
sudo DEBIAN_FRONTEND=noninteractive lava-server manage add-device-type beaglebone-black
sudo DEBIAN_FRONTEND=noninteractive lava-server manage add-device --device-type beaglebone-black bbb01 --worker jessie.raw

# Create the Device Dictionary file for the Beaglebone Black and store it in ~/mybbb.dat
cd ~
echo "{% extends 'beaglebone-black.jinja2' %}" > mybbb.dat
echo "{% set connection_command = 'telnet localhost 8020' %}" >> mybbb.dat
echo "{% set poweron_command = 'pduclient --daemon localhost --hostname 127.0.0.1 --port 3 --command on' %}" >> mybbb.dat
echo "{% set poweroff_command = 'pduclient --daemon localhost --hostname 127.0.0.1 --port 3 --command off' %}" >> mybbb.dat
echo "{% set reboot_command = 'pduclient --daemon localhost --hostname 127.0.0.1 --port 3 --command reboot' %}" >> mybbb.dat

# Import the Beaglebone Black Device Dictionary file into the LAVA2 Server
sudo DEBIAN_FRONTEND=noninteractive lava-server manage device-dictionary --hostname bbb01 --import mybbb.dat


