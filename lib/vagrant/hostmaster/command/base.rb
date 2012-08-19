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
            if vm.created?
              Hostmaster::VM.new(vm).send sub_command.to_sym
            else
              vm.ui.info I18n.t("vagrant.commands.common.vm_not_created")
            end
          end

          # Success, exit status 0
          0
        end
      end
    end
  end
end