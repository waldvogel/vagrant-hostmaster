# vagrant-hostmaster

**Standalone version (easier to include in a project directly, not via gem)**

`vagrant-hostmaster` is a Vagrant plugin to manage /etc/hosts entries on both the host OS and guest VMs.

## Installation

Clone the `standalone` branch into your project folder, for example:

    git clone -b standalone <git://github.com/waldvogel/vagrant-hostmaster.git> hostmaster

Include `hostmaster.rb` in your Vagrantfile:

    require File.dirname(__FILE__) + "/hostmaster/hostmaster.rb"

This should be enough to add hostmaster to your project.

## Usage

vagrant-hostmaster will automatically add/update /etc/hosts entries when you run `vagrant up`
(or `vagrant provision`).

The host entries will automatically be removed when you run `vagrant destroy`.

### Configuration

By default, the name specified in the `vm.host_name` configuration option will be associated
with the address of the first network interface.

For example:

    Vagrant::Config.run do |config|
      ...

      config.vm.host_name = "www.example.com"

      config.vm.network :hostonly, "33.33.33.60"
    end

This would result in the following hosts entry:

    33.33.33.60 www.example.com # VAGRANT: ...

### Using a different host name
  
To use a different host name, specify it in your Vagrantfile using the `hosts.name` configuration
option.

For example:

    Vagrant::Config.run do |config|
      ...

      config.vm.host_name = "www.example.com"
      config.hosts.name = "example.com"

      config.vm.network :hostonly, "33.33.33.60"
    end

This would result in the following hosts entry:

    33.33.33.60 example.com # VAGRANT: ...

### Host aliases

In addition, the `hosts.aliases` configuration option can be used to provide aliases for your host names.

For example:

    Vagrant::Config.run do |config|
      ...

      config.vm.host_name = "www.example.com"
      config.hosts.aliases = %w(example.com)

      config.vm.network :hostonly, "33.33.33.60"
    end

This would result in the following hosts entry:

    33.33.33.60 www.example.com example.com # VAGRANT: ...

## Command Line

In addition to automatically updating the hosts file, the `hosts` command supports manual
modification (or verification) of the hosts entries.

    Usage: vagrant hosts <command> [<args>]

    Available subcommands:
         list
         remove
         update

    For help on any individual command run `vagrant hosts COMMAND -h`

### List Host Entries

    vagrant hosts list [vm-name]

### Remove Host Entries

    vagrant hosts remove [vm-name]

### Update Host Entries

    vagrant hosts update [vm-name]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
