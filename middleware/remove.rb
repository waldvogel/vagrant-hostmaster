module Vagrant
  module Hostmaster
    module Middleware
      class Remove
        def initialize(app, env)
          @app = app
        end

        def call(env)
          remove env[:vm] if env["vm"].created?
          @app.call(env)
        end

        protected
          def remove(vm)
            Hostmaster::VM.new(vm).remove(:guests => false)
          end
      end
    end
  end
end