module Vagrant
  module Hostmaster
    module Command
      class Update < Vagrant::Command::Base
        def execute
          options = {}

          opts = OptionParser.new do |opts|
            opts.banner = "Usage: vagrant hosts update [<vm-name> [...]]"
          end

          # Parse the options
          argv = parse_options(opts)
          return if !argv

          with_target_vms(argv) do |vm|
            update vm
          end

          # Success, exit status 0
          0
        end

        protected
          def update(vm)
            @env.ui.info("Updating host entry for #{vm.name} VM...", :prefix => false)
            type, (address, *) = vm.config.vm.networks.first
            address ||= '127.0.0.1'
            signature = "# VAGRANT: #{vm.uuid}"
            system %Q(grep '#{signature}$' /etc/hosts && sudo sh -c 'sed -e \'/#{signature}$/ d\' -ibak /etc/hosts')
            host_entry = "#{address}  #{vm.config.vm.host_name}  #{signature}"
            system %Q(sudo sh -c 'echo "#{host_entry}" >>/etc/hosts')
          end
      end
    end
  end
end