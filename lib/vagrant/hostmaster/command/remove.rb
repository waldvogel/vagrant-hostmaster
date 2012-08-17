module Vagrant
  module Hostmaster
    module Command
      class Remove < Vagrant::Command::Base
        def execute
          options = {}

          opts = OptionParser.new do |opts|
            opts.banner = "Usage: vagrant hosts remove [<vm-name> [...]]"
          end

          # Parse the options
          argv = parse_options(opts)
          return if !argv

          with_target_vms(argv) do |vm|
            remove vm
          end

          # Success, exit status 0
          0
        end

        protected
          def remove(vm)
            @env.ui.info("Removing host entry for #{vm.name} VM...", :prefix => false)
            signature = "# VAGRANT: #{vm.uuid}"
            system %Q(sudo sed -e '/#{signature}$/ d' -ibak /etc/hosts)
          end
      end
    end
  end
end