require 'test/unit'
require 'mocha'
require 'vagrant/hostmaster'
require 'vagrant/hostmaster/command/remove'

module Vagrant
  module Hostmaster
    module CommandTests
      class RemoveTest < Test::Unit::TestCase
        include Vagrant::TestHelpers

        def setup
          @env = vagrant_env
          @vm = @env.vms.values.first
          @vm.stubs(:state).returns(:running)
          @command = Vagrant::Hostmaster::Command::Remove.new([], @env)
        end

        def test_not_created
          @vm.stubs(:state).returns(:not_created)
          Vagrant::Hostmaster::Command::Remove.expects(:new).with([], @env).returns(@command)
          Vagrant::Hostmaster::VM.expects(:new).never
          @env.cli('hosts', 'remove')
        end

        def test_not_running
          @vm.stubs(:state).returns(:poweroff)
          Vagrant::Hostmaster::Command::Remove.expects(:new).with([], @env).returns(@command)
          Vagrant::Hostmaster::VM.expects(:new).never
          @env.cli('hosts', 'remove')
        end

        def test_remove
          Vagrant::Hostmaster::Command::Remove.stubs(:new).with([], @env).returns(@command)
          vm = Vagrant::Hostmaster::VM.new(@vm)
          Vagrant::Hostmaster::VM.expects(:new).with(@vm).returns(vm)
          vm.expects(:remove).with()
          @env.cli('hosts', 'remove')
        end
      end
    end
  end
end
