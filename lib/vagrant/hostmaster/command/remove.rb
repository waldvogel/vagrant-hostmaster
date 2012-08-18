module Vagrant
  module Hostmaster
    module Command
      class Remove < Vagrant::Command::Base
        def execute
          options = OptionParser.new do |opts|
            opts.banner = "Usage: vagrant hosts remove [<vm-name> [...]]"
          end

          # Parse the options
          argv = parse_options(options)
          return if !argv

          with_target_vms(argv) do |vm|
            Hostmaster::VM.new(vm).remove
          end

          # Success, exit status 0
          0
        end
      end
    end
  end
end