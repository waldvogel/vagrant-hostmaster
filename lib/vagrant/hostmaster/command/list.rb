module Vagrant
  module Hostmaster
    module Command
      class List < Vagrant::Command::Base
        def execute
          options = OptionParser.new do |opts|
            opts.banner = "Usage: vagrant hosts list"
          end

          # Parse the options
          argv = parse_options(options)
          return if !argv
          raise Vagrant::Errors::CLIInvalidUsage, :help => opts.help.chomp if argv.length != 0

          with_target_vms do |vm|
            list vm
          end

          # Success, exit status 0
          0
        end

        protected
          def list(vm)
            type, (address, *) = vm.config.vm.networks.first
            address ||= '127.0.0.1'
            signature = "# VAGRANT: #{vm.uuid}"
            system %Q(grep '#{signature}$' /etc/hosts)
          end
      end
    end
  end
end