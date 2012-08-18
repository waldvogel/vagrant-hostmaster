require 'forwardable'

module Vagrant
  module Hostmaster
    class VM
      extend Forwardable

      def_delegators :@vm, :config, :env, :name, :uuid

      def initialize(vm)
        @vm = vm
      end

      def add(options = {})
        env.ui.info("Adding host entry for #{name} VM. Administrator privileges will be required...") unless options[:quiet]
        sudo %Q(sh -c 'echo "#{host_entry}" >>/etc/hosts')
      end

      def list(options = {})
        system %Q(grep '#{signature}$' /etc/hosts)
      end

      def remove(options = {})
        env.ui.info("Removing host entry for #{name} VM. Administrator privileges will be required...") unless options[:quiet]
        sudo %Q(sed -e '/#{signature}$/ d' -ibak /etc/hosts)
      end

      def update(options = {})
        env.ui.info("Updating host entry for #{name} VM. Administrator privileges will be required...") unless options[:quiet]
        remove(:quiet => true) && add(:quiet => true)
      end

      protected
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

        def network
          @network ||= config.vm.networks.first
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
