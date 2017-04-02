#! /bin/sh
# Copyright (C) 2017, Codethink, Ltd., Christos Karamitsos <christos.karamitsos@codethink.co.uk>
# SPDX-License-Identifier:	AGPL-3.0
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

# Configure KernelCI for 'Single Developer at Desk with Board' Use Case

sudo apt-get install ser2net

if grep ^8020 /etc/ser2net.conf > /dev/null; then
    echo ser2net.conf already fixed
else
    sudo sed -i '$a\8020:telnet:0:/dev/ttyUSB0:115200,8DATABITS,NONE,1STOPBIT,banner' /etc/ser2net.conf
    sudo service ser2net restart
fi
