require 'test/unit'
require "mocha"
require 'vagrant/hostmaster'
require 'vagrant/hostmaster/test_helpers'

module Vagrant
  module Hostmaster
    class VMTest < Test::Unit::TestCase
      include Vagrant::TestHelpers
      include Vagrant::Hostmaster::TestHelpers

      def setup
        super

        # TODO: test both windows and non-windows
        Util::Platform.stubs(:windows?).returns(false)
        @hosts_file = Tempfile.new('hosts')
        @address = '123.45.67.89'
        @host_name = 'hostmaster.dev'
        @uuid = '01234567-89ab-cdef-fedc-ba9876543210'

        @env = vagrant_env
        @vm = @env.vms.values.first
        @vm.config.vm.host_name = @host_name
        @vm.config.vm.network :hostonly, @address
        @vm.stubs(:state).returns(:running)
        @vm.stubs(:uuid).returns(@uuid)

        @hostmaster_vm = Vagrant::Hostmaster::VM.new(@vm)
      end

      def teardown
        @hosts_file.unlink
        super
      end

      def test_hosts_path
        assert_equal '/etc/hosts', Vagrant::Hostmaster::VM.hosts_path
      end

      def test_hosts_path_for_windows
        Util::Platform.stubs(:windows?).returns(true)
        ENV.stubs(:[]).with('SYSTEMROOT').returns('/windows')
        assert_equal '/windows/system32/drivers/etc/hosts', Vagrant::Hostmaster::VM.hosts_path
      end

      def test_add_local_hosts_entry
        Vagrant::Hostmaster::VM.stubs(:hosts_path).returns @hosts_file.path
        @hostmaster_vm.add
        assert_local_host_entry_for @uuid, @hosts_file
        assert_local_host_address_of @address, @uuid, @hosts_file
        assert_local_host_name_of @host_name, @uuid, @hosts_file
      end

      def test_list
        Vagrant::Hostmaster::VM.stubs(:hosts_path).returns @hosts_file.path
        @hosts_file.puts "#{@address} #{@host_name} # VAGRANT: #{@uuid} (default)"
        @hostmaster_vm.list
        assert false
      end

      def test_remove_local_hosts_entry
        Vagrant::Hostmaster::VM.stubs(:hosts_path).returns @hosts_file.path
        @hosts_file.puts "#{@address} #{@host_name} # VAGRANT: #{@uuid} (default)"
        @hostmaster_vm.remove
        assert_no_local_host_entry_for @uuid, @hosts_file
      end

      def test_update
        Vagrant::Hostmaster::VM.stubs(:hosts_path).returns @hosts_file.path
        @hosts_file.puts "10.10.10.10 www.hostmaster.dev # VAGRANT: #{@uuid} (default)"
        @hostmaster_vm.update
        assert_local_host_entry_for @uuid, @hosts_file
        assert_local_host_address_of @address, @uuid, @hosts_file
        assert_local_host_name_of @host_name, @uuid, @hosts_file
      end
    end
  end
end
