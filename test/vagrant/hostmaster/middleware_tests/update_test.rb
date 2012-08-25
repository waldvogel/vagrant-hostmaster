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
          @instance = Vagrant::Hostmaster::Middleware::Update.new(@app, @env)
          @env["vm"].stubs(:state).returns(:running)
        end

        def test_not_created
          @env["vm"].stubs(:state).returns(:not_created)
          # @env["vm"].expects(:ssh).never
          @instance.call(@env)
        end

        def test_not_running
          @env["vm"].stubs(:state).returns(:poweroff)
          # @env["vm"].expects(:ssh).never
          @instance.call(@env)
        end
      end
    end
  end
end
