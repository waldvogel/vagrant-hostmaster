require 'test/unit'
require 'mocha'
require 'vagrant/hostmaster'
require 'vagrant/hostmaster/command/list'

module Vagrant
  module Hostmaster
    module CommandTests
      class ListTest < Test::Unit::TestCase
        include Vagrant::TestHelpers

        def setup
          @env = vagrant_env
          @vm = @env.vms.values.first
          @vm.stubs(:state).returns(:running)
          @command = Vagrant::Hostmaster::Command::List.new([], @env)
        end

        def test_not_created
          @vm.stubs(:state).returns(:not_created)
          Vagrant::Hostmaster::Command::List.expects(:new).with([], @env).returns(@command)
          Vagrant::Hostmaster::VM.expects(:new).never
          @env.cli('hosts', 'list')
        end

        def test_not_running
          @vm.stubs(:state).returns(:poweroff)
          Vagrant::Hostmaster::Command::List.expects(:new).with([], @env).returns(@command)
          Vagrant::Hostmaster::VM.expects(:new).never
          @env.cli('hosts', 'list')
        end

        def test_list
          Vagrant::Hostmaster::Command::List.stubs(:new).with([], @env).returns(@command)
          vm = Vagrant::Hostmaster::VM.new(@vm)
          Vagrant::Hostmaster::VM.expects(:new).with(@vm).returns(vm)
          vm.expects(:list).with()
          @env.cli('hosts', 'list')
        end
      end
    end
  end
end
