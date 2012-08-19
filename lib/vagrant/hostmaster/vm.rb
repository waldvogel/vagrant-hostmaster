require 'forwardable'

module Vagrant
  module Hostmaster
    class VM
      extend Forwardable

      def_delegators :@vm, :channel, :config, :env, :name, :uuid

      class << self
        def process(method, vms)
          vms.each { |vm| vm.send method, vms.reject { |other_vm| other_vm.name == vm.name } }
        end
      end

      def initialize(vm)
        @vm = vm
      end

      def add(options = {})
        env.ui.info("Adding host entry for #{name} VM. Administrator privileges will be required...") unless options[:quiet]
        sudo add_command
        with_other_vms { |vm| channel.sudo vm.add_command(uuid) }
      end

      def list(options = {})
        output = `#{list_command}`.chomp
        env.ui.info("Local host entry for #{name}...\n#{output}\n\n", :prefix => false) unless output.empty?

        entries = []
        with_other_vms do |vm|
          entry = ""
          channel.execute(vm.list_command(uuid), :error_check => false) do |type, data|
            entry << data if type == :stdout
          end
          entry.chomp!
          entries << entry unless entry.empty?
        end
        env.ui.info("#{entries.size} guest host #{entries.size > 1 ? 'entries' : 'entry'} on #{name}...\n#{entries.join("\n")}\n\n", :prefix => false) unless entries.empty?
      end

      def remove(options = {})
        env.ui.info("Removing host entry for #{name} VM. Administrator privileges will be required...") unless options[:quiet]
        sudo remove_command
        with_other_vms { |vm| channel.sudo vm.remove_command(uuid) }
      end

      def update(options = {})
        env.ui.info("Updating host entry for #{name} VM. Administrator privileges will be required...") unless options[:quiet]
        sudo(remove_command) && sudo(add_command)
        with_other_vms { |vm| channel.sudo(vm.remove_command(uuid)) && channel.sudo(vm.add_command(uuid)) }
      end

      protected
        def add_command(uuid = self.uuid)
          %Q(sh -c 'echo "#{host_entry(uuid)}" >>/etc/hosts')
        end

        def address
          # network parameters consist of an address and a hash of options
          @address ||= (network_parameters && network_parameters.first)
        end

        def network_parameters
          # network is a pair of a network type and the network parameters
          @network_parameters ||= (network && network.last)
        end

        def host_aliases
          @host_aliases ||= Array(config.hosts.aliases)
        end

        def host_entry(uuid = self.uuid)
          %Q(#{address}  #{host_names.join(' ')}  #{signature(uuid)})
        end

        def host_name
          @host_name ||= (config.hosts.name || config.vm.host_name)
        end

        def host_names
          @host_names ||= (Array(host_name) + host_aliases)
        end

        def list_command(uuid = self.uuid)
          %Q(grep '#{signature(uuid)}$' /etc/hosts)
        end

        def network
          # hostonly networks are the only ones we're interested in
          @network ||= networks.find { |type,network_parameters| type == :hostonly }
        end

        def networks
          @networks ||= config.vm.networks
        end

        def remove_command(uuid = self.uuid)
          %Q(sed -e '/#{signature(uuid)}$/ d' -ibak /etc/hosts)
        end

        def signature(uuid = self.uuid)
          %Q(# VAGRANT: #{uuid} (#{name}))
        end

        def sudo(command)
          `sudo #{command}`
        end

        def with_other_vms
          env.vms.each do |name,vm|
            yield Hostmaster::VM.new(vm) if vm.config.vm.networks.any? { |type,network_parameters| type == :hostonly } && vm.name != self.name
          end
        end
    end
  end
end
