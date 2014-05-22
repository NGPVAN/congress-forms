# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define :integration do |integration_config|
    integration_config.vm.box = "dummy"
    integration_config.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"

    integration_config.vm.provider :aws do |aws, override|
      aws.keypair_name = "vagrant"
      aws.ami = "ami-b08b6cd8"
      override.ssh.username = "ubuntu"
      override.ssh.private_key_path = "~/.ssh/vagrant.pem"
    end
  end

  config.vm.define :local do |local_config|
    config.vm.box = "precise64"
    config.vm.box_url = "http://files.vagrantup.com/precise64.box"
    config.vm.network "forwarded_port", guest: 9292, host: 9292
  end

  config.vm.provision :shell,
    path: "setup_dev.sh"
end
