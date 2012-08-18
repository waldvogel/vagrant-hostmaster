require 'forwardable'

module Vagrant
  module Hostmaster
    class VM
      extend Forwardable

      def_delegators :@vm, :config, :env, :name, :uuid

      def initialize(vm)
        @vm = vm
      end

      def add
        system %Q(sudo sh -c 'echo "#{host_entry}" >>/etc/hosts')
      end

      def list
        system %Q(grep '#{signature}$' /etc/hosts)
      end

      def remove
        system %Q(sudo sed -e '/#{signature}$/ d' -ibak /etc/hosts)
      end

      def update
        remove && add
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
    end
  end
end
