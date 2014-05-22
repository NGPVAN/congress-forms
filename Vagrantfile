# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define :ec2 do |ec2_config|
    ec2_config.vm.box = "dummy"
    ec2_config.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"

    ec2_config.vm.provider :aws do |aws, override|
      aws.keypair_name = "congress-forms"
      aws.ami = "ami-b08b6cd8"
      aws.security_groups = "congress-forms"
      override.ssh.username = "ubuntu"
      override.ssh.private_key_path = "~/.ssh/congress-forms.pem"
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
