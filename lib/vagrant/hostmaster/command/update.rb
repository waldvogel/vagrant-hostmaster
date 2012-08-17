module Vagrant
  module Hostmaster
    module Command
      class Update < Vagrant::Command::Base
        def execute
          options = OptionParser.new do |opts|
            opts.banner = "Usage: vagrant hosts update [<vm-name> [...]]"
          end

          # Parse the options
          argv = parse_options(options)
          return if !argv

          with_target_vms(argv) do |vm|
            update vm
          end

          # Success, exit status 0
          0
        end

        protected
          def update(vm)
            @env.ui.info("Updating host entry for #{vm.name} VM. Administrator privileges will be required...", :prefix => false)
            type, (address, *) = vm.config.vm.networks.first
            address ||= '127.0.0.1'
            signature = "# VAGRANT: #{vm.uuid}"
            system %Q(sudo sh -c 'sed -e "/#{signature}$/ d" -ibak /etc/hosts')
            host_names = [vm.config.vm.host_name]
            host_names += Array(vm.config.hosts.aliases)
            host_entry = "#{address}  #{host_names.join(' ')}  #{signature}"
            system %Q(sudo sh -c 'echo "#{host_entry}" >>/etc/hosts')
          end
      end
    end
  end
end