# vagrant-hostmaster

vagrant-hostmaster is a Vagrant plugin to manage /etc/hosts entries on both the host OS and guest VMs.

## Installation

Add this line to your application's Gemfile:

    gem 'vagrant-hostmaster'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vagrant-hostmaster

## Usage

    Usage: vagrant hosts <command> [<args>]

    Available subcommands:
         list
         remove
         update

    For help on any individual command run `vagrant hosts COMMAND -h`

### List Host Entries

    vagrant hosts list

### Remove Host Entries

    vagrant hosts remove [<vm-name> [...]]

### Update Host Entries

    vagrant hosts update [<vm-name> [...]]

## TODO

1. add commands to modify guests

2. add provisioning support so that changes are made automatically

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
