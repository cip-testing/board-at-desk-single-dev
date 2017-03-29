#! /bin/sh
# Copyright (C) 2017, Codethink, Ltd., Christos Karamitsos
# <christos.karamitsos@codethink.co.uk>
# Configure KernelCI for 'Single Developer at Desk with Board' Use Case

sudo apt-get install ser2net

if grep ^8020 /etc/ser2net.conf > /dev/null; then
    echo ser2net.conf already fixed
else
    sudo sed -i '$a\8020:telnet:0:/dev/ttyUSB0:115200,8DATABITS,NONE,1STOPBIT,banner' /etc/ser2net.conf
    sudo service ser2net restart
fi
