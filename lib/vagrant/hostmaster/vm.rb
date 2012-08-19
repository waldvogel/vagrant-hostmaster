require 'forwardable'

module Vagrant
  module Hostmaster
    class VM
      extend Forwardable

      def_delegators :@vm, :channel, :config, :env, :name, :uuid

      class << self
        def process(method, vms)
          vms = vms.collect { |vm| new(vm) }
          vms.each { |vm| vm.send method, vms.reject { |other_vm| other_vm.name == vm.name } }
        end
      end

      def initialize(vm)
        @vm = vm
      end

      def add(vms, options = {})
        env.ui.info("Adding host entry for #{name} VM. Administrator privileges will be required...") unless options[:quiet]
        sudo add_command
        vms.each { |vm| vm.channel.sudo add_command }
      end

      def list(vms, options = {})
        system list_command
        vms.each do |vm|
          output = ""
          vm.channel.execute(list_command, :error_check => false) do |type, data|
            output << data if type == :stdout
          end && env.ui.info("#{vm.name}:\n#{output}", :prefix => false)
        end
      end

      def remove(vms, options = {})
        env.ui.info("Removing host entry for #{name} VM. Administrator privileges will be required...") unless options[:quiet]
        sudo remove_command
        vms.each { |vm| vm.channel.sudo remove_command }
      end

      def update(vms, options = {})
        env.ui.info("Updating host entry for #{name} VM. Administrator privileges will be required...") unless options[:quiet]
        sudo(remove_command) && sudo(add_command)
        vms.each { |vm| vm.channel.sudo(remove_command) && vm.channel.sudo(add_command) }
      end

      protected
        def add_command
          @add_command ||= %Q(sh -c 'echo "#{host_entry}" >>/etc/hosts')
        end

        def address
          @address ||= (addresses && addresses.first || '127.0.0.1')
        end

        def addresses
          @network_addresses ||= (network && network.last)
        end

        def host_aliases
          @host_aliases ||= Array(config.hosts.aliases)
        end

        def host_entry
          @host_entry ||= "#{address}  #{host_names.join(' ')}  #{signature}"
        end

        def host_name
          @host_name ||= (config.hosts.name || config.vm.host_name)
        end

        def host_names
          @host_names ||= (Array(host_name) + host_aliases)
        end

        def list_command
          @list_command ||= %Q(grep '#{signature}$' /etc/hosts)
        end

        def network
          @network ||= config.vm.networks.first
        end

        def remove_command
          @remove_command ||= %Q(sed -e '/#{signature}$/ d' -ibak /etc/hosts)
        end

        def signature
          @signature ||= "# VAGRANT: #{uuid}"
        end

        def sudo(command)
          system %Q(sudo #{command})
        end
    end
  end
end
