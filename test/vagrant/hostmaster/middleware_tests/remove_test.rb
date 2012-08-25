require 'test/unit'
require "mocha"
require 'vagrant/hostmaster'

module Vagrant
  module Hostmaster
    module MiddlewareTests
      class RemoveTest < Test::Unit::TestCase
        include Vagrant::TestHelpers

        def setup
          @app, @env = action_env(vagrant_env.vms.values.first.env)
          @env['vm'].stubs(:state).returns(:running)
          @middleware = Vagrant::Hostmaster::Middleware::Remove.new(@app, @env)
        end

        def test_not_created
          @env['vm'].stubs(:state).returns(:not_created)
          Vagrant::Hostmaster::VM.expects(:new).never
          @middleware.call(@env)
        end

        def test_not_running
          @env['vm'].stubs(:state).returns(:poweroff)
          vm = Vagrant::Hostmaster::VM.new(@env['vm'])
          Vagrant::Hostmaster::VM.expects(:new).with(@env['vm']).returns(vm)
          vm.expects(:remove).with(:guests => false)
          @middleware.call(@env)
        end

        def test_remove
          vm = Vagrant::Hostmaster::VM.new(@env['vm'])
          Vagrant::Hostmaster::VM.expects(:new).with(@env['vm']).returns(vm)
          vm.expects(:remove).with(:guests => false)
          @middleware.call(@env)
        end
      end
    end
  end
end
