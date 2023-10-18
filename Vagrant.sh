#!/bin/bash
#Initializing vagrant machine 
vagrant init ubuntu/focal64

#writing the configuration of slave and master machine into vagrant file for outer stream
cat <<EOF > Vagrantfile
Vagrant.configure("2") do |config|

  config.vm.define "slave_machine" do |slave_machine|

    slave_machine.vm.hostname = "slave_machine"
    slave_machine.vm.box = "ubuntu/focal64"
    slave_machine.vm.network "private_network", ip: "192.168.20.100"
   
#Provisioning  the slave machine  to  update necessary packages 
    slave_machine.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update && sudo apt-get upgrade -y
    
    #installing sshpass and enabling Password Authentication to allow ssh connection

    sudo apt install sshpass -y
    sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sudo systemctl restart sshd
    sudo apt-get install -y avahi-daemon libnss-mdns
    SHELL
  end

  config.vm.define "master" do |master|

    master.vm.hostname = "master"
    master.vm.box = "ubuntu/focal64"
    master.vm.network "private_network", ip: "192.168.20.101"
##Provisioning  the slave machine  to  update necessary packages 
    master.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y avahi-daemon libnss-mdns
    sudo apt install sshpass -y
   # sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
   # sudo systemctl restart sshd
    SHELL
  end

#configuring resource to the machine provider
    config.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
      vb.cpus = "1"
    end
end
EOF

vagrant up

source commands.sh 


  

