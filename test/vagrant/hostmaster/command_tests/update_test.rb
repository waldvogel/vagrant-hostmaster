require 'test/unit'
require 'mocha'
require 'vagrant/hostmaster'
require 'vagrant/hostmaster/command/update'

module Vagrant
  module Hostmaster
    module CommandTests
      class UpdateTest < Test::Unit::TestCase
        include Vagrant::TestHelpers

        def setup
          @env = vagrant_env
          @vm = @env.vms.values.first
          @vm.stubs(:state).returns(:running)
          @command = Vagrant::Hostmaster::Command::Update.new([], @env)
        end

        def test_not_created
          @vm.stubs(:state).returns(:not_created)
          Vagrant::Hostmaster::Command::Update.expects(:new).with([], @env).returns(@command)
          Vagrant::Hostmaster::VM.expects(:new).never
          @env.cli('hosts', 'update')
        end

        def test_not_running
          @vm.stubs(:state).returns(:poweroff)
          Vagrant::Hostmaster::Command::Update.expects(:new).with([], @env).returns(@command)
          Vagrant::Hostmaster::VM.expects(:new).never
          @env.cli('hosts', 'update')
        end

        def test_update
          Vagrant::Hostmaster::Command::Update.stubs(:new).with([], @env).returns(@command)
          vm = Vagrant::Hostmaster::VM.new(@vm)
          Vagrant::Hostmaster::VM.expects(:new).with(@vm).returns(vm)
          vm.expects(:update).with()
          @env.cli('hosts', 'update')
        end
      end
    end
  end
end
