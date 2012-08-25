require 'test/unit'
require "mocha"
require 'vagrant/hostmaster'

module Vagrant
  module Hostmaster
    module MiddlewareTests
      class UpdateTest < Test::Unit::TestCase
        include Vagrant::TestHelpers

        def setup
          @app, @env = action_env(vagrant_env.vms.values.first.env)
          @env['vm'].stubs(:state).returns(:running)
          @middleware = Vagrant::Hostmaster::Middleware::Update.new(@app, @env)
        end

        def test_not_created
          @env['vm'].stubs(:state).returns(:not_created)
          Vagrant::Hostmaster::VM.expects(:new).never
          @middleware.call(@env)
        end

        def test_not_running
          @env['vm'].stubs(:state).returns(:poweroff)
          Vagrant::Hostmaster::VM.expects(:new).never
          @middleware.call(@env)
        end

        def test_update
          vm = Vagrant::Hostmaster::VM.new(@env['vm'])
          Vagrant::Hostmaster::VM.expects(:new).with(@env['vm']).returns(vm)
          vm.expects(:update).with()
          @middleware.call(@env)
        end
      end
    end
  end
end
