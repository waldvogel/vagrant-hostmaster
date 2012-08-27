require 'test/unit'
require "mocha"
require 'vagrant/hostmaster'
require 'vagrant/hostmaster/test_helpers'

module Vagrant
  module Hostmaster
    class MultipleVMTest < Test::Unit::TestCase
      include Vagrant::TestHelpers
      include Vagrant::Hostmaster::TestHelpers

      def setup
        super

        # TODO: test both windows and non-windows
        Util::Platform.stubs(:windows?).returns(false)
        @hosts_file = Tempfile.new('hosts')
        hostmaster_box 'one.hostmaster.dev', '10.0.0.100', '11111111-1111-1111-1111-111111111111'
        hostmaster_box 'two.hostmaster.dev', '10.0.0.200', '22222222-2222-2222-2222-222222222222'
        @vms = hostmaster_vms(vagrant_env(vagrantfile(hostmaster_config)))
      end

      def teardown
        @hosts_file.unlink
        clean_paths
        super
      end

      def test_add_local_hosts_entries
        Vagrant::Hostmaster::VM.stubs(:hosts_path).returns @hosts_file.path
        @vms.each { |vm| vm.add :guests => false }
        assert_local_host_entries_for @vms, @hosts_file
      end

      def test_list_local_hosts_entry
        Vagrant::Hostmaster::VM.stubs(:hosts_path).returns @hosts_file.path
        write_local_host_entries_for @vms, @hosts_file
        @vms.each { |vm| vm.list :guests => false }
        assert false
      end

      def test_remove_local_hosts_entry
        Vagrant::Hostmaster::VM.stubs(:hosts_path).returns @hosts_file.path
        write_local_host_entries_for @vms, @hosts_file
        @vms.each { |vm| vm.remove :guests => false }
        assert_no_local_host_entries_for @vms, @hosts_file
      end

      def test_update
        Vagrant::Hostmaster::VM.stubs(:hosts_path).returns @hosts_file.path
        write_local_host_entries_for @vms, @hosts_file, :addresses => %w(10.10.10.11 10.10.10.22), :names => %w(a.hostmaster.dev b.hostmaster.dev)
        @vms.each { |vm| vm.update :guests => false }
        assert_local_host_entries_for @vms, @hosts_file
      end
    end
  end
end
