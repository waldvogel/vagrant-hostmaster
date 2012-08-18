module Vagrant
  module Hostmaster
    module Command
      class Update < Vagrant::Hostmaster::Command::Base
        def execute
          options = OptionParser.new do |opts|
            opts.banner = "Usage: vagrant hosts update [<vm-name> [...]]"
          end

          # Parse the options
          argv = parse_options(options)
          return if !argv

          with_target_vms(argv) do |vm|
            Hostmaster::VM.new(vm).update
          end

          # Success, exit status 0
          0
        end
      end
    end
  end
end