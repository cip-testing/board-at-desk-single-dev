# Copyright (C) 2016, Siemens AG, Wolfgang Mauerer <wolfgang.mauerer@siemens.com>
# SPDX-License-Identifier:	Apache-2.0

$build = <<SCRIPT
cd /vagrant

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
    
    vbox.customize ["modifyvm", :id, "--memory", "1024"]
    vbox.customize ["modifyvm", :id, "--cpus", "2"]
  end

  # Forward port 8888 for the internal REST server 
  config.vm.network :forwarded_port, guest: 8888, host: 8888
  # Forward port 8010 for the Storage Server
  config.vm.network :forwarded_port, guest: 8010, host: 8010
  # Forward port 5000 for the KernelCI Frontend Web Server
  config.vm.network :forwarded_port, guest: 5000, host: 5000
  # Forward port 80 for the http Lava Frontend Web Server
  config.vm.network :forwarded_port, guest: 80, host: 8080
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
