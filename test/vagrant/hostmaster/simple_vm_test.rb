require 'test/unit'
require "mocha"
require 'vagrant/hostmaster'
require 'vagrant/hostmaster/test_helpers'

module Vagrant
  module Hostmaster
    class SimpleVMTest < Test::Unit::TestCase
      include Vagrant::TestHelpers
      include Vagrant::Hostmaster::TestHelpers

      def setup
        super

        # TODO: test both windows and non-windows
        Util::Platform.stubs(:windows?).returns(false)
        @hosts_file = Tempfile.new('hosts')
        hostmaster_box :default, 'hostmaster.dev', '123.45.67.89', '01234567-89ab-cdef-fedc-ba9876543210'
        @vms = hostmaster_vms(hostmaster_env)
      end

      def teardown
        @hosts_file.unlink
        clean_paths
        super
      end

      def test_hosts_path
        assert_equal '/etc/hosts', Vagrant::Hostmaster::VM.hosts_path
      end

      def test_hosts_path_on_windows
        Util::Platform.stubs(:windows?).returns(true)
        ENV.stubs(:[]).with('SYSTEMROOT').returns('C:\Windows')
        Vagrant::Hostmaster::VM.stubs(:expand_path).with('system32/drivers/etc/hosts', 'C:\Windows').returns('C:/Windows/system32/drivers/etc/hosts')
        assert_equal 'C:/Windows/system32/drivers/etc/hosts', Vagrant::Hostmaster::VM.hosts_path
      end

      def test_vm_hosts_path
        assert_equal '/etc/hosts', @vms.first.hosts_path
      end

      def test_vm_hosts_path_on_windows
        Util::Platform.stubs(:windows?).returns(true)
        assert_equal '/etc/hosts', @vms.first.hosts_path
      end

      def test_add_local_hosts_entry
        Vagrant::Hostmaster::VM.stubs(:hosts_path).returns @hosts_file.path
        @vms.each { |vm| vm.add }
        assert_local_host_entries_for @vms, @hosts_file
      end

      def test_list_local_hosts_entry
        Vagrant::Hostmaster::VM.stubs(:hosts_path).returns @hosts_file.path
        write_local_host_entries @hosts_file
        hostmaster_boxes.each do |name,box|
          output = Vagrant::Hostmaster::UI::Capture.capture { box[:vm].list }
          assert_match /^\[local\]\s+#{box[:address]}\s+#{box[:host_name]}\s*# VAGRANT: #{box[:uuid]} \(#{name}\)$/, output
        end
      end

      def test_remove_local_hosts_entry
        Vagrant::Hostmaster::VM.stubs(:hosts_path).returns @hosts_file.path
        write_local_host_entries @hosts_file
        @vms.each { |vm| vm.remove }
        assert_no_local_host_entries_for @vms, @hosts_file
      end

      def test_update
        Vagrant::Hostmaster::VM.stubs(:hosts_path).returns @hosts_file.path
        write_local_host_entries @hosts_file, :default => {:address => '10.10.10.10', :host_name => 'www.hostmaster.dev'}
        @vms.each { |vm| vm.update }
        assert_local_host_entries_for @vms, @hosts_file
      end
    end
  end
end
