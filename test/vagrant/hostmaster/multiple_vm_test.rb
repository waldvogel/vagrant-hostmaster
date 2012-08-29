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
        hostmaster_box :one, 'one.hostmaster.dev', '10.0.0.100', '11111111-1111-1111-1111-111111111111'
        hostmaster_box :two, 'two.hostmaster.dev', '10.0.0.200', '22222222-2222-2222-2222-222222222222'
        @vms = hostmaster_vms(hostmaster_env)
      end

      def teardown
        @hosts_file.unlink
        clean_paths
        super
      end

      def test_add
        Vagrant::Hostmaster::VM.stubs(:hosts_path).returns @hosts_file.path
        @vms.each do |vm|
          hostmaster_boxes.each do |name,box|
            next if name == vm.name
            param = %Q(sh -c 'echo \"#{box[:address]}  #{box[:host_name]}  # VAGRANT: #{vm.uuid} \(#{name}\)\" >>#{vm.hosts_path}')
            vm.channel.expects(:sudo).with(param)
          end
          vm.add
        end
        assert_local_host_entries_for @vms, @hosts_file
      end

      def test_list
        Vagrant::Hostmaster::VM.stubs(:hosts_path).returns @hosts_file.path
        write_local_host_entries @hosts_file
        hostmaster_boxes.each do |target_name,target_box|
          address, host_name, uuid, vm = target_box.values_at(:address, :host_name, :uuid, :vm)
          hostmaster_boxes.each do |name,box|
            next if name == target_name
            param = "grep '# VAGRANT: #{uuid} (#{name})$' #{vm.hosts_path}"
            vm.channel.expects(:execute).with(param, :error_check => false)
          end
          output = Vagrant::Hostmaster::UI::Capture.capture { vm.list }
          assert_match /^\[local\] #{address} #{host_name} # VAGRANT: #{uuid} \(#{target_name}\)$/, output
        end
      end

      def test_remove_local_hosts_entry
        Vagrant::Hostmaster::VM.stubs(:hosts_path).returns @hosts_file.path
        write_local_host_entries @hosts_file
        @vms.each do |vm|
          hostmaster_boxes.each do |name,box|
            next if name == vm.name
            param = %Q(sed -e '/# VAGRANT: #{vm.uuid} (#{name})$/ d' -ibak #{vm.hosts_path})
            vm.channel.expects(:sudo).with(param)
          end
          vm.remove
        end
        assert_no_local_host_entries_for @vms, @hosts_file
      end

      def test_update_local_hosts_entry
        Vagrant::Hostmaster::VM.stubs(:hosts_path).returns @hosts_file.path
        write_local_host_entries @hosts_file, :one => {:address => '10.10.10.11', :host_name => 'a.hostmaster.dev'}, :two => {:address => '10.10.10.22', :host_name => 'b.hostmaster.dev'}
        @vms.each do |vm|
          hostmaster_boxes.each do |name,box|
            next if name == vm.name
            param = %Q(sed -e '/# VAGRANT: #{vm.uuid} (#{name})$/ d' -ibak #{vm.hosts_path})
            vm.channel.expects(:sudo).with(param).returns(0)
            param = %Q(sh -c 'echo \"#{box[:address]}  #{box[:host_name]}  # VAGRANT: #{vm.uuid} \(#{name}\)\" >>#{vm.hosts_path}')
            vm.channel.expects(:sudo).with(param).returns(0)
          end
          vm.update
        end
        assert_local_host_entries_for @vms, @hosts_file
      end
    end
  end
end
