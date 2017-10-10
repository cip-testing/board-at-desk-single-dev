# Copyright (C) 2016-2017, Siemens AG, Wolfgang Mauerer <wolfgang.mauerer@siemens.com>
# Copyright (C) 2016-2017, Codethink, Ltd., Robert Marshall <robert.marshall@codethink.co.uk>
# SPDX-License-Identifier:	AGPL-3.0
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

$build = <<SCRIPT
cd /vagrant
set -e
integration-scripts/install_ifupdown_workaround.sh
integration-scripts/install_dependencies.sh
integration-scripts/install_backend.sh
integration-scripts/install_frontend.sh
integration-scripts/install_build_script.sh
integration-scripts/configure_singledev.sh
integration-scripts/install_lava.sh
integration-scripts/configure_lava.sh
SCRIPT

Vagrant.configure(2) do |config|
  config.vm.provider :virtualbox do |vbox, override|
    config.vm.box = "debian/jessie64"
    
    vbox.customize ["modifyvm", :id, "--vram", "12"]
    vbox.customize ["modifyvm", :id, "--memory", "2048"]
    vbox.customize ["modifyvm", :id, "--cpus", "2"]
    vbox.customize ["modifyvm", :id, "--usb", "on"]
  end

  config.vm.provider :libvirt do |libvirt|
    libvirt.memory = 2048
    libvirt.cpus = 2
  end

  # Forward port 8888 for the internal REST server 
  config.vm.network :forwarded_port, guest: 8888, host: 8888
  # Forward port 8010 for the Storage Server
  config.vm.network :forwarded_port, guest: 8010, host: 8010
  # Forward port 5000 for the KernelCI Frontend Web Server
  config.vm.network :forwarded_port, guest: 5000, host: 5000
  # Forward port 80 for the http Lava Frontend Web Server
  config.vm.network :forwarded_port, guest: 8080, host: 8080
  # Forward port 443 for the https Lava Frontend Web Server
  config.vm.network :forwarded_port, guest: 443, host: 4443
  # Configure network accessibility for tftp server
  config.vm.network "public_network", use_dhcp_assigned_default_route: true

  config.vm.provision "shell" do |s|
    s.privileged = false
    s.inline = $build
  end

  config.vm.synced_folder ".", "/vagrant", type: "rsync"
end
