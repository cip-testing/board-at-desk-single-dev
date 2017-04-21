#!/usr/bin/expect
# Copyright (C) 2017, Codethink, Ltd., Don Brown <don.brown@codethink.co.uk>
# SPDX-License-Identifier:	AGPL-3.0
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

#USAGE: connectBBB.sh 192.168.1.50 8020 debian lava123
if {[llength $argv] == 0} {
  send_user "Usage: connectBBB.sh <ip address> <port> <username> <password>\n"
  exit 1
}

# Set input parameters
set timeout 1
set ip [lindex $argv 0]
set port [lindex $argv 1]
set username [lindex $argv 2]
set password [lindex $argv 3]

# Create a telnet process
spawn telnet $ip $port

# Wait for the escape character to be sent
expect "'^]'."
sleep .1

# Send a carriage return
send "\r"

# send the username and password at the "login:" and "password:" prompts
expect "login:" {
    send "$username\r"
    expect "password:"
    send "$password\r"
}
# Wait for user prompt
expect -re {[#$!]\s*$}

# Allow user (or LAVA) to interact with the BBB normally
interact
