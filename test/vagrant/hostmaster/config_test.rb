require 'test/unit'
require "mocha"
require 'vagrant/hostmaster'

module Vagrant
  module Hostmaster
    class ConfigTest < Test::Unit::TestCase
      include Vagrant::TestHelpers

      def setup
        @config = Vagrant::Hostmaster::Config.new
        @errors = Vagrant::Config::ErrorRecorder.new
        @env = vagrant_env
      end

      def test_default_valid
        @config.validate(@env, @errors)
        assert @errors.errors.empty?, "Default configuration should not have any errors."
      end

      def test_valid
        @config.name = 'hostmaster.dev'
        @config.aliases = %w(www.hostmaster.dev)
        @config.validate(@env, @errors)
        assert @errors.errors.empty?, "Configuration should not have any errors."
      end
    end
  end
end
