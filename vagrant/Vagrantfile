# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.provision :shell, :path => "bootstrap.sh"

  # please run:
  #  $ vagrant init
  #  $ vagrant box add precise64 <URL>
  #  $ vagrant up --provider=kvm 
  #
  # URL for virtualbox
  # config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  
  # URL for kvm
  # config.vm.box_url = "https://dl.dropboxusercontent.com/u/90779460/kvm.box"

  # If you use encrypted linux host directory, you should set synced_folder
  # config.vm.synced_folder "/opt/vagrant/users/miurahr/", "/vagrant"
  config.vm.synced_folder "../../", "/vagrant"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. 
  # config.vm.network :forwarded_port, guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network :private_network, ip: "192.168.33.10"

end
