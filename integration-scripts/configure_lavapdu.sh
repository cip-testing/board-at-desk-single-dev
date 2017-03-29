#! /bin/sh
# Copyright (C) 2017, Codethink, Ltd., Don Brown
# <don.brown@codethink.co.uk>
# Configure KernelCI for 'Single Developer at Desk with Board' Use Case

# Copy drivers to /usr/lib/python2.7/dist-packages/lavapdu/drivers
sudo DEBIAN_FRONTEND=noninteractive cp /vagrant/scripts/lavapdu/*.py /usr/lib/python2.7/dist-packages/lavapdu/drivers

# Move relay-ctrl.py to /usr/bin
sudo DEBIAN_FRONTEND=noninteractive mv /usr/lib/python2.7/dist-packages/lavapdu/drivers/relay-ctrl.py /usr/bin
