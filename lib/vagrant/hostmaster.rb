require 'vagrant/hostmaster/version'
require 'vagrant/hostmaster/command/root'
require 'vagrant/hostmaster/config'
require 'vagrant/hostmaster/vm'

Vagrant.commands.register(:hosts) { Vagrant::Hostmaster::Command::Root }
Vagrant.config_keys.register(:hosts) { Vagrant::Hostmaster::Config }