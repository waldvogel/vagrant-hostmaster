require 'vagrant'
require 'vagrant/hostmaster/command/base'
require 'vagrant/hostmaster/command/root'
require 'vagrant/hostmaster/config'
require 'vagrant/hostmaster/vm'
require 'vagrant/hostmaster/middleware/remove'
require 'vagrant/hostmaster/middleware/update'

Vagrant.commands.register(:hosts) { Vagrant::Hostmaster::Command::Root }
Vagrant.config_keys.register(:hosts) { Vagrant::Hostmaster::Config }

Vagrant.actions[:destroy].insert_after(Vagrant::Action::VM::ProvisionerCleanup, Vagrant::Hostmaster::Middleware::Remove)

Vagrant.actions[:provision].insert_after(Vagrant::Action::VM::Provision, Vagrant::Hostmaster::Middleware::Update)
Vagrant.actions[:start].insert_after(Vagrant::Action::VM::Provision, Vagrant::Hostmaster::Middleware::Update)
