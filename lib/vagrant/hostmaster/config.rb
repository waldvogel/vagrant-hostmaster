module Vagrant
  module Hostmaster
    class Config < Vagrant::Config::Base
      attr_accessor :aliases
    end
  end
end
