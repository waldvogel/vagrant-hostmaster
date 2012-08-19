module Vagrant
  module Hostmaster
    module Middleware
      class Remove
        def initialize(app, env)
          @app = app
        end

        def call(env)
          remove env[:vm]
          @app.call(env)
        end

        protected
          def remove(vm)
            # TODO: need to pass collection of other vms
            Hostmaster::VM.new(vm).remove other_vms
          end
      end
    end
  end
end