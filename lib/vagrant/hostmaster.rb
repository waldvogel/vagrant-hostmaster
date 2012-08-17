require 'vagrant/hostmaster/version'
require 'vagrant/hostmaster/command/root'

Vagrant.commands.register(:hosts) { Vagrant::Hostmaster::Command::Root }