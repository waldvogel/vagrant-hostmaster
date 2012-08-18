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
            Hostmaster::VM.new(vm).list
          end

          # Success, exit status 0
          0
        end
      end
    end
  end
end