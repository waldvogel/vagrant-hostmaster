module Vagrant
  module Hostmaster
    module Command
      class Base < Vagrant::Command::Base
        def execute
          sub_command = self.class.name.downcase

          parser = OptionParser.new do |opts|
            opts.banner = "Usage: vagrant hosts #{sub_command} [vm-name]"
          end

          # Parse the options
          argv = parse_options(parser)
          return if !argv

          with_target_vms(argv, options) do |vm|
            Hostmaster::VM.new(vm).send sub_command.to_sym
          end

          # Success, exit status 0
          0
        end
      end
    end
  end
end