require 'test/unit'
require 'mocha'
require 'vagrant/hostmaster'
require 'vagrant/hostmaster/command/list'
require 'vagrant/hostmaster/command/remove'
require 'vagrant/hostmaster/command/update'

module Vagrant
  module Hostmaster
    module CommandTests
      class RootTest < Test::Unit::TestCase
        include Vagrant::TestHelpers

        def setup
          @env = vagrant_env
          @vm = @env.vms.values.first
        end

        def test_no_command
          command = Vagrant::Hostmaster::Command::Root.new([], @env)
          Vagrant::Hostmaster::Command::Root.expects(:new).with([], @env).returns(command)
          command.expects(:help)
          @env.cli('hosts')
        end

        def test_list
          command = Vagrant::Hostmaster::Command::List.new([], @env)
          Vagrant::Hostmaster::Command::List.expects(:new).with([], @env).returns(command)
          command.expects(:execute).with()
          @env.cli('hosts', 'list')
        end

        def test_remove
          command = Vagrant::Hostmaster::Command::Remove.new([], @env)
          Vagrant::Hostmaster::Command::Remove.expects(:new).with([], @env).returns(command)
          command.expects(:execute).with()
          @env.cli('hosts', 'remove')
        end

        def test_update
          command = Vagrant::Hostmaster::Command::Update.new([], @env)
          Vagrant::Hostmaster::Command::Update.expects(:new).with([], @env).returns(command)
          command.expects(:execute).with()
          @env.cli('hosts', 'update')
        end
      end
    end
  end
end
